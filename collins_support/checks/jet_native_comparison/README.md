# Native ep / high-pT jet comparison

Run commands from the root of the checkout being tested. Python 3.10+ and a
licensed Wolfram Engine 15 installation are external prerequisites; no Python
packages beyond the standard library are needed. The kernel path below is the
one recorded in `collins_ep_analytic_SIDIS/ru_runtime.json`; substitute your
installed kernel path if needed. Neither an environment nor a Wolfram license
is packaged here.

The [publication report](../../reports/jet-native-review/REPORT.md) links the
unchanged completed comparison evidence and the fresh publication regression.
The published four-component regression needs only the actual production
`collins_sidis_highpt/common/jet_matching.wl`, this check directory and Wolfram;
it does not need saved native runs. Its standalone command is below.

To repeat the **full focused comparison**, first install the external saved
inputs described below. This is separate from the lightweight publication
regression; the publication operation did not rerun the comparison.

```bash
python3 -B collins_support/checks/jet_native_comparison/run.py \
  --out collins_support/reports/jet-native-comparison-replay-001
```

Use a new output directory. The runner verifies source and receipt SHA-256
identities before executing the four-component native regression and two comparison adapters. It writes expressions,
logs, `comparison.csv`, `summary.json`, and `REPORT.md` only under `--out`.
Exit 2 means a discrepancy/unresolved comparison (inspect the report), or an
execution failure (inspect `summary.json`); it does not relabel findings as PASS.
No SymPy translation is used for the numerical or symbolic comparison.

Required saved runs (override with `--ep-run` and `--highpt-run`):

- ep: `collins_support/states/runs/reverse-unitarity-003/20260915T063100Z-b8feba4db8fd/`.
- high-pT: `collins_support/states/runs/sidis-highpt-001/continuation-001/native-campaign-002/physical/20260916T095719Z-1584d7f6dd71/`.

These historical run trees are local inputs, not packaged fixtures. Required
selected files and their receipt/source hashes are listed in each output's
`provenance.json`. The large high-pT UU/UT files and hard bank are read only;
only the saved Born entries and LO/jet assembly expressions are retained.
[`external-inputs.json`](external-inputs.json) lists the exact external files,
sizes and SHA-256 hashes required by the saved-run replay. Obtain these from
the retained native-run evidence, and install them beneath **this checkout's**
root at the listed relative paths. They are not fetched automatically and a
new checkout does not share active `/bigTMD` state directories. The runner's
run paths must be inside its checkout; do not point them at a different
checkout with `--ep-run` or `--highpt-run`. Keep receipt and input bytes intact.
The published compact `native-extract.wl` supports inspection but does not
replace the receipt-checked original run inputs used by `run.py`.
No NLO hard integral, amplitude, master reduction, campaign or probe is run.
Three relocated high-pT producing scripts are checked against their original
hashes by undoing only the root-discovery depth change in memory.

`source-correction.json` explicitly records the old and corrected full-file
identities of `common/jet_matching.wl`. Only two grouping parentheses were
inserted around `HSJetDistributionAction`'s entire RHS. The historical hash
mismatch remains recorded as such: `source_correction.py` verifies the exact
new hash, then removes only these parentheses in memory and requires the
original full-file hash. Every other mismatch fails closed. Historical
receipts, pinned fixtures and the two original discrepancies in
[`jet-native-comparison-001/verified`](../../reports/jet-native-comparison-001/verified/REPORT.md)
are preserved. Absolute paths and hashes in archived logs, receipts and reports
describe their original executions; they have not been rewritten for publication.

The native regression loads the actual production file, not a replacement
definition. Its independent exact tests are delta `3*(1+1^2)=6`, plus0 on
`phi(z)=z` with coefficient 2 giving `-2`, plus1 on `phi(z)=z` with coefficient
3 giving `3`, and regular `(1+z)*(1+z^2)` integrating to `25/12`.
The original actual file passed only delta (1/4); the grouped file passes 4/4.
Before/after logs, DownValues and source hashes are in
[`regression-before`](../../reports/jet-native-comparison-002/regression-before/regression.json)
and [`regression-after`](../../reports/jet-native-comparison-002/regression-after/regression.json),
with adjacent logs in that report directory.
To run just this regression into an unused directory:

```bash
JET_ACTION_REGRESSION_OUT="$PWD/collins_support/reports/jet-action-regression-001" \
OPENBLAS_NUM_THREADS=1 OMP_NUM_THREADS=1 MKL_NUM_THREADS=1 \
/opt/Wolfram/WolframEngine/15.0/Executables/WolframKernel -noprompt -script \
  "$PWD/collins_support/checks/jet_native_comparison/regress_distribution_action.wls"
```

`python3 -B collins_support/checks/jet_native_comparison/test_source_correction.py`
tests the source identity gate, including rejection of further formula edits.

`verify_correction_report.py` was the original local preservation/row audit.
Reexecuting that audit requires the complete original preservation inventory,
including unrelated local fixtures and source files not selected for this
publication. Its completed JSON/CSV results are published unchanged. This
restriction does not apply to the standalone native regression or the five
source-identity tests.

`extract_native.wls` reads actual saved expressions. `compare_native.wls`
executes the native soft coefficient assembly, Fourier helpers,
`RUObservablePolynomial`, `RUObservableHFAction`, `HSTMDInput`,
`HSBuildChannelObservable`, and native distribution actions. Saved ep soft
integration factors and its evaluated sphere are reused; the cut integrations
are not regenerated. The high-pT hard-NLO bank is explicitly zeroed **only in
the in-memory assembly isolation test**, leaving the actual saved Born bank.

Common inputs are `FFq(t)=t(1-t)^2`, `FFg(t)=2t(1-t)^3/5`,
`Hhatq(t)=3 Mh t^2(1-t)^3/5`, and
`HF(t1,t2)=Mh t1(1-t1)^2 (t1/t2)^2 (1-t1/t2)^2/7`.
The last two are nonzero polarized test inputs; HF vanishes with its first
derivative at its contact boundary. They are tests, not fits. The native
small-b expansion is tested inside the report's finite small-b windows;
separate Gaussian tests exercise the full Fourier inverse identities.

`quadrature.wl` integrates the rational HF test's inner variable analytically,
checks its primitive exactly and against independent one-dimensional numerical
integrals, then performs the remaining quadrature. It changes no kernel or
tolerance. The actual native color map also converts archived `SUNN` to `Nc`.

The high-pT intrinsic TMD is supplied from ep after the explicit normalization
and sign map. This tests assembly compatibility, **not independent high-pT
intrinsic Collins matching**. Out-of-jet matching and ep recoil soft remain
separate. Full hard/angular cross-section equivalence, generic twist-three
contacts, finite-R corrections and independent physics acceptance remain open.
