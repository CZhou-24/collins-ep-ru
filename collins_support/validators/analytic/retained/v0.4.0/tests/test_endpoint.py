import unittest
import sympy as s
from symbolic import SYMBOLS as V,zero
import oracles

class TwoFractionEndpointTests(unittest.TestCase):
    def test_smooth_probe_preserves_delta_and_derivative_contacts(self):
        v=V['v']
        for seed in (1729,92741):
            density=oracles.probe_density(seed,'HF');contacts=oracles.probe_endpoints(seed)
            for degree in (0,1,2,3):
                with self.subTest(seed=seed,degree=degree):
                    phi=v**degree;value=phi.subs(v,1);derivative=s.diff(phi,v).subs(v,1)
                    prescribed=s.integrate(density*(phi-value-(v-1)*derivative),(v,0,1))+contacts['v_delta']*value-contacts['v_derivative']*derivative
                    direct=s.integrate(density*phi,(v,0,1))
                    self.assertTrue(zero(prescribed-direct))
    def test_omitting_derivative_contact_changes_linear_test_function(self):
        v=V['v'];density=oracles.probe_density(1729,'HF');contact=oracles.probe_endpoints(1729)
        self.assertFalse(zero(contact['v_delta']-s.integrate(density*v,(v,0,1))))
