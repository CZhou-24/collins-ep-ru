#!/usr/bin/env python3
"""Acceptance for executed s00–s12. No paper/full-NLO profile is implemented."""
import argparse,json,os,sys,uuid
from pathlib import Path
import verify as foundation
from support import *
from workflow import audit_run as audit_all,stage_list as stages_all,proof_check

RETAINED_STAGE_IDS = frozenset(f"s{i:02d}" for i in range(13))

def stage_list(): return [s for s in stages_all() if s["id"] in RETAINED_STAGE_IDS]
def audit_run(run,production):
    m,done=audit_all(run,production)
    return m,{k:v for k,v in done.items() if k in RETAINED_STAGE_IDS}
from assembly_oracle import coefficients,requests,compare_response
import bridge_probes

ROOT=Path(__file__).resolve().parent
SCOPE=('One-loop leading-power, narrow-jet, azimuthally averaged operator assembly with external renormalized TMD inputs. '
       'Independent coefficient/real-projection/integral checks plus supplied-proof replay and provenance; source review required. '
       'No exact finite-R, complete small-b OPE/mixing, matched phenomenology, Figure 6, or full polarized NLO acceptance.')
SEMANTIC={'s10':['real_amplitudes.wl','real_functions.wl','measurement.wl','regulated_integrals.wl','families.wl','reduction.wl','master_inputs.wl','masters.wl','radiation.wl','radiation.json','primitives.wl'],
          's11':['operator_definitions.wl','operator_diagrams.wl','operator_integrals.wl','operators.wl','operators.json'],
          's12':['assembly.wl','assembly.json','operators.json','born_hard.json','spacelike_hard_one_loop.json','accuracy_ledger.json']}
ACCURACY={'schema':2,'power_accuracy':'leading_power_qT_over_Q_and_jT_over_pTR',
          'radius':'leading_narrow_jet_terms_only','azimuth':'averaged_soft_sectors','perturbative_order':'one_loop_coefficients',
          'inputs':'external_renormalized_TMDs','small_b_finite_OPE':False,'full_twist3_mixing':False,
          'paper':False,'full_nlo':False,'finite_R_certified':False}

def compare_new_runs(a,b,production):
    a,b=access(a),access(b)
    ma,da=audit_run(a,production);mb,db=audit_run(b,production)
    needed={s['id'] for s in stage_list()}
    if set(da)!=needed or set(db)!=needed:raise Blocked('Two complete s00–s12 runs are required')
    if any(r.get('no_cache_requested') is not True for r in [*da.values(),*db.values()]):raise ValueError('Assembly replay includes cache-enabled stages')
    # Retained comparer checks freshness, no resume/cache, sources, runtime and foundation expressions.
    foundation.compare_runs(a,b,production)
    count=0
    for sid,names in SEMANTIC.items():
        for name in names:
            pa=Path(a)/'common'/f'{sid}_result'/name;pb=Path(b)/'common'/f'{sid}_result'/name
            equal=read(pa)==read(pb) if name.endswith('.json') else pa.read_bytes()==pb.read_bytes()
            if not equal:raise ValueError('Fresh new-stage semantic output differs: '+sid+'/'+name)
            count+=1
    return {'id':'assembly.clean_replay','status':'PASS','new_canonical_outputs':count,
            'run_paths':[str(Path(a).resolve()),str(Path(b).resolve())],
            'runs':[ma['run_id'],mb['run_id']],'run_manifest_sha256':[sha(Path(a)/'run.json'),sha(Path(b)/'run.json')]}

def backend_evidence(run,runtime):
    root=access(run)/'common'/'s10_result';p=read(root/'backend_jobs.json')
    if type(p) is not dict or set(p)!={'schema','jobs'} or p['schema']!=2 or type(p['jobs']) is not list:raise ValueError('Wrong backend evidence schema')
    seen=set()
    for job in p['jobs']:
        if type(job) is not dict or set(job)!={'backend','purpose','argv','exit_code','inputs','outputs','log'}:raise ValueError('Wrong backend job schema')
        name=job['backend']
        if name not in ('kira','subtropica') or name in seen:raise ValueError('Require exactly one documented primary job per backend')
        seen.add(name)
        if type(job['exit_code']) is not int or job['exit_code']!=0 or not isinstance(job['purpose'],str) or len(job['purpose'])<20:raise ValueError('Incomplete backend execution')
        argv=job['argv']
        if type(argv) is not list or len(argv)<2 or not all(isinstance(x,str) and x for x in argv) or any(x in ('--version','-v','--help') for x in argv):raise ValueError('A version query is not a calculation')
        expected=runtime['kira' if name=='kira' else 'wolfram_kernel']
        if not same_path(argv[0],expected):raise ValueError('Wrong recorded backend executable')
        for group in ('inputs','outputs'):
            files=job[group]
            if type(files) is not dict or not files:raise ValueError('Missing actual backend '+group)
            for rel,digest in files.items():
                file=relative_file(root,rel)
                if not file.stat().st_size or sha(file)!=digest:raise ValueError('Missing/changed backend file')
        log=relative_file(root,job['log'])
        if log.name!=('kira.log' if name=='kira' else 'subtropica.log') or log.stat().st_size<20:raise ValueError('Missing actual backend log')
    if seen!={'kira','subtropica'}:raise ValueError('Missing real-reduction/master backend evidence')
    return {'id':'assembly.backend_records','status':'PASS','scope':'Hashed job records; actual scientific content remains subject to source review'}

def producer_map(run):
    run=access(run);out=run/'common'/'s12_result';p=read(out/'derivation_map.json')
    expected={'radiation':'common/s10_result/radiation.wl','operators':'common/s11_result/operators.wl',
              'assembly':'common/s12_result/assembly.wl','HUU':'common/s03_result/tensors.wl',
              'HUT':'common/s03_result/tensors.wl','hard1':'common/s07_result/hard.wl',
              'real_eq':'common/s10_result/real_amplitudes.wl','real_eg':'common/s10_result/real_amplitudes.wl',
              'primitives':'common/s10_result/masters.wl'}
    if type(p) is not dict or set(p)!={'schema','entries','external_inputs'} or p['schema']!=2 or type(p['entries']) is not dict or set(p['entries'])!=set(expected) or type(p['external_inputs']) is not list:
        raise ValueError('Wrong derivation map')
    for key,path in expected.items():
        row=p['entries'][key]
        if type(row) is not dict or set(row)!={'artifact','sha256','description'} or row['artifact']!=path or not isinstance(row['description'],str) or not row['description'].strip():raise ValueError('Wrong producer entry '+key)
        if sha(relative_file(run,path))!=row['sha256']:raise ValueError('Wrong producer hash '+key)
    for name,stage in [('operators.json','s11'),('born_hard.json','s09'),('spacelike_hard_one_loop.json','s09')]:
        if sha(out/name)!=sha(run/'common'/f'{stage}_result'/name):raise ValueError('Copied input differs: '+name)
    if read(out/'accuracy_ledger.json')!=ACCURACY:raise ValueError('Unsupported accuracy claim or missing ledger')
    return {'id':'assembly.producer_map','status':'PASS'}

def verify(args):
    repo=Path(args.repo).resolve();production=repo/'collins_ep_analytic';run=access(args.run)
    report=output_path(args.report,repo,protected=(ROOT,run,*([access(args.replay)] if args.replay else [])),area='reports')
    if report.is_relative_to(production) or report.is_relative_to(run):raise ValueError('Write acceptance outside source and run directories')
    if args.replay and report.is_relative_to(access(args.replay)):raise ValueError('Write acceptance outside the replay run directory')
    if report.exists():raise ValueError('Report exists; choose a fresh report path')
    work=report.with_name(report.stem+'-evidence')
    if work.exists():raise ValueError('Evidence directory exists; choose a fresh report path')
    work.mkdir(parents=True);checks=[]
    result={'schema':2,'profile':args.profile,'seed':args.seed,'scope':SCOPE,'status':'BLOCKED','checks':checks,'paper':'BLOCKED','nlo':'BLOCKED'}
    try:
        result['validator_manifest_sha256']=release_integrity(ROOT)
        if args.profile in ('paper','nlo'):raise Blocked('No paper or full-NLO acceptance in this release')
        if type(args.seed) is not int or not 0<=args.seed<2**64:raise ValueError('Seed must be uint64')
        before=baseline_check(repo,args.numerical_state);numeric=snapshot(repo/'collins_ep');history=existing_records(args.numerical_state)
        m,done=audit_run(run,production)
        if set(done)!={s['id'] for s in stage_list()} or m.get('status')!='STAGES_PASS' or m.get('baseline_after')!=before:raise Blocked('Complete s00–s12 and preservation gates first')
        result.update(run_id=m['run_id'],run=str(run),run_manifest_sha256=sha(run/'run.json'),sources=m['source_sha256'],runtime=m['runtime'],baseline_before=before)
        if not args.replay:raise Blocked('Assembly acceptance requires a distinct clean --replay run')
        checks.append(compare_new_runs(run,args.replay,production));rt=execution_context(m['runtime']['config'])
        checks.append(backend_evidence(run,rt));checks.append(producer_map(run))
        rad=read(run/'common/s10_result/radiation.json');op=read(run/'common/s11_result/operators.json');ass=read(run/'common/s12_result/assembly.json')
        checks.extend(coefficients(rad,op,ass,args.seed))
        if any(c['status']=='FAIL' for c in checks):raise ValueError('New coefficient/assembly checks failed')
        for stage in stage_list():
            if int(stage['id'][1:])<10:continue
            target=work/stage['id'];target.mkdir()
            context={'run_id':m['run_id'],'stage':stage['id'],'runtime':rt,'production':str(production)}
            # Required proof file remains immutable in the run, while replay output is fresh.
            pc={**context,'proof_ids':stage['proof_ids'],'proof_file':str(run/'common'/f"{stage['id']}_result"/'proofs.wl'),'proof_report':str(target/'proof-check.json')}
            cp=target/'context.json';write(cp,execution_context(pc));env=os.environ.copy();env['COLLINS_ANALYTIC_CONTEXT']=str(cp)
            ex=execute([rt['wolfram_kernel'],'-noprompt','-script',str(ROOT/'check_proofs.wls')],production,target/'proof.log',1800,env)
            proof=read(target/'proof-check.json') if (target/'proof-check.json').is_file() else {}
            if ex['exit_code']!=0 or proof.get('status')!='PASS' or proof.get('run_id')!=m['run_id'] or proof.get('stage')!=stage['id'] or not foundation.valid_proof_ids(proof.get('proof_ids'),stage['proof_ids']):raise ValueError('Fresh proof replay failed: '+stage['id'])
            checks.append({'id':'assembly.proof.'+stage['id'],'status':'PASS','identities':len(stage['proof_ids']),'report_sha256':sha(target/'proof-check.json')})
        nonce=uuid.uuid4().hex;req=requests(args.seed)
        packets={key:str(run/'common'/f'{stage}_result'/file) for key,stage,file in [
            ('radiation','s10','radiation.wl'),('operators','s11','operators.wl'),('assembly','s12','assembly.wl'),
            ('real','s10','real_functions.wl'),('primitives','s10','primitives.wl')]}
        cp=work/'context.json';write(cp,{'run_id':nonce,'runtime':rt,'requests':req,'packets':packets,'response':str(work/'response.json')})
        env=os.environ.copy();env['COLLINS_ANALYTIC_CONTEXT']=str(cp)
        ex=execute([rt['wolfram_kernel'],'-noprompt','-script',str(ROOT/'evaluate_assembly.wls')],production,work/'evaluate.log',args.timeout,env)
        if ex['exit_code']!=0:raise ValueError('Fresh new Wolfram evaluation failed')
        checks.extend(compare_response(req,read(work/'response.json'),nonce))
        result['wolfram_evaluation']=ex
        bridge_req=[r for r in req if r['kind']=='gaussian' or (r['kind']=='coefficient' and r['source'] in ('operators','assembly'))]
        bp=work/'bridge-requests.json';write(bp,{'run_id':nonce,'requests':bridge_req})
        bridge=relative_file(production,'numerics/evaluate_assembly.py')
        ex=execute([sys.executable,str(bridge),'--export-dir',str(run/'common/s12_result'),'--requests',str(bp)],production,work/'bridge-response.json',args.timeout)
        if ex['exit_code']!=0:raise ValueError('Generated assembly bridge failed')
        checks.extend(compare_response(bridge_req,read(work/'bridge-response.json'),nonce,'bridge'))
        result['bridge_execution']=ex
        checks.extend(bridge_probes.run(production,run/'common/s12_result',work,args.seed,nonce,args.timeout))
        if any(c['status']=='FAIL' for c in checks):raise ValueError('New evaluated physics checks failed')
        # Both profiles replay retained analytical checks freshly. Only the historical
        # assembly profile requests the unchanged 457-check fitted regression.
        fa=argparse.Namespace(**vars(args));fa.profile='analytic_foundation' if args.profile=='analytic_assembly' else 'foundation';fa.report=str(work/'foundation.json')
        if args.profile=='analytic_assembly': result['numerical_regression']='NOT_REQUESTED_ANALYTICAL_ONLY'
        rc=foundation.verify(fa);fr=read(fa.report)
        if rc!=0 or fr.get('status')!='CHECKS_PASS':
            if fr.get('status')=='BLOCKED':raise Blocked('Retained foundation acceptance blocked; see '+fa.report)
            raise ValueError('Retained foundation acceptance failed; see '+fa.report)
        result['foundation_report']={'path':fa.report,'sha256':sha(fa.report),'checks':len(fr['checks'])}
        for c in fr['checks']:checks.append({**c,'id':'retained.'+c['id']})
        result['status']='CHECKS_PASS'
    except Exception as exc:
        result['status']='BLOCKED' if isinstance(exc,(Blocked,FileNotFoundError)) else 'FAIL';result['detail']=str(exc)
        if any(c.get('status')=='FAIL' for c in checks):result['status']='FAIL'
    if 'before' in locals():
        try:
            retained_files(args.numerical_state,history);retained_files(repo/'collins_ep',numeric)
            after=baseline_check(repo,args.numerical_state);result['baseline_after']=after
            if after!=before or snapshot(repo/'collins_ep')!=numeric:raise ValueError('Protected numerical/original inputs changed')
            if 'm' in locals():audit_run(run,production)
        except Exception as exc:result['status']='FAIL';result['preservation_error']=str(exc)
    ids=[c['id'] for c in checks]
    if len(ids)!=len(set(ids)):result['status']='FAIL';result['detail']='Duplicate check IDs'
    try:result['evidence_files']=snapshot(work)
    except Exception as exc:result['status']='FAIL';result['evidence_error']=str(exc)
    write(report,result);print(json.dumps({'status':result['status'],'checks':len(checks),'report':str(report),'scope':SCOPE}))
    return 0 if result['status']=='CHECKS_PASS' else (2 if result['status']=='BLOCKED' else 1)

def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--repo',default='/bigTMD');p.add_argument('--run',required=True);p.add_argument('--replay');p.add_argument('--profile',choices=['assembly','analytic_assembly','paper','nlo'],default='assembly');p.add_argument('--seed',type=int,default=1729);p.add_argument('--report',required=True);p.add_argument('--numerical-validator',default='/bigTMD/collins_support/validators/numerical');p.add_argument('--numerical-state',default='/bigTMD/collins_support/baselines/SIDIS-validation-state');p.add_argument('--numerical-timeout',type=int,default=7200);p.add_argument('--timeout',type=int,default=3600)
    a=p.parse_args()
    try:return verify(a)
    except Exception as exc:print(json.dumps({'status':'FAIL','detail':str(exc)}));return 1
if __name__=='__main__':raise SystemExit(main())
