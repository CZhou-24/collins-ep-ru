#!/usr/bin/env python3
"""Focused native jet comparison; read historical data and write only --out."""
import argparse
import collections
import hashlib
import json
import os
from pathlib import Path
import subprocess
import sys
import time

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
EP_RUN = "collins_support/states/runs/reverse-unitarity-003/20260915T063100Z-b8feba4db8fd"
HP_RUN = "collins_support/states/runs/sidis-highpt-001/continuation-001/native-campaign-002/physical/20260916T095719Z-1584d7f6dd71"


def digest(path):
    h = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            h.update(block)
    return h.hexdigest()


def dump(path, value):
    path.write_text(json.dumps(value, indent=2) + "\n")


def provenance(root, ep, hp):
    """Receipt hashes are checked, not replaced. Source changes are fail closed."""
    rows, completions = [], {}

    def record(path, role, expected=None, recorded_by=None):
        actual = digest(path)
        row = {"path": str(path.relative_to(root)), "role": role,
               "bytes": path.stat().st_size, "sha256": actual}
        if expected:
            row.update(recorded_sha256=expected, recorded_by=recorded_by,
                       matches_recorded=actual == expected)
            if actual != expected:
                from source_correction import verify_correction
                row["explicit_source_correction"] = verify_correction(root, path, expected)
        rows.append(row)

    ep_files = {
        "r00": ["measured_soft_operators.wl", "measured_tmd_operators.wl", "measured_hf_operators.wl"],
        "r01": ["measured_integrands.wl", "jobs/measured/reduction_certificate.wl"],
        "r02": ["jobs/measured/masters.wl", "jobs/measured/subtropica_execution.json"],
        "r03": ["measured_coefficients.wl", "packet.wl", "execution.log"],
        "r07": ["observable_assembly.wl", "convention_conversion.wl", "packet.wl", "execution.log"],
    }
    hp_files = {"r07": ["finite-jet/jet-matching-native.wl", "finite-jet/jet-matching-native.json",
                         "finite-jet.log", "jet-TMD-RG/rg.wl", "jet-TMD-RG.log", "observable.log",
                         "observable/UU_Hqq.wl", "observable/UT_Hqq.wl", "observable/hard-banks.wl",
                         "native-driver.json", "execution.log"]}
    ep_sources = ["CONVENTIONS.md", "common/r00_definitions.wls", "common/r01_real_map.wls",
                  "common/r02_real_masters.wls", "common/r03_real_assembly.wls", "common/r07_assembly.wls",
                  "common/ru_stage.wl", "common/ru_io.wl", "common/ru_soft_generation.wl",
                  "common/ru_soft_transforms.wl", "common/ru_soft_assembly.wl", "common/ru_tmd_generation.wl",
                  "common/ru_tmd_assembly.wl", "common/ru_hf_projection.wl", "common/ru_observable_helpers.wl"]
    hp_sources = ["common/fragmentation.wl", "common/jet_matching.wl", "common/tmd_evolution.wl",
                  "common/observable_assembly.wl", "common/observable_flavors.wl",
                  "common/observable_convolution.wl", "common/observable_distribution_actions.wl",
                  "references/2311.00672v2/source/main.tex"]
    for name, run, engine, files, sources, skey in [
            ("ep", ep, "collins_ep_analytic_SIDIS", ep_files, ep_sources, "sources"),
            ("highpt", hp, "collins_sidis_highpt", hp_files, hp_sources, "engine_sources")]:
        run_data = json.loads((run / "run.json").read_text())
        record(run / "run.json", "historical run identity/completion")
        completions[name] = {"run": str(run.relative_to(root)), "status": run_data["status"],
                             "through": run_data["through"], "stages": {}}
        for stage, names in files.items():
            receipt = run / "receipts" / f"{stage}.json"
            data = json.loads(receipt.read_text())
            record(receipt, "historical receipt")
            completion = {"exit_code": data["execution"]["exit_code"]}
            if completion["exit_code"] != 0:
                raise RuntimeError(f"Incomplete stage: {receipt}")
            completions[name]["stages"][stage] = completion
            for filename in names:
                f = run / "common" / f"{stage}_result" / filename
                record(f, "reused native expression/evidence", data["tree"][filename]["sha256"],
                       str(receipt.relative_to(root)))
        for filename in sources:
            record(root / engine / filename, "active generating source/reference",
                   run_data[skey][filename]["sha256"], str((run / "run.json").relative_to(root)))
        if name == "highpt":
            for basename in ("assemble_native_observable.wls", "jet_matching_check.wls", "jet_tmd_rg_check.wls"):
                current = root / engine / "tools/pipeline" / basename
                record(current, "relocated native producing script")
                old_bytes = current.read_bytes().replace(
                    b"DirectoryName[DirectoryName[DirectoryName[DirectoryName[$InputFileName]]]]",
                    b"DirectoryName[DirectoryName[DirectoryName[$InputFileName]]]")
                historical_hash = run_data[skey]["tools/" + basename]["sha256"]
                reconstructed = hashlib.sha256(old_bytes).hexdigest()
                if reconstructed != historical_hash:
                    raise RuntimeError(f"Producing script differs beyond documented root-depth move: {current}")
                rows[-1].update(historical_sha256=historical_hash,
                                historical_source_reconstruction_sha256=reconstructed,
                                historical_source_relation="Exact original hash after undoing only the extra DirectoryName for tools/pipeline relocation; no physics/body differences.")
            result = json.loads((run / "result.json").read_text())
            record(run / "result.json", "historical completion only, not new comparison evidence")
            completions[name].update(result_status=result["status"],
                                     historical_checks=dict(collections.Counter(x["status"] for x in result["checks"])))
            driver = json.loads((run / "common/r07_result/native-driver.json").read_text())
            completions[name]["jet_helper_jobs"] = [
                {k: job[k] for k in ("label", "status", "exit_code", "source_sha256", "log_sha256")}
                for job in driver if job.get("label") in ("finite-jet", "jet-TMD-RG", "observable")]
    for f in sorted(HERE.glob("*")):
        if f.is_file():
            record(f, "new comparison adapter/input")
    runtime = root / "collins_ep_analytic_SIDIS/ru_runtime.json"
    record(runtime, "unchanged active runtime configuration")
    return {"files": rows, "historical_completion": completions,
            "scope": "Relevant jet dependency evidence; no replay of full historical acceptance or hard calculations."}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--out", required=True, type=Path)
    parser.add_argument("--ep-run", type=Path, default=ROOT / EP_RUN)
    parser.add_argument("--highpt-run", type=Path, default=ROOT / HP_RUN)
    args = parser.parse_args()
    out = args.out.resolve()
    if not out.is_relative_to(ROOT / "collins_support/reports"):
        parser.error("--out must be under collins_support/reports")
    if out.exists():
        parser.error("Use a new output directory; historical outputs are never overwritten")
    out.mkdir(parents=True)
    context = {"repo": str(ROOT), "out": str(out), "ep_run": str(args.ep_run.resolve()),
               "highpt_run": str(args.highpt_run.resolve()), "production": str(ROOT / "collins_ep_analytic_SIDIS"),
               "output": str(out), "validation_probe": False}
    dump(out / "context.json", context)
    executions = []
    started = time.time()
    try:
        identities = provenance(ROOT, args.ep_run.resolve(), args.highpt_run.resolve())
        kernel = Path(json.loads((ROOT / "collins_ep_analytic_SIDIS/ru_runtime.json").read_text())["wolfram_kernel"])
        identities["wolfram"] = {"path": str(kernel), "sha256": digest(kernel)}
        identities["wolfram"]["historical_comparisons"] = {}
        for name, run in (("ep", args.ep_run), ("highpt", args.highpt_run)):
            historical = json.loads((run / "run.json").read_text())["runtime"]["identities"]["wolfram_kernel"]
            identities["wolfram"]["historical_comparisons"][name] = {
                "recorded": historical, "same_sha256": identities["wolfram"]["sha256"] == historical["sha256"]}
        dump(out / "provenance.json", identities)
        env = os.environ.copy()
        env.update(JET_NATIVE_CONTEXT=str(out / "context.json"), COLLINS_RU_CONTEXT=str(out / "context.json"),
                   JET_ACTION_REGRESSION_OUT=str(out / "distribution-regression"),
                   OMP_NUM_THREADS="1", OPENBLAS_NUM_THREADS="1", MKL_NUM_THREADS="1",
                   VECLIB_MAXIMUM_THREADS="1", NUMEXPR_NUM_THREADS="1")
        for script in ("regress_distribution_action.wls", "extract_native.wls", "compare_native.wls"):
            command = [str(kernel), "-noprompt", "-script", str(HERE / script)]
            log = out / (script.removesuffix(".wls") + ".log")
            print(f"Running {script}; log: {log}", flush=True)
            t = time.time()
            with log.open("w") as stream:
                completed = subprocess.run(command, cwd=ROOT, env=env, stdout=stream, stderr=subprocess.STDOUT)
            executions.append({"command": command, "exit_code": completed.returncode,
                               "elapsed_seconds": time.time() - t, "log": log.name, "log_sha256": digest(log)})
            if completed.returncode:
                raise RuntimeError(f"{script} exited {completed.returncode}; see {log.name}")
        native = json.loads((out / "native-results.json").read_text())
        regression = json.loads((out / "distribution-regression/regression.json").read_text())
        if regression["status"] != "PASS" or regression["passed"] != 4:
            raise RuntimeError("The four-component native distribution regression did not pass")
        unchanged = all(digest(ROOT / row["path"]) == row["sha256"] for row in identities["files"])
        if not unchanged:
            raise RuntimeError("A source/input/evidence file changed during the focused check")
        summary = {"status": native["status"], "counts": native["counts"], "native": native,
                   "source_and_historical_evidence_unchanged": unchanged,
                   "preservation_scope": "Unchanged during this focused rerun; the explicit source correction relative to the historical run is recorded separately.",
                   "explicit_source_corrections": [row["explicit_source_correction"] for row in identities["files"]
                                                   if "explicit_source_correction" in row],
                   "distribution_regression": regression,
                   "executions": executions, "elapsed_seconds": time.time() - started,
                   "reused": "Saved ep measured TMD/soft/Fourier and r07 assemblies; saved high-pT finite jet and UU/UT assembly/Born banks.",
                   "recomputed": "Only jet soft/Fourier helpers and isolated fragmentation/jet assembly tests; no hard/reduction calculations.",
                   "native_campaign": False, "dependency_probes": False}
        summary["qualifications"] = {
            "independent_highpt_intrinsic_Collins_matching": False,
            "independent_highpt_regulated_injet_soft_output": False,
            "whole_observable_or_global_angular_frame_equivalence": False,
            "generic_HF_contacts": "Not certified; nonzero physical endpoint-class input tested",
            "historical_acceptance": "Not renewed by this focused comparison"}
        dump(out / "summary.json", summary)
        # REPORT.md is produced from the same fresh results by the reusable reporter.
        from report import write_report
        write_report(out, summary, identities)
        print(json.dumps({"status": summary["status"], "counts": summary["counts"], "report": str(out / "REPORT.md")}, indent=2))
        # A completed comparison with a detected production-helper discrepancy
        # deliberately exits 2, while still writing its complete report.
        return 0 if native["status"] == "FOCUSED_CHECKS_COMPLETE_WITH_QUALIFICATIONS" else 2
    except Exception as exc:
        dump(out / "summary.json", {"status": "INCOMPLETE", "first_concrete_failure": str(exc), "executions": executions})
        print(str(exc), file=sys.stderr)
        return 2


if __name__ == "__main__":
    raise SystemExit(main())
