#!/usr/bin/env python3
"""Fresh independent checks of executed analytic-foundation artifacts."""
import argparse,math,os,sys,uuid
from pathlib import Path
from support import Blocked,baseline_check,execute,read,relative_file,release_integrity,runtime_record,sha,snapshot,write,existing_records,retained_files,access,execution_context,output_path
from workflow import audit_run as audit_all,stage_list as stages_all

RETAINED_STAGE_IDS = frozenset(f"s{i:02d}" for i in range(10))

def stage_list(): return [s for s in stages_all() if s["id"] in RETAINED_STAGE_IDS]
def audit_run(run,production):
    m,done=audit_all(run,production)
    return m,{k:v for k,v in done.items() if k in RETAINED_STAGE_IDS}
from oracle import loads_export,validate_export
from soft_oracle import requests,compare_response,expected
ROOT=Path(__file__).resolve().parent
LEGACY_MANIFEST='3388a5b2dc35e555240f0f908ebab781d1ea1ea757f3aeefd88a090a89712f50'
SCOPE='Coefficient agreement, finite soft-slice checks, execution provenance and replay of implementation-supplied identities. Not an independent proof of complete derivation; no full soft function, paper reproduction or full NLO certification.'
SEMANTIC={
 's02':['definitions.wl'], 's03':['amplitudes.wl','tensors.wl'],
 's04':['integrands.wl'],'s05':['families.wl','reduction.wl'],
 's06':['master_inputs.wl','masters.wl'],
 's07':['bare_virtual.wl','renormalized_virtual.wl','hard.wl'],
 's08':['measurement.wl','soft_pilot.wl'],
 's09':['born_hard.json','spacelike_hard_one_loop.json','coefficients.wl','soft_pilot.wl']}

def compare_runs(first,second,production):
    first,second=access(first),access(second)
    a,done_a=audit_run(first,production);b,done_b=audit_run(second,production)
    needed={s['id'] for s in stage_list()}
    if a['run_id']==b['run_id'] or Path(first).resolve()==Path(second).resolve(): raise ValueError('Replay must be a distinct fresh run')
    if any(m.get('status')!='STAGES_PASS' or m.get('baseline_after')!=m.get('baseline_before') or m.get('resumed') is not False for m in (a,b)):
        raise ValueError('Both replay runs must finish preservation gates and be fresh, without resume')
    if any(r.get('no_cache_requested') is not True for r in [*done_a.values(),*done_b.values()]): raise ValueError('Replay includes cache-enabled stages')
    if set(done_a)!=needed or set(done_b)!=needed: raise ValueError('Both runs must complete all foundation stages')
    if a['source_sha256']!=b['source_sha256'] or a['runtime']!=b['runtime'] or a['baseline_before']!=b['baseline_before']: raise ValueError('Run pair inputs differ')
    differences=[]
    for sid,names in SEMANTIC.items():
        for name in names:
            rel=Path('common')/(sid+'_result')/name
            p,q=Path(first)/rel,Path(second)/rel
            # JSON key ordering is irrelevant, but arrays and every value are retained.
            equal=read(p)==read(q) if name.endswith('.json') else p.read_bytes()==q.read_bytes()
            if not equal: differences.append(str(rel))
    if differences: raise ValueError('Fresh semantic exports differ: '+', '.join(differences))
    return {'id':'replay.semantic_outputs','status':'PASS','compared':sum(map(len,SEMANTIC.values()))}

def verify_derivation_map(export,run):
    data=read(export/'derivation_map.json')
    if set(data)!={'schema','entries','external_inputs'} or data['schema']!=1: raise ValueError('Wrong derivation map schema')
    required={'H_UU','H_UT','h1','soft.kernel','soft.angular_primitive','soft.prefactor','soft.slice'}
    entries=data['entries']
    producers={'H_UU':'common/s03_result/tensors.wl','H_UT':'common/s03_result/tensors.wl','h1':'common/s07_result/hard.wl',**{k:'common/s08_result/soft_pilot.wl' for k in required if k.startswith('soft.')}}
    if not isinstance(entries,dict) or set(entries)!=required or not isinstance(data['external_inputs'],list): raise ValueError('Incomplete derivation map')
    for quantity,entry in entries.items():
        if set(entry)!={'artifact','sha256','description'} or not isinstance(entry['description'],str) or not entry['description'].strip(): raise ValueError('Wrong derivation entry')
        if entry['artifact']!=producers[quantity]: raise ValueError('Wrong upstream producer for '+quantity)
        p=relative_file(run,entry['artifact'])
        if sha(p)!=entry['sha256'] or 's09_result' in p.parts: raise ValueError('Derived export must identify a hashed upstream artifact')
    if sha(export/'soft_pilot.wl')!=sha(Path(run)/'common/s08_result/soft_pilot.wl'): raise ValueError('s09 soft export is not the derived s08 packet')
    return {'id':'derivation.map','status':'PASS','scope':'Links to upstream artifacts; does not prove that their computation is independent'}

def valid_proof_ids(actual,expected):
    return (type(actual) is list and all(type(x) is str for x in actual)
            and len(actual)==len(set(actual)) and set(actual)==set(expected))

def legacy_check(args,work,seed):
    root=access(args.numerical_validator)
    if not (root/'MANIFEST.json').is_file() or sha(root/'MANIFEST.json')!=LEGACY_MANIFEST: raise Blocked('Expected unchanged numerical validator v0.3.0 release')
    release_integrity(root)
    report=work/f'numerical-{seed}.json'; repo=Path(args.repo).resolve()
    adapter=[sys.executable,str(repo/'collins_ep'/'validation_adapter.py')]
    cmd=[sys.executable,str(root/'verify.py'),'check','--repo',str(repo),'--state',str(access(args.numerical_state)),'--adapter-cmd',__import__('json').dumps(adapter),'--profile','evolution','--seed',str(seed),'--timeout','600','--report',str(report)]
    execution=execute(cmd,repo,work/f'numerical-{seed}.log',args.numerical_timeout)
    if execution['exit_code']!=0: raise ValueError('Existing numerical regression failed; see '+str(report))
    r=read(report); checks=r.get('checks',[])
    if r.get('status')!='PASS' or r.get('profile')!='evolution' or r.get('seed')!=seed or len(checks)!=457 or any(x.get('status')!='PASS' for x in checks): raise ValueError('Incomplete numerical regression report')
    return {'id':'numerical.regression','status':'PASS','checks':len(checks),'report_sha256':sha(report),'execution':execution}

def verify(args):
    report=output_path(args.report,args.repo,protected=(ROOT,access(args.run),*([access(args.replay)] if args.replay else [])),area='reports')
    if report.exists(): raise ValueError('Report already exists; choose a new filename')
    work=report.with_name(report.stem+'-evidence')
    if work.exists(): raise ValueError('Evidence directory already exists')
    work.mkdir(parents=True); checks=[]
    result={'schema':1,'profile':args.profile,'seed':args.seed,'status':'BLOCKED','scope':SCOPE,'checks':checks,'paper':'BLOCKED','nlo':'BLOCKED'}
    try:
        result['validator_manifest_sha256']=release_integrity(ROOT)
        if args.profile in ('paper','nlo'): raise Blocked('No paper/full-NLO acceptance gates in this release')
        repo=Path(args.repo).resolve();production=repo/'collins_ep_analytic';run=access(args.run)
        before=baseline_check(repo,args.numerical_state); numerical_before=snapshot(repo/'collins_ep');history_before=existing_records(args.numerical_state)
        manifest,done=audit_run(run,production)
        if set(done)!={s['id'] for s in stage_list()}: raise Blocked('Complete s00 through s09 before analytic-export acceptance')
        if manifest.get('baseline_after')!=before or manifest.get('status')!='STAGES_PASS': raise ValueError('Run did not finish its preservation gates')
        result['run']=str(run);result['replay']=str(access(args.replay)) if args.replay else None
        result['run_id']=manifest['run_id'];result['run_manifest_sha256']=sha(run/'run.json');result['sources']=manifest['source_sha256']; result['runtime']=manifest['runtime']
        checks.append({'id':'workflow.provenance','status':'PASS','stages':len(done)})
        export=run/'common'/'s09_result'
        for filename in ('born_hard.json','spacelike_hard_one_loop.json'):
            payload=loads_export((export/filename).read_text())
            if payload['component']!=filename.removesuffix('.json'): raise ValueError('Export file has wrong component')
            rows=validate_export(payload,args.seed)
            for row in rows: row['id']=filename.removesuffix('.json')+'/'+row['id']
            checks.extend(rows)
        checks.append(verify_derivation_map(export,run))
        rt=execution_context(manifest['runtime']['config'])
        # Replay every supplied identity freshly, outside accepted stage directories.
        for stage in stage_list():
            if not stage['proof_ids']: continue
            dest=work/stage['id'];dest.mkdir()
            context={'run_id':manifest['run_id'],'stage':stage['id'],'runtime':rt,'proof_file':str(run/'common'/f"{stage['id']}_result"/'proofs.wl'),'proof_ids':stage['proof_ids'],'proof_report':str(dest/'proof-check.json')}
            cp=dest/'context.json';write(cp,execution_context(context));env=os.environ.copy();env['COLLINS_ANALYTIC_CONTEXT']=str(cp)
            ex=execute([rt['wolfram_kernel'],'-noprompt','-script',str(ROOT/'check_proofs.wls')],production,dest/'proof.log',min(rt['stage_timeout_seconds'],1800),env)
            proof=read(dest/'proof-check.json') if (dest/'proof-check.json').is_file() else {}
            if ex['exit_code']!=0 or proof.get('status')!='PASS' or proof.get('run_id')!=manifest['run_id'] or proof.get('stage')!=stage['id'] or not valid_proof_ids(proof.get('proof_ids'),stage['proof_ids']): raise ValueError('Fresh identity replay failed: '+stage['id'])
            checks.append({'id':'proofs.'+stage['id'],'status':'PASS','identities':len(stage['proof_ids']),'report_sha256':sha(dest/'proof-check.json')})
        # Independent Wolfram evaluation of the derived WL export, in addition to AST checks.
        nonce=uuid.uuid4().hex;req=requests(args.seed)
        context={'run_id':nonce,'runtime':rt,'requests':req,'upstream_born':str(run/'common'/'s03_result'/'tensors.wl'),'upstream_hard':str(run/'common'/'s07_result'/'hard.wl'),'coefficients':str(export/'coefficients.wl'),'soft_pilot':str(export/'soft_pilot.wl'),'response':str(work/'response.json')}
        cp=work/'export-context.json';write(cp,execution_context(context));env=os.environ.copy();env['COLLINS_ANALYTIC_CONTEXT']=str(cp)
        ex=execute([rt['wolfram_kernel'],'-noprompt','-script',str(ROOT/'evaluate_exports.wls')],production,work/'exports.log',1800,env)
        if ex['exit_code']!=0: raise ValueError('Fresh derived-export evaluation failed')
        checks.extend(compare_response(req,read(work/'response.json'),nonce))
        hard_requests=[r for r in req if r['kind']=='hard']
        write(work/'bridge-requests.json',{'run_id':nonce,'requests':hard_requests})
        bridge=relative_file(production,'numerics/evaluate.py')
        ex=execute([sys.executable,str(bridge),'--exports',str(export),'--requests',str(work/'bridge-requests.json')],production,work/'bridge.json',120)
        if ex['exit_code']!=0: raise ValueError('Numerical coefficient bridge failed')
        bridge_response=read(work/'bridge.json')
        if set(bridge_response)!={'run_id','responses'} or bridge_response['run_id']!=nonce or not isinstance(bridge_response['responses'],list): raise ValueError('Invalid bridge envelope')
        bridge_rows={}
        for row in bridge_response['responses']:
            if set(row)!={'id','values'} or row['id'] in bridge_rows: raise ValueError('Duplicate or invalid bridge row')
            bridge_rows[row['id']]=row['values']
        if set(bridge_rows)!={r['id'] for r in hard_requests}: raise ValueError('Missing bridge responses')
        for r in hard_requests:
            got=bridge_rows[r['id']]; want=expected(r)
            if not isinstance(got,dict) or set(got)!={'H_UU','H_UT','h1'}: raise ValueError('Wrong bridge component set')
            for key,v in got.items():
                if type(v) not in (int,float) or not math.isfinite(v): raise ValueError('Nonfinite bridge output')
                checks.append({'id':'bridge.'+r['id']+'.'+key,'status':'PASS' if abs(v-want[key])<=2e-10*max(1,abs(want[key])) else 'FAIL','actual':v,'expected':want[key]})
        if args.profile in ('foundation','analytic_foundation'):
            if not args.replay: raise Blocked('Foundation requires --replay with a distinct clean run')
            checks.append(compare_runs(run,args.replay,production))
            if args.profile=='foundation':
                checks.append(legacy_check(args,work,args.seed))
            else:
                result['numerical_regression']='NOT_REQUESTED_ANALYTICAL_ONLY'
        retained_files(args.numerical_state,history_before)
        after=baseline_check(repo,args.numerical_state)
        if before!=after or snapshot(repo/'collins_ep')!=numerical_before: raise ValueError('Protected original/numerical inputs changed during verification')
        audit_run(run,production)
        result['baseline_before']=before;result['baseline_after']=after
        result['status']='CHECKS_PASS' if all(x['status']=='PASS' for x in checks) else 'FAIL'
    except Exception as exc:
        result['status']='BLOCKED' if isinstance(exc,(Blocked,FileNotFoundError)) else 'FAIL';result['detail']=str(exc)
    if 'before' in locals():
        try:
            retained_files(args.numerical_state,history_before)
            retained_files(repo/'collins_ep',numerical_before)
            result['baseline_before']=before;result['baseline_after']=baseline_check(repo,args.numerical_state)
            if result['baseline_after']!=before: raise ValueError('Baseline changed during verification')
        except Exception as exc: result['status']='FAIL';result['preservation_error']=str(exc)
    ids=[c['id'] for c in checks]
    if len(ids)!=len(set(ids)):result['status']='FAIL';result['detail']='Duplicate check IDs'
    try:result['evidence_files']=snapshot(work)
    except Exception as exc:result['status']='FAIL';result['evidence_error']=str(exc)
    write(report,result);print(__import__('json').dumps({'status':result['status'],'checks':len(checks),'report':str(report),'scope':SCOPE}))
    return 0 if result['status']=='CHECKS_PASS' else (2 if result['status']=='BLOCKED' else 1)

def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--repo',default='/bigTMD');p.add_argument('--run',required=True);p.add_argument('--replay');p.add_argument('--profile',choices=['coefficients','foundation','analytic_foundation','paper','nlo'],default='foundation');p.add_argument('--seed',type=int,default=1729);p.add_argument('--report',required=True);p.add_argument('--numerical-validator',default='/bigTMD/collins_support/validators/numerical');p.add_argument('--numerical-state',default='/bigTMD/collins_support/baselines/SIDIS-validation-state');p.add_argument('--numerical-timeout',type=int,default=7200)
    a=p.parse_args()
    try: return verify(a)
    except Exception as exc: print(str(exc),file=sys.stderr);return 1
if __name__=='__main__':raise SystemExit(main())
