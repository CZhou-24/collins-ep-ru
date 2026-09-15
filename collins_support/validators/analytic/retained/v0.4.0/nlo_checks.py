"""Exact constraints, complete distribution comparisons and reference diagnostics.

Finite constants without a settled frozen independent reference are tested by
two declared native routes and upstream probes, and ALWAYS require source review.
This module never treats a passing consistency check as an independent derivation.
"""
import sympy as s
from symbolic import decode,encode,distribution,PARTS,SYMBOLS as V,zero
from nlo_support import read,canonical_hash
import oracles

V_ENDPOINTS=('v_delta','v_derivative')
def full_HF(p,field):
    result=distribution(p[field])
    for endpoint in V_ENDPOINTS:
        result.update({endpoint+'_'+k:x for k,x in distribution(p[endpoint][field]).items()})
    return result

def row(name,ok,**extra):return {'id':name,'status':'PASS' if ok else 'FAIL',**extra}
def eq(name,a,b):return row(name,zero(a-b),residual=encode(s.cancel(s.expand(a-b))))
def restrict(x,names):
    return x.free_symbols <= {V[n] for n in names}
def data(packet,stage):
    if (type(packet) is not dict or packet.get('schema')!=1 or packet.get('stage')!=stage
        or packet.get('purpose')!='DERIVATION' or packet.get('coupling')!='alpha_s/(2*pi)'):
        raise ValueError('invalid scientific packet '+stage)
    return packet['data']

def d16_checks(packet):
    p=data(packet,'d16');u,v,z,z1,z2= (V[k] for k in ('u','v','z','z1','z2'))
    rows=[]
    expected={'process':'ep_Collins','electron':'unpolarized','proton':'transverse',
      'jet_algorithm':'anti-kt','jet_axis':'standard_E_scheme','coupling':'alpha_s/(2*pi)',
      'born_coupling':'alpha_EM^2','sidis_commit':'5062dcb2407594dafcc2f9f72800e96ff9e6d957',
      'operator_basis':['Hhat','HF'],'HF_diagonal':'zero','rapidity_order':'eta_then_epsilon',
      'radius_qualification':'narrow_cone_derivation_R1_not_certified',
      'paper_limit':'HF_zero_and_jet_finite_extension_zero',
      'all_b':'renormalized_symbolic_TMDs','small_b':'local_OPE_only'}
    for k,value in expected.items():rows.append(row('d16.definition.'+k,p.get('definitions',{}).get(k)==value))
    for k in ('operator_identification','gauge_boundary','support_and_EOM','finite_jet_scope'):
        rows.append(row('d16.review_record.'+k,type(p.get('review',{}).get(k)) is str and len(p['review'][k].strip())>=40))
    identities={'dz1_measure':1/z,'PV_combined_measure':1/(1-v),
                'delta_inverse_fraction':z**2,'EOM_contact':s.Integer(1),
                'Fourier_rank0_relative':1/z**2,'Collins_rank1_relative':1/(2*z**3)}
    for name,expected in identities.items():rows.append(eq('d16.'+name,decode(p['identities'][name]),expected))
    rows.append(row('d16.independent_HF',p['independent_HF'] is True))
    return rows

def d17_checks(packet,base_matching):
    p=data(packet,'d17');rows=[];parts={k:distribution(p[k]) for k in
        ('bare','counterterm','finite','independent_finite','mixing','epsilon_projection')}
    B=decode(p['reference_B']);B0=oracles.kang_B();B1=oracles.yuan_minus_AF()
    matches=[zero(B-B0),zero(B-B1)]
    rows.append(row('d17.reference.kernel_supported',any(matches),
       matched=[n for n,ok in zip(('Kang2011_literal','Yuan2009_minus_AF_literal'),matches) if ok],
       qualification='Literal alternatives, not evidence that the conventions or printed formulas are equivalent'))
    # Both residuals are immutable report data, including the nonzero one.
    for name,ref in [('Kang2011',B0),('Yuan2009_minus_AF',B1)]:
        rows.append(row('d17.reference.record.'+name,True,agreement='EXACT' if zero(B-ref) else 'DISCREPANCY',residual=encode(s.cancel(B-ref))))
    factor=decode(p['native_basis_factor'])
    rows.append(row('d17.reference.basis_factor',not zero(factor) and restrict(factor,('u','v','zh'))))
    kernel=oracles.transformed(B)*factor
    allowed=('u','v','zh','CF','CA','B','T')
    for part in PARTS:
        bare,ct,finite,independent,mixing,proj=(parts[k][part] for k in
            ('bare','counterterm','finite','independent_finite','mixing','epsilon_projection'))
        rows.append(eq('d17.subtraction.'+part,bare+ct,finite))
        rows.append(eq('d17.collinear_counterterm.'+part,ct,mixing/V['eps']))
        rows.append(row('d17.finite_symbols.'+part,restrict(finite,allowed)))
        rows.append(eq('d17.independent_finite.'+part,finite,independent))
        rows.append(eq('d17.mixing.'+part,mixing,kernel if part=='regular' else s.Integer(0)))
        rows.append(eq('d17.RG.'+part,s.diff(finite,V['B']),-mixing))
        rows.append(eq('d17.rapidity.'+part,s.diff(finite,V['T']),s.Integer(0)))
        rows.append(row('d17.projection_symbols.'+part,restrict(proj,('u','v','zh','CF','CA'))))
    rows.append(row('d17.color_CF_present',not zero(s.diff(parts['mixing']['regular'],V['CF']))))
    rows.append(row('d17.color_CA_present',not zero(s.diff(parts['mixing']['regular'],V['CA']))))
    rows.append(row('d17.retained_diagonal',p['diagonal_canonical']==base_matching['coefficients']['collins']))
    rows.append(row('d17.retained_transversity',p['diagonal_splitting']==base_matching['splitting']['transversity']))
    rows.append(row('d17.HF_not_closed_RG_claim',p.get('closed_full_twist3_RG') is False))
    for name in ('primary','independent'):
        rows.append(row('d17.route.'+name,type(p.get('routes',{}).get(name)) is str and len(p['routes'][name].strip())>=40))
    rows.append(row('d17.routes_distinct',p['routes']['primary']!=p['routes']['independent']))
    rows.append(row('d17.v_endpoint_prescription',p.get('v_prescription')=='two_subtractions_plus_explicit_delta_and_delta_prime'))
    for endpoint in V_ENDPOINTS:
        ep={k:distribution(p[endpoint][k]) for k in ('bare','counterterm','finite','independent_finite','mixing','epsilon_projection')}
        for part in PARTS:
            e={k:x[part] for k,x in ep.items()};label=endpoint+'.'+part
            rows.append(eq('d17.endpoint.subtraction.'+label,e['bare']+e['counterterm'],e['finite']))
            rows.append(eq('d17.endpoint.collinear_counterterm.'+label,e['counterterm'],e['mixing']/V['eps']))
            rows.append(eq('d17.endpoint.independent.'+label,e['finite'],e['independent_finite']))
            rows.append(eq('d17.endpoint.RG.'+label,s.diff(e['finite'],V['B']),-e['mixing']))
            rows.append(eq('d17.endpoint.rapidity.'+label,s.diff(e['finite'],V['T']),s.Integer(0)))
            rows.append(row('d17.endpoint.symbols.'+label,all(V['v'] not in x.free_symbols for x in e.values()) and restrict(e['finite'],('u','zh','CF','CA','B','T'))))
    return rows

def d18_checks(packet):
    p=data(packet,'d18');rows=[];jets={}
    for ch in ('UU','UT'):
        q=p[ch];e={k:decode(q[k]) for k in ('bare','counterterm','overlap','finite','independent_finite','epsilon_projection')}
        jets[ch]=e['finite']
        rows.append(eq('d18.subtraction.'+ch,e['bare']+e['counterterm']-e['overlap'],e['finite']))
        rows.append(eq('d18.independent_finite.'+ch,e['finite'],e['independent_finite']))
        rows.append(row('d18.finite_symbols.'+ch,restrict(e['finite'],('CF','CA','r'))))
        rows.append(row('d18.projection_symbols.'+ch,restrict(e['epsilon_projection'],('CF','CA','r'))))
        # The ratio is formed AFTER expressing the TMD at zeta_J=pT^2 R^2.
        rows.append(eq('d18.RG.'+ch,decode(q['gamma_G_minus_TMD']),s.Integer(0)))
    rows.append(eq('d18.spin_blind_remainder',jets['UU'],jets['UT']))
    rows.append(row('d18.no_extra_inclusive_jet',p.get('multiply_inclusive_J') is False))
    rows.append(row('d18.no_inclusive_pp_H_transplant',p.get('import_pp_out_of_jet_H') is False))
    rows.append(row('d18.radius_qualification',p.get('radius_qualification')=='narrow_cone_derivation_R1_not_certified'))
    for k in ('operator_scope','out_of_jet_overlap','radius_validity','independent_route'):
        rows.append(row('d18.review_record.'+k,type(p.get('review',{}).get(k)) is str and len(p['review'][k].strip())>=40))
    return rows

def d19_checks(packet,p17,p18):
    p=data(packet,'d19');m=data(p17,'d17');j=data(p18,'d18');rows=[]
    maps={'observable':{'UU0','UT0','UU1','UT1'},'ratio':{'A0','A1'},
          'paper_limit':{'UU0','UT0','UU1','UT1'},'scheme_variation':{'UU','UT'}}
    for name,keys in maps.items():
        if type(p.get(name)) is not dict or set(p[name])!=keys:raise ValueError('wrong first-order coefficient map: '+name)
    kernel=full_HF(m,'finite');jU=decode(j['UU']['finite']);jT=decode(j['UT']['finite'])
    for key,source in [('d17',p17),('d18',p18)]:
        rows.append(row('d19.input.'+key,p['input_packet_hashes'][key]==canonical_hash(source)))
    expected=oracles.assembly(jU,jT,s.Integer(0))
    for name in ('UU0','UT0','UU1','UT1'):
        rows.append(eq('d19.assembly.'+name,decode(p['observable'][name]),expected[name]))
    if set(p['HF_integrand'])!=set(kernel):raise ValueError('incomplete two-fraction endpoint assembly')
    for part in kernel:
        field=V['HFend'] if part.startswith('v_delta_') else -V['HFderiv'] if part.startswith('v_derivative_') else V['HF0']
        rows.append(eq('d19.HF_consumed.'+part,decode(p['HF_integrand'][part]),
                       V['HUT']*V['h0']*kernel[part]*field))
    for name,x in oracles.ratio().items():rows.append(eq('d19.integrated_ratio.'+name,decode(p['ratio'][name]),x))
    expected0=oracles.assembly(s.Integer(0),s.Integer(0),s.Integer(0))
    for name in ('UU0','UT0','UU1','UT1'):
        rows.append(eq('d19.paper_limit.'+name,decode(p['paper_limit'][name]),expected0[name]))
    # Independent arbitrary O(a) shifts, not four candidate numbers chosen to sum to zero.
    kH,kB,kF,kS=(V[k] for k in ('kH','kB','kF','kS'))
    for ch,tree in [('UU',expected['UU0']),('UT',expected['UT0'])]:
        shifted=decode(p['scheme_variation'][ch])
        rows.append(eq('d19.scheme.generic.'+ch,shifted,tree*(kH+kB+kF+kS)))
        rows.append(eq('d19.scheme.compensated.'+ch,shifted.subs(kS,-kH-kB-kF),s.Integer(0)))
    for k,val in {'fitted_inputs_evaluated':False,'all_b_OPE_extrapolation':False,'HF_independent':True,
                  'ratio_after_common_linear_integral':True,'paper_limit_is_full_NLO':False,
                  'full_fixed_order_NLO':False}.items():rows.append(row('d19.scope.'+k,p.get(k) is val))
    return rows

def check_all(packets,base_matching):
    rows=[]
    for sid,fn in [('d16',lambda:d16_checks(packets['d16'])),
                   ('d17',lambda:d17_checks(packets['d17'],base_matching)),
                   ('d18',lambda:d18_checks(packets['d18'])),
                   ('d19',lambda:d19_checks(packets['d19'],packets['d17'],packets['d18']))]:
        try:rows.extend(fn())
        except Exception as e:rows.append(row(sid+'.packet_valid',False,detail=str(e)))
    return rows

def probe_checks(kind,original,changed,delta,assembly_changed=None):
    sid='d17' if kind=='HF' else 'd18';p=data(original,sid);q=data(changed,sid);rows=[]
    if kind=='HF':
        for part in PARTS:
            target=delta if part=='regular' else s.Integer(0)
            rows.append(eq('probe.HF.projector.'+part,decode(q['epsilon_projection'][part])-decode(p['epsilon_projection'][part]),target))
            rows.append(eq('probe.HF.finite.'+part,decode(q['finite'][part])-decode(p['finite'][part]),-target))
        rows.append(row('probe.HF.pole_unchanged',p['mixing']==q['mixing']))
        v=V['v']
        contact={'v_delta':s.integrate(delta,(v,0,1)),
                 'v_derivative':s.integrate(delta*(1-v),(v,0,1))}
        for endpoint in V_ENDPOINTS:
            for part in PARTS:
                target=contact[endpoint] if part=='regular' else s.Integer(0)
                rows.append(eq('probe.HF.projector.'+endpoint+'.'+part,decode(q[endpoint]['epsilon_projection'][part])-decode(p[endpoint]['epsilon_projection'][part]),target))
                rows.append(eq('probe.HF.finite.'+endpoint+'.'+part,decode(q[endpoint]['finite'][part])-decode(p[endpoint]['finite'][part]),-target))
            rows.append(row('probe.HF.pole_unchanged.'+endpoint,p[endpoint]['mixing']==q[endpoint]['mixing']))
        if assembly_changed is not None:
            a=data(assembly_changed,'d19');rows.append(eq('probe.HF.assembly',decode(a['HF_integrand']['regular']),
                V['HUT']*V['h0']*(decode(p['finite']['regular'])-delta)*V['HF0']))
    else:
        for ch in ('UU','UT'):
            rows.append(eq('probe.jet.projector.'+ch,decode(q[ch]['epsilon_projection'])-decode(p[ch]['epsilon_projection']),delta))
            rows.append(eq('probe.jet.finite.'+ch,decode(q[ch]['finite'])-decode(p[ch]['finite']),-delta))
    return rows
