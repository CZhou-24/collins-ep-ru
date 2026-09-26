#!/usr/bin/env python3
"""Direct jet-interface comparison; source algebra, not a native campaign.

Requires SymPy 1.14. Snapshots are pinned and hashed. Expected nonzero
semi-inclusive differences are recorded, not suppressed or called failures.
No assertion of equality of full cross sections or intrinsic NLO Collins OPEs.
"""
import argparse
import csv
import hashlib
import json
from pathlib import Path
import re
import sympy as s
import jet_algebra as ja

BASE=Path(__file__).resolve().parent
rows=[]

def check(name,residual,meaning):
    residual=s.simplify(s.expand(residual))
    rows.append(dict(check=name,residual=str(residual),verdict='PASS' if residual==0 else 'FAIL',meaning=meaning))

def read(path):
    return (BASE/'sources'/path).read_text()

def parse(text):
    x=ja.parse(text)
    for name,fn in [('BesselJ',s.besselj),('Factorial',s.factorial)]:
        x=x.replace(lambda n:n.is_Function and n.func.__name__==name,lambda n:fn(*n.args))
    return x

def main():
    ap=argparse.ArgumentParser();ap.add_argument('--out',type=Path,required=True,help='New output directory under collins_support/reports/');args=ap.parse_args()
    if not args.out.resolve().is_relative_to(BASE.parents[1]/'reports'):
        ap.error('--out must be under collins_support/reports/')
    args.out.mkdir(parents=True,exist_ok=False)
    manifest=json.loads((BASE/'source_manifest.json').read_text())
    for f in manifest['files']:
        raw=(BASE/'sources'/f['path']).read_bytes()
        assert hashlib.sha256(raw).hexdigest()==f['sha256'],f['path']
        assert hashlib.sha1(b'blob '+str(len(raw)).encode()+b'\0'+raw).hexdigest()==f['sha'],f['path']

    # Reconstruct ep soft from source using the earlier analytic eta-first route.
    # Sphere normalization is analytic input; native integration is not rerun.
    soft=ja.ep_soft();sym={str(x):x for x in [ja.B,ja.V,ja.g,ja.CF,ja.eps,ja.eta]}
    jet=s.sympify(soft['injet_finite'],locals=sym)
    jet_all=s.sympify(soft['injet_Laurent'],locals=sym)
    half_all=s.sympify(soft['standard_half_Laurent'],locals=sym)
    check('soft / shifted standard half',jet_all-half_all.subs(ja.V,ja.V-ja.g),'ep derived extra intrinsic jet remainder, poles and finite part')
    evolution=read('collins_sidis_highpt/common/tmd_evolution.wl')
    softnu=parse(evolution.split('HSInJetSoftNuGamma[color_,Lb_]:=')[1].split(';')[0]).subs({s.Symbol('color'):ja.CF,s.Symbol('Lb'):ja.B})
    tmdnu=parse(evolution.split('HSUnsubtractedTMDNuGamma[color_,Lb_]:=')[1].split(';')[0]).subs({s.Symbol('color'):ja.CF,s.Symbol('Lb'):ja.B})
    check('soft / cross-workflow nu derivative',-2*s.diff(jet,ja.V)-softnu,'ep soft finite expression vs high-pT explicit in-jet rapidity anomalous dimension; coefficient of a')
    check('soft / cancellation with high-pT unsubtracted TMD',-2*s.diff(jet,ja.V)+tmdnu,'one in-jet soft allocation cancels the unsubtracted TMD rapidity dependence')

    # Scale map: read the actual all-b zeta declarations in both sources.
    ep=read('collins_ep_analytic_SIDIS/common/r07_assembly.wls')
    hp=read('collins_sidis_highpt/common/observable_assembly.wl')
    zeta_ep=parse(re.search(r'zetaJ==([^}]+)',ep).group(1))
    zeta_hp=parse(re.search(r'tmd=HSTMDInput\[sector,parent,zh,jT,Mh,mu,([^\]]+)\]',hp).group(1))
    check('scale / zetaJ',zeta_ep.subs(s.Symbol('pT'),s.Symbol('pJT'))-zeta_hp,'same local jet transverse momentum and R; no claim of a global frame transformation')

    # Parse the high-pT forward/inverse moment formula itself and integrate an
    # analytic Gaussian test function. This is not a fitted physical TMD.
    frag=read('collins_sidis_highpt/common/fragmentation.wl')
    fwd=frag.split('Module[{k},')[1].split(']];')[0]
    inv=frag.split('Module[{b},')[1].split(']];')[0]
    fpre=fwd.split('Inactive')[0];fker=fwd.split('Inactive[Integrate][')[1].split(',{k,')[0]
    ipre=inv.split('Inactive')[0];iker=inv.split('Inactive[Integrate][')[1].split(',{b,')[0]
    k,b,j,z,M,beta=s.symbols('k b j zh Mh beta',positive=True)
    pos={s.Symbol(str(x)):x for x in [k,b,j,z,M,beta]}
    def P(t,n):
        return parse(re.sub(r'\bn\b',str(n),t)).subs(pos)
    gaussian=s.exp(-beta*k*k)
    forward={};inverse={}
    for n in [0,1]:
        forward[n]=s.simplify(P(fpre,n)*s.integrate(P(fker.replace('fn[k]','1'),n)*gaussian,(k,0,s.oo)))
        inverse[n]=s.simplify(P(ipre,n)*s.integrate(P(iker.replace('fn[b]','1'),n)*forward[n],(b,0,s.oo)))
        check(f'Fourier / high-pT Gaussian round trip n={n}',inverse[n]-s.exp(-beta*j*j),'exact transform normalization test from parsed forward/inverse formulas')

    # ep radial factors are source-bound. Native rank1 projection is HN, as
    # stated and checked in ru_hf_projection.wl; do not rerun its Dirac trace.
    assert 'rank0=FullSimplify[1/Abs[Det[-z IdentityMatrix[2]]],z>0]' in ep
    assert 'rank1=FullSimplify[rank0 momentUnit/(2z),z>0]' in ep
    proj=read('collins_ep_analytic_SIDIS/common/ru_hf_projection.wl')
    assert '"native_moment"->nativeMoment-Global`HN' in proj
    ep_u=parse(ja.rhs(ep,'fragmentUU').replace('(rank0/.z->zh)','1/zh^2')).subs({s.Symbol('bh'):b,s.Symbol('jT'):j,s.Symbol('zh'):z})
    ep_t=parse(ja.rhs(ep,'fragmentUT').replace('(rank1/.z->zh)','1/(2zh^3)')).subs({s.Symbol('bh'):b,s.Symbol('jT'):j,s.Symbol('zh'):z})
    ep_forward=s.simplify(2*s.pi*s.integrate(k*s.besselj(0,b*k/z)*gaussian,(k,0,s.oo)))
    check('Fourier / UU forward map',ep_forward-z*z*forward[0],'D_ep = zh^2 D_tilde_highpt for the same momentum-space input')
    check('Fourier / UU inverse map',ep_u*ep_forward-P(ipre,0)*P(iker.replace('fn[b]','1'),0)*forward[0],'radial integrands coincide after the forward normalization map')

    # Documented HC=-HTrento/zh fixes a sign. This is an input convention map,
    # not evidence that the full ep and Breit-frame angular hard projections agree.
    conventions=read('collins_ep_analytic_SIDIS/CONVENTIONS.md')
    assert 'HC=-HTrento/z' in conventions and 'Hhat3=-2z Mh HTrento^(1)' in conventions
    C_ep=s.simplify(-4*s.pi/(M*b)*s.integrate(k*k*s.besselj(1,b*k/z)*gaussian,(k,0,s.oo)))
    Hmoment=s.pi/(z*z*M*M)*s.integrate(k**3*gaussian,(k,0,s.oo))
    check('Fourier / native Collins coefficient map',C_ep+2*z**4*M*forward[1],'C_ep(b) = -2 zh^4 Mh H_tilde_highpt^(1)(b), for declared common momentum input')
    check('Fourier / native tree moment limit',s.limit(C_ep,b,0)+2*z*M*Hmoment,'formal Gaussian b->0 limit gives Hhat3=-2 zh Mh HTrento^(1); no UV OPE claim')
    hp_t=j/(z*M)*P(ipre,1)*P(iker.replace('fn[b]','1'),1)*forward[1]
    check('Fourier / UT signed inverse map',ep_t*C_ep+hp_t,'raw native scalar radial coefficient is minus Trento/analyzer coefficient; conversion is required')
    check('Fourier / UT converted Gaussian action',-s.integrate(ep_t*C_ep,(b,0,s.oo))-j/(z*M)*s.exp(-beta*j*j),'mapped radial action reproduces the high-pT Collins analyzer magnitude and sign')

    # Complete jet operators are not equal. Read the semi-inclusive hard
    # matching coefficients and retain the nonzero distributional difference.
    jtext=read('collins_sidis_highpt/common/jet_matching.wl');differences={}
    for spin in ['U','T']:
        prefix=f'HSJetMatching["{spin}","q","q",z_,L_]:='
        c=ja.canonical(parse(jtext.split(prefix)[1].split(';')[0]))
        differences[spin]={part:str(s.simplify(value)) for part,value in c.items()}
        # phi(zJ)=1 is integrable for these qq channels. At L=0 this is a
        # concrete counterexample to identifying the full two jet functions.
        action=s.simplify(c['delta']+s.integrate(c['regular'],(ja.z,0,1)))
        expect=ja.CF*(-ja.L**2/2+ s.pi**2/12 + (-2*ja.L-4 if spin=='T' else -s.Rational(3,2)*ja.L-4))
        check(f'full jet / {spin} qq distribution difference action',action-expect,'verify NONZERO semi-inclusive correction on phi=1; it is absent from ep intrinsic jet remainder')
        differences[spin]['action_phi_1']=str(action)
        differences[spin]['action_phi_1_at_L_0']=str(action.subs(ja.L,0))
        assert s.simplify(action.subs(ja.L,0))!=0

    summary={'commit':manifest['commit'],'snapshot_files':len(manifest['files']),
             'checks':len(rows),'passed':sum(r['verdict']=='PASS' for r in rows),'failed':sum(r['verdict']=='FAIL' for r in rows),
             'verdict':'Shared soft/Fourier interfaces consistent under the recorded map; full jet operators not equal.',
             'qualification':'Source algebra with analytic Gaussian inputs, not a native Wolfram campaign, intrinsic Collins OPE comparison, all-b numerical TMD comparison or full cross-section equivalence.',
             'sympy':s.__version__,'semiinclusive_minus_intrinsic_qq':differences,
             'soft':soft,'gaussian_forward':{str(n):str(f) for n,f in forward.items()},'native_Collins_gaussian':str(C_ep),
             'convention_map':{'UU':'D_ep = zh^2 D_tilde_highpt','UT':'C_ep = -2 zh^4 Mh H_tilde_highpt^(1); native scalar radial action = - highpt analyzer radial action',
                               'scale':'zetaJ = pJT^2 R^2 in a common local jet convention'}}
    (args.out/'summary.json').write_text(json.dumps(summary,indent=2)+'\n')
    with (args.out/'checks.csv').open('w',newline='') as f:
        w=csv.DictWriter(f,fieldnames=list(rows[0]));w.writeheader();w.writerows(rows)
    print(json.dumps({k:summary[k] for k in ['checks','passed','failed','verdict']},indent=2))
    for row in rows:
        if row['verdict']=='FAIL':print(row)
    raise SystemExit(bool(summary['failed']))

if __name__=='__main__':main()
