"""Independent finite soft-slice quadrature. This is not a full soft function."""
import functools,math,random

@functools.lru_cache(None)
def legendre(n):
    pairs=[]
    for i in range(1,n+1):
        x=math.cos(math.pi*(i-.25)/(n+.5))
        for _ in range(40):
            p0,p1=1.0,x
            for k in range(2,n+1): p0,p1=p1,((2*k-1)*x*p1-(k-1)*p0)/k
            dp=n*(x*p1-p0)/(x*x-1)
            step=p1/dp;x-=step
            if abs(step)<2e-15: break
        pairs.append((x,2/((1-x*x)*dp*dp)))
    return pairs

def integrate(f,a,b,n=40):
    half=(b-a)/2;mid=(b+a)/2
    return half*math.fsum(w*f(mid+half*x) for x,w in legendre(n))

def soft_slice(R,Y,kmin,kmax,n=40):
    """2D Gaussian quadrature split on the circular anti-kt boundary.

    Both rapidity signs and azimuth signs are summed analytically. Inside
    |u|<R, u=R*sin(theta) smooths the boundary sqrt(R^2-u^2).
    No candidate code or candidate angular primitive is used.
    """
    if not (0<R<min(Y,math.pi) and 0<kmin<kmax): raise ValueError('Invalid finite soft slice')
    def angular(u,lo):
        return integrate(lambda v:4*math.cosh(u)/(math.cosh(u)-math.cos(v)),lo,math.pi,n)
    inside=integrate(lambda theta:angular(R*math.sin(theta),R*math.cos(theta))*R*math.cos(theta),0,math.pi/2,n)
    outside=integrate(lambda u:angular(u,0),R,Y,n)
    return math.log(kmax/kmin)*(inside+outside)

def requests(seed):
    rng=random.Random(seed);out=[]
    for i in range(12):
        y=rng.uniform(.12,.88);s=math.exp(rng.uniform(-1,6));nc=rng.choice([2,3,5])
        out.append({'id':f'hard.{i:02d}','kind':'hard','s':s,'t':-y*s,'u':-(1-y)*s,'L':rng.uniform(-4,4),'CF':(nc*nc-1)/(2*nc)})
    for i in range(10):
        us=rng.choice([-1,1])*rng.uniform(.2,2);phi=rng.choice([-1,1])*rng.uniform(.15,2.8);cf=rng.choice([.75,4/3,2.4])
        out.append({'id':f'soft.kernel.{i:02d}','kind':'soft_kernel','u':us,'phi':phi,'CF':cf})
    for i in range(4):
        R=rng.uniform(.45,1.2);Y=rng.uniform(1.4,2.6);kmin=rng.uniform(.2,.8);kmax=kmin*rng.uniform(1.5,4)
        out.append({'id':f'soft.slice.{i:02d}','kind':'soft_slice','R':R,'Y':Y,'kmin':kmin,'kmax':kmax,'yJ':rng.uniform(-1.5,2.5)})
    base=next(x for x in out if x['kind']=='soft_slice')
    out.extend([dict(base,id='soft.radius',R=base['R']*.8),dict(base,id='soft.translation',yJ=base['yJ']+2),dict(base,id='soft.radial_scaling',kmin=2*base['kmin'],kmax=2*base['kmax']),dict(base,id='soft.log_scaling',kmax=base['kmax']**2/base['kmin'])])
    return out

def expected(r):
    if r['kind']=='hard':
        s,t,u,L,cf=(r[k] for k in ('s','t','u','L','CF'))
        v={'H_UU':2*(s*s+u*u)/(t*t),'H_UT':-4*s*u/(t*t),'h1':cf*(-L*L-3*L-8+math.pi**2/6)}
        return dict(v,**{'upstream_'+key:value for key,value in v.items()})
    if r['kind']=='soft_kernel':
        kernel=math.exp(r['u'])/(math.cosh(r['u'])-math.cos(r['phi']))
        return {'kernel':kernel,'angular_derivative':kernel,'prefactor':r['CF']/(2*math.pi**2)}
    args=[r[k] for k in ('R','Y','kmin','kmax')]
    v1=soft_slice(*args,n=32);v2=soft_slice(*args,n=56)
    if abs(v1-v2)>1e-8*max(1,abs(v2)): raise ValueError('Independent soft oracle did not converge')
    return {'slice':v2}

def compare_response(requests,payload,run_id):
    if type(payload)!=dict or set(payload)!={'run_id','status','responses'} or payload['run_id']!=run_id or payload['status']!='PASS': raise ValueError('Wrong response envelope')
    if type(payload['responses']) is not list: raise ValueError('Responses must be a list')
    rows={}
    for row in payload['responses']:
        if type(row)!=dict or set(row)!={'id','values'} or not isinstance(row['id'],str) or row['id'] in rows: raise ValueError('Invalid or duplicate response')
        rows[row['id']]=row['values']
    if set(rows)!={r['id'] for r in requests}: raise ValueError('Missing or unexpected response IDs')
    checks=[]
    for r in requests:
        want=expected(r);got=rows[r['id']]
        if type(got)!=dict or set(got)!=set(want): raise ValueError('Wrong component keys')
        tol=3e-6 if r['kind']=='soft_slice' else 2e-10
        for key,value in want.items():
            actual=got[key]
            if type(actual) not in (int,float) or not math.isfinite(actual): raise ValueError('Nonfinite/non-numeric value')
            checks.append({'id':r['id']+'.'+key,'status':'PASS' if abs(actual-value)<=tol*max(1,abs(value)) else 'FAIL','actual':actual,'expected':value,'tolerance':tol*max(1,abs(value))})
    return checks
