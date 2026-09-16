#!/usr/bin/env python3
"""Independent scalar recheck of native collinear exports; no finite NLO claim."""
import argparse
import hashlib
import json
from pathlib import Path
import sympy as s
from sympy.parsing.mathematica import parse_mathematica


def field(text, name, next_name):
    start = text.index('"' + name + '" ->') + len(name) + 5
    end = text.index('"' + next_name + '" ->', start)
    return parse_mathematica(text[start:end].strip().rstrip(',').strip())


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--embedding', type=Path, required=True)
    ap.add_argument('--output', type=Path, required=True)
    args = ap.parse_args()
    source = args.embedding.resolve()
    text = source.read_text()
    ndr = field(text, 'NDR', 'BMHV')
    bmhv = field(text, 'BMHV', 'BMHV_minus_NDR')
    raw_ndr = field(text, 'NDR_unaveraged', 'BMHV_unaveraged')
    raw_bmhv = field(text, 'BMHV_unaveraged', 'NDR')
    gram = s.Matrix(field(text, 'gramD', 'hat_squared'))
    D, CF, z, m2, aa, bb, eps = s.symbols('D CF z m2 aa bb eps')
    literal = 2 * CF * z / (1 - z)
    radial = m2 * (1 - z) / z
    average = {aa**2: radial / (D - 2), bb**2: radial / (D - 2)}
    residuals = {
        'NDR_angular_average': s.factor(raw_ndr.subs(average) - ndr),
        'BMHV_angular_average': s.factor(raw_bmhv.subs(average) - bmhv),
        'physical_daughter_BMHV_minus_NDR': s.factor(bmhv - ndr),
        'daughter_spin_orthogonality': gram[1, 4],
        'parent_projected_spin_orthogonality': s.factor(gram[3, 4] - aa * gram[3, 0]),
        'projected_spin_norm': s.factor(gram[4, 4] - 2 * aa * gram[4, 0] + aa**2 * gram[0, 0] + 1),
    }
    for i in range(5):
        residuals[f'momentum_conservation_gram_{i}'] = s.factor(gram[i, 3] - gram[i, 1] - gram[i, 2])
    if any(value != 0 for value in residuals.values()):
        raise ValueError(residuals)
    difference = s.factor(ndr - literal)
    epsilon_difference = s.factor(difference.subs(D, 4 - 2 * eps))
    action_rows = []
    for n in range(3):
        # Integral_0^1 z^n (1-z)^(1-eps) dz, using the integer-n beta recurrence.
        beta_action = s.factorial(n) / s.prod(k - eps for k in range(2, n + 3))
        action = -CF * eps * beta_action / (1 - eps)
        finite = s.limit(action, eps, 0)
        assert finite == 0
        action_rows.append(dict(test_function=f'z^{n}', regulated_action=str(action), finite_coefficient=str(finite)))
    root = Path(__file__).resolve().parents[3]
    ref = root / 'collins_sidis_highpt/references/transversity_operator_snippets.json'
    pinned = json.loads(ref.read_text())
    result = {
        'scope': 'Native fixed-physical-daughter collinear trace, independently checked scalar algebra only',
        'input': str(source), 'input_sha256': hashlib.sha256(source.read_bytes()).hexdigest(),
        'script_sha256': hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
        'reference_metadata_sha256': hashlib.sha256(ref.read_bytes()).hexdigest(),
        'literal_reference_latex': pinned['snippets']['losplitd']['latex'],
        'literal_reference_location': 'hep-ph/9706511v2 Eq. (36), x<1; explicit map x=z',
        'reference_source_sha256': pinned['source_sha256'],
        'assumptions': 'm2>0, 0<z<1, D=4-2 eps; uniform transverse sphere of dimension D-2; spin vectors physical',
        'symbolic_residuals': {key: str(value) for key, value in residuals.items()},
        'all_D_literal_comparison': {'status': 'MISMATCH', 'difference': str(difference)},
        'epsilon_difference': str(epsilon_difference),
        'through_epsilon_1_residual': str(s.series(epsilon_difference, eps, 0, 2).removeO()),
        'simple_pole_finite_coefficient': str(s.limit(-epsilon_difference / eps, eps, 0)),
        'double_pole_finite_coefficient': str(s.limit(epsilon_difference / eps**2, eps, 0)),
        'independent_test_function_actions': action_rows,
        'measure_note': 'For a simple unresolved virtuality integral, integral_0^B dt t^(-1-eps)=-B^(-eps)/eps. The displayed monomial actions include an additional (1-z)^(-eps) endpoint weight. No process phase-space normalization is inferred.',
        'qualification': 'The regular epsilon-squared difference gives no finite term with this simple pole. A double pole would give a nonzero finite term. This is not proof that the assembled process has only a simple pole, nor a derivation of the fragmentation operator finite conversion.',
        'floating_point_used': False,
    }
    with args.output.open('x') as f:
        json.dump(result, f, indent=2)
        f.write('\n')
    print(json.dumps({'exact_scalar_checks': len(residuals), 'retained_literal_mismatches': 1, 'test_function_actions': len(action_rows), 'output': str(args.output)}))


if __name__ == '__main__':
    main()
