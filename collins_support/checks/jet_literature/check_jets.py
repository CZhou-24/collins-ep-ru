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


def jets():
    text = source('collins_sidis_highpt/common/jet_matching.wl')
    actual = {}
    for sector in [('U','q','q'), ('U','q','g'), ('U','g','q'), ('U','g','g'), ('T','q','q')]:
        prefix = 'HSJetMatching[' + ','.join('"'+x+'"' for x in sector) + ',z_,L_]:='
        actual['_'.join(sector)] = canonical(parse(text.split(prefix)[1].split(';')[0]))

    # arXiv:2311.00672v2, Eqs.114-121 and 126; alpha_s/(2*pi) stripped.
    # References below are in constant-coefficient plus-distribution form.
    # z is jet/parent momentum fraction, NOT the hadron-in-jet fraction z_h.
    log = sp.log(1-z)
    refs = {
      'U_q_q': dict(delta=CF*(-L**2/2+sp.pi**2/12), plus0=2*CF*L, plus1=-4*CF,
                    regular=CF*(-L*(1+z)+2*(1+z)*log-(1-z))),
      'U_q_g': dict(delta=0, plus0=0, plus1=0,
                    regular=CF*((L-2*log)*(2/z-2+z)-z)),
      'U_g_q': dict(delta=0, plus0=0, plus1=0,
                    regular=TF*((L-2*log)*(1-2*z+2*z**2)-2*z*(1-z))),
      'U_g_g': dict(delta=CA*(-L**2/2+sp.pi**2/12), plus0=2*CA*L, plus1=-4*CA,
                    regular=2*CA*L*(1/z-2+z-z**2)
                            -4*CA*(1/z-2+z-z**2)*log),
      'T_q_q': dict(delta=CF*(-L**2/2+sp.pi**2/12), plus0=2*CF*L, plus1=-4*CF,
                    regular=CF*(-2*L+4*log)),
    }
    equations = {'U_q_q':'114', 'U_q_g':'115', 'U_g_g':'116', 'U_g_q':'117', 'T_q_q':'126'}
    for key in refs:
        for part in refs[key]:
            record(key+'/'+part, actual[key][part]-refs[key][part],
                   '2311.00672v2 Eq.'+equations[key])

    # Check scale derivatives separately against the published anomalous
    # dimensions Eqs.130-133,138. mu*d/dmu = 2*d/dL at fixed coupling.
    splitting = {'U_q_q': CF*((1+z**2)*D0+sp.Rational(3,2)*dd),
                 'U_q_g': CF*(1+(1-z)**2)/z,
                 'U_g_q': TF*(z**2+(1-z)**2),
                 'U_g_g': 2*CA*(z*D0+(1-z)/z+z*(1-z))+beta0*dd/2,
                 'T_q_q': CF*(2*z*D0+sp.Rational(3,2)*dd)}
    gamma = dict(splitting)
    for key in ['U_q_q','T_q_q']:
        gamma[key] -= CF*(L+sp.Rational(3,2))*dd
    gamma['U_g_g'] -= (CA*L+beta0/2)*dd
    for key in refs:
        refgamma = canonical(2*gamma[key])
        for part in refs[key]:
            record(key+'/mu derivative/'+part,
                   2*sp.diff(actual[key][part],L)-refgamma[part],
                   '2311.00672v2 Eqs.130-133,138')

    # An independent action applies the numerator INSIDE the plus prescription.
    # Use phi=z^n (n>=1) so all g-initiated 1/z terms are integrable at z=0.
    # The code-side action is the canonical export; the paper-side action is
    # the original numerator-weighted distribution.
    raw = {
      'U_q_q': CF*dd*(-L**2/2-3*L/2+sp.pi**2/12)+L*splitting['U_q_q']
                   -2*CF*(1+z**2)*D1-CF*(1-z),
      'U_q_g': refs['U_q_g']['regular'],
      'U_g_q': refs['U_g_q']['regular'],
      'U_g_g': dd*(-CA*L**2/2-beta0*L/2+CA*sp.pi**2/12)+L*splitting['U_g_g']
                   -4*CA*(1-z+z**2)**2*D1/z,
      'T_q_q': L*splitting['T_q_q']+CF*(-4*z*D1+dd*(-3*L/2-L**2/2+sp.pi**2/12))}
    action_values = {}
    for key in raw:
        expr=sp.expand(raw[key]); f0=expr.coeff(D0); f1=expr.coeff(D1)
        freg=expr.subs({D0:0,D1:0,dd:0}); fd=expr.coeff(dd)
        c=actual[key]
        for n in [1,2,3]:
            phi=z**n
            paper_integrand=(f0*phi-f0.subs(z,1))/(1-z)\
                +(f1*phi-f1.subs(z,1))*sp.log(1-z)/(1-z)+freg*phi
            code_integrand=c['plus0']*(phi-1)/(1-z)\
                +c['plus1']*sp.log(1-z)*(phi-1)/(1-z)+c['regular']*phi
            residual=sp.simplify(code_integrand-paper_integrand)
            record(key+'/test action z^'+str(n), c['delta']-fd+
                   sp.integrate(residual,(z,0,1)), '2311.00672v2 Eqs.114-117,126',
                   'exact distribution action')
            # Retain the finite actual action as evidence, not only its residual.
            action_values[key+'/z^'+str(n)] = str(sp.simplify(c['delta']+
                sp.integrate(sp.expand(code_integrand),(z,0,1))))
    return actual, action_values


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


def archived_values(soft):
    data=json.loads((BASE/'archived_ep_values.json').read_text())
    def decode(x):
        if isinstance(x,int): return sp.Integer(x)
        if isinstance(x,str):
            if x=='pi':return sp.pi
            if re.fullmatch(r'-?\d+(/\d+)?',x):return sp.Rational(x)
            if re.fullmatch(r'[A-Za-z][A-Za-z0-9_]*',x):return sp.Symbol(x)
            raise ValueError(('unrecognized string',x))
        tag,*args=x; a=[decode(v) for v in args]
        if tag=='add':return sp.Add(*a)
        if tag=='mul':return sp.Mul(*a)
        if tag=='pow':return sp.Pow(*a)
        raise ValueError(('unsupported archived AST',tag))
    r3=data['r03'];r7=data['r07']
    parse_symbols={str(v):v for v in [B,V,g,CF,eps,eta,Y,r]}
    formulas={k:sp.sympify(v,locals=parse_symbols) for k,v in soft.items()}
    expected={'r03/measured_normalization':1-sp.pi**2*eps**2/12,
              'r03/soft_standard':2*formulas['standard_half_Laurent'].subs(B,sp.Symbol('Bq')),
              'r03/soft_injet':formulas['injet_Laurent'].subs(B,sp.Symbol('Bh')),
              'r03/recoil_soft_finite':formulas['recoil_finite'].subs(B,sp.Symbol('Bq')),
              'r03/jet_UU_bare_remainder':0,'r03/jet_UT_bare_remainder':0}
    for key,value in expected.items():
        record('archived/'+key,decode(r3[key]['value'])-value,
               data['run_id'],'archived value vs fresh symbolic calculation')
    for key,value in r7.items():
        record('archived/export/'+key,decode(value['record']['value']),
               data['run_id'],'archived final export; common zero remainder')
    return data['run_id']


def main():
    parser=argparse.ArgumentParser()
    parser.add_argument('--out',type=Path,required=True,help='New output directory under collins_support/reports/')
    args=parser.parse_args()
    if not args.out.resolve().is_relative_to(BASE.parents[1]/'reports'):
        parser.error('--out must be under collins_support/reports/')
    args.out.mkdir(parents=True,exist_ok=False)
    manifest=json.loads((BASE/'source_manifest.json').read_text())
    for row in manifest['files']:
        data=(BASE/'sources'/row['path']).read_bytes()
        if hashlib.sha256(data).hexdigest()!=row['sha256']:
            raise SystemExit('Changed audited source: '+row['path'])
    canonical_rows,actions=jets()
    soft=ep_soft()
    archive_run=archived_values(soft)
    # Check the actual ep product's expansion, including single allocation of
    # the jet remainder. This is a source-level check, not a native packet replay.
    text=source('collins_ep_analytic_SIDIS/common/ru_observable_helpers.wl')
    a,hard,softvar,jetU,jetT,HUU,HUT,f0,f1,ff0,ff1,h0,h1,C0,C1=sp.symbols(
        'a hard soft jetU jetT HUU HUT f0 f1 D0 D1 h0 h1 C0 C1')
    for label,expr,tree,one in [
        ('UU',parse(rhs(text,'uu')),HUU*f0*ff0,
         HUU*(f1*ff0+f0*ff1+f0*ff0*(hard+softvar+jetU))),
        ('UT',parse(rhs(text,'ut')),HUT*h0*C0,
         HUT*(h1*C0+h0*C1+h0*C0*(hard+softvar+jetT)))]:
        # Expand is understood by parse_mathematica; .expand also makes this explicit.
        for power,expected in [(0,tree),(1,one)]:
            record('ep/'+label+'/order '+str(power),sp.expand(expr).coeff(a,power)-expected,
                   'source product; 2007.07281 Eq.17 identified-hadron factorization')
    summary={'scope':'Source-formula algebra and selected archived values; no Wolfram/native rerun or finite-R certification',
             'commit':manifest['commit'],'sympy':sp.__version__,
             'archived_ep_run':archive_run,
             'checks':len(rows),'passed':sum(r['verdict']=='PASS' for r in rows),
             'failed':sum(r['verdict']=='FAIL' for r in rows),
             'soft':soft,'jet_canonical':{k:{p:str(v) for p,v in row.items()}
                                       for k,row in canonical_rows.items()},
             'distribution_actions':actions}
    (args.out/'summary.json').write_text(json.dumps(summary,indent=2)+'\n')
    with (args.out/'comparison.csv').open('w',newline='') as f:
        writer=csv.DictWriter(f,fieldnames=list(rows[0]));writer.writeheader();writer.writerows(rows)
    print(json.dumps({k:summary[k] for k in ['commit','checks','passed','failed','scope']},indent=2))
    for row in rows:
        if row['verdict']!='PASS':print(row)
    raise SystemExit(bool(summary['failed']))


if __name__=='__main__': main()
