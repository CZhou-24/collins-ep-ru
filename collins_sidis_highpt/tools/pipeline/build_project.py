#!/usr/bin/env python3
"""Declare the actual development-prefix inputs and independent checks."""
import hashlib,json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
E=ROOT/'collins_sidis_highpt'
spec=json.loads((ROOT/'collins_support/validators/sidis_highpt_project.example.json').read_text())
spec['ready']=True
spec['scope'].update(spin_definition='Physical right-handed bases about p and k1, density slash(p)(1+gamma5 slash(S))/2; metric +---; BMHV production.',
 azimuth_definition='phi_S about p and phi_h about the standard jet axis relative to the hard production plane; retain photon L,X,Y until lepton contraction; see SCOPE.md.',
 jet_algorithm='anti-kT, rapidity-azimuth distance, E-scheme standard axis; semi-inclusive with no extra-jet veto',
 jet_radius='symbolic R',jet_approximation='Leading power small R and j_T/(p_JT R), from arXiv:2311.00672v2 Sec.3.1; finite matching required.',
 momentum_region='j_T << p_JT R << p_JT ~ Q, p_JT R >> Lambda_QCD in Breit frame',
 factorization_definition='Collinear inclusive hard coefficient with outgoing subtraction convoluted with semi-inclusive TMD fragmenting-jet matching; subtracted TMD input at zeta_J=(p_JT R)^2. NLO assembly still in development.')
spec['sources']={}
def source(key,root,path,role,origin):
    base=ROOT/'SIDIS' if root=='sidis' else E
    spec['sources'][key]=dict(root=root,path=path,role=role,origin=origin,sha256=hashlib.sha256((base/path).read_bytes()).hexdigest())
source('Hqq_amplitudes','sidis','Hqq/s01_result/s01_inputs/s01_result.wl','amplitudes','Saved two Born, 8 qgg, 8 same-flavor pair, 4 distinct-flavor pair and 15 virtual amplitudes. Local SIDIS revision 5062dcb2407594dafcc2f9f72800e96ff9e6d957; imported, not freshly generated.')
source('Hqq_born_normalization','sidis','Hqq/s01_result/s01_inputs/s02_result.wl','definitions','Archived model charge, initial averages and normalization definitions. Its UU output is separately independently extracted as a reference.')
source('born_independent','engine','references/born_clifford.json','reference','Independently constructed two diagrams and 4x4 Clifford traces in tools/checks/independent_born.py; no candidate result or amplitude bank loaded.')
source('born_uu_archived','engine','references/uu_born_archived.json','reference','Literal archived UU Born expressions, extracted natively with tools/checks/export_uu_reference.wls; source hash retained.')
source('Hqg_amplitudes','sidis','Hqg/s01_result/s01_inputs/s04_result.wl','amplitudes','Saved Born, real and virtual amplitudes used in fresh tagged-spin operator-zero checks.')
source('Hqqprime_amplitudes','sidis','Hqqprime/s01_result/s01_inputs/s01_result/real.wl','amplitudes','Saved open-spinor distinct-observed-flavor real amplitude used in fresh operator-zero checks.')
source('Hqqbar_amplitudes','sidis','Hqqbar/s01_result/s01_inputs/s01_result/real.wl','amplitudes','Saved open-spinor tagged-antiquark real amplitudes, used in the fresh complete dimensional real calculation; the original input identity is retained.')
source('UU_bigTMD_validation','sidis','bigTMD_comparison/s04_result.json','definitions','Historical 60 coefficient and 120 numerical comparisons; byte identities checked here, not freshly replayed. Separate Hgq MadGraph issue remains unresolved.')
uu_records=json.loads((ROOT/'SIDIS/bigTMD_comparison/s04_result.json').read_text())['Channels']
for ch,row in uu_records.items():
    source(ch+'_UU','sidis',row['ProductionFile'],'unpolarized_result','Exact saved inclusive UU coefficient bank from the preserved BigTMD comparison. The new jet measurement/convolution is applied separately by r07.')
    if spec['sources'][ch+'_UU']['sha256']!=row['ProductionSHA256']:raise ValueError('UU source identity differs from historical comparison: '+ch)
for ch in spec['channels']:
    spec['channels'][ch]=dict(born=ch in ('Hqq','Hqg','Hgq'),ut_active=True if ch=='Hqq' else None,
      reason='Hqq has the incoming and tagged outgoing quark on the spin-transfer line; Born is freshly contracted.' if ch=='Hqq' else 'Assignment under review from tagged amplitude lines; no zero or NLO completion asserted by this development prefix.',
      zero_check=None,uu_source=None,uu_validation=None)
    spec['channels'][ch].update(uu_source=ch+'_UU',uu_validation='UU_bigTMD_validation')
    if ch in ('Hqg','Hqqprime','Hgq','Hgg'):
        reason='Actual tagged amplitude traces vanish with open photon indices: odd-gamma chiral-odd trace.' if ch in ('Hqg','Hqqprime') else 'Leading-twist collinear helicity-two gluon operator is excluded between spin-half proton states by the explicit Jz commutator equation.'
        spec['channels'][ch].update(ut_active=False,zero_check=ch+'.operator_zero',reason=reason)
    if ch=='Hqqbar':spec['channels'][ch].update(ut_active=True,reason='Identical-flavor exchange interferences are chirally allowed; the full eight-diagram physical-point contraction has a nonzero Collins spin-trace coefficient. Born absent; leading hard order alpha_s squared. Full dimensional real coefficient remains required.')
spec['checks']=[]
def check(key,kind,reason,**kw):
    spec['checks'].append(dict(id='Hqq.'+key,kind=kind,stage='r00',channel='Hqq',lhs='r00/'+key,reason=reason,**kw))
for key in json.loads((E/'references/born_clifford.json').read_text())['equations']:
    check(key,'born_reference' if key.startswith('T') else 'uu_recovery','Full physical photon/spin tensor component versus independent explicit Clifford trace.',reference={'source':'born_independent','equation':key})
conv={'Q2':['pow','Q',2],'s':['mul',['pow','Q',2],'r'],'t':['mul',-1,['pow','Q',2],['add',1,'r'],['add',1,['mul',-1,'z']]],'SUNN':'Nc'}
for proj in ('Pg','Ppp'):
    check('UU_'+proj,'uu_recovery','Recover the original D-dimensional UU contraction from the same saved amplitudes.',
      reference={'source':'born_uu_archived','equation':'Born'+proj},reference_substitutions=conv,
      conversion='Q2=Q^2; s=Q^2 r; t=-Q^2(1+r)(1-z); SUNN=Nc. Candidate CF=(Nc^2-1)/(2Nc). No D->4 conversion for this comparison.')
for side in ('in','out'):
    for i in (1,2):
        check(f'spin_{side}_orth_{i}','spin_basis','Physical transverse basis orthogonal to its tagged massless momentum.',rhs=0)
        for j in (1,2):check(f'spin_{side}_gram_{i}{j}','spin_basis','Spacelike orthonormal basis in metric +---.',rhs=0)
check('photon_ward_UU','ward','Replace virtual photon polarization by q in the actual Born amplitude before squaring.',rhs=0)
for i in (1,2):
    for j in (1,2):check(f'photon_ward_T{i}{j}','ward','Photon Ward identity with both tagged spin densities retained.',rhs=0)
for ph in ('L','X','Y'):check('gluon_ward_'+ph,'ward','Spectator-gluon Ward identity of the tagged-spin Born amplitude.',rhs=0)
for key in ('spin_normalization_UU','spin_normalization_TT'):
    check(key,'normalization','Four independently contracted fixed-spin orientation squares versus direct UU/TT density contraction, with initial/outgoing factors explicit.',rhs=0)
check('spin_rotation','spin_basis','Direct contraction with independent rationally rotated incoming/outgoing spin vectors versus tensor rotation.',rhs=0)
for key in ('UU_photon_basis_recovery','UU_p_projection_recovery'):
    check(key,'normalization','Recover covariant UU projections from complete physical photon basis at D=4.',rhs=0)
for i in range(1,10):check('angular_'+str(i),'normalization','Lepton mass-shell/current conservation, hadron azimuth integral, spin reversal and coefficient-defining Collins Fourier projection; see native angular evidence.',rhs=0)
for ch in ('Hqg','Hqqprime','Hgq','Hgg'):
    spec['checks'].append(dict(id=ch+'.operator_zero',kind='channel_zero',stage='r00',channel=ch,lhs='r00/zero_'+ch,rhs=0,reason=spec['channels'][ch]['reason']))
spec['master_imports']={};spec['exports']={}
from native_project_spec import extend
complete_inventory = extend(spec, ROOT, E, source)
(E/'project.json').write_text(json.dumps(spec,indent=2)+'\n')
print(json.dumps({'declared_through':'r07' if complete_inventory else 'r00','checks':len(spec['checks']),'sources':len(spec['sources']),'full_native_inventory':complete_inventory,'acceptance':'separate native campaign required'}))
