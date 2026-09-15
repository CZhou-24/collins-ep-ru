#!/usr/bin/env python3
"""Replay both RU reports and their evidence; do not count reported PASS labels."""
import argparse,json
from pathlib import Path
from ru_support import *
from verify_ru import replay_rows, pair_inputs

def check_report(repo,path):
    path=access(path);r=read(path);work=path.with_name(path.stem+'-evidence')
    if r.get('schema')!=5 or r.get('profile')!=PROFILE or r.get('status')!='CHECKS_PASS' or r.get('qualifications')!=QUALIFICATIONS or r.get('verification_scope')!=CHECK_SCOPE or not same_release(ROOT,r.get('release')):raise ValueError('wrong RU report identity/scope')
    if r.get('seed') not in (1729,92741) or rows_status(r.get('checks'))!='CHECKS_PASS':raise ValueError('invalid check rows')
    if r['evidence_snapshot']!=snapshot(work):raise ValueError('changed report evidence')
    ma,data=pair_inputs(repo,r['run'],r['replay'])
    if r['sources']!=ma['sources'] or r['runtime']!=ma['runtime'] or r['run_sha256']!=digest(Path(r['run'])/'run.json') or r['replay_sha256']!=digest(Path(r['replay'])/'run.json'):raise ValueError('report bindings changed')
    if replay_rows(repo,r['run'],r['replay'],work,r['seed'])!=r['checks']:raise ValueError('reported rows differ from arithmetic replay')
    return r

def compare(a):
    repo=Path(a.repo).resolve();paths=[access(x) for x in a.reports]
    if len(set(paths))!=2:raise ValueError('two distinct reports required')
    protected=[repo,ROOT,*paths,*[p.with_name(p.stem+'-evidence') for p in paths]]
    reports=[read(p) for p in paths]
    for r in reports:
        if not isinstance(r,dict):continue
        for name in ('run','replay'):
            if isinstance(r.get(name),str) and r[name]:protected.append(access(r[name]))
    dest=output_path(a.report,repo,protected=protected,area='reports');work=dest.with_name(dest.stem+'-evidence')
    if dest.exists() or work.exists():raise ValueError('choose unused pair output')
    work.mkdir(parents=True)
    result={'schema':5,'profile':PROFILE,'status':'FAIL','qualifications':QUALIFICATIONS,'verification_scope':CHECK_SCOPE}
    try:
        validate_input_statuses(reports)
        rs=[check_report(repo,p) for p in paths]
        if {r['seed'] for r in rs}!={1729,92741}:raise ValueError('both official seeds required')
        for key in ('run','replay','run_sha256','replay_sha256','sources','runtime','release'):
            if rs[0][key]!=rs[1][key]:raise ValueError('pair input mismatch: '+key)
        result.update(status='CHECKS_PASS',seeds=[1729,92741],release=release_integrity(),reports=[{'path':str(p),'sha256':digest(p)} for p in paths])
    except Exception as exc:result.update(error_result(exc)[0])
    result['evidence_snapshot']=snapshot(work);write(dest,result);print(json.dumps(result,indent=2))
    return 0 if result['status']=='CHECKS_PASS' else 2 if result['status']=='BLOCKED' else 1

def validate_input_statuses(reports):
    """An early block is legitimate; a malformed/PASS-shaped report is not."""
    if any(not isinstance(r,dict) or r.get('schema')!=5 or r.get('profile')!=PROFILE
           or r.get('qualifications')!=QUALIFICATIONS or r.get('verification_scope')!=CHECK_SCOPE or r.get('seed') not in (1729,92741)
           or any(not isinstance(r.get(k),str) or not r[k] for k in ('run','replay'))
           or r.get('status') not in ('CHECKS_PASS','BLOCKED','FAIL') for r in reports):
        raise ValueError('invalid RU input report identity/status')
    if {r['seed'] for r in reports}!={1729,92741}:raise ValueError('both official seeds required')
    if any(r['status']=='FAIL' for r in reports):raise ValueError('input RU report is FAIL')
    if any(r['status']=='BLOCKED' for r in reports):
        raise Blocked('input RU report is BLOCKED; complete fresh workflow and verification required')

def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--repo',default=str(PROJECT));p.add_argument('--report',required=True);p.add_argument('reports',nargs=2)
    try:return compare(p.parse_args())
    except Exception as exc:r,c=error_result(exc);print(json.dumps(r));return c
if __name__=='__main__':raise SystemExit(main())
