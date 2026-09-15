"""Oracle tests and deliberate defects; these are never derivation outputs."""
import copy
import json
import math
import unittest

import oracle


def rat(num, den=1):
    return {"op": "rat", "num": num, "den": den}


def sym(name):
    return {"op": "sym", "name": name}


def add(*args):
    return {"op": "add", "args": list(args)}


def mul(*args):
    return {"op": "mul", "args": list(args)}


def power(base, exponent):
    return {"op": "pow", "base": base, "exp": exponent}


def fixture(component):
    if component == "born_hard":
        expressions = {
            "H_UU": mul(rat(2), add(power(sym("s"), 2), power(sym("u"), 2)),
                        power(sym("t"), -2)),
            "H_UT": mul(rat(-4), sym("s"), sym("u"), power(sym("t"), -2)),
        }
    else:
        expressions = {"h1": mul(sym("CF"), add(
            mul(rat(-1), power(sym("L"), 2)), mul(rat(-3), sym("L")),
            rat(-8), mul(rat(1, 6), power(sym("pi"), 2))))}
    return {"schema": oracle.SCHEMA, "component": component,
            "conventions": copy.deepcopy(oracle.CONVENTIONS[component]),
            "expressions": expressions}


class OracleTests(unittest.TestCase):
    def passes(self, payload, seed=92741):
        return all(check["status"] == "PASS" for check in oracle.validate_export(payload, seed))

    def test_reference_fixtures_both_seeds(self):
        for seed in (1729, 92741):
            for component in oracle.CONVENTIONS:
                with self.subTest(seed=seed, component=component):
                    payload = fixture(component)
                    checks = oracle.validate_export(payload, seed)
                    self.assertEqual(len(checks), 73)
                    self.assertTrue(all(x["status"] == "PASS" for x in checks), checks)

    def test_json_roundtrip(self):
        for component in oracle.CONVENTIONS:
            payload = fixture(component)
            self.assertEqual(oracle.loads_export(json.dumps(payload)), payload)

    def test_determinism(self):
        payload = fixture("born_hard")
        self.assertEqual(oracle.validate_export(payload, 199), oracle.validate_export(payload, 199))
        self.assertNotEqual(oracle.validate_export(payload, 199), oracle.validate_export(payload, 201))

    def test_spin_sign_mutant(self):
        payload = fixture("born_hard")
        payload["expressions"]["H_UT"] = mul(rat(-1), payload["expressions"]["H_UT"])
        self.assertFalse(self.passes(payload))

    def test_born_factor_two_mutant(self):
        payload = fixture("born_hard")
        payload["expressions"]["H_UU"] = mul(rat(2), payload["expressions"]["H_UU"])
        self.assertFalse(self.passes(payload))

    def test_born_missing_u_squared_mutant(self):
        payload = fixture("born_hard")
        payload["expressions"]["H_UU"]["args"][1] = power(sym("s"), 2)
        self.assertFalse(self.passes(payload))

    def test_equivalent_born_on_shell(self):
        payload = fixture("born_hard")
        # Replace u by -s-t; identity holds on the declared massless support.
        payload["expressions"]["H_UT"] = mul(
            rat(4), sym("s"), add(sym("s"), sym("t")), power(sym("t"), -2))
        self.assertTrue(self.passes(payload))

    def test_hard_amplitude_normalization_mutant(self):
        payload = fixture("spacelike_hard_one_loop")
        payload["expressions"]["h1"] = mul(rat(1, 2), payload["expressions"]["h1"])
        self.assertFalse(self.passes(payload))

    def test_hard_log_sign_mutant(self):
        payload = fixture("spacelike_hard_one_loop")
        payload["expressions"]["h1"]["args"][1]["args"][1] = mul(rat(3), sym("L"))
        self.assertFalse(self.passes(payload))

    def test_hard_missing_finite_term_mutant(self):
        payload = fixture("spacelike_hard_one_loop")
        payload["expressions"]["h1"]["args"][1]["args"][2] = rat(0)
        self.assertFalse(self.passes(payload))

    def test_hard_timelike_pi_squared_mutant(self):
        payload = fixture("spacelike_hard_one_loop")
        payload["expressions"]["h1"]["args"][1]["args"][3] = mul(rat(7, 6), power(sym("pi"), 2))
        self.assertFalse(self.passes(payload))

    def test_hard_fixed_cf_mutant(self):
        payload = fixture("spacelike_hard_one_loop")
        payload["expressions"]["h1"]["args"][0] = rat(4, 3)
        self.assertFalse(self.passes(payload))

    def test_bad_convention(self):
        payload = fixture("spacelike_hard_one_loop")
        payload["conventions"]["logarithm"] = "L=ln(Q^2/mu^2)"
        self.assertFalse(self.passes(payload))

    def test_code_string_rejected(self):
        payload = fixture("born_hard")
        payload["expressions"]["H_UU"] = "__import__('os').system('false')"
        self.assertFalse(self.passes(payload))

    def test_call_operation_rejected(self):
        payload = fixture("born_hard")
        payload["expressions"]["H_UU"] = {"op": "call", "name": "open", "args": []}
        self.assertFalse(self.passes(payload))

    def test_unknown_symbol(self):
        payload = fixture("born_hard")
        payload["expressions"]["H_UU"] = sym("__import__")
        self.assertFalse(self.passes(payload))

    def test_extra_field_rejected(self):
        payload = fixture("born_hard")
        payload["expected_outputs"] = []
        self.assertFalse(self.passes(payload))

    def test_float_and_bool_rational_rejected(self):
        for value in (2.0, True, float("nan"), float("inf")):
            payload = fixture("born_hard")
            payload["expressions"]["H_UU"] = rat(value)
            self.assertFalse(self.passes(payload))

    def test_zero_denominator_rejected(self):
        payload = fixture("born_hard")
        payload["expressions"]["H_UU"] = rat(1, 0)
        self.assertFalse(self.passes(payload))

    def test_nonpositive_denominator_rejected(self):
        payload = fixture("born_hard")
        payload["expressions"]["H_UU"] = rat(1, -2)
        self.assertFalse(self.passes(payload))

    def test_huge_rational_rejected(self):
        payload = fixture("born_hard")
        payload["expressions"]["H_UU"] = rat(2**200)
        self.assertFalse(self.passes(payload))

    def test_unbounded_power_rejected(self):
        for exponent in (999, 1.5, True):
            payload = fixture("born_hard")
            payload["expressions"]["H_UU"] = power(sym("s"), exponent)
            self.assertFalse(self.passes(payload))

    def test_deep_expression_rejected(self):
        payload = fixture("born_hard")
        expression = sym("s")
        for _ in range(50):
            expression = power(expression, 1)
        payload["expressions"]["H_UU"] = expression
        self.assertFalse(self.passes(payload))

    def test_cyclic_expression_rejected(self):
        payload = fixture("born_hard")
        expression = {"op": "pow", "exp": 1}
        expression["base"] = expression
        payload["expressions"]["H_UU"] = expression
        self.assertFalse(self.passes(payload))

    def test_node_budget_rejected(self):
        payload = fixture("born_hard")
        payload["expressions"]["H_UU"] = add(*[rat(1) for _ in range(2048)])
        self.assertFalse(self.passes(payload))

    def test_undefined_export_rejected(self):
        payload = fixture("born_hard")
        payload["expressions"]["H_UU"] = power(rat(0), -1)
        self.assertFalse(self.passes(payload))

    def test_duplicate_keys_rejected(self):
        with self.assertRaises(oracle.ExportError):
            oracle.loads_export('{"schema":"x","schema":"y"}')

    def test_nan_json_rejected(self):
        with self.assertRaises(oracle.ExportError):
            oracle.loads_export('{"schema":NaN}')

    def test_invalid_seeds(self):
        for seed in (-1, True, "1729", 2**64):
            self.assertFalse(self.passes(fixture("born_hard"), seed))

    def test_dual_product_polynomial(self):
        # Derivatives of (x^2+3x+2)*(x^2-1) at x=0,1,2,-3.
        expression = mul(add(power(sym("L"), 2), mul(rat(3), sym("L")), rat(2)),
                         add(power(sym("L"), 2), rat(-1)))
        for x in (0.0, 1.0, 2.0, -3.0):
            actual = oracle._evaluate(expression, {"L": x}, "L")
            expected = (x**4+3*x**3+x*x-3*x-2, 4*x**3+9*x*x+2*x-3, 12*x*x+18*x+2)
            self.assertEqual(actual, expected)

    def test_dual_laurent(self):
        expression = power(add(sym("L"), rat(7)), -2)
        for x in (-3.0, 0.0, 2.0):
            actual = oracle._evaluate(expression, {"L": x}, "L")
            expected = ((x+7)**-2, -2*(x+7)**-3, 6*(x+7)**-4)
            for a, b in zip(actual, expected):
                self.assertTrue(math.isclose(a, b, rel_tol=1e-15))


if __name__ == "__main__":
    unittest.main()
