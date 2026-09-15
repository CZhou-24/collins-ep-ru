"""Exact certificate arithmetic. Candidate strings are never evaluated."""
import re
import sympy as s
from ru_support import Blocked

def decode(tree):
    count=[0]
    def go(t,depth=0):
        count[0]+=1
        if count[0]>50000 or depth>80: raise ValueError('expression transport limit')
        if type(t) is int: return s.Integer(t)
        if type(t) is str:
            if t=='pi': return s.pi
            if re.fullmatch(r'-?\d+(?:/[1-9]\d*)?',t): return s.Rational(t)
            if re.fullmatch(r'[A-Za-z][A-Za-z0-9]{0,39}',t) and t not in ('nan','oo','Infinity','Indeterminate'):
                return s.Symbol(t)
            raise ValueError('unsupported atom')
        if type(t) is not list or not t or type(t[0]) is not str: raise ValueError('exact prefix expression required')
        op=t[0];a=[go(x,depth+1) for x in t[1:]]
        if op=='add' and a: return s.Add(*a)
        if op=='mul' and a: return s.Mul(*a)
        if op=='pow' and len(a)==2 and a[1].is_Rational and abs(a[1])<=32: return a[0]**a[1]
        if op=='log' and len(a)==1: return s.log(a[0])
        if op=='li2' and len(a)==1: return s.polylog(2,a[0])
        if op=='polylog' and len(a)==2 and a[0].is_Integer and 1<=a[0]<=8:return s.polylog(a[0],a[1])
        if op=='complex' and len(a)==2:return a[0]+s.I*a[1]
        if op=='zeta' and len(a)==1 and a[0].is_Integer and 2<=a[0]<=8: return s.zeta(a[0])
        raise ValueError('unsupported operator')
    x=go(tree)
    if x.has(s.nan,s.zoo,s.oo,-s.oo): raise ValueError('nonfinite exact expression')
    return x

def encode(x):
    if x==s.pi:return 'pi'
    if x==s.I:return ['complex',0,1]
    if x.is_Integer:return int(x)
    if x.is_Rational:return str(x)
    if x.is_Symbol:return str(x)
    ops={s.Add:'add',s.Mul:'mul',s.Pow:'pow',s.log:'log',s.zeta:'zeta'}
    if x.func==s.polylog and x.args[0]==2:return ['li2',encode(x.args[1])]
    if x.func==s.polylog:return ['polylog',int(x.args[0]),encode(x.args[1])]
    if x.func in ops:return [ops[x.func],*[encode(a) for a in x.args]]
    raise ValueError('cannot encode '+repr(x))

def equal(a,b):
    d=s.cancel(s.expand(a-b))
    return d==0 or s.simplify(d)==0

def truncate(x,eta_order,eps_order):
    if type(eta_order)!=int or type(eps_order)!=int or not 0<=eta_order<=4 or not 0<=eps_order<=4: raise ValueError('invalid series order')
    # Ordered subtraction convention: eta before epsilon.
    for name,order in [('eta',eta_order),('eps',eps_order)]:
        v=s.Symbol(name)
        if v in x.free_symbols:x=s.series(x,v,0,order+1).removeO().expand()
    return s.expand(x)

def evaluate_values(packet, known):
    vals=packet.get('values',{})
    if type(vals)!=dict: raise ValueError('values must be an object')
    pending=dict(vals);done={};recipes={}
    while pending:
        advanced=False
        for key,item in list(pending.items()):
            if type(key)!=str or '/' not in key or key in known: raise ValueError('nonunique value ID')
            if set(item)!={'constant','terms','eta_order','eps_order','value','sectors'}: raise ValueError('wrong value fields')
            terms=item['terms']
            if not isinstance(terms,list):raise ValueError('terms must be a list')
            if any(set(t)!={'ref','factor'} or type(t['ref'])!=str for t in terms):raise ValueError('invalid linear term')
            if len({t['ref'] for t in terms})!=len(terms):raise ValueError('duplicate linear reference')
            if not all(t['ref'] in known or t['ref'] in done for t in terms):continue
            x=decode(item['constant'])
            for t in terms:x+=decode(t['factor'])*(done.get(t['ref'],known.get(t['ref'])))
            x=truncate(x,item['eta_order'],item['eps_order'])
            if not equal(x,decode(item['value'])):raise ValueError('assembly/reduction certificate mismatch: '+key)
            done[key]=x;recipes[key]=item;del pending[key];advanced=True
        if not advanced:raise ValueError('cycle or missing reference in value graph: '+str(list(pending)[:3]))
    return done,recipes

def recompute(recipes,masters):
    out=dict(masters);pending=dict(recipes)
    while pending:
        advanced=False
        for key,r in list(pending.items()):
            if not all(t['ref'] in out for t in r['terms']):continue
            x=decode(r['constant'])+sum((decode(t['factor'])*out[t['ref']] for t in r['terms']),s.Integer(0))
            out[key]=truncate(x,r['eta_order'],r['eps_order']);del pending[key];advanced=True
        if not advanced:raise ValueError('unresolved recomputation graph')
    return out

def dependencies(key,recipes):
    if key not in recipes:return {key}
    out=set()
    for t in recipes[key]['terms']:
        if not equal(decode(t['factor']),s.Integer(0)):out |= dependencies(t['ref'],recipes)
    return out

def check_precision(recipes,master_orders):
    """Unknown higher epsilon terms may not be silently multiplied into a finite result."""
    eps=s.Symbol('eps');available=dict(master_orders)
    for key,r in recipes.items():
        for t in r['terms']:
            factor=decode(t['factor'])
            if equal(factor,s.Integer(0)):continue
            if t['ref'] not in available:raise ValueError('missing expansion-depth provenance')
            lead=factor.as_leading_term(eps);power=lead.as_powers_dict().get(eps,s.Integer(0))
            if not power.is_Integer:raise ValueError('unsupported fractional epsilon valuation')
            if available[t['ref']]+int(power)<r['eps_order']:raise ValueError('insufficient master/upstream epsilon depth: '+key)
        available[key]=r['eps_order']
    return available

def check_families(packet, real):
    families=packet.get('families')
    if not isinstance(families,list) or not families:raise ValueError('integral families required')
    ids=set();n=0
    for f in families:
        if not isinstance(f.get('id'),str) or not re.fullmatch('[A-Za-z][A-Za-z0-9]*',f['id']):raise ValueError('invalid Kira family name')
        if f['id'] in ids:raise ValueError('duplicate family')
        ids.add(f['id']);ds=[decode(x) for x in f['denominators']];cuts=f['cuts'];targets=f['targets']
        if not ds or len(ds)>32 or any(equal(d,s.Integer(0)) for d in ds):raise ValueError('invalid denominator basis')
        if len(set(cuts))!=len(cuts) or any(type(c)!=int or c<0 or c>=len(ds) for c in cuts):raise ValueError('invalid cut indices')
        if bool(cuts)!=real:raise ValueError('real families need cuts; virtual families must be uncut')
        if real and (f.get('positive_energy') is not True or not f.get('support_artifact')):raise ValueError('positive-energy support missing')
        if not targets:raise ValueError('no reduction targets')
        for t in targets:
            powers=t['powers']
            if len(powers)!=len(ds) or any(type(x)!=int or abs(x)>16 for x in powers):raise ValueError('wrong target powers')
            if any(powers[c]<=0 for c in cuts):raise ValueError('physical cut removed from a reduction target')
            lhs=decode(t['integrand']);rhs=decode(t['numerator'])
            for d,p in zip(ds,powers):rhs*=d**(-p)
            if not equal(lhs,rhs):raise ValueError('rational integrand reconstruction failed')
            n+=1
    return n

def check_cut_rule():
    # Exact convention for a unit-power cut: 1/(x-i0)-1/(x+i0)
    # divided by 2*pi*i, with the positive-energy theta kept separately.
    # The finite-width difference is the normalized Lorentzian distribution.
    x,d=s.symbols('x d',real=True,positive=True)
    lhs=(1/(x-s.I*d)-1/(x+s.I*d))/(2*s.pi*s.I)
    return equal(lhs,d/(s.pi*(x*x+d*d)))
