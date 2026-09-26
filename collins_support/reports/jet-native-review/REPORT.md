# Native jet comparison and grouping correction

The only production edit is two parentheses around the entire existing
`HSJetDistributionAction` RHS in
[`jet_matching.wl`](../../../collins_sidis_highpt/common/jet_matching.wl).
The integrand, coefficients, signs and tolerances are unchanged. Wolfram had
loaded the ungrouped definition with only its delta term.

| Evidence | Result | Execution status |
|---|---|---|
| Corrected focused native comparison | 68 exact; 24 numerical agreements; 27 expected nonzero differences; zero discrepancies/unresolved rows | Completed comparison reused unchanged |
| Isolated delta / plus0 / plus1 / regular | Old 1/4; corrected 4/4 | Original before/after native evidence reused unchanged |
| Previously non-discrepant rows | 117/117 unchanged expressions, values, residuals, statuses and tolerances | Completed row audit reused unchanged |
| Regression in publication checkout | See [publication checks](publication-checks.json) and [native results](native-regression/regression.json) | Fresh four-case native check only |

The 27 expected nonzero rows comprise 24 semi-inclusive corrections and three
separate ep recoil corrections. They have not been forced to zero. The two
corrected auxiliary rows now have exact zero residuals; their original Uqq
`CF*(8+3*L)/2` and Tqq `2*CF*(2+L)` discrepancies are retained in the
[original report](../jet-native-comparison-001/verified/REPORT.md),
[CSV](../jet-native-comparison-001/verified/comparison.csv) and native logs/exports.

The [corrected report](../jet-native-comparison-002/REPORT.md),
[119-row CSV](../jet-native-comparison-002/comparison/comparison.csv),
[summary](../jet-native-comparison-002/comparison/summary.json),
[row audit](../jet-native-comparison-002/baseline-comparison.csv) and
[verification](../jet-native-comparison-002/correction-verification.json)
substantiate the counts. Native symbolic exports, numerical residuals,
settings and logs accompany those records. The original evidence remains
unchanged locally and the selected published historical records preserve
their original bytes, paths, dates and verdicts. Statements about no push in
those archived reports refer to their original execution, before publication.

The old/corrected standalone regression evidence records exact results:
delta `6`/`6`, plus0 `0`/`-2`, plus1 `0`/`3`, regular `0`/`25/12`.
See [before](../jet-native-comparison-002/regression-before/regression.json),
[after](../jet-native-comparison-002/regression-after/regression.json),
the [original source](../jet-native-comparison-002/jet_matching.before.wl),
and the [two-parenthesis diff](../jet-native-comparison-002/source-correction.diff).

- Historical source SHA-256: `6165881fb32282fff5a29005a14cbbd00d355f2ec5da83489af82ef4c1f81829`.
- Corrected source SHA-256: `57e616a97afdcd2804fb8be9330ee52b7800fbca9feb50eaeaf595b9d3bbe1ba`.

The historical mismatch remains explicit (`matches_recorded: false`) in
[provenance](../jet-native-comparison-002/comparison/provenance.json).
The source gate checks both full hashes and requires that removing only the
two parentheses reconstructs the historical full hash. It rejects other
mismatches. No historical acceptance is renewed. The README and new external
input inventory were prepared for publication; the scientific check bodies,
regression, production inputs and archived hash records were not reformatted.

The high-pT intrinsic Collins input is supplied from ep after explicit
normalization and sign conversions. This demonstrates assembly compatibility,
**not an independent high-pT intrinsic Collins matching calculation**.
Out-of-jet matching and ep recoil soft remain separate. Generic twist-three
contacts, all-b nonperturbative input, finite-R corrections, full hard/angular
observable equivalence and independent physics review remain open. The saved
comparison contains the previously documented unused-endpoint diagnostics;
no row or tolerance was waived to suppress them.

Reproduce the four-case native regression from the root of this checkout,
using an unused output directory and the licensed Wolfram 15 kernel recorded
in `collins_ep_analytic_SIDIS/ru_runtime.json`:

```bash
JET_ACTION_REGRESSION_OUT="$PWD/collins_support/reports/jet-action-regression-001" \
OPENBLAS_NUM_THREADS=1 OMP_NUM_THREADS=1 MKL_NUM_THREADS=1 \
/opt/Wolfram/WolframEngine/15.0/Executables/WolframKernel -noprompt -script \
  "$PWD/collins_support/checks/jet_native_comparison/regress_distribution_action.wls"
```

Substitute your installed kernel path if it differs. The regression uses the
actual production file in this checkout and requires no saved run trees.
Python 3.10+ with its standard library runs the five source-identity tests:

```bash
python3 -B collins_support/checks/jet_native_comparison/test_source_correction.py
```

The [check README](../../checks/jet_native_comparison/README.md) gives the full
focused comparison command and
[exact external native input inventory](../../checks/jet_native_comparison/external-inputs.json).
Those original inputs must be obtained and installed under the current
checkout before a full comparison replay; they are not assumed to exist in
another `/bigTMD` checkout. Such a replay was **not run for publication**.
The original preservation audit also requires its complete local inventory.

The publication checks also verified all 49 relative Markdown links inside
the checkout and preserved unrelated working files. Git reports trailing
whitespace in native Wolfram exports and an archived CSV; these hashed bytes
are retained exactly. Production and reusable check source has no such warning.

[MANIFEST.json](MANIFEST.json) records selected published file sizes and
SHA-256 hashes. Raw state trees, environments, caches, cleanup records,
archives and unrelated reorganizations are excluded. Only the grouping fix,
its reusable checks, selected historical evidence and this compact review
are selected for the commit. No campaigns or dependency probes were run.
