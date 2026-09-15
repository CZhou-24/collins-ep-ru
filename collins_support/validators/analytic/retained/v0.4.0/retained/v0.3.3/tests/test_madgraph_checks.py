"""Synthetic adapter and archived source-format tests; NOT a native MG run."""
import cmath
import copy
import itertools
import json
import math
import re
from pathlib import Path
import sys
import tempfile
import unittest
from unittest.mock import patch

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
import madgraph_checks as m


def basis(p):
    """Independent analytic massless Weyl spinors, helicity (-,+)."""
    e = p[0]
    theta = math.acos(max(-1., min(1., p[3]/e)))
    phi = math.atan2(p[2], p[1])
    c, s = math.cos(theta/2), math.sin(theta/2)
    norm = math.sqrt(2*e)
    minus = [-cmath.exp(-1j*phi)*s*norm, c*norm, 0j, 0j]
    plus = [0j, 0j, c*norm, cmath.exp(1j*phi)*s*norm]
    return [minus, plus]


def bar(u):
    g0 = m.weyl_matrices()[0][0]
    return [sum(u[k].conjugate()*g0[k][j] for k in range(4)) for j in range(4)]


def born_amplitudes(request):
    """Direct helicity currents, independent of the Clifford trace oracle."""
    ps = request['momenta']
    wave = [basis(p) for p in ps]
    gs = m.weyl_matrices()[0]
    q = [a-b for a,b in zip(ps[0], ps[2])]
    factor = 4*math.pi*m.ALPHA_EM*m.CHARGE/m.dot(q,q)
    def current(out, inc, mu):
        ubar = bar(out)
        return sum(ubar[i]*gs[mu][i][j]*inc[j] for i in range(4) for j in range(4))
    result = {}
    for hel in itertools.product((-1,1), repeat=4):
        u = [wave[i][(h+1)//2] for i,h in enumerate(hel)]
        result[hel] = factor*sum((1 if mu==0 else -1)*current(u[2],u[0],mu)*current(u[3],u[1],mu) for mu in range(4))
    return result


def native_fixture(request):
    """Native text FORMAT fixture, using synthetic helicity amplitudes."""
    amps = born_amplitudes(request)
    uu = 3*sum(abs(a)**2 for a in amps.values())/12
    lines = [f'MGUU 1 {uu:.17e}']
    for mask in range(16):
        hel = tuple(2*((mask>>i)&1)-1 for i in range(4))
        a = amps[hel]
        lines.append(f'MGAMP 1 {mask} {a.real:.17e} {a.imag:.17e} 3.0 {3*abs(a)**2:.17e}')
    for hi,h in enumerate((-1,1)):
        ui = basis(request['momenta'][1])[hi]
        uo = bar(basis(request['momenta'][3])[hi])
        for i in range(4):
            lines.append(f'MGSPIN 1 {h} {i+3} {ui[i].real:.17e} {ui[i].imag:.17e} {uo[i].real:.17e} {uo[i].imag:.17e}')
    return '\n'.join(lines)+'\n'


class PhaseSpaceTests(unittest.TestCase):
    def test_deterministic_physical_points_and_spin_projectors(self):
        first = m.points(1729)
        self.assertEqual(first, m.points(1729))
        self.assertNotEqual(first, m.points(92741))
        self.assertEqual(len(first), 18)
        self.assertEqual(len({r['id'] for r in first}), 18)
        for r in first:
            m.validate_point(r)
            self.assertGreater(m.covariant(r), 0)
            if r['spin_in'] is not None:
                self.assertLessEqual(abs(m.covariant(r,True)), m.covariant(r)*(1+1e-10))
                m.spin_density(r['momenta'][1], r['spin_in'], basis(r['momenta'][1]))

    def test_bad_momentum_and_spin_are_rejected(self):
        r = copy.deepcopy(m.points(1,1)[0])
        r['momenta'][2][0] *= 2
        with self.assertRaises(ValueError): m.validate_point(r)
        r = copy.deepcopy(m.points(1,1)[0])
        r['spin_in'] = [0.,0.,0.,0.]
        with self.assertRaises(ValueError): m.validate_point(r)


class CoherentSpinTests(unittest.TestCase):
    def test_complex_helicity_born_matches_independent_dirac_trace(self):
        for request in m.points(3701):
            if request['process'] != 'born_eq': continue
            amps = born_amplitudes(request)
            ci = m.spin_density(request['momenta'][1],request['spin_in'],basis(request['momenta'][1]))
            co = m.spin_density(request['momenta'][3],request['spin_out'],basis(request['momenta'][3]))
            actual = m.coherent_sum(amps,ci,co,3.,12)
            expected = m.covariant(request,True)
            self.assertTrue(m.close(actual,expected), (actual,expected))
            self.assertTrue(m.close(sum(abs(a)**2 for a in amps.values())/4,m.covariant(request)))
            # Erasing interference must NOT reproduce the transverse check.
            diagonal = [[ci[0][0],0j],[0j,ci[1][1]]]
            incoherent = m.coherent_sum(amps,diagonal,co,3.,12)
            self.assertLess(abs(incoherent),1e-20)
            self.assertGreater(abs(expected),1e-6)

    def test_native_outgoing_phases_and_parser_controls(self):
        request = m.points(2,1)[0]
        parsed = m.parse_native(native_fixture(request),[request])[1]
        self.assertTrue(m.close(parsed['UU'],m.covariant(request)))
        self.assertTrue(m.close(parsed['UT'],m.covariant(request,True)))
        # This includes the runner's spin reversal, double reversal, zero
        # polarization and compensated arbitrary native rephasing controls.

    def test_rephased_native_spinors_change_density_covariantly(self):
        r = m.points(34,1)[0]
        u = basis(r['momenta'][3])
        original = m.spin_density(r['momenta'][3],r['spin_out'],u)
        phases = (.7,-.23)
        changed = [[x*cmath.exp(1j*phases[i]) for x in ui] for i,ui in enumerate(u)]
        rho = m.spin_density(r['momenta'][3],r['spin_out'],changed)
        for a in range(2):
            for b in range(2):
                self.assertLess(abs(rho[a][b]-original[a][b]*cmath.exp(1j*(phases[b]-phases[a]))),1e-12)

    def test_wrong_spinor_basis_cannot_receive_pass(self):
        r=m.points(1,1)[0]
        u=basis(r['momenta'][1]);u[0]=[2*x for x in u[0]]
        with self.assertRaises(m.Unsupported): m.spin_density(r['momenta'][1],r['spin_in'],u)


class NativeParserTests(unittest.TestCase):
    def setUp(self):
        self.request=m.points(1729,1)[0]
        self.text=native_fixture(self.request)

    def test_fortran_d_exponents(self):
        parsed=m.parse_native(self.text.replace('e','D'),[self.request])
        self.assertIn('UT',parsed[1])

    def test_missing_duplicate_nonfinite_and_wrong_color_are_rejected(self):
        variants = [
            '\n'.join(self.text.splitlines()[:-1]),
            self.text+self.text.splitlines()[0]+'\n',
            self.text.replace(self.text.splitlines()[0],'MGUU 1 nan'),
            self.text.replace(self.text.splitlines()[0],'MGUU 1 1.0'),
            self.text.replace('MGAMP 1 0','MGAMP 1 32'),
            self.text+'MGUU 1 1.0 extra\n',
        ]
        for text in variants:
            with self.subTest(text=text[-50:]):
                with self.assertRaises((ValueError,m.Unsupported)): m.parse_native(text,[self.request])


class InstrumentationTests(unittest.TestCase):
    def test_supported_color_layouts_preserve_generated_amplitude_lines(self):
        for layout,metric in [('packed_scalar','DBLE(CF(1))/DBLE(DENOM)'),('square_scalar','DBLE(CF(1,1))/DBLE(DENOM(1))')]:
            original=(Path(m.__file__).parent/'madgraph_templates'/f'{layout}.f').read_text()
            updated,name=m.instrument_matrix(original)
            self.assertEqual(name,'MATRIX')
            self.assertIn('AUDITCOLOR='+metric,updated)
            retained='\n'.join(line for line in updated.splitlines() if not any(x in line for x in ('AUDITAMP','AUDITCOLOR','AUDITCAPTURE')))+'\n'
            self.assertEqual(retained,original)
            with self.assertRaises(m.Unsupported): m.instrument_matrix(original.replace('NCOLOR=1','NCOLOR=2'))

    def test_unknown_color_and_signature_are_blocked(self):
        original=(Path(m.__file__).parent/'madgraph_templates/packed_scalar.f').read_text()
        with self.assertRaises(m.Unsupported): m.instrument_matrix(original.replace('CF(NCOLOR*(NCOLOR+1)/2)','CF(99)'))
        with self.assertRaises(m.Unsupported): m.instrument_matrix(original.replace('MATRIX(P,NHEL,IC)','MATRIX(P,NHEL)'))

    def test_native_initialization_and_actual_outgoing_wavefunction(self):
        self.assertEqual(m.initialization_call("      CALL SETPARA('param_card.dat')\n"),"CALL SETPARA('../../Cards/param_card.dat')")
        self.assertIn(', .TRUE.)',m.initialization_call("      CALL SETPARA('param_card.dat', .TRUE.)\n"))
        with self.assertRaises(m.Unsupported): m.initialization_call('CALL INITIALISE_MODEL(foo)')
        source=m.driver_source('MATRIX',4)
        self.assertIn('CALL OXXXXX(P(0,4)',source)
        self.assertNotIn('CALL IXXXXX(P(0,4)',source)

    def test_parameter_card_changes_only_declared_inputs(self):
        card='BLOCK SMINPUTS\n 1 127.0\n 2 1.166e-5\n 3 .12\nBLOCK MASS\n 11 .000511\n 2 .002\n 21 0.0\n 23 91.18\nDECAY 23 2.495\n'
        result=m.parameter_card(card)
        self.assertIn(' 2 1.166e-5',result)
        self.assertIn(' 23 91.18',result)
        self.assertIn('DECAY 23 2.495',result)
        self.assertIn(f'{1/m.ALPHA_EM:.17g}',result)
        with self.assertRaises(m.Unsupported): m.parameter_card('BLOCK MASS\n 11 0.\n')


class GeneratedInitializationTests(unittest.TestCase):
    """Exercise actual driver syntax and guard against accepting hidden calls."""
    fixture_root = Path(__file__).parent/'fixtures/madgraph_370'
    valid = "      CALL SETPARA('param_card.dat')\n"
    canonical = "CALL SETPARA('../../Cards/param_card.dat')"

    def test_generated_mass_includes_keep_original_zero_parameter(self):
        # The v0.3.1 native build failed here, after initialization succeeded.
        # Exercise all three genuine generator includes, not a mock pmass.
        original = (self.fixture_root/'check_sa.f').read_text().upper()
        declarations = ('REAL*8 ZERO', 'PARAMETER (ZERO=0D0)')
        for declaration in declarations:
            self.assertIn(declaration, original)
        for process in m.PROCESSES:
            with self.subTest(process=process):
                pmass = (self.fixture_root/f'{process}.pmass.inc').read_text().upper()
                assignments = re.findall(r'PMASS\((\d+)\)\s*=\s*([A-Z0-9_]+)', pmass)
                n = 4 if process == 'born_eq' else 5
                self.assertEqual(assignments, [(str(i), 'ZERO') for i in range(1, n+1)])
                driver = m.driver_source('MATRIX', n).upper()
                self.assertIn('IMPLICIT NONE', driver)
                initialization = driver.index('CALL SETPARA(')
                for declaration in declarations:
                    self.assertLess(driver.index(declaration), initialization)
                self.assertLess(initialization, driver.index("INCLUDE 'PMASS.INC'"))

    def test_actual_mg370_driver_and_fixture_provenance(self):
        manifest = json.loads((self.fixture_root/'PROVENANCE.json').read_text())
        for name, entry in manifest['files'].items():
            with self.subTest(fixture=name):
                self.assertEqual(m.sha(self.fixture_root/name), entry['sha256'])
                self.assertEqual((self.fixture_root/name).stat().st_size, entry['bytes'])
        driver = (self.fixture_root/'check_sa.f').read_text()
        self.assertIn("call setpara('param_card.dat')  !first call", driver)
        self.assertEqual(m.initialization_call(driver), self.canonical)
        self.assertEqual(len(manifest['files']['check_sa.f']['archive_paths']), 6)

    def test_actual_mg370_matrices_need_no_template_change(self):
        for process in m.PROCESSES:
            with self.subTest(process=process):
                original = (self.fixture_root/f'{process}.matrix.original.f').read_text()
                instrumented, name = m.instrument_matrix(original)
                self.assertEqual(name, 'MATRIX')
                self.assertEqual(instrumented.count('AUDITAMP=JAMP(1)'), 1)
                self.assertIn('AUDITCOLOR=DBLE(CF(1))/DBLE(DENOM)', instrumented)
                retained = ''.join(line for line in instrumented.splitlines(keepends=True)
                                   if not any(token in line for token in ('AUDITAMP', 'AUDITCOLOR', 'AUDITCAPTURE')))
                self.assertEqual(retained, original)

    def test_inline_comments_one_and_two_argument_calls(self):
        for line, expected in (
            ("      call setpara('param_card.dat') ! setup\n", self.canonical),
            ('      CALL SETPARA("param_card.dat",.true.) ! setup\n', self.canonical[:-1]+', .TRUE.)'),
            ("      CALL SETPARA('param_card.dat', .FALSE.)! setup\n", self.canonical[:-1]+', .FALSE.)'),
        ):
            with self.subTest(line=line):
                self.assertEqual(m.initialization_call(line), expected)

    def test_exclamation_marks_and_doubled_quotes_remain_literal_data(self):
        for filename in ("'cards!parameter.dat'", '"cards!parameter.dat"',
                         "'cards''quoted!parameter.dat'", '"cards""quoted!parameter.dat"',
                         "'text CALL SETPARA(!inside.dat'"):
            with self.subTest(filename=filename):
                self.assertEqual(m.initialization_call('      CALL SETPARA('+filename+') ! call SETPARA(other)\n'), self.canonical)

    def test_commented_calls_and_string_mentions_are_inactive(self):
        extras = [
            "C     CALL SETPARA(dynamic)\n", "c     CALL SETPARA(dynamic)\n",
            "*     CALL SETPARA(dynamic)\n", "!     CALL SETPARA(dynamic)\n",
            "      ! CALL SETPARA(dynamic)\n",
            '      WRITE(*,*) "CALL SETPARA(dynamic)"\n',
        ]
        for extra in extras:
            with self.subTest(extra=extra):
                self.assertEqual(m.initialization_call(extra+self.valid), self.canonical)

    def test_dynamic_and_unsupported_argument_forms_block(self):
        bad = [
            '      CALL SETPARA(PATH)\n',
            "      CALL SETPARA('param_card.dat', READLHA)\n",
            "      CALL SETPARA('param_card.dat', .TRUE., .FALSE.)\n",
            "      CALL SETPARA('param_card.dat'//SUFFIX)\n",
            "      CALL SETPARA('')\n", "      CALL SETPARA()\n",
            "      CALL SETPARA('param_card.dat', TRUE)\n",
        ]
        for statement in bad:
            with self.subTest(statement=statement):
                with self.assertRaises(m.Unsupported): m.initialization_call(statement)

    def test_all_active_calls_count_even_when_some_have_unsupported_arguments(self):
        for extra in (self.valid, '      CALL SETPARA(PATH)\n',
                      "      CALL SETPARA('param_card.dat', READLHA)\n",
                      '      CALL SETPARA; CALL PRINT()\n'):
            for combined in (self.valid+extra, extra+self.valid):
                with self.subTest(combined=combined):
                    with self.assertRaises(m.Unsupported): m.initialization_call(combined)

    def test_continuations_and_split_call_tokens_are_unsupported(self):
        variants = [
            "      CALL SETPARA('param_card.dat',\n     & .TRUE.)\n",
            "      CALL SETPARA('param_card.dat')\n     & ; CALL PRINT()\n",
            "      CALL SET\n     & PARA(PATH)\n",
            "      CA\n     & LL SETPARA(PATH)\n",
            "     &CALL SETPARA('param_card.dat')\n",
        ]
        for variant in variants:
            with self.subTest(variant=variant):
                with self.assertRaises(m.Unsupported): m.initialization_call(variant)
                with self.assertRaises(m.Unsupported): m.initialization_call(self.valid+variant)

    def test_extra_statements_and_conditional_initialization_are_unsupported(self):
        variants = [
            "      CALL SETPARA('param_card.dat'); CALL PRINT()\n",
            "      CALL PRINT(); CALL SETPARA('param_card.dat')\n",
            "      CALL SETPARA('param_card.dat'); CALL SETPARA(PATH)\n",
            "      IF (FIRST) CALL SETPARA('param_card.dat')\n",
        ]
        for variant in variants:
            with self.subTest(variant=variant):
                with self.assertRaises(m.Unsupported): m.initialization_call(variant)

    def test_unterminated_literals_and_missing_calls_block(self):
        for source in ("      CALL SETPARA('param_card.dat) ! setup\n",
                       "      PROGRAM EMPTY\n      END\n",
                       "C     CALL SETPARA('param_card.dat')\n"):
            with self.subTest(source=source):
                with self.assertRaises(m.Unsupported): m.initialization_call(source)


class GateTests(unittest.TestCase):
    def test_absent_madgraph_is_blocked_never_native_pass(self):
        with tempfile.TemporaryDirectory() as d:
            checks=m.run_checks(d,d,{},d,1729)
        self.assertTrue(any(c['status']=='BLOCKED' for c in checks))
        self.assertFalse(any(c['id'].startswith('madgraph.native_covariant') for c in checks))

    def test_missing_adapter_is_blocked_even_if_native_fixture_agrees(self):
        with tempfile.TemporaryDirectory() as d, patch.object(m,'native_process') as native:
            def fixture(name,requests,cfg,dest):
                return {i:{key:m.covariant(r,key=='UT') for key in (('UU',) if name=='real_eg' else ('UU','UT'))} for i,r in enumerate(requests,1)}
            native.side_effect=fixture
            checks=m.run_checks(d,d,{'madgraph':{'root':d}},d,1729)
        self.assertTrue(any(c['id']=='madgraph.candidate.adapter' and c['status']=='BLOCKED' for c in checks))

    def test_stale_response_fails_and_missing_native_does_not_pass(self):
        with tempfile.TemporaryDirectory() as d:
            (Path(d)/'candidate-response.json').write_text('{}')
            checks=m.run_checks(d,d,{'madgraph':{'root':d},'madgraph_candidate_command':['false']},d,1729)
        self.assertTrue(any(c['id']=='madgraph.candidate.freshness' and c['status']=='FAIL' for c in checks))
        self.assertEqual(sum(c['status']=='BLOCKED' for c in checks),3)

    def test_candidate_booleans_nonfinite_duplicates_and_missing_rows_fail(self):
        req=m.points(9,1)
        rows=[dict(id=r['id'],UU=1.,**({} if r['process']=='real_eg' else {'UT':.2})) for r in req]
        self.assertEqual(len(m.validate_candidate({'schema':1,'rows':rows},req)),3)
        for bad in (True,float('nan'),float('inf'),None):
            mutated=copy.deepcopy(rows);mutated[0]['UU']=bad
            with self.assertRaises(ValueError): m.validate_candidate({'schema':1,'rows':mutated},req)
        for invalid in ({'schema':True,'rows':rows},{'schema':1,'rows':rows+rows[:1]},{'schema':1,'rows':rows[:-1]}):
            with self.assertRaises(ValueError): m.validate_candidate(invalid,req)


def write_synthetic_born_archive(dest, seed):
    """Temporary unit-test evidence; never emitted as native run evidence."""
    req=m.points(seed)
    root=Path(dest)
    (root/'requests.json').write_text(json.dumps({'schema':1,'seed':seed,'rows':req},indent=2)+'\n')
    candidate={'schema':1,'rows':[dict(id=r['id'],UU=m.covariant(r),UT=m.covariant(r,True)) for r in req]}
    (root/'candidate-response.json').write_text(json.dumps(candidate)+'\n')
    process=root/'born_eq';sub=process/'standalone/SubProcesses/P0_born'
    sub.mkdir(parents=True)
    cards=process/'standalone/Cards';cards.mkdir()
    original=(Path(m.__file__).parent/'madgraph_templates/square_scalar.f').read_text()
    (process/'matrix.original.f').write_text(original)
    instrumented,symbol=m.instrument_matrix(original)
    (sub/'matrix.f').write_text(instrumented)
    setpara="CALL SETPARA('../../Cards/param_card.dat')"
    (sub/'check_sa.f').write_text(m.driver_source(symbol,4,setpara))
    (sub/'check').write_text('SYNTHETIC UNIT TEST; NOT A COMPILED EXECUTABLE\n')
    (cards/'param_card.dat').write_text(m.parameter_card('BLOCK SMINPUTS\n 1 137.0\n 3 .118\nBLOCK MASS\n 11 0.\n 2 0.\n 21 0.\n'))
    for filename in ('generate.mg5','generation.log','build-source.log','build-subprocess.log'):
        (process/filename).write_text('SYNTHETIC UNIT TEST; NOT A NATIVE RUN\n')
    data=str(len(req))+'\n'+'\n'.join(' '.join(format(x,'.17e') for x in p) for r in req for p in r['momenta'])+'\n'
    (process/'momenta.txt').write_text(data)
    output=''.join(native_fixture(r).replace('MGUU 1 ',f'MGUU {i} ').replace('MGAMP 1 ',f'MGAMP {i} ').replace('MGSPIN 1 ',f'MGSPIN {i} ') for i,r in enumerate(req,1))
    (process/'native-output.txt').write_text(output)
    native=m.parse_native(output,req)
    values={r['id']:{key:native[i][key] for key in ('UU','UT')} for i,r in enumerate(req,1)}
    (root/'native-values.json').write_text(json.dumps(values)+'\n')
    artifact_names=('generate.mg5','matrix.original.f','momenta.txt','native-output.txt','generation.log','build-source.log','build-subprocess.log')
    manifest={'schema':1,'process':'born_eq','request_ids':[r['id'] for r in req],
              'mg5_entry_sha256':m.sha(sub/'check'),'mg5_version':'SYNTHETIC TEST ONLY',
              'original_matrix_sha256':m.sha(process/'matrix.original.f'),
              'candidate_before_native_generation_sha256':m.sha(root/'candidate-response.json'),
              'artifacts':{name:m.sha(process/name) for name in artifact_names},
              'generated_build':{str(p.relative_to(process/'standalone')):m.sha(p) for p in (process/'standalone').rglob('*') if p.is_file()},
              'native_tree':m.snapshot_native_tree(process/'standalone'),
              'subprocess':'SubProcesses/P0_born','matrix_symbol':symbol,'setpara_call':setpara}
    (process/'build-identities.json').write_text(json.dumps(manifest)+'\n')
    expected=[m.record('phase_space','PASS',{'points':len(req),'requests_sha256':m.sha(root/'requests.json')}),
              m.record('candidate.freshness','PASS',{'response_sha256':m.sha(root/'candidate-response.json'),'answered_before_native_generation':True})]
    for i,r in enumerate(req,1): expected.extend(m.native_comparisons(r,native[i]))
    expected.extend(m.candidate_comparisons(req,m.validate_candidate(candidate,req),values))
    return expected


class ReplayTests(unittest.TestCase):
    def setUp(self):
        self.directory=tempfile.TemporaryDirectory()
        self.addCleanup(self.directory.cleanup)
        self.patch=patch.object(m,'PROCESSES',{'born_eq':m.PROCESSES['born_eq']})
        self.patch.start();self.addCleanup(self.patch.stop)
        self.root=Path(self.directory.name)
        self.expected=write_synthetic_born_archive(self.root,1729)

    def test_core_recomputed_from_raw_amplitudes_without_status_file(self):
        self.assertEqual(m.replay_checks(self.root,1729),self.expected)
        self.assertTrue(all(c['status']=='PASS' for c in self.expected))

    def test_changed_seed_and_cached_values_are_rejected(self):
        result=m.replay_checks(self.root,92741)
        self.assertEqual(result[-1]['status'],'FAIL')
        values=json.loads((self.root/'native-values.json').read_text())
        values['born_eq.0']['UU']=True
        (self.root/'native-values.json').write_text(json.dumps(values))
        self.assertEqual(m.replay_checks(self.root,1729)[-1]['status'],'FAIL')

    def test_missing_native_output_cannot_pass_replay(self):
        (self.root/'born_eq/native-output.txt').unlink()
        self.assertEqual(m.replay_checks(self.root,1729)[-1]['status'],'BLOCKED')

    def test_changed_raw_amplitude_detected_even_after_hash_update(self):
        process=self.root/'born_eq'
        p=process/'native-output.txt'
        lines=p.read_text().splitlines()
        fields=lines[1].split();fields[3]='1.25';lines[1]=' '.join(fields)
        p.write_text('\n'.join(lines)+'\n')
        self.assertEqual(m.replay_checks(self.root,1729)[-1]['status'],'FAIL')
        manifest=json.loads((process/'build-identities.json').read_text())
        manifest['artifacts']['native-output.txt']=m.sha(p)
        (process/'build-identities.json').write_text(json.dumps(manifest))
        result=m.replay_checks(self.root,1729)
        self.assertEqual(result[-1]['status'],'FAIL')
        self.assertIn('JAMP',result[-1]['detail'])

    def test_changed_native_driver_detected_even_after_hash_update(self):
        process=self.root/'born_eq'
        p=process/'standalone/SubProcesses/P0_born/check_sa.f'
        p.write_text(p.read_text().replace('CALL OXXXXX','CALL IXXXXX'))
        manifest=json.loads((process/'build-identities.json').read_text())
        manifest['generated_build']['SubProcesses/P0_born/check_sa.f']=m.sha(p)
        manifest['native_tree']=m.snapshot_native_tree(process/'standalone')
        (process/'build-identities.json').write_text(json.dumps(manifest))
        result=m.replay_checks(self.root,1729)
        self.assertEqual(result[-1]['status'],'FAIL')
        self.assertIn('driver',result[-1]['detail'])


    def test_changed_link_spelling_rejected_by_native_replay(self):
        process=self.root/'born_eq';native=process/'standalone'
        (native/'Source').mkdir()
        (native/'Source/target.inc').write_text('fixture')
        link=native/'Source/alias.inc';link.symlink_to('target.inc')
        manifest=json.loads((process/'build-identities.json').read_text())
        manifest['native_tree']=m.snapshot_native_tree(native)
        (process/'build-identities.json').write_text(json.dumps(manifest))
        self.assertTrue(all(c['status']=='PASS' for c in m.replay_checks(self.root,1729)))
        link.unlink();link.symlink_to('./target.inc')
        result=m.replay_checks(self.root,1729)
        self.assertEqual(result[-1]['status'],'FAIL')
        self.assertIn('link evidence changed',result[-1]['detail'])

    def test_optional_dangling_link_can_be_recorded_but_not_supply_output(self):
        process=self.root/'born_eq';native=process/'standalone'
        (native/'Source').mkdir()
        (native/'Source/optional.inc').symlink_to('not_generated.inc')
        manifest=json.loads((process/'build-identities.json').read_text())
        manifest['native_tree']=m.snapshot_native_tree(native)
        (process/'build-identities.json').write_text(json.dumps(manifest))
        self.assertTrue(all(c['status']=='PASS' for c in m.replay_checks(self.root,1729)))
        (process/'native-output.txt').unlink()
        self.assertNotEqual(m.replay_checks(self.root,1729)[-1]['status'],'PASS')


if __name__=='__main__':
    unittest.main()
