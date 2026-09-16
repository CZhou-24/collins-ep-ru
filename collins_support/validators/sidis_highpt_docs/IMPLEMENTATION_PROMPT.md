# Implement polarized high-pT SIDIS using the existing calculation

Work in `/bigTMD`. Implement the Breit-frame Collins hadron-in-jet calculation at high jet transverse momentum, using the existing verified unpolarized SIDIS workflow and saved amplitudes. Use the installed additive validator in `collins_support/validators/sidis_highpt.py`. Aim to complete the implementation and native validation today; report a real scientific blocker accurately if the calculations cannot establish the required result. Do not lower the acceptance standard to meet the time target.

This is one implementation assignment. Continue through routine coding, interface, algebra and runtime fixes without repeatedly asking for permission. Do not stop after a scaffold, a plan or a Born-only example. Use one agent unless the user explicitly authorizes delegation. Do not send messages to collaborators or publish/push changes without authorization.

## Starting material and scope

Zhongbo distinguished:

1. Back-to-back electron–jet production in the electron–proton beam frame, followed by a hadron inside the jet; the current Collins TMD package addresses this.
2. High-pT SIDIS in the Breit frame, with the virtual photon and proton defining the axis; hard jet production is described by collinear factorization. He requested the unpolarized BigTMD baseline followed by the appropriate polarization projection at NLO.

For this assignment, the working target is the Collins hadron-in-jet spin-transfer observable in setup (2): an unpolarized electron and transversely polarized proton, a hard jet measured relative to the photon–proton axis, and the hadron transverse momentum/azimuth measured relative to that jet. This is an explicit working interpretation of the conversation, not a quotation of a complete factorization theorem from Zhongbo. Establish its precise factorization, measurement and accuracy in `SCOPE.md` before final acceptance. Keep collinear hard production distinct from any TMD fragmentation inside the jet.

Use the session/project instructions and any applicable local AGENTS.md. Read the supplied handoff and the installed `sidis_highpt_docs/INTERFACE.md`. Do not restart retired cleanup, migration, preservation or Figure 6 campaigns.

Known locations:

- `/bigTMD/SIDIS/`: existing six-channel unpolarized high-pT SIDIS calculation.
- `/bigTMD/collins_ep_analytic_SIDIS/`: current electron–jet Collins calculation. Its working producing code and existing acceptance must remain intact.
- `/bigTMD/collins_support/validators/analytic/`: unchanged current checker and native integration interfaces.
- `/bigTMD/collins_support/validators/sidis_highpt.py`: the new additive entry point.
- `/bigTMD/collins_ep_analytic_SIDIS/ru_runtime.json`: existing native runtime paths.
- `/bigTMD/publication/collins-ep-ru-upload/`: separate publication checkout; do not synchronize or push automatically.

Upstream SIDIS repository: `https://github.com/NonHermitianMatrix/SIDIS_dsigma_till_NLO`, recorded revision `5062dcb2407594dafcc2f9f72800e96ff9e6d957`. Current published Collins baseline: `https://github.com/CZhou-24/collins-ep-ru`, inspected revision `48b564843fc26bc2736d63536e6085ff2c7cb3e4`.

The actual saved Hqq amplitude bank exists at `SIDIS/Hqq/s01_result/s01_inputs/s01_result.wl`, with `Born`, `RealQGG`, `RealSame`, `RealDistinct` and `Virtual` expressions retaining external spinors. Other channels have their own preserved input banks. Read their manifests and source generators to identify the correct amplitude-level inputs; do not try to reconstruct spin information from final spin-averaged F1/F2.

The previously checked unpolarized coefficients and BigTMD comparisons are useful existing evidence. Preserve their literal reference conventions and qualifications, including the separate unresolved Hgq MadGraph comparison. Use relevant established checkpoints when their identities/definitions match; do not rerun the entire unpolarized derivation simply to re-establish history.

## Deliverable layout and allowed changes

Create the new producing implementation in `/bigTMD/collins_sidis_highpt/`, with `project.json`, `SCOPE.md`, `common/r00.wls` through `r07.wls`, focused helper files and independently prepared reference formulas. Keep its new run evidence in `collins_support/states/runs/sidis-highpt-001/` and new reports in `collins_support/reports/sidis-highpt-001/`. Use new run directories when source changes. Preserve unrelated work.

Adapt the new SIDIS validator files only when a concrete implementation requirement is demonstrated. Add a focused regression test for a real interface/validation fix and update the corresponding entry in `sidis_highpt_files.json`. Do not change the old `analytic/` code, manifest or reference values to accommodate the second process. If a shared interface limitation is encountered, prefer a narrow local adaptation in the new files. No new validator version tree, general plugin framework, migration scheme or repeated backup archives are needed.

All shell commands in instructions and progress reports should be one physical line. Retain a concise progress record and explain findings in physics terms. Keep analytical reports separate from any supporting numerical comparison report.

## Implementation sequence

1. **Inspect the actual baseline.** Confirm the current validator software checks; inspect the source identities and saved amplitudes. Read the high-pT SIDIS kinematics, channel/projector conventions, master definitions and existing BigTMD comparison. Register only required source files by exact hash. Treat saved amplitudes, master values and validated UU coefficients as reused inputs; never label them freshly derived.

2. **Define the observable.** Specify Breit-frame vectors, hard variables, incoming/outgoing transverse-spin bases, the Collins azimuth, jet algorithm/radius, chosen jet approximation, hadron momentum convention, gamma5/dimensional scheme, factorization scales and subtraction conventions. Hard LO is order alpha_s and NLO is alpha_s squared, apart from electroweak couplings. Derive or source the applicable factorization and jet/fragmentation matching. The original inclusive fragmenting-parton coefficients are not automatically jet coefficients at NLO: account for the jet measurement and clustering consistently, or limit the stated result to the hard kernel until those pieces are established. Do not reuse the small electron–jet-imbalance soft factor as the Breit-frame hard-production formula.

3. **Build and check the polarized Born calculation.** Insert spin-density/projector information before summing over the relevant external quark spins. Establish the needed polarized tensor structures, lepton contractions and angular harmonics; the unpolarized photon F1/F2 projections need not span them. Recover the old unpolarized contractions from the same amplitudes. Independently verify spin normalization/signs with a separately coded physical spinor, Clifford or helicity calculation and check Ward identities and basis rotations. Implement r00, then run its native development check. This is a milestone, not the stopping point.

4. **Review all channel assignments.** Determine which of Hqq, Hqg, Hgq, Hgg, Hqqbar and Hqqprime contribute to transversity/Collins spin transfer. Derive excluded-channel zeros and record the operator/helicity reason. Preserve all needed unpolarized denominator contributions even when a channel's polarized numerator is zero. Register reused UU coefficients and their saved validation evidence explicitly.

5. **Complete one active channel through NLO.** Start with the appropriate quark channel. Reuse the saved process amplitudes and propagator geometry where applicable. Derive polarized real and virtual numerators and all relevant interferences, retaining dimensional Born terms needed with poles. Pass the new targets through Kira; preserve positive-energy cuts and exact integrand reconstruction. Reuse old scalar masters only after matching measures, variables, cut support, branch/continuation and expansion depth. Use fresh SubTropica evaluations for genuinely new/insufficient masters. The original current and new high-pT hard process have different kinematics; do not insert the current's virtual coefficient as a substitute.

6. **Derive the subtraction and finite assembly.** Use the appropriate transversity and fragmentation/jet counterterms. Do not carry over unpolarized channel mixing blindly. Check UV and remaining IR/factorization cancellation coefficient by coefficient, including independent charge/color structures, delta/plus/regular distributions and endpoint actions. Check the appropriate scale evolution identity, not arbitrary scale independence of a single hard coefficient. Keep any physical endpoint assumptions explicit; generic contacts cannot be declared zero because they were restricted in the first process.

7. **Extend to every required channel and assemble the symbolic observable.** Produce finite UU/UT hard coefficients through the declared orders and the correct hadronic convolution/Collins harmonic with symbolic distributions and fragmentation functions. Retain full relevant unpolarized channel coverage. Keep physical predictions/fits outside scope unless separately requested.

8. **Complete native validation.** Fill the declared check and output inventories with actual derived expressions. Keep independent reference formulas separate from production. Run two fresh full workflows with identical input/source/runtime identities, compare all exported coefficients and run the real/virtual dependency probes with seeds 1729 and 92741. Fix routine failures and rerun only affected development work until ready for the final campaign. Re-run the software suites after validator edits.

Use the commands in `INSTALL.md`; do not invent CLI switches. The source/evidence protocol and exact prefix-expression transport are in `INTERFACE.md`. If the required expressions need an interface extension, implement and test it locally rather than substituting a numerical approximation or a hardcoded desired coefficient.

## Validation requirements and reporting

- Emit calculated residuals for identities and pole tests. A literal `PASS`, a table of declared statuses, or a frozen desired zero does not establish the result.
- Do not tune physical coefficients, references, comparison maps or tolerances to force agreement. Document genuine convention transformations with all compensating factors.
- In dependency probes, keep generating formulas unchanged. Let the validator evaluate the intentionally changed residuals and expected algebraic response. Never branch to a special answer under `validation_probe`.
- Record exact reuse separately from fresh derivation. The provided handoff is a one-run subset with two reported seed results; it is not a full native replay and does not establish this new process.
- Preserve the old electron–jet tests and their meaning. New `NATIVE_CHECKS_PASS`, pair and probe results cover declared computational checks; independent physics review remains pending.
- Keep a row-level comparison inventory: exact, exact after documented conversion, mismatch, or unverified. New-loop expressions lacking an independent reference must remain identified as such even when internal consistency passes.
- Do not stop for routine implementation choices or small corrective edits. If a genuine unresolved definition, missing operator contribution or integration obstruction prevents the requested observable, finish the useful work that does not depend on it, record the exact blocker/evidence and the remaining scientific decision, and do not advertise complete NLO acceptance.

Deliver the producing code, updated project/check specification, native run/report paths, a readable derivation note and a short status explaining what was reused, what was calculated, which checks actually ran, what accuracy/domain is supported and what remains unresolved. Do not claim completion from software tests or a successful Born pilot alone.
