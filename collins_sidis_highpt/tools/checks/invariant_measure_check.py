#!/usr/bin/env python3
"""Derive the massless Breit phase-space bounds and invariant Jacobians.

This is a measure check, not a finite hard coefficient or a prediction.
The dimensional real/virtual measure must still be multiplied before taking
its finite part. No fit, hard result, or reference coefficient is loaded.
"""
import argparse
import hashlib
import json
from pathlib import Path
import sympy as s


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--output', type=Path, required=True)
    args = ap.parse_args()
    args.output.mkdir(parents=True, exist_ok=False)
    Q, pT, xB, x, zJ, u = s.symbols('Q pT xB x zJ u', positive=True)
    # u=exp(eta_J)>0 avoids unproved logarithmic simplifications.
    metric = s.diag(1, -1, -1, -1)
    dot = lambda a, b: (a.T * metric * b)[0]
    P = Q / (2*xB) * s.Matrix([1, 0, 0, 1])
    q = s.Matrix([0, 0, 0, -Q])
    jet = s.Matrix([pT*(u+1/u)/2, pT, 0, pT*(u-1/u)/2])
    incoming, observed = x*P, jet/zJ
    recoil = incoming+q-observed
    shat = s.factor(dot(incoming+q, incoming+q))
    that = s.factor(dot(q-observed, q-observed))
    w = s.factor(dot(recoil, recoil))
    xmin = s.factor(s.solve(w, x)[0])
    zmin = s.factor(s.solve(xmin-1, zJ)[0])
    A, C = Q*pT/u, Q*pT*(u-1/u)
    expected_xmin = xB*(Q**2*zJ+C)/(Q**2*zJ-A)
    expected_zmin = pT/Q*(1/u+xB*u/(1-xB))
    phi, eta = s.symbols('phi eta', real=True)
    spatial = s.Matrix([pT*s.cos(phi), pT*s.sin(phi), pT*s.sinh(eta)])
    # Variables ordered to give positive determinant in the physical region.
    jet_jac = s.simplify(spatial.jacobian([pT, phi, eta]).det())
    parent_spatial = spatial/zJ
    scaling_jac = s.simplify(parent_spatial.jacobian([pT, phi, eta]).det()/jet_jac)
    y, lm = s.symbols('y lm', positive=True)
    Q2 = s.symbols('Q2', positive=True)
    lepton_coords = s.Matrix([Q2*(1-y), lm*(1-y)])
    lepton_jac = s.factor(lepton_coords.jacobian([Q2,y]).det())
    # Incoming target/parton fluxes are 4 l.P and 4 l.(xP), respectively.
    l = s.Matrix([lm/2,0,0,-lm/2])
    flux_ratio = s.factor(dot(l,P)/dot(l,incoming))
    hg, hpp, F1, F2 = s.symbols('hg hpp F1 F2')
    xh = s.symbols('xh', positive=True)
    projector_equations = [F1-(-hg/2+2*hpp*xh**2/Q2),
                           F2-(-hg*xh+12*hpp*xh**3/Q2)]
    solved = s.solve(projector_equations, [hg,hpp])
    uuL = s.factor((4*hpp*xh**2/Q2).subs(solved))
    uuT = s.factor((4*hpp*xh**2/Q2-hg).subs(solved))
    lepton = Q2/y**2*(4*(1-y)*uuL+(1+(1-y)**2)*uuT)
    residuals = {
        'target_mass': dot(P,P), 'jet_mass': s.factor(dot(jet,jet)),
        'photon_mass': dot(q,q)+Q**2,
        's_invariant': shat-Q**2*(x/xB-1),
        't_invariant': that+Q**2+C/zJ,
        'recoil_invariant': w-((x/xB)*(Q**2-A/zJ)-Q**2-C/zJ),
        'incoming_lower_bound': xmin-expected_xmin,
        'jet_fraction_lower_bound': zmin-expected_zmin,
        'recoil_minus_positive_at_zmin': (Q-A/(Q*zJ)).subs(zJ,zmin)-Q*xB*u**2/(1-xB+xB*u**2),
        'endpoint_x_is_one': xmin.subs(zJ,zmin)-1,
        'recoil_at_xmin': w.subs(x,xmin),
        'jet_invariant_measure': jet_jac/(2*pT*s.cosh(eta))-pT/2,
        'fragmentation_measure': scaling_jac*zJ-1/zJ**2,
        'incoming_flux_ratio': flux_ratio-1/x,
        'lepton_invariant_measure': -lepton_jac/(4*lm*(1-y))-s.Rational(1,4),
        'UU_L_conversion': uuL-(F2/(2*xh)-F1),
        'UU_T_conversion': uuT-2*F1,
        'UU_lepton_contraction': lepton-2*Q2/y**2*(y**2*F1+(1-y)*F2/xh),
    }
    residuals = {k: s.factor(v) for k,v in residuals.items()}
    root = Path(__file__).resolve().parents[3]
    imports = ['SIDIS/Hqq/s01_result/s01_inputs/s02_result.wl',
               'SIDIS/common/s20_final_hats.wl']
    result = {
        'scope': 'Massless leading-power Breit measurement and invariant measures; no NLO acceptance',
        'variables': 'u=exp(eta_J), 0<xB<1, 0<y<1, Q,pT>0; zJ_min<1',
        'invariants': {'s':str(shat),'t':str(that),'w':str(w)},
        'bounds': {'zJ_min':str(zmin),'x_min_at_zJ':str(xmin),
                   'integration':'zJ_min <= zJ <= 1; x_min(zJ) <= x <= 1'},
        'measures': {'incoming':'dx/x', 'jet_fraction':'dzJ/zJ^2',
                     'lepton':'dQ2 dy dphi_l / [4 (2 pi)^3]',
                     'jet':'pJT dpJT detaJ dphiJ / [2 (2 pi)^3]',
                     'hadron':'dz_h d^2 j_T; the TMD Fourier convention is separate'},
        'flux':'1/(4 l.P)=1/(2 S); e^4/Q^4 multiplies the leptonic/current tensor contraction',
        'normalization_note':'Archived inclusive Fhats include hardNormalization=(2 pi)^(-4); undo it before using the raw current tensor with these invariant phase measures.',
        'symbolic_residuals': {k:str(v) for k,v in residuals.items()},
        'source_sha256':hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
        'imported_projector_and_normalization_sources':{
            name: hashlib.sha256((root/name).read_bytes()).hexdigest()
            for name in imports},
        'sympy_version':s.__version__,
        'qualification':'The phase/flux identities do not establish jet/TMD finite-scheme compatibility or supply missing hard coefficients.'
    }
    (args.output/'measures.json').write_text(json.dumps(result,indent=2)+'\n')
    if any(v != 0 for v in residuals.values()):
        raise SystemExit('Nonzero measure residual: '+str({k:v for k,v in residuals.items() if v!=0}))
    print('INVARIANT_MEASURES_EXACT',len(residuals))


if __name__ == '__main__':
    main()
