#!/usr/bin/env python3
"""Focused reporting regressions; all native execution here is mocked.

Run with --repo pointing to the patched bigTMD root. This does not perform
physics acceptance or change any production data.
"""
import argparse
import hashlib
import importlib.util
import json
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest
from unittest.mock import patch

parser = argparse.ArgumentParser()
parser.add_argument('--repo', type=Path, required=True)
args, extra = parser.parse_known_args()
repo = args.repo.resolve()
sys.path.insert(0, str(repo / 'collins_support/validators/analytic'))


def module(name, filename):
    spec = importlib.util.spec_from_file_location(name, repo / 'collins_sidis_highpt/tools' / filename)
    result = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(result)
    return result


report = module('review_report', 'checks/build_campaign_report.py')
driver = module('review_driver', 'development/reproduce_development.py')


def write(path, value):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(value))


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


class ReportingTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.root = Path(self.tmp.name)
        self.reproduction = self.root / 'new-reproduction'
        self.reproduction.mkdir()
        self.run = self.root / 'run-r00'
        self.run.mkdir()
        self.old = self.root / 'old-campaign'
        self.old.mkdir()
        self.make_inputs(False)

    def make_inputs(self, partial):
        names = ['r00-native', 'angular', 'jet-native', 'jet-distributions',
                 'fragmentation', 'operator-scheme', 'diagnostic-export']
        if partial:
            names += ['real-contractions', 'real-map', 'real-ward', 'real-kira',
                      'real-kira-check', 'cut-master-depth', 'partial-real-distributions']
        self.meta = dict(report_root=str(self.reproduction), partial_real=partial,
                         native_run=str(self.run), steps=[dict(name=n, exit_code=0) for n in names])
        for name in names:
            (self.reproduction / (name + '.log')).write_text('')
        (self.reproduction / 'r00-native.log').write_text(json.dumps({'run': str(self.run)}) + '\n')
        write(self.reproduction / 'reproduction.json', self.meta)
        payload = self.reproduction / 'operator-scheme-002/native.wl'
        payload.parent.mkdir(exist_ok=True)
        payload.write_text('synthetic reporting fixture; no physical computation')
        self.diag = dict(report_root=str(self.reproduction), partial_real_present=partial,
                         input_sha256={str(payload): digest(payload)},
                         operator_differences=dict(ndr_minus_literal_all_D='retained nonzero difference',
                                                  ndr_minus_literal_through_eps1='0',
                                                  spacelike_bmhv_minus_ndr='0',
                                                  outgoing_bmhv_minus_ndr='retained outgoing difference'),
                         partial_real_endpoint_residuals=[], partial_real_reconstruction={},
                         fourier_residuals=['0', '0'], antiquark_point_present=False,
                         antiquark_point_qualification='NOT_RUN in this reproduction')
        write(self.reproduction / 'diagnostic-summary.json', self.diag)
        write(self.reproduction / 'jet-matching-002/jet-distribution-checks.json',
              dict(coefficient_rows=[], exact_test_function_actions=[],
                   numerical_test_function_actions=[], RG_residuals={}))
        if partial:
            write(self.reproduction / 'real-kira-check-001/summary.json',
                  dict(archive_difference_residuals={}, target_count=1, final_master_count=1,
                       covered_archive_targets=0, uncovered_archive_targets=1))
            write(self.reproduction / 'real-map-001/kira-input.json', dict(targets=[dict(family='R01', powers=[1, 1])]))

    def test_requested_evidence_used_and_mismatches_retained(self):
        write(self.old / 'diagnostic-summary.json', dict(operator_differences='OLD SENTINEL'))
        with patch.object(report, 'B', self.old):
            _, _, diag, kira, targets = report.load_reproduction_inputs(self.reproduction)
        self.assertEqual(diag['operator_differences']['outgoing_bmhv_minus_ndr'], 'retained outgoing difference')
        self.assertIsNone(kira)
        self.assertIsNone(targets)

    def test_missing_current_evidence_never_falls_back_to_old(self):
        write(self.old / 'diagnostic-summary.json', self.diag)
        (self.reproduction / 'diagnostic-summary.json').unlink()
        with patch.object(report, 'B', self.old), self.assertRaises(FileNotFoundError):
            report.load_reproduction_inputs(self.reproduction)

    def test_requested_partial_real_requires_current_reduction(self):
        self.make_inputs(True)
        _, _, _, kira, targets = report.load_reproduction_inputs(self.reproduction)
        self.assertEqual(kira['target_count'], 1)
        self.assertEqual(len(targets), 1)
        (self.reproduction / 'real-kira-check-001/summary.json').unlink()
        write(self.old / 'real-kira-check-001/summary.json', kira)
        with patch.object(report, 'B', self.old), self.assertRaises(FileNotFoundError):
            report.load_reproduction_inputs(self.reproduction)

    def test_failed_or_missing_export_step_rejected(self):
        self.meta['steps'][-1]['exit_code'] = 1
        write(self.reproduction / 'reproduction.json', self.meta)
        with self.assertRaisesRegex(ValueError, 'steps'):
            report.load_reproduction_inputs(self.reproduction)
        self.meta['steps'].pop()
        write(self.reproduction / 'reproduction.json', self.meta)
        with self.assertRaisesRegex(ValueError, 'steps'):
            report.load_reproduction_inputs(self.reproduction)

    def test_changed_or_external_diagnostic_input_rejected(self):
        payload = Path(next(iter(self.diag['input_sha256'])))
        payload.write_text('changed')
        with self.assertRaisesRegex(ValueError, 'external or changed'):
            report.load_reproduction_inputs(self.reproduction)
        oldfile = self.old / 'native.wl'
        oldfile.write_text('old')
        self.diag['input_sha256'] = {str(oldfile): digest(oldfile)}
        write(self.reproduction / 'diagnostic-summary.json', self.diag)
        with self.assertRaisesRegex(ValueError, 'external or changed'):
            report.load_reproduction_inputs(self.reproduction)

    def test_report_root_and_run_identity_rejected(self):
        self.diag['report_root'] = str(self.old)
        write(self.reproduction / 'diagnostic-summary.json', self.diag)
        with self.assertRaisesRegex(ValueError, 'root or partial-real'):
            report.load_reproduction_inputs(self.reproduction)
        self.make_inputs(False)
        (self.reproduction / 'r00-native.log').write_text(json.dumps({'run': str(self.old)}) + '\n')
        with self.assertRaisesRegex(ValueError, 'Native run'):
            report.load_reproduction_inputs(self.reproduction)

    def test_full_report_preserves_differences_and_skips_future_checks(self):
        engine = self.root / 'collins_sidis_highpt'
        engine.mkdir()
        old_engine = self.root / 'collins_ep_analytic_SIDIS'
        old_engine.mkdir()
        validator = self.root / 'collins_support/validators/analytic'
        validator.mkdir(parents=True)
        paths = self.root / 'collins_support/paths.py'
        paths.write_text('')
        checks = [dict(id='current', stage='r00', lhs='r00/value', kind='identity', rhs=0, reason='fixture'),
                  dict(id='future', stage='r07', lhs='r07/not-produced', kind='ir_poles', rhs=0, reason='future')]
        write(self.run / 'project.json', dict(checks=checks))
        write(self.run / 'result.json', dict(status='DEVELOPMENT_PASS', checks=[dict(status='PASS')]))
        write(self.run / 'common/r00_result/packet.json', dict(values={'r00/value': dict(value=0)}))
        write(self.run / 'run.json', dict(through='r00', status='EXECUTED', run_path=str(self.run),
                                        engine_sources=report.u.snapshot(engine), sources={}))
        write(self.old / 'preservation-before.json', dict(engine=report.u.snapshot(old_engine),
                                                        old_validator=report.u.snapshot(validator),
                                                        old_release='fixture', path_support_sha256=digest(paths),
                                                        runtime={'fixture': True}, reused_files={}))
        write(self.root / 'SIDIS/bigTMD_comparison/s04_result.json', dict(Channels={}))
        dest = self.root / 'report'
        with patch.multiple(report, ROOT=self.root, E=engine, B=self.old), \
             patch.object(report.u, 'runtime', return_value={'fixture': True}), \
             patch.object(report.u, 'release_integrity', return_value='fixture'), \
             patch.object(report.subprocess, 'run', return_value=subprocess.CompletedProcess([], 0, stdout='')), \
             patch.object(sys, 'argv', ['report', '--reproduction', str(self.reproduction), '--destination', str(dest)]):
            report.main()
        inventory = json.loads((dest / 'COMPARISON_INVENTORY.json').read_text())
        mismatches = [r for r in inventory['rows'] if r['status'] == 'MISMATCH']
        self.assertEqual(len(mismatches), 2)
        self.assertTrue(all(str(self.reproduction) in r['evidence'] for r in mismatches))
        self.assertNotIn('future', [r['id'] for r in inventory['rows']])
        self.assertIn('Partial-real replay: **NOT_RUN**', (dest / 'MILESTONE_REPORT.md').read_text())

    def test_driver_wires_current_run_and_export(self):
        root = self.root / 'driver-root'
        engine = root / 'collins_sidis_highpt'
        engine.mkdir(parents=True)
        write(root / 'collins_ep_analytic_SIDIS/ru_runtime.json', {'wolfram_kernel': '/mock/WolframKernel'})
        out = root / 'new-output'
        calls = []
        def execute(command, **kwargs):
            calls.append((command, dict(kwargs['env'])))
            if 'sidis_highpt.py' in command[1]:
                kwargs['stdout'].write(json.dumps({'run': str(self.run)}) + '\n')
            return subprocess.CompletedProcess(command, 0)
        with patch.multiple(driver, ROOT=root, E=engine), \
             patch.object(driver.subprocess, 'run', side_effect=execute), \
             patch.object(sys, 'argv', ['reproduce', '--reports', str(out)]):
            driver.main()
        self.assertTrue(calls[-1][0][-1].endswith('export_diagnostics.wls'))
        angular = next(env for command, env in calls if command[-1].endswith('angular_check.wls'))
        self.assertEqual(angular['SIDIS_BORN_RUN'], str(self.run))
        self.assertEqual(angular['SIDIS_HIGHPT_REPORT_ROOT'], str(out))
        record = json.loads((out / 'reproduction.json').read_text())
        self.assertFalse(record['partial_real'])
        self.assertEqual(record['steps'][-1]['name'], 'diagnostic-export')


unittest.main(argv=[sys.argv[0]] + extra, verbosity=2)
