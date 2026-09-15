#!/usr/bin/env python3
"""Replay both sealed NLO reports and the unchanged retained official pair."""
import argparse,json,sys
from pathlib import Path
from nlo_support import *
from verify_nlo import SCOPE,QUALIFICATIONS,replay_rows,fresh_pair,guard

def check(repo,path):
    path=access(path);r=read(path);work=path.with_name(path.stem+'-evidence')
    release_integrity()
    if (r.get('schema')!=4 or r.get('profile')!='leading_power_nlo_extension' or r.get('scope')!=SCOPE
       or r.get('qualifications')!=QUALIFICATIONS or r.get('status')!='CHECKS_PASS'
       or not same_release(ROOT,r.get('release_sha256'))):raise ValueError('invalid report or promoted scope')
    if r['seed'] not in (1729,92741) or status(r['checks'])!='CHECKS_PASS':raise ValueError('invalid report rows/seed')
    if r['evidence_snapshot']!=snapshot(work):raise ValueError('changed NLO evidence')
    ma,mb=fresh_pair(repo,r['run'],r['replay'])
    if r['sources']!=ma['sources'] or r['runtime']!=ma['runtime'] or r['run_manifest_sha256']!=sha(Path(r['run'])/'run.json') or r['replay_manifest_sha256']!=sha(Path(r['replay'])/'run.json'):
        raise ValueError('report identity mismatch')
    br=work/'retained.json'
    if not same_path(r['retained']['path'],br) or r['retained']['sha256']!=sha(br) or r['retained']['execution']['exit_code']!=0 or r['retained']['execution']['log_sha256']!=sha(work/'retained.log'):raise ValueError('retained evidence identity changed')
    old=read(br)
    if old.get('seed')!=r['seed'] or old.get('run')!=ma['base_run'] or old.get('status')!='CHECKS_PASS':raise ValueError('wrong retained report')
    if replay_rows(repo,r['run'],r['replay'],work,r['seed'])!=r['checks']:raise ValueError('checks differ from fresh arithmetic replay')
    return r,br

def compare(a):
    repo=Path(a.repo).resolve();paths=[access(p) for p in a.reports]
    if len(set(paths))!=2:raise ValueError('two distinct reports required')
    # Guard every output before creating it, even when an input is malformed.
    protected=[repo,ROOT,*paths]
    for path in paths:
        r=read(path)
        for k in ('run','replay'):
            if k in r:
                protected.append(access(r[k]));m=read(access(r[k])/'run.json')
                if 'base_run' in m:protected.append(access(m['base_run']))
        protected.append(path.with_name(path.stem+'-evidence'))
    dest=outside(a.report,protected,new=True);work=dest.with_name(dest.stem+'-evidence');outside(work,protected,new=True);work.mkdir(parents=True)
    result={'schema':4,'profile':'leading_power_nlo_extension','scope':SCOPE,'qualifications':QUALIFICATIONS,'status':'FAIL'}
    try:
        pairs=[check(repo,p) for p in paths];rs=[x[0] for x in pairs]
        if {r['seed'] for r in rs}!={1729,92741}:raise ValueError('need both official seeds')
        for key in ('sources','runtime','run','replay','release_sha256','run_manifest_sha256','replay_manifest_sha256'):
            if rs[0][key]!=rs[1][key]:raise ValueError('different pair inputs '+key)
        oldout=work/'retained-pair.json'
        ex=execute([sys.executable,BASE/'compare_derivation_reports.py','--repo',repo,'--report',oldout,*[x[1] for x in pairs]],repo,work/'retained-pair.log',86400)
        if ex['exit_code']!=0 or read(oldout).get('status')!='CHECKS_PASS':raise ValueError('retained official pair replay failed')
        result.update(status='CHECKS_PASS',seeds=[1729,92741],release_sha256=release_integrity(),
          reports=[{'path':str(p),'sha256':sha(p)} for p in paths],retained_pair={'sha256':sha(oldout),'execution':ex})
    except Exception as exc:result['detail']=str(exc)
    result['evidence_snapshot']=snapshot(work);write(dest,result);print(json.dumps(result,indent=2))
    return 0 if result['status']=='CHECKS_PASS' else 1

def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--repo',default='/bigTMD');p.add_argument('--report',required=True);p.add_argument('reports',nargs=2)
    try:return compare(p.parse_args())
    except Exception as e:print(json.dumps({'status':'FAIL','detail':str(e)}));return 1
if __name__=='__main__':raise SystemExit(main())
