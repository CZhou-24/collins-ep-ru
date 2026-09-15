"""Independently transcribed mathematics; reference disagreements stay visible."""
import sympy as s
from symbolic import SYMBOLS as V

def kang_B():
    zh,z,z1,CF,CA=(V[k] for k in ('zh','z','z1','CF','CA'))
    return 2*CF*zh/z*(1+zh/z1-zh/z)+CA*zh/z*(zh**2*(z**2+z1**2)-z*z1*(z+z1))/((z1-z)*(z1-zh)*z)

def yuan_minus_AF():
    zh,z,z1,CF,CA=(V[k] for k in ('zh','z','z1','CF','CA'))
    # Negative of the literal HF density in 0903.4680's A. This sign is a
    # comparison convention, not an inferred physical Collins sign.
    return 2*CF*zh/z*(1+zh/z1-zh/z)+CA*zh/z*(z*z1*(z+z1)-zh*(z**2+z1**2))/(z*(z-z1)*(z1-zh))

def transformed(kernel):
    u,v,zh,z,z1=(V[k] for k in ('u','v','zh','z','z1'))
    return s.cancel(kernel.subs({z:zh/u,z1:zh/(u*v)},simultaneous=True)/(1-v))

def hard():
    CF,L=V['CF'],V['L']
    return CF*(-L**2-3*L-8+s.pi**2/6)

def soft():
    CF,Y,r,B=(V[k] for k in ('CF','Y','r','Bq'))
    return CF*((2*Y+r)*B-r**2/2)

def assembly(jU,jT,kernel):
    HUU,HUT,f0,f1,h0,h1,D0,D1,C0,C1,HF0=(V[k] for k in
        ('HUU','HUT','f0','f1','h0','h1','D0','D1','C0','C1','HF0'))
    return {'UU0':HUU*f0*D0,'UT0':HUT*h0*C0,
            'UU1':HUU*(f1*D0+f0*D1+(hard()+soft()+jU)*f0*D0),
            'UT1':HUT*(h1*C0+h0*C1+(hard()+soft()+jT)*h0*C0),
            'HF_integrand':HUT*h0*kernel*HF0}

def ratio():
    U0,U1,N0,N1=(V[k] for k in ('U0','U1','N0','N1'))
    return {'A0':N0/U0,'A1':N1/U0-N0*U1/U0**2}

def probe_density(seed,kind):
    u,v,CF=(V[k] for k in ('u','v','CF'))
    # Rational upstream perturbations, unrelated to fitted hadronic inputs.
    n=1+(seed%17)
    return s.Rational(n,19)*CF*(u**3*(1-u)**2*v**2*(1-v)**2 if kind=='HF' else 1)

def probe_endpoints(seed):
    # A smooth density represented with two endpoint subtractions needs these
    # explicit contacts: c0*phi(1) - c1*phi'(1).
    u,CF=V['u'],V['CF'];factor=s.Rational(1+(seed%17),19)*CF*u**3*(1-u)**2
    return {'v_delta':factor/30,'v_derivative':factor/60}
