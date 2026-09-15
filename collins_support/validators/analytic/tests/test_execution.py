import copy,json,sys,tempfile,unittest,io
from contextlib import redirect_stdout
from pathlib import Path
from unittest.mock import patch
sys.path.insert(0,str(Path(__file__).resolve().parents[1]))
import algebra as a
import ru_support as u
import workflow as w
import verify_ru as v
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

if __name__=='__main__':unittest.main()
