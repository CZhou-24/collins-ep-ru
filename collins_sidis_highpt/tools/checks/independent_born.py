#!/usr/bin/env python3
"""Independent four-dimensional gamma-matrix Born calculation.

Build gamma* q -> q g directly from the two QCD Feynman diagrams, without
loading the saved amplitude bank or any new producing result. This is only an
independent Born reference, not an NLO hard coefficient.
"""
import json,sys
from pathlib import Path
import sympy as s
ROOT=Path(__file__).resolve().parents[3]
sys.dont_write_bytecode=True
sys.path.insert(0,str(ROOT/'collins_support/validators/analytic'))
from algebra import encode
r,z,h,Q,CF=s.symbols('r z h Q CF',real=True)
metric=[1,-1,-1,-1]
zero=s.zeros(2);eye=s.eye(2)
pauli=[s.Matrix([[0,1],[1,0]]),s.Matrix([[0,-s.I],[s.I,0]]),s.diag(1,-1)]
gamma=[s.diag(1,1,-1,-1)]+[zero.row_join(a).col_join((-a).row_join(zero)) for a in pauli]
g5=s.I*gamma[0]*gamma[1]*gamma[2]*gamma[3]
def slash(v):return sum((metric[i]*v[i]*gamma[i] for i in range(4)),s.zeros(4))
def dot(v,w):return sum(metric[i]*v[i]*w[i] for i in range(4))
def reduce(x):
    n,d=s.fraction(s.cancel(s.expand(x)))
    return s.factor(s.rem(n,h*h-r*z*(1-z),h)/s.rem(d,h*h-r*z*(1-z),h))
def bar(m):return gamma[0]*m.conjugate().T*gamma[0]
p=s.Matrix([Q*(1+r)/2,0,0,Q*(1+r)/2]);q=s.Matrix([0,0,0,-Q])
k=s.Matrix([Q*(r+(1-r)*z)/2,Q*h,0,Q*(r-(1+r)*z)/2]);g=p+q-k
unit=[s.eye(4)[:,i] for i in range(4)]
Si=[unit[1],unit[2]]
So=[s.Matrix([0,k[3]/k[0],0,-k[1]/k[0]]),unit[2]]
photons=[unit[0],unit[1],unit[2]]
names=['L','X','Y']
den_s=Q*Q*r;den_t=-Q*Q*(1+r)*(1-z)
def current(ph,gl):return slash(gl)*slash(p+q)*slash(ph)/den_s+slash(ph)*slash(k-q)*slash(gl)/den_t
def contraction(ph1,ph2,spin_in=None,spin_out=None,gluon=None):
    pin=slash(p) if spin_in is None else slash(p)*g5*slash(spin_in)
    pout=slash(k) if spin_out is None else slash(k)*g5*slash(spin_out)
    terms=[(gluon,1)] if gluon is not None else [(unit[a],-metric[a]) for a in range(4)]
    return reduce(CF*s.Rational(1,2)*sum(weight*s.trace(pout*current(ph1,gl)*pin*bar(current(ph2,gl))) for gl,weight in terms))
def main():
    equations={};native={};proofs={}
    def put(key,value):
        native[key]=str(value)
        equations[key]={'value':encode(value),'source_url':'local:tools/checks/independent_born.py',
          'location':'Independent 4x4 Clifford trace of the two gamma* q -> q g Feynman diagrams; '+key,
          'transcription':'Generated independently with explicit Dirac matrices; r=s/Q^2, z=(Q^2+s+t)/(Q^2+s), h>0 and h^2=r z (1-z). No producing result or saved amplitude was loaded.',
          'independence':'independent_calculation'}
    for i,ph1 in enumerate(photons):
        for j,ph2 in enumerate(photons):
            put('UU_'+names[i]+names[j],contraction(ph1,ph2))
            for a in range(2):
                for b in range(2):put(f'T{a+1}{b+1}_{names[i]}{names[j]}',contraction(ph1,ph2,Si[a],So[b]))
        print('completed photon row '+names[i],flush=True)
    proofs['p_null']=str(reduce(dot(p,p)));proofs['k_null']=str(reduce(dot(k,k)))
    proofs['g_null']=str(reduce(dot(g,g)));proofs['q_virtuality']=str(reduce(dot(q,q)+Q*Q))
    for a in range(2):
        proofs[f'in_orthogonal_{a}']=str(reduce(dot(Si[a],p)))
        proofs[f'out_orthogonal_{a}']=str(reduce(dot(So[a],k)))
        for b in range(2):
            proofs[f'in_basis_{a}{b}']=str(reduce(dot(Si[a],Si[b])+int(a==b)))
            proofs[f'out_basis_{a}{b}']=str(reduce(dot(So[a],So[b])+int(a==b)))
    proofs['photon_ward_UU']=str(contraction(q,q))
    for a in range(2):
        for b in range(2):proofs[f'photon_ward_T{a}{b}']=str(contraction(q,q,Si[a],So[b]))
    for i,ph in enumerate(photons):
        proofs[f'gluon_ward_UU_{i}']=str(contraction(ph,ph,gluon=g))
        for a in range(2):
            for b in range(2):proofs[f'gluon_ward_T{a}{b}_{i}']=str(contraction(ph,ph,Si[a],So[b],g))
    if any(v!='0' for v in proofs.values()):raise ValueError('Independent Born check failed: '+str(proofs))
    dest=ROOT/'collins_sidis_highpt/references/born_clifford.json'
    with dest.open('x') as f:json.dump({'equations':equations},f,indent=2);f.write('\n')
    out=ROOT/'collins_support/reports/sidis-highpt-001/independent-born.json'
    with out.open('x') as f:json.dump({'scope':'four-dimensional independent Born reference only','equations':native,'residuals':proofs},f,indent=2);f.write('\n')
    print(json.dumps({'status':'INDEPENDENT_BORN_CHECKS_PASS','equations':len(equations),'zero_residuals':len(proofs)}))

if __name__=='__main__':main()
