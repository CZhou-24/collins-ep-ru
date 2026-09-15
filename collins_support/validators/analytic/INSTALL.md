# Completed historical v0.5.1 installation and upgrade

**The commands below are historical and must not be executed for the current layout.** The engine and validator are already installed. Old root locations, ZIP extraction and standalone v0.5.0 prerequisites describe the completed upgrade, not current dependencies. Current commands use [the support guide](../../README.md) and [RELOCATION.md](../../reports/RELOCATION.md). New runs belong under `collins_support/states/runs/`; no current setup command should create filesystem-root support directories.

## Original upgrade instructions (historical)

This is a separate validator release. Keep the installed v0.5.0 validator, its entire state and the prior review directory. The implementation remains `/bigTMD/collins_ep_analytic_SIDIS`; the accepted `/bigTMD/collins_ep_analytic` engine is unchanged. **Use `upgrade.py`, not the initial `install.py`. No source or runtime file is replaced.**

Place the ZIP and checksum in `/bigTMD`. Keep the Python environment that passed v0.4.0 and ran v0.5.0 (the reported environment used `/usr/bin/python3.10`). Do not extract over an existing v0.5.1 release or reuse an existing new state directory.

```bash
cd /bigTMD
sha256sum -c Collins-ep-analytic-validation-v0.5.1.zip.sha256
unzip Collins-ep-analytic-validation-v0.5.1.zip -d /

export COLLINS_VALIDATOR=/Collins-ep-analytic-validation-v0.5.1
export COLLINS_STATE=/Collins-ep-analytic-state-v0.5.1
export COLLINS_PYTHON=/usr/bin/python3.10
export PYTHONDONTWRITEBYTECODE=1
export OPENBLAS_NUM_THREADS=1 OMP_NUM_THREADS=1 MKL_NUM_THREADS=1

"$COLLINS_PYTHON" "$COLLINS_VALIDATOR/selftest.py"

"$COLLINS_PYTHON" "$COLLINS_VALIDATOR/upgrade.py" \
  --repo /bigTMD --state "$COLLINS_STATE" --dry-run

"$COLLINS_PYTHON" "$COLLINS_VALIDATOR/upgrade.py" \
  --repo /bigTMD --state "$COLLINS_STATE"

"$COLLINS_PYTHON" "$COLLINS_VALIDATOR/native_regression.py" \
  --repo /bigTMD --output "$COLLINS_STATE/native-regression-initial"

"$COLLINS_PYTHON" "$COLLINS_VALIDATOR/workflow.py" doctor --repo /bigTMD
```

Run the commands in order and inspect each result before proceeding. No dependency reinstall or `cp ru_runtime.example.json` is needed for this upgrade. Do not apply the old review's unapplied patches to the frozen v0.5.0 files; the fixes are already in v0.5.1.

The upgrader defaults to `/Collins-ep-analytic-validation-v0.5.0` and `/Collins-ep-analytic-state-v0.5.0`. If either is actually elsewhere, supply `--previous-validator PATH` and `--previous-state PATH`. It reads the real accepted v0.4.0 pair location from the old adoption record and checks its identity. An optional `--accepted-pair PATH` must identify that same accepted evidence. Preserve the original paths and reports; do not edit a report to fit an example command.

The upgrade checks the exact previous release, accepted old source/evidence identity, current reuse ledger and native configuration. It writes only `adoption.json`, `initial-engine-snapshot.json` and `previous-state-snapshot.json` in the new state. Those are a record of the partial engine at upgrade time, not a new physics acceptance.

## Expected results

| Command | Expected result | Meaning |
|---|---|---|
| `selftest.py` | `PASS`, 111 tests | Validator software tests only |
| Upgrade dry run | `DRY_RUN` | Checks passed; nothing written |
| Upgrade | `UPGRADE_READY` | Existing engine adopted; old files unchanged |
| `native_regression.py` | `NATIVE_REGRESSION_PASS` | Actual Kira/SubTropica repair regression passed |
| Doctor | `READY_TO_EXECUTE` | Existing stage and tool paths found; completeness is not checked |

The native regression is more substantial than the old transport smoke. It runs a two-cut Kira job, evaluates volume and eikonal Euler integrals, checks ten exact residuals, tests both seeded complete-map mutations and runs a deliberately period-disabled helper copy that must be rejected. The negative-control log is expected to contain an error; the final `result.json` must report `NATIVE_REGRESSION_PASS`. This command could not be run in the authoring environment, so its result on your host is still required. It does not certify the full Collins process or the unfinished measured sectors.

If an execution fails, preserve its output directory. Use a new path for a deliberate retry after diagnosis; never overwrite failed evidence. If a native API problem remains, return the failing regression directory for review.

## Launch the continuation

After these setup checks, give the agent:

> Please carry out `/Collins-ep-analytic-validation-v0.5.1/AGENT_PROMPT.md` exactly. Continue the existing implementation in `/bigTMD/collins_ep_analytic_SIDIS`, using `/bigTMD` as the working repository.

This is an implementation mission. The prompt first requires a fresh pilot through r03, then the missing fixed-fraction TMD, Collins/HF, measured soft and jet/overlap work and full assembly. Higher reasoning is appropriate. A successful native regression does not complete that work.
