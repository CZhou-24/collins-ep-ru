"""Independent arithmetic checks and deliberately wrong coefficient mutants."""
import copy,math,random,unittest
from fractions import Fraction
from algebra import *
from assembly_reference import references
from assembly_oracle import *
import real_oracle as real

def fixtures():
    r,o,a,_=references()
    return packet('radiation',r),packet('operators',o),packet('assembly',{'expressions':a})

class AlgebraTests(unittest.TestCase):
    def test_exact_distributivity(self):
        x=sym('Bq');y=sym('Bh')
        self.assertTrue(equal(power(add(x,y),2),add(power(x,2),mul(2,x,y),power(y,2))))
    def test_exact_pi_constant_detected(self):
        self.assertFalse(equal(mul(rat(1,6),power(sym('pi'),2)),mul(rat(1,12),power(sym('pi'),2))))
    def test_regulator_hidden_in_coefficient(self):
        with self.assertRaises(ValueError):laurent({'-1,0':sym('eps')})
    def test_mixed_pole_retained(self):
        self.assertNotEqual(combination((1,{'-1,-1':rat(2)})),{})
    def test_noncanonical_power_rejected(self):
        with self.assertRaises(ValueError):laurent({'-01,0':rat(1)})
    def test_negative_polynomial_power_rejected(self):
        with self.assertRaises(ValueError):polynomial(power(sym('CF'),-1))
    def test_fraction_cancellation(self):
        self.assertEqual(combination((Fraction(1,2),{'-1,0':rat(2)}),(-1,{'-1,0':rat(1)})),{})
    def test_boolean_rational_rejected(self):
        with self.assertRaises(ValueError):validate({'op':'rat','num':True,'den':1})
    def test_duplicate_plus_order(self):
        with self.assertRaises(ValueError):distribution({'delta':rat(0),'regular':rat(0),'plus':[{'n':0,'numerator':rat(1)}]*2})
    def test_bad_schema(self):
        r,o,a=fixtures();r['unreviewed_extra']=True
        with self.assertRaises(ValueError):coefficients(r,o,a,1729)
    def test_held_out_seeds(self):
        for seed in (1729,92741,61019,83077):
            checks=coefficients(*fixtures(),seed)
            self.assertEqual(len(checks),184);self.assertTrue(all(c['status']=='PASS' for c in checks),checks)

class DistributionTests(unittest.TestCase):
    def test_qq_and_tensor_moments(self):
        r,*_=references();p={'CF':4/3,'TR':.5,'kappa':1.1}
        for N in range(1,9):
            phi=[0.]*(N-1)+[1.];H=sum(1/n for n in range(1,N+1))
            self.assertAlmostEqual(action(r['splitting']['qq'],phi,p),p['CF']*(1.5-2*H+1/(N*(N+1))),places=10)
            self.assertAlmostEqual(action(r['splitting']['transversity'],phi,p),p['CF']*(1.5-2*H),places=10)
    def test_gq_moment(self):
        r,*_=references();p={'CF':1.2,'TR':.5,'kappa':1.1}
        for N in range(2,7):
            self.assertAlmostEqual(action(r['splitting']['gq'],[0.]*(N-1)+[1.],p),1.2*(2/(N-1)-2/N+1/(N+1)),places=11)
    def test_qg_moment(self):
        r,*_=references();p={'CF':1.2,'TR':.5,'kappa':1.1}
        for N in range(1,7):
            self.assertAlmostEqual(action(r['splitting']['qg'],[0.]*(N-1)+[1.],p),.5*(1/N-2/(N+1)+2/(N+2)),places=11)
    def test_interval_boundary(self):
        d={'delta':rat(0),'regular':rat(0),'plus':[{'n':0,'numerator':rat(1)}]}
        for x in (.1,.4,.8):self.assertAlmostEqual(action(d,[1.],{},x),math.log(1-x),places=11)
    def test_log_moments(self):
        for n in range(3):
            d={'delta':rat(0),'regular':rat(0),'plus':[{'n':n,'numerator':rat(1)}]}
            self.assertAlmostEqual(action(d,[0.,1.],{},n=96),(-1)**(n+1)*math.factorial(n),places=7)
    def test_regulated_endpoint_remainder(self):
        r,*_=references();p={'CF':1.2,'TR':.5,'kappa':1.3};phi=[.3,-.4,.7]
        errors=[]
        for eps in (-.025,-.0125):
            alpha=-p['kappa']*eps
            # Independent beta integrals for polynomial weights; endpoint formula is not used.
            exact=sum(c*math.gamma(n+1)*math.gamma(alpha)/math.gamma(n+1+alpha) for n,c in enumerate(phi))
            expansion=sum(eps**int(k)*action(d,phi,p,n=96) for k,d in r['endpoint'].items())
            errors.append(abs(exact-expansion))
        self.assertLess(errors[1],errors[0]*.14)

class IntegralTests(unittest.TestCase):
    def test_laplace_against_gamma(self):
        for eps in (.17,.31,.53):
            for A,B in ((.5,1.8),(1.8,.5),(1.,1.)):
                self.assertAlmostEqual(radial_difference(eps,A,B),math.gamma(-eps)*(A**eps-B**eps),places=10)
    def test_gaussian_log_at_zero(self):
        a=.7;mu=3.;i,l=gaussian_integrals(0,a,mu);c0=2*math.exp(-.5772156649015329)
        self.assertAlmostEqual(i,1/(4*math.pi*a),places=14)
        self.assertAlmostEqual(l/i,math.log(mu*mu/(a*c0*c0))-.5772156649015329,places=13)
    def test_gaussian_series_against_angular_quadrature(self):
        # J0 is independently integrated as an angular cosine, not evaluated by the series oracle.
        for q,A in ((.25,.4),(.8,.8)):
            mu=3.;c0=2*math.exp(-.5772156649015329)
            def f(t,log):
                b=t*t;angular=integrate(lambda theta:math.cos(q*b*math.cos(theta)),0,math.pi,64)/math.pi
                return 2*t**3*math.exp(-A*b*b)*angular*(math.log(mu*mu*b*b/(c0*c0)) if log else 1)/(2*math.pi)
            for log,expected_value in enumerate(gaussian_integrals(q,A,mu)):
                actual=sum(integrate(lambda t:f(t,log),lo,hi,96) for lo,hi in [(0,.1),(.1,.5),(.5,1),(1,2),(2,3)])
                self.assertAlmostEqual(actual,expected_value,places=9)
    def test_spin_reverse_and_zero_j(self):
        req=[r for r in requests(1729) if r['kind']=='gaussian'];a,b,z=expected(req[5]),expected(req[-1]),expected(req[-2])
        self.assertEqual(a['UU1'],b['UU1']);self.assertEqual(a['UT1'],-b['UT1']);self.assertEqual(z['UT0'],0.);self.assertEqual(z['UT1'],0.)
    def test_two_widths_do_not_cancel_soft(self):
        r=[r for r in requests(1729) if r['kind']=='gaussian'][0];v=expected(r)
        self.assertGreater(abs(v['UT1']/v['UT0']-v['UU1']/v['UU0']),1e-3)

class RealTests(unittest.TestCase):
    def test_clifford_algebra(self):
        for i in range(4):
            for j in range(4):
                a=real.plus(real.mm(real.G[i],real.G[j]),real.mm(real.G[j],real.G[i]));b=real.scale(real.ident(),2*real.METRIC[i] if i==j else 0)
                self.assertEqual(a,b)
    def test_on_shell_and_conservation(self):
        for r in real.requests(1729):
            for key in ('l','p','lp','pp','k'):self.assertAlmostEqual(real.dot(r[key],r[key]),0,places=9)
            d=real.vadd(real.vadd(r['l'],r['p']),real.vscale(real.vadd(real.vadd(r['lp'],r['pp']),r['k']),-1))
            self.assertLess(max(map(abs,d)),1e-12)
    def test_ward_and_spin_bound(self):
        for r in real.requests(92741):
            vals=real.expected(r);self.assertGreater(vals['UU'],0)
            if 'UT' in vals:self.assertLessEqual(abs(vals['UT']),vals['UU']*(1+1e-12))
            for ward in ('gluon','photon'):self.assertLess(abs(real.contract(r,r['channel'],ward=ward)),1e-10*max(1,vals['UU']))
    def test_real_homogeneity(self):
        for r in real.requests(1729)[:2]:
            rr=copy.deepcopy(r)
            for key in ('l','p','lp','pp','k'):rr[key]=[3*x for x in rr[key]]
            self.assertAlmostEqual(real.contract(rr,r['channel'])*9,real.contract(r,r['channel']),places=11)
    def test_soft_limit(self):
        E=5.;th=.8
        r={'l':[E,0,0,-E],'p':[E,0,0,E],'pp':[E,E*math.sin(th),0,E*math.cos(th)],'lp':[E,-E*math.sin(th),0,-E*math.cos(th)],'CF':4/3}
        s=4*E*E;t=real.dot(real.vadd(r['l'],real.vscale(r['lp'],-1)),real.vadd(r['l'],real.vscale(r['lp'],-1)));u=-s-t;born=2*(s*s+u*u)/(t*t)
        for lam in (1e-4,1e-5):
            r['k']=[lam,0,lam,0];soft=2*real.dot(r['p'],r['pp'])/(real.dot(r['p'],r['k'])*real.dot(r['pp'],r['k']))
            self.assertLess(abs(real.contract(r)/(r['CF']*soft*born)-1),lam)

class ResponseTests(unittest.TestCase):
    def setUp(self):self.req=[r for r in requests(1729) if r['kind'] in ('primitive','gaussian','scales')][:7];self.payload={'run_id':'fresh','status':'PASS','responses':[{'id':r['id'],'values':expected(r)} for r in self.req]}
    def test_expected_values(self):self.assertTrue(all(c['status']=='PASS' for c in compare_response(self.req,self.payload,'fresh')))
    def test_wrong_nonce(self):
        with self.assertRaises(ValueError):compare_response(self.req,self.payload,'stale')
    def test_missing_row(self):
        self.payload['responses'].pop()
        with self.assertRaises(ValueError):compare_response(self.req,self.payload,'fresh')
    def test_duplicate_row(self):
        self.payload['responses'].append(self.payload['responses'][0])
        with self.assertRaises(ValueError):compare_response(self.req,self.payload,'fresh')
    def test_nan(self):
        self.payload['responses'][0]['values']['value']=float('nan')
        with self.assertRaises(ValueError):compare_response(self.req,self.payload,'fresh')
    def test_fake_numeric(self):
        self.payload['responses'][0]['values']['value']='1.0'
        with self.assertRaises(ValueError):compare_response(self.req,self.payload,'fresh')

class MutantTests(unittest.TestCase):
    def rejected(self,edit):
        r,o,a=fixtures();edit(r,o,a)
        try:cs=coefficients(r,o,a,92741)
        except (ValueError,KeyError):return
        self.assertTrue(any(c['status']=='FAIL' for c in cs),'Physics mutant escaped')

def _mutants():
    cases={}
    for sector in ('global','cs_out','standard','injet'):
        cases['missing_'+sector]=lambda r,o,a,s=sector:r['soft_bare'].pop(s)
        for key in ('-2,0','-1,0','0,0'):
            cases['changed_'+sector+'_'+key.replace(',','_').replace('-','m')]=lambda r,o,a,s=sector,k=key:r['soft_bare'][s].__setitem__(k,add(r['soft_bare'][s][k],sym('CF')))
    cases['dropped_mixed_pole']=lambda r,o,a:r['soft_bare']['global'].pop('-1,-1')
    cases['discarded_eta']=lambda r,o,a:r['soft_bare']['standard'].__setitem__('0,-1',rat(0))
    cases['inclusive_jet_constant']=lambda r,o,a:r['jet_bare'].__setitem__('0,0',rat(0))
    cases['tensor_as_unpolarized']=lambda r,o,a:r['splitting'].__setitem__('transversity',copy.deepcopy(r['splitting']['qq']))
    cases['missing_endpoint_delta']=lambda r,o,a:r['splitting']['qq'].__setitem__('delta',rat(0))
    cases['whole_fraction_plus']=lambda r,o,a:r['splitting']['qq'].__setitem__('delta',mul(3,sym('CF')))
    cases['endpoint_sign']=lambda r,o,a:r['endpoint']['1']['plus'][0].__setitem__('numerator',sym('kappa'))
    cases['epsilon_numerator']=lambda r,o,a:r['raw_splitting'].__setitem__('qq',mul(sym('CF'),add(1,power(sym('z'),2)),power(sub(1,sym('z')),-1)))
    cases['gluon_spin_average']=lambda r,o,a:r['raw_splitting'].__setitem__('qg',mul(2,r['raw_splitting']['qg']))
    cases['radius_sign']=lambda r,o,a:o['renormalized'].__setitem__('soft',mul(-1,o['renormalized']['soft']))
    cases['wrong_subtraction_sign']=lambda r,o,a:o['counterterms']['soft'].__setitem__('-1,0',mul(-1,o['counterterms']['soft']['-1,0']))
    cases['gamma_factor_two']=lambda r,o,a:o['anomalous'].__setitem__('beam_UT',mul(2,o['anomalous']['beam_UT']))
    cases['Collins_Soper_sign']=lambda r,o,a:o['anomalous'].__setitem__('CS_fragment',mul(-1,o['anomalous']['CS_fragment']))
    cases['extra_jet']=lambda r,o,a:a['expressions'].__setitem__('UU1',add(a['expressions']['UU1'],mul(sym('J1'),sym('HUU'),sym('f0'),sym('d0'))))
    cases['missing_fragment_order1']=lambda r,o,a:a['expressions'].__setitem__('UT1',sub(a['expressions']['UT1'],mul(sym('HUT'),sym('t0'),sym('c1'))))
    cases['UT_wrong_hard']=lambda r,o,a:a['expressions'].__setitem__('UT0',mul(sym('HUU'),sym('t0'),sym('c0')))
    cases['order2_contamination']=lambda r,o,a:a['expressions'].__setitem__('UU1',add(a['expressions']['UU1'],mul(sym('HUU'),sym('f1'),sym('d1'))))
    cases['overclaimed_radius']=lambda r,o,a:r['conventions'].__setitem__('approximation','exact_R')
    return cases

MUTANTS=_mutants()
for name,edit in MUTANTS.items():
    def test(self,e=edit):self.rejected(e)
    setattr(MutantTests,'test_'+name,test)

if __name__=='__main__':unittest.main()
