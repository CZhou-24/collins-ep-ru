# v0.3.3 — native parameter-card serialization

- Replaces `.17e` with `.17g` for fixed benchmark entries, preserving binary values within MG5's 20-character reader field.
- Adds genuine reader/card fixtures and tests for truncation, exact round trips, idempotence and unchanged unrelated entries.
- Accepts the exact v0.3.2 installation issuer without modifying preservation locks; state defaults use v0.3.3.
- Leaves amplitudes, conventions, phase-space generation, coefficient oracles, proof requirements and tolerances unchanged.
- Records independent execution of six archived binaries, and documents Python-version sensitivity of exact historical replay without relaxing any gate.
- Updates the prompt to complete execution and acceptance of the reviewed candidate. Full NLO and reverse unitarity remain later work.

# v0.3.2 — native-driver and evidence repair

- Restores the double-precision `ZERO=0D0` parameter required by actual MG5 3.7.0 `pmass.inc` files under `IMPLICIT NONE`.
- Captures generated MadGraph links by link text, resolved in-tree target, target hash/executable bit, and missing-target state. Handles optional dangling leaf includes without treating them as build success.
- Limits links to the three known generated standalone trees. Rejects escaping/absolute/cyclic/directory links and special nodes; production `snapshot` and source-path guards are unchanged.
- Seals the generated native tree in each build identity and checks it again during native replay. Retargeting a link changes evidence even when target bytes agree.
- Writes a failed verifier report if evidence capture fails, preserving earlier check rows. A safely located comparator output receives failure JSON on comparison errors.
- Accepts exact v0.3.0 and v0.3.1 installation issuers without rewriting original locks or inventories. New run/report defaults use v0.3.2.
- Adds actual generated mass-include fixtures and regression tests for link preservation, replay and failure reporting.
- Retains the equation inventory, stages, reference formulas, conventions, amplitudes and comparison tolerances. Updates the prompt to validate the saved d13–d15 candidate; full NLO and reverse unitarity remain later missions.

These are validator repairs. Native compilation and amplitude agreement remain requirements on the implementation machine.

# v0.3.1 — MadGraph parser compatibility

- Recognizes valid trailing Fortran comments in MG5 3.7.0's literal SETPARA initialization; counts all active calls before validating the supported API.
- Retains strict rejection of unsupported arguments, duplicate initialization, continuations and extra statements; preserves exclamation marks inside quoted strings.
- Adds genuine archived driver/matrix fixtures and negative parser cases. Existing matrix instrumentation is unchanged.
- Accepts the exact v0.3.0 installation-lock issuer without rewriting locks, runtime configuration, candidate files or original preservation inventories. New output state defaults to v0.3.1.
- Leaves the 31-obligation inventory, stages, reference formulas, convention lock, physics inputs and comparison tolerances unchanged.
- Adds a focused continuation prompt, including genuine coefficient-producing reverse unitarity as an additional independently reviewed requirement. Existing automated acceptance alone does not certify that requirement or full polarized fixed-order NLO.

This patch fixes checker compatibility, not the missing endpoint, Collins or finite scheme derivations. Native MadGraph generation/compilation must still be exercised on the implementation machine.

# v0.3.0 — analytical derivation contract

- Adds d13–d15 production scaffolds, a frozen 31-obligation inventory, native evidence requirements and separate provenance/agreement labels.
- Pins applicable SIDIS conventions and requires explicit TMD/Collins extensions and paper-side conversions.
- Adds exact finite distribution comparisons, normalization and scheme checks, fresh numerator dependency probes and native MadGraph amplitude/interference machinery.
- Adds analytical-only foundation/assembly acceptance, preserving clean native replay and historical numerical profiles.
- Adds complete-report replay checks and two-seed final report comparison.
- Preserves all original candidate files through an additive installer and external installation identity.

This is a validator release, not a completed physics implementation. New production stages intentionally exit BLOCKED until implemented. Release tests cover checker behavior and synthetic/mocked fixtures. No Wolfram/Kira/SubTropica or native MadGraph calculation has been run during preparation. Source review is required after automated checks. Phenomenology and reorganization remain deferred.
