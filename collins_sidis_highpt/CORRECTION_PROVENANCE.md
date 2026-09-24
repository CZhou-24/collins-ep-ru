# Correction provenance: V07 continuation, outgoing FF measure and scalar-export identifiers

This file records **only** the corrections applied after the preserved run
`20260916T095719Z-1584d7f6dd71`, and what was rebuilt because of them. It does
not restate or replace the upstream provenance of the reused artifacts, which
remains in [NATIVE_VALIDATION.md](NATIVE_VALIDATION.md),
[COMPLETION_INVENTORY.md](COMPLETION_INVENTORY.md), `project.json` and
`inputs/master-preparation.json`. The historical run, its receipts and its
recorded verdict are unchanged and are **not** reissued by this rebuild.

## Corrections

### C1 — outgoing fragmentation measure in the transversity subtraction

`tools/pipeline/transversity_subtractions.wls` weights the outgoing collinear
root by `outgoing^(2-2 eps)` instead of `outgoing^2`, and records the measure as
`HoldComplete[dzeta/zeta^(2-2 eps)]`. The regulator dependence is kept through
the subtraction's Laurent expansion, so the `O(eps)` part of the weight meets
the `1/eps` pole of the MSbar counterterm and produces a finite term.

The outgoing root is `outgoing = (s-w)/s`, so the new finite term is
`2 Log[1 - w/s]` times the splitting kernel times the dimensional Born tensor.

### C2 — V07 dilogarithm continuation

Both `SIDIS/common/s19_result/s19_virtual/*/s19_masters.wl` banks wrap
`PolyLog[2, (Q2+s)/Q2]` in `Conjugate[...]`, in the `V07` master series and in
the matching `FunctionLimits` continuation record. The whole integral is not
conjugated and no blanket replacement is made.

### C3 — scale-check kernel

In `tools/pipeline/assemble_hard_recipes.wls`, `projectKernel` alone takes
`/.{D->4, eps->0}`. `projectSub` consumes the already expanded MSbar
counterterms and `projectBorn` keeps its own separate rule list.

### C4 — follow-on source correction required by C2

`common/physical_polylogs.wl` gained a rule for `Conjugate[PolyLog[2, x]]` with
`x > 1`, listed **before** the plain rule so `ReplaceAll` does not rewrite the
inner dilogarithm with the below-the-cut branch:

    Conjugate[PolyLog[2,x]] -> Pi^2/3 - Log[x]^2/2 - PolyLog[2,1/x] + I Pi Log[x]

Without it `HSPhysicalHermitian` rewrote the dilogarithm inside the `Conjugate`
head and left unresolved `Conjugate[Log[...]]` and `Conjugate[PolyLog[...]]` in
`pre_Hermitian_converted`. The reconstruction residual was then numerically zero
but not symbolically zero, and
`tools/development/prepare_virtual_master_coefficients.wls` failed its gate
`every complex Laurent coefficient reconstructed`. This is a representation
correction; it changes no archived master value.

### C5 — scalar-export identifier truncation (found after the comparison)

`common/native_compact_basis_linear.wl` labelled exported coefficients with
`IntegerString[n,10,3]`, which keeps only the last three digits of `n`. In a
block with more than 999 colour/charge monomials, index 1000 became `_c000`
and 1001 onwards overwrote 001 onwards in the exported `values`, `basis`,
`recipes` and `scalar_values` associations. The polynomial-reconstruction gate
runs on `colorRows` before identifiers are assigned, so it could not see the
loss, and every downstream check saw a complete, self-consistent, wrong set.

Two blocks are affected, in both the preserved run and this rebuild:
`r07/Hqq_Collins_T_plus_Regular_p0_b001` and
`r07/Hqq_Collins_T_minus_Regular_p0_b001`. Each has **1149** coefficients; the
truncated export kept 1000 identifiers (`_c000` … `_c999`), so 149
coefficients per block were silently dropped from the assembled transverse
`Regular` term. No r03 real certificate, no r06 virtual certificate and no
other r07 block exceeds 999 (largest elsewhere: 482).

**Causal confirmation.** Evaluating the r07 recipe directly, without scalar
export, and subtracting the truncated export's reconstruction gives, in the
comparison's normalization at the benchmark point `x=1/3, z=2/5, w=3/4`:

    0.09103198892753964850191237749766114126

which is the previously unresolved `Hqq` transverse interior residual digit
for digit (it was reported as `ours - theirs = -0.0910319889275396485…`). At
`x=1/2, z=1/3, w=3/4` the same construction gives `0.21017862619788669…`,
again matching. The longitudinal block gives exactly `0`.

**Fix.** Identifiers are now formatted by
`HSCompactIndex[n] = IntegerString[n,10,Max[3,IntegerLength[n]]]` — three-digit
zero padding below 1000, natural width above — for both the block index
(`_bNNN`) and the colour index (`_cNNN`). Two gates were added so a collision
fails the run instead of overwriting: `unique block identifier` and
`unique exported scalar identifier`. No consumer parses the identifier width.
The three retained development helpers with the same construction
(`native_basis_linear.wl`, `native_color_basis_linear.wl`,
`native_polynomial_basis_linear.wl`) received the same one-line change; none is
on the production chain.

**Regression.** `tools/checks/check_compact_basis_ids.wls` exports a synthetic
1003-monomial block and requires 1003 unique identifiers, no `_c000`, the
indices 1000–1003 present and exact reconstruction. It passes on the fixed
helper and fails on the previous one with exactly the wrap and a nonzero
reconstruction residual.

**Rebuild.** `hard-recipes` is unchanged (the defect is downstream of the
recipes). The export inventory was regenerated with the same producers the
recorded run used (`emit_native_final_packet.wls`,
`tools/development/prepare_native_contract.py`, `build_project.py`), with the
run's own r01 packet and the preserved reduction inventory; the r07 packet
emitter read the reused r07 sub-outputs through symlinks into the rebuild
tree. `hard-basis`, `boundary`, `observable` and the r07 packet were
regenerated with the fixed helper into the same rebuild tree; the truncated
intermediate outputs are kept beside them as `*-truncated-ids` for provenance.
Fixed export versus truncated export: 13,986 values against 13,688; exactly two
of the 32 finite candidates change, `Hqq Collins_T Regular` on both branches;
64/64 pole rows and 96/96 scale residuals remain zero; the fixed export equals
the directly evaluated recipe to the working precision on both branches.

**Historical impact.** The preserved run `20260916T095719Z-1584d7f6dd71`
carries the same defect: its 13,113 declared exports include the two wrapped
`_c000` identifiers, its `result.json` records `PASS` for their `.finite`
checks, and its transverse `Regular` finite coefficient is missing the same 149
coefficients per block. Those files are unchanged. Its recorded verdict is a
statement about the exports it declared; the declaration was incomplete in
those two blocks.

## Independent verification of the corrections

`Q2>0, s>0, t<0, Q2+s+t>0`, four interior points, Feynman deformation
`c14 -> -I eta - s`, `c23 -> -I eta + Q2+s+t`, `c34 -> -I eta + Q2`:

| continuation record | `eta -> 0+` limit | recorded value | verdict |
|---|---|---|---|
| V07 `PolyLog[2, 1-c14/c34]` | `Im > 0` | `Conjugate[PolyLog[2,(Q2+s)/Q2]]` | exact, deviation 0 |
| V06 `PolyLog[2, 1-c34/c23]` | `Im < 0` | `PolyLog[2,(Q2+s)/s]`, unconjugated | exact, deviation 0 |
| V06/V07/V08 remaining dilogarithms | real, argument `< 1` | unconjugated | exact, deviation 0 |

The uncorrected V07 record would have been wrong by `2 Pi I Log[(Q2+s)/Q2]`.
V06 and V07 take opposite signs of the infinitesimal imaginary part, so a
blanket conjugation would have introduced an error in V06.

## What the corrections change

**C2 changes 3 of 126 entries** of the portable virtual master bank — the
generic entry and its two branch views of the same quantity:

    V07_1_1_1_1_Re_p0  delta = 4 Pi^3 Log[(Q2+s)/Q2] / (s (Q2+s+t))

All pole coefficients, all imaginary parts, all other masters and all recorded
Laurent depths are unchanged.

**C2 does not change the assembled polarized virtual contribution.** The V07
reduction coefficient is purely imaginary (`Re[c] == 0`), so the Hermitian
physical combination `2 Re[Sum c M]` depends only on `Im[V07]`, while C2 moved
only `Re[V07]` at order `eps^0`. All 18 Laurent rows of the r06 virtual
assembly (6 components x 3 orders) are unchanged, and the regenerated virtual
master basis is content-identical to the registered one (same 378 selections,
same expansions, same values); only its recorded source hashes differ.

C2 remains a correctness fix to the archived bank and to anything else that
consumes `Re[V07]`; it is inert for this engine's observable.

**C1 changes 4 of 36 MSbar counterterm rows** — the FF-side `Regular` entry of
the four transverse components `11_XX, 11_YY, 22_XX, 22_YY`. The longitudinal
rows shift only at `O(eps^2)` because the longitudinal Born tensor is purely
evanescent (`Born_D4[Collins_L] == 0`), so their finite counterterm is unchanged.

**C1 changes exactly one finite hard coefficient**: `Hqq Collins_T Regular`, on
both branches. `Delta`, `L0`, `L1`, every longitudinal coefficient and every
`Hqqbar` coefficient are unchanged, as are `Born_D4` and the full row inventory.

## Rebuild

Reused unchanged from `20260916T095719Z-1584d7f6dd71`, after confirming that all
32 non-corrected registered inputs are byte-identical to their registration:
r00 Born tensors and amplitudes, r01–r02 real maps and reductions, r03 real
linear certificates, collinear templates, tagged/virtual operator records and
`scheme-match`, r04 virtual map, r05 virtual reduction, r06 `uv`, r07 UU import.

Regenerated into
`collins_support/states/runs/sidis-highpt-002-v07-subtraction-fix/`:

| artifact | producer |
|---|---|
| `masters/portable-virtual` | `tools/development/prepare_virtual_master_coefficients.wls` |
| `masters/virtual-portable-views` | `tools/development/prepare_virtual_master_branch_views.wls` |
| `masters/master-basis` | `tools/development/prepare_master_basis.wls` |
| `r05_result/jobs/virtual/masters.wl` | `collins_support/validators/sidis_highpt_extract.wls` |
| `r03_result/subtractions` | `tools/pipeline/transversity_subtractions.wls` |
| `r06_result/direct-virtual` | `tools/pipeline/assemble_virtual_masters.wls` |
| `r06_result/linear-{generic,plus,minus}` | `tools/pipeline/virtual_linear_certificates.wls` |
| `r07_result/hard-recipes` | `tools/pipeline/assemble_hard_recipes.wls` |
| `r07_result/hard-basis` | `tools/pipeline/assemble_native_hard_compact.wls` (rerun after C5; truncated output kept as `hard-basis-truncated-ids`) |
| `r07_result/boundary` | `tools/pipeline/check_native_boundary_series.wls` |
| `r07_result/observable` | `tools/pipeline/assemble_native_observable.wls` (rerun after C5) |
| `r07_result/packet.wl`, `finite-exports.wl`, `native-contract-r07.json` | `tools/pipeline/emit_native_final_packet.wls` (after C5; reused r07 sub-outputs are symlinked from the preserved run) |

`rebuild.sh` in that directory is the exact driver, with every input path
explicit. Downstream consumption was verified by path: the r07 hard-recipe
context names the regenerated subtraction, the regenerated r06 certificates and
the regenerated portable virtual bank; the hard-basis context names the
regenerated virtual basis and the regenerated extracted masters.

The real-side control passed: rerunning `prepare_master_basis.wls` on the
unchanged real bank and the same recipe inputs reproduced the registered
`real-master-basis.wl` content exactly (158 values, identical expansions,
identical original selections, zero changed coefficients).

## Checks after the rebuild

| check | result |
|---|---|
| pole rows `eps^-2`, `eps^-1` | 64 of 64 cancel |
| scale residuals `muR`, `muPDF`, `muFF` | 96 of 96 zero |
| finite rows | 32, complete |
| `r07_result/boundary/summary.json` | 16 rows, all finite, all equal, `all_completed_pass: true` (rerun after C5, same result) |
| registered source hashes | 34 of 34 match on disk |
| declared checks / exports | 16,796 / 13,439, regenerated from the fixed r07 packet (was 16,470 / 13,113: +28 from C1's change to the transverse `Regular` basis, +298 = 2 x 149 from C5) |
| observable | `UU0`, `UU1`, `UT0` identical to the truncated-ID build; only `UT1` changes; order residuals 0 |
| Wolfram syntax over engine sources | 145 of 145 pass |
| `tools/checks/check_compact_basis_ids.wls` | pass |

`complete_boundary_inventory` is `false` in the standalone boundary summary
because that flag is set by the full stage driver, not by the focused rerun.
All 16 rows are present and passing.

## Scope of this rebuild

This is a focused correction and rebuild of the affected stages, not a new
native campaign. It does not run r00–r07, the two-run campaign, pair comparison
or either dependency probe, and it does not transfer the historical run's
`NATIVE_CHECKS_PASS` to this source revision. The historical verdict, its
counts and its qualifications stand as recorded; the independent-comparison
verdict is kept separately in
`collins_support/reports/sidis-highpt-002-v07-subtraction-fix/README.md`.
