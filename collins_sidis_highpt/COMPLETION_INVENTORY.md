# Implemented calculation and native acceptance inventory

This file describes the implementation at the source freeze. Full native
acceptance is recorded outside the source tree in the campaign identified by
[NATIVE_VALIDATION.md](NATIVE_VALIDATION.md). The recorded reduced campaign has one full native pass;
the second run and dependency probes were cancelled, and pair/additional seed omitted. A development check or an inventory declaration is not completion.
The domain remains the named leading-power small-R/small-jT Collins moment in
[SCOPE.md](SCOPE.md); independent physics review is pending.

All development paths below are relative to
`../collins_support/reports/sidis-highpt-001/continuation-001/`.

| Ingredient | Producing or reused source | Completed development evidence | Native connection / qualification |
|---|---|---|---|
| Born spin/photon tensor | Saved Hqq amplitudes; spin densities and independent Clifford matrices | 45 physical tensor components, dimensional UU recovery, Ward, basis, normalization and angular checks; fresh 85-check r00 reproduction | `common/r00.wls`; independent Born reference retained |
| Hqq qgg real | Fresh 36-pair open tensors, Collins projection, cut-family maps | 97 targets, three masters, 75 exact archived overlaps; 72 fresh projection comparisons; both gluon Ward identities | Fresh tensor/projection preparation at r00; mapping at r01 and coefficient assembly at r02–r03; saved master values reused |
| Hqq same-flavor real | Fresh 36-pair tensors with saved exchange signs | 180 targets, six masters, 172 archived overlaps; full endpoint distributions | r01–r03; no omitted exchange terms |
| Hqq distinct-flavor real | Fresh 10-pair full tensor and three charge sectors | 46 targets, two masters, 42 archived overlaps; 18 components and exchange-odd integrated interference | r01–r03; no pointwise removal of the mixed-charge term |
| Hqqbar real-only UT | Fresh 36-pair tagged-antiquark calculation | 182 targets, seven masters, 176 archived overlaps; 72 independent D-dimensional UU recoveries; finite nonzero L/T coefficient | r01–r03 and r07; starts at alpha_s squared, no Born jet correction |
| Hqq virtual / UV | Fresh 15-diagram interference, loop map and large-loop residue | 210 targets, seven masters, 202 archived overlaps; six per-master Ward and six UV cancellations; finite principal-branch assembly | r04–r06; explicit auxiliary terminal target; archived integrals reused |
| Inactive UT channels | Actual Hqg and Hqqprime traces; gluon spin-half selection rule | Hqg and Hqqprime traces vanish; Hgq/Hgg helicity-two operator vanishes | r00 proofs remain connected to r07; all corresponding UU terms retained |
| Initial and outgoing factorization | Full production collinear tensors, physical-tagged real/virtual operators and dimensional Born | Six outgoing, six incoming and 36 stronger incoming-pole cancellations; both exact MS convolutions | r03; PDF and fragmentation measures kept distinct |
| Finite operator conversion | Physical-tagged BMHV/NDR traces, literal pinned all-D expression, actual pole depth | Real and virtual angular averages agree; epsilon-squared soft-integrable difference times simple pole has no finite contribution; anti-kT finite-jet cross-check | Conversion zero is derived within the stated prescription; original two MISMATCH diagnostics remain |
| Finite Hqq hard | All actual affine real/virtual recipes plus UV and both MS terms | 16 open-branch finite distribution coefficients; calculated pole and 48 original scale residuals zero | r07 expands exact function/polynomial coefficients for the unchanged validator |
| Common t=-s boundary | Independent termwise asymptotic series on both branches | `native-boundary-series-001`: all 16 limits finite and equal | Every physical campaign run separately requires all 16; changed-master probes may spoil regularity |
| Six-channel UU | Six preserved inclusive banks and historical BigTMD evidence | All 102 converted full expressions retained; 2,071 exact scalar representation checks; six nonzero literal reference recoveries | Explicit reuse, not fresh UU integration or historical recertification; Hgq MadGraph gap retained |
| Finite jet / Fourier / soft | Pinned 2311.00672v2 literal formulas and physical-tagged finite-jet derivation | 20 finite coefficients, canonical distribution/RG checks, rapidity cancellation, CS integrability and Fourier test identities | r07; standard-axis small-R theorem is a literature input; soft-subtracted TMD kept symbolic |
| Flavor and measured convolutions | `observable_flavors.wl`, measure and distribution-action helpers | 25 independent flavor checks, 18 invariant-measure checks, 17 native action checks | Six UU and two UT routes; all finite lower-limit terms retained |
| UU, Collins UT and asymmetry | `assemble_native_observable.wls`, actual current-master hard coefficients | Complete symbolic convolution and consistent NLO ratio; finite and order gates pass | r07; no C1 J1 contribution, PDF/Collins fits or Figure 6 |
| Exact native interfaces | Scalar master banks, actual producing packets and durable `build_project.py` extension | Focused real/virtual Kira adapters and 536 master imports; 15,395 r07 rows passed; input contract declares 16,416 checks and 13,113 scalar exports | Original run completed native arithmetic and source checks; pair and both seeds remain incomplete; no synthetic stage or desired pole zero |
| Actual reduced campaign | Installed unchanged SIDIS/analytic validator and current runtime | One native r00–r07 pass with 16,416 declared checks and 16 boundary comparisons | Original two-run campaign ended at user request; second run/probes cancelled, pair/additional seed omitted; independent physics review pending |

Scalar export counts depend on the explicit transport representation; they are
not a count of independent physical predictions. Complete hard expressions and
reconstruction bases remain available. No independent full polarized NLO hard
reference has been supplied. Acceptance requires both the scoped physics
inventory and completed native checks; neither alone certifies physical accuracy.

The first full campaign reached the unchanged two-hour r01 limit while mapping the distinct-flavor tensor; its failed state and logs are retained. The current scheduling moves the same fresh qgg preparation into r00 and adds parent/child lifetime handling. These orchestration repairs do not change the scientific expressions or count the failed attempt as a completed run. See `NATIVE_VALIDATION.md` and the external campaign 002 records.

The [virtual-comparison follow-up](VIRTUAL_COMPARISON_FOLLOWUP.md) adds 54 declared identities in a separate source revision. The preserved count above belongs to the original run.
