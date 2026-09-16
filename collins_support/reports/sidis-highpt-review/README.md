# SIDIS high-pT: review summary

The implementation supplies the specified Breit-frame Collins hadron-in-jet
observable at NLO, within its leading-power, small-R/small-jT assumptions.
PDFs and TMDs remain symbolic. See the engine's
[scope](../../../collins_sidis_highpt/SCOPE.md) and
[derivation](../../../collins_sidis_highpt/DERIVATION.md).

| Evidence | Recorded outcome |
|---|---|
| Historical full native r00-r07 run | 16,416 declared checks passed; 16 boundary comparisons passed |
| Current organized revision | 16,470 declarations; no full native campaign for this revision |
| Additional virtual identities | 54 passed in focused saved-certificate replay; synthetic nonzero and missing/extra cases rejected |
| Installation software checks | Shared-base 101/101 in both checkouts; adapter 44 passed, one optional handoff skip; reporting 8 + 10 passed |
| Registered input identities | All 34 resolved inside the publication checkout with matching hashes at installation |

Read [native-summary.json](native-summary.json) for the saved native verdicts,
[software-checks.json](software-checks.json) for installation checks,
[virtual-followup.json](virtual-followup.json) for the separate follow-up, and
[input-identities.json](input-identities.json) for input binding.

## Comparisons and limits

[reference-comparisons.json](reference-comparisons.json) retains all 73 stored
reference comparisons: 36 Born, 17 UU recovery and 20 literature comparisons.
It also retains every MISMATCH/UNVERIFIED row, not just successful examples.
These component checks do not provide an independent full polarized NLO result.

The classification inventory records 16,388 EXACT and 28 EXACT AFTER EXPLICIT
CONVERSION rows, plus two operator-diagnostic MISMATCH and 33 UNVERIFIED rows.
The latter include 32 full polarized hard-reference gaps and the historical
Hgq MadGraph qualification. Independent physics review remains pending.

The second fresh run was cancelled. The dependency command was cancelled
before either replay began; pair comparison and the second seed were omitted.
The original campaign remains ENDED_AT_USER_REQUEST, not a complete campaign pass.
Check counts depend on representation and are not counts of independent predictions.

## Provenance and reproduction

[evidence-origins.json](evidence-origins.json) identifies the exact local source
records used for this compact extraction. It is not a new algebra audit.
The full audit directories, frozen sources, run state and three review ZIPs
remain preserved locally; this directory is not a standalone native replay archive.
The engine's [native instructions](../../../collins_sidis_highpt/NATIVE_VALIDATION.md)
describe reproduction with the required external tools.
