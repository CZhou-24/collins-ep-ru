"""Focused checks for current execution without historical package dependencies."""
import copy
import io
import json
import sys
import tempfile
import unittest
from contextlib import redirect_stdout
from pathlib import Path
from unittest.mock import patch
import ru_support as u
import workflow as w
from paths import PROJECT, access, output_path


class CurrentPackage(unittest.TestCase):
    def test_release_without_retired_trees(self):
        self.assertFalse((u.ROOT/'retained').exists())
        self.assertFalse((PROJECT/'collins_ep_analytic').exists())
        self.assertEqual(u.release_integrity(),u.digest(u.ROOT/'MANIFEST.json'))

    def test_doctor_with_only_current_sources(self):
        # Stub only native discovery, since software tests do not execute Wolfram.
        stream=io.StringIO()
        with patch.object(sys,'argv',['workflow.py','doctor']), patch.object(w,'runtime',return_value={'fixture':True}), redirect_stdout(stream):
            self.assertEqual(w.main(),0)
        self.assertEqual(json.loads(stream.getvalue())['status'],'READY_TO_EXECUTE')

    def test_old_report_is_not_promoted(self):
        with tempfile.TemporaryDirectory() as tmp:
            run=Path(tmp)
            u.write(run/'run.json',{'schema':5,'profile':'reverse_unitarity','status':'STAGES_PASS','fresh':True})
            with self.assertRaises(u.Blocked):w.audit(run,PROJECT)

    def test_scalar_mismatch_fails_run_audit(self):
        with tempfile.TemporaryDirectory() as tmp:
            run=Path(tmp);sources=u.snapshot(PROJECT/u.ENGINE)
            r={'schema':5,'profile':u.PROFILE,'status':'STAGES_PASS','fresh':True,'repo':str(PROJECT),'release':u.release_integrity(),'sources':sources,'runtime':{},'sidis_sources':{},'reuse':{}}
            u.write(run/'run.json',r)
            with patch.object(w,'runtime',return_value={}),patch.object(w,'upstream_source_state',return_value={}),patch.object(w,'check_reuse',return_value={}),patch.object(w,'scientific_audit',return_value={'rows':[{'id':'reference.bad','status':'FAIL'}]}):
                with self.assertRaisesRegex(ValueError,'comparisons failed'):w.audit(run,PROJECT)

    def test_missing_current_executable_rejected(self):
        with tempfile.TemporaryDirectory() as tmp:
            package=Path(tmp)
            u.write(package/'MANIFEST.json',{'profile':u.PROFILE,'files':{'absent.py':'invalid'},'support_files':{}})
            with patch.object(u,'ROOT',package):
                with self.assertRaisesRegex(ValueError,'contents changed'):u.release_integrity()

    def test_relative_paths_use_checkout(self):
        self.assertEqual(access('collins_support/paths.py'),PROJECT/'collins_support/paths.py')

    def test_output_symlink_cannot_redirect(self):
        with tempfile.TemporaryDirectory() as tmp:
            repo=Path(tmp);support=repo/'collins_support';support.mkdir()
            other=repo/'engine';other.mkdir()
            (support/'reports').symlink_to(other,target_is_directory=True)
            with self.assertRaises(ValueError):output_path('collins_support/reports/run.json',repo,area='reports')

    def test_output_cannot_overwrite_run_evidence(self):
        with tempfile.TemporaryDirectory() as tmp:
            repo=Path(tmp);base=repo/'collins_support/reports/existing-evidence';base.mkdir(parents=True)
            with self.assertRaises(ValueError):output_path(base/'overwritten.json',repo,protected=[base],area='reports')
