#!/usr/bin/env python3
"""Exact scalar momentum-conservation simplification of an exported open tensor.

This reads a native export. It is an algebra check, not another amplitude derivation.
"""
import argparse
import ast
import hashlib
import json
import re
from pathlib import Path

import sympy as sp
from sympy.printing.mathematica import mathematica_code


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--input', type=Path, required=True)
    ap.add_argument('--output', type=Path, required=True)
    args = ap.parse_args()
    args.output.mkdir(parents=True, exist_ok=False)
    text = args.input.read_text()
    raw = re.split(r'"original"\s*->', text, maxsplit=1)[1]
    raw = re.split(r',\s*"symmetric"\s*->', raw, maxsplit=1)[0]
    # This exporter row is a rational scalar expression, not general Wolfram
    # code. Refuse calls, attributes, strings and inexact numeric literals.
    rational_text = ' '.join(raw.split()).replace('^', '**')
    tree = ast.parse(rational_text, mode='eval')
    allowed = (ast.Expression, ast.BinOp, ast.UnaryOp, ast.Add, ast.Sub,
               ast.Mult, ast.Div, ast.Pow, ast.USub, ast.UAdd, ast.Name,
               ast.Load, ast.Constant)
    if any(not isinstance(node, allowed) for node in ast.walk(tree)):
        raise ValueError('Export is not a rational scalar expression')
    if any(isinstance(node, ast.Constant) and type(node.value) is not int for node in ast.walk(tree)):
        raise ValueError('Only exact integer numeric literals are allowed')
    names = {node.id for node in ast.walk(tree) if isinstance(node, ast.Name)}
    local = {name: (sp.I if name == 'I' else sp.Symbol(name)) for name in names}
    print('PARSE_RATIONAL', len(raw), flush=True)
    def exact(node):
        if isinstance(node, ast.Name):
            return local[node.id]
        if isinstance(node, ast.Constant):
            return sp.Integer(node.value)
        if isinstance(node, ast.UnaryOp):
            return (-1 if isinstance(node.op, ast.USub) else 1) * exact(node.operand)
        if isinstance(node.op, (ast.Add, ast.Sub)):
            # Flatten the long printed sum before constructing a SymPy Add.
            pending, terms = [(node, 1)], []
            while pending:
                term, sign = pending.pop()
                if isinstance(term, ast.BinOp) and isinstance(term.op, (ast.Add, ast.Sub)):
                    pending.extend([(term.left, sign), (term.right, -sign if isinstance(term.op, ast.Sub) else sign)])
                else:
                    terms.append(sign * exact(term))
            return sp.Add(*terms)
        left, right = exact(node.left), exact(node.right)
        if isinstance(node.op, ast.Mult):
            return left * right
        if isinstance(node.op, ast.Div):
            return left / right
        if isinstance(node.op, ast.Pow):
            return left ** right
        raise ValueError('Unsupported rational operator')
    expression = exact(tree.body)
    def dot(i, j):
        if (i, j) in {(1, 6), (3, 7)}:
            return sp.Integer(0)
        return sp.Symbol(f'hsDot{i}x{j}')
    rules = {dot(5, j): dot(1, j) + dot(2, j) - dot(3, j) - dot(4, j) for j in range(6, 10)}
    print('EXACT_CONSERVATION_SUBSTITUTION', flush=True)
    numerator, denominator = expression.as_numer_denom()
    if any(denominator.has(symbol) for symbol in rules):
        raise ValueError('Unexpected projector-dependent denominator')
    substituted = numerator.xreplace(rules)
    expanded = sp.expand(substituted)
    conserved = expanded / denominator
    residual = sp.expand(substituted - expanded)
    if residual != 0:
        raise ValueError('Conserved expression does not reconstruct')
    (args.output / 'conserved.wl').write_text(mathematica_code(conserved) + '\n')
    summary = dict(source=str(args.input.resolve()), source_sha256=hashlib.sha256(args.input.read_bytes()).hexdigest(),
                   driver_sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
                   rules={str(k): str(v) for k, v in rules.items()}, residual=str(residual),
                   original_operations=sp.count_ops(expression), conserved_operations=sp.count_ops(conserved),
                   qualification='Momentum conservation k3=p+q-k1-k2 with physical tagged spins p.Sin=k1.Sout=0. Exact simplification of a native tensor, not a new trace.')
    (args.output / 'summary.json').write_text(json.dumps(summary, indent=2, default=int) + '\n')
    print(json.dumps(summary, default=int))


if __name__ == '__main__':
    main()
