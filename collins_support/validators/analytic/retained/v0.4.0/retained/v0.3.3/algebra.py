"""Bounded AST arithmetic and exact polynomial identities for the new checks.

This imports the retained AST parser, not candidate code. No eval/exec is used.
"""
from fractions import Fraction
import math
from oracle import _validate_tree, _evaluate

SYMBOLS = set('CF TR pi Bq Bh V Y r g LQ LJ Tq T0 z eps kappa HUU HUT hard1 soft1 f0 f1 d0 d1 t0 t1 c0 c1 J1'.split())

def rat(n, d=1):
    x = Fraction(n, d)
    return {'op': 'rat', 'num': x.numerator, 'den': x.denominator}

def sym(name): return {'op': 'sym', 'name': name}
def coerce(x): return x if isinstance(x, dict) else rat(x)
def add(*xs):
    return {'op': 'add', 'args': [coerce(x) for x in xs]} if len(xs)>1 else coerce(xs[0])
def mul(*xs):
    return {'op': 'mul', 'args': [coerce(x) for x in xs]} if len(xs)>1 else coerce(xs[0])
def power(x, n): return {'op': 'pow', 'base': coerce(x), 'exp': n}
def sub(x, y): return add(x, mul(-1, y))

def validate(x, allowed=SYMBOLS): _validate_tree(x, allowed)
def value(x, point, wrt=None):
    validate(x)
    return _evaluate(x, point, wrt)

def _sum(a,b):
    out=dict(a)
    for k,v in b.items():
        out[k]=out.get(k,Fraction(0))+v
        if not out[k]: del out[k]
    if len(out)>4096: raise ValueError('Polynomial term budget exceeded')
    return out

def _product(a,b):
    out={}
    if len(a)*len(b)>100000: raise ValueError('Polynomial product budget exceeded')
    for ka,va in a.items():
        for kb,vb in b.items():
            powers=dict(ka)
            for s,n in kb: powers[s]=powers.get(s,0)+n
            if sum(powers.values())>32: raise ValueError('Polynomial degree exceeded')
            key=tuple(sorted(powers.items()))
            out[key]=out.get(key,Fraction(0))+va*vb
    return {k:v for k,v in out.items() if v}

def polynomial(x):
    validate(x)
    def walk(t):
        op=t['op']
        if op=='rat':
            v=Fraction(t['num'],t['den']);return {():v} if v else {}
        if op=='sym':return {((t['name'],1),):Fraction(1)}
        if op in ('add','mul'):
            out={} if op=='add' else {():Fraction(1)}
            for c in t['args']:out=(_sum if op=='add' else _product)(out,walk(c))
            return out
        if t['exp']<0: raise ValueError('Negative power in exact polynomial packet')
        out={():Fraction(1)};base=walk(t['base'])
        for _ in range(t['exp']):out=_product(out,base)
        return out
    return walk(x)

def equal(a,b): return polynomial(a)==polynomial(b)

def laurent(x):
    if type(x) is not dict or not x or len(x)>20: raise ValueError('Invalid Laurent packet')
    out={}
    for key,expr in x.items():
        if not isinstance(key,str):raise ValueError('Invalid regulator index')
        try: e,h=map(int,key.split(','))
        except Exception as exc: raise ValueError('Expected eps_power,eta_power') from exc
        if key!=f'{e},{h}' or not -2<=e<=2 or h not in (-1,0):raise ValueError('Unsupported regulator powers')
        # Coefficients cannot conceal regulators.
        validate(expr,SYMBOLS-{'eps'})
        p=polynomial(expr)
        if p:out[(e,h)]=p
    return out

def laurent_equal(a,b):return laurent(a)==laurent(b)

def combination(*terms):
    """Exact sparse sum of (rational multiplier, Laurent packet) pairs."""
    out={}
    for coefficient,packet in terms:
        for key,p in laurent(packet).items():
            out[key]=_sum(out.get(key,{}),{k:Fraction(coefficient)*v for k,v in p.items()})
            if not out[key]:del out[key]
    return out

def distribution(x):
    if type(x) is not dict or set(x)!={'delta','regular','plus'}:raise ValueError('Wrong distribution schema')
    validate(x['delta']);validate(x['regular'])
    if type(x['plus']) is not list or len(x['plus'])>4:raise ValueError('Wrong plus terms')
    seen=set()
    for term in x['plus']:
        if type(term) is not dict or set(term)!={'n','numerator'} or type(term['n']) is not int or not 0<=term['n']<=2 or term['n'] in seen:
            raise ValueError('Wrong/duplicate plus order')
        seen.add(term['n']);validate(term['numerator'])
    return x

def finite(x):return type(x) in (int,float) and math.isfinite(x)

def check(name, actual, expected, tol=2e-9):
    if not finite(actual) or not finite(expected):raise ValueError('Nonfinite/non-numeric scalar: '+name)
    tolerance=tol*max(1.,abs(expected))
    return {'id':name,'status':'PASS' if abs(actual-expected)<=tolerance else 'FAIL',
            'actual':actual,'expected':expected,'tolerance':tolerance}

def assertion(name,condition,detail=''):
    return {'id':name,'status':'PASS' if condition else 'FAIL','detail':detail}
