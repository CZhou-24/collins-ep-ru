#!/usr/bin/env python3
"""Assemble the native qgg leading-pole pairs in the declared continuous family."""
import argparse
import hashlib
import json
from pathlib import Path
import sympy as s
from sympy.parsing.mathematica import parse_mathematica
from check_collinear_exports import field


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def final_field(text, key):
    start = text.index('"' + key + '" ->') + len(key) + 5
    return parse_mathematica(text[start:text.index('|>', start)].strip())


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--first-run', type=Path, required=True)
    ap.add_argument('--last-pair-run', type=Path, required=True)
    ap.add_argument('--embedding', type=Path, required=True)
    ap.add_argument('--output', type=Path, required=True)
    args = ap.parse_args()
    first, last = args.first_run.resolve(), args.last_pair_run.resolve()
    for name in ['geometry.wl', 'born.wl']:
        if (first / name).read_bytes() != (last / name).read_bytes():
            raise ValueError('Collinear family or Born normalization differs: ' + name)
    den_text = (last / 'denominators.wl').read_text()
    singular = field(den_text, 'vanishing_denominator_diagrams', 'domain')
    assert tuple(singular) == (1, 8)
    assert field(den_text, 'emission_Dirac_identity_residual', 'axial_transversality_residual') == 0
    assert field(den_text, 'axial_transversality_residual', 'singular_amplitudes') == 0
    pair_files = [first / '1_1.wl', first / '1_8.wl', last / '8_8.wl']
    coefficients = {}
    high_poles = {}
    for path in pair_files:
        text = path.read_text().split('"averaged_laurent" ->', 1)[1]
        coefficients[path.stem] = final_field(text, '-2')
        high_poles[path.stem] = [field(text, '-4', '-3'), field(text, '-3', '-2')]
    assert all(value == 0 for row in high_poles.values() for value in row)
    born = final_field((first / 'born.wl').read_text(), 'dimensional_Born_T22_XX')
    m2, SUNN, CF, zc, z, D, eps = s.symbols('m2 SUNN CF zc z D eps')
    kernel = s.factor(m2 * sum(coefficients.values()) / (2 * born))
    op_text = args.embedding.read_text()
    operator = field(op_text, 'BMHV', 'BMHV_minus_NDR').subs({CF: (SUNN**2 - 1) / (2 * SUNN), z: zc})
    residue = s.factor(kernel - operator)
    if residue != 0:
        raise ValueError('Actual real residue does not equal the fixed-daughter operator: ' + str(residue))
    literal = (SUNN**2 - 1) / SUNN * zc / (1 - zc)
    literal_difference = s.factor(kernel - literal)
    inputs = pair_files + [first / 'geometry.wl', first / 'born.wl', first / 'inputs.wl', last / 'inputs.wl', last / 'denominators.wl', args.embedding]
    result = {
        'scope': 'Exact outgoing k1||k2 collinear residue of saved Hqq RealQGG for spin 22 and photon XX; Q=2, s=4, parent central Born direction, continuous 0<zc<1 and symbolic D',
        'assumptions': 'm2>0, D=4-2 eps, lam->0, physical k1 and spins; unobserved k2/k3 retain opposite evanescent momenta; uniform transverse angular average in D-2 dimensions',
        'input_sha256': {str(p.resolve()): sha(p) for p in inputs},
        'script_sha256': sha(Path(__file__)),
        'singular_diagrams': [1, 8],
        'native_emission_and_axial_identity_residuals': ['0', '0'],
        'pair_lam_minus_2_coefficients': {key: str(value) for key, value in coefficients.items()},
        'lam_minus_4_and_minus_3_residuals': {key: list(map(str, value)) for key, value in high_poles.items()},
        'dimensional_Born': str(born),
        'normalization': 'b times unweighted real spin tensor / (2 times dimensional Born spin tensor), b=lam^2*m2; eq^2 gs^4 stripped from real and eq^2 gs^2 from Born',
        'kernel': str(kernel),
        'fixed_physical_daughter_operator_check': {'status': 'EXACT AFTER EXPLICIT CONVERSION', 'difference': str(residue), 'conversion': 'z=zc, CF=(SUNN^2-1)/(2 SUNN); identical angular average and dimensional spin convention'},
        'literal_Eq36_check': {'status': 'MISMATCH', 'difference': str(literal_difference)},
        'epsilon_expansion': str(s.series(kernel.subs(D, 4 - 2 * eps), eps, 0, 3)),
        'exclusion_of_other_pairs': 'The native denominator inventory leaves only diagrams 1 and 8 singular. The massless outgoing-emission Dirac identity and axial transversality remove their nominal lam^-2 amplitude numerator, so they scale at most lam^-1. All other amplitudes and their gauge denominators are analytic for 0<zc<1. Only the three singular/singular pairs can contribute to a lam^-2 squared-amplitude residue.',
        'unapplied_factors': 'Identical-gluon weight 1/2, second collinear region k1||k3, phase-space/flux factors, initial-state convolution and outgoing fragmentation convolution',
        'qualification': 'This is an exact component/family check of the actual real amplitude, not a general-kinematics full-tensor theorem or a complete renormalized-operator/finite-NLO matching proof. No finite 2 CF z counterterm is inserted.',
        'floating_point_used': False,
    }
    with args.output.open('x') as f:
        json.dump(result, f, indent=2)
        f.write('\n')
    print(json.dumps({'operator_difference': str(residue), 'literal_difference': str(literal_difference), 'kernel': str(kernel), 'output': str(args.output)}))


if __name__ == '__main__':
    main()
