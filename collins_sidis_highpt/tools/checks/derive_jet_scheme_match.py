#!/usr/bin/env python3
"""Exact out-of-jet radial/distribution calculation, with literal references.

The transverse kernel is taken from the native production-collinear export.
The geometric radial measure is Eq. A.2 of pinned 2311.00672v2. This is a
finite jet matching check, not an independent hard-scattering calculation.
"""
import argparse
import hashlib
import json
import re
import sys
from pathlib import Path

import sympy as s
from sympy.parsing.mathematica import parse_mathematica

ROOT = Path(__file__).resolve().parents[3]
ENGINE = ROOT / "collins_sidis_highpt"
sys.path.insert(0, str(ROOT / "collins_support/validators/analytic"))
from algebra import decode

p = argparse.ArgumentParser()
p.add_argument("--production-kernel", required=True, type=Path,
               help="Native tagged-operator embedding.wl containing the exact BMHV scalar")
p.add_argument("--output", required=True, type=Path)
args = p.parse_args()
if args.output.exists():
    raise FileExistsError(args.output)
z, L, CF, D, eps = s.symbols("z L CF D eps")
native_text = args.production_kernel.read_text()
matches = re.findall(r'"BMHV"\s*->\s*(.*?)\s*,\s*"BMHV_minus_NDR"', native_text, re.S)
if len(matches) != 1:
    raise ValueError("Expected one native BMHV scalar followed by its BMHV_minus_NDR field")
kernel = parse_mathematica(matches[0])
literal = 2 * CF * z / (1-z)
expected = literal + CF * (D-4)**2 * (1-z)/(2*(D-2))
kernel_check = s.factor(kernel-expected)
if kernel_check != 0:
    raise ValueError(f"Unexpected native production kernel: {kernel_check}")

# Integral from kT_min^2=(1-z)^2*(pJT R)^2 to infinity is
# (kT_min^2)^(-eps)/eps, initially Re eps>0. Analytic continuation
# defines the endpoint distributions; no ordinary divergent integral is used.
measure = 1 + eps*L + eps**2*(L**2/2-s.pi**2/12)
soft_distribution = {"delta": -1/(2*eps), "plus0": s.Integer(1),
                     "plus1": -2*eps}
bare = {part: s.expand(2*CF*measure*v/eps)
        for part, v in soft_distribution.items()}
# z times a plus distribution = its endpoint value times the plus
# distribution plus (z-1) times its ordinary density. Keep this regular term.
bare["regular"] = s.expand(-2*CF*measure/eps *
                           (1-2*eps*s.log(1-z)))
pole = {"delta": -CF/eps**2-CF*L/eps,
        "plus0": 2*CF/eps, "plus1": s.Integer(0), "regular": -2*CF/eps}
finite = {k: s.expand(v-pole[k]).coeff(eps, 0) for k, v in bare.items()}
negative_residuals = {k: {str(n): str(s.expand(v-pole[k]).coeff(eps,n))
                        for n in (-2,-1)} for k,v in bare.items()}

# The exact difference has one vanishing power at the soft endpoint; the
# out-of-jet radial pole is simple for it. It has no hidden endpoint pole.
difference = s.factor((kernel-literal).subs(D,4-2*eps))
finite_conversion = s.limit(difference/eps, eps, 0)
soft_valuation = 1
reference_path = ENGINE / "references/jet_matching.json"
reference = json.loads(reference_path.read_text())
key = next(k.rsplit("_",1)[0] for k in reference["equations"]
           if k.startswith("Tqq_") and k.endswith("_delta"))
rows = []
for part, value in finite.items():
    equation = reference["equations"][key+"_"+part]
    target = decode(equation["value"])
    residual = s.simplify(value-target)
    rows.append({"id":part,"derived":str(value),"reference":str(target),
                 "difference":str(residual),
                 "status":"EXACT AFTER EXPLICIT CONVERSION" if residual==0 else "MISMATCH",
                 "reference_key":key+"_"+part})

# Independent regulated monomial actions of 2 CF z (1-z)^(-1-2eps).
# Beta(n+2,-2eps)=Gamma(n+2)Gamma(-2eps)/Gamma(n+2-2eps).
# Write Gamma(-2eps)/Gamma(n+2-2eps) as a finite exact product; this
# avoids asking a symbolic integrator to manipulate a divergent endpoint.
actions = []
for n in (0,1,2,3):
    beta = s.factorial(n+1)/s.prod(k-2*eps for k in range(n+2))
    regulated = 2*CF*measure*beta/eps
    regulated_finite = s.series(regulated,eps,0,1).removeO().expand().coeff(eps,0)
    test = z**n
    canonical = finite["delta"] + s.integrate(
        finite["plus0"]*(test-1)/(1-z)
        +finite["plus1"]*s.log(1-z)*(test-1)/(1-z)
        +finite["regular"]*test,(z,0,1))
    residual = s.simplify(regulated_finite-canonical)
    actions.append({"test":str(test),"regulated_finite":str(s.simplify(regulated_finite)),
                    "canonical_finite":str(s.simplify(canonical)),"residual":str(residual)})

files = [Path(__file__), args.production_kernel, reference_path,
         ENGINE / "references/2311.00672v2/source/main.tex"]
result = {
    "scope":"Physical-tagged quark transversity out-of-jet matching at one loop; hard finite assembly remains separate",
    "radial_integral":"Integral_(pJT R)^2(1-z)^2^infinity dkT2/(kT2)^(1+eps) = ((pJT R)^2(1-z)^2)^(-eps)/eps",
    "angular_normalization":"exp(gamma_E eps)/Gamma(1-eps); L=log(mu^2/(pJT R)^2)",
    "source_measure":"Pinned 2311.00672v2 Appendix A, out-of-jet integral and endpoint expansion",
    "production_kernel":str(kernel),"literal_real_kernel":str(literal),
    "all_D_difference":str(s.factor(kernel-literal)),"all_D_status":"MISMATCH",
    "soft_endpoint_valuation":soft_valuation,
    "finite_conversion_from_actual_kernel":str(finite_conversion),
    "pole_subtraction":{k:str(v) for k,v in pole.items()},
    "pole_definition":"MSbar out-of-jet matching counterterm: -CF delta/eps^2 + [Delta_T Pqq-CF(L+3/2)delta]/eps; soft-subtracted TMD operator held fixed",
    "pole_residuals":negative_residuals,"coefficient_checks":rows,
    "independent_regulated_actions":actions,
    "conventions":"D_n=[log^n(1-z)/(1-z)]_+ on [0,1]; multiply z before canonical conversion; observed daughter physical; gamma5 BMHV; no extra in-jet soft factor",
    "qualification":"Exact symbolic radial/distribution check using a native-derived spin kernel and imported universal anti-kT geometry. It is neither a new derivation of the TMD factorization theorem nor full NLO observable acceptance.",
    "source_sha256":{str(f.resolve()):hashlib.sha256(f.read_bytes()).hexdigest() for f in files}}
args.output.parent.mkdir(parents=True,exist_ok=True)
args.output.write_text(json.dumps(result,indent=2)+"\n")
failures = sum(r["status"]=="MISMATCH" for r in rows)
failures += sum(a["residual"]!="0" for a in actions)
failures += sum(v!="0" for values in negative_residuals.values() for v in values.values())
failures += finite_conversion != 0
print(json.dumps({"finite_coefficients":len(rows),"regulated_actions":len(actions),
                  "finite_conversion":str(finite_conversion),"failures":int(failures)}))
sys.exit(bool(failures))
