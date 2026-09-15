import copy,json,sys,tempfile,unittest,io
from contextlib import redirect_stdout
from pathlib import Path
from unittest.mock import patch
sys.path.insert(0,str(Path(__file__).resolve().parents[1]))
import algebra as a
import ru_support as u
import workflow as w
import verify_ru as v
import install as installer
from test_validator import value

def probe_data(master=2,factor=3):
    key='master/r02/A/M';recipes={'r03/I':value(0,[(key,factor)],master*factor),'r07/C':value(1,[('r03/I',1)],1+master*factor)}
    masters={key:a.decode(master)};vals=a.recompute(recipes,masters)
    return {'masters':masters,'recipes':recipes,'values':vals,'exports':{'C':{'value':'r07/C','evidence':'r07/assembly'}},'packets':{'r03':{'integrated_values':['r03/I']}}}

class ActualResponse(unittest.TestCase):
    def test_master_response(self):
        b=probe_data();c=probe_data(master=4)
        self.assertEqual(v.check_probe('real_master',b,c,'master/r02/A/M',a.decode(2)),['C'])
    def test_cached_final_rejected(self):
        b=probe_data();c=probe_data(master=4);c['values']['r07/C']=b['values']['r07/C']
        with self.assertRaises(ValueError):v.check_probe('real_master',b,c,'master/r02/A/M',a.decode(2))
    def test_ignored_master_rejected(self):
        b=probe_data()
        with self.assertRaises(ValueError):v.check_probe('real_master',b,b,'master/r02/A/M',a.decode(2))
    def test_kira_response(self):
        b=probe_data();c=probe_data(factor=6)
        self.assertEqual(v.check_probe('kira_real_rules',b,c,None,a.decode(2)),['C'])
    def test_fake_direct_shift_rejected(self):
        b=probe_data();c=probe_data(master=4);c['recipes']['r07/C']['constant']=7
        with self.assertRaises(ValueError):v.check_probe('real_master',b,c,'master/r02/A/M',a.decode(2))
    def test_unlisted_integrated_value(self):
        b=probe_data();b['packets']['r03']['integrated_values']=[]
        with self.assertRaises(ValueError):v.check_probe('kira_real_rules',b,probe_data(factor=6),None,a.decode(2))
    def test_unresponsive_selection(self):
        b=probe_data(factor=0)
        with self.assertRaises(ValueError):v.choose_master(b,'r02',1729)

class JobFailures(unittest.TestCase):
    def setUp(self):
        self.tmp=tempfile.TemporaryDirectory();self.root=Path(self.tmp.name);self.out=self.root/'stage';self.work=self.out/'jobs/test';self.work.mkdir(parents=True)
        self.job={'id':'test','inputs':['euler_inputs.wl'],'outputs':['masters.wl','raw_results.wl','subtropica_execution.json'],'families':['R1'],'sectors':['beam_fqq']}
        (self.work/'euler_inputs.wl').write_text('unevaluated input')
        self.rt={'config':{'wolfram_kernel':'/dummy/kernel','fermat':'/dummy/fermat','subtropica_root':'/dummy/ST','timeout_seconds':1}}
        self.stage={'id':'r02','tool':'subtropica'}
    def tearDown(self):self.tmp.cleanup()
    def test_precomputed_master_refused(self):
        (self.work/'masters.wl').write_text('a supplied answer')
        with self.assertRaises(ValueError):w.job_execute(self.stage,self.job,self.out,self.rt,{})
    def test_noop_tool_cannot_pass(self):
        with patch.object(w,'execute',return_value={'exit_code':0}):
            with self.assertRaises(u.Blocked):w.job_execute(self.stage,self.job,self.out,self.rt,{})
    def test_nonzero_tool_exit(self):
        with patch.object(w,'execute',return_value={'exit_code':4}):
            with self.assertRaises(u.Blocked):w.job_execute(self.stage,self.job,self.out,self.rt,{})
    def test_changed_tool_input(self):
        def run(*args,**kwargs):(self.work/'euler_inputs.wl').write_text('changed');return {'exit_code':0}
        with patch.object(w,'execute',side_effect=run):
            with self.assertRaises(ValueError):w.job_execute(self.stage,self.job,self.out,self.rt,{})
    def test_output_path_escape(self):
        self.job['outputs'].append('../../../../../elsewhere')
        with self.assertRaises(ValueError):w.job_execute(self.stage,self.job,self.out,self.rt,{})
    def test_duplicate_input_output(self):
        self.job['outputs'].append('euler_inputs.wl')
        with self.assertRaises(ValueError):w.job_execute(self.stage,self.job,self.out,self.rt,{})

class Installation(unittest.TestCase):
    def setUp(self):
        self.tmp=tempfile.TemporaryDirectory();self.root=Path(self.tmp.name);self.repo=self.root/'repo';self.old=self.repo/u.OLD_ENGINE;self.old.mkdir(parents=True)
        u.write(self.old/'runtime.json',{});(self.old/'physics.wl').write_text('old accepted source')
        self.args=type('Args',(),{'repo':str(self.repo),'state':str(self.root/'newstate'),'accepted_pair':str(self.root/'oldstate/pair.json'),'dry_run':False})()
    def tearDown(self):self.tmp.cleanup()
    def invoke(self):
        with redirect_stdout(io.StringIO()),patch.object(installer,'release_integrity',return_value='fixture'),patch.object(installer,'accepted_pair',return_value={'fixture':True}),patch.object(installer,'preserve_old',return_value='fixture'):
            return installer.install(self.args)
    def test_additive_install_footprint(self):
        before=u.snapshot(self.old);self.assertEqual(self.invoke(),0);self.assertEqual(before,u.snapshot(self.old))
        made=u.snapshot(self.repo/u.ENGINE)
        self.assertEqual(set(made),{'common/ru_io.wl','ru_runtime.example.json'})
    def test_no_physics_stubs(self):
        self.invoke();self.assertFalse(any((self.repo/u.ENGINE).glob('common/r0*.wls')))
    def test_dry_run_writes_nothing(self):
        self.args.dry_run=True;before=u.snapshot(self.root);self.invoke();self.assertEqual(before,u.snapshot(self.root))
    def test_reinstall_refused(self):
        self.invoke()
        with self.assertRaises(ValueError):self.invoke()

class AcceptedIdentity(unittest.TestCase):
    def setUp(self):
        self.tmp=tempfile.TemporaryDirectory();self.root=Path(self.tmp.name);self.pin=u.read(u.ROOT/'accepted_v040.json');self.paths=[]
        for seed in (1729,92741):
            p=self.root/('nlo-'+str(seed)+'.json')
            u.write(p,{'schema':4,'profile':'leading_power_nlo_extension','status':'CHECKS_PASS','seed':seed,'release_sha256':self.pin['validator_manifest_sha256'],'sources':self.pin['sources'],'qualifications':self.pin['qualifications'],'checks':[{'id':str(i),'status':'PASS'} for i in range(self.pin['check_count'])]});self.paths.append(p)
        self.pair=self.root/'pair.json';self.refresh()
    def tearDown(self):self.tmp.cleanup()
    def refresh(self):
        u.write(self.pair,{'schema':4,'profile':'leading_power_nlo_extension','status':'CHECKS_PASS','seeds':[1729,92741],'release_sha256':self.pin['validator_manifest_sha256'],'qualifications':self.pin['qualifications'],'reports':[{'path':str(p),'sha256':u.digest(p)} for p in self.paths]},replace=True)
    def gate(self):
        with patch.object(u,'preserve_old',return_value='fixture-source-check'):
            return u.accepted_pair(self.root,self.pair)
    def alter(self,key,value):
        r=u.read(self.paths[0]);r[key]=value;u.write(self.paths[0],r,replace=True);self.refresh()
    def test_correct_report_identity(self):self.assertEqual(len(self.gate()['reports']),2)
    def test_wrong_source_snapshot(self):
        self.alter('sources',{})
        with self.assertRaises(ValueError):self.gate()
    def test_wrong_profile(self):
        self.alter('profile','different')
        with self.assertRaises(ValueError):self.gate()
    def test_missing_check(self):
        self.alter('checks',[{'id':'x','status':'PASS'}])
        with self.assertRaises(ValueError):self.gate()
    def test_wrong_seed_pair(self):
        self.alter('seed',92741)
        with self.assertRaises(ValueError):self.gate()
    def test_changed_report_hash(self):
        with self.paths[0].open('a') as f:f.write(' ')
        with self.assertRaises(ValueError):self.gate()

if __name__=='__main__':unittest.main()
