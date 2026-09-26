# Native jet distribution grouping correction

**PASS** — only the two RHS grouping parentheses in `HSJetDistributionAction` were added to production. The integrand, coefficients, signs and tolerances are preserved.

| Native isolated component | Old actual | Expected / corrected actual | Old / corrected |
|---|---|---|---|
| delta | `6` | `6` | PASS / PASS |
| plus0 | `0` | `-2` | FAIL / PASS |
| plus1 | `0` | `3` | FAIL / PASS |
| regular | `0` | `25/12` | FAIL / PASS |

Both runs load the actual production file; the identical native regression ran before and after the edit. Exact expectations use independent polynomial/logarithmic integrals on [0,1]. [Old evidence](regression-before/regression.json), [corrected evidence](regression-after/regression.json) and adjacent execution logs retain DownValues, source/script hashes and exit codes (2 then 0).

Fresh focused comparison: **119 rows**; 68 EXACT; 27 EXPECTED_NONZERO_DIFFERENCE; 24 NUMERICAL_AGREEMENT.
**117/117** previously non-discrepant rows retain their exact saved expression strings, values, residuals, statuses and tolerances. This includes production UU/UT assembly results and **27 expected nonzero** corrections: 24 semi-inclusive and 3 separate ep recoil rows. The two auxiliary rows now have exact zero residuals. Their original Uqq `CF*(8+3*L)/2` and Tqq `2*CF*(2+L)` residuals and all original evidence remain unchanged under [001/verified](../jet-native-comparison-001/verified/REPORT.md).

Preservation: **342/343** recorded files unchanged; the sole intended difference is the corrected production helper. Original report trees, pinned fixtures, selected native evidence, validators and runtime files were hashed before and after. See [preservation-after.json](preservation-after.json).

- Old source SHA-256: `6165881fb32282fff5a29005a14cbbd00d355f2ec5da83489af82ef4c1f81829`.
- New source SHA-256: `57e616a97afdcd2804fb8be9330ee52b7800fbca9feb50eaeaf595b9d3bbe1ba`.

The historical mismatch remains explicit in fresh provenance (`matches_recorded: false`). The source gate verifies the exact old/new hashes and reconstructs the full historical hash by undoing only the two parentheses; other mismatches fail closed. [Exact edit](source-correction.diff); [row-by-row comparison](baseline-comparison.csv); [machine-readable verification](correction-verification.json).

See the [focused native report](comparison/REPORT.md), [comparison CSV](comparison/comparison.csv) and [summary](comparison/summary.json) for inputs, convention maps, residuals, tolerances and logs. Known native endpoint diagnostics in the comparison log arise in unused intermediate values; the returned/integrated expressions remain finite and no comparison was waived.

High-pT intrinsic Collins matching is still a supplied input, not independently verified. The semi-inclusive correction and ep recoil factor remain separate. Generic contacts, finite-R/full-observable equivalence and independent physics review remain open. No full campaign, probe, publication sync, commit or push; no renewed historical acceptance.

Reproduce the four native regression tests and focused comparison into an unused directory:

```bash
python3 -B collins_support/checks/jet_native_comparison/run.py \
  --out collins_support/reports/jet-native-comparison-replay-002
```
