#!/usr/bin/env python3
"""Fresh analytical derivation-extension checks with mandatory independent MG checks."""
import argparse,json,os
from pathlib import Path
import workflow,verify_assembly,derivation_checks,madgraph_checks
from conventions import check_conventions
from derivation_support import runtime_for_checks
from native_evidence import snapshot_derivation_evidence
from support import Blocked,read,write,sha,snapshot,release_integrity,baseline_check,retained_files,existing_records,execute,access,execution_context,output_path
ROOT=Path(__file__).resolve().parent
SCOPE=('Born/one-loop leading-power Collins ep in the declared diagonal homogeneous twist-three approximation. '
       'Native derivation records, independent finite coefficient comparisons, convention evidence, fresh dependency probes and native MadGraph amplitudes. '
       'CHECKS_PASS remains subject to source review; no fitted-provider, Figure 6, full-mixing or nonsingular-NLO certification.')
NEW_IDS={'d13','d14','d15'}

def compare_runs(a,b,production):
    a,b=access(a),access(b)
    if a==b:raise ValueError('Distinct fresh runs required')
    manifests=[]
    required={s['id'] for s in workflow.stage_list()}
    for path in (a,b):
        m,done=workflow.audit_run(path,production)
        if set(done)!=required or m.get('status')!='STAGES_PASS':raise Blocked('Complete both runs through d15')
        if m.get('resumed') is not False or any(x.get('no_cache_requested') is not True for x in done.values()):raise ValueError('Acceptance needs clean non-resumed runs')
        manifests.append(m)
    if manifests[0]['run_id']==manifests[1]['run_id']:raise ValueError('Repeated run identity')
    for field in ('source_sha256','runtime','validator_manifest_sha256','baseline_before','baseline_after'):
        if manifests[0].get(field)!=manifests[1].get(field):raise ValueError('Fresh run inputs differ: '+field)
    verify_assembly.compare_new_runs(a,b,production)
    count=0
    for stage in workflow.stage_list():
        if stage['id'] not in NEW_IDS:continue
        for name in stage['artifacts']:
            x=a/'common'/(stage['id']+'_result')/name;y=b/'common'/(stage['id']+'_result')/name
            equal=read(x)==read(y) if name.endswith('.json') else x.read_bytes()==y.read_bytes()
            if not equal:raise ValueError('Non-deterministic new derivation artifact: '+stage['id']+'/'+name)
            count+=1
    return {'id':'derivation.clean_replay','status':'PASS','run_paths':[str(a),str(b)],
            'run_ids':[m['run_id'] for m in manifests],'run_manifest_sha256':[sha(p/'run.json') for p in (a,b)],'new_artifacts':count}

def combine_status(checks):
    if type(checks) is not list or any(type(c) is not dict for c in checks):return 'FAIL'
    ids=[c.get('id') for c in checks]
    if not checks or any(not isinstance(x,str) or not x for x in ids) or len(ids)!=len(set(ids)):
        return 'FAIL'
    states={c.get('status') for c in checks}
    if states-{'PASS','FAIL','BLOCKED'} or 'FAIL' in states:return 'FAIL'
    return 'BLOCKED' if 'BLOCKED' in states else 'CHECKS_PASS'

def verify(args):
    repo=Path(args.repo).resolve();production=repo/'collins_ep_analytic';run=access(args.run)
    replay=access(args.replay) if args.replay else None
    report=output_path(args.report,repo,protected=[ROOT,run]+([replay] if replay else []),area='reports')
    if report.exists():raise ValueError('Choose a new report path')
    work=report.with_name(report.stem+'-evidence')
    if work.exists():raise ValueError('Choose a new evidence path')
    work.mkdir(parents=True);checks=[]
    result={'schema':3,'profile':'derivation','scope':SCOPE,'seed':args.seed,'checks':checks,
            'status':'BLOCKED','source_review':'REQUIRED','numerical_regression':'NOT_REQUESTED_ANALYTICAL_ONLY',
            'paper':'BLOCKED','nlo':'BLOCKED'}
    try:
        result['validator_manifest_sha256']=release_integrity(ROOT)
        if type(args.seed) is not int or not 0<=args.seed<2**64:raise ValueError('Seed must be uint64')
        before=baseline_check(repo,args.numerical_state);numeric=snapshot(repo/'collins_ep');history=existing_records(args.numerical_state)
        m,done=workflow.audit_run(run,production)
        result.update(run=str(run),run_id=m['run_id'],run_manifest_sha256=sha(run/'run.json'),sources=m['source_sha256'],runtime=m['runtime'],baseline_before=before)
        if replay is None:raise Blocked('A distinct clean --replay run is mandatory')
        checks.append(compare_runs(run,replay,production))
        checks.extend(check_conventions(run))
        rt=runtime_for_checks(m)
        # Fresh proof checks write only outside the sealed runs.
        for stage in workflow.stage_list():
            if stage['id'] not in NEW_IDS:continue
            sid=stage['id'];out=work/sid;out.mkdir()
            context={'run_id':m['run_id'],'stage':sid,'production':str(production),'runtime':m['runtime']['config']}
            packet=run/'common'/(sid+'_result')/'proofs.wl'
            context.update(proof_ids=stage['proof_ids'],proof_file=str(packet),proof_report=str(out/'proof-check.json'))
            cp=out/'proof-context.json';write(cp,execution_context(context))
            env=os.environ.copy();env['COLLINS_ANALYTIC_CONTEXT']=str(cp)
            ex=execute([rt['wolfram_kernel'],'-noprompt','-script',str(ROOT/'check_proofs.wls')],production,out/'proof.log',min(rt['stage_timeout_seconds'],1800),env)
            proof=read(out/'proof-check.json')
            if ex['exit_code']!=0 or proof.get('status')!='PASS' or proof.get('stage')!=sid or proof.get('run_id')!=m['run_id'] or sorted(proof.get('proof_ids',[]))!=sorted(stage['proof_ids']):raise ValueError('Fresh derivation proof replay failed: '+sid)
            checks.append({'id':'derivation.proof.'+sid,'status':'PASS','execution':ex,'proof_sha256':sha(packet)})
        # All numerical arithmetic here is perturbative/synthetic; no fitted providers.
        for name,rows in [('derivation',derivation_checks.run_checks(repo,run,rt,work/'derivation',args.seed)),
                          ('madgraph',madgraph_checks.run_checks(repo,run,rt,work/'madgraph',args.seed))]:
            if type(rows) is not list or not rows or any(type(c) is not dict for c in rows):
                raise ValueError('Mandatory '+name+' checks returned no valid records')
            checks.extend(rows)
        fa=argparse.Namespace(**vars(args));fa.profile='analytic_assembly';fa.report=str(work/'assembly.json')
        rc=verify_assembly.verify(fa);old=read(fa.report)
        result['assembly_report']={'path':fa.report,'sha256':sha(fa.report)}
        if rc==0 and old.get('status')=='CHECKS_PASS':
            if (old.get('profile')!='analytic_assembly' or old.get('seed')!=args.seed
                or old.get('sources')!=result['sources'] or old.get('runtime')!=result['runtime']
                or old.get('run')!=str(run) or combine_status(old.get('checks'))!='CHECKS_PASS'):
                raise ValueError('Retained analytical acceptance returned incomplete or wrong-scope evidence')
        checks.extend({**c,'id':'retained.'+c['id']} for c in old.get('checks',[]))
        checks.append({'id':'derivation.retained_analytic_assembly','status':'PASS' if rc==0 and old.get('status')=='CHECKS_PASS' else ('BLOCKED' if old.get('status')=='BLOCKED' else 'FAIL'),'detail':fa.report})
        result['status']=combine_status(checks)
    except Exception as exc:
        result['status']='BLOCKED' if isinstance(exc,(Blocked,FileNotFoundError)) else 'FAIL';result['detail']=str(exc)
        if any(c.get('status')=='FAIL' for c in checks):result['status']='FAIL'
    if 'before' in locals():
        try:
            retained_files(args.numerical_state,history);retained_files(repo/'collins_ep',numeric)
            after=baseline_check(repo,args.numerical_state);result['baseline_after']=after
            if after!=before or snapshot(repo/'collins_ep')!=numeric:raise ValueError('Protected inputs changed')
            if 'm' in locals():workflow.audit_run(run,production)
            if replay is not None and 'm' in locals():workflow.audit_run(replay,production)
        except Exception as exc:result['status']='FAIL';result['preservation_error']=str(exc)
    if any(type(c) is not dict or not isinstance(c.get('id'),str) for c in checks) or len({c['id'] for c in checks})!=len(checks):result['status']='FAIL';result['detail']='Invalid or duplicate check IDs'
    try:
        result['evidence_files']=snapshot_derivation_evidence(work)
    except Exception as exc:
        result['status']='FAIL'
        result['evidence_files']=None
        result['evidence_capture_error']=str(exc)
    write(report,result)
    print(json.dumps({'status':result['status'],'checks':len(checks),'report':str(report),'scope':SCOPE}))
    return 0 if result['status']=='CHECKS_PASS' else 2 if result['status']=='BLOCKED' else 1

def parser():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--repo',default='/bigTMD');p.add_argument('--run',required=True);p.add_argument('--replay')
    p.add_argument('--seed',type=int,default=1729);p.add_argument('--report',required=True)
    p.add_argument('--numerical-state',default='/bigTMD/collins_support/baselines/SIDIS-validation-state')
    # Retained parser compatibility; analytical profile never executes these providers.
    p.add_argument('--numerical-validator',default='/bigTMD/collins_support/validators/numerical');p.add_argument('--numerical-timeout',type=int,default=7200);p.add_argument('--timeout',type=int,default=3600)
    return p

def main():
    try:return verify(parser().parse_args())
    except Exception as exc:print(json.dumps({'status':'FAIL','detail':str(exc)}));return 1
if __name__=='__main__':raise SystemExit(main())
