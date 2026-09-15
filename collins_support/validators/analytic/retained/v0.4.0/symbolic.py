"""Restricted exact-expression transport. No eval/sympify on candidate text."""
import re
import sympy as s

NAMES = ('u v zh z z1 z2 CF CA TR nf L B Bq T LJ Y r eps eta '
         'HUU HUT f0 f1 h0 h1 D0 D1 C0 C1 HF0 HF1 HFend HFderiv '
         'U0 U1 N0 N1 kH kB kF kS lam').split()
SYMBOLS = {n: s.Symbol(n) for n in NAMES}
SYMBOLS['pi'] = s.pi
MAX_NODES = 50000

def decode(tree):
    count = [0]
    def visit(t, depth=0):
        count[0] += 1
        if count[0] > MAX_NODES or depth > 100:
            raise ValueError('expression exceeds transport limits')
        if type(t) is int:
            return s.Integer(t)
        if type(t) is str:
            if t in SYMBOLS:
                return SYMBOLS[t]
            if re.fullmatch(r'-?\d+(?:/[1-9]\d*)?', t):
                a, _, b = t.partition('/')
                return s.Rational(int(a), int(b or 1))
            raise ValueError('unknown expression atom: ' + t[:80])
        if type(t) is not list or not t or type(t[0]) is not str:
            raise ValueError('use integer/rational/symbol/prefix-list expressions')
        op, args = t[0], [visit(x, depth+1) for x in t[1:]]
        if op == 'add' and args: return s.Add(*args)
        if op == 'mul' and args: return s.Mul(*args)
        if op == 'pow' and len(args) == 2 and args[1].is_Rational:
            if abs(args[1]) > 20: raise ValueError('power exceeds transport limit')
            return args[0] ** args[1]
        if op == 'log' and len(args) == 1: return s.log(args[0])
        if op == 'li2' and len(args) == 1: return s.polylog(2,args[0])
        if op == 'zeta' and len(args) == 1 and args[0] in (2,3,4): return s.zeta(args[0])
        raise ValueError('unsupported expression operation: '+op)
    result=visit(tree)
    if result.has(s.nan,s.zoo,s.oo,-s.oo): raise ValueError('nonfinite expression')
    return result

def encode(x):
    x=s.sympify(x)  # trusted SymPy objects only, never candidate strings
    if x==s.pi:return 'pi'
    if x.is_Integer:return int(x)
    if x.is_Rational:return str(x)
    if x.is_Symbol:
        if str(x) not in SYMBOLS: raise ValueError('unknown symbol '+str(x))
        return str(x)
    if x.is_Add:return ['add',*[encode(a) for a in x.args]]
    if x.is_Mul:return ['mul',*[encode(a) for a in x.args]]
    if x.is_Pow:return ['pow',*[encode(a) for a in x.args]]
    if x.func==s.log:return ['log',encode(x.args[0])]
    if x.func==s.polylog and x.args[0]==2:return ['li2',encode(x.args[1])]
    if x.func==s.zeta:return ['zeta',encode(x.args[0])]
    raise ValueError('unsupported export '+repr(x))

def zero(x):
    return s.cancel(s.expand(x)) == 0 or s.simplify(x) == 0

PARTS=('regular','delta','D0','D1')
def distribution(obj):
    if type(obj) is not dict or set(obj)!=set(PARTS):
        raise ValueError('distribution needs regular, delta, D0, D1 exactly')
    result={k:decode(obj[k]) for k in PARTS}
    if any(SYMBOLS['u'] in result[k].free_symbols for k in ('delta','D0','D1')):
        raise ValueError('endpoint coefficients must be independent of u; reduce numerator plus distributions first')
    return result

def plus_action(part, test, lo=s.Rational(0)):
    """Definition of 1, delta(1-u), [1/(1-u)]+, [ln(1-u)/(1-u)]+."""
    u=SYMBOLS['u']; endpoint=test.subs(u,1)
    if part=='regular': return s.integrate(test,(u,lo,1))
    if part=='delta':return endpoint
    integrand=s.cancel((test-endpoint)/(1-u))
    if part=='D0':return s.integrate(integrand,(u,lo,1))+endpoint*s.log(1-lo)
    if part=='D1':
        t=s.Dummy('one_minus_u',positive=True)
        return s.integrate(s.expand(integrand.subs(u,1-t))*s.log(t),(t,0,1-lo))+endpoint*s.log(1-lo)**2/2
    raise ValueError(part)
