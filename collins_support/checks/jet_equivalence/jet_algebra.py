#!/usr/bin/env python3
"""Focused, source-bound jet algebra audit. Requires SymPy 1.14.

This parses the selected Wolfram formula RHSs; it does not execute Wolfram,
regenerate amplitudes/masters, or certify a full native run. Paper expressions
are independently transcribed below, with equation numbers in each check.
"""
import argparse
import csv
import hashlib
import json
from pathlib import Path
import re
import sympy as sp
from sympy.parsing.mathematica import parse_mathematica

BASE = Path(__file__).resolve().parent
z, L, CF, CA, TF, beta0, D0, D1, dd = sp.symbols('z L CF CA TF beta0 D0 D1 dd')
eps, eta, B, V, g, Y, r, radial0 = sp.symbols('eps eta B V g Y r radial0')
rows = []


def record(name, residual, reference, kind='symbolic equality'):
    value = sp.simplify(sp.expand(residual))
    rows.append(dict(name=name, kind=kind, reference=reference,
                     residual=str(value), verdict='PASS' if value == 0 else 'FAIL'))
    return value

def parse(text):
    expr=parse_mathematica(text).subs(sp.Symbol('EulerGamma'), sp.EulerGamma)
    # SymPy's Mathematica parser leaves Gamma as an undefined function.
    return expr.replace(lambda n: n.is_Function and n.func.__name__ == 'Gamma',
                        lambda n: sp.gamma(*n.args))

def source(path):
    return (BASE / 'sources' / path).read_text()

def rhs(text, variable):
    text = re.sub(r'\(\*.*?\*\)', '', text, flags=re.S)
    found = re.findall(r'(?<![\w])' + re.escape(variable) + r'\s*=(.*?);', text, re.S)
    if len(found) != 1:
        raise ValueError((variable, 'ambiguous source assignment', len(found)))
    return found[0]

def canonical(expr):
    v = sp.expand(expr.replace(lambda n: n.is_Function and n.func.__name__ == 'delta1',
                               lambda n: n.args[0] * dd))
    c0, c1 = v.coeff(D0), v.coeff(D1)
    reg = v.subs({D0: 0, D1: 0, dd: 0})
    return dict(delta=v.coeff(dd), plus0=c0.subs(z, 1), plus1=c1.subs(z, 1),
                regular=sp.simplify(reg + (c0-c0.subs(z, 1))/(1-z)
                                   + (c1-c1.subs(z, 1))*sp.log(1-z)/(1-z)))

def ep_soft():
    text=source('collins_ep_analytic_SIDIS/common/ru_soft_assembly.wl')
    # Source formulas are parsed directly. Integral identities are transcribed
    # from the source's explicit Beta/Gamma construction, NOT from finite exports.
    # The normalized sphere N=exp(gamma_E eps)/Gamma(1-eps) is an ANALYTICAL
    # input here; its Kira/SubTropica computation is not rerun by this audit.
    symbol_map={'chain["eta_standard_regular"]':'ES',
                'chain["eta_global_regular"]':'EG',
                'chain["injet_rapidity_evaluated"]':'EJ',
                'chain["cone_log_evaluated"]':'EC',
                '(angularMellin/.eta->0)':'radial0'}
    def get(name):
        v=rhs(text,name)
        for old,new in symbol_map.items(): v=v.replace(old,new)
        return parse(v)
    # To first order in eta at fixed eps:
    # eta*Beta(eta/2,1-eta)=2+O(eta^2).
    # eta*globalSpecial=2/Gamma(1-eps)*(1-eta/(2eps))+O(eta^2).
    # d_eta log(radial)=-(psi(-eps)+psi(1+eps))/2.
    # The last derivative equals gamma_E-1/(2eps)+O(eps^2);
    # O(eps^2) times the simple radial pole is beyond finite order.
    common=get('common').subs(sp.Symbol('angularMellin'),
        radial0*(1+eta*(sp.EulerGamma-1/(2*eps))))
    factors={sp.Symbol('common'):common,
             sp.Symbol('ES'):sp.Integer(2),
             sp.Symbol('EG'):2/sp.gamma(1-eps)*(1-eta/(2*eps)),
             sp.Symbol('EJ'):sp.exp(eta*g/2)/eta,
             sp.Symbol('EC'):sp.exp(-eps*r)/eps}
    expressions={key:sp.simplify(get(key).subs(factors,simultaneous=True))
                 for key in ['std','glob','cone','cs']}
    eta_rows={}
    for key,value in expressions.items():
        regular=sp.simplify(eta*value)
        eta_rows[key]=sp.simplify(regular.subs(eta,0))/eta+\
                     sp.simplify(sp.diff(regular,eta).subs(eta,0))
    # N*Gamma(-eps)/Gamma(1+eps), through the order needed for two poles.
    radial_series=-1/eps*(1+2*sp.EulerGamma*eps+
                         (2*sp.EulerGamma**2-sp.pi**2/12)*eps**2)
    def laurent(expr):
        return sp.expand(sp.series(expr.subs(radial0,radial_series),eps,0,1).removeO())
    jet=laurent(eta_rows['cone'])
    standardhalf=laurent(eta_rows['std']/2)
    shifted=standardhalf.subs(V,V-g)
    record('ep/injet minus shifted standard-soft half',jet-shifted,
           '2311.00672v2 Eq.89')
    jet_finite=jet.coeff(eps,0).coeff(eta,0)
    expected=CF*(-B**2/2+B*(V-g)-sp.pi**2/12)
    record('ep/injet finite including constant',jet_finite-expected,
           '2311.00672v2 Eq.83; narrow-cone scale map')
    record('ep/standard half finite',standardhalf.coeff(eps,0).coeff(eta,0)
           -CF*(-B**2/2+B*V-sp.pi**2/12),'2311.00672v2 Eq.88')
    recoil=laurent(eta_rows['glob']+eta_rows['cs']-eta_rows['std']/2)
    record('ep/recoil rapidity residue',recoil.coeff(eta,-1),'2007.07281 Appendix A3')
    recoil_finite=recoil.coeff(eps,0)
    reference=CF*((2*Y+r)*B-r**2/2)
    record('ep/recoil finite',recoil_finite-reference,'2007.07281 Appendix A3')
    # RG coefficients below have alpha_s/(2pi) stripped. B and V both shift
    # by 2 d(log mu), while dV/d(log nu)=-2 and g is geometric.
    record('ep/injet mu anomalous dimension',
           2*(sp.diff(jet_finite,B)+sp.diff(jet_finite,V))-2*CF*(V-g),
           '2311.00672v2 Eq.86')
    record('ep/injet nu anomalous dimension',-2*sp.diff(jet_finite,V)+2*CF*B,
           '2311.00672v2 Eq.87')
    # A nonzero finite term is essential in each constituent even though the
    # ratio at the SAME shifted scale is one.
    return {'injet_Laurent':str(jet),'standard_half_Laurent':str(standardhalf),
            'injet_finite':str(jet_finite),'recoil_Laurent':str(recoil),
            'recoil_finite':str(recoil_finite),'extra_jet_remainder':str(sp.simplify(jet-shifted))}

