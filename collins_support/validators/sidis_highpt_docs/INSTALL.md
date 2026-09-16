# Install and run the SIDIS high-pT package

The engine, shared validator and SIDIS adapter are included in this source
revision. Do not reinstall the original additive ZIP over them. The base
manifest, SIDIS extension manifest, predicates, references and tolerances
are unchanged. This package carries the already installed reporting fixes.

## Software and inputs

Use Python 3.10+ with the base requirements and PyYAML for Kira configuration:

```bash
python3 -m pip install -r collins_support/validators/analytic/requirements.txt 'PyYAML>=6,<7'
```

Native execution requires a working licensed Wolfram kernel, FeynCalc with
FeynArts, Kira, Fermat, SubTropica and polymake. The preserved runtime record
uses Wolfram Engine 15.0, the installed kira-3.1 path, and SubTropica-1.2.10.
Exact executable and source identities of the completed run are in
`collins_support/reports/sidis-highpt-final-review/successful-run/run.json`.
Do not treat version labels as a replacement for those hashes.

The validator currently reads `collins_ep_analytic_SIDIS/ru_runtime.json`.
That path is retained for compatibility; the new engine remains
`collins_sidis_highpt/`. The checked-in runtime file preserves the reviewed
local configuration, including absolute installation paths and timeout 7200.
For another machine, configure local executable/tool paths explicitly before
a new run. This creates a new runtime identity, not historical acceptance.
Do not alter the original runtime record or archived run metadata.

The 34 registered source files are bound by `collins_sidis_highpt/project.json`.
They include preserved upstream `SIDIS/` amplitudes, definitions and UU banks,
plus engine `inputs/` and `references/`. Keep the upstream tree at its
repository-relative path. Native libraries/tools may require installation
outside Git. Do not regenerate source inputs as an installation shortcut.

## Focused installation checks

```bash
export PYTHONDONTWRITEBYTECODE=1 OPENBLAS_NUM_THREADS=1 OMP_NUM_THREADS=1 MKL_NUM_THREADS=1
python3 collins_support/validators/tests/test_sidis_highpt.py
python3 collins_support/validators/sidis_highpt.py check-inputs \
  --project collins_sidis_highpt/project.json --sidis-root SIDIS
```

The adapter's optional handoff test may be skipped without a handoff archive.
These are software/input checks; they do not claim native or physical acceptance.

The broader shared suite, `python3 collins_support/validators/analytic/selftest.py`,
also tests the separate ep engine's doctor. It requires that engine's actual
`collins_ep_analytic_SIDIS/common/r00_definitions.wls` through
`r07_assembly.wls` source tree. The selected
high-pT package retains only its runtime configuration, so that one legacy
integration test is blocked in an isolated checkout (100 tests pass).
The unchanged suite passes all 101 tests in the original complete checkout.
No dummy ep stages or changed validator predicates are supplied to mask this.

## One ordinary fresh execution

From the repository root, choose a new state directory:

```bash
python3 collins_support/validators/sidis_highpt.py run \
  --project collins_sidis_highpt/project.json --sidis-root SIDIS \
  --repo "$PWD" --state collins_support/states/runs/sidis-highpt-new --through r07
```

The returned run path holds `run.json`, `result.json`, frozen `project.json`,
`receipts/`, and per-stage packets/logs. Require `NATIVE_CHECKS_PASS` and all
16 passing rows in `common/r07_result/boundary/summary.json` separately.
The final expression is `common/r07_result/observable/observable.wl`.

The reviewed historical record is one successful run with 16,416 declared
checks and 16 boundary comparisons. The second run and probes were cancelled;
pair and additional seed were omitted. The planned original two-run campaign
did not pass. The 54 additional virtual comparisons are a separate source
follow-up; focused checks do not certify a new full native run.

See the engine [README](../../../collins_sidis_highpt/README.md),
[native validation guide](../../../collins_sidis_highpt/NATIVE_VALIDATION.md)
for optional extended campaigns, and [compact evidence](../../reports/sidis-highpt-final-review/README.md).
Independent physics review remains pending; both operator MISMATCH rows and
33 UNVERIFIED rows remain. The review archive has explicit omissions and is
not a standalone replay dataset. Public artifact URLs are pending final review.
