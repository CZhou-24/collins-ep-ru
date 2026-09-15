#!/usr/bin/env python3
"""Two fresh routes, native replay, master/reduction probes and retained replay."""
import argparse,json,shutil,sys
from pathlib import Path
import workflow
from ru_support import *
from algebra import decode,encode,equal,recompute,dependencies

def pair_inputs(repo,run,replay):
    run=access(run);replay=access(replay)
    if run==replay:raise ValueError('two distinct fresh runs required')
    ma,da=workflow.audit(run,repo);mb,db=workflow.audit(replay,repo)
    if ma['run_id']==mb['run_id']:raise ValueError('reused run ID')
    for key in ('sources','sidis_sources','runtime','release','accepted_source_hash','reuse','qualifications'):
        if ma[key]!=mb[key]:raise ValueError('fresh run inputs differ: '+key)
    if da['packets']!=db['packets']:raise ValueError('native packets differ between fresh runs')
    if set(da['masters'])!=set(db['masters']) or any(not equal(x,db['masters'][k]) for k,x in da['masters'].items()):raise ValueError('evaluated masters differ between fresh runs')
    return ma,da

def retained_replay(repo,pair,work):
    gate=accepted_pair(repo,pair);work.mkdir(parents=True,exist_ok=False)
    report=work/'pair.json'
    ex=execute([sys.executable,RETAINED/'compare_nlo_reports.py','--repo',repo,'--report',report,*[str(access(r['path'])) for r in gate['reports']]],repo,work/'execution.log',86400)
    if ex['exit_code']!=0 or read(report).get('status')!='CHECKS_PASS':raise Blocked('retained v0.4.0/v0.3.3 evidence replay failed; see '+str(work))
    return {'identity':gate,'execution':ex,'report_sha256':digest(report)}

def recipes_equal(a,b,scaled=(),factor=None):
    if set(a)!=set(b):raise ValueError('probe changed recipe inventory')
    for k,x in a.items():
        y=b[k];scale=factor if k in scaled else decode(1)
        if x['eta_order']!=y['eta_order'] or x['eps_order']!=y['eps_order'] or x['sectors']!=y['sectors']:raise ValueError('probe changed recipe scope')
        if not equal(decode(y['constant']),scale*decode(x['constant'])):raise ValueError('probe changed constant outside its expected response')
        tx={t['ref']:decode(t['factor']) for t in x['terms']};ty={t['ref']:decode(t['factor']) for t in y['terms']}
        if set(tx)!=set(ty) or any(not equal(ty[n],scale*v) for n,v in tx.items()):raise ValueError('probe bypassed fixed assembly/reduction dependence')

def choose_master(data,stage,seed):
    candidates=sorted(k for k in data['masters'] if '/'+stage+'/' in k)
    if not candidates:raise ValueError('no candidate masters')
    offset=seed%len(candidates);candidates=candidates[offset:]+candidates[:offset]
    for key in candidates:
        changed=dict(data['masters']);changed[key]*=decode(2);values=recompute(data['recipes'],changed)
        if any(not equal(values[e['value']],data['values'][e['value']]) for e in data['exports'].values()):return key
    raise ValueError('no master with a nonzero final coefficient response: '+stage)

def prefix_copy(baseline,probe,start):
    for st in workflow.stages()[:start]:
        sid=st['id'];shutil.copytree(baseline/'common'/(sid+'_result'),probe/'common'/(sid+'_result'),symlinks=True)
        (probe/'receipts').mkdir(parents=True,exist_ok=True)
        shutil.copy2(baseline/'receipts'/(sid+'.json'),probe/'receipts'/(sid+'.json'))

def reseal_derived_prefix(probe,sid,jobids,rt):
    """Mark copied, deliberately mutated inputs; never call these fresh tool runs."""
    path=probe/'receipts'/(sid+'.json');r=read(path);out=probe/'common'/(sid+'_result')
    for jr in r['jobs']:
        if jr['job']['id'] not in jobids:continue
        w=out/'jobs'/jr['job']['id'];jr['outputs']={n:digest(contained(w,n)) for n in jr['job']['outputs']}
        if jr['kind']=='subtropica':
            (w/'masters.json').unlink()
            jr['mutation_reexport']=workflow.export_native(w/'masters.wl',w/'masters.json','masters',rt,w/'mutation-export')
        else:
            cp=w/'kira_audit_context.json';ctx=read(cp);old=Path(read(out/'context.json')['output'])
            for name in ('master_inventory','native_output','output'):
                ctx[name]=str(out/Path(ctx[name]).relative_to(old))
            ctx['rule_files']=[str(out/Path(f).relative_to(old)) for f in ctx['rule_files']]
            write(cp,ctx,replace=True)
            ex=execute([rt['config']['wolfram_kernel'],'-noprompt','-script',ROOT/'native_kira_audit.wls'],w,w/'kira_mutation_audit.log',rt['config']['timeout_seconds'],{'COLLINS_RU_KIRA_AUDIT':cp})
            if ex['exit_code']!=0:raise Blocked('mutated Kira rules failed native audit')
            jr['mutation_kira_audit']=ex;jr['audited_outputs']={n:digest(w/n) for n in jr['audited_outputs']}
        jr['derived_probe_input']=True
    r['derived_probe_input']=True;r['tree']=snapshot(out);write(path,r,replace=True)

def kira_mutation_jobs(baseline,probe,receipt):
    jobs=[]
    for jr in receipt['jobs']:
        jid=jr['job']['id'];rel=Path('common/r01_result/jobs')/jid
        paths=[str(contained(probe/rel,n)) for n in jr['outputs']
               if n.startswith('results/') and n.endswith('.m')]
        if not paths:raise ValueError('no audited Kira rule files to perturb: '+jid)
        jobs.append({'id':jid,'paths':paths,'certificate':str(contained(baseline/rel,'reduction_certificate.wl')),
                     'probe_certificate':str(contained(probe/rel,'reduction_certificate.wl'))})
    if not jobs or len({j['id'] for j in jobs})!=len(jobs):raise ValueError('invalid Kira mutation jobs')
    return jobs

def validate_reduction_response(result,mutation):
    jobs=result.get('jobs',[])
    if result.get('status')!='PASS' or result.get('scope')!='complete_audited_reduction_map' or result.get('factor')!=[mutation['numerator'],mutation['denominator']]:
        raise ValueError('wrong native reduction response identity')
    if not isinstance(jobs,list) or [j.get('id') for j in jobs]!=[j['id'] for j in mutation['jobs']]:
        raise ValueError('incomplete native reduction response jobs')
    for job in jobs:
        count=job.get('rules');identities=job.get('identity_rules')
        if type(count) is not int or count<1 or type(identities) is not int or not 0<=identities<=count or job.get('residuals')!=['0']*count:
            raise ValueError('incomplete/failed native reduction response')

def reduction_response_bindings(mutation):
    return {j['id']:{name:digest(j[name]) for name in ('certificate','probe_certificate')}
            for j in mutation['jobs']}

def audit_reduction_response(mutation,rt,probe):
    ex=execute([rt['config']['wolfram_kernel'],'-noprompt','-script',ROOT/'native_probe_audit.wls'],
               probe,probe/'reduction-response.log',rt['config']['timeout_seconds'],
               {'COLLINS_RU_MUTATION':probe/'mutation-context.json'})
    if ex['exit_code']!=0:raise Blocked('native reduction-map response audit failed: '+str(probe))
    validate_reduction_response(read(mutation['audit_output']),mutation)
    return {'execution':ex,'sha256':digest(mutation['audit_output']),
            'bindings':reduction_response_bindings(mutation)}

def make_probe(kind,seed,repo,baseline,ma,data,work):
    probe=work/kind;probe.mkdir(parents=True);factor=decode(str(seed%5+7)+'/6')
    start=2 if kind=='kira_real_rules' else 3 if kind=='real_master' else 6
    prefix_copy(baseline,probe,start);sid='r01' if kind=='kira_real_rules' else 'r02' if kind=='real_master' else 'r05'
    mutation={'kind':'kira' if kind=='kira_real_rules' else 'master','numerator':int(factor.p),'denominator':int(factor.q)}
    jobids=[];key=None
    if kind=='kira_real_rules':
        jobs=kira_mutation_jobs(baseline,probe,read(probe/'receipts/r01.json'))
        jobids=[j['id'] for j in jobs]
        mutation.update(jobs=jobs,paths=[p for j in jobs for p in j['paths']],
                        scope='complete_audited_reduction_map',audit_output=str(probe/'reduction-response.json'))
    else:
        key=choose_master(data,sid,seed);loc=data['locations'][key];jobids=[loc['job']]
        mutation.update(path=str(probe/'common'/(sid+'_result')/'jobs'/loc['job']/'masters.wl'),key=loc['key'])
    write(probe/'mutation-context.json',mutation)
    changed_paths=mutation.get('paths',[mutation.get('path')]);before={str(Path(p).relative_to(probe)):digest(p) for p in changed_paths}
    ex=execute([ma['runtime']['config']['wolfram_kernel'],'-noprompt','-script',ROOT/'native_mutate.wls'],probe,probe/'mutation.log',ma['runtime']['config']['timeout_seconds'],{'COLLINS_RU_MUTATION':probe/'mutation-context.json'})
    if ex['exit_code']!=0:raise Blocked('native mutation failed: '+str(probe))
    after={str(Path(p).relative_to(probe)):digest(p) for p in changed_paths}
    if before==after:raise ValueError('native mutation had no effect')
    reseal_derived_prefix(probe,sid,jobids,ma['runtime'])
    reduction_response=audit_reduction_response(mutation,ma['runtime'],probe) if kind=='kira_real_rules' else None
    workflow.run_stages(repo,probe,ma['runtime'],start,validation_probe=True)
    actual=workflow.scientific_audit(probe,repo)
    expected=check_probe(kind,data,actual,key,factor)
    result={'kind':kind,'seed':seed,'baseline':str(baseline),'factor':encode(factor),'master':key,'mutation':mutation,'execution':ex,'before':before,'after':after,'start_stage':workflow.stages()[start]['id'],'status':'PASS','changed_exports':expected,'fresh_workflow':False,'meaning':'validator-mutated copied inputs followed by fresh downstream execution'}
    if reduction_response is not None:result['reduction_response']=reduction_response
    write(probe/'probe.json',result)
    return result

def check_probe(kind,before,after,key,factor):
    if set(before['masters'])!=set(after['masters']):raise ValueError('probe changed master inventory')
    if before['exports']!=after['exports']:raise ValueError('probe changed exported value bindings')
    expected_masters=dict(before['masters']);scaled=[]
    if kind=='kira_real_rules':
        scaled=before['packets']['r03'].get('integrated_values',[])
        if not scaled or len(scaled)!=len(set(scaled)):raise ValueError('r03 integrated_values required for Kira probe')
        for k in scaled:
            r=before['recipes'].get(k)
            if not r or not equal(decode(r['constant']),decode(0)) or not r['terms'] or any(not t['ref'].startswith('master/r02/') for t in r['terms']):raise ValueError('integrated_values must be pure linear real-master contractions')
        direct=[k for k,r in before['recipes'].items() if any(t['ref'].startswith('master/r02/') for t in r['terms'])]
        if set(scaled)!=set(direct):raise ValueError('integrated_values must include all direct real-master contractions')
    else:expected_masters[key]*=factor
    for k,v in expected_masters.items():
        if not equal(v,after['masters'][k]):raise ValueError('unexpected master change: '+k)
    recipes_equal(before['recipes'],after['recipes'],scaled,factor)
    expected=recompute(after['recipes'],expected_masters)
    for k,x in after['values'].items():
        if k in expected and not equal(x,expected[k]):raise ValueError('wrong downstream response: '+k)
    changed=[name for name,e in before['exports'].items() if not equal(before['values'][e['value']],after['values'][e['value']])]
    if not changed:raise ValueError('no nonzero response in compared coefficients')
    return changed

def mutation_jobs_equal(recorded,current):
    # Only these declared native evidence paths relocate; job IDs remain exact.
    if not isinstance(recorded,list) or len(recorded)!=len(current):return False
    for old,new in zip(recorded,current):
        if set(old)!=set(new) or old['id']!=new['id'] or len(old['paths'])!=len(new['paths']):return False
        if any(not same_path(a,b) for a,b in zip(old['paths'],new['paths'])):return False
        if any(not same_path(old[k],new[k]) for k in ('certificate','probe_certificate')):return False
    return True

def replay_probe(path,repo,baseline,data):
    path=access(path);baseline=access(baseline);p=read(path/'probe.json');factor=decode(p['factor'])
    if not same_path(p['baseline'],baseline) or p['status']!='PASS' or p['fresh_workflow'] is not False:raise ValueError('wrong probe identity')
    if p['execution']['exit_code']!=0 or p['execution']['log_sha256']!=digest(path/'mutation.log') or p['mutation']!=read(path/'mutation-context.json'):raise ValueError('changed mutation receipt')
    for rel,d in p['before'].items():
        if digest(baseline/rel)!=d:raise ValueError('wrong baseline mutation input')
    for rel,d in p['after'].items():
        if digest(path/rel)!=d:raise ValueError('changed mutated input')
    if p['kind']=='kira_real_rules':
        mutation=p['mutation'];record=p['reduction_response'];ex=record['execution']
        expected_jobs=kira_mutation_jobs(baseline,path,read(path/'receipts/r01.json'))
        if not mutation_jobs_equal(mutation.get('jobs'),expected_jobs) or mutation.get('scope')!='complete_audited_reduction_map' or not same_path(mutation.get('audit_output'),path/'reduction-response.json'):
            raise ValueError('changed complete-map mutation bindings')
        if ex['exit_code']!=0 or ex['log_sha256']!=digest(path/'reduction-response.log') or record['sha256']!=digest(path/'reduction-response.json') or record['bindings']!=reduction_response_bindings(mutation):
            raise ValueError('changed native reduction response evidence')
        validate_reduction_response(read(path/'reduction-response.json'),mutation)
    actual=workflow.scientific_audit(path,repo)
    if check_probe(p['kind'],data,actual,p['master'],factor)!=p['changed_exports']:raise ValueError('changed probe response')
    return {'id':'probe.'+p['kind'],'status':'PASS','changed_exports':len(p['changed_exports'])}

def replay_rows(repo,run,replay,work,seed):
    ma,data=pair_inputs(repo,run,replay);rows=list(data['rows'])
    for st in workflow.stages():
        p=work/'native-replay'/st['id'];ex=read(p/'receipt.json')
        if ex['exit_code']!=0 or ex['log_sha256']!=digest(p/'job/execution.log') or read(p/'packet.json')!=data['packets'][st['id']]:raise ValueError('native packet replay changed')
    for key,loc in data['locations'].items():
        p=work/'master-replay'/loc['stage']/loc['job'];ex=read(p/'receipt.json')
        if ex['exit_code']!=0 or ex['log_sha256']!=digest(p/'job/execution.log') or not equal(decode(read(p/'masters.json')[loc['key']]),data['masters'][key]):raise ValueError('native master replay changed')
    for kind in read(ROOT/'contract.json')['probe_kinds']:
        p=work/'probes'/kind
        if read(p/'probe.json')['seed']!=seed:raise ValueError('wrong probe seed')
        rows.append(replay_probe(p,repo,access(run),data))
    rows.append({'id':'native.packet_replay','status':'PASS'})
    return rows

def verify(a):
    repo=access(a.repo);run=access(a.run);replay=access(a.replay)
    dest=disjoint(a.report,[repo,ROOT,run,replay,access(a.accepted_pair).parent]);work=dest.with_name(dest.stem+'-evidence')
    if dest.exists() or work.exists():raise ValueError('choose unused report path')
    work.mkdir(parents=True);result={'schema':5,'profile':'reverse_unitarity','seed':a.seed,'run':str(run),'replay':str(replay),'qualifications':QUALIFICATIONS,'status':'BLOCKED','checks':[]}
    try:
        if a.seed not in (1729,92741):raise ValueError('official seeds: 1729 and 92741')
        ma,data=pair_inputs(repo,run,replay)
        result.update(release=release_integrity(),sources=ma['sources'],runtime=ma['runtime'],run_sha256=digest(run/'run.json'),replay_sha256=digest(replay/'run.json'))
        result['retained']=retained_replay(repo,a.accepted_pair,work/'retained')
        for st in workflow.stages():
            p=work/'native-replay'/st['id'];p.mkdir(parents=True)
            ex=workflow.export_native(run/'common'/(st['id']+'_result')/'packet.wl',p/'packet.json','packet',ma['runtime'],p/'job');write(p/'receipt.json',ex)
        seen=set()
        for loc in data['locations'].values():
            group=(loc['stage'],loc['job'])
            if group in seen:continue
            seen.add(group);p=work/'master-replay'/loc['stage']/loc['job'];p.mkdir(parents=True)
            ex=workflow.export_native(loc['path'],p/'masters.json','masters',ma['runtime'],p/'job');write(p/'receipt.json',ex)
        for kind in read(ROOT/'contract.json')['probe_kinds']:make_probe(kind,a.seed,repo,run,ma,data,work/'probes')
        result['checks']=replay_rows(repo,run,replay,work,a.seed);result['status']=rows_status(result['checks'])
        pair_inputs(repo,run,replay)
    except Exception as exc:result.update(error_result(exc)[0])
    result['evidence_snapshot']=snapshot(work);write(dest,result)
    print(json.dumps({'status':result['status'],'report':str(dest),'checks':len(result['checks']),'detail':result.get('detail'),'qualifications':QUALIFICATIONS}))
    return 0 if result['status']=='CHECKS_PASS' else 2 if result['status']=='BLOCKED' else 1

def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--repo',default='/bigTMD');p.add_argument('--run',required=True);p.add_argument('--replay',required=True);p.add_argument('--seed',type=int,required=True);p.add_argument('--report',required=True);p.add_argument('--accepted-pair',default='collins_support/states/Collins-ep-analytic-state-v0.4.0/literature-revalidation-001/nlo-pair.json')
    try:return verify(p.parse_args())
    except Exception as exc:r,c=error_result(exc);print(json.dumps(r));return c
if __name__=='__main__':raise SystemExit(main())
