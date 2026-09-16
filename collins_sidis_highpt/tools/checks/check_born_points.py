#!/usr/bin/env python3
"""Independent physical-point Clifford replay and Collins projector sign."""
import argparse,hashlib,json,sys
from pathlib import Path
import sympy as s
ROOT=Path(__file__).resolve().parents[3]
sys.path.insert(0,str(ROOT/'collins_support/validators/analytic'))
from algebra import decode
import independent_born as b
parser=argparse.ArgumentParser();parser.add_argument('--run',required=True,type=Path);parser.add_argument('--output',required=True,type=Path);args=parser.parse_args()
packetfile=args.run/'common/r00_result/packet.json';packet=json.loads(packetfile.read_text())
original={name:getattr(b,name) for name in ('p','q','k','g','Si','So','den_s','den_t','CF')}
rows=[];normalizations=[];positivity=[]
points=[(s.Integer(1),s.Rational(1,2),s.Rational(1,2)),(s.Integer(4),s.Rational(1,2),s.Integer(1)),(s.Integer(1),s.Rational(4,5),s.Rational(2,5))]
for ip,(rr,zz,hh) in enumerate(points):
    subs={b.r:rr,b.z:zz,b.h:hh,b.Q:10,original['CF']:s.Rational(4,3)}
    for name,value in original.items():
        setattr(b,name,[v.subs(subs) for v in value] if isinstance(value,list) else value.subs(subs))
    native_subs={s.Symbol(str(k)):v for k,v in subs.items()}
    for i,ph1 in enumerate(b.photons):
        for j,ph2 in enumerate(b.photons):
            keys=[('UU_'+b.names[i]+b.names[j],None,None)]
            keys += [(f'T{a+1}{c+1}_{b.names[i]}{b.names[j]}',b.Si[a],b.So[c]) for a in range(2) for c in range(2)]
            for key,si,so in keys:
                ref=b.contraction(ph1,ph2,si,so)
                candidate=decode(packet['values']['r00/'+key]['value']).subs(native_subs)
                residual=s.simplify(candidate-ref)
                rows.append(dict(point=ip+1,id=key,candidate=str(candidate),independent=str(ref),residual=str(residual)))
    # Four actual fixed-spin squares for physical transverse photon X.
    fixed={}
    for sign_i in (1,-1):
        for sign_o in (1,-1):
            pin=b.slash(b.p)*(s.eye(4)+b.g5*b.slash(sign_i*b.Si[0]))/2
            pout=b.slash(b.k)*(s.eye(4)+b.g5*b.slash(sign_o*b.So[0]))/2
            value=s.simplify(b.CF*sum(-b.metric[a]*s.trace(pout*b.current(b.photons[1],b.unit[a])*pin*b.bar(b.current(b.photons[1],b.unit[a]))) for a in range(4)))
            fixed[sign_i,sign_o]=value
            positivity.append(dict(point=ip+1,spin_in=sign_i,spin_out=sign_o,fixed_square=str(value),nonnegative=bool(value>=0)))
    uu=s.simplify(sum(fixed.values())/2)
    tt=s.simplify(sum(i*j*v for (i,j),v in fixed.items())/2)
    normalizations.extend([dict(point=ip+1,id='four_spin_UU',residual=str(s.simplify(uu-b.contraction(b.photons[1],b.photons[1])))),
      dict(point=ip+1,id='four_spin_TT',residual=str(s.simplify(tt-b.contraction(b.photons[1],b.photons[1],b.Si[0],b.So[0]))))])
# Eq.70 sign map: i n_nu sigma^{k nu} gamma5 measures +S^k relative to slash(n).
k=s.Matrix([1,0,0,1]);n=s.Matrix([1,0,0,-1]);basis=[s.Matrix([0,1,0,0]),s.Matrix([0,0,1,0])]
spin_sign=[]
for i,Si in enumerate(basis):
    rho=b.slash(k)*(s.eye(4)+b.g5*b.slash(Si))/2
    uu=s.trace(rho*b.slash(n))
    for j in range(2):
        op=sum((s.I*n[a]*b.metric[a]*s.I*(b.gamma[j+1]*b.gamma[a]-b.gamma[a]*b.gamma[j+1])/2*b.g5 for a in range(4)),s.zeros(4))
        projection=s.simplify(s.trace(rho*op)/uu)
        spin_sign.append(dict(spin_basis=i+1,operator_index=j+1,projection=str(projection),residual=str(projection-int(i==j))))
result=dict(scope='Born physical-point check only. Pointwise equality is not the symbolic proof; the latter is in the native/reference comparison.',
 assumptions='Q=10, CF=4/3, metric +---; real h>0; nonsingular r>0,0<z<1; h^2=r z(1-z)',
 points=[{'r':str(r),'z':str(z),'h':str(h)} for r,z,h in points],rows=rows,normalization_residuals=normalizations,
 fixed_spin_positivity=positivity,fragmentation_spin_projector=spin_sign,
 Collins_analyzer='With epsilon_T^{12}=+1, paper Eq.70 gives (-sin(phi_h),cos(phi_h))*j_T/(z_h M_h).',
 hashes={str(p):hashlib.sha256(p.read_bytes()).hexdigest() for p in (packetfile,Path(__file__),Path(b.__file__))})
if args.output.exists():raise FileExistsError(args.output)
args.output.write_text(json.dumps(result,indent=2)+'\n')
bad=[r for r in rows+normalizations+spin_sign if r['residual']!='0']+[r for r in positivity if not r['nonnegative']]
print(json.dumps(dict(point_comparisons=len(rows),normalization_checks=len(normalizations),projector_checks=len(spin_sign),positive_fixed_squares=len(positivity),failures=len(bad))))
sys.exit(bool(bad))
