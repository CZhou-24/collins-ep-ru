#!/usr/bin/env python3
"""Compare native jet kernels with an independent paper transcription."""
import argparse,hashlib,json,sys
from pathlib import Path
import sympy as s
import mpmath as mp
ROOT=Path(__file__).resolve().parents[3];E=ROOT/'collins_sidis_highpt';R=ROOT/'collins_support/reports/sidis-highpt-001'
parser=argparse.ArgumentParser();parser.add_argument('--evidence-dir',type=Path,default=R);args=parser.parse_args();R=args.evidence_dir.resolve()
sys.path.insert(0,str(ROOT/'collins_support/validators/analytic'))
from algebra import decode
native=json.loads((R/'jet-matching-native.json').read_text())
reference=json.loads((E/'references/jet_matching.json').read_text())
z,L,CF,CA,TF,beta0=s.symbols('z L CF CA TF beta0')
rows=[]
for name,c in native['matching'].items():
    for part,v in c.items():
        diff=s.cancel(decode(v)-decode(reference['equations'][name+'_'+part]['value']))
        rows.append(dict(id=name+'_'+part,status='EXACT AFTER EXPLICIT CONVERSION' if diff==0 else 'MISMATCH',difference=str(diff),
          conversion='f(z) D_n = f(1) D_n + (f(z)-f(1))*log^n(1-z)/(1-z), D_n on [0,1].'))
actions=[]
tests=[z,z*z,z*(1-z),z*(1+2*z)]
for name,c in native['matching'].items():
    p=reference['direct_paper_distributions'][name]
    n={k:decode(v) for k,v in c.items()};p={k:decode(v) for k,v in p.items()}
    for f in tests:
        f1=f.subs(z,1)
        ni=s.cancel(n['plus0']*(f-f1)/(1-z)+n['plus1']*s.log(1-z)*(f-f1)/(1-z)+n['regular']*f)
        pi=s.cancel((p['multiplier_plus0']*f-p['multiplier_plus0'].subs(z,1)*f1)/(1-z)+s.log(1-z)*(p['multiplier_plus1']*f-p['multiplier_plus1'].subs(z,1)*f1)/(1-z)+p['regular']*f)
        # Integrate the two expressions separately, not their already-cancelled difference.
        na=s.simplify(n['delta']*f1+s.integrate(ni,(z,0,1)))
        pa=s.simplify(p['delta']*f1+s.integrate(pi,(z,0,1)))
        residual=s.simplify(na-pa)
        actions.append(dict(id=name,test=str(f),candidate=str(na),reference=str(pa),residual=str(residual),
          status='EXACT AFTER EXPLICIT CONVERSION' if residual==0 else 'MISMATCH'))
mp.mp.dps=70
numeric=[]
sub={L:s.Rational(2,3),CF:s.Rational(4,3),CA:3,TF:s.Rational(1,2),beta0:s.Rational(23,3)}
for name,c in native['matching'].items():
    n={k:decode(v).subs(sub) for k,v in c.items()};p={k:decode(v).subs(sub) for k,v in reference['direct_paper_distributions'][name].items()}
    f=z*s.exp(-z);f1=s.exp(-1)
    ni=s.cancel(n['plus0']*(f-f1)/(1-z)+n['plus1']*s.log(1-z)*(f-f1)/(1-z)+n['regular']*f)
    pi=s.cancel((p['multiplier_plus0']*f-p['multiplier_plus0'].subs(z,1)*f1)/(1-z)+s.log(1-z)*(p['multiplier_plus1']*f-p['multiplier_plus1'].subs(z,1)*f1)/(1-z)+p['regular']*f)
    na=mp.mpf(str(s.N(n['delta']*f1,72)))+mp.quad(s.lambdify(z,ni,'mpmath'),[0,mp.mpf('0.5'),1])
    pa=mp.mpf(str(s.N(p['delta']*f1,72)))+mp.quad(s.lambdify(z,pi,'mpmath'),[0,mp.mpf('0.5'),1])
    residual=abs(na-pa)
    numeric.append(dict(id=name,test='z exp(-z)',candidate=mp.nstr(na,65),reference=mp.nstr(pa,65),residual=mp.nstr(residual,12),
      tolerance='1e-45',precision_digits=70,status='NUMERICAL AGREEMENT' if residual<mp.mpf('1e-45') else 'MISMATCH'))
rg={name:{part:str(s.cancel(decode(v))) for part,v in c.items()} for name,c in native['RG_residuals'].items()}
result=dict(scope='Universal matching import and distribution checks, not a new DIS NLO hard result.',coefficient_rows=rows,
 exact_test_function_actions=actions,numerical_test_function_actions=numeric,RG_residuals=rg,
 order_residual=str(decode(native['order_residual'])),
 source_hashes={str(p.relative_to(ROOT)):hashlib.sha256(p.read_bytes()).hexdigest() for p in [E/'common/jet_matching.wl',E/'references/jet_matching.json',R/'jet-matching-native.json',Path(__file__)]})
dest=R/'jet-distribution-checks.json'
if dest.exists():raise FileExistsError(dest)
dest.write_text(json.dumps(result,indent=2)+'\n')
bad=[row for row in rows+actions+numeric if row['status']=='MISMATCH']
bad.extend(v for c in rg.values() for v in c.values() if v!='0')
if result['order_residual']!='0':bad.append(result['order_residual'])
print(json.dumps(dict(coefficients=len(rows),exact_convolutions=len(actions),numerical_convolutions=len(numeric),RG_residuals=sum(map(len,rg.values())),failures=len(bad))))
sys.exit(bool(bad))
