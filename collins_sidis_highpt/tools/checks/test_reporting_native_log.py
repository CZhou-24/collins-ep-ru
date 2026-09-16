"""Regressions for the real validator's start/result run announcements."""
import json
from pathlib import Path
import runpy
import subprocess
import sys
import unittest
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[3]
with patch.object(sys, 'argv', ['test_reporting_fix.py', '--repo', str(ROOT)]), patch.object(unittest, 'main'):
    original = runpy.run_path(str(Path(__file__).with_name('test_reporting_fix.py')))
report = original['report']
driver = original['driver']


class NativeLogTests(original['ReportingTests']):
    def test_repeated_native_announcements_are_one_run(self):
        logfile = self.reproduction / 'r00-native.log'
        logfile.write_text(json.dumps({'run': str(self.run)}) + '\nprogress\n' +
                           json.dumps({'run': str(self.run), 'status': 'DEVELOPMENT_PASS'}) + '\n')
        meta, *_ = report.load_reproduction_inputs(self.reproduction)
        self.assertEqual(meta['native_run'], str(self.run))
        with logfile.open('a') as f:
            f.write(json.dumps({'run': str(self.old)}) + '\n')
        with self.assertRaisesRegex(ValueError, 'Native run'):
            report.load_reproduction_inputs(self.reproduction)

    def test_driver_accepts_repetition_and_rejects_conflict(self):
        root = self.root / 'native-driver'
        engine = root / 'collins_sidis_highpt'
        engine.mkdir(parents=True)
        original['write'](root / 'collins_ep_analytic_SIDIS/ru_runtime.json', {'wolfram_kernel': '/mock/WolframKernel'})
        for conflicting in [False, True]:
            out = root / ('conflicting' if conflicting else 'repeated')
            def execute(command, **kwargs):
                if 'sidis_highpt.py' in command[1]:
                    kwargs['stdout'].write(json.dumps({'run': str(self.run)}) + '\n')
                    kwargs['stdout'].write(json.dumps({'run': str(self.old if conflicting else self.run), 'status': 'DEVELOPMENT_PASS'}) + '\n')
                return subprocess.CompletedProcess(command, 0)
            with patch.multiple(driver, ROOT=root, E=engine), patch.object(driver.subprocess, 'run', side_effect=execute), patch.object(sys, 'argv', ['driver', '--reports', str(out)]):
                if conflicting:
                    with self.assertRaisesRegex(ValueError, 'one distinct native run'):
                        driver.main()
                else:
                    driver.main()
                    self.assertEqual(json.loads((out / 'reproduction.json').read_text())['native_run'], str(self.run))


if __name__ == '__main__':
    unittest.main(verbosity=2)
