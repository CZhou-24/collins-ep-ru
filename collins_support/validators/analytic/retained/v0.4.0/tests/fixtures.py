"""Synthetic algebra only. Never native or scientific acceptance evidence."""
import copy
import sympy as s
from symbolic import SYMBOLS as V,encode,PARTS
import oracles
from nlo_support import canonical_hash

def packet(sid,data):return {'schema':1,'stage':sid,'purpose':'DERIVATION','coupling':'alpha_s/(2*pi)','data':data}
def dist(regular=0,delta=0,D0=0,D1=0):return {k:encode(v) for k,v in dict(regular=regular,delta=delta,D0=D0,D1=D1).items()}
def fixtures():
    u,v,z,z1,z2,B,CF,eps,eta=(V[k] for k in ('u','v','z','z1','z2','B','CF','eps','eta'))
    definition={'process':'ep_Collins','electron':'unpolarized','proton':'transverse','jet_algorithm':'anti-kt','jet_axis':'standard_E_scheme',
       'coupling':'alpha_s/(2*pi)','born_coupling':'alpha_EM^2','sidis_commit':'5062dcb2407594dafcc2f9f72800e96ff9e6d957',
       'operator_basis':['Hhat','HF'],'HF_diagonal':'zero','rapidity_order':'eta_then_epsilon',
       'radius_qualification':'narrow_cone_derivation_R1_not_certified','paper_limit':'HF_zero_and_jet_finite_extension_zero',
       'all_b':'renormalized_symbolic_TMDs','small_b':'local_OPE_only'}
    notes={k:'SYNTHETIC TEST RECORD; this is not a native derivation or scientific evidence.' for k in
        ('operator_identification','gauge_boundary','support_and_EOM','finite_jet_scope')}
    d16=packet('d16',{'definitions':definition,'review':notes,'independent_HF':True,
      'identities':{k:encode(x) for k,x in {'dz1_measure':1/z,'PV_combined_measure':1/(1-v),'delta_inverse_fraction':z**2,
      'EOM_contact':1,'Fourier_rank0_relative':1/z**2,'Collins_rank1_relative':1/(2*z**3)}.items()}})
    kernel=oracles.transformed(oracles.kang_B());finite=-B*kernel+2*s.log(u)*kernel+CF*u*v*(1-v)
    # Nonzero finite constant chosen for testing, never an external physical answer.
    base={'coefficients':{'collins':{'synthetic':'retained diagonal fixture'}},'splitting':{'transversity':{'synthetic':'retained splitting fixture'}}}
    d17=packet('d17',{'reference_B':encode(oracles.kang_B()),'native_basis_factor':1,
        'bare':dist(finite-kernel/eps),'counterterm':dist(kernel/eps),'finite':dist(finite),
        'independent_finite':dist(finite),'mixing':dist(kernel),'epsilon_projection':dist(CF*u*v),
        'diagonal_canonical':base['coefficients']['collins'],'diagonal_splitting':base['splitting']['transversity'],
        'closed_full_twist3_RG':False,'routes':{'primary':'SYNTHETIC PRIMARY OPE ROUTE FOR SOFTWARE TESTS ONLY; no native claim.',
        'independent':'SYNTHETIC SECOND INTEGRAL ROUTE FOR SOFTWARE TESTS ONLY; no native claim.'}})
    d17['data']['v_prescription']='two_subtractions_plus_explicit_delta_and_delta_prime'
    for endpoint in ('v_delta','v_derivative'):
        d17['data'][endpoint]={k:dist() for k in ('bare','counterterm','finite','independent_finite','mixing','epsilon_projection')}
    j=s.Rational(7,9)*CF
    q={'bare':encode(j+CF/eps+CF/eta),'counterterm':encode(-CF/eps),'overlap':encode(CF/eta),
       'finite':encode(j),'independent_finite':encode(j),'epsilon_projection':encode(CF),'gamma_G_minus_TMD':0}
    d18=packet('d18',{'UU':copy.deepcopy(q),'UT':copy.deepcopy(q),'multiply_inclusive_J':False,'import_pp_out_of_jet_H':False,
      'radius_qualification':'narrow_cone_derivation_R1_not_certified','review':{k:'SYNTHETIC SOFTWARE TEST; no physical finite jet coefficient is asserted here.' for k in
          ('operator_scope','out_of_jet_overlap','radius_validity','independent_route')}})
    d19=make_assembly(d17,d18)
    return {'d16':d16,'d17':d17,'d18':d18,'d19':d19},base

def make_assembly(d17,d18):
    from symbolic import decode
    from nlo_checks import full_HF
    jU=decode(d18['data']['UU']['finite']);jT=decode(d18['data']['UT']['finite'])
    pol=oracles.assembly(jU,jT,0);zero=oracles.assembly(0,0,0)
    return packet('d19',{'input_packet_hashes':{'d17':canonical_hash(d17),'d18':canonical_hash(d18)},
       'observable':{k:encode(pol[k]) for k in ('UU0','UT0','UU1','UT1')},
       'HF_integrand':{k:encode(V['HUT']*V['h0']*x*(V['HFend'] if k.startswith('v_delta_') else -V['HFderiv'] if k.startswith('v_derivative_') else V['HF0'])) for k,x in full_HF(d17['data'],'finite').items()},
       'ratio':{k:encode(x) for k,x in oracles.ratio().items()},
       'paper_limit':{k:encode(zero[k]) for k in ('UU0','UT0','UU1','UT1')},
       'scheme_variation':{ch:encode(pol[ch+'0']*sum(V[k] for k in ('kH','kB','kF','kS'))) for ch in ('UU','UT')},
       'fitted_inputs_evaluated':False,'all_b_OPE_extrapolation':False,'HF_independent':True,
       'ratio_after_common_linear_integral':True,'paper_limit_is_full_NLO':False,'full_fixed_order_NLO':False})

def perturbed(packets,kind,seed):
    from symbolic import decode
    ps=copy.deepcopy(packets);delta=oracles.probe_density(seed,kind);sid='d17' if kind=='HF' else 'd18';d=ps[sid]['data']
    if kind=='HF':
        d['epsilon_projection']['regular']=encode(decode(d['epsilon_projection']['regular'])+delta)
        for name in ('bare','finite','independent_finite'):d[name]['regular']=encode(decode(d[name]['regular'])-delta)
        for endpoint,value in oracles.probe_endpoints(seed).items():
            d[endpoint]['epsilon_projection']['regular']=encode(decode(d[endpoint]['epsilon_projection']['regular'])+value)
            for name in ('bare','finite','independent_finite'):d[endpoint][name]['regular']=encode(decode(d[endpoint][name]['regular'])-value)
    else:
        for ch in ('UU','UT'):
            d[ch]['epsilon_projection']=encode(decode(d[ch]['epsilon_projection'])+delta)
            for name in ('bare','finite','independent_finite'):d[ch][name]=encode(decode(d[ch][name])-delta)
    ps['d19']=make_assembly(ps['d17'],ps['d18']);return ps
