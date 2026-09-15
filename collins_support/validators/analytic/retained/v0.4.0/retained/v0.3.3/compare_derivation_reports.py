#!/usr/bin/env python3
"""Replay saved arithmetic, identities and exact coverage of two derivation reports."""
import argparse,json
from pathlib import Path
import derivation_checks as dc,madgraph_checks as mg,compare_assembly_reports as old,workflow
from verify_derivation import SCOPE,NEW_IDS,compare_runs,combine_status
from conventions import check_conventions
from native_evidence import snapshot_derivation_evidence
from support import read,write,sha,snapshot,release_integrity,relative_file,access,same_path,same_release
ROOT=Path(__file__).resolve().parent

def check_report(repo,path,release):
    path=access(path);r=read(path);work=path.with_name(path.stem+'-evidence')
    if (r.get('schema')!=3 or r.get('profile')!='derivation' or r.get('status')!='CHECKS_PASS' or r.get('scope')!=SCOPE or
        not same_release(ROOT,r.get('validator_manifest_sha256')) or r.get('source_review')!='REQUIRED' or
        r.get('numerical_regression')!='NOT_REQUESTED_ANALYTICAL_ONLY' or r.get('paper')!='BLOCKED' or r.get('nlo')!='BLOCKED'):
        raise ValueError('Incomplete or wrong-scope derivation report')
    checks=r.get('checks');
    if not isinstance(checks,list) or combine_status(checks)!='CHECKS_PASS':raise ValueError('Incomplete/duplicate/failed check rows')
    if snapshot_derivation_evidence(work)!=r.get('evidence_files'):raise ValueError('Acceptance evidence changed')
    saved={c['id']:c for c in checks};run=access(r['run']);production=Path(repo).resolve()/'collins_ep_analytic'
    m,_=workflow.audit_run(run,production)
    if r['sources']!=m['source_sha256'] or r['runtime']!=m['runtime'] or r['run_id']!=m['run_id'] or r['run_manifest_sha256']!=sha(run/'run.json'):
        raise ValueError('Report no longer matches source/runtime/run')
    if r.get('baseline_before')!=m['baseline_before'] or r.get('baseline_after')!=m['baseline_after']:raise ValueError('Baseline metadata differs')
    replay=saved.get('derivation.clean_replay',{});paths=replay.get('run_paths',[])
    if len(paths)!=2 or not same_path(paths[0],run):raise ValueError('Wrong fresh run pair')
    fresh=compare_runs(*paths,production)
    if ({k:v for k,v in replay.items() if k!='run_paths'}!={k:v for k,v in fresh.items() if k!='run_paths'}
        or len(fresh.get('run_paths',[]))!=2 or not all(same_path(a,b) for a,b in zip(paths,fresh['run_paths']))):raise ValueError('Changed fresh-run evidence')
    arithmetic=check_conventions(run)+dc.replay_checks(run,work/'derivation',r['seed'])+mg.replay_checks(work/'madgraph',r['seed'])
    if combine_status(arithmetic)!='CHECKS_PASS':raise ValueError('Saved arithmetic/native evidence replay failed')
    need={'derivation.clean_replay','derivation.retained_analytic_assembly'}
    for row in arithmetic:
        if row['id'].startswith('replay.'):continue
        need.add(row['id'])
        if saved.get(row['id'])!=row:raise ValueError('Reported arithmetic does not equal replayed evidence: '+row['id'])
    for kind in ('qq_epsilon','qg_epsilon'):
        work2=work/'derivation'/('upstream-'+kind)
        scope=read(work2/'SCOPE.json');lib=production/'common/d13_matching_library.wl'
        if scope.get('library_sha256')!=sha(lib):raise ValueError('Upstream library identity changed')
        id='upstream.'+kind+'.library_unchanged';need.add(id)
        if saved.get(id)!=dc.row(id,True):raise ValueError('Missing upstream library identity check')
        for name in ('projections.wl','regulated_integrals.wl','subtractions.wl'):
            id='upstream.'+kind+'.regenerated.'+name;need.add(id)
            if saved.get(id)!=dc.row(id,relative_file(work2,name).stat().st_size>0):raise ValueError('Missing upstream artifact check')
    for stage in workflow.stage_list():
        sid=stage['id']
        if sid not in NEW_IDS:continue
        id='derivation.proof.'+sid;need.add(id);row=saved.get(id,{})
        proof=read(work/sid/'proof-check.json');ex=row.get('execution',{})
        if (proof.get('status')!='PASS' or proof.get('stage')!=sid or proof.get('run_id')!=m['run_id'] or
            sorted(proof.get('proof_ids',[]))!=sorted(stage['proof_ids']) or ex.get('exit_code')!=0 or
            ex.get('log_sha256')!=sha(work/sid/'proof.log') or row.get('proof_sha256')!=sha(run/'common'/(sid+'_result')/'proofs.wl')):
            raise ValueError('Fresh native proof evidence incomplete: '+sid)
    ar=r.get('assembly_report',{});ap=work/'assembly.json'
    if not same_path(ar.get('path',''),ap) or ar.get('sha256')!=sha(ap):raise ValueError('Wrong retained report identity')
    assembly=read(ap)
    if assembly.get('profile')!='analytic_assembly' or assembly.get('seed')!=r['seed'] or assembly.get('sources')!=r['sources'] or assembly.get('runtime')!=r['runtime'] or assembly.get('run')!=r['run']:
        raise ValueError('Wrong retained report scope/inputs')
    for row in assembly.get('checks',[]):
        key='retained.'+row['id'];need.add(key)
        if saved.get(key)!={**row,'id':key}:raise ValueError('Changed retained check row')
    if set(saved)!=need:raise ValueError('Missing or extra derivation checks')
    retained=saved['derivation.retained_analytic_assembly']
    if ({k:v for k,v in retained.items() if k!='detail'}!={'id':'derivation.retained_analytic_assembly','status':'PASS'}
        or not same_path(retained.get('detail',''),ap)):raise ValueError('Wrong retained acceptance record')
    return r,ap

def compare(repo,paths):
    if len(paths)!=2 or same_path(paths[0],paths[1]):raise ValueError('Two distinct reports required')
    release=release_integrity(ROOT);items=[check_report(repo,p,release) for p in paths];reports=[x[0] for x in items]
    if {r.get('seed') for r in reports}!={1729,92741}:raise ValueError('Final seeds must be 1729 and 92741')
    for key in ('sources','runtime','run','run_manifest_sha256'):
        if reports[0][key]!=reports[1][key]:raise ValueError('Final report inputs differ')
    replay=[[c for c in r['checks'] if c['id']=='derivation.clean_replay'][0] for r in reports]
    if replay[0]!=replay[1]:raise ValueError('Final replay pairs differ')
    old.compare(repo,[x[1] for x in items])
    return {'schema':3,'status':'CHECKS_PASS','profile':'derivation','scope':SCOPE,'source_review':'REQUIRED','seeds':[1729,92741],
            'validator_manifest_sha256':release,'reports':[{'path':str(access(p)),'sha256':sha(p)} for p in paths]}

def guard_output(repo,dest,paths):
    dest=old.guard_output(repo,dest,paths)
    protected=[ROOT]
    for path in paths:
        for row in read(path).get('checks',[]):
            if row.get('id')=='derivation.clean_replay':protected.extend(access(p) for p in row.get('run_paths',[]))
    if any(dest.is_relative_to(p) for p in protected):raise ValueError('Pair output cannot modify validator or replay runs')
    return dest

def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--repo',default='/bigTMD');p.add_argument('--report',required=True);p.add_argument('reports',nargs=2);a=p.parse_args()
    try:
        dest=guard_output(a.repo,a.report,a.reports)
    except Exception as exc:
        print(json.dumps({'status':'FAIL','detail':str(exc)}));return 1
    try:
        result=compare(a.repo,a.reports);rc=0
    except Exception as exc:
        result={'schema':3,'profile':'derivation','status':'FAIL','detail':str(exc)};rc=1
    write(dest,result);print(json.dumps(result,indent=2));return rc
if __name__=='__main__':raise SystemExit(main())
