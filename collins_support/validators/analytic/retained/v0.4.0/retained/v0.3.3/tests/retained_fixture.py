"""Synthetic retained evidence helpers. No native derivation is represented."""
import argparse, contextlib, io, os
from pathlib import Path
from unittest.mock import patch
import verify as foundation
from selftest_oracle import fixture
from support import write, read, sha, snapshot


def populate_run(run):
    for sid,names in foundation.SEMANTIC.items():
        for name in names:
            p=run/'common'/f'{sid}_result'/name;p.parent.mkdir(parents=True,exist_ok=True)
            if name.endswith('.json'):write(p,fixture(name.removesuffix('.json')))
            else:p.write_text('MOCKED retained semantic '+sid+'/'+name)
    export=run/'common/s09_result'
    (export/'soft_pilot.wl').write_bytes((run/'common/s08_result/soft_pilot.wl').read_bytes())
    producers={'H_UU':'s03/tensors.wl','H_UT':'s03/tensors.wl','h1':'s07/hard.wl',
        **{key:'s08/soft_pilot.wl' for key in ('soft.kernel','soft.angular_primitive','soft.prefactor','soft.slice')}}
    entries={}
    for key,producer in producers.items():
        sid,name=producer.split('/');rel=f'common/{sid}_result/{name}'
        entries[key]={'artifact':rel,'sha256':sha(run/rel),'description':'MOCKED producer'}
    write(export/'derivation_map.json',{'schema':1,'entries':entries,'external_inputs':[]})


def foundation_report(repo,run,replay,state,file,seed,profile,manifest,legacy_mode='pass',execution_mutation=None):
    """Run real foundation orchestration with explicitly mocked native processes."""
    state.mkdir(parents=True,exist_ok=True)
    (repo/'collins_ep').mkdir(parents=True,exist_ok=True)
    (repo/'collins_ep/__init__.py').write_text('raise RuntimeError("fitted provider imported")\n')
    (repo/'collins_ep_analytic/numerics').mkdir(parents=True,exist_ok=True)
    (repo/'collins_ep_analytic/numerics/evaluate.py').write_text('# MOCKED coefficient bridge')
    args=argparse.Namespace(repo=str(repo),run=str(run),replay=str(replay) if replay else None,
        profile=profile,seed=seed,report=str(file),numerical_state=str(state),numerical_validator='/MOCKED',numerical_timeout=10)
    executions=[];legacy_calls=[]
    def execute(cmd,cwd,log,timeout,env=None):
        executions.append(cmd)
        if env:
            c=read(env['COLLINS_ANALYTIC_CONTEXT'])
            if 'proof_ids' in c:
                output={'status':'PASS','run_id':c['run_id'],'stage':c['stage'],'proof_ids':c['proof_ids']}
                if execution_mutation=='duplicate_proof':output['proof_ids']+=output['proof_ids'][:1]
                write(c['proof_report'],output)
            else:
                output={'run_id':c['run_id'],'status':'PASS','responses':[{'id':r['id'],'values':foundation.expected(r)} for r in c['requests']]}
                if execution_mutation=='missing_response':output['responses'].pop()
                write(c['response'],output)
            Path(log).write_text('MOCKED native execution')
        else:
            c=read(cmd[-1]);write(log,{'run_id':c['run_id'],'responses':[{'id':r['id'],'values':{k:v for k,v in foundation.expected(r).items() if k in ('H_UU','H_UT','h1')}} for r in c['requests']]})
        return {'exit_code':0,'argv':cmd,'log_sha256':sha(log)}
    def legacy(args,work,seed):
        legacy_calls.append(seed)
        if legacy_mode=='raise':raise ValueError('legacy sentinel reached')
        nf=work/f'numerical-{seed}.json'
        write(nf,{'status':'PASS','profile':'evolution','seed':seed,'checks':[{'id':f'MOCKED.numeric.{i}','status':'PASS'} for i in range(457)]})
        return {'id':'numerical.regression','status':'PASS','checks':457,'report_sha256':sha(nf),'execution':{'scope':'MOCKED numerical execution'}}
    done={sid:{'no_cache_requested':True} for sid in foundation.RETAINED_STAGE_IDS}
    def audit(path,production):
        m=dict(manifest)
        if Path(path).resolve()!=run.resolve():m['run_id']='MOCKED replay'
        return m,done
    with contextlib.ExitStack() as stack:
        for name,value in [('release_integrity',lambda p:'MOCKED release'),('baseline_check',lambda *x:manifest['baseline_after']),('audit_run',audit),('execute',execute),('legacy_check',legacy)]:
            stack.enter_context(patch.object(foundation,name,value))
        with contextlib.redirect_stdout(io.StringIO()):rc=foundation.verify(args)
    return rc,read(file),executions,legacy_calls
