"""Independent 4D tree-current contractions using explicit Clifford matrices.

No FeynCalc expressions or candidate tensors are imported. This checks physical
4D projections, not the O(eps) BMHV terms needed in integrated operators.
Couplings e^4 e_q^2 g_s^2 are stripped. Color averages give CF (eq) or TR (eg).
"""
import math, random

METRIC=(1,-1,-1,-1)
def zero(): return [[0j]*4 for _ in range(4)]
def ident(): return [[complex(i==j) for j in range(4)] for i in range(4)]
def scale(a,c):return [[c*x for x in row] for row in a]
def plus(*arrays):return [[sum(a[i][j] for a in arrays) for j in range(4)] for i in range(4)]
def mm(a,b):return [[sum(a[i][k]*b[k][j] for k in range(4)) for j in range(4)] for i in range(4)]
def chain(*arrays):
    out=ident()
    for a in arrays:out=mm(out,a)
    return out
def trace(a):return sum(a[i][i] for i in range(4))
G0=[[complex((1 if i<2 else -1) if i==j else 0) for j in range(4)] for i in range(4)]
PAULI=(((0,1),(1,0)),((0,-1j),(1j,0)),((1,0),(0,-1)))
G=[G0]
for p in PAULI:
    a=zero()
    for i in range(2):
        for j in range(2):a[i][j+2]=p[i][j];a[i+2][j]=-p[i][j]
    G.append(a)
G5=scale(chain(*G),1j)
def slash(p):return plus(*(scale(g,m*v) for g,m,v in zip(G,METRIC,p)))
def adj(a):return chain(G0,[[a[j][i].conjugate() for j in range(4)] for i in range(4)],G0)
def dot(a,b):return math.fsum(m*x*y for m,x,y in zip(METRIC,a,b))
def vadd(a,b):return [x+y for x,y in zip(a,b)]
def vscale(a,c):return [c*x for x in a]
def cross(a,b):return [a[1]*b[2]-a[2]*b[1],a[2]*b[0]-a[0]*b[2],a[0]*b[1]-a[1]*b[0]]
def unit(a):
    norm=math.sqrt(sum(x*x for x in a));return [x/norm for x in a]
def spin(p,phi):
    n=unit(p[1:]);axis=[0.,0.,1.] if abs(n[2])<.8 else [1.,0.,0.]
    e1=unit(cross(axis,n));e2=cross(n,e1)
    return [0.]+[math.cos(phi)*a+math.sin(phi)*b for a,b in zip(e1,e2)]
def boost(p,beta):
    b2=sum(x*x for x in beta)
    if b2<1e-30:return p
    gamma=1/math.sqrt(1-b2);bp=sum(x*y for x,y in zip(beta,p[1:]))
    return [gamma*(p[0]+bp)]+[p[i+1]+((gamma-1)*bp/b2+gamma*p[0])*beta[i] for i in range(3)]

def sample(rng,E):
    l=[E,0.,0.,-E];p=[E,0.,0.,E]
    c=rng.uniform(-.6,.6);phi=rng.uniform(-math.pi,math.pi);ee=E*rng.uniform(.35,.8)
    lp=[ee,ee*math.sqrt(1-c*c)*math.cos(phi),ee*math.sqrt(1-c*c)*math.sin(phi),ee*c]
    rem=vadd(vadd(l,p),vscale(lp,-1));mass=math.sqrt(dot(rem,rem))
    c=rng.uniform(-.65,.65);phi=rng.uniform(-math.pi,math.pi)
    v=[math.sqrt(1-c*c)*math.cos(phi),math.sqrt(1-c*c)*math.sin(phi),c]
    beta=[x/rem[0] for x in rem[1:]]
    pp=boost([mass/2]+[mass*x/2 for x in v],beta)
    k=boost([mass/2]+[-mass*x/2 for x in v],beta)
    return {'l':l,'p':p,'lp':lp,'pp':pp,'k':k,'Sin':spin(p,rng.random()*6),'Sout':spin(pp,rng.random()*6)}

def currents(p,pp,k):
    dp=2*dot(pp,k);dm=-2*dot(p,k)
    if abs(dp*dm)<1e-22:raise ValueError('Singular real-emission point')
    a=scale(slash(vadd(pp,k)),1/dp);b=scale(slash(vadd(p,vscale(k,-1))),1/dm)
    return [[plus(chain(G[al],a,G[mu]),chain(G[mu],b,G[al])) for al in range(4)] for mu in range(4)]

def contract(r,channel='eq',polarized=False,ward=None):
    l,p,lp,pp,k=(r[n] for n in ('l','p','lp','pp','k'))
    q=vadd(l,vscale(lp,-1));q2=dot(q,q)
    if channel=='eq':
        A=currents(p,pp,k);rho=slash(p);color=r.get('CF',4/3);gluon=k
    elif channel=='eg':
        A=currents(vscale(k,-1),pp,vscale(p,-1));rho=slash(k);color=r.get('TR',.5);gluon=p
        if polarized:raise ValueError('No gluon transversity channel for the spin-1/2 target')
    else:raise ValueError('Unknown partonic channel')
    rhop=slash(pp)
    if polarized:rho=chain(rho,G5,slash(r['Sin']));rhop=chain(rhop,G5,slash(r['Sout']))
    if ward=='gluon':
        reduced=[plus(*(scale(A[mu][al],METRIC[al]*gluon[al]/l[0]) for al in range(4))) for mu in range(4)]
        A=[[reduced[mu]] for mu in range(4)];weights=[1.]
    else:weights=[-x for x in METRIC]
    left=[[chain(rhop,A[mu][al],rho) for al in range(len(weights))] for mu in range(4)]
    rights=[[adj(A[mu][al]) for al in range(len(weights))] for mu in range(4)]
    L=[[.5*trace(chain(slash(lp),G[mu],slash(l),G[nu]))*METRIC[mu]*METRIC[nu]
        for nu in range(4)] for mu in range(4)]
    if ward=='photon':
        L=[[METRIC[mu]*q[mu]*METRIC[nu]*q[nu]/l[0]**2 for nu in range(4)] for mu in range(4)]
    total=0j
    for mu in range(4):
        for nu in range(4):
            for al,w in enumerate(weights):
                tr=sum(left[mu][al][i][j]*rights[nu][al][j][i] for i in range(4) for j in range(4))
                total+=L[mu][nu]*w*.5*tr
    result=color*total/(q2*q2)
    if abs(result.imag)>1e-8*max(1,abs(result.real)):raise ValueError('Complex physical matrix element')
    return result.real

def requests(seed):
    rng=random.Random(f'collins-real-v2:{seed}');out=[]
    for i in range(8):
        r=sample(rng,10**rng.uniform(.5,1.4));r.update(CF=rng.choice([.75,4/3,2.4]),TR=.5)
        out.append(dict(r,id=f'real.eq.{i}',kind='real',channel='eq'))
        if i<4:out.append(dict(r,id=f'real.eg.{i}',kind='real',channel='eg'))
    return out

def expected(r):
    vals={'UU':contract(r,r['channel']),'ward_photon':0.,'ward_gluon':0.}
    if r['channel']=='eq':vals['UT']=contract(r,'eq',True)
    return vals
