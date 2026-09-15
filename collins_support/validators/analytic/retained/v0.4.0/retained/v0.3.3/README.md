# Collins ep analytical validation v0.3.3

This retained checker is installed inside `collins_support/validators/analytic/retained/v0.4.0/retained/v0.3.3`. Read [RELOCATION.md](../../../../../../reports/RELOCATION.md) for current commands and the exact path/configuration changes; scientific checks and qualifications remain unchanged. All installation, execution and verification commands below describe the completed historical v0.3.3 campaign. Do not execute those root-location commands, reinstall scaffolds or restore old standalone validator releases. Current retained evidence replay is invoked by the active project-local RU comparator.

## Historical v0.3.3 release guide

This release repairs MG5 parameter-card serialization. Its reader stores 20 characters per value, while `.17e` produces 23. The replacement `.17g` encoding fits all five fixed benchmark entries and preserves their exact binary values. The ZERO declaration and generated-link repairs are retained.

Review re-executed copies of all six compiled official drivers. Each fails with its original card, then passes all amplitude comparisons after only the formatting change. These are executions of archived binaries, not fresh compilation or official acceptance.

The saved candidate already implements d13–d15. Adopt this external validator and validate that candidate under the unchanged analytical contract. The bundled original scaffolds remain intentionally incomplete and must **not** be installed over the saved implementation. Installing this patch does not establish a new physical result.

The analytical calculation and its acceptance checks do not require fitted PDFs or fragmentation functions. The existing numerical sources and saved regression records remain protected. Figure 6, fitting, and phenomenological changes are paused.

## Scope and conventions

The frozen contract is `equation_inventory.json`: **31 obligations**, of which 27 require derivation and four explicitly identify external coefficients, symbolic matrix elements, or a model. The scope is Born and one-loop leading-power Collins ep, with the stated diagonal homogeneous twist-three approximation. Full twist-three mixing, two-loop derivations, nonsingular recoil terms, and full polarized fixed-order NLO are outside this release.

Use the [SIDIS_dsigma_till_NLO repository](https://github.com/NonHermitianMatrix/SIDIS_dsigma_till_NLO) at commit `5062dcb2407594dafcc2f9f72800e96ff9e6d957` as the baseline for applicable conventions. The frozen `sidis_convention_lock.json` records the commit, Git tree, and file hashes; source extracts are bundled under `reference_sources/sidis/`. Inherit its applicable coupling, dimensional-regularization, subtraction, and normalization conventions with source citations. SIDIS partonic photon scattering and full electron–parton scattering use different invariants and prefactors; derive the map instead of identifying them by their names. Transverse-spin, rapidity, TMD, and Collins conventions absent from the original calculation require explicit extensions.

Paper equations remain literal references. Store any translation, correction, or suspected discrepancy separately; do not modify a quoted equation to manufacture agreement. In particular, a disagreement between two papers is not automatically a production error, and an empirical `2z` rescaling is not an accepted normalization conversion.

The references are pinned in `references.json`:

| Reference | Role |
|---|---|
| [2007.07281v1](https://arxiv.org/abs/2007.07281v1) | Electron–jet and Collins ep factorization; Appendix A |
| [1505.05589v1](https://arxiv.org/abs/1505.05589v1) | TMD definitions, finite matching, evolution, and Collins moments |
| [1303.2129v1](https://arxiv.org/abs/1303.2129v1) | Independent polarized TMD evolution and matching |
| [1707.00913v2](https://arxiv.org/abs/1707.00913v2) | Hadron-in-jet Collins conventions; its pp hard scattering is not an ep hard factor |

## What the extension adds

| Stage/check | Required result |
|---|---|
| Retained `s00`–`s12` | Existing amplitude, reduction, master, subtraction, and assembly evidence |
| `d13` | Derived finite matching and splitting distributions, including delta, plus, regular, and subtraction terms; native Wolfram exports |
| `d14` | Derived Fourier/Collins normalizations, finite regulator-to-TMD conversion, hard-factor redistribution, rapidity compensation, and evolution measures; explicit convention ledger |
| `d15` | Native symbolic UU/UT assembly consuming upstream outputs, with unevaluated hadronic matrix elements and a declared first-order expansion |
| Independent verification | Symbolic and distribution checks, upstream dependency probes, fresh-run reproducibility, and native MadGraph amplitude comparisons |

MadGraph checks cover photon-mediated `eq -> eq`, `eq -> eqg`, and `eg -> eq qbar` UU amplitudes, plus double transverse quark-spin coefficients in the quark channels. The spin check requires complex helicity interference and native spinor phase calibration. Helicity-squared differences are insufficient. These are partonic amplitude checks, not checks of Collins fitted functions or TMD subtraction.

Read `docs/DERIVATION_INTERFACES.md` and `docs/MADGRAPH.md` for the exact artifact and adapter contracts. `AGENT_PROMPT.md` gives the focused acceptance assignment. Retained validator scripts are included for compatibility; the current acceptance entry points are `verify_derivation.py` and `compare_derivation_reports.py`.

## Existing v0.3.0–v0.3.2 installation: adopt the patch

Extract this release into a new external directory. Keep the old validator and saved results. **Do not rerun the scaffold installer over the saved implementation, edit an installation lock, or reset a baseline.**

```bash
COLLINS_VALIDATOR=/Collins-ep-analytic-validation-v0.3.3
export OPENBLAS_NUM_THREADS=1 OMP_NUM_THREADS=1 MKL_NUM_THREADS=1
export PYTHONDONTWRITEBYTECODE=1
python3 "$COLLINS_VALIDATOR/selftest.py"
python3 "$COLLINS_VALIDATOR/workflow.py" doctor --repo /bigTMD
```

The patch explicitly accepts the original preservation lock only when its issuing manifest is the known v0.3.0 identity `e87f8da47802f37d61e0e9cf7c07f75b66c374bba258d2e4044d93d50cbbed08` or the exact v0.3.1 identity `fc169985cd5634d8c8ef3ab3faa99b1857603617f088b4897ffdc4fe9b196ffa`, or the exact v0.3.2 identity `4b8ef224916cae97bba765567b0ba3f565bed7b5d70f3dbb2f588c6172416ae8` (or the current release). The original lock and its protected-file inventory remain unchanged. New runs record the new validator identity and continue to check those original protected files. Candidate additions remain editable; they are not promoted into the protected inventory merely by adopting this patch.

Use `/Collins-ep-analytic-state-v0.3.3` for new runs and reports. `derivation_runtime.json` may continue to point to `/Collins-ep-analytic-state-v0.3.0/installation.json`. Run outputs and installation-lock location serve different purposes.

Read `AGENT_PROMPT.md` for the focused acceptance run. **Reverse unitarity is DEFERRED BY USER.** The document under `docs/REVERSE_UNITARITY_CONTINUATION.md` is retained as a future specification, not an acceptance requirement for this mission. The agreed sequence is current scoped acceptance, full NLO implementation, then organization and reverse unitarity. This patch implements no new physical coefficient.

The changed validator identity requires two fresh workflow runs; an old v0.3.2 run cannot be relabeled as a v0.3.3 run. Keep the existing derivation source and regenerate its results. No installation-lock or runtime edit is needed just to select this release.

## First installation only

Use a validator directory outside the repository. The example assumes it was extracted to `/Collins-ep-analytic-validation-v0.3.3`:

```bash
COLLINS_VALIDATOR=/Collins-ep-analytic-validation-v0.3.3
python3 "$COLLINS_VALIDATOR/selftest.py"
python3 "$COLLINS_VALIDATOR/install.py" --repo /bigTMD \
  --state /Collins-ep-analytic-state-v0.3.3 \
  --baseline-state /SIDIS-validation-state --dry-run
python3 "$COLLINS_VALIDATOR/install.py" --repo /bigTMD \
  --state /Collins-ep-analytic-state-v0.3.3 \
  --baseline-state /SIDIS-validation-state
```

Installation checks the existing baseline and records all original analytical and numerical files in an external preservation lock. It only adds scaffold paths. An incomplete or incompatible installation blocks; do not reinitialize or alter a baseline to bypass it.

Implement the new stages and adapter in the candidate tree, and configure the added `derivation_runtime.json` using real installed tool paths. Existing production files are frozen. A correction that requires changing an original file must be reported as an explicit blocker for a separately reviewed migration. Do not edit the validator, its inventory, its reference formulas, or tolerances to pass.

The workflow initially stops at the unimplemented stages. That is expected. A tool-path check is not a native execution check, and self-tests do not certify a user's Wolfram, Kira, SubTropica, or MadGraph installation. Harness self-tests must not download or replace a native runtime or invoke fitted-provider calculations.

## Execute and verify

Finish source changes and any comparison documents saved inside production before these runs. Run the command below twice, without `--resume`, and retain the two run directories printed by the workflow:

```bash
OPENBLAS_NUM_THREADS=1 OMP_NUM_THREADS=1 MKL_NUM_THREADS=1 \
python3 "$COLLINS_VALIDATOR/workflow.py" run --repo /bigTMD \
  --state /Collins-ep-analytic-state-v0.3.3 \
  --numerical-state /SIDIS-validation-state --through d15
```

Set `COLLINS_RUN_A` and `COLLINS_RUN_B` to those two absolute paths, then run:

```bash
export OPENBLAS_NUM_THREADS=1 OMP_NUM_THREADS=1 MKL_NUM_THREADS=1
python3 "$COLLINS_VALIDATOR/verify_derivation.py" --repo /bigTMD \
  --run "$COLLINS_RUN_A" --replay "$COLLINS_RUN_B" --seed 1729 \
  --numerical-state /SIDIS-validation-state \
  --report /Collins-ep-analytic-state-v0.3.3/derivation-1729.json
python3 "$COLLINS_VALIDATOR/verify_derivation.py" --repo /bigTMD \
  --run "$COLLINS_RUN_A" --replay "$COLLINS_RUN_B" --seed 92741 \
  --numerical-state /SIDIS-validation-state \
  --report /Collins-ep-analytic-state-v0.3.3/derivation-92741.json
python3 "$COLLINS_VALIDATOR/compare_derivation_reports.py" --repo /bigTMD \
  --report /Collins-ep-analytic-state-v0.3.3/derivation-pair.json \
  /Collins-ep-analytic-state-v0.3.3/derivation-1729.json \
  /Collins-ep-analytic-state-v0.3.3/derivation-92741.json
```

`--numerical-state` identifies protected historical evidence. It does not request a fitted-provider calculation. Keep all run artifacts and reports outside production while checks are running: production source hashes are part of the run identity. Verifier reports must also be outside the validator and sealed run directories; use new report paths for each attempt. Editing a source or its runtime configuration requires fresh runs. Resume only an unchanged run to recover an interruption; do not present resumed stages as an independent fresh replay.

## Interpreter consistency

Keep the existing Python interpreter consistent through workflow, verification and comparison. The supplied campaign used Python 3.10. Python 3.12 changed float summation, causing last-bit differences in a few regenerated kinematic/spin components during exact historical replay. This patch leaves the point generator and exact comparisons unchanged. Do not edit archived requests or relax the identity checks.

A separate retrospective pre-3.12 summation diagnostic independently reconstructs the original points and replays all 62 native checks per seed. It is confined to `review/review_received_v032.py`, outside official acceptance. Independent execution of the archived binaries at recorded kinematics also passes all 60 amplitude comparisons per seed with current arithmetic.

## Reading the outcome

`STAGES_PASS` records execution and replay of supplied proofs; it is not final analytical acceptance. The derivation verifier also checks the frozen contract, independent comparisons, upstream dependencies, reproducibility, and MadGraph evidence. Missing tools or an unsupported native interface remain blockers rather than skipped successes. Failed comparisons remain failures.

Even a complete automated pass requires source review: an executable provenance graph does not establish that an operator definition or physical approximation is justified. This release has reviewed the saved implementation and replayed archived arithmetic. It has re-executed archived native binaries but has not regenerated/compiled MadGraph, rerun Wolfram/Kira/SubTropica derivations, completed official acceptance, or validated Figure 6.

Preserve the earlier 70-row equation table, with separate derivation-origin and verification-status columns. Cross-reference it to the 31 obligations and mark uncovered rows explicitly. The new contract is not a claim that all 70 rows are independently automated. Produce new comparison documents under `/bigTMD/collins_ep_analytic/reports/` before the final two fresh runs. The final milestone report and authoritative machine evidence stay in the external state directory, with the verified source identity. Copying or updating reports inside production after verification changes that identity and requires fresh acceptance runs.
