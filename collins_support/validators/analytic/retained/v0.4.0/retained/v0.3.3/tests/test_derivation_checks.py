"""Harness tests: malformed evidence and seeded mistakes must be rejected.

Fixtures are synthetic. Their PASS does not certify a candidate derivation,
reference convention conversion, or any physical prediction.
"""
import copy
import json
import tempfile
import unittest
from fractions import Fraction
from pathlib import Path
from unittest.mock import patch

import derivation_checks as dc


def failing(checks):
    return [c for c in checks if c['status'] != 'PASS']


def scheme_packet(resolved=False):
    zero = {factor: dc.rat(0) for factor in ('hard', 'soft', 'beam', 'fragment')}
    return {'schema': 1, 'expressions': dc.reference_expressions(),
            'conventions': {
                'fragmentation_fourier': 'z^-2 integral d2b/(2pi)^2 exp(+i j.b/z)',
                'collins_vector': '-i b^alpha Hhat3/(2z)',
                'radial_rank1': 'contract with jhat; coefficient multiplies b^2 db J1(b*j/z)',
                'sudakov_log': 'LQ here denotes ln(Q^2/mu_b^2) for sudakov_fixed_coupling only',
                'rapidity_parameter': 'chi=ln(zeta_new/zeta_old); same b and mu; finite NP prescription external'},
            'physical_map': {
                'status': 'RESOLVED' if resolved else 'UNRESOLVED',
                'from_scheme': 'synthetic-regulator', 'to_scheme': 'synthetic-subtracted',
                'shift_uu': copy.deepcopy(zero), 'shift_ut': copy.deepcopy(zero),
                'native_evidence': ['common/d14_result/regulated_scheme.wl',
                                    'common/d13_result/regulated_integrals.wl',
                                    'common/d13_result/subtractions.wl'],
                'reference_note': 'Synthetic contract fixture, not a physical scheme proof.'}}


def assembly_packet():
    return {'schema': 1, 'coupling': 'alpha_s/(2*pi)',
            'expressions': dc.reference_assembly(),
            'truncation': 'O(a); A=A0+a*A1; no products of one-loop corrections',
            'inclusive_jet_multiplier': False,
            'input_roles': {'f0': 'symbolic_f1', 'd0': 'symbolic_D1',
                            't0': 'symbolic_h1', 'c0': 'symbolic_Hhat3',
                            'f1': 'derived_matching_convolution',
                            'd1': 'derived_matching_convolution',
                            't1': 'derived_matching_convolution',
                            'c1': 'derived_matching_convolution'}}


class ArithmeticTests(unittest.TestCase):
    def test_exact_rational_identity_without_sampling(self):
        z = dc.sym('z')
        self.assertTrue(dc.equal(dc.div(dc.add(1, dc.neg(dc.pow_(z, 2))),
                                       dc.add(1, dc.neg(z))), dc.add(1, z)))
        self.assertFalse(dc.equal(dc.add(1, z), dc.add(1, dc.pow_(z, 2))))

    def test_division_by_identically_zero_rejected(self):
        with self.assertRaises(dc.PacketError):
            dc.rational(dc.div(1, dc.add(dc.sym('z'), dc.neg(dc.sym('z')))))

    def test_unsupported_ast_and_boolean_numbers_rejected(self):
        for bad in ({'op': 'eval', 'code': '1'}, {'op': 'sym', 'name': 'provider'},
                    {'op': 'rat', 'num': True, 'den': 1},
                    {'op': 'pow', 'base': dc.sym('z'), 'exp': 100}):
            with self.subTest(bad=bad), self.assertRaises(dc.PacketError):
                dc.rational(bad)

    def test_endpoint_coefficient_cannot_hide_z_dependence(self):
        for key in ('delta', 'D0', 'D1'):
            with self.subTest(key=key), self.assertRaises(dc.PacketError):
                p = dc.distribution()
                p[key] = dc.sym('ell')
                dc.validate_distribution(p)

    def test_distribution_parts_not_interchangeable(self):
        self.assertFalse(dc.dist_equal(dc.distribution(delta=1), dc.distribution(D0=1)))


class MatchingTests(unittest.TestCase):
    def test_comparison_packet_contract(self):
        self.assertFalse(failing(dc.check_matching(dc.reference_matching())))

    def test_finite_endpoint_and_regular_mistakes_detected(self):
        for kernel, part in (('fqq', 'delta'), ('dqq', 'D0'), ('collins', 'regular'),
                             ('fqg', 'D1'), ('hqq', 'regular')):
            p = dc.reference_matching()
            p['coefficients'][kernel]['one_loop'][part] = dc.add(
                p['coefficients'][kernel]['one_loop'][part], dc.rat(1, 13))
            with self.subTest(kernel=kernel, part=part):
                self.assertTrue(failing(dc.check_matching(p)))

    def test_wrong_tree_gluon_coefficient_detected(self):
        p = dc.reference_matching()
        p['coefficients']['fqg']['tree']['delta'] = dc.rat(1)
        self.assertTrue(failing(dc.check_matching(p)))

    def test_wrong_splitting_endpoint_detected(self):
        p = dc.reference_matching()
        p['splitting']['qq']['delta'] = dc.sym('CF')
        self.assertTrue(failing(dc.check_matching(p)))

    def test_reference_target_cannot_be_silently_relabelled_native(self):
        p = dc.reference_matching()
        p['scheme'] = 'SIDIS-native'
        self.assertTrue(failing(dc.check_matching(p)))

    def test_missing_channel_rejected(self):
        p = dc.reference_matching()
        del p['coefficients']['collins']
        with self.assertRaises(dc.PacketError):
            dc.check_matching(p)

    def test_algebraically_rearranged_regular_term_accepted(self):
        p = dc.reference_matching()
        p['coefficients']['fqq']['one_loop']['regular'] = dc.add(
            dc.sym('CF'), dc.mul(-1, dc.sym('CF'), dc.sym('z')))
        self.assertFalse(failing(dc.check_matching(p)))


class SchemeAndAssemblyTests(unittest.TestCase):
    def test_unresolved_scheme_is_blocked_despite_exact_reference_formulas(self):
        bad = failing(dc.check_scheme(scheme_packet()))
        self.assertEqual([(c['id'], c['status']) for c in bad],
                         [('scheme.physical_map', 'BLOCKED')])

    def test_unknown_scheme_status_is_not_accepted(self):
        p = scheme_packet()
        p['physical_map']['status'] = 'PASS'
        with self.assertRaises(dc.PacketError):
            dc.check_scheme(p)

    def test_missing_companion_rapidity_shift_fails(self):
        p = scheme_packet(True)
        p['physical_map']['shift_ut']['beam'] = dc.sym('chi')
        self.assertTrue(failing(dc.check_scheme(p)))

    def test_scheme_evidence_labels_do_not_substitute_for_files(self):
        with tempfile.TemporaryDirectory() as tmp, self.assertRaises(FileNotFoundError):
            dc.check_scheme(scheme_packet(True), tmp)

    def test_rank_one_sign_and_z_power_detected(self):
        for replacement in (dc.div(1, dc.mul(4, dc.sym('pi'), dc.pow_(dc.sym('z'), 2))),
                            dc.neg(dc.reference_expressions()['fourier_rank1_radial'])):
            p = scheme_packet()
            p['expressions']['fourier_rank1_radial'] = replacement
            bad = failing(dc.check_scheme(p))
            self.assertIn('scheme.fourier_rank1_radial', [c['id'] for c in bad])

    def test_hard_finite_constant_difference_is_not_discarded(self):
        p = scheme_packet()
        p['expressions']['literal_hard_difference'] = dc.rat(0)
        self.assertIn('scheme.literal_hard_difference',
                      [c['id'] for c in failing(dc.check_scheme(p))])

    def test_formal_assembly_fixture(self):
        self.assertFalse(failing(dc.check_assembly(assembly_packet())))

    def test_retaining_product_of_one_loop_terms_fails(self):
        p = assembly_packet()
        p['expressions']['UU1'] = dc.add(p['expressions']['UU1'],
                                            dc.mul(dc.sym('HUU'), dc.sym('f1'), dc.sym('d1')))
        self.assertTrue(failing(dc.check_assembly(p)))

    def test_extra_jet_and_fitted_inputs_rejected(self):
        p = assembly_packet()
        p['inclusive_jet_multiplier'] = True
        p['input_roles']['t0'] = 'fitted_transversity_grid'
        ids = {c['id'] for c in failing(dc.check_assembly(p))}
        self.assertEqual(ids, {'assembly.no_extra_inclusive_jet', 'assembly.input_roles'})

    def test_unexpanded_ratio_correction_fails(self):
        p = assembly_packet()
        p['expressions']['A1'] = dc.div(p['expressions']['UT1'], p['expressions']['UU1'])
        self.assertTrue(failing(dc.check_assembly(p)))


class EvidenceTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)

    def file(self, name, text='synthetic evidence; not a derivation\n'):
        p = self.root / name
        p.parent.mkdir(parents=True, exist_ok=True)
        p.write_text(text)
        return dc.sha(p)

    def manifest(self):
        all_evidence = {'source_note.md': self.file('source_note.md')}
        for stage, names in dc.REQUIRED_ARTIFACTS.items():
            for name in names:
                if name != 'derivation_manifest.json':
                    path = 'common/' + stage + '_result/' + name
                    all_evidence[path] = self.file(path)
        inventory = dc.read(dc.ROOT / 'equation_inventory.json')['equations']
        return {'schema': 1, 'equations': [
            {'id': r['id'], 'origin': r['required_origin'], 'agreement': 'NUMERICAL',
             'evidence': copy.deepcopy(all_evidence), 'reference': r['reference'] + ': synthetic fixture',
             'note': 'Only evidence-schema tests; native execution is tested separately.'}
            for r in inventory]}

    def test_duplicate_json_keys_and_nonfinite_values_rejected(self):
        for raw in ('{"schema":1,"schema":2}', '{"a":NaN}'):
            p = self.root / 'bad.json'
            p.write_text(raw)
            with self.subTest(raw=raw), self.assertRaises(dc.PacketError):
                dc.read(p)

    def test_symlink_and_path_traversal_rejected(self):
        self.file('real.wl')
        (self.root / 'alias.wl').symlink_to('real.wl')
        for name in ('alias.wl', '../real.wl', str(self.root / 'real.wl')):
            with self.subTest(name=name), self.assertRaises(dc.PacketError):
                dc.safe(self.root, name)

    def test_empty_and_stale_evidence_rejected(self):
        digest = self.file('proof.wl', '')
        with self.assertRaises(dc.PacketError):
            dc.evidence_hashes({'proof.wl': digest}, self.root)
        digest = self.file('proof.wl', 'first')
        self.file('proof.wl', 'changed')
        self.assertFalse(dc.evidence_hashes({'proof.wl': digest}, self.root))

    def test_inventory_schema_fixture(self):
        self.assertFalse(failing(dc.check_manifest(self.manifest(), self.root)))

    def test_required_derivation_cannot_be_relabelled_imported(self):
        p = self.manifest()
        r = next(r for r in p['equations'] if r['id'] == 'matching.collins')
        r['origin'] = 'EXTERNAL'
        self.assertTrue(failing(dc.check_manifest(p, self.root)))

    def test_dropping_inventory_row_rejected(self):
        p = self.manifest()
        p['equations'].pop()
        with self.assertRaises(dc.PacketError):
            dc.check_manifest(p, self.root)

    def test_hashing_only_final_output_cannot_meet_derivation_contract(self):
        p = self.manifest()
        r = next(r for r in p['equations'] if r['id'] == 'matching.collins')
        final = 'common/d13_result/finite_matching.json'
        r['evidence'] = {final: r['evidence'][final]}
        self.assertIn('inventory.derivation_evidence.matching.collins',
                      [c['id'] for c in failing(dc.check_manifest(p, self.root))])

    def test_unverified_required_derivation_blocks(self):
        p = self.manifest()
        p['equations'][0]['agreement'] = 'UNVERIFIED'
        bad = failing(dc.check_manifest(p, self.root))
        self.assertEqual(bad[0]['status'], 'BLOCKED')

    def test_declared_dependency_chain_cannot_skip_integral(self):
        names = ('operator_inputs', 'projection', 'regulated_integral', 'subtraction', 'finite_output')
        files = ('operator_inputs.json', 'projections.wl', 'regulated_integrals.wl',
                 'subtractions.wl', 'finite_matching.json')
        chain = []
        for i, (kind, name) in enumerate(zip(names, files)):
            path = 'common/d13_result/' + name
            chain.append({'kind': kind, 'path': path, 'sha256': self.file(path),
                          'depends_on': [] if i == 0 else [names[i-1]], 'native_symbol': 'Example'})
        graph = {'schema': 1, 'chains': {k: copy.deepcopy(chain) for k in dc.KERNELS}}
        self.assertFalse(failing(dc.check_graph(graph, self.root)))
        graph['chains']['collins'][3]['depends_on'] = ['projection']
        self.assertTrue(failing(dc.check_graph(graph, self.root)))


class UpstreamProbeTests(unittest.TestCase):
    def test_pole_times_epsilon_numerator_has_negative_finite_response(self):
        original = dc.reference_matching()
        _, altered = dc.mutation('qq_epsilon', Fraction(2, 7))
        point = {'CF': 4/3, 'TR': 1/2, 'z': 1/3, 'ell': -1.0986122886681098}
        for k in ('fqq', 'dqq'):
            before = dc.value(original['coefficients'][k]['one_loop']['regular'], point)
            after = dc.value(altered['coefficients'][k]['one_loop']['regular'], point)
            self.assertAlmostEqual(after-before, -16/63, places=14)
        self.assertEqual(original['coefficients']['collins'], altered['coefficients']['collins'])

    def test_exporter_ignoring_modified_numerator_fails(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            repo, run, evidence = root/'repo', root/'run', root/'evidence'
            library = repo/'collins_ep_analytic/common/d13_matching_library.wl'
            library.parent.mkdir(parents=True)
            library.write_text('(* MOCK library; never executed *)')
            dc.write(run/'common/d13_result/operator_inputs.json', dc.operator_inputs())

            def frozen_export(runtime, script, context, work):
                self.assertIn('CollinsMatchingFromOperatorInputs', script)
                self.assertNotEqual(dc.read(context['input']), dc.operator_inputs())
                dc.write(context['output'], dc.reference_matching())
                for name in ('projections.wl', 'regulated_integrals.wl', 'subtractions.wl'):
                    (Path(work)/name).write_text('MOCKED regenerated artifact')

            with patch.object(dc, 'native_call', frozen_export):
                checks = dc.upstream_checks(repo, run, {}, evidence, 1729)
            bad = failing(checks)
            self.assertTrue(bad)
            self.assertTrue(all(c['status'] == 'FAIL' for c in bad))
            self.assertEqual(dc.read(run/'common/d13_result/operator_inputs.json'), dc.operator_inputs())

    def test_existing_probe_output_cannot_be_reused(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            library = root/'repo/collins_ep_analytic/common/d13_matching_library.wl'
            library.parent.mkdir(parents=True)
            library.write_text('MOCK')
            dc.write(root/'run/common/d13_result/operator_inputs.json', dc.operator_inputs())
            (root/'evidence/upstream-qq_epsilon').mkdir(parents=True)
            with self.assertRaises(dc.PacketError):
                dc.upstream_checks(root/'repo', root/'run', {}, root/'evidence', 1729)

    def test_replay_detects_seed_input_and_execution_tampering(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            library = root/'repo/collins_ep_analytic/common/d13_matching_library.wl'
            library.parent.mkdir(parents=True)
            library.write_text('MOCK')
            dc.write(root/'run/common/d13_result/operator_inputs.json', dc.operator_inputs())

            def fake_native(runtime, script, context, work):
                # Synthetic packet fixture tests replay, not Wolfram/physics.
                work = Path(work)
                kind = work.name.removeprefix('upstream-')
                delta = Fraction(dc.read(work/'SCOPE.json')['delta'])
                dc.write(context['output'], dc.mutation(kind, delta)[1])
                for name in ('projections.wl', 'regulated_integrals.wl', 'subtractions.wl'):
                    (work/name).write_text('SYNTHETIC native record')
                (work/'probe.wls').write_text(script)
                dc.write(work/'context.json', context)
                (work/'native.log').write_text('MOCKED execution; no physical claim\n')
                dc.write(work/'execution.json', {'exit_code': 0,
                    'context_sha256': dc.sha(work/'context.json'),
                    'script_sha256': dc.sha(work/'probe.wls'),
                    'log_sha256': dc.sha(work/'native.log')})

            with patch.object(dc, 'native_call', fake_native):
                checks = dc.upstream_checks(root/'repo', root/'run', {}, root/'evidence', 1729)
            self.assertFalse(failing(checks))
            self.assertFalse(failing(dc.replay_upstream(root/'evidence', 1729)))
            self.assertTrue(failing(dc.replay_upstream(root/'evidence', 92741)))
            work = root/'evidence/upstream-qq_epsilon'
            saved = dc.read(work/'operator_inputs.json')
            dc.write(work/'operator_inputs.json', dc.operator_inputs())
            self.assertTrue(failing(dc.replay_upstream(root/'evidence', 1729)))
            dc.write(work/'operator_inputs.json', saved)
            (work/'probe.wls').write_text('(* Altered runner *)')
            self.assertTrue(failing(dc.replay_upstream(root/'evidence', 1729)))

    def test_empty_run_is_blocked_never_pass(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            checks = dc.run_checks(root/'repo', root/'run', {}, root/'evidence', 1729)
            self.assertEqual(len(checks), 6)
            self.assertTrue(all(c['status'] == 'BLOCKED' for c in checks))
            self.assertTrue((root/'evidence/derivation_checks.json').is_file())


if __name__ == '__main__':
    unittest.main()
