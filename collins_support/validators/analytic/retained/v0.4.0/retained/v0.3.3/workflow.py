#!/usr/bin/env python3
"""Numbered derivation-stage execution. PASS means executed contract checks only."""
import argparse,datetime,hashlib,json,os,sys,uuid
from pathlib import Path
from support import Blocked,baseline_check,execute,read,relative_file,release_integrity,runtime_record as base_runtime_record,sha,snapshot,write,existing_records,retained_files,access,same_snapshot,same_release,historical_runtime_equal,execution_context,output_path
ROOT=Path(__file__).resolve().parent
from extension_inputs import check_foundation,extra_runtime

def runtime_record(config):
    record=base_runtime_record(config)
    record["extension"]=extra_runtime(Path(config).parent)
    from derivation_support import runtime_extension, check_installation
    record['derivation']=runtime_extension(Path(config).parent)
    check_installation(Path(config).parent)
    return record


def stage_list(): return read(ROOT/'stages.json')['stages']
def ancestors(through):
    stages={s['id']:s for s in stage_list()}; required=set()
    def visit(sid):
        if sid in required: return
        if sid not in stages: raise ValueError('Unknown stage '+sid)
        for dep in stages[sid]['dependencies']: visit(dep)
        required.add(sid)
    visit(through)
    return [s for s in stages.values() if s['id'] in required]

def proof_check(stage,out,context,runtime,log):
    if not stage['proof_ids']: return None
    proof_context=dict(context,proof_ids=stage['proof_ids'],proof_file=str(out/'proofs.wl'),proof_report=str(out/'proof-check.json'))
    pc=out/'proof-context.json'; write(pc,execution_context(proof_context))
    env=os.environ.copy(); env['COLLINS_ANALYTIC_CONTEXT']=str(pc)
    result=execute([runtime['wolfram_kernel'],'-noprompt','-script',str(ROOT/'check_proofs.wls')],context['production'],log,min(runtime['stage_timeout_seconds'],1800),env)
    if result['exit_code']!=0: raise ValueError('Independent proof replay failed: '+stage['id'])
    report=read(out/'proof-check.json')
    if report.get('run_id')!=context['run_id'] or report.get('stage')!=stage['id'] or report.get('status')!='PASS' or (len(report.get('proof_ids',[]))!=len(stage['proof_ids']) or set(report.get('proof_ids',[]))!=set(stage['proof_ids'])):
        raise ValueError('Invalid proof replay receipt')
    return result

def evidence_check(stage,out,run_id):
    data=read(relative_file(out,'evidence.json'))
    expected={'schema':1,'stage':stage['id'],'run_id':run_id,'status':'CANDIDATE_COMPLETE'}
    if data!=expected: raise ValueError('Wrong or stale stage evidence envelope')
    files={name:sha(relative_file(out,name)) for name in stage['artifacts']}
    if any((out/name).stat().st_size==0 for name in stage['artifacts']): raise ValueError('Empty required artifact')
    files['evidence.json']=sha(out/'evidence.json')
    return files

def audit_run(run,production):
    run=access(run); production=access(production); m=read(run/'run.json')
    check_foundation(production)
    if m.get('schema')!=1 or m.get('production')!=str(production): raise ValueError('Run belongs to another production tree')
    if baseline_check(Path(m['repo']),m['numerical_state'])!=m['baseline_before']: raise ValueError('Original baseline changed since run')
    if not same_snapshot(production,m['source_sha256'],snapshot(production)): raise ValueError('Production sources changed; create a fresh run')
    release_integrity(ROOT)
    if not same_release(ROOT,m['validator_manifest_sha256']): raise ValueError('Wrong validator release')
    if not historical_runtime_equal(m['runtime'],runtime_record(production/'runtime.json')): raise ValueError('Runtime changed; create a fresh run')
    retained_files(Path(m['repo'])/'collins_ep',m['numerical_sources_before'])
    retained_files(m['numerical_state'],m['history_before'])
    done={}
    for stage in stage_list():
        p=run/'receipts'/f"{stage['id']}.json"
        if not p.is_file(): continue
        r=read(p)
        if r.get('status')!='PASS': continue
        if r.get('stage')!=stage['id'] or r.get('run_id')!=m['run_id']: raise ValueError('Stale stage receipt')
        expected={dep:sha(run/'receipts'/f'{dep}.json') for dep in stage['dependencies'] if dep in done}
        if len(expected)!=len(stage['dependencies']) or r.get('dependencies')!=expected: raise ValueError('Missing or changed dependency receipt')
        out=run/'common'/f"{stage['id']}_result"
        files=evidence_check(stage,out,m['run_id'])
        if r.get('artifacts')!=files or r.get('artifact_tree')!=snapshot(out): raise ValueError('Changed stage artifacts: '+stage['id'])
        if r.get('source_sha256')!=m['source_sha256'] or r.get('runtime')!=m['runtime']: raise ValueError('Stage source/runtime identity differs')
        execution=r.get('execution',{})
        if execution.get('exit_code')!=0 or execution.get('log_sha256')!=sha(out/'execution.log'): raise ValueError('Changed execution log or failed process')
        if stage['proof_ids']:
            proof=read(out/'proof-check.json')
            if r.get('proof_report_sha256')!=sha(out/'proof-check.json') or proof.get('status')!='PASS' or proof.get('run_id')!=m['run_id'] or (len(proof.get('proof_ids',[]))!=len(stage['proof_ids']) or set(proof.get('proof_ids',[]))!=set(stage['proof_ids'])): raise ValueError('Missing or changed proof evidence')
            if r['proof_execution']['log_sha256']!=sha(out/'proof.log') or r['proof_execution']['exit_code']!=0: raise ValueError('Changed proof execution evidence')
        done[stage['id']]=r
    return m,done

def run_workflow(args):
    validator_hash=release_integrity(ROOT); repo=Path(args.repo).resolve(); production=repo/'collins_ep_analytic'
    if not production.is_dir(): raise Blocked('Install collins_ep_analytic inside the repository first')
    check_foundation(production)
    before=baseline_check(repo,args.numerical_state); sources=snapshot(production); runtime=runtime_record(production/'runtime.json')
    numerical_sources=snapshot(repo/'collins_ep'); history=existing_records(args.numerical_state)
    wanted=ancestors(args.through)
    if args.resume:
        run=access(args.resume); m,done=audit_run(run,production)
        m['resumed']=True; write(run/'run.json',m)
        if m['baseline_before']!=before: raise ValueError('Original baseline identity changed')
    else:
        run_id=datetime.datetime.now(datetime.timezone.utc).strftime('%Y%m%dT%H%M%SZ')+'-'+uuid.uuid4().hex[:12]
        run=output_path(access(args.state,required=False)/'runs'/run_id,repo,protected=(production,ROOT),area='states')
        if run.is_relative_to(production): raise ValueError('Use a state directory outside the production source tree')
        run.mkdir(parents=True,exist_ok=False)
        m={'schema':1,'run_id':run_id,'production':str(production),'repo':str(repo),'numerical_state':str(access(args.numerical_state)),'source_sha256':sources,'runtime':runtime,'validator_manifest_sha256':validator_hash,'baseline_before':before,'numerical_sources_before':numerical_sources,'history_before':history,'status':'RUNNING','resumed':False,'scope':'Execution, supplied-proof replay and provenance; not a complete independent derivation audit'}
        write(run/'run.json',m); done={}
    print(json.dumps({'run':str(run),'through':args.through}),flush=True)
    failure=None
    try:
        for stage in wanted:
            sid=stage['id']
            if sid in done: print(f'{sid}: reuse verified checkpoint',flush=True); continue
            out=run/'common'/f'{sid}_result'
            if out.exists():
                archive=run/'previous_runs'/f'{sid}-{uuid.uuid4().hex[:8]}'; archive.parent.mkdir(parents=True,exist_ok=True); out.rename(archive)
            out.mkdir(parents=True)
            dependencies={dep:sha(run/'receipts'/f'{dep}.json') for dep in stage['dependencies']}
            context={'schema':1,'stage':sid,'run_id':m['run_id'],'production':str(production),'output':str(out),'inputs':{item['id']:str(run/'common'/(item['id']+'_result')) for item in ancestors(sid) if item['id']!=sid},'runtime':runtime['config'],'extension_runtime':runtime.get('extension'),'derivation_runtime':runtime.get('derivation'),'baseline':before}
            cp=out/'context.json'; write(cp,execution_context(context))
            env=os.environ.copy(); env['COLLINS_ANALYTIC_CONTEXT']=str(cp); env['COLLINS_ANALYTIC_NO_CACHE']='1' if not args.resume else '0'
            script=relative_file(production,stage['script'])
            command=[sys.executable,str(script)] if script.suffix=='.py' else [runtime['config']['wolfram_kernel'],'-noprompt','-script',str(script)]
            print(f'{sid}: execute {stage["name"]}',flush=True)
            stage_timeout=(runtime['derivation']['config']['stage_timeout_seconds'] if sid.startswith('d') else (runtime['extension']['stage_timeout_seconds'] if int(sid[1:])>=10 else runtime['config']['stage_timeout_seconds']))
            execution=execute(command,production,out/'execution.log',stage_timeout,env)
            if execution['exit_code']!=0:
                failure=Blocked(f'{sid} is incomplete; see {out}') if execution['exit_code']==2 else RuntimeError(f'{sid} execution failed; see {out}')
                raise failure
            artifacts=evidence_check(stage,out,m['run_id'])
            proof=proof_check(stage,out,context,runtime['config'],out/'proof.log')
            if snapshot(production)!=sources: raise ValueError('Production source changed during execution')
            receipt={'schema':1,'stage':sid,'run_id':m['run_id'],'status':'PASS','source_sha256':sources,'runtime':runtime,'dependencies':dependencies,'no_cache_requested':not bool(args.resume),'artifacts':artifacts,'artifact_tree':snapshot(out),'execution':execution,'proof_execution':proof,'proof_report_sha256':sha(out/'proof-check.json') if proof else None}
            write(run/'receipts'/f'{sid}.json',receipt); done[sid]=receipt
        audit_run(run,production)
        m['status']='STAGES_PASS'; m['completed_stages']=[s['id'] for s in wanted]
    except BaseException as exc:
        failure=exc; m['status']='BLOCKED' if isinstance(exc,Blocked) else 'FAIL'; m['detail']=str(exc)
    try:
        retained_files(repo/'collins_ep',m['numerical_sources_before'])
        retained_files(args.numerical_state,m['history_before'])
        m['baseline_after']=baseline_check(repo,args.numerical_state)
        if m['baseline_after']!=before or snapshot(production)!=sources or runtime_record(production/'runtime.json')!=runtime: raise ValueError('Inputs changed during run')
    except Exception as exc: failure=exc; m['status']='FAIL'; m['detail']=str(exc)
    write(run/'run.json',m)
    print(json.dumps({'status':m['status'],'run':str(run),'detail':m.get('detail')}),flush=True)
    return 0 if failure is None else (2 if isinstance(failure,Blocked) else 1)

def main():
    ap=argparse.ArgumentParser(description=__doc__); sub=ap.add_subparsers(dest='command',required=True)
    doctor=sub.add_parser('doctor'); doctor.add_argument('--repo',default='/bigTMD')
    status=sub.add_parser('status'); status.add_argument('--repo',default='/bigTMD'); status.add_argument('--run')
    run=sub.add_parser('run'); run.add_argument('--repo',default='/bigTMD'); run.add_argument('--state',default='/bigTMD/collins_support/states');run.add_argument('--numerical-state',default='/bigTMD/collins_support/baselines/SIDIS-validation-state');run.add_argument('--through',choices=[s['id'] for s in stage_list()],default='d15');run.add_argument('--resume')
    args=ap.parse_args()
    try:
        if args.command=='run': return run_workflow(args)
        if args.command=='doctor':
            release_integrity(ROOT)
            config=Path(args.repo).resolve()/'collins_ep_analytic'/'runtime.json'
            if not config.is_file():
                print(__import__('json').dumps({'status':'BLOCKED','detail':'Copy runtime.example.json to runtime.json and set actual installed paths.'})); return 2
            data=read(config); findings=[]
            check_foundation(config.parent)
            extra=extra_runtime(config.parent)
            from derivation_support import runtime_extension, check_installation
            runtime_extension(config.parent); check_installation(config.parent)
            findings.append({'dependency':'polymake','path':extra['polymake']['path'],'found':True})
            for key in ('wolfram_kernel','kira','fermat','subtropica_root','feyncalc_root','feynarts_root'):
                path=data.get(key); ok=isinstance(path,str) and access(path,required=False).exists()
                findings.append({'dependency':key,'path':path,'found':ok})
            print(__import__('json').dumps({'status':'PATHS_FOUND' if all(x['found'] for x in findings) else 'BLOCKED','dependencies':findings,'note':'Path inventory only. Actual Wolfram/FeynCalc/FeynArts and Kira smoke checks run in s00; actual Kira/SubTropica calculations must run in s05/s06.'},indent=2)); return 0 if all(x['found'] for x in findings) else 2
        release_integrity(ROOT)
        if args.run:
            m,done=audit_run(args.run,Path(args.repo).resolve()/'collins_ep_analytic'); print(json.dumps({'status':'AUDITED','completed':list(done),'scope':m['scope']},indent=2))
        else: print(json.dumps({'status':'SCAFFOLD','stages':stage_list(),'paper':'BLOCKED','nlo':'BLOCKED'},indent=2))
        return 0
    except Exception as exc:
        print(json.dumps({'status':'BLOCKED' if isinstance(exc,(Blocked,FileNotFoundError)) else 'FAIL','detail':str(exc)})); return 2 if isinstance(exc,(Blocked,FileNotFoundError)) else 1
if __name__=='__main__': raise SystemExit(main())
