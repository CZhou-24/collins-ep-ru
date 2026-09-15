# SIDIS conventions first

The production convention baseline is `NonHermitianMatrix/SIDIS_dsigma_till_NLO` at commit `5062dcb2407594dafcc2f9f72800e96ff9e6d957` (confirmed against GitHub on 2026-09-12). `sidis_convention_lock.json` pins selected source files by SHA-256 and Git blob identity; exact source snapshots are under `reference_sources/sidis/`. This is a targeted source pin, not a claim that the full repository has been vendored or revalidated.

Use the source definitions, including channel-specific normalization, rather than transplanting a convenient equation from another paper. The SIDIS process uses a virtual photon and different perturbative counting from photon-exchange ep Born scattering. For example its `s=(p+q)^2`, `t=(q-k1)^2`, `q^2=-Q2` must be mapped, not equated by name to the ep `s,t,u`. Its nonzero-transverse-momentum hard structure functions start at alpha_s; ep Born starts at alpha_EM^2. Both statements can hold simultaneously.

The unpolarized repository does not define a Collins moment, transverse spin projector or TMD rapidity subtraction. Specify these as explicit extensions compatible with its shared definitions. Keep native production expressions in that convention. `finite_matching.json`, `scheme_conversion.json` and the compact `symbolic_observable.json` are explicitly converted, verifier-side comparison representations. Their equality to the references does not by itself show that a native SIDIS-compatible output was derived. `native_matching.wl`, `native_observable.wl`, native conversion proofs and the ledger supply the traceable connection for source review.

## Ledger interface

Emit `common/d14_result/conventions.json` with exactly:

- `schema`: 1.
- `baseline_commit`: the pinned commit.
- `baseline_files`: the path-to-SHA-256 map obtained from `sidis_convention_lock.json`'s `files` entries.
- `rows`: exactly one record for each ID in the lock's `rows` map.

Each row has `id`, `status`, `baseline_definition`, `production_definition`, `reference_definition`, `evidence`, `note`. Definition/note fields are nonempty strings. `evidence` maps run-relative artifact paths to SHA-256, not source-tree paths or URLs. For inherited quantities use `INHERITED` or `CONVERTED`; for quantities absent from SIDIS use `EXPLICIT_EXTENSION`. `UNRESOLVED` is allowed only as an explicit blocker. For absent definitions, say so in `baseline_definition` with the relevant inspected source scope. A general absence cannot be inferred from five selected files alone; inspect the appropriate full source on the implementation machine.

Required inherited rows: `invariant_map`, `dimensional_regulator`, `couplings`, `spin_color_averages`, `phase_space`, `factorization`.

Required explicit extensions: `transverse_spin`, `collins_moment`, `fourier_tmd`, `rapidity_scheme`, `perturbative_truncation`.

Collectively the evidence must include:

- `common/d13_result/native_matching.wl`, `common/d13_result/finite_matching.json`;
- `common/d14_result/normalization_derivation.wl`, `scheme_derivation.wl`, `regulated_scheme.wl`, `scheme_conversion.json`, `proofs.wl`;
The later d15 stage supplies `native_observable.wl`; its hash belongs in the d15 derivation manifest, not the earlier d14 ledger.


A literal mismatch to a printed reference is recorded unchanged in the comparison report. Do not alter a production convention simply to remove that discrepancy. If no valid conversion has been derived, acceptance remains BLOCKED. The hard-constant shift is a comparison, not an automatically justified counterterm. A common finite redistribution that sums to zero is necessary but cannot establish individual regulator-dependent shifts.

Keep electromagnetic normalization, flux, initial averages, fragmentation measures and operator definitions distinct. MadGraph compares full-coupling matrix elements without phase space/flux. Its interface conversion must be derived explicitly. Fixed-order comparisons use a=alpha_s/(2pi); native expansion notation may differ if the exact conversion is recorded. No empirical 2z rescaling is accepted as a derived normalization.
