#!/usr/bin/env python3
"""Execute fresh candidate stages and real Kira/SubTropica jobs; audit evidence."""
import argparse, datetime, json, os, shutil, sys, uuid
from pathlib import Path
from ru_support import *
from algebra import decode, encode, equal, evaluate_values, dependencies, check_families, check_precision

def stages(): return read(ROOT/'contract.json')['stages']

def export_native(src,dest,mode,rt,work):
    work=access(work,required=False);work.mkdir(parents=True,exist_ok=False)
    cp=work/'context.json';write(cp,{'input':str(access(src)),'output':str(access(dest,required=False)),'mode':mode})
    ex=execute([rt['config']['wolfram_kernel'],'-noprompt','-script',ROOT/'native_reexport.wls'],work,work/'execution.log',rt['config']['timeout_seconds'],{'COLLINS_RU_REEXPORT':cp})
    if ex['exit_code']!=0:raise Blocked('native reexport failed: '+str(work))
    read(dest)
    return ex

def job_execute(stage,job,out,rt,packet):
    wanted={'id','inputs','outputs','families','sectors'} | ({'master_inventory'} if stage['tool']=='kira' else set())
    if set(job)!=wanted:raise ValueError('invalid job keys')
    jid=job['id']
    if not isinstance(jid,str) or not jid.replace('_','').isalnum():raise ValueError('invalid job ID')
    work=out/'jobs'/jid
    if not work.is_dir():raise Blocked('job inputs missing: '+str(work))
    inputs=job['inputs'];outputs=job['outputs']
    if not inputs or not outputs or len(set(inputs+outputs))!=len(inputs+outputs):raise ValueError('duplicate/overlapping job files')
    before={n:digest(contained(work,n)) for n in inputs}
    for n in outputs:
        p=contained(work,n,exists=False)
        if p.exists():raise ValueError('tool output preexists: '+str(p))
    kind=stage['tool']
    if kind=='kira':
        if not {'jobs.yaml','config/integralfamilies.yaml','config/kinematics.yaml','targets'}<=set(inputs):raise ValueError('Kira requires config, targets and jobs.yaml')
        if not any(n.endswith('.m') and n.startswith('results/') for n in outputs):raise ValueError('actual Kira Mathematica rules required')
        if job['master_inventory'] not in outputs:raise ValueError('Kira final master inventory must be captured')
        command=[rt['config']['kira'],'--parallel=1','jobs.yaml']
    elif kind=='subtropica':
        if 'euler_inputs.wl' not in inputs or not {'masters.wl','raw_results.wl','subtropica_execution.json'}<=set(outputs):raise ValueError('SubTropica Euler inputs, raw results and masters.wl required')
        command=[rt['config']['wolfram_kernel'],'-noprompt','-script',ROOT/'native_subtropica.wls']
    else:raise ValueError('unknown tool job')
    ex=execute(command,work,work/'tool.log',rt['config']['timeout_seconds'],{'FERMATPATH':rt['config']['fermat'],'COLLINS_RU_TOOL_CONTEXT':out/'context.json','COLLINS_RU_SUBTROPICA_ROOT':rt['config']['subtropica_root']})
    if ex['exit_code']!=0:raise Blocked(kind+' job failed: '+str(work))
    if before!={n:digest(contained(work,n)) for n in inputs}:raise ValueError('tool changed its declared inputs')
    result={n:digest(contained(work,n)) for n in outputs}
    if any((work/n).stat().st_size==0 for n in outputs):raise ValueError('empty native tool output')
    reexport=None;kira_audit=None;audited_outputs={}
    if kind=='kira':
        cp=work/'kira_audit_context.json'
        write(cp,{'rule_files':[str(work/n) for n in outputs if n.endswith('.m') and n.startswith('results/')],
              'master_inventory':str(work/job['master_inventory']),
              'families':[f for f in packet['families'] if f['id'] in job['families']],
              'native_output':str(work/'reduction_certificate.wl'),'output':str(work/'reduction_audit.json')})
        kira_audit=execute([rt['config']['wolfram_kernel'],'-noprompt','-script',ROOT/'native_kira_audit.wls'],work,work/'kira_audit.log',rt['config']['timeout_seconds'],{'COLLINS_RU_KIRA_AUDIT':cp})
        if kira_audit['exit_code']!=0 or read(work/'reduction_audit.json').get('status')!='PASS':raise ValueError('native Kira rule/cut audit failed')
        audited_outputs={n:digest(work/n) for n in ('reduction_certificate.wl','reduction_audit.json')}
    if kind=='subtropica':
        reexport=export_native(work/'masters.wl',work/'masters.json','masters',rt,work/'native-export')
        if not read(work/'masters.json'):raise ValueError('no evaluated masters')
    return {'job':job,'kind':kind,'inputs':before,'outputs':result,'execution':ex,'reexport':reexport,'kira_audit':kira_audit,'audited_outputs':audited_outputs}

def graph_add(packet,out,stage,graph,jobs,production):
    sid=stage['id'];source='source/'+sid
    graph[source]={'parents':[],'role':'source','sha256':digest(production/stage['script'])}
    entries=packet.get('evidence',{})
    if not entries:raise ValueError('missing native derivation evidence')
    if set(entries)&set(graph):raise ValueError('duplicate evidence ID')
    pending=dict(entries)
    while pending:
        progressed=False
        for key,item in list(pending.items()):
            if set(item)!={'path','role','parents'} or not key.startswith(sid+'/'):raise ValueError('invalid evidence node')
            if not isinstance(item['parents'],list) or not item['parents']:raise ValueError('evidence must identify its producing dependencies')
            if not all(p in graph for p in item['parents']):continue
            f=contained(out,item['path'])
            if f.stat().st_size==0:raise ValueError('empty evidence artifact')
            graph[key]={**item,'sha256':digest(f)};del pending[key];progressed=True
        if not progressed:raise ValueError('cyclic/missing evidence ancestry')
    roles={x['role'] for x in entries.values()}
    if not set(stage['roles'])<=roles:raise ValueError('missing native evidence roles for '+sid)
    for jr in jobs:
        jid=jr['job']['id']
        for name,d in {**jr['outputs'],**jr['audited_outputs']}.items():
            graph['tool/'+sid+'/'+jid+'/'+name]={'parents':[source,*entries],'role':jr['kind'],'sha256':d}

def stage_execute(stage,repo,run,rt,validation_probe=False):
    prod=Path(repo)/ENGINE;out=run/'common'/(stage['id']+'_result');out.mkdir(parents=True,exist_ok=False)
    inputs={st['id']:str(run/'common'/(st['id']+'_result')) for st in stages() if st['id']<stage['id']}
    ctx={'schema':5,'stage':stage['id'],'production':str(prod),'output':str(out),'inputs':inputs,'runtime':rt['config'],'no_cache':True,'validation_probe':validation_probe,'scope':read(ROOT/'contract.json')['scope']}
    write(out/'context.json',ctx)
    script=contained(prod,stage['script'])
    ex=execute([rt['config']['wolfram_kernel'],'-noprompt','-script',script],prod,out/'execution.log',rt['config']['timeout_seconds'],{'COLLINS_RU_CONTEXT':out/'context.json','COLLINS_ANALYTIC_NO_CACHE':'1'})
    if ex['exit_code']!=0:raise Blocked('stage stopped: '+str(out))
    nx=export_native(contained(out,'packet.wl'),out/'packet.json','packet',rt,out/'native-export')
    packet=read(out/'packet.json')
    if packet.get('schema')!=5 or packet.get('stage')!=stage['id']:raise ValueError('wrong native packet identity')
    jobs=packet.get('jobs',[])
    if bool(jobs)!=bool(stage.get('tool')):raise ValueError('wrong tool-job coverage in '+stage['id'])
    if len({j['id'] for j in jobs})!=len(jobs):raise ValueError('duplicate native jobs')
    if stage['id'] in ('r01','r04'):
        check_families(packet,stage['id']=='r01')
        if stage['id']=='r01':
            for f in packet['families']:contained(out,f['support_artifact'])
        declared={f['id'] for f in packet['families']}
        used={f for j in jobs for f in j['families']}
        if used!=declared:raise ValueError('Kira jobs do not cover declared families')
    receipts=[job_execute(stage,j,out,rt,packet) for j in jobs]
    return {'stage':stage['id'],'execution':ex,'native_export':nx,'jobs':receipts,'tree':snapshot(out)}

def scientific_audit(run,repo):
    """Recompute certificate arithmetic and graph coverage from sealed native exports."""
    run=access(run);prod=Path(repo)/ENGINE;known={};recipes={};graph={};packets={};masters={};locations={};orders={};rows=[]
    for stage in stages():
        sid=stage['id'];out=run/'common'/(sid+'_result');p=read(out/'packet.json');packets[sid]=p
        receipt=read(run/'receipts'/(sid+'.json'))
        if receipt['stage']!=sid or receipt['tree']!=snapshot(out):raise ValueError('changed stage tree: '+sid)
        for ex,log in [(receipt['execution'],out/'execution.log'),(receipt['native_export'],out/'native-export/execution.log')]:
            if ex['exit_code']!=0 or ex['log_sha256']!=digest(log):raise ValueError('changed native execution')
        if receipt['jobs'] and len(receipt['jobs'])!=len(p['jobs']):raise ValueError('changed job count')
        for jr in receipt['jobs']:
            job=jr['job'];work=out/'jobs'/job['id']
            if job not in p['jobs']:raise ValueError('job specification mismatch')
            if jr['execution']['exit_code']!=0 or jr['execution']['log_sha256']!=digest(work/'tool.log'):raise ValueError('changed tool execution')
            for field in ('inputs','outputs'):
                if jr[field]!={n:digest(contained(work,n)) for n in job[field]}:raise ValueError('changed job '+field)
            if jr['audited_outputs']!={n:digest(contained(work,n)) for n in jr['audited_outputs']}:raise ValueError('changed audited reduction outputs')
            if jr['kind']=='kira':
                ka=jr['kira_audit']
                if ka['exit_code']!=0 or ka['log_sha256']!=digest(work/'kira_audit.log'):raise ValueError('changed native Kira audit')
            if jr['kind']=='subtropica':
                nx=jr['reexport']
                if nx['exit_code']!=0 or nx['log_sha256']!=digest(work/'native-export/execution.log'):raise ValueError('changed master native reexport')
                for name,t in read(work/'masters.json').items():
                    key='master/'+sid+'/'+job['id']+'/'+name
                    if '/' in name or not name:raise ValueError('invalid master name')
                    masters[key]=decode(t);locations[key]={'path':str(work/'masters.wl'),'key':name,'stage':sid,'job':job['id']}
                    orders[key]=read(work/'subtropica_execution.json')['orders'][name]
                    if type(orders[key]) is not int or not 0<=orders[key]<=4:raise ValueError('invalid native master precision')
        graph_add(p,out,stage,graph,receipt['jobs'],prod)
        known.update(masters)
        done,new=evaluate_values(p,known);known.update(done);recipes.update(new)
        if any(not k.startswith(sid+'/') for k in done):raise ValueError('value belongs to wrong stage')
        rows.append({'id':'native.'+sid,'status':'PASS','values':len(done),'jobs':len(receipt['jobs'])})
        if sid in ('r01','r04'):rows.append({'id':'integrands.'+sid,'status':'PASS','targets':check_families(p,sid=='r01')})
    check_precision(recipes,orders)
    contract=read(ROOT/'contract.json');final=packets['r07'];exports=final.get('exports',{})
    expected=read(ROOT/'reference_values.json')['values']
    if set(exports)!=set(expected):raise ValueError('comparison inventory incomplete or expanded silently')
    def ancestors(key,seen=None):
        if key not in graph:raise ValueError('missing export evidence node')
        seen=set() if seen is None else seen
        if key in seen:return seen
        seen.add(key)
        for parent in graph[key]['parents']:ancestors(parent,seen)
        return seen
    reached=set();output_values={}
    for name,e in exports.items():
        if set(e)!={'value','evidence'} or e['value'] not in known:raise ValueError('missing native exported value')
        reached|=ancestors(e['evidence']);x=known[e['value']];output_values[name]=x
        ref=decode(expected[name])
        if name.startswith('s09/H_'):
            import sympy as sy
            u,ss,t=sy.symbols('u s t');ok=equal(x.subs(u,-ss-t),ref.subs(u,-ss-t))
        else:ok=equal(x,ref)
        rows.append({'id':'reference.'+name,'status':'PASS' if ok else 'FAIL','meaning':'accepted-engine comparison in declared comparison convention'})
    tools={k for k in graph if k.startswith('tool/')}
    if not tools<=reached:raise ValueError('native tool outputs disconnected from final evidence')
    if not all('source/'+st['id'] in reached for st in stages()):raise ValueError('stage disconnected from final evidence')
    used=set().union(*(dependencies(e['value'],recipes) for e in exports.values()))
    active={k for k in masters if k in used and not equal(masters[k],decode(0))}
    if not any('/r02/' in k for k in active) or not any('/r05/' in k for k in active):raise ValueError('nonzero real and virtual masters must feed final coefficients')
    sector_results=final.get('sector_results',{})
    if set(sector_results)!=set(contract['sectors']):raise ValueError('missing required physics sector')
    for sector,keys in sector_results.items():
        if not keys or any(k not in recipes for k in keys):raise ValueError('missing sector derivation values: '+sector)
        if not any(dependencies(k,recipes)&set(masters) for k in keys):raise ValueError('sector has no evaluated integral ancestry: '+sector)
    conventions=packets['r00'].get('conventions',{})
    if set(conventions)!=set(contract['conventions']):raise ValueError('convention inventory incomplete')
    for key,c in conventions.items():
        if set(c)!={'sidis_source','collins_definition','conversion','evidence'} or c['evidence'] not in graph:raise ValueError('missing convention evidence: '+key)
        if not all(isinstance(c[x],str) and c[x].strip() for x in ('sidis_source','collins_definition','conversion')):raise ValueError('empty convention statement')
    rows.append({'id':'coverage.integrals_and_conventions','status':'PASS','qualification':'source review required for physical content'})
    return {'rows':rows,'masters':masters,'locations':locations,'recipes':recipes,'values':known,'exports':exports,'packets':packets}

def check_reuse(prod):
    pin=read(ROOT/'sidis_reuse.json');ledger=read(contained(prod,'provenance/SIDIS_REUSE_MANIFEST.json'))
    if ledger.get('commit')!=pin['commit'] or set(ledger.get('files',{}))!={f['source'] for f in pin['files']}:raise ValueError('reuse ledger must enumerate the 20 approved files')
    used=0
    for f in pin['files']:
        row=ledger['files'][f['source']]
        if row.get('used') is False:
            if not row.get('reason'):raise ValueError('unused reuse entry needs a reason')
            continue
        if row.get('used') is not True or not row.get('destinations') or not row.get('adaptation'):raise ValueError('incomplete reuse entry')
        original=contained(prod,'provenance/sidis/'+pin['commit']+'/'+f['source'])
        data=original.read_bytes();blob=hashlib.sha1(('blob '+str(len(data))+'\0').encode()+data).hexdigest()
        if blob!=f['git_blob_sha1']:raise ValueError('wrong pinned SIDIS source: '+f['source'])
        for n,h in row['destinations'].items():
            if digest(contained(prod,n))!=h:raise ValueError('adapted source hash mismatch')
        used+=1
    if not used:raise Blocked('no approved SIDIS machinery reused')
    return {'approved':20,'used':used,'ledger_sha256':digest(prod/'provenance/SIDIS_REUSE_MANIFEST.json')}

def audit(run,repo):
    run=access(run);repo=access(repo);m=read(run/'run.json')
    if m.get('schema')!=5 or m.get('profile')!=PROFILE or m.get('status')!='STAGES_PASS' or m.get('fresh') is not True:raise Blocked('complete fresh RU workflow required')
    if m['repo']!=str(repo) or not same_release(ROOT,m['release']) or m['sources']!=snapshot(repo/ENGINE):raise ValueError('run source/release mismatch')
    if m['runtime']!=runtime(repo) or m['sidis_sources']!=upstream_source_state(repo):raise ValueError('runtime/SIDIS sources changed')
    if m['reuse']!=check_reuse(repo/ENGINE):raise ValueError('reuse provenance changed')
    data=scientific_audit(run,repo)
    if rows_status(data['rows'])!='CHECKS_PASS':raise ValueError('current scientific comparisons failed')
    return m,data

def run_stages(repo,run,rt,start=0,validation_probe=False,stop=None):
    sources=snapshot(Path(repo)/ENGINE)
    for st in stages()[start:stop]:
        print(st['id']+': '+st['name'],flush=True)
        receipt=stage_execute(st,repo,run,rt,validation_probe)
        if snapshot(Path(repo)/ENGINE)!=sources:raise ValueError('candidate changed during execution')
        write(run/'receipts'/(st['id']+'.json'),receipt)

def run(a):
    release=release_integrity();repo=Path(a.repo).resolve();prod=repo/ENGINE
    rt=runtime(repo);reuse=check_reuse(prod)
    stop=[s['id'] for s in stages()].index(a.through)+1
    for st in stages()[:stop]:contained(prod,st['script'])
    state=output_path(a.state,repo,protected=[ROOT,prod],area='states');rid=datetime.datetime.now(datetime.timezone.utc).strftime('%Y%m%dT%H%M%SZ')+'-'+uuid.uuid4().hex[:12]
    dest=state/rid;dest.mkdir(parents=True,exist_ok=False)
    m={'schema':5,'profile':PROFILE,'fresh':True,'through':a.through,'status':'RUNNING','run_id':rid,'repo':str(repo),'release':release,'verification_scope':CHECK_SCOPE,'sources':snapshot(prod),'sidis_sources':upstream_source_state(repo),'runtime':rt,'reuse':reuse,'qualifications':QUALIFICATIONS}
    write(dest/'run.json',m);print(json.dumps({'run':str(dest)}),flush=True)
    try:
        run_stages(repo,dest,rt,stop=stop);m['status']='STAGES_PASS' if a.through=='r07' else 'DEVELOPMENT_PASS';write(dest/'run.json',m,replace=True)
        if a.through=='r07':audit(dest,repo)
    except Exception as exc:m.update(error_result(exc)[0])
    try:
        if m['sources']!=snapshot(prod) or m['runtime']!=runtime(repo):raise ValueError('inputs changed')
        if m['sidis_sources']!=upstream_source_state(repo):raise ValueError('original SIDIS sources changed')
        release_integrity()
    except Exception as exc:m.update(status='FAIL',preservation_error=str(exc))
    write(dest/'run.json',m,replace=True);print(json.dumps({'status':m['status'],'run':str(dest),'detail':m.get('detail')}))
    return 0 if m['status'] in ('STAGES_PASS','DEVELOPMENT_PASS') else 2 if m['status']=='BLOCKED' else 1

def main():
    p=argparse.ArgumentParser(description=__doc__);sub=p.add_subparsers(dest='command',required=True)
    for name in ('doctor','run','status'):
        q=sub.add_parser(name);q.add_argument('--repo',default=str(PROJECT))
        if name=='run':
            q.add_argument('--state',default='collins_support/states/runs');q.add_argument('--through',choices=[s['id'] for s in stages()],default='r07')
        if name=='status':q.add_argument('--run',required=True)
    a=p.parse_args()
    try:
        if a.command=='run':return run(a)
        release_integrity()
        if a.command=='status':m,d=audit(a.run,a.repo);print(json.dumps({'status':m['status'],'reference_status':rows_status(d['rows']),'qualifications':QUALIFICATIONS}));return 0
        prod=Path(a.repo)/ENGINE;missing=[s['script'] for s in stages() if not (prod/s['script']).is_file()]
        configured=(prod/'ru_runtime.json').is_file()
        if configured:runtime(a.repo)
        st='IMPLEMENTATION_REQUIRED' if missing or not configured else 'READY_TO_EXECUTE'
        print(json.dumps({'status':st,'missing_stage_sources':missing,'runtime_configured':configured,'note':'Path/runtime inventory only; no native or scientific acceptance.'},indent=2));return 2 if st=='IMPLEMENTATION_REQUIRED' else 0
    except Exception as exc:r,code=error_result(exc);print(json.dumps(r));return code

if __name__=='__main__':raise SystemExit(main())
