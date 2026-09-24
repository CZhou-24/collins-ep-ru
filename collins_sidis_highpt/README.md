# SIDIS high-pT Collins engine

This engine assembles the leading-power small-R, small-jT Collins
hadron-in-jet moment in the Breit frame, with standard-axis anti-kT jets and
`jT << pJT R << pJT ~ Q`. It includes six UU channels, Hqq and Hqqbar UT,
finite jet matching, symbolic PDF/TMD convolutions, and the consistently
expanded NLO asymmetry. PDFs and soft-subtracted TMDs remain symbolic;
there is no fit or Figure 6 reproduction.

## Recorded acceptance

The preserved source revision `26b270b3` corresponds to successful run
`20260916T095719Z-1584d7f6dd71`: **one full native r00–r07 run passed
16,416 declared checks and all 16 physical boundary comparisons**. Of those
checks, 13,113 concern scalar finiteness; counts depend on representation.
There are 73 stored reference comparisons, including 28 explicit conversions.

The second run and dependency-probe command were cancelled at the user's
request. Neither real-master nor virtual-master probe replay started.
Pair comparison and seed 92741 were omitted. The campaign remains
`ENDED_AT_USER_REQUEST`; the original two-run campaign did not pass.
Independent physics review remains pending. The two operator diagnostic
MISMATCH rows and 33 UNVERIFIED rows remain visible, including 32 independent
polarized hard-reference gaps and the historical Hgq MadGraph qualification.
The finite scheme conversion is the documented derived zero; no guessed
`2 CF z` correction is introduced.

This is a scoped implementation/regression record, not a claim of arbitrary-R,
fully resolved-azimuth accuracy or transfer of historical acceptance. Saved
amplitudes, master integrals, and UU banks are explicitly reused. Polarized
contractions, maps, actual-target reductions and assembly were native. Real
phase-space integrals use reverse unitarity with physical cuts; virtual
integrals are ordinary loop integrals.

The organization revision changes paths only. The separately documented
54-check follow-up exports already calculated virtual comparison residuals
and uses existing exact identity checks. Focused follow-up checks do not
transfer the original native pass to a new source revision. See
[follow-up status](VIRTUAL_COMPARISON_FOLLOWUP.md).

## Applied corrections after the recorded run

Two corrections were applied after `20260916T095719Z-1584d7f6dd71`: the
outgoing fragmentation measure in the transversity subtraction
(`dzeta/zeta^(2-2 eps)`) and the V07 dilogarithm continuation in both archived
virtual master banks. The affected virtual-master representations, subtraction
terms, virtual assembly, finite hard coefficients and observable were rebuilt;
the reused Born, real and reduction artifacts were checked byte-for-byte
against their registration. The independent comparison then exposed a third
defect: the scalar exporter truncated coefficient identifiers to three digits
and silently overwrote 149 coefficients in each of the two transverse
`Regular` blocks, in the recorded run as well; the exporter was fixed, guarded
and regression-tested, and the r07 stages and export inventory were
regenerated. What changed, what it changed, and the checks after the rebuild
are recorded separately in
[CORRECTION_PROVENANCE.md](CORRECTION_PROVENANCE.md). That rebuild is not a new
native campaign and does not transfer the recorded acceptance above.

An independent comparison of the inclusive polarized hard coefficients against
Congyue's `SIDIS_HighPT_TT_HardCoefficients` package is kept separately in
`../collins_support/reports/sidis-highpt-002-v07-subtraction-fix/README.md`,
with its own verdict.

## Installation and ordinary execution

Follow [installation and runtime setup](../collins_support/validators/sidis_highpt_docs/INSTALL.md).
From the repository root, choose a new output directory:

```bash
export PYTHONDONTWRITEBYTECODE=1 OPENBLAS_NUM_THREADS=1 OMP_NUM_THREADS=1 MKL_NUM_THREADS=1
python3 collins_support/validators/sidis_highpt.py check-inputs \
  --project collins_sidis_highpt/project.json --sidis-root SIDIS
python3 collins_support/validators/sidis_highpt.py run \
  --project collins_sidis_highpt/project.json --sidis-root SIDIS \
  --repo "$PWD" --state collins_support/states/runs/sidis-highpt-new --through r07
```

`run` creates one new timestamped run and owns all native execution receipts.
Require its `result.json` to report `NATIVE_CHECKS_PASS` **and** its
`common/r07_result/boundary/summary.json` to contain all 16 finite, equal
limits, `complete_boundary_inventory: true`, and `all_completed_pass: true`.
The ordinary adapter does not itself promote the saved boundary summary to
a separate campaign verdict. Preserve both records.

These commands are instructions for a future calculation. They were not run
as part of publication preparation. See [validation and optional campaigns](NATIVE_VALIDATION.md)
for the separate repeatability/probe protocol.

## Sources, results and evidence

- [SCOPE.md](SCOPE.md), [DERIVATION.md](DERIVATION.md) and
  [COMPLETION_INVENTORY.md](COMPLETION_INVENTORY.md) describe formulas and qualifications.
- `common/r00.wls` through `common/r07.wls` are stable native entry points.
  [tools/README.md](tools/README.md) explains pipeline, check and development helpers.
- `project.json` registers input hashes and checks. `inputs/` preserves
  exact master representations and the scalar contract; `references/`
  preserves literal formulas and pinned paper source material.
- New runs write the final self-contained expression to
  `common/r07_result/observable/observable.wl`, with separate UU/UT files,
  hard banks, packets and receipts in the same run.
- Compact original evidence (retained locally; [publication summary](../collins_support/reports/sidis-highpt-review/README.md))
  includes the milestone, campaign disposition, boundary summary, supplement,
  Kira audit summaries and provenance hashes. Historical files are unchanged.
- External artifact index (retained locally; [publication summary](../collins_support/reports/sidis-highpt-review/README.md))
  pins the existing review ZIP and supplement. These remain local pending
  final review; public download URLs must be added at publication. The review
  ZIP omits reduction databases and is not a standalone replay archive.

To regenerate only the project inventory, run
`python3 collins_sidis_highpt/tools/pipeline/build_project.py`.
It uses preserved inputs and declares checks; it performs no derivation and
does not issue acceptance. Do not regenerate frozen historical run files.
