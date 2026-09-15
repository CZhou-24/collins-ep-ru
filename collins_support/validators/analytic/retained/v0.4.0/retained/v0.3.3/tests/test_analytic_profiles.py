"""Analytic-only profile policy using real retained checks and mocked backends."""
import json, os, subprocess, sys, tempfile, unittest
from pathlib import Path
from unittest.mock import patch
import verify, verify_assembly
from support import write
from retained_fixture import populate_run, foundation_report

class AnalyticalProfileTests(unittest.TestCase):
    def setUp(self):
        self.temp=tempfile.TemporaryDirectory();self.addCleanup(self.temp.cleanup);self.root=Path(self.temp.name)
        self.repo=self.root/'repo';self.run=self.root/'a';self.replay=self.root/'b'
        self.manifest={'run_id':'MOCKED first','source_sha256':{'MOCKED':'source'},'runtime':{'config':{'wolfram_kernel':'/MOCKED/WolframKernel','stage_timeout_seconds':20}},
            'baseline_before':{'MOCKED':'baseline'},'baseline_after':{'MOCKED':'baseline'},'status':'STAGES_PASS','resumed':False}
        for run in (self.run,self.replay):
            populate_run(run);write(run/'run.json',self.manifest)
    def report(self,profile='analytic_foundation',**kwargs):
        return foundation_report(self.repo,self.run,self.replay,self.root/'state',self.root/'report.json',1729,profile,self.manifest,legacy_mode='raise',**kwargs)
    def test_analytic_omits_legacy_keeps_all_retained_checks(self):
        rc,r,executions,legacy=self.report()
        self.assertEqual(rc,0,r);self.assertEqual(len(r['checks']),303);self.assertFalse(legacy)
        self.assertEqual(r['numerical_regression'],'NOT_REQUESTED_ANALYTICAL_ONLY')
        self.assertIn('replay.semantic_outputs',{c['id'] for c in r['checks']})
        self.assertGreaterEqual(sum('/MOCKED/WolframKernel' in c for c in executions),9)
        self.assertFalse(any('validation_adapter.py' in str(c) for c in executions))
    def test_historical_profile_still_calls_legacy(self):
        rc,r,_,legacy=self.report('foundation')
        self.assertEqual(rc,1);self.assertEqual(legacy,[1729]);self.assertIn('legacy sentinel',r['detail'])
    def test_missing_replay_still_blocks(self):
        self.replay=None;rc,r,_,legacy=self.report()
        self.assertEqual(rc,2);self.assertFalse(legacy);self.assertIn('--replay',r['detail'])
    def test_duplicate_fresh_proof_fails(self):
        rc,r,_,_=self.report(execution_mutation='duplicate_proof')
        self.assertEqual(rc,1);self.assertIn('identity replay failed',r['detail'])
    def test_missing_analytic_response_fails(self):
        rc,r,_,_=self.report(execution_mutation='missing_response')
        self.assertEqual(rc,1);self.assertIn('response IDs',r['detail'])
    def test_filters_are_exact_but_full_audit_is_called(self):
        entries=[{'id':f's{i:02}'} for i in range(13)]+[{'id':'d13'},{'id':'x01'},{'id':'s1'}]
        for module,count in [(verify,10),(verify_assembly,13)]:
            with patch.object(module,'stages_all',return_value=entries),patch.object(module,'audit_all',return_value=({},dict.fromkeys(x['id'] for x in entries))) as audit:
                self.assertEqual(len(module.stage_list()),count)
                self.assertEqual(set(module.audit_run('run','production')[1]),{f's{i:02}' for i in range(count)})
                audit.assert_called_once_with('run','production')
    def test_all_requests_deterministic_across_python_hash_seeds(self):
        root=Path(verify.__file__).resolve().parent
        script='import json; from assembly_oracle import requests; print(json.dumps([requests(1729),requests(92741)],sort_keys=True,separators=(",",":")))'
        outputs=[]
        for seed in ('0','1','739','random'):
            p=subprocess.run([sys.executable,'-c',script],cwd=root,env={**os.environ,'PYTHONHASHSEED':seed},capture_output=True,check=True)
            outputs.append(p.stdout)
        self.assertTrue(all(payload==outputs[0] for payload in outputs))

if __name__=='__main__':unittest.main()
