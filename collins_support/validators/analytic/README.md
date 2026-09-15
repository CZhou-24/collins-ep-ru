# Analytical runner and checks

See [current commands and scope](../../README.md). The analytical implementation remains v0.5.1; the report profile `reverse_unitarity_current` explicitly excludes historical acceptance replay.

| File | Purpose |
|---|---|
| `workflow.py` | Execute r00–r07; audit native evidence and compare 167 scalar exports |
| `verify_ru.py` | Compare two fresh runs, reexport native packets/masters and perturb upstream inputs |
| `compare_ru_reports.py` | Recompute both seeded reports and check their evidence bindings |
| `algebra.py` | Exact expression transport, reconstruction, cut and regulator-depth checks |
| `native_*.wl`, `native_*.wls` | Wolfram interfaces for native export, Kira/SubTropica audits and probes |
| `ru_support.py`, `../../paths.py` | Current file identities, subprocesses and constrained output paths |
| `reference_values.json` | Frozen comparison expressions with origin metadata; never production input |
| `sidis_reuse.json` | Pinned source-reuse identities |
| `references.json`, `literature_inventory.json` | Reference equations, source details and unresolved literature statuses |
| `tests/`, `selftest.py` | Software tests, including mathematical and failure-detection fixtures |

The 167 scalar checks are distinct from the broader literature equation inventory. Earlier reports and their qualifications remain historical evidence. This package does not claim independent physics acceptance just because a current comparison passes.
