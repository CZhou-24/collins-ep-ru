"""Checker failure probes; fixture data and mocked native execution are not physics."""
import copy,tempfile,unittest
from pathlib import Path
from unittest.mock import patch
import conventions as cv,verify_derivation as vd
from support import read,write,sha
from test_assembly_workflow import NewStageWorkflowTests

class StatusTests(unittest.TestCase):
    def test_no_vacuous_success(self):self.assertEqual(vd.combine_status([]),'FAIL')
    def test_missing_native_is_blocked(self):self.assertEqual(vd.combine_status([{'id':'mg','status':'BLOCKED'}]),'BLOCKED')
    def test_failure_overrides_blocker(self):self.assertEqual(vd.combine_status([{'id':'x','status':'FAIL'},{'id':'mg','status':'BLOCKED'}]),'FAIL')
    def test_duplicate_check_rejected(self):self.assertEqual(vd.combine_status([{'id':'x','status':'PASS'}]*2),'FAIL')
    def test_unknown_state_rejected(self):self.assertEqual(vd.combine_status([{'id':'x','status':'SKIP'}]),'FAIL')

class ConventionTests(unittest.TestCase):
    def setUp(self):
        self.temp=tempfile.TemporaryDirectory();self.addCleanup(self.temp.cleanup);self.run=Path(self.temp.name)
        lock=read(cv.ROOT/'sidis_convention_lock.json');self.path=self.run/'common/d14_result/conventions.json'
        evidence={}
        for name in cv.LINKS:
            p=self.run/name;p.parent.mkdir(parents=True,exist_ok=True);p.write_text('MOCKED convention evidence; no native physics\n');evidence[name]=sha(p)
        self.packet={'schema':1,'baseline_commit':lock['commit'],'baseline_files':{k:v['sha256'] for k,v in lock['files'].items()},'rows':[
            {'id':k,'status':'EXPLICIT_EXTENSION' if v=='EXPLICIT_EXTENSION' else 'INHERITED','baseline_definition':'fixture baseline','production_definition':'fixture production','reference_definition':'fixture reference','note':'MOCKED evidence only','evidence':dict(evidence)} for k,v in lock['rows'].items()]}
    def check(self):write(self.path,self.packet);return cv.check_conventions(self.run)
    def test_positive_metadata_fixture(self):self.assertTrue(all(c['status']=='PASS' for c in self.check()))
    def test_wrong_commit(self):
        self.packet['baseline_commit']='0'*40
        with self.assertRaises(ValueError):self.check()
    def test_missing_obligation(self):
        self.packet['rows'].pop()
        with self.assertRaises(ValueError):self.check()
    def test_unsupported_inheritance(self):
        self.packet['rows'][-1]['status']='INHERITED'
        with self.assertRaises(ValueError):self.check()
    def test_unresolved_blocks(self):
        self.packet['rows'][-1]['status']='UNRESOLVED'
        self.assertTrue(any(c['status']=='BLOCKED' for c in self.check()))
    def test_changed_evidence(self):
        (self.run/next(iter(cv.LINKS))).write_text('changed')
        with self.assertRaises(ValueError):self.check()
    def test_no_reference_native_link(self):
        for row in self.packet['rows']:row['evidence'].pop('common/d13_result/native_matching.wl')
        with self.assertRaises(ValueError):self.check()
    def test_duplicate_row(self):
        self.packet['rows'].append(copy.deepcopy(self.packet['rows'][0]))
        with self.assertRaises(ValueError):self.check()

class DerivationStages(NewStageWorkflowTests):
    def setUp(self):
        super().setUp()
        original=self.fake_runtime_record
        self.start_patch('runtime_record',lambda p:{**original(p),'extension':{'stage_timeout_seconds':30},'derivation':{'config':{'stage_timeout_seconds':30}}})
    def test_all_new_stages_fresh(self):
        self.stable_json();a=self.successful_run('d15');b=self.successful_run('d15')
        self.assertEqual(vd.compare_runs(a,b,self.production)['status'],'PASS')
    def test_derivation_stub_blocks(self):
        self.stage_exit['d13']=2;rc,_=self.run_workflow(through='d15');self.assertEqual(rc,2)
    def test_missing_native_matching_rejected(self):
        self.omit_artifact['d13']='native_matching.wl';rc,_=self.run_workflow(through='d15');self.assertEqual(rc,1)
    def test_repeated_derivation_run_rejected(self):
        self.stable_json();a=self.successful_run('d15')
        with self.assertRaises(ValueError):vd.compare_runs(a,a,self.production)
    def test_changed_convention_artifact(self):
        self.stable_json();a=self.successful_run('d15');b=self.successful_run('d15')
        (a/'common/d14_result/conventions.json').write_text('{}')
        with self.assertRaises(ValueError):vd.compare_runs(a,b,self.production)

def load_tests(loader,tests,pattern):
    suite=unittest.TestSuite()
    for cls in (StatusTests,ConventionTests,DerivationStages):
        for name in sorted(cls.__dict__):
            if name.startswith('test_'):suite.addTest(cls(name))
    return suite
if __name__=='__main__':unittest.main()
