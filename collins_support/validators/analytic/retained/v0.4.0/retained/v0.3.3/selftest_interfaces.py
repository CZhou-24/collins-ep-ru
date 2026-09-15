"""Reference-interface and replay-policy tests; no loop derivation performed."""
import copy,math,unittest
from pathlib import Path
from unittest.mock import patch
import soft_oracle as soft
import verify

class InterfaceTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.requests=soft.requests(1729)
        cls.payload={'run_id':'test','status':'PASS','responses':[{'id':r['id'],'values':soft.expected(r)} for r in cls.requests]}

    def test_gauss_legendre_polynomials(self):
        for n in range(15):self.assertAlmostEqual(soft.integrate(lambda x:x**n,-1,1,n=12),0 if n%2 else 2/(n+1),places=12)

    def test_soft_against_independent_angular_primitive(self):
        # Analytically integrate phi; use an independent 1D quadrature expression.
        R,Y,lo,hi=.9,2.1,.3,1.4
        def inner(theta):
            u=R*math.sin(theta);v=R*math.cos(theta)
            return 8/math.tanh(u)*math.atan(math.tanh(u/2)/math.tan(v/2))*R*math.cos(theta)
        exact_phi=soft.integrate(inner,0,math.pi/2,n=80)+4*math.pi*math.log(math.sinh(Y)/math.sinh(R))
        self.assertAlmostEqual(soft.soft_slice(R,Y,lo,hi,n=56),math.log(hi/lo)*exact_phi,places=9)

    def test_radial_scaling(self):
        self.assertAlmostEqual(soft.soft_slice(.8,2,.2,1),soft.soft_slice(.8,2,.4,2),places=12)

    def test_radius_monotonicity(self):self.assertGreater(soft.soft_slice(.6,2,.2,1),soft.soft_slice(1.1,2,.2,1))
    def test_invalid_domain(self):
        for args in [(0,2,.2,1),(2,2,.2,1),(.8,2,1,.2)]:
            with self.assertRaises(ValueError):soft.soft_slice(*args)
    def test_seed_determinism(self):self.assertEqual(self.requests,soft.requests(1729));self.assertNotEqual(self.requests,soft.requests(92741))
    def test_valid_synthetic_response(self):self.assertTrue(all(x['status']=='PASS' for x in soft.compare_response(self.requests,self.payload,'test')))
    def test_upstream_sign_mutant(self):
        p=copy.deepcopy(self.payload);p['responses'][0]['values']['upstream_H_UT']*=-1
        self.assertTrue(any(x['status']=='FAIL' for x in soft.compare_response(self.requests,p,'test')))
    def test_soft_factor_two_mutant(self):
        p=copy.deepcopy(self.payload);next(r for r in p['responses'] if r['id'].startswith('soft.slice'))['values']['slice']*=2
        self.assertTrue(any(x['status']=='FAIL' for x in soft.compare_response(self.requests,p,'test')))
    def test_stale_nonce(self):
        with self.assertRaises(ValueError):soft.compare_response(self.requests,self.payload,'another')
    def test_duplicate_response(self):
        p=copy.deepcopy(self.payload);p['responses'].append(p['responses'][0])
        with self.assertRaises(ValueError):soft.compare_response(self.requests,p,'test')
    def test_missing_response(self):
        p=copy.deepcopy(self.payload);p['responses'].pop()
        with self.assertRaises(ValueError):soft.compare_response(self.requests,p,'test')
    def test_bool_response(self):
        p=copy.deepcopy(self.payload);p['responses'][0]['values']['H_UU']=True
        with self.assertRaises(ValueError):soft.compare_response(self.requests,p,'test')
    def test_nan_response(self):
        p=copy.deepcopy(self.payload);p['responses'][0]['values']['H_UU']=float('nan')
        with self.assertRaises(ValueError):soft.compare_response(self.requests,p,'test')

class ReplayPolicyTests(unittest.TestCase):
    def setUp(self):
        self.a={'run_id':'A','status':'STAGES_PASS','baseline_before':{},'baseline_after':{},'resumed':False,'source_sha256':{},'runtime':{}}
        self.b=dict(self.a,run_id='B');self.done={s['id']:{'no_cache_requested':True} for s in verify.stage_list()}
    def compare(self):
        with patch.object(verify,'audit_run',side_effect=[(self.a,self.done),(self.b,self.done)]),patch.object(verify,'SEMANTIC',{}):
            return verify.compare_runs('/MOCK/A','/MOCK/B','/MOCK/production')
    def test_fresh_policy(self):self.assertEqual(self.compare()['status'],'PASS')
    def test_replay_failed_final_gate(self):
        self.b['status']='FAIL'
        with self.assertRaises(ValueError):self.compare()
    def test_replay_changed_final_baseline(self):
        self.b['baseline_after']={'changed':True}
        with self.assertRaises(ValueError):self.compare()
    def test_replay_resumed(self):
        self.b['resumed']=True
        with self.assertRaises(ValueError):self.compare()
    def test_cache_enabled_stage(self):
        self.done['s06']['no_cache_requested']=False
        with self.assertRaises(ValueError):self.compare()
    def test_same_run_id(self):
        self.b['run_id']='A'
        with self.assertRaises(ValueError):self.compare()
    def test_missing_stage(self):
        self.done.pop('s08')
        with self.assertRaises(ValueError):self.compare()
    def test_changed_sources(self):
        self.b['source_sha256']={'changed':'file'}
        with self.assertRaises(ValueError):self.compare()

if __name__=='__main__':unittest.main()
