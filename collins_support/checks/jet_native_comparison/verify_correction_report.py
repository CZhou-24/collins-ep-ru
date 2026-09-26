#!/usr/bin/env python3
"""Compare fresh rows with the preserved 001 report and verify pre-edit hashes."""
import argparse
import csv
import hashlib
import json
from pathlib import Path

from source_correction import SOURCE, verify_correction

ROOT = Path(__file__).resolve().parents[3]
OLD_REPORT = ROOT / "collins_support/reports/jet-native-comparison-001/verified"
CORRECTED_ROWS = {"auxiliary_distribution_helper/Uqq", "auxiliary_distribution_helper/Tqq"}
FIELDS = ("group", "status", "left", "right", "residual", "scaled_residual", "tolerance")


def digest(path):
    h = hashlib.sha256()
    with path.open("rb") as f:
        for block in iter(lambda: f.read(1048576), b""):
            h.update(block)
    return h.hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--report", type=Path, required=True,
                        help="Correction evidence directory containing preservation-before.json and comparison/")
    args = parser.parse_args()
    report = args.report.resolve()
    if not report.is_relative_to(ROOT / "collins_support/reports"):
        parser.error("Evidence must stay under collins_support/reports")
    outputs = ("preservation-after.json", "baseline-comparison.csv", "correction-verification.json", "REPORT.md")
    if any((report / name).exists() for name in outputs):
        parser.error("Do not overwrite a completed correction verification")
    before = json.loads((report / "preservation-before.json").read_text())
    preservation = []
    for row in before["files"]:
        path = ROOT / row["path"]
        actual = digest(path) if path.is_file() else None
        entry = dict(row, current_sha256=actual, unchanged=actual == row["sha256"])
        if row["path"] == SOURCE:
            entry["explicit_source_correction"] = verify_correction(ROOT, path, row["sha256"])
        preservation.append(entry)
    unexpected_changes = [r["path"] for r in preservation if not r["unchanged"] and r["path"] != SOURCE]
    old = json.loads((OLD_REPORT / "summary.json").read_text())
    new = json.loads((report / "comparison/summary.json").read_text())
    old_rows = {r["id"]: r for r in old["native"]["rows"]}
    new_rows = {r["id"]: r for r in new["native"]["rows"]}
    row_records = []
    for key in sorted(old_rows.keys() | new_rows.keys()):
        a, b = old_rows.get(key, {}), new_rows.get(key, {})
        same = bool(a and b) and all(a[f] == b[f] for f in FIELDS)
        corrected = (key in CORRECTED_ROWS and a.get("status") == "DISCREPANCY"
                     and b.get("status") == "EXACT" and b.get("residual") == "0"
                     and a.get("right") == b.get("right") and a.get("tolerance") == b.get("tolerance"))
        row_records.append({"id": key, "old_status": a.get("status"), "new_status": b.get("status"),
                            "old_residual": a.get("residual"), "new_residual": b.get("residual"),
                            "values_residuals_status_tolerance_unchanged": same,
                            "explicit_auxiliary_correction": corrected,
                            "check": "PASS" if same or corrected else "FAIL"})
    red = json.loads((report / "regression-before/regression.json").read_text())
    green = json.loads((report / "regression-after/regression.json").read_text())
    regression_cases = {r["component"]: r for r in red["rows"]}
    regression_ok = (red["status"] == "FAIL" and red["passed"] == 1 and green["status"] == "PASS"
                     and green["passed"] == 4 and red["regression_sha256"] == green["regression_sha256"]
                     and regression_cases["delta"]["pass"]
                     and all(not regression_cases[k]["pass"] for k in ("plus0", "plus1", "regular")))
    stable = sum(r["values_residuals_status_tolerance_unchanged"] for r in row_records)
    corrected = sum(r["explicit_auxiliary_correction"] for r in row_records)
    expected = sum(r["status"] == "EXPECTED_NONZERO_DIFFERENCE" for r in new_rows.values())
    ok = (not unexpected_changes and all(r["check"] == "PASS" for r in row_records)
          and stable == 117 and corrected == 2 and expected == 27 and regression_ok
          and new["status"] == "FOCUSED_CHECKS_COMPLETE_WITH_QUALIFICATIONS")
    result = {"status": "PASS" if ok else "FAIL", "original_report": str(OLD_REPORT.relative_to(ROOT)),
              "original_summary_sha256": digest(OLD_REPORT / "summary.json"),
              "fresh_summary_sha256": digest(report / "comparison/summary.json"),
              "preservation_files": len(preservation), "unchanged_files": sum(r["unchanged"] for r in preservation),
              "unexpected_changes": unexpected_changes, "unchanged_comparison_rows": stable,
              "resolved_auxiliary_discrepancies": corrected, "expected_nonzero_rows_retained": expected,
              "old_counts": old["counts"], "new_counts": new["counts"],
              "old_definition_failed_corrected_passed_same_regression": regression_ok,
              "regression_script_sha256": green["regression_sha256"],
              "row_failures": [r for r in row_records if r["check"] != "PASS"]}
    (report / "preservation-after.json").write_text(json.dumps({"files": preservation}, indent=2) + "\n")
    (report / "correction-verification.json").write_text(json.dumps(result, indent=2) + "\n")
    with (report / "baseline-comparison.csv").open("w", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=list(row_records[0]))
        writer.writeheader()
        writer.writerows(row_records)
    source_row = next(r for r in preservation if r["path"] == SOURCE)
    lines = ["# Native jet distribution grouping correction", "",
             f"**{result['status']}** — only the two RHS grouping parentheses in `HSJetDistributionAction` "
             "were added to production. The integrand, coefficients, signs and tolerances are preserved.", "",
             "| Native isolated component | Old actual | Expected / corrected actual | Old / corrected |",
             "|---|---|---|---|"]
    for a, b in zip(red["rows"], green["rows"]):
        lines.append(f"| {a['component']} | `{a['actual']}` | `{b['actual']}` | "
                     f"{'PASS' if a['pass'] else 'FAIL'} / {'PASS' if b['pass'] else 'FAIL'} |")
    lines += ["", "Both runs load the actual production file; the identical native regression ran before "
              "and after the edit. Exact expectations use independent polynomial/logarithmic integrals "
              "on [0,1]. [Old evidence](regression-before/regression.json), "
              "[corrected evidence](regression-after/regression.json) and adjacent execution logs retain "
              "DownValues, source/script hashes and exit codes (2 then 0).", "",
              f"Fresh focused comparison: **{len(new_rows)} rows**; " + "; ".join(f"{n} {s}" for s, n in new["counts"].items()) + ".",
              f"**{stable}/117** previously non-discrepant rows retain their exact saved expression strings, "
              "values, residuals, statuses and tolerances. This includes production UU/UT assembly results "
              f"and **{expected} expected nonzero** corrections: 24 semi-inclusive and 3 separate ep recoil rows. "
              "The two auxiliary rows now have exact zero residuals. Their original Uqq `CF*(8+3*L)/2` "
              "and Tqq `2*CF*(2+L)` residuals and all original evidence remain unchanged under "
              "[001/verified](../jet-native-comparison-001/verified/REPORT.md).", "",
              f"Preservation: **{result['unchanged_files']}/{len(preservation)}** recorded files unchanged; "
              "the sole intended difference is the corrected production helper. Original report trees, "
              "pinned fixtures, selected native evidence, validators and runtime files were hashed before "
              "and after. See [preservation-after.json](preservation-after.json).", "",
              f"- Old source SHA-256: `{source_row['sha256']}`.",
              f"- New source SHA-256: `{source_row['current_sha256']}`.", "",
              "The historical mismatch remains explicit in fresh provenance (`matches_recorded: false`). "
              "The source gate verifies the exact old/new hashes and reconstructs the full historical "
              "hash by undoing only the two parentheses; other mismatches fail closed. "
              "[Exact edit](source-correction.diff); [row-by-row comparison](baseline-comparison.csv); "
              "[machine-readable verification](correction-verification.json).", "",
              "See the [focused native report](comparison/REPORT.md), [comparison CSV](comparison/comparison.csv) "
              "and [summary](comparison/summary.json) for inputs, convention maps, residuals, tolerances and logs. "
              "Known native endpoint diagnostics in the comparison log arise in unused intermediate values; "
              "the returned/integrated expressions remain finite and no comparison was waived.", "",
              "High-pT intrinsic Collins matching is still a supplied input, not independently verified. "
              "The semi-inclusive correction and ep recoil factor remain separate. Generic contacts, "
              "finite-R/full-observable equivalence and independent physics review remain open. "
              "No full campaign, probe, publication sync, commit or push; no renewed historical acceptance.", "",
              "Reproduce the four native regression tests and focused comparison into an unused directory:", "", "```bash",
              "python3 -B collins_support/checks/jet_native_comparison/run.py \\",
              "  --out collins_support/reports/jet-native-comparison-replay-002", "```", ""]
    (report / "REPORT.md").write_text("\n".join(lines))
    print(json.dumps(result, indent=2))
    return 0 if ok else 2


if __name__ == "__main__":
    raise SystemExit(main())
