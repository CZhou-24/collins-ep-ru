# Current runner and analytical checks

`validators/analytic/` contains the r00–r07 runner, native-tool interfaces, exact expression checks and dependency probes. There is one current verification profile: `reverse_unitarity_current`. Retired validators, relocation logs, earlier engines and historical acceptance states are not inputs to it.

The engine's Wolfram source programs and all 167 reference scalar expressions retain their existing bytes. References are comparison inputs only; the native stages generate their own amplitudes, reductions, masters and assembled outputs. Source snapshots, native receipts, reference comparisons, convention coverage, cut/precision checks and dependency probes remain enforced.

## Run

Run these commands from the root of this checkout. Each command is one shell line. Python 3.10 or newer and the dependencies in `validators/analytic/requirements.txt` are needed.

```bash
python3 -m pip install -r collins_support/validators/analytic/requirements.txt
PYTHONDONTWRITEBYTECODE=1 python3 collins_support/validators/analytic/selftest.py
PYTHONDONTWRITEBYTECODE=1 python3 collins_support/validators/analytic/workflow.py doctor
PYTHONDONTWRITEBYTECODE=1 OPENBLAS_NUM_THREADS=1 OMP_NUM_THREADS=1 MKL_NUM_THREADS=1 python3 collins_support/validators/analytic/workflow.py run --state collins_support/states/runs/review --through r07
```

Set the installed native-tool locations in `collins_ep_analytic_SIDIS/ru_runtime.json`: Wolfram, FeynCalc/FeynArts, Kira, Fermat, SubTropica/HyperIntica and polymake. Existing absolute paths may point to tool installations under `/bigTMD/SIDIS`; those tools must exist, but earlier Collins engines and acceptance states are unnecessary. Relative configuration paths are resolved from this checkout. `doctor` checks dependencies; it does not execute a derivation.

Each `run` invocation uses a new output directory and prints its location. Results live under `collins_support/states/runs/`. A complete r07 run checks the native derivation evidence and the 167 reference scalars. A failed comparison fails the run. Software selftests alone do not certify native execution or physics.

## Two-run verification

For the current native replay and upstream mutation checks, run the workflow twice. Put the printed run paths in `RUN_A` and `RUN_B`, then use:

```bash
PYTHONDONTWRITEBYTECODE=1 python3 collins_support/validators/analytic/verify_ru.py --run "$RUN_A" --replay "$RUN_B" --seed 1729 --report collins_support/reports/review-1729.json
PYTHONDONTWRITEBYTECODE=1 python3 collins_support/validators/analytic/verify_ru.py --run "$RUN_A" --replay "$RUN_B" --seed 92741 --report collins_support/reports/review-92741.json
PYTHONDONTWRITEBYTECODE=1 python3 collins_support/validators/analytic/compare_ru_reports.py --report collins_support/reports/review-pair.json collins_support/reports/review-1729.json collins_support/reports/review-92741.json
```

Use unused report filenames. `status --run <printed-run-path>` also audits an existing **current-profile** run. Saved historical reports are not accepted as current-profile reports.

The report scope covers the current RU route, scalar references and probes. It does not rerun the retired v0.4.0/v0.3.3 checks or their MadGraph campaigns. Their original acceptance remains attached to the historical Git revision. Scientific limitations in the comparison PDFs remain applicable.

Current executable files and references have a SHA-256 inventory in `validators/analytic/MANIFEST.json`; `paths.py` is included in that identity. Documentation is not a runtime preservation dependency. Runs bind the full engine snapshot and installed-tool identities before and after execution. Historical relocation exceptions are no longer accepted.
