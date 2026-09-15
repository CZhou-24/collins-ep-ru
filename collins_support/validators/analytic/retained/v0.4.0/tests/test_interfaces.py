import argparse,copy,json,sys,tempfile,unittest,contextlib,io
from pathlib import Path
from unittest.mock import patch
import nlo_support as n,workflow,install
from verify_nlo import guard,audit_saved_stage

class InstallationTests(unittest.TestCase):
    def setUp(self):
        self.tmp=tempfile.TemporaryDirectory();self.root=Path(self.tmp.name)
        self.rel=self.root/'release';self.rel.mkdir();(self.rel/'candidate_api').mkdir();(self.rel/'candidate_api/nlo_io.wl').write_text('transport fixture')
        self.repo=self.root/'repo';self.prod=self.repo/'collins_ep_analytic';self.prod.mkdir(parents=True);(self.prod/'accepted.wl').write_text('accepted fixture')
        self.frozen={'accepted.wl':n.sha(self.prod/'accepted.wl')}
        n.write(self.rel/'accepted_sources.json',{'files':self.frozen});n.write(self.rel/'retained_identity.json',{'manifest_sha256':'retained-manifest'})
        self.old=self.root/'old-state';self.old.mkdir();refs=[]
        for seed in (1729,92741):
            p=self.old/('derivation-'+str(seed)+'.json')
            n.write(p,{'seed':seed,'status':'CHECKS_PASS','profile':'derivation','sources':self.frozen,'validator_manifest_sha256':'retained-manifest',
              'checks':[{'id':'fixture-'+str(i),'status':'PASS'} for i in range(1337)]})
            refs.append({'path':str(p),'sha256':n.sha(p)})
        n.write(self.old/'derivation-pair.json',{'status':'CHECKS_PASS','profile':'derivation','seeds':[1729,92741],
            'validator_manifest_sha256':'retained-manifest','reports':refs})
        self.args=argparse.Namespace(repo=str(self.repo),state=str(self.root/'new-state'),accepted_state=str(self.old),dry_run=True)
        self.patches=[patch.object(n,'ROOT',self.rel),patch.object(install,'ROOT',self.rel),patch.object(install,'release_integrity',lambda:'v040-manifest')]
        for p in self.patches:p.start()
        self.capture=contextlib.redirect_stdout(io.StringIO());self.capture.__enter__()
    def tearDown(self):
        self.capture.__exit__(None,None,None)
        for p in reversed(self.patches):p.stop()
        self.tmp.cleanup()
    def test_dry_run_and_additive_install(self):
        before=(self.prod/'accepted.wl').read_bytes();self.assertEqual(install.install(self.args),0)
        self.assertFalse((self.prod/'common').exists());self.assertFalse(Path(self.args.state).exists())
        self.args.dry_run=False;self.assertEqual(install.install(self.args),0)
        self.assertEqual((self.prod/'accepted.wl').read_bytes(),before)
        self.assertTrue((self.prod/'common/nlo_io.wl').is_file());self.assertTrue((self.prod/'nlo_runtime.example.json').is_file())
        self.assertFalse((self.prod/'nlo_runtime.json').exists());self.assertFalse((self.prod/'common/d17_nlo.wls').exists())
        with self.assertRaises(ValueError):install.install(self.args)
    def test_preflight_no_partial_overwrite(self):
        (self.prod/'nlo_runtime.example.json').write_text('existing user config');self.args.dry_run=False
        with self.assertRaises(ValueError):install.install(self.args)
        self.assertFalse((self.prod/'common/nlo_io.wl').exists())
    def test_changed_accepted_source_blocks(self):
        (self.prod/'accepted.wl').write_text('changed')
        with self.assertRaises(ValueError):install.install(self.args)
    def test_wrong_accepted_pair_blocks(self):
        p=self.old/'derivation-pair.json';r=n.read(p);r['status']='FAIL';n.write(p,r)
        with self.assertRaises(n.Blocked):install.install(self.args)
    def test_accepted_report_tamper_blocks(self):
        p=self.old/'derivation-1729.json';r=n.read(p);r['checks'].pop();n.write(p,r)
        with self.assertRaises(ValueError):install.install(self.args)
    def test_report_guard_includes_retained_runs(self):
        run=self.root/'nlo-run';run.mkdir();base=self.root/'base-run';base.mkdir();n.write(run/'run.json',{'base_run':str(base)})
        with self.assertRaises(ValueError):guard(self.repo,base/'bad.json',run,run)

class NativeBoundaryTests(unittest.TestCase):
    def setUp(self):
        self.tmp=tempfile.TemporaryDirectory();self.root=Path(self.tmp.name)
        self.prod=self.root/'prod';(self.prod/'common').mkdir(parents=True)
        (self.prod/'common/d16_nlo.wls').write_text('MOCK NATIVE BOUNDARY; NOT A DERIVATION')
        self.base=self.root/'base/d15_result';self.base.mkdir(parents=True)
        n.write(self.base/'context.json',{'runtime':{'kira':'mock-kira'},'extension_runtime':{},'derivation_runtime':{}})
        self.rt={'wolfram_kernel':sys.executable,'config':{'stage_timeout_seconds':30,'probe_timeout_seconds':30}}
        self.st={'id':'d16','script':'common/d16_nlo.wls','roles':['definitions'],
                 'artifacts':['packet.json','packet.wl','provenance.json']}
    def tearDown(self):self.tmp.cleanup()
    def fake_execution(self,command,cwd,log,timeout,env):
        ctx=n.read(env['COLLINS_NLO_CONTEXT']);legacy=n.read(env['COLLINS_ANALYTIC_CONTEXT'])
        self.assertEqual(legacy['runtime']['kira'],'mock-kira');self.assertTrue(ctx['no_cache'])
        out=Path(ctx['output']);n.write(out/'packet.json',{'schema':1,'stage':'d16','data':{'fixture':1}});(out/'packet.wl').write_text('MOCK PACKET')
        (out/'raw.wl').write_text('MOCK OPERATOR')
        nodes=[{'id':'source','role':'source','parents':[],'file':{'root':'production','path':'common/d16_nlo.wls','sha256':n.sha(self.prod/'common/d16_nlo.wls')},'explanation':'Software transport source fixture only.'},
          {'id':'output','role':'definitions','parents':['source'],'file':{'root':'output','path':'raw.wl','sha256':n.sha(out/'raw.wl')},'explanation':'Software transport output fixture only.'}]
        n.write(out/'provenance.json',{'schema':1,'stage':'d16','nodes':nodes,'exports':['output']})
        Path(log).write_text('MOCK EXECUTION ONLY');return {'exit_code':0,'log_sha256':n.sha(log)}
    def fake_reexport(self,out,work,rt):
        work.mkdir();(work/'execution.log').write_text('MOCK REEXPORT ONLY');n.write(work/'packet.json',n.read(out/'packet.json'))
        return {'exit_code':0,'log_sha256':n.sha(work/'execution.log')}
    def test_native_boundary_and_sealed_artifact_tamper(self):
        out=self.root/'out';inputs={'d15':self.base}
        with patch.object(workflow,'execute',self.fake_execution),patch.object(workflow,'reexport',self.fake_reexport):
            receipt=workflow.stage_execute(self.st,self.prod,out,inputs,'mock-run',self.rt)
        n.write(self.root/'receipt.json',receipt)
        audit_saved_stage(self.st,out,self.root/'receipt.json',self.prod,inputs)
        (out/'raw.wl').write_text('TAMPERED')
        with self.assertRaises(ValueError):audit_saved_stage(self.st,out,self.root/'receipt.json',self.prod,inputs)
    def test_native_exit_two_blocks(self):
        with patch.object(workflow,'execute',lambda *args,**kwargs:{'exit_code':2}):
            with self.assertRaises(n.Blocked):workflow.stage_execute(self.st,self.prod,self.root/'out',{'d15':self.base},'run',self.rt)
    def test_native_exit_one_fails(self):
        with patch.object(workflow,'execute',lambda *args,**kwargs:{'exit_code':1}):
            with self.assertRaises(RuntimeError):workflow.stage_execute(self.st,self.prod,self.root/'out',{'d15':self.base},'run',self.rt)
