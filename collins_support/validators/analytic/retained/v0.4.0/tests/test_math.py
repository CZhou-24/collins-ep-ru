import copy,unittest
import sympy as s
from symbolic import *
from nlo_support import status,canonical_hash
import nlo_checks as c,oracles
from tests.fixtures import fixtures,perturbed,make_assembly

class MathTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):cls.ps,cls.base=fixtures()
    def test_fixture_consistency_only(self):
        rows=c.check_all(self.ps,self.base)
        self.assertEqual(status(rows),'CHECKS_PASS',[r for r in rows if r['status']!='PASS'])
    def test_literal_references_not_silently_equal(self):
        self.assertFalse(zero(oracles.kang_B()-oracles.yuan_minus_AF()))
        rows=c.d17_checks(self.ps['d17'],self.base)
        r=next(x for x in rows if x['id']=='d17.reference.record.Yuan2009_minus_AF')
        self.assertEqual(r['agreement'],'DISCREPANCY')
    def test_paper_alternative_explicit(self):
        ps=copy.deepcopy(self.ps);p=ps['d17']['data'];K=oracles.transformed(oracles.yuan_minus_AF());F=-V['B']*K
        p.update(reference_B=encode(oracles.yuan_minus_AF()),mixing={**p['mixing'],'regular':encode(K)},
          finite={**p['finite'],'regular':encode(F)},independent_finite={**p['finite'],'regular':encode(F)},
          bare={**p['bare'],'regular':encode(F-K/V['eps'])},counterterm={**p['counterterm'],'regular':encode(K/V['eps'])})
        self.assertEqual(status(c.d17_checks(ps['d17'],self.base)),'CHECKS_PASS')
    def test_transport_roundtrip(self):
        for e in [s.Rational(-2,3),s.pi,V['u']+V['v'],s.log(V['u']),s.polylog(2,V['v']),oracles.hard(),oracles.kang_B()]:
            self.assertTrue(zero(decode(encode(e))-e))
    def test_transport_rejects_code_and_undefined(self):
        for tree in ['__import__("os")','undefined',True,1.2,['exec','u'],['pow','u',1000],['log',0],{'op':'raw','code':'x'}]:
            with self.subTest(tree=tree):
                with self.assertRaises(ValueError):decode(tree)
    def test_endpoint_distribution_actions(self):
        u=V['u']
        for n in range(1,7):
            self.assertTrue(zero(plus_action('D0',u**n)+s.harmonic(n)))
            self.assertTrue(zero(plus_action('D1',u**n)-(s.harmonic(n)**2+s.harmonic(n,2))/2))
        for low in [s.Rational(1,7),s.Rational(2,5)]:
            self.assertEqual(plus_action('D0',s.Integer(1),low),s.log(1-low))
            self.assertEqual(plus_action('D1',s.Integer(1),low),s.log(1-low)**2/2)
    def test_endpoint_coefficients_cannot_hide_u(self):
        with self.assertRaises(ValueError):distribution({'regular':0,'delta':'u','D0':0,'D1':0})
    def test_each_physics_mutation_fails(self):
        cases=[('d16',['identities','PV_combined_measure'],0),('d16',['definitions','born_coupling'],'alpha_EM*alpha_s'),
          ('d16',['independent_HF'],False),('d16',['definitions','radius_qualification'],'all_R_certified'),
          ('d17',['reference_B'],0),('d17',['native_basis_factor'],0),('d17',['finite','regular'],0),
          ('d17',['counterterm','regular'],0),('d17',['independent_finite','delta'],1),
          ('d17',['finite','delta'],'T'),('d17',['diagonal_canonical'],{}),('d17',['closed_full_twist3_RG'],True),
          ('d17',['v_prescription'],'ordinary_integral'),('d17',['v_delta','finite','regular'],1),('d17',['v_derivative','mixing','regular'],1),
          ('d18',['UU','overlap'],0),('d18',['UT','finite'],0),('d18',['UU','gamma_G_minus_TMD'],1),
          ('d18',['multiply_inclusive_J'],True),('d18',['import_pp_out_of_jet_H'],True),
          ('d19',['observable','UT1'],0),('d19',['HF_integrand','regular'],0),('d19',['ratio','A1'],0),
          ('d19',['input_packet_hashes','d17'],'wrong'),('d19',['all_b_OPE_extrapolation'],True),
          ('d19',['paper_limit_is_full_NLO'],True),('d19',['scheme_variation','UU'],0)]
        for sid,path,value in cases:
            with self.subTest(sid=sid,path=path):
                ps=copy.deepcopy(self.ps);d=ps[sid]['data']
                for key in path[:-1]:d=d[key]
                d[path[-1]]=value
                self.assertEqual(status(c.check_all(ps,self.base)),'FAIL')
    def test_probes_both_seeds(self):
        for seed in (1729,92741):
            for kind in ('HF','jet'):
                with self.subTest(seed=seed,kind=kind):
                    ps=perturbed(self.ps,kind,seed);sid='d17' if kind=='HF' else 'd18'
                    rows=c.probe_checks(kind,self.ps[sid],ps[sid],oracles.probe_density(seed,kind),ps['d19'])
                    self.assertEqual(status(rows),'CHECKS_PASS')
                    self.assertEqual(status(c.check_all(ps,self.base)),'CHECKS_PASS')
                    self.assertEqual(status(c.probe_checks(kind,self.ps[sid],self.ps[sid],oracles.probe_density(seed,kind),self.ps['d19'])),'FAIL')
    def test_unreviewed_finite_constant_limit_explicit(self):
        # A consistent common finite change is NOT constrained by pole/RG tests.
        # This expected limitation is why scientific review remains mandatory.
        ps=copy.deepcopy(self.ps);p=ps['d17']['data'];delta=V['CF']*V['u']**3*V['v']**2
        for name in ('bare','finite','independent_finite'):
            p[name]['regular']=encode(decode(p[name]['regular'])+delta)
        ps['d19']=make_assembly(ps['d17'],ps['d18'])
        self.assertEqual(status(c.check_all(ps,self.base)),'CHECKS_PASS')
        from verify_nlo import QUALIFICATIONS
        self.assertEqual(QUALIFICATIONS['source_review'],'REQUIRED')
    def test_recoil_and_fragmentation_logs_independent(self):
        ps=copy.deepcopy(self.ps);p=ps['d19']['data'];p['observable']['UU1']=encode(decode(p['observable']['UU1']).subs(V['Bq'],V['B']))
        self.assertEqual(status(c.check_all(ps,self.base)),'FAIL')

V=SYMBOLS
