#!/usr/bin/env python3
"""Run the unchanged retained workflow and additive native d16--d19 stages."""
import argparse,datetime,json,os,sys,uuid
from pathlib import Path
import provenance
from nlo_support import *

def stages(through='d19'):
    items=read(ROOT/'contract.json')['stages'];ids=[x['id'] for x in items]
    if through not in ids:raise ValueError('unknown NLO stage')
    return items[:ids.index(through)+1]

def reexport(out,work,rt):
    work.mkdir(parents=True,exist_ok=False)
    cp=work/'context.json';dest=work/'packet.json'
    write(cp,{'packet':str(out/'packet.wl'),'output':str(dest)})
    ex=execute([rt['wolfram_kernel'],'-noprompt','-script',ROOT/'reexport.wls'],out,work/'execution.log',
               rt['config']['probe_timeout_seconds'],{'COLLINS_NLO_REEXPORT_CONTEXT':str(cp)})
    if ex['exit_code']!=0 or read(dest)!=read(out/'packet.json'):raise ValueError('native packet and JSON disagree')
    return ex

def check_observable_export(actual,packet):
    """Compare complete raw-native coefficient maps, including zero entries."""
    wanted={k:packet[k] for k in ('observable','HF_integrand','ratio','paper_limit','scheme_variation')}
    from symbolic import decode,zero
    if type(actual) is not dict or set(actual)!=set(wanted):raise ValueError('invalid native observable export')
    for k,values in wanted.items():
        if type(actual[k]) is not dict or set(actual[k])!=set(values) or any(not zero(decode(actual[k][n])-decode(x)) for n,x in values.items()):
            raise ValueError('native observable differs from tested packet: '+k)

def reexport_observable(out,work,rt):
    work.mkdir(parents=True,exist_ok=False);cp=work/'context.json';dest=work/'observable.json'
    write(cp,{'packet':str(out/'NATIVE_OBSERVABLE.wl'),'output':str(dest),'encoder':str(ROOT/'candidate_api/nlo_io.wl')})
    ex=execute([rt['wolfram_kernel'],'-noprompt','-script',ROOT/'reexport_observable.wls'],out,work/'execution.log',
               rt['config']['probe_timeout_seconds'],{'COLLINS_NLO_REEXPORT_CONTEXT':str(cp)})
    packet=read(out/'packet.json')['data']
    # Wolfram may canonicalize sums/factors differently; compare actual algebra.
    if ex['exit_code']!=0:raise ValueError('native observable reexport failed')
    check_observable_export(read(dest),packet)
    return ex

def stage_execute(stage,production,out,inputs,run_id,rt,probe=None):
    out.mkdir(parents=True,exist_ok=False)
    legacy=read(Path(inputs['d15'])/'context.json')
    context={'schema':1,'stage':stage['id'],'run_id':run_id,'production':str(production),
       'output':str(out),'inputs':{k:str(v) for k,v in inputs.items()},'runtime':rt,
       'native_runtime':legacy['runtime'],'extension_runtime':legacy.get('extension_runtime'),
       'derivation_runtime':legacy.get('derivation_runtime'),
       'probe':probe,'no_cache':True,'scope':read(ROOT/'contract.json')['scope']}
    context=execution_context(context)
    cp=out/'context.json';write(cp,context)
    legacy_context={**context,'runtime':context['native_runtime']}
    lp=out/'legacy-context.json';write(lp,legacy_context)
    script=relative(production,stage['script'])
    ex=execute([rt['wolfram_kernel'],'-noprompt','-script',script],production,out/'execution.log',
         rt['config']['probe_timeout_seconds'] if probe else rt['config']['stage_timeout_seconds'],
         {'COLLINS_NLO_CONTEXT':str(cp),'COLLINS_ANALYTIC_CONTEXT':str(lp),'COLLINS_ANALYTIC_NO_CACHE':'1'})
    if ex['exit_code']!=0:
        raise (Blocked if ex['exit_code']==2 else RuntimeError)('native '+stage['id']+' stopped; see '+str(out/'execution.log'))
    artifacts={f:sha(relative(out,f)) for f in stage['artifacts']}
    if any((out/f).stat().st_size==0 for f in artifacts):raise ValueError('empty required artifact')
    # New native stages must use regular contained files. Retained MadGraph links
    # are handled by the unchanged v0.3.3 evidence implementation.
    if any(x['kind']=='symlink' for x in snapshot(out).values()):raise ValueError('symlink in new native stage output')
    native=reexport(out,out/'native-reexport',rt)
    observable=reexport_observable(out,out/'native-observable',rt) if stage['id']=='d19' else None
    graph=provenance.check(stage,out,production,inputs)
    return {'schema':1,'stage':stage['id'],'run_id':run_id,'status':'PASS','execution':ex,
            'native_reexport':native,'observable_reexport':observable,'artifacts':artifacts,'artifact_tree':snapshot(out),
            'provenance':graph,'no_cache_requested':True}

def inputs_for(base,run):
    base,run=access(base),access(run)
    result={x.name[:-7]:x for x in (base/'common').iterdir() if x.is_dir() and x.name.endswith('_result')}
    for st in read(ROOT/'contract.json')['stages']:
        p=Path(run)/'common'/(st['id']+'_result')
        if p.is_dir():result[st['id']]=p
    return result

def audit(run,repo,require_complete=True):
    run=access(run);repo=Path(repo).resolve();prod=repo/'collins_ep_analytic';m=read(run/'run.json')
    if m.get('schema')!=4 or m.get('repo')!=str(repo) or m.get('profile')!='leading_power_nlo_extension':raise ValueError('wrong run identity')
    release_integrity()
    if not same_release(ROOT,m['release_sha256']) or not same_snapshot(prod,m['sources'],snapshot(prod)):raise ValueError('source or release changed')
    if m['accepted_source_hash']!=preserve_accepted(prod) or m['runtime']!=runtime(prod):raise ValueError('accepted inputs/runtime changed')
    base=access(m['base_run']);bm=read(base/'run.json')
    if sha(base/'run.json')!=m['base_manifest_sha256'] or bm['source_sha256']!={k:v['sha256'] for k,v in m['sources'].items() if v['kind']=='file'}:
        raise ValueError('retained run identity/source map changed')
    done={};inputs=inputs_for(base,run)
    for st in stages(m['through']):
        sid=st['id'];r=read(run/'receipts'/(sid+'.json'));out=run/'common'/(sid+'_result')
        if r.get('stage')!=sid or r.get('run_id')!=m['run_id'] or r.get('status')!='PASS' or r.get('no_cache_requested') is not True:raise ValueError('bad stage receipt')
        if r['artifact_tree']!=snapshot(out) or r['artifacts']!={f:sha(relative(out,f)) for f in st['artifacts']}:raise ValueError('stage artifacts changed')
        if r['execution']['exit_code']!=0 or r['execution']['log_sha256']!=sha(out/'execution.log'):raise ValueError('stage execution changed')
        if r['native_reexport']['exit_code']!=0 or r['native_reexport']['log_sha256']!=sha(out/'native-reexport/execution.log'):raise ValueError('native export evidence changed')
        if read(out/'native-reexport/packet.json')!=read(out/'packet.json'):raise ValueError('native replay packet changed')
        if sid=='d19':
            ex=r['observable_reexport']
            if ex['exit_code']!=0 or ex['log_sha256']!=sha(out/'native-observable/execution.log'):raise ValueError('native observable export changed')
        if r['provenance']!=provenance.check(st,out,prod,inputs):raise ValueError('derivation graph changed')
        deps={d:sha((run if d in done else base)/'receipts'/(d+'.json')) for d in st['dependencies']}
        if r['dependencies']!=deps:raise ValueError('dependency receipt changed')
        done[sid]=r
    if require_complete and (m['status']!='STAGES_PASS' or m['through']!='d19' or m['base_reused']):raise Blocked('complete fresh run through d19 required')
    return m,done

def run_workflow(a):
    repo=Path(a.repo).resolve();prod=repo/'collins_ep_analytic';release=release_integrity();accepted=preserve_accepted(prod)
    rt=runtime(prod);wanted=stages(a.through)
    for st in wanted:relative(prod,st['script'])
    state=outside(a.state,[repo,ROOT],area='states');rid=datetime.datetime.now(datetime.timezone.utc).strftime('%Y%m%dT%H%M%SZ')+'-'+uuid.uuid4().hex[:12]
    run=state/'runs'/rid;run.mkdir(parents=True,exist_ok=False);sources=snapshot(prod)
    print(json.dumps({'run':str(run),'through':a.through}),flush=True)
    m={'schema':4,'profile':'leading_power_nlo_extension','run_id':rid,'repo':str(repo),'production':str(prod),
       'release_sha256':release,'accepted_source_hash':accepted,'sources':sources,'runtime':rt,'through':a.through,
       'base_reused':bool(a.base_run),'status':'RUNNING','numerical_state':str(access(a.numerical_state))}
    write(run/'run.json',m)
    try:
        if a.base_run:
            base=access(a.base_run);ex,bm=retained_audit(repo,base,run/'retained-status.log')
        else:
            ex=execute([sys.executable,BASE/'workflow.py','run','--repo',repo,'--state',state/'retained',
                        '--numerical-state',m['numerical_state'],'--through','d15'],repo,run/'retained-workflow.log',86400)
            result=last_json(run/'retained-workflow.log','run');base=access(result['run'])
            if ex['exit_code']!=0:raise (Blocked if ex['exit_code']==2 else RuntimeError)('retained workflow stopped; see '+str(base))
            bm=read(base/'run.json')
        if bm.get('status')!='STAGES_PASS' or bm.get('resumed') is not False:raise Blocked('retained native stages incomplete')
        m.update(base_run=str(base),base_manifest_sha256=sha(base/'run.json'),retained_execution=ex)
        write(run/'run.json',m)
        for st in wanted:
            inputs=inputs_for(base,run);sid=st['id'];print(sid+': '+st['name'],flush=True)
            receipt=stage_execute(st,prod,run/'common'/(sid+'_result'),inputs,rid,rt)
            receipt['dependencies']={d:sha((run if d.startswith('d') and int(d[1:])>=16 else base)/'receipts'/(d+'.json')) for d in st['dependencies']}
            if snapshot(prod)!=sources or runtime(prod)!=rt:raise ValueError('inputs changed during native stage')
            write(run/'receipts'/(sid+'.json'),receipt)
        m['status']='STAGES_PASS'
    except Exception as exc:
        m['status']='BLOCKED' if isinstance(exc,(Blocked,FileNotFoundError)) else 'FAIL';m['detail']=str(exc)
    try:
        if snapshot(prod)!=sources or runtime(prod)!=rt:raise ValueError('inputs changed during run')
        preserve_accepted(prod);release_integrity()
    except Exception as exc:m['status']='FAIL';m['preservation_error']=str(exc)
    write(run/'run.json',m)
    if m['status']=='STAGES_PASS':audit(run,repo,require_complete=False)
    print(json.dumps({'status':m['status'],'run':str(run),'detail':m.get('detail')}),flush=True)
    return 0 if m['status']=='STAGES_PASS' else 2 if m['status']=='BLOCKED' else 1

def main():
    p=argparse.ArgumentParser(description=__doc__);sub=p.add_subparsers(dest='command',required=True)
    for name in ('doctor','run','status'):
        q=sub.add_parser(name);q.add_argument('--repo',default='/bigTMD')
        if name=='run':
            q.add_argument('--state',default='collins_support/states/runs/nlo');q.add_argument('--numerical-state',default='collins_support/baselines/SIDIS-validation-state')
            q.add_argument('--through',choices=['d16','d17','d18','d19'],default='d19');q.add_argument('--base-run',help='development only; excluded from final fresh-pair acceptance')
        if name=='status':q.add_argument('--run',required=True)
    a=p.parse_args()
    try:
        if a.command=='run':return run_workflow(a)
        if a.command=='status':m,done=audit(a.run,a.repo,False);print(json.dumps({'status':m['status'],'stages':list(done)}));return 0
        release_integrity();prod=Path(a.repo).resolve()/'collins_ep_analytic';preserve_accepted(prod)
        missing=[st['script'] for st in stages() if not (prod/st['script']).is_file()]
        cfg=(prod/'nlo_runtime.json').is_file()
        if cfg:runtime(prod)
        print(json.dumps({'status':'READY_TO_EXECUTE' if cfg and not missing else 'IMPLEMENTATION_REQUIRED',
            'missing_stage_sources':missing,'nlo_runtime_configured':cfg,
            'note':'Path and preservation check only; no native execution or physics acceptance.'},indent=2))
        return 0 if cfg and not missing else 2
    except Exception as exc:
        st='BLOCKED' if isinstance(exc,(Blocked,FileNotFoundError)) else 'FAIL';print(json.dumps({'status':st,'detail':str(exc)}));return 2 if st=='BLOCKED' else 1
if __name__=='__main__':raise SystemExit(main())
