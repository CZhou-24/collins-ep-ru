> **Deferred by the user's current sequence.** This retained specification is for a later mission after current scoped acceptance and full NLO work. It imposes no reverse-unitarity acceptance gate on v0.3.3.

# Reverse-unitarity requirement for the continuation mission

This is an additional scientific/workflow requirement for the continuation mission. The v0.3.1 patch retains the v0.3.0 automated equation contract. A `CHECKS_PASS` from that contract does **not** certify this requirement. Until the evidence below has been produced and independently source-reviewed, report `REVERSE_UNITARITY: UNVERIFIED` or `BLOCKED`; never infer acceptance from filenames or a manifest alone.

## Native route and scope

Use the pinned SIDIS commit `5062dcb2407594dafcc2f9f72800e96ff9e6d957`. Relevant precedents are `SIDIS/common/s03_real_families.wl`, `s04_reduce_real.wl`, `s08_cut_master_inputs.wl`, and `s10_evaluate_cut_masters.wl`. Obtain and verify these exact files at the pinned commit; the convention-lock extracts alone do not contain the entire integration workflow. Adapt the integral families to our measured Collins ep observable. Do not copy SIDIS coefficient functions or assume its photon-parton and our electron-parton variables coincide.

The intended real-emission chain is:

1. Fresh generated amplitudes/operator insertions and regulated UU/transverse projections.
2. On-shell delta constraints represented by cut propagators, with physical positive-energy support retained explicitly.
3. Reconstruction of the original integrand in the chosen cut families.
4. Actual Kira reduction with declared cut propagators and correct vanishing rules.
5. Evaluation of the masters returned by that reduction, using SubTropica where applicable and documented treatment of measurement/rapidity boundaries.
6. Endpoint expansion and subtraction, then finite exports actually consumed by d13/d14/d15.

Virtual graphs continue to use ordinary loop-integral mapping. Tarasov dimension shifts are required only if the chosen reduction needs them; record the relation and convention when used. No FORM backend is required by this continuation.

## Protected-source boundary

Retain s00-s12 and their old radial results as regression evidence. Add helpers called from the editable d13/d14/d15 stages. The new branch may consume freshly generated unintegrated s10 amplitudes, but its cut reductions must not be supplied by the already integrated s10 radial master. Operator-specific graphs absent from s10 must be generated separately. The final finite terms must trace to the new branch. This is an additive implementation, not permission to rewrite protected original files or old run directories.

## Required evidence

For each contributing real sector, retain the following in each fresh run:

- Process/operator definition, spin/color projectors, loop routing, measurement definition, regulator, and native normalization.
- Exact delta-to-discontinuity identity with its sign and factors of `2*pi*i`. Preserve the positive-energy theta constraint; a discontinuity alone does not select that branch.
- Cut-family definitions, integral targets, powers and numerator reconstruction. At least one nonzero contributing family must be reduced as a genuine cut family, not an uncut radial tadpole renamed as a cut calculation.
- Kira configurations including `cut_propagators`, jobs, logs, generated rules, and master inventory. Check that masters/targets obey the cut-index rules and that terms with removed required cuts vanish.
- Master definitions reconstructed from those returned rules. Derive phase-space Jacobians, angular factors and the needed epsilon expansion depth from the pole orders multiplying the masters.
- Native SubTropica inputs/logs/results for the applicable returned masters. If positivity constraints are solved to map a cut master to an Euler density, preserve that derivation and independently check its normalization against the original cut measure.
- Explicit handling of cone/jet theta functions, transverse measurements, rapidity regulators and endpoint distributions. Do not differentiate a physical boundary while discarding its surface term, or treat noninteger rapidity powers as ordinary integer cut indices. Establish validity of each IBP identity for the chosen domain/regulator.
- Tests of an actual upstream numerator/projector/cut-normalization perturbation in disposable runs, showing the predicted changes in reduced integrals, finite coefficients and symbolic assembly. Changing only the final export is insufficient.
- Fresh-run source/input/output hashes and executable commands; independent comparisons at nonsingular physical points and distribution-level checks where applicable.

Use a sector ledger to identify which pieces follow the cut route and which need a different justified treatment. If some required sector cannot be treated consistently, retain that exact blocker rather than declaring the whole route reproduced. A pilot unrelated to the final finite exports does not satisfy the requirement.

## Acceptance and NLO boundary

The reviewer must inspect the cut mapping, integration domains, reduction rules and actual downstream consumption. A structural manifest can establish traceability, but cannot prove the physical reduction. Report this source-review outcome separately from the existing 31-obligation automated result.

This continuation preserves the declared leading-power, narrow-jet and diagonal homogeneous twist-three scope. Completing the cut route and those obligations is not a certificate of the full polarized fixed-order NLO observable. Keep the outstanding full-NLO terms in the scope ledger; do not silently change the measurement or remove required channels to obtain agreement.
