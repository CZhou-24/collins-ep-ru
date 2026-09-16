# Historical validator-delivery validation

The tables below describe the original adapter delivery, before the completed high-pT run. See the [current installation guide](INSTALL.md) and [engine status](../../../collins_sidis_highpt/README.md) for the later single-run record and remaining qualifications. Original test/verdict numbers below are retained.

# Validation of the delivered update

Prepared on 15 September 2026 from the supplied `collins_ep_reverse_unitarity_003_handoff.zip` and the published Collins source at revision `48b564843fc26bc2736d63536e6085ff2c7cb3e4`.

| Check | Result | Meaning |
|---|---|---|
| Existing current-validator software tests | 101 passed | The existing package and its release manifest remain unchanged |
| New SIDIS adapter software tests | 45 passed | Exact checks, specification coverage, input binding, runner orchestration, failure handling and probe arithmetic |
| Supplied handoff file inventory | 29/29 hashes and sizes matched | The selected subset is internally intact |
| Handoff packets versus native receipts | All eight stages matched | Packet bytes match their recorded receipt entries |
| Seed-report aliases and pair report | Matched | The renamed archive files retain the original report bytes |
| Base validator identity | Matched | `c016a289ceb0dbe5019373efcc23fea7d23f5adc5efed8664610f63663e0ecd3` |

Tests ran with Python 3.12.14 and SymPy 1.14.0. The scripts retain the current project's Python 3.10+ language compatibility, but Python 3.10 was not separately executed here.

The new suite covers corrupted or changed saved inputs, internal versus escaping symlinks, missing observable definitions, wrong perturbative orders, missing channel/pole checks, a zero UT channel retaining its UU denominator, nonzero pole residuals, incorrect certificate arithmetic, leftover regulators, insufficient epsilon depth, disconnected NLO coefficients, incomplete/misidentified runs and duplicate-run comparison. It also exercises a development run and the complete eight-stage adapter, pair comparison and both probe seeds with explicitly mocked native tools. Synthetic expressions in these tests are software fixtures, not predictions.

The 45-test count includes the optional handoff-integrity test. Running the installed test script without `SIDIS_HANDOFF_BUNDLE` skips that one test; this does not indicate an installation failure. Existing current-validator tests retain their own meaning and do not certify the new process.

**Not performed here:** actual Wolfram execution of the new extractor, a native polarized SIDIS derivation, fresh Kira/SubTropica jobs for the new process, or an independent physics audit. The handoff lacks the full native trees and second run, so its reported native acceptance was not replayed. These are stated limits of the delivered validator update, not claims of completed polarized NLO physics.

The bundle README's runtime comparison refers to the upstream SIDIS repository. The relevant Collins validator baseline was checked separately against the supplied run's release identity. The update does not modify the user's runtime configuration.

The archive contains additive files only. No old engine, validator, reference, report, native evidence, installed tool, publication checkout or saved state is overwritten by the documented `unzip -n` installation.
