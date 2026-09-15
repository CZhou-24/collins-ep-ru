#!/usr/bin/env python3
"""Check two complete acceptance reports against current sources and run artifacts."""
import argparse,json
from pathlib import Path
from support import read,sha,release_integrity,write,snapshot,access,same_path,same_release,output_path
from verify_assembly import audit_run
import verify as foundation
import math
from verify_assembly import compare_new_runs,SCOPE
ROOT=Path(__file__).resolve().parent

def _check_rows(rows,label):
    if type(rows) is not list or not rows or any(type(c) is not dict or type(c.get('id')) is not str or c.get('status')!='PASS' for c in rows):
        raise ValueError('Incomplete/failed '+label+' checks')
    ids=[c['id'] for c in rows]
    if len(ids)!=len(set(ids)):raise ValueError('Duplicate '+label+' check IDs')
    return set(ids)

def _foundation_checks(file,f,r,repo,release,replay):
    """Recompute retained arithmetic and exact coverage from hashed evidence.

    This rechecks saved evidence; fresh native execution remains the verifier's
    job and is separately bound by run identity, proof receipts and replay.
    """
    profile='analytic_foundation' if r['profile']=='analytic_assembly' else 'foundation'
    if (f.get('status')!='CHECKS_PASS' or f.get('profile')!=profile or f.get('scope')!=foundation.SCOPE
        or not same_release(ROOT,f.get('validator_manifest_sha256')) or f.get('seed')!=r['seed']
        or f.get('sources')!=r['sources'] or f.get('runtime')!=r['runtime']
        or f.get('run')!=r['run'] or f.get('run_id')!=r['run_id']
        or f.get('run_manifest_sha256')!=r['run_manifest_sha256']
        or f.get('replay')!=replay['run_paths'][1]
        or f.get('baseline_before')!=r['baseline_before'] or f.get('baseline_after')!=r['baseline_after']):
        raise ValueError('Wrong retained foundation report metadata')
    ids=_check_rows(f.get('checks'),'foundation')
    work=file.with_name(file.stem+'-evidence')
    if snapshot(work)!=f.get('evidence_files'):raise ValueError('Retained foundation evidence changed')
    run=access(r['run']);production=Path(repo).resolve()/'collins_ep_analytic';export=run/'common/s09_result'
    m,done=foundation.audit_run(run,production)
    if set(done)!=foundation.RETAINED_STAGE_IDS:raise ValueError('Incomplete retained run stages')
    generated=[{'id':'workflow.provenance','status':'PASS','stages':len(done)}]
    for name in ('born_hard','spacelike_hard_one_loop'):
        payload=foundation.loads_export((export/(name+'.json')).read_text())
        if payload['component']!=name:raise ValueError('Wrong retained export component')
        generated.extend({**c,'id':name+'/'+c['id']} for c in foundation.validate_export(payload,r['seed']))
    generated.append(foundation.verify_derivation_map(export,run))
    saved={c['id']:c for c in f['checks']}
    for stage in foundation.stage_list():
        if not stage['proof_ids']:continue
        pf=work/stage['id']/'proof-check.json';proof=read(pf)
        if (proof.get('status')!='PASS' or proof.get('run_id')!=r['run_id'] or proof.get('stage')!=stage['id']
            or not foundation.valid_proof_ids(proof.get('proof_ids'),stage['proof_ids'])):
            raise ValueError('Wrong retained fresh proof receipt')
        row={'id':'proofs.'+stage['id'],'status':'PASS','identities':len(stage['proof_ids']),'report_sha256':sha(pf)}
        if saved.get(row['id'])!=row:raise ValueError('Changed retained proof record')
        generated.append(row)
    req=foundation.requests(r['seed']);ctx=read(work/'export-context.json')
    if ctx.get('requests')!=req:raise ValueError('Retained requests differ from seed')
    generated.extend(foundation.compare_response(req,read(work/'response.json'),ctx['run_id']))
    hard=[q for q in req if q['kind']=='hard'];bridge_req=read(work/'bridge-requests.json')
    if bridge_req!={'run_id':ctx['run_id'],'requests':hard}:raise ValueError('Wrong retained bridge requests')
    response=read(work/'bridge.json')
    if type(response) is not dict or set(response)!={'run_id','responses'} or response['run_id']!=ctx['run_id'] or type(response['responses']) is not list:
        raise ValueError('Wrong retained bridge envelope')
    rows={}
    for row in response['responses']:
        if type(row) is not dict or set(row)!={'id','values'} or type(row['id']) is not str or row['id'] in rows:raise ValueError('Wrong retained bridge row')
        rows[row['id']]=row['values']
    if set(rows)!={q['id'] for q in hard}:raise ValueError('Missing retained bridge response')
    for q in hard:
        got=rows[q['id']];want=foundation.expected(q)
        if type(got) is not dict or set(got)!={'H_UU','H_UT','h1'}:raise ValueError('Wrong retained bridge components')
        for key,v in got.items():
            if type(v) not in (int,float) or not math.isfinite(v) or abs(v-want[key])>2e-10*max(1,abs(want[key])):raise ValueError('Retained bridge arithmetic failed')
            generated.append({'id':'bridge.'+q['id']+'.'+key,'status':'PASS'})
    rerun=foundation.compare_runs(run,f['replay'],production)
    if saved.get(rerun['id'])!=rerun:raise ValueError('Missing/changed retained replay record')
    generated.append(rerun)
    if profile=='analytic_foundation':
        if f.get('numerical_regression')!='NOT_REQUESTED_ANALYTICAL_ONLY' or r.get('numerical_regression')!='NOT_REQUESTED_ANALYTICAL_ONLY':
            raise ValueError('Wrong analytic-only regression metadata')
    else:
        legacy=saved.get('numerical.regression')
        if not legacy or legacy.get('checks')!=457:raise ValueError('Missing 457-check numerical regression')
        nfile=work/f"numerical-{r['seed']}.json"
        if sha(nfile)!=legacy.get('report_sha256'):raise ValueError('Numerical regression report changed')
        nr=read(nfile);nc=nr.get('checks')
        if nr.get('status')!='PASS' or nr.get('profile')!='evolution' or nr.get('seed')!=r['seed'] or len(_check_rows(nc,'numerical'))!=457:
            raise ValueError('Incomplete numerical regression evidence')
        generated.append(legacy)
    needed=_check_rows(generated,'regenerated foundation')
    if ids!=needed or len(ids)!=(303 if profile=='analytic_foundation' else 304):raise ValueError('Wrong retained foundation check coverage')
    return f['checks']

def compare(repo,paths):
    if len(paths)!=2 or same_path(paths[0],paths[1]):raise ValueError('Two distinct reports required')
    release=release_integrity(ROOT);reports=[read(p) for p in paths]
    if {r.get('seed') for r in reports}!={1729,92741}:raise ValueError('Require both final seeds 1729 and 92741')
    profiles={r.get('profile') for r in reports}
    if len(profiles)!=1 or not profiles <= {'assembly','analytic_assembly'}:raise ValueError('Mixed or unsupported report profiles')
    pairs=[]
    for report_path,r in zip(paths,reports):
        checks=r.get('checks')
        if r.get('status')!='CHECKS_PASS' or r.get('scope')!=SCOPE or not same_release(ROOT,r.get('validator_manifest_sha256')) or type(checks) is not list or not checks or any(c.get('status')!='PASS' for c in checks):raise ValueError('Incomplete/failed/wrong-scope report')
        ids=_check_rows(checks,'assembly')
        work=access(report_path).with_name(Path(report_path).stem+'-evidence')
        if snapshot(work)!=r.get('evidence_files'):raise ValueError('Acceptance evidence changed')
        replay=[c for c in checks if c.get('id')=='assembly.clean_replay']
        if len(replay)!=1:raise ValueError('Missing replay record')
        m,done=audit_run(r['run'],Path(repo).resolve()/'collins_ep_analytic')
        if r['sources']!=m['source_sha256'] or r['runtime']!=m['runtime'] or r.get('run_id')!=m['run_id'] or r.get('baseline_before')!=m['baseline_before'] or r.get('baseline_after')!=m['baseline_after'] or sha(Path(r['run'])/'run.json')!=r['run_manifest_sha256']:raise ValueError('Report no longer matches current inputs/run')
        roots=[access(name) for name in replay[0]['run_paths']]
        if len(roots)!=2 or not same_path(roots[0],r['run']):raise ValueError('Wrong replay path identity')
        new=compare_new_runs(*roots,Path(repo).resolve()/'collins_ep_analytic')
        if ({k:v for k,v in new.items() if k!='run_paths'}!={k:v for k,v in replay[0].items() if k!='run_paths'}
            or len(new.get('run_paths',[]))!=2 or not all(same_path(a,b) for a,b in zip(new['run_paths'],replay[0]['run_paths']))):raise ValueError('Replay record changed')
        fr=r['foundation_report'];file=access(fr['path'])
        if file!=work/'foundation.json':raise ValueError('Wrong retained evidence location')
        if sha(file)!=fr['sha256']:raise ValueError('Retained foundation report changed')
        f=read(file)
        _foundation_checks(file,f,r,repo,release,replay[0])
        if fr.get('checks')!=len(f['checks']):raise ValueError('Wrong retained report count metadata')
        from assembly_oracle import coefficients,requests,compare_response
        run=access(r['run']);new_checks=coefficients(read(run/'common/s10_result/radiation.json'),read(run/'common/s11_result/operators.json'),read(run/'common/s12_result/assembly.json'),r['seed'])
        req=requests(r['seed']);ctx=read(work/'context.json')
        if ctx['requests']!=req:raise ValueError('Saved request set differs from seed')
        new_checks+=compare_response(req,read(work/'response.json'),ctx['run_id'])
        br=[x for x in req if x['kind']=='gaussian' or (x['kind']=='coefficient' and x['source'] in ('operators','assembly'))]
        new_checks+=compare_response(br,read(work/'bridge-response.json'),ctx['run_id'],'bridge')
        import bridge_probes
        new_checks+=bridge_probes.replay(work,r['seed'],ctx['run_id'])
        needed={c['id'] for c in new_checks}|{'assembly.clean_replay','assembly.backend_records','assembly.producer_map',
            'assembly.proof.s10','assembly.proof.s11','assembly.proof.s12'}|{'retained.'+c['id'] for c in f['checks']}
        if set(ids)!=needed or any(c['status']!='PASS' for c in new_checks):raise ValueError('Incomplete check coverage or failed replayed arithmetic')
        pairs.append(replay[0]['run_manifest_sha256'])
    if reports[0]['sources']!=reports[1]['sources'] or reports[0]['runtime']!=reports[1]['runtime'] or pairs[0]!=pairs[1]:raise ValueError('Final report inputs/run pairs differ')
    return {'status':'CHECKS_PASS','profile':reports[0]['profile'],'scope':SCOPE,'reports':[{'path':str(access(p)),'sha256':sha(p)} for p in paths],
            'seeds':[1729,92741],'validator_manifest_sha256':release}

def guard_output(repo,dest,reports):
    dest=access(dest,required=False)
    if dest.exists():raise ValueError('Report exists; choose a fresh path')
    protected=[ROOT,Path(repo).resolve()/'collins_ep_analytic',Path(repo).resolve()/'collins_ep_analytic_SIDIS',Path(repo).resolve()/'collins_ep']
    for p in reports:
        r=read(p)
        protected.extend((access(p),access(p).with_name(Path(p).stem+'-evidence')))
        if r.get('run'):protected.append(access(r['run']))
        for c in r.get('checks',[]):
            if c.get('id')=='assembly.clean_replay':protected.extend(access(x) for x in c.get('run_paths',[]))
    if any(dest.is_relative_to(p) for p in protected):raise ValueError('Write the pair report outside source and run directories')
    return output_path(dest,repo,protected=protected,area='reports')

def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--repo',default='/bigTMD');p.add_argument('--report',required=True);p.add_argument('reports',nargs=2);a=p.parse_args()
    try:dest=guard_output(a.repo,a.report,a.reports)
    except Exception as exc:print(json.dumps({'status':'FAIL','detail':str(exc)}));return 1
    try:r=compare(a.repo,a.reports);rc=0
    except Exception as exc:r={'status':'FAIL','detail':str(exc)};rc=1
    write(dest,r);print(json.dumps(r,indent=2));return rc
if __name__=='__main__':raise SystemExit(main())
