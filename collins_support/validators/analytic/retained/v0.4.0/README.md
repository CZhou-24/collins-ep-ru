# Collins ep analytical validation v0.4.0

This retained checker now lives inside the one active validator at `collins_support/validators/analytic/retained/v0.4.0`. Use [RELOCATION.md](../../../../reports/RELOCATION.md) for current commands and exact path/configuration identities. Installation/upgrade descriptions and campaign requirements below are historical; no standalone v0.4.0 release is required. Scientific checks and qualifications are unchanged. Current retained replay is invoked by the active project-local RU comparator.

## Historical v0.4.0 release guide

This is a **separate validator extension and implementation mission**, built on the accepted v0.3.3 sources. It contains executable validation machinery, an additive installer, native transport checks, reference comparisons, software tests and an agent prompt. It does **not** contain the new physical derivations. The agent implements those under `/bigTMD/collins_ep_analytic`.

The primary physical specification is [2007.07281v1](https://arxiv.org/abs/2007.07281v1): an unpolarized electron and transversely polarized proton, an anti-kt jet with the standard axis, and the Collins hadron-in-jet modulation. The eventual Figure 6 settings remain R=1, qT/pT_jet<0.3 and jT<1.5 GeV, with its other cuts/bins and scales. **This release targets complete one-loop matching/assembly within the leading-power framework; it does not target unrestricted fixed-order recoil, power corrections, a fit, or Figure 6.**

The existing producing derivation uses a narrow-cone expansion. Its hard/jet/soft exports match the paper's A1–A3, but their derivation at R=1 remains qualified. This release records that issue without pretending it is resolved or requiring a wholesale finite-R calculation. See `docs/SCOPE.md`.

## What is retained and what is new

| Part | Treatment |
|---|---|
| Accepted v0.3.3 validator | Included under `retained/v0.3.3`; original manifests remain in the relocation origin record, with exact path/configuration changes and updated nested identities |
| 1,399 accepted candidate files | Frozen by `accepted_sources.json`; new code is additive, and original installation locks/baselines stay untouched |
| s00–d15 | Regenerated in each final workflow; the retained official two-seed verification and pair replay remain mandatory |
| d16 | Measurement, operator basis, EOM/contact conventions and explicit identification with the paper |
| d17 | Independent two-fraction HF contribution, its mixing into Hhat, finite small-b matching, and endpoint contacts |
| d18 | Finite quark fragmenting-jet/TMD conversion under the ep measurement, including overlap subtraction |
| d19 | Symbolic first-order UU/UT assembly consuming d17 and d18, with the retained approximation recovered explicitly |

The 26 new obligations in `contract.json` supplement the 31 retained obligations. They are not a claim of automatic coverage of every one of the historical 70 equation rows. New comparison documents must keep derivation origin, mathematical agreement and scientific scope separate.

`docs/COVERAGE.md` maps every new obligation to its automated evidence and remaining source review. `RELEASE_TESTING.md` records which release checks were executed here and which native checks must run on the installed physics environment.

## Independent checks and their limits

The extension executes native Wolfram stages, seals native files and dependency records, independently reexports the Wolfram packets, and checks exact coefficient/distribution identities. It tests collinear counterterms, regulator cancellation, matching-scale derivatives, rapidity independence of the new HF coefficient, finite-jet spin/scale consistency, perturbative assembly, scheme compensation and the ratio after a common integration functional.

Both seeds also trigger fresh upstream epsilon-projector perturbations in d17 and d18 and then regenerate d19. The required response includes HF endpoint contacts. A candidate that only changes metadata, reads a fixed final answer, or omits a downstream dependency should fail these tests; source review is still needed to assess the actual insertion point.

The two new Collins references contain a **literal off-diagonal-kernel discrepancy**. Both source formulas are preserved; the verifier records both residuals and requires an explicit supported comparison plus a derivation-based explanation. Their bulk comparison does not determine every endpoint contact. The new finite HF and finite-jet constants do not have a complete, settled frozen numerical oracle in this release: they require agreement between two documented native routes, upstream-response evidence, and **scientific source review**. A common wrong constant can satisfy RG/pole identities, so those checks alone never grant physical certification. `tests/test_math.py` explicitly tests this limitation.

`CHECKS_PASS` means the specified automated checks passed, including retained native MadGraph acceptance. `source_review=REQUIRED` and `radius_R1_certification=NOT_GRANTED` remain explicit. No report automatically grants full fixed-order NLO, full closed twist-three evolution, or Figure 6 certification.

MadGraph remains the independent partonic amplitude check already implemented in v0.3.3. This release does not replace it with a stub. It does not use MadGraph to claim validation of Wilson-line operators or their fragmentation matching.

## Use

1. Read `INSTALL.md` and run its software and native transport checks.
2. Give the agent `AGENT_PROMPT.md`, together with the release location.
3. The agent implements the four **candidate-owned** scripts named in `contract.json` and their native libraries. Read `docs/INTERFACES.md` before implementation.
4. Complete source changes and comparison documents before freezing the candidate for two fresh workflows.
5. Run `verify_nlo.py` at seeds 1729 and 92741 and `compare_nlo_reports.py`; return the sealed evidence and scientific review for independent audit.

No numerical provider is run for analytical acceptance. `--numerical-state` in the retained runner locates protected historical records only. Fitting, Figure 6, broad reorganization and reverse unitarity remain deferred. The existing radial integration route must not be relabelled reverse unitarity.

Use the same Python version through a campaign. The accepted native campaign used Python 3.10.12; Python 3.12 float-summation changes affect exact retrospective request replay. The v0.4.0 code does not patch those old requests or relax identity checks.
