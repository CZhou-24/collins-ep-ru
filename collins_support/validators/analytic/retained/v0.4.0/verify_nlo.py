#!/usr/bin/env python3
"""Fresh retained acceptance, NLO consistency, native export and dependency probes."""
import argparse,json,sys
from pathlib import Path
from nlo_support import *
import nlo_checks as checks,workflow,oracles,provenance
from symbolic import encode,decode

SCOPE='One-loop leading-power Collins ep with independent HF matching; narrow-cone/R1 qualification retained; not unrestricted fixed-order NLO or Figure 6.'
QUALIFICATIONS={'source_review':'REQUIRED','radius_R1_certification':'NOT_GRANTED',
 'full_fixed_order_NLO':'OUTSIDE_SCOPE','figure6':'PAUSED','fitted_providers':'NOT_REQUIRED',
 'finite_HF_reference':'native-route and upstream checks; source review required',
 'closed_full_twist3_evolution':'NOT_CLAIMED'}

def packets(run):return {s['id']:read(access(run)/'common'/(s['id']+'_result')/'packet.json') for s in workflow.stages()}

def fresh_pair(repo,a,b):
    a,b=access(a),access(b)
    if a==b:raise ValueError('two distinct fresh runs required')
    ma,_=workflow.audit(a,repo);mb,_=workflow.audit(b,repo)
    if ma['run_id']==mb['run_id'] or ma['base_run']==mb['base_run']:raise ValueError('reused NLO or retained run')
    for key in ('sources','runtime','release_sha256','accepted_source_hash','numerical_state'):
        if ma[key]!=mb[key]:raise ValueError('fresh-pair inputs differ: '+key)
    for st in workflow.stages():
        if read(a/'common'/(st['id']+'_result')/'packet.json')!=read(b/'common'/(st['id']+'_result')/'packet.json'):
            raise ValueError('nonreproducible scientific packet: '+st['id'])
        if (a/'common'/(st['id']+'_result')/'packet.wl').read_bytes()!=(b/'common'/(st['id']+'_result')/'packet.wl').read_bytes():
            raise ValueError('nonreproducible native packet: '+st['id'])
    return ma,mb

def save_probe(kind,seed,m,run,work):
    prod=access(m['production']);stages={s['id']:s for s in workflow.stages()};sid='d17' if kind=='HF' else 'd18'
    root=work/('probe-'+kind);root.mkdir()
    delta=oracles.probe_density(seed,kind)
    probe={'schema':1,'kind':kind+'_epsilon_projector','delta':encode(delta),
           'insertion':'epsilon numerator before the normalized -1/epsilon transverse master; no direct finite-export edits'}
    inp=workflow.inputs_for(m['base_run'],run);out=root/sid
    receipt=workflow.stage_execute(stages[sid],prod,out,inp,m['run_id']+'-'+kind+'-'+str(seed),m['runtime'],probe)
    write(root/'receipt.json',receipt)
    inp[sid]=out
    aout=root/'d19'
    ar=workflow.stage_execute(stages['d19'],prod,aout,inp,m['run_id']+'-assembly-'+kind+'-'+str(seed),m['runtime'],
                            {'schema':1,'kind':'recompute_from_replaced_dependency'})
    write(root/'assembly-receipt.json',ar)
    return root

def audit_saved_stage(stage,out,receipt,prod,inputs):
    r=read(receipt)
    if r.get('status')!='PASS' or r.get('stage')!=stage['id'] or r.get('no_cache_requested') is not True:raise ValueError('invalid saved probe receipt')
    if r['artifacts']!={f:sha(relative(out,f)) for f in stage['artifacts']} or r['artifact_tree']!=snapshot(out):raise ValueError('changed probe tree')
    if r['execution']['exit_code']!=0 or r['execution']['log_sha256']!=sha(out/'execution.log'):raise ValueError('changed probe execution')
    if r['native_reexport']['exit_code']!=0 or r['native_reexport']['log_sha256']!=sha(out/'native-reexport/execution.log'):raise ValueError('changed probe reexport')
    if read(out/'native-reexport/packet.json')!=read(out/'packet.json'):raise ValueError('changed probe native packet')
    if stage['id']=='d19':
        ex=r['observable_reexport']
        if ex['exit_code']!=0 or ex['log_sha256']!=sha(out/'native-observable/execution.log'):raise ValueError('changed native observable probe export')
    if r['provenance']!=provenance.check(stage,out,prod,inputs):raise ValueError('changed probe graph')
    return r

def replay_rows(repo,run,replay,work,seed):
    run,replay=access(run),access(replay)
    m,_=fresh_pair(repo,run,replay);ps=packets(run);base=access(m['base_run']);prod=access(m['production'])
    base_matching=read(base/'common/d13_result/finite_matching.json')
    rows=checks.check_all(ps,base_matching)
    stages={s['id']:s for s in workflow.stages()}
    for sid in stages:
        r=read(work/'reexports'/sid/'receipt.json')
        if r['exit_code']!=0 or r['log_sha256']!=sha(work/'reexports'/sid/'execution.log'):raise ValueError('fresh reexport receipt changed')
        if read(work/'reexports'/sid/'packet.json')!=ps[sid]:raise ValueError('fresh native JSON changed')
    rows.append(checks.row('native.fresh_reexports',True))
    observed=read(work/'observable-reexport/observable.json')
    workflow.check_observable_export(observed,ps['d19']['data'])
    ox=read(work/'observable-reexport/receipt.json')
    if ox['exit_code']!=0 or ox['log_sha256']!=sha(work/'observable-reexport/execution.log'):raise ValueError('fresh observable receipt changed')
    rows.append(checks.row('native.fresh_observable_export',True))
    for kind in ('HF','jet'):
        sid='d17' if kind=='HF' else 'd18';root=work/('probe-'+kind);inp=workflow.inputs_for(base,run)
        out=root/sid;delta=oracles.probe_density(seed,kind)
        audit_saved_stage(stages[sid],out,root/'receipt.json',prod,inp)
        ctx=read(out/'context.json');expected={'schema':1,'kind':kind+'_epsilon_projector','delta':encode(delta),
                'insertion':'epsilon numerator before the normalized -1/epsilon transverse master; no direct finite-export edits'}
        if (ctx['probe']!=expected or set(ctx['inputs'])!=set(inp)
            or any(not same_path(ctx['inputs'][k],v) for k,v in inp.items())
            or not same_path(ctx['production'],prod)):raise ValueError('wrong saved probe request')
        inp[sid]=out
        audit_saved_stage(stages['d19'],root/'d19',root/'assembly-receipt.json',prod,inp)
        acontext=read(root/'d19/context.json')
        if set(acontext['inputs'])!=set(inp) or any(not same_path(acontext['inputs'][k],v) for k,v in inp.items()):raise ValueError('wrong probe assembly inputs')
        changed=read(out/'packet.json');asm=read(root/'d19/packet.json')
        rows.extend(checks.probe_checks(kind,ps[sid],changed,delta,asm))
        d17=changed if kind=='HF' else ps['d17'];d18=changed if kind=='jet' else ps['d18']
        specific=checks.d17_checks(changed,base_matching) if kind=='HF' else checks.d18_checks(changed)
        rows.extend({**r,'id':'probe.'+kind+'.consistency.'+r['id']} for r in specific)
        rows.extend({**r,'id':'probe.'+kind+'.consistency.'+r['id']} for r in checks.d19_checks(asm,d17,d18))
    return rows

def guard(repo,dest,a,b):
    protected=[Path(repo),ROOT,access(a),access(b)]
    for run in (a,b):
        p=access(run)/'run.json'
        if p.is_file() and read(p).get('base_run'):protected.append(access(read(p)['base_run']))
    return outside(dest,protected,new=True)

def verify(a):
    repo=Path(a.repo).resolve();run=access(a.run);replay=access(a.replay)
    dest=guard(repo,a.report,run,replay);work=dest.with_name(dest.stem+'-evidence')
    guard(repo,work,run,replay);work.mkdir(parents=True)
    result={'schema':4,'profile':'leading_power_nlo_extension','scope':SCOPE,'qualifications':QUALIFICATIONS,
      'seed':a.seed,'run':str(run),'replay':str(replay),'checks':[],'status':'BLOCKED'}
    try:
        if a.seed not in (1729,92741):raise ValueError('official seeds are 1729 and 92741')
        ma,mb=fresh_pair(repo,run,replay)
        result.update(release_sha256=release_integrity(),sources=ma['sources'],runtime=ma['runtime'],
            run_manifest_sha256=sha(run/'run.json'),replay_manifest_sha256=sha(replay/'run.json'))
        br=work/'retained.json'
        ex=execute([sys.executable,BASE/'verify_derivation.py','--repo',repo,'--run',access(ma['base_run']),'--replay',access(mb['base_run']),
          '--seed',str(a.seed),'--numerical-state',access(ma['numerical_state']),'--report',br],repo,work/'retained.log',86400)
        result['retained']={'path':str(br),'sha256':sha(br) if br.is_file() else None,'execution':ex}
        if ex['exit_code']!=0 or read(br).get('status')!='CHECKS_PASS':raise (Blocked if ex['exit_code']==2 else ValueError)('retained acceptance did not pass')
        for st in workflow.stages():
            w=work/'reexports'/st['id'];ex=workflow.reexport(run/'common'/(st['id']+'_result'),w,ma['runtime']);write(w/'receipt.json',ex)
        w=work/'observable-reexport';ex=workflow.reexport_observable(run/'common/d19_result',w,ma['runtime']);write(w/'receipt.json',ex)
        for kind in ('HF','jet'):save_probe(kind,a.seed,ma,run,work)
        result['checks']=replay_rows(repo,run,replay,work,a.seed)
        result['status']=status(result['checks'])
        fresh_pair(repo,run,replay)
    except Exception as exc:
        result['status']='BLOCKED' if isinstance(exc,(Blocked,FileNotFoundError)) else 'FAIL';result['detail']=str(exc)
    try:
        if 'ma' in locals():fresh_pair(repo,run,replay)
        result['evidence_snapshot']=snapshot(work)
    except Exception as exc:result['status']='FAIL';result['preservation_error']=str(exc)
    write(dest,result)
    print(json.dumps({'status':result['status'],'checks':len(result['checks']),'report':str(dest),'qualifications':QUALIFICATIONS}))
    return 0 if result['status']=='CHECKS_PASS' else 2 if result['status']=='BLOCKED' else 1

def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--repo',default='/bigTMD');p.add_argument('--run',required=True)
    p.add_argument('--replay',required=True);p.add_argument('--seed',required=True,type=int);p.add_argument('--report',required=True)
    try:return verify(p.parse_args())
    except Exception as e:print(json.dumps({'status':'FAIL','detail':str(e)}));return 1
if __name__=='__main__':raise SystemExit(main())
