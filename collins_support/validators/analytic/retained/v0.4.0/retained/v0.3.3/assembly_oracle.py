"""Exact coefficient, distribution-action and fresh evaluation checks.

No fitted inputs and no candidate numerical routine is used for references.
The numerical v0.3.0 suite remains a separate unchanged regression gate.
"""
import math, random
from fractions import Fraction
from algebra import *
from assembly_reference import references
from soft_oracle import integrate
import real_oracle

CONVENTIONS={'process':'e_unpolarized+p_transverse->e+jet(h)+X',
    'approximation':'leading_power_narrow_jet_azimuth_averaged',
    'axis':'anti_kt_standard_E_scheme','expansion':'a=alpha_s/(2*pi);coefficients_through_a^1',
    'regulator':'eta_before_eps;JHEP11(2021)005_nu_convention',
    'TMD_inputs':'external_renormalized_operators;no_small_b_finite_OPE_certification',
    'plus':'numerator_times_[ln^n(1-z)/(1-z)]_plus_on_[0,1]',
    'gamma_mu':'d/dln(mu^2)','gamma_CS':'d/dln(sqrt(zeta))'}

def packet(kind,data):return {'schema':'collins-ep-'+kind+'/v2','conventions':dict(CONVENTIONS),**data}

def validate_packet(p,kind,keys):
    if type(p) is not dict or set(p)!={'schema','conventions',*keys} or p['schema']!='collins-ep-'+kind+'/v2' or p['conventions']!=CONVENTIONS:
        raise ValueError('Wrong '+kind+' packet schema/conventions')

def point(rng):
    p={k:rng.uniform(-2,2) for k in sorted(SYMBOLS-{'pi','z','eps','kappa'})}
    p.update(CF=rng.choice([.75,4/3,2.4]),TR=.5,z=rng.uniform(.03,.96),eps=rng.uniform(-.18,.12),kappa=rng.uniform(.4,2.3))
    return p

def _keys(actual,reference,name):
    if type(actual) is not dict or set(actual)!=set(reference):raise ValueError('Wrong component set: '+name)

def coefficients(radiation,operators,assembly,seed):
    r,o,a,extra=references();out=[];rng=random.Random(f'assembly-algebra:{seed}')
    validate_packet(radiation,'radiation',set(r));validate_packet(operators,'operators',set(o))
    validate_packet(assembly,'assembly',{'expressions'});_keys(assembly['expressions'],a,'assembly')
    for category in ('soft_bare',):
        _keys(radiation[category],r[category],category)
        for key,ref in r[category].items():out.append(assertion(category+'.'+key,laurent_equal(radiation[category][key],ref)))
    out.append(assertion('jet.bare',laurent_equal(radiation['jet_bare'],r['jet_bare'])))
    for category in ('collinear_uv','counterterms','renormalized','anomalous'):
        _keys(operators[category],o[category],category)
        for key,ref in o[category].items():
            test=laurent_equal if category in ('collinear_uv','counterterms') else equal
            out.append(assertion(category+'.'+key,test(operators[category][key],ref)))
    for key,ref in a.items():out.append(assertion('assembly.polynomial.'+key,equal(assembly['expressions'][key],ref)))
    _keys(radiation['raw_splitting'],r['raw_splitting'],'raw_splitting')
    for i in range(14):
        p=point(rng)
        for key,ref in r['raw_splitting'].items():
            out.append(check(f'raw_splitting.{key}.{i}',value(radiation['raw_splitting'][key],p)[0],value(ref,p)[0]))
    _keys(radiation['splitting'],r['splitting'],'splitting');_keys(radiation['endpoint'],r['endpoint'],'endpoint')
    for group in ('splitting','endpoint'):
        for key,ref in r[group].items():
            d=distribution(radiation[group][key])
            # Compare the distributions through actions, including nonconstant weights.
            for n in range(1,7):
                p=point(rng)
                phi=[rng.uniform(-1,1) for _ in range(n+1)]
                x=.08+.08*n if group=='splitting' and key=='gq' else 0.
                got=action(d,phi,p,x,64);want=action(ref,phi,p,x,96)
                out.append(check(f'distribution.{group}.{key}.{n}',got,want,3e-7))
    sb=radiation['soft_bare'];ct=operators['counterterms']
    combined=combination((1,sb['global']),(1,sb['cs_out']),(Fraction(-1,2),sb['standard']),(1,ct['soft']))
    out.append(assertion('subtraction.residual_soft_exact',combined=={(0,0):polynomial(operators['renormalized']['soft'])}))
    j=combination((1,radiation['jet_bare']),(1,ct['jet']))
    out.append(assertion('subtraction.inclusive_jet_exact',j=={(0,0):polynomial(operators['renormalized']['jet'])}))
    for channel in ('beam_UU','beam_UT','fragment_UU','fragment_Collins'):
        beam=channel.startswith('beam');soft=extra['half_q'] if beam else sb['injet']
        # Check singular cancellation. Finite collinear matrix elements remain TMD inputs.
        c=combination((1,operators['collinear_uv'][channel]),(1,soft),(1,ct['beam' if beam else 'fragment']))
        out.append(assertion('subtraction.operator_poles.'+channel,not any(e<0 or h<0 for e,h in c)))
    for i in range(12):
        p=physical_point(rng)
        gam=operators['anomalous']
        for channel in ('UU','UT'):
            keys=['hard','beam_'+channel,'fragment_'+('UU' if channel=='UU' else 'Collins'),'soft']
            total=math.fsum(value(gam[k],p)[0] for k in keys)
            out.append(check(f'RGE.assembled.{channel}.{i}',total,0,2e-10))
        ds=value(operators['renormalized']['soft'],p,'Bq')[1]
        out.append(check(f'RGE.soft_derivative.{i}',ds,value(gam['soft'],p)[0],2e-10))
        for B,T,k in [('Bq','Tq','beam'),('Bh','T0','fragment')]:
            lhs=value(gam['CS_'+k],p,B)[1]
            rhs=-2*value(gam['beam_UU' if k=='beam' else 'fragment_UU'],p,T)[1]
            out.append(check(f'RGE.CS_integrability.{k}.{i}',lhs,rhs,2e-10))
    return out

def poly_eval(cs,z):
    out=0.
    for c in reversed(cs):out=out*z+c
    return out

def action(d,phi,p,x=0.,n=80):
    """Integral on [x,1] of a distribution times polynomial phi.

    Numerator is inside the subtraction: (N(z)phi(z)-N(1)phi(1))/(1-z).
    The interval [0,x] is accounted for by its analytic boundary term.
    """
    distribution(d)
    def ev(tree,z):return value(tree,dict(p,z=z))[0]
    result=ev(d['delta'],1.)*sum(phi)
    # t substitution clusters nodes near the logarithmic endpoint.
    result+=integrate(lambda z:ev(d['regular'],z)*poly_eval(phi,z),x,1.,n)
    for term in d['plus']:
        N=term['numerator'];order=term['n'];end=ev(N,1.)*sum(phi)
        def f(t):
            q=(1-x)*t*t;z=1-q
            return 2*math.log(q)**order*(ev(N,z)*poly_eval(phi,z)-end)/t
        # Four panels improve endpoint log convergence without copying candidate integration.
        val=sum(integrate(f,a,b,n) for a,b in [(0.,.03),(.03,.15),(.15,.5),(.5,1.)])
        result+=val+end*math.log(1-x)**(order+1)/(order+1)
    return result

def physical_point(rng):
    mu=10**rng.uniform(.3,1.2);Q2=10**rng.uniform(1.4,2.8);pT=10**rng.uniform(.6,1.4)
    Y=rng.uniform(-1.7,1.7);R=rng.uniform(.12,.48);bq=rng.uniform(.2,1.8);bh=rng.uniform(.2,1.8);nu=mu*rng.uniform(.6,2.2)
    c0=2*math.exp(-0.5772156649015329)
    zp=Q2*Q2*math.exp(2*Y)/(pT*pT);z0=4*pT*pT*math.cosh(Y)**2;zj=pT*pT*R*R
    return dict(mu=mu,Q2=Q2,pT=pT,Y=Y,R=R,bq=bq,bh=bh,nu=nu,CF=4/3,TR=.5,
        Bq=math.log(mu*mu*bq*bq/c0**2),Bh=math.log(mu*mu*bh*bh/c0**2),V=math.log(mu*mu/(nu*nu)),
        r=math.log(R*R),g=math.log(R*R/(4*math.cosh(Y)**2)),LQ=math.log(mu*mu/Q2),
        LJ=math.log(mu*mu/zj),Tq=math.log(mu*mu/zp),T0=math.log(mu*mu/z0),z=.4,eps=-.1,kappa=1.3)

def radial_difference(eps,A,B,n=60):
    if not 0<eps<.7 or not 0<A or not 0<B:raise ValueError('Radial primitive domain')
    # t=exp(v); the small-t tail is bounded and added to first order.
    low=-55.;high=5.
    def f(v):
        t=math.exp(v)
        return math.exp(-eps*v)*math.exp(-min(A,B)*t)*(-math.expm1(-abs(B-A)*t))*(1 if B>A else -1)
    val=sum(integrate(f,low+i*5,low+(i+1)*5,n) for i in range(12))
    return val+(B-A)*math.exp((1-eps)*low)/(1-eps)

def gaussian_integrals(q,A,mu):
    """Independent convergent power-series moments, not Hankel quadrature."""
    w=q*q/(4*A);c0=2*math.exp(-0.5772156649015329);h=0.;term=1.;total=0.
    const=math.log(mu*mu/(A*c0*c0))-0.5772156649015329
    for n in range(100):
        if n:term*=-w/n;h+=1/n
        total+=term*(h+const)
        if n>20 and abs(term)*(abs(h+const)+1)<1e-16:break
    else:raise ValueError('Gaussian reference series failed to converge')
    return math.exp(-w)/(4*math.pi*A),total/(4*math.pi*A)

def gaussian_expected(r):
    cf=r['CF'];L=math.log(r['mu']**2/r['Q2']);rr=math.log(r['R']**2)
    hard=cf*(-L*L-3*L-8+math.pi**2/6)
    vals={k:0. for k in ('UU0','UU1','UT0','UT1')}
    for f in r['flavors']:
        iq,logq=gaussian_integrals(r['q'],f['Aq'],r['mu']);it,logt=gaussian_integrals(r['q'],f['At'],r['mu'])
        k=r['j']/r['z'];D=math.exp(-k*k/(4*f['Bh']))/(4*math.pi*f['Bh']*r['z']**2)
        C=k*math.exp(-k*k/(4*f['Bc']))/(8*math.pi*f['Bc']**2*r['z']**2)
        uq=f['weight']*r['HUU']*f['f']*f['d']*D;ut=f['weight']*r['HUT']*f['t']*f['c']*C
        vals['UU0']+=uq*iq;vals['UT0']+=ut*it
        vals['UU1']+=uq*(hard*iq+cf*((2*r['Y']+rr)*logq-.5*rr*rr*iq))
        vals['UT1']+=ut*(hard*it+cf*((2*r['Y']+rr)*logt-.5*rr*rr*it))
    return vals

def leaves(tree,path=()):
    if isinstance(tree,dict) and 'op' in tree:
        validate(tree);yield list(path),tree
    elif isinstance(tree,dict):
        for key,val in tree.items():yield from leaves(val,(*path,key))
    elif isinstance(tree,list):
        for i,val in enumerate(tree):
            if isinstance(val,dict) and 'numerator' in val:yield from leaves(val['numerator'],(*path,i+1,'numerator'))

def requests(seed):
    rng=random.Random(f'assembly-requests:{seed}');rad,op,ass,_=references();out=real_oracle.requests(seed)
    for source,tree in [('radiation',rad),('operators',op),('assembly',{'expressions':ass})]:
        for j,(path,expr) in enumerate(leaves(tree)):
            for i in range(2):
                p=point(rng)
                out.append({'id':f'coefficient.{source}.{j}.{i}','kind':'coefficient','source':source,'path':path,'point':p})
    for i in range(5):out.append({'id':f'primitive.{i}','kind':'primitive','eps':rng.uniform(.15,.55),'A':rng.uniform(.4,.9),'B':rng.uniform(1.1,2.2)})
    for i in range(8):
        p=physical_point(rng);out.append({'id':f'scales.{i}','kind':'scales',**{k:p[k] for k in ('Q2','pT','Y','R')}})
    for i in range(6):
        r={'id':f'gaussian.{i}','kind':'gaussian','q':rng.uniform(.1,.8),'j':rng.uniform(.02,.3),'z':rng.uniform(.25,.75),
            'mu':rng.uniform(2,8),'Q2':rng.uniform(20,80),'R':rng.uniform(.15,.45),'Y':rng.uniform(-1.2,1.2),
            'CF':4/3,'HUU':rng.uniform(2,6),'HUT':rng.uniform(1,3),'flavors':[]}
        for weight in (4/9,1/9):
            r['flavors'].append(dict(weight=weight,f=rng.uniform(.3,1),d=rng.uniform(.3,1),t=rng.uniform(-.3,.3),c=rng.uniform(-.2,.2),
                Aq=rng.uniform(.35,1),At=rng.uniform(.35,1),Bh=rng.uniform(.35,1),Bc=rng.uniform(.35,1)))
        out.append(r)
    import copy
    base=copy.deepcopy(out[-1]);base['id']='gaussian.zero_j';base['j']=0.;out.append(base)
    base=copy.deepcopy(out[-2]);base['id']='gaussian.spin_reverse'
    for f in base['flavors']:f['t']*=-1
    out.append(base)
    return out

def expected(r):
    if r['kind']=='real':return real_oracle.expected(r)
    if r['kind']=='primitive':return {'value':radial_difference(r['eps'],r['A'],r['B'])}
    if r['kind']=='scales':
        Q2,pT,Y,R=(r[k] for k in ('Q2','pT','Y','R'))
        return {'zeta_P':Q2*Q2*math.exp(2*Y)/pT**2,'zeta_0':4*pT*pT*math.cosh(Y)**2,'zeta_J':pT*pT*R*R}
    if r['kind']=='gaussian':return gaussian_expected(r)
    if r['kind']=='coefficient':
        rad,op,a,_=references();node={'radiation':rad,'operators':op,'assembly':{'expressions':a}}[r['source']]
        for p in r['path']:node=node[p-1] if isinstance(p,int) else node[p]
        return {'value':value(node,r['point'])[0]}
    raise ValueError('Unknown request kind')

def compare_response(req,payload,nonce,prefix='wolfram'):
    if type(payload) is not dict or set(payload)!={'run_id','status','responses'} or payload['run_id']!=nonce or payload['status']!='PASS' or type(payload['responses']) is not list:
        raise ValueError('Wrong fresh response envelope')
    rows={}
    for row in payload['responses']:
        if type(row) is not dict or set(row)!={'id','values'} or not isinstance(row['id'],str) or row['id'] in rows:raise ValueError('Invalid/duplicate response row')
        rows[row['id']]=row['values']
    if set(rows)!={r['id'] for r in req}:raise ValueError('Missing/extra response IDs')
    checks=[]
    for r in req:
        target=expected(r);got=rows[r['id']];_keys(got,target,r['id'])
        tol=4e-7 if r['kind']=='gaussian' else (3e-8 if r['kind']=='real' else 2e-9)
        for k,v in target.items():checks.append(check(prefix+'.'+r['id']+'.'+k,got[k],v,tol))
    return checks
