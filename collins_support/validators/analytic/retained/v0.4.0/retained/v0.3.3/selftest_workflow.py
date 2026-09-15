#!/usr/bin/env python3
"""Mocked orchestration regression tests only; no physics is evaluated here.

These tests replace external runtime discovery and process execution with local
fixtures. They exercise the real workflow, evidence checks, dependency hashing,
baseline preservation and resume audit. A passing result does not certify any
Wolfram expression, Kira reduction, SubTropica integral or analytic calculation.

Place this file beside workflow.py in the installed validator. During release
development it can also run from analytic_scaffold_work/tests_draft/.
"""
from __future__ import annotations

import argparse
import contextlib
import copy
import hashlib
import importlib
import io
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest
from unittest.mock import patch


HERE = Path(__file__).resolve().parent
VALIDATOR = HERE if (HERE / "workflow.py").is_file() else (
    HERE.parent / "release" / "SIDIS-analytic-validation-v0.1.1"
)
sys.path.insert(0, str(VALIDATOR))
workflow = importlib.import_module("workflow")


class WorkflowOrchestrationTests(unittest.TestCase):
    """Every generated expression/report in this class is a mocked test fixture."""

    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory(prefix="collins-mocked-workflow-")
        self.addCleanup(self.temporary.cleanup)
        self.root = Path(self.temporary.name)
        self.repo = self.root / "bigTMD"
        self.repo.mkdir()
        self.git("init", "--quiet")
        (self.repo / "original.txt").write_text("Preserved original tracked source.\n")
        (self.repo / "original-link").symlink_to("original.txt")
        self.git("add", "original.txt", "original-link")
        self.git("-c", "user.name=Scaffold selftest", "-c",
                 "user.email=selftest@example.invalid", "commit", "--quiet", "-m", "Fixture")
        self.numerics = self.repo / "collins_ep"
        self.numerics.mkdir()
        (self.numerics / "existing.py").write_text("# protected numerical fixture\n")
        self.production = self.repo / "collins_ep_analytic"
        self.production.mkdir()
        self.stages = [s for s in workflow.stage_list() if int(s["id"][1:]) <= 9]
        self.start_patch("stage_list", lambda: self.stages)
        self.start_patch("check_foundation", lambda production: {"scope": "MOCKED foundation lock"})
        self.by_id = {stage["id"]: stage for stage in self.stages}
        for stage in self.stages:
            script = self.production / stage["script"]
            script.parent.mkdir(parents=True, exist_ok=True)
            script.write_text("# MOCKED ORCHESTRATION FIXTURE ONLY; never executed.\n")
        self.runtime_config = {"wolfram_kernel": "/MOCK_ONLY/WolframKernel",
                               "stage_timeout_seconds": 30}
        workflow.write(self.production / "runtime.json", self.runtime_config)
        self.runtime_identity = "mock-runtime-version-1"
        self.numerical_state = self.root / "SIDIS-validation-state"
        self.numerical_state.mkdir()
        tracked = self.repo / "original.txt"
        # This is the exact schema emitted by the retained numerical init command.
        baseline = {
            "schema": 1, "repo": str(self.repo), "head": self.git("rev-parse", "HEAD"),
            "origin": "https://example.invalid/mocked-fixture.git",
            "files": {"original.txt": {
                "sha256": workflow.sha(tracked), "git_mode": "100644",
                "is_symlink": False, "executable": bool(tracked.stat().st_mode & 0o111),
            }, "original-link": {
                "sha256": hashlib.sha256(b"symlink\0original.txt").hexdigest(),
                "git_mode": "120000", "is_symlink": True,
                "executable": bool((self.repo / "original-link").lstat().st_mode & 0o111),
            }}, "initial_status": "",
        }
        workflow.write(self.numerical_state / "baseline.json", baseline)
        workflow.write(self.numerical_state / "historical-report.json",
                       {"scope": "MOCKED historical fixture", "preserve": True})
        self.state = self.root / "SIDIS-analytic-state"
        self.calls = []
        self.stage_cache_flags = []
        self.stage_exit = {}
        self.proof_exit = {}
        self.omit_artifact = {}
        self.bad_evidence = {}
        self.bad_proof = {}
        self.effects = {}
        self.latest_run = None
        self.start_patch("runtime_record", self.fake_runtime_record)
        self.start_patch("execute", self.fake_execute)
        # Packaging integrity is independently tested against the exact ZIP.
        # This constant keeps orchestration tests usable before manifests exist.
        self.start_patch("release_integrity", lambda root: "MOCKED-RELEASE-INTEGRITY")

    def start_patch(self, name, replacement):
        patcher = patch.object(workflow, name, replacement)
        patcher.start()
        self.addCleanup(patcher.stop)

    def git(self, *arguments):
        completed = subprocess.run(["git", "-C", str(self.repo), *arguments],
                                   text=True, capture_output=True, check=True,
                                   env={**os.environ, "GIT_OPTIONAL_LOCKS": "0"})
        return completed.stdout.strip()

    def fake_runtime_record(self, path):
        return {"config": workflow.read(path),
                "hashes": {"MOCK_ONLY": self.runtime_identity}}

    def fake_execute(self, command, cwd, log, timeout, env=None):
        self.assertIsNotNone(env)
        context = workflow.read(env["COLLINS_ANALYTIC_CONTEXT"])
        sid = context["stage"]
        stage = self.by_id[sid]
        proof = Path(command[-1]).name == "check_proofs.wls"
        kind = "proof" if proof else "stage"
        self.calls.append((kind, sid, copy.deepcopy(context)))
        if not proof:
            self.stage_cache_flags.append((sid, env.get("COLLINS_ANALYTIC_NO_CACHE")))
        output = Path(context["output"])
        log = Path(log)
        log.write_text(f"MOCKED ORCHESTRATION ONLY: {kind} {sid}\n")
        code = (self.proof_exit if proof else self.stage_exit).get(sid, 0)
        if code == 0 and proof:
            report = {"schema": 1, "stage": sid, "run_id": context["run_id"],
                      "status": "PASS", "proof_ids": stage["proof_ids"],
                      "test_scope": "MOCKED ORCHESTRATION ONLY; no proof evaluated"}
            report.update(self.bad_proof.get(sid, {}))
            workflow.write(output / "proof-check.json", report)
        elif code == 0:
            for name in stage["artifacts"]:
                if name == self.omit_artifact.get(sid):
                    continue
                artifact = output / name
                artifact.parent.mkdir(parents=True, exist_ok=True)
                artifact.write_text(f"MOCKED ORCHESTRATION ONLY: {sid}/{name}\n")
            evidence = {"schema": 1, "stage": sid, "run_id": context["run_id"],
                        "status": "CANDIDATE_COMPLETE"}
            evidence.update(self.bad_evidence.get(sid, {}))
            workflow.write(output / "evidence.json", evidence)
            if sid in self.effects:
                self.effects[sid](context, output)
        return {"argv": command, "exit_code": code, "elapsed_seconds": 0.0,
                "log_sha256": workflow.sha(log)}

    def run_workflow(self, through="s09", resume=None):
        arguments = argparse.Namespace(repo=str(self.repo), state=str(self.state),
                                       numerical_state=str(self.numerical_state),
                                       through=through, resume=str(resume) if resume else None)
        output = io.StringIO()
        with contextlib.redirect_stdout(output):
            code = workflow.run_workflow(arguments)
        for line in output.getvalue().splitlines():
            if line.startswith("{"):
                record = json.loads(line)
                if "run" in record:
                    self.latest_run = Path(record["run"])
        self.assertIsNotNone(self.latest_run, output.getvalue())
        return code, workflow.read(self.latest_run / "run.json")

    def successful_run(self, through="s09"):
        code, record = self.run_workflow(through)
        self.assertEqual(code, 0, record)
        self.assertEqual(record["status"], "STAGES_PASS")
        return self.latest_run

    def assert_audit_rejects(self):
        with self.assertRaises((ValueError, workflow.Blocked, FileNotFoundError)):
            workflow.audit_run(self.latest_run, self.production)

    def test_fresh_all_stages_records_real_orchestration_dependencies(self):
        originals = workflow.snapshot(self.numerics)
        historical = workflow.snapshot(self.numerical_state)
        run = self.successful_run()
        stages = [sid for kind, sid, _ in self.calls if kind == "stage"]
        self.assertEqual(stages, [stage["id"] for stage in self.stages])
        self.assertEqual(len(self.calls), len(self.stages) + sum(bool(s["proof_ids"]) for s in self.stages))
        manifest, done = workflow.audit_run(run, self.production)
        self.assertEqual(set(done), set(self.by_id))
        self.assertEqual(workflow.snapshot(self.numerics), originals)
        self.assertEqual(workflow.snapshot(self.numerical_state), historical)
        self.assertEqual(set(done["s09"]["dependencies"]), {"s07", "s08"})
        self.assertEqual(manifest["baseline_before"], manifest["baseline_after"])
        self.assertFalse(manifest["resumed"])
        self.assertTrue(all(receipt["no_cache_requested"] for receipt in done.values()))
        self.assertTrue(all(flag == "1" for _, flag in self.stage_cache_flags))

    def test_unchanged_resume_performs_no_execution(self):
        run = self.successful_run()
        before = len(self.calls)
        code, record = self.run_workflow(resume=run)
        self.assertEqual((code, record["status"]), (0, "STAGES_PASS"))
        self.assertEqual(len(self.calls), before)
        self.assertTrue(record["resumed"])

    def test_second_fresh_run_uses_new_nonce_and_executes_every_stage(self):
        first = self.successful_run()
        first_id = workflow.read(first / "run.json")["run_id"]
        before = len(self.calls)
        second = self.successful_run()
        second_id = workflow.read(second / "run.json")["run_id"]
        self.assertNotEqual(first, second)
        self.assertNotEqual(first_id, second_id)
        self.assertEqual(len(self.calls), 2 * before)

    def test_missing_required_artifact_fails_without_checkpoint(self):
        self.omit_artifact["s02"] = "definitions.wl"
        code, record = self.run_workflow()
        self.assertEqual((code, record["status"]), (1, "FAIL"))
        self.assertFalse((self.latest_run / "receipts/s02.json").exists())
        self.assertNotIn("s03", [sid for kind, sid, _ in self.calls if kind == "stage"])

    def test_stale_stage_nonce_fails(self):
        self.bad_evidence["s02"] = {"run_id": "old-fixture-nonce"}
        code, record = self.run_workflow()
        self.assertEqual((code, record["status"]), (1, "FAIL"))
        self.assertIn("stale", record["detail"])

    def test_stale_proof_nonce_fails(self):
        self.bad_proof["s02"] = {"run_id": "old-fixture-nonce"}
        code, record = self.run_workflow()
        self.assertEqual((code, record["status"]), (1, "FAIL"))
        self.assertIn("proof", record["detail"])

    def test_missing_proof_id_fails(self):
        self.bad_proof["s02"] = {"proof_ids": []}
        code, record = self.run_workflow()
        self.assertEqual((code, record["status"]), (1, "FAIL"))

    def test_nonzero_stage_exit_is_failure(self):
        self.stage_exit["s04"] = 7
        code, record = self.run_workflow()
        self.assertEqual((code, record["status"]), (1, "FAIL"))
        self.assertFalse((self.latest_run / "receipts/s04.json").exists())

    def test_exit_two_is_blocked_and_can_resume_completed_checkpoints(self):
        self.stage_exit["s04"] = 2
        code, record = self.run_workflow()
        self.assertEqual((code, record["status"]), (2, "BLOCKED"))
        run = self.latest_run
        self.stage_exit.clear()
        before = len(self.calls)
        code, record = self.run_workflow(resume=run)
        self.assertEqual((code, record["status"]), (0, "STAGES_PASS"))
        resumed = [sid for kind, sid, _ in self.calls[before:] if kind == "stage"]
        self.assertEqual(resumed, ["s04", "s05", "s06", "s07", "s08", "s09"])
        self.assertEqual(len(list((run / "previous_runs").iterdir())), 1)
        self.assertTrue(record["resumed"])
        receipt = workflow.read(run / "receipts/s09.json")
        self.assertFalse(receipt["no_cache_requested"])
        self.assertTrue(all(flag == "0" for _, flag in self.stage_cache_flags[-6:]))

    def test_nonzero_proof_execution_is_failure(self):
        self.proof_exit["s03"] = 3
        code, record = self.run_workflow()
        self.assertEqual((code, record["status"]), (1, "FAIL"))
        self.assertFalse((self.latest_run / "receipts/s03.json").exists())

    def test_changed_analytic_source_is_detected_before_resume_execution(self):
        self.successful_run()
        (self.production / self.by_id["s03"]["script"]).write_text("modified source\n")
        before = len(self.calls)
        self.assert_audit_rejects()
        with self.assertRaises(ValueError):
            self.run_workflow(resume=self.latest_run)
        self.assertEqual(len(self.calls), before)

    def test_changed_runtime_identity_is_detected(self):
        self.successful_run()
        self.runtime_identity = "mock-runtime-version-2"
        self.assert_audit_rejects()

    def test_changed_upstream_required_artifact_is_detected(self):
        self.successful_run()
        (self.latest_run / "common/s02_result/definitions.wl").write_text("modified expression\n")
        self.assert_audit_rejects()

    def test_added_raw_artifact_is_detected(self):
        self.successful_run()
        (self.latest_run / "common/s05_result/unrecorded-kira-output.txt").write_text("changed raw tree\n")
        self.assert_audit_rejects()

    def test_changed_execution_log_is_detected(self):
        self.successful_run()
        (self.latest_run / "common/s03_result/execution.log").write_text("modified process output\n")
        self.assert_audit_rejects()

    def test_changed_dependency_receipt_is_detected(self):
        self.successful_run()
        path = self.latest_run / "receipts/s03.json"
        receipt = workflow.read(path)
        receipt["unrecorded_edit"] = True
        workflow.write(path, receipt)
        self.assert_audit_rejects()

    def test_changed_historical_report_is_detected(self):
        self.successful_run()
        workflow.write(self.numerical_state / "historical-report.json", {"changed": True})
        self.assert_audit_rejects()

    def test_changed_numerical_source_is_detected(self):
        self.successful_run()
        (self.numerics / "existing.py").write_text("modified numerical source\n")
        self.assert_audit_rejects()

    def test_editing_baseline_is_detected(self):
        self.successful_run()
        path = self.numerical_state / "baseline.json"
        baseline = workflow.read(path)
        baseline["head"] = "edited-baseline-head"
        workflow.write(path, baseline)
        self.assert_audit_rejects()

    def test_original_tracked_source_edit_is_rejected_before_execution(self):
        (self.repo / "original.txt").write_text("changed original tracked source\n")
        with self.assertRaises(ValueError):
            self.run_workflow()
        self.assertEqual(self.calls, [])

    def test_audit_rechecks_original_tracked_sources(self):
        self.successful_run()
        (self.repo / "original.txt").write_text("original changed after completed run\n")
        self.assert_audit_rejects()

    def test_final_stage_mutation_of_earlier_artifact_is_rejected(self):
        def mutate_earlier(context, output):
            earlier = Path(context["inputs"]["s02"]) / "definitions.wl"
            earlier.write_text("downstream corruption of upstream artifact\n")
        self.effects["s09"] = mutate_earlier
        code, record = self.run_workflow()
        self.assertEqual((code, record["status"]), (1, "FAIL"))
        self.assertIn("Changed stage artifacts", record["detail"])


if __name__ == "__main__":
    print("MOCKED ORCHESTRATION SELFTESTS ONLY; no physics or external CAS execution.", flush=True)
    unittest.main(verbosity=2)
