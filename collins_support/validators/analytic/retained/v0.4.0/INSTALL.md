# Installation and execution

**Completed historical instructions. Do not execute the installation or root-location commands below in the current layout.** This checker is already bundled under `collins_support/validators/analytic/retained/v0.4.0`. Use [RELOCATION.md](../../../../reports/RELOCATION.md) for current local commands. No standalone validator release or historical archival campaign is required for current analytical replay.

Use a new external validator directory, `/Collins-ep-analytic-validation-v0.4.0`. Keep `/Collins-ep-analytic-validation-v0.3.3`, its accepted state, and every original installation lock. **Do not invoke the retained scaffold installer.** The new installer adds only `common/nlo_io.wl` and `nlo_runtime.example.json`; it neither replaces accepted files nor installs fake native stage implementations.

Extract the delivered ZIP's top-level `Collins-ep-analytic-validation-v0.4.0/` folder under `/`. For example, with the ZIP saved in `/bigTMD`:

```bash
cd /bigTMD
sha256sum -c collins_ep_analytic_validation_v0_4_0.zip.sha256
unzip collins_ep_analytic_validation_v0_4_0.zip -d /

export COLLINS_VALIDATOR=/Collins-ep-analytic-validation-v0.4.0
export COLLINS_STATE=/Collins-ep-analytic-state-v0.4.0
export OPENBLAS_NUM_THREADS=1 OMP_NUM_THREADS=1 MKL_NUM_THREADS=1
export PYTHONDONTWRITEBYTECODE=1
COLLINS_PY=$(command -v python3)
"$COLLINS_PY" --version
```

Use the Python 3.10 environment from the accepted campaign. Check `numpy`, `scipy` and `sympy` imports. The new dependency is SymPy (>=1.12,<1.15). If needed, install it into that Python environment; do not replace native tools or recreate numerical baselines. `requirements.txt` also records the retained NumPy/SciPy requirements.

If SymPy is missing, the command is `"$COLLINS_PY" -m pip install 'sympy>=1.12,<1.15'`. Keep the same installed version through both final runs and both report checks.

```bash
"$COLLINS_PY" -c 'import numpy, scipy, sympy; print(numpy.__version__, scipy.__version__, sympy.__version__)'
"$COLLINS_PY" "$COLLINS_VALIDATOR/selftest.py"
"$COLLINS_PY" "$COLLINS_VALIDATOR/install.py" --repo /bigTMD \
  --accepted-state /Collins-ep-analytic-state-v0.3.3 \
  --state "$COLLINS_STATE" --dry-run
"$COLLINS_PY" "$COLLINS_VALIDATOR/install.py" --repo /bigTMD \
  --accepted-state /Collins-ep-analytic-state-v0.3.3 \
  --state "$COLLINS_STATE"
```

The installer checks the accepted 1,399-file source identity and both accepted v0.3.3 reports. It refuses any overwrite. After a successful install, use the saved implementation directly; do not reinstall over an agent's edits. The old installation lock is neither edited nor replaced.

Create the new configuration once (the agent may do this):

```bash
cp -n /bigTMD/collins_ep_analytic/nlo_runtime.example.json \
      /bigTMD/collins_ep_analytic/nlo_runtime.json
"$COLLINS_PY" "$COLLINS_VALIDATOR/native_smoke.py" --repo /bigTMD \
  --output "$COLLINS_STATE/native-smoke-initial"
"$COLLINS_PY" "$COLLINS_VALIDATOR/workflow.py" doctor --repo /bigTMD
```

`SMOKE_PASS` tests actual Wolfram expression transport and independent native reexport using synthetic expressions. It does not run a physics derivation. `doctor` initially reports `IMPLEMENTATION_REQUIRED` because d16–d19 have not been written; this is expected. A stage source is candidate work, not a protected missing validator parser.

Use a new output directory if repeating the smoke test. The new runtime file controls timeouts only; the runner obtains FeynArts/FeynCalc/Kira/SubTropica paths from the existing accepted native configuration. All final commands must use the same interpreter.

## After implementation

Finish source changes and the new equation-comparison documents first. Then run the following command **twice**, without `--base-run`, using the two distinct run paths printed in its output:

```bash
"$COLLINS_PY" "$COLLINS_VALIDATOR/workflow.py" run --repo /bigTMD \
  --state "$COLLINS_STATE" --numerical-state /SIDIS-validation-state --through d19
```

Set `COLLINS_RUN_A` and `COLLINS_RUN_B` to the printed absolute paths, then:

```bash
"$COLLINS_PY" "$COLLINS_VALIDATOR/verify_nlo.py" --repo /bigTMD \
  --run "$COLLINS_RUN_A" --replay "$COLLINS_RUN_B" --seed 1729 \
  --report "$COLLINS_STATE/nlo-1729.json"
"$COLLINS_PY" "$COLLINS_VALIDATOR/verify_nlo.py" --repo /bigTMD \
  --run "$COLLINS_RUN_A" --replay "$COLLINS_RUN_B" --seed 92741 \
  --report "$COLLINS_STATE/nlo-92741.json"
"$COLLINS_PY" "$COLLINS_VALIDATOR/compare_nlo_reports.py" --repo /bigTMD \
  --report "$COLLINS_STATE/nlo-pair.json" \
  "$COLLINS_STATE/nlo-1729.json" "$COLLINS_STATE/nlo-92741.json"
```

Use unused report names for every attempt. Do not move or modify sealed evidence during replay. The NLO verifiers automatically run the retained official v0.3.3 verifications, including actual native MadGraph generation/build/evaluation, and the final pair invokes its unchanged official pair comparator. No separate manual modification of the old validator is required.

During development, `workflow.py run --through d16` (or d17/d18) is available. `--base-run /absolute/retained/run` reuses a retained run only when its entire candidate source map is still unchanged. Editing a new stage also changes that map and therefore requires a fresh retained run. Reuse is recorded and **cannot qualify as a final fresh run**. Run outputs and acceptance reports stay outside production; the new equation-comparison documents inside production must be completed before freezing the source map.

Native failures and a necessary correction to a protected source must be accompanied by a minimal reproducer and exact unapplied patch. Preserve the accepted baseline; do not weaken a test or edit an installation lock to produce a pass.
