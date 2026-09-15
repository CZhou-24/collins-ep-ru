"""Real filesystem/Git tests with MOCKED physics backends. No physics certification."""
import argparse,contextlib,copy,io,json,os,tempfile,unittest
from pathlib import Path
from unittest.mock import patch
import workflow,verify_assembly as va,install,extension_inputs as locks
from support import read,sha,snapshot,write
from selftest_workflow import WorkflowOrchestrationTests
from assembly_reference import references
from assembly_oracle import packet,expected

class NewStageWorkflowTests(WorkflowOrchestrationTests):
    # Inherited runner failure/preservation probes now run over all thirteen stages.
    def setUp(self):
        original=workflow.stage_list();super().setUp()
        self.stages=original;self.by_id={s['id']:s for s in self.stages}
        for stage in self.stages:
            p=self.production/stage['script'];p.parent.mkdir(parents=True,exist_ok=True);p.write_text('# MOCKED NEW STAGE\n')
        original_runtime=self.fake_runtime_record
        self.start_patch('runtime_record',lambda path:{**original_runtime(path),'extension':{'stage_timeout_seconds':30},'derivation':{'config':{'stage_timeout_seconds':30}}})
    def test_new_stubs_block(self):
        self.stage_exit['s10']=2
        rc,_=self.run_workflow(through='s12')
        self.assertEqual(rc,2)
    def test_new_dependencies_complete(self):
        self.assertEqual([s['id'] for s in workflow.ancestors('s12')],[f's{i:02}' for i in range(13)])
    def test_new_missing_artifact(self):
        self.omit_artifact['s11']='operators.json'
        rc,_=self.run_workflow(through='s12')
        self.assertEqual(rc,1)
    def stable_json(self):
        for stage in self.stages:
            def effect(context,output,s=stage):
                for name in s['artifacts']:
                    if name.endswith('.json'):write(output/name,{'scope':'MOCKED semantic fixture','stage':s['id'],'artifact':name})
            self.effects[stage['id']]=effect
    def test_new_clean_replay(self):
        self.stable_json();a=self.successful_run('s12');b=self.successful_run('s12')
        row=va.compare_new_runs(a,b,self.production)
        self.assertEqual(row['status'],'PASS');self.assertEqual(row['new_canonical_outputs'],22)
    def test_new_derivation_receipts_do_not_expand_retained_acceptance(self):
        self.stable_json();a=self.successful_run('d15');b=self.successful_run('d15')
        self.assertEqual(set(va.audit_run(a,self.production)[1]),va.RETAINED_STAGE_IDS)
        self.assertEqual(va.compare_new_runs(a,b,self.production)['status'],'PASS')
    def test_changed_derivation_receipt_still_fails_full_audit(self):
        self.stable_json();a=self.successful_run('d15');b=self.successful_run('d15')
        p=a/'receipts/d14.json';row=read(p);row['run_id']='stale';write(p,row)
        with self.assertRaises(ValueError):va.compare_new_runs(a,b,self.production)
    def test_new_stage_cache_request_rejected(self):
        self.stable_json();a=self.successful_run('s12');b=self.successful_run('s12')
        p=b/'receipts/s12.json';row=read(p);row['no_cache_requested']=False;write(p,row)
        with self.assertRaisesRegex(ValueError,'cache-enabled'):va.compare_new_runs(a,b,self.production)
    def test_same_run_rejected(self):
        self.stable_json();a=self.successful_run('s12')
        with self.assertRaises(ValueError):va.compare_new_runs(a,a,self.production)
    def test_new_sealed_artifact_rejected(self):
        self.stable_json();a=self.successful_run('s12');b=self.successful_run('s12')
        (a/'common/s11_result/operators.wl').write_text('changed')
        with self.assertRaises(ValueError):va.compare_new_runs(a,b,self.production)
    def test_missing_new_checkpoint_blocks(self):
        self.stable_json();a=self.successful_run('s09');b=self.successful_run('s12')
        with self.assertRaises(Exception):va.compare_new_runs(a,b,self.production)

class InstallTests(WorkflowOrchestrationTests):
    def setUp(self):
        super().setUp()
        import derivation_support
        self.install_state=self.root/'derivation-state'
        self.release_fixture=self.root/'validator-identity';self.release_fixture.mkdir()
        write(self.release_fixture/'MANIFEST.json',{'fixture':True})
        self.patches=[patch.object(derivation_support,'ROOT',self.release_fixture),patch.object(install,'release_integrity',lambda p:sha(self.release_fixture/'MANIFEST.json')),patch.object(install,'check_foundation',lambda p:{'mock':True})]
        for p in self.patches:p.start();self.addCleanup(p.stop)
    def test_dry_run_no_mutation(self):
        old=snapshot(self.production);r=install.install(self.repo,self.numerical_state,self.install_state,dry_run=True)
        self.assertEqual(r['status'],'DRY_RUN_READY');self.assertEqual(snapshot(self.production),old)
    def test_additive_install_and_repeat(self):
        old=snapshot(self.production);r=install.install(self.repo,self.numerical_state,self.install_state)
        self.assertTrue(r['new_files']);self.assertEqual(install.install(self.repo,self.numerical_state,self.install_state)['status'],'ALREADY_INSTALLED')
        for name,h in old.items():self.assertEqual(sha(self.production/name),h)
    def test_no_overwrite(self):
        (self.production/'DERIVATION_CONTRACT.md').write_text('existing different user file')
        old=snapshot(self.production)
        with self.assertRaises(ValueError):install.install(self.repo,self.numerical_state,self.install_state)
        self.assertEqual(snapshot(self.production),old)
    def test_dangling_link_rejected(self):
        (self.production/'DERIVATION_CONTRACT.md').symlink_to('missing')
        with self.assertRaises(ValueError):install.install(self.repo,self.numerical_state,self.install_state)
    def test_existing_baseline_required(self):
        (self.numerical_state/'baseline.json').unlink()
        with self.assertRaises(Exception):install.install(self.repo,self.numerical_state,self.install_state)
    def test_lock_failure_before_mutation(self):
        old=snapshot(self.production)
        with patch.object(install,'check_foundation',side_effect=ValueError('changed foundation')):
            with self.assertRaises(ValueError):install.install(self.repo,self.numerical_state,self.install_state)
        self.assertEqual(snapshot(self.production),old)

class LockTests(unittest.TestCase):
    def test_real_hash_lock(self):
        with tempfile.TemporaryDirectory() as d:
            root=Path(d);p=root/'repo/collins_ep_analytic';p.mkdir(parents=True);n=root/'repo/collins_ep';n.mkdir()
            (p/'old.wl').write_text('locked analytic');(n/'old.py').write_text('locked numerics')
            write(root/'foundation_lock.json',{'reviewed_source_identity':'test','files':{'old.wl':sha(p/'old.wl')}})
            write(root/'numerical_lock.json',{'files':{'old.py':sha(n/'old.py')}})
            with patch.object(locks,'ROOT',root):
                self.assertEqual(locks.check_foundation(p)['files'],1)
                (n/'old.py').write_text('changed')
                with self.assertRaises(ValueError):locks.check_foundation(p)
                (n/'old.py').write_text('locked numerics');(p/'old.wl').write_text('changed')
                with self.assertRaises(ValueError):locks.check_foundation(p)
    def test_history_and_executable_record(self):
        with tempfile.TemporaryDirectory() as d:
            root=Path(d);p=root/'candidate';p.mkdir();h=root/'history';h.mkdir();exe=root/'polymake';exe.write_text('#!/bin/sh\nexit 0\n');exe.chmod(0o755)
            write(h/'accepted.json',{'accepted':True});write(root/'history_lock.json',{'files':{'accepted.json':sha(h/'accepted.json')}})
            write(p/'assembly_runtime.json',{'polymake':str(exe),'stage_timeout_seconds':50,'legacy_analytic_state':str(h)})
            with patch.object(locks,'ROOT',root):
                a=locks.extra_runtime(p);self.assertEqual(a['polymake']['sha256'],sha(exe))
                exe.write_text('#!/bin/sh\nexit 1\n');self.assertNotEqual(a,locks.extra_runtime(p))
                write(h/'accepted.json',{'accepted':False})
                with self.assertRaises(ValueError):locks.extra_runtime(p)

class AcceptanceOrchestrationTests(unittest.TestCase):
    """Mock all physics execution and legacy acceptance; exercise new orchestration."""
    def setUp(self):
        self.temp=tempfile.TemporaryDirectory();self.addCleanup(self.temp.cleanup);self.root=Path(self.temp.name)
        self.repo=self.root/'repo';self.production=self.repo/'collins_ep_analytic';self.production.mkdir(parents=True)
        (self.repo/'collins_ep').mkdir();(self.repo/'collins_ep/old.py').write_text('# protected')
        (self.production/'numerics').mkdir();(self.production/'numerics/evaluate_assembly.py').write_text('# MOCKED bridge')
        self.state=self.root/'state';self.state.mkdir();write(self.state/'old-report.json',{'old':True})
        self.run=self.root/'run';self.run.mkdir();write(self.run/'run.json',{'mock':True})
        for sid in ('s10','s11','s12'):(self.run/'common'/f'{sid}_result').mkdir(parents=True)
        r,o,a,_=references();write(self.run/'common/s10_result/radiation.json',packet('radiation',r));write(self.run/'common/s11_result/operators.json',packet('operators',o));write(self.run/'common/s12_result/assembly.json',packet('assembly',{'expressions':a}))
        self.rt={'wolfram_kernel':'/MOCKED/WolframKernel','wolfram_init':None,'stage_timeout_seconds':30}
        self.manifest={'run_id':'mock-fresh','source_sha256':snapshot(self.production),'runtime':{'config':self.rt},'status':'STAGES_PASS','baseline_after':{'hash':'same'}}
        self.args=argparse.Namespace(repo=str(self.repo),run=str(self.run),replay=str(self.root/'run2'),profile='assembly',seed=1729,report=str(self.root/'acceptance.json'),numerical_state=str(self.state),numerical_validator='/MOCKED/legacy',numerical_timeout=10,timeout=10)
        self.mode=None
        self.patch(va,'release_integrity',lambda p:'MOCKED release');self.patch(va,'baseline_check',lambda *x:{'hash':'same'})
        self.patch(va,'audit_run',self.audit);self.patch(va,'compare_new_runs',lambda *x:{'id':'assembly.clean_replay','status':'PASS'})
        self.patch(va,'backend_evidence',lambda *x:{'id':'assembly.backend_records','status':'PASS'})
        self.patch(va,'producer_map',lambda *x:{'id':'assembly.producer_map','status':'PASS'})
        self.patch(va,'execute',self.execute);self.patch(va.foundation,'verify',self.legacy)
        self.patch(va.bridge_probes,'run',lambda *x:[{'id':'probe.mocked','status':'PASS'}])
    def patch(self,obj,name,value):
        p=patch.object(obj,name,value);p.start();self.addCleanup(p.stop)
    def audit(self,*args):
        if snapshot(self.production)!=self.manifest['source_sha256']:raise ValueError('source mutated')
        return self.manifest,{s['id']:{} for s in va.stage_list()}
    def legacy(self,args):
        self.foundation_profile=args.profile
        status='BLOCKED' if self.mode=='legacy_blocked' else ('FAIL' if self.mode=='legacy_fail' else 'CHECKS_PASS')
        write(args.report,{'status':status,'checks':[{'id':'legacy_mock_only','status':'PASS'}]})
        return {'BLOCKED':2,'FAIL':1,'CHECKS_PASS':0}[status]
    def execute(self,cmd,cwd,log,timeout,env=None):
        Path(log).parent.mkdir(parents=True,exist_ok=True);Path(log).write_text('MOCKED process output')
        if env:
            c=read(env['COLLINS_ANALYTIC_CONTEXT'])
            if 'proof_ids' in c:
                write(c['proof_report'],{'run_id':c['run_id'],'stage':c['stage'],'status':'PASS','proof_ids':c['proof_ids']})
            else:
                out={'run_id':c['run_id'],'status':'PASS','responses':[{'id':r['id'],'values':expected(r)} for r in c['requests']]}
                if self.mode=='stale_nonce':out['run_id']='stale'
                if self.mode=='missing_row':out['responses'].pop()
                write(c['response'],out)
        else:
            c=read(cmd[-1]);out={'run_id':c['run_id'],'status':'PASS','responses':[{'id':r['id'],'values':expected(r)} for r in c['requests']]}
            if self.mode=='bad_bridge':out['responses'][0]['values']['value']+=1
            write(log,out)
        if self.mode=='source_mutation':(self.production/'changed.py').write_text('bad')
        return {'exit_code':0,'argv':cmd,'log_sha256':sha(log)}
    def run_check(self):
        with contextlib.redirect_stdout(io.StringIO()):return va.verify(self.args)
    def test_mock_success(self):
        self.assertEqual(self.run_check(),0);self.assertEqual(self.foundation_profile,'foundation')
    def test_analytic_assembly_requests_fresh_analytic_foundation(self):
        self.args.profile='analytic_assembly'
        self.assertEqual(self.run_check(),0);self.assertEqual(self.foundation_profile,'analytic_foundation')
        self.assertEqual(read(self.args.report)['numerical_regression'],'NOT_REQUESTED_ANALYTICAL_ONLY')
    def test_stale_nonce(self):self.mode='stale_nonce';self.assertEqual(self.run_check(),1)
    def test_missing_response(self):self.mode='missing_row';self.assertEqual(self.run_check(),1)
    def test_bad_bridge(self):self.mode='bad_bridge';self.assertEqual(self.run_check(),1)
    def test_legacy_blocked(self):self.mode='legacy_blocked';self.assertEqual(self.run_check(),2)
    def test_legacy_fail(self):self.mode='legacy_fail';self.assertEqual(self.run_check(),1)
    def test_changed_source(self):self.mode='source_mutation';self.assertEqual(self.run_check(),1)
    def test_missing_replay(self):self.args.replay=None;self.assertEqual(self.run_check(),2)
    def test_paper_blocked(self):self.args.profile='paper';self.assertEqual(self.run_check(),2)
    def test_nlo_blocked(self):self.args.profile='nlo';self.assertEqual(self.run_check(),2)
    def test_existing_report_not_overwritten(self):
        write(self.args.report,{'keep':True})
        with self.assertRaises(ValueError):self.run_check()
        self.assertEqual(read(self.args.report),{'keep':True})
    def test_report_in_source_rejected(self):
        self.args.report=str(self.production/'report.json')
        with self.assertRaises(ValueError):self.run_check()
    def test_bad_polynomial(self):
        p=self.run/'common/s12_result/assembly.json';data=read(p);data['expressions']['UU1']={'op':'rat','num':0,'den':1};write(p,data)
        self.assertEqual(self.run_check(),1)

def load_tests(loader,tests,pattern):
    # Reuse setup/helpers without rerunning inherited ten-stage tests three times.
    suite=unittest.TestSuite()
    for cls in (NewStageWorkflowTests,InstallTests,LockTests,AcceptanceOrchestrationTests):
        for name in sorted(cls.__dict__):
            if name.startswith('test_'):suite.addTest(cls(name))
    return suite

if __name__=='__main__':unittest.main()
