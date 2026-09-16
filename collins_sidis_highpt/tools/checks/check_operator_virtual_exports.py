#!/usr/bin/env python3
"""Independent exact scalar averaging of the executed operator trace export."""
import argparse
import hashlib
import json
import re
from pathlib import Path
import sympy as s
from check_collinear_exports import field


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--input', type=Path, required=True)
    ap.add_argument('--output', type=Path, required=True)
    args = ap.parse_args()
    if args.output.exists():
        ap.error('Choose an unused output file')
    text = args.input.read_text()
    names = ['Born', 'vertex', 'Wilson_left', 'Wilson_right', 'UV_angular_vertex']
    values = {}
    for scheme in ['BMHV', 'NDR']:
        block = re.search(r'"'+scheme+r'"\s*->\s*<\|(.*?)\|>', text, re.S)
        if not block:
            raise ValueError('Missing actual native scheme export: '+scheme)
        # SymPy reserves the name ln as its logarithm function. Rename the
        # scalar dot-product token for parsing, then restore the symbol.
        source = re.sub(r'\bln\b','loopNDot',block.group(1))+', "END" -> 0'
        values[scheme] = {name:field(source,name,next_name).xreplace({s.Symbol('loopNDot'):s.Symbol('ln')})
                         for name,next_name in zip(names,names[1:]+['END'])}
    D,l2,lp,ln,ls,lhat = s.symbols('D l2 lp ln ls lhat')
    transverse = l2-2*lp*ln
    raw = {key:s.factor(values['BMHV'][key]-values['NDR'][key]) for key in names}
    averaged = {key:s.factor(value.subs({ls**2:-transverse/(D-2),
                         lhat:(D-4)*transverse/(D-2)})) for key,value in raw.items()}
    if any(value != 0 for value in averaged.values()):
        raise ValueError('Nonzero operator difference after physical averaging: '+str(averaged))
    result = dict(
        scope='Scalar cross-check of freshly executed virtual operator Dirac numerators',
        input=str(args.input.resolve()),
        input_sha256=hashlib.sha256(args.input.read_bytes()).hexdigest(),
        source_sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
        scalar_parser_source_sha256=hashlib.sha256(Path(__file__).with_name('check_collinear_exports.py').read_bytes()).hexdigest(),
        sympy_version=s.__version__,
        parser_conversion='Scalar token ln is temporarily renamed loopNDot to avoid the SymPy logarithm alias, then restored as Symbol(ln).',
        native_values={scheme:{key:str(value) for key,value in row.items()}
                       for scheme,row in values.items()},
        unaveraged_differences={key:str(value) for key,value in raw.items()},
        averaged_differences={key:str(value) for key,value in averaged.items()},
        angular_definition='Uniform D-2 space transverse to lightlike p,n; p.n=1. Physical S^2=-1 and the evanescent subspace has dimension D-4.',
        denominator_condition='A common scalar denominator/regulator depending on l2, lp, ln is independent of this transverse orientation.',
        implication='The zero averaged numerator difference persists under a common azimuth-invariant UV/IR regulator; no numerical approximation is used.',
        qualification='Independent scalar averaging, not an independent Dirac calculation. Real endpoint and complete production operator/jet matching remain separate.')
    args.output.write_text(json.dumps(result,indent=2)+'\n')
    print('OPERATOR_VIRTUAL_SCALAR_EXACT',len(averaged))


if __name__ == '__main__':
    main()
