# v0.3.2 acceptance review and v0.3.3 installation

The native amplitude agreement is supported by independent re-execution. The reported official blocker is a validator serialization defect; the one-line repair changes no physical value or expression. Official acceptance still requires fresh runs under the corrected immutable release.

## Verified evidence

Received archive: `collins_ep_analytic_v0_3_2_acceptance_bundle.tar.gz`.

```text
SHA-256: b951b06dbeeb1c8ee4bc5636276686c0cf6c629bd1b47339e66042384b99e260
```

All 9,903 manifest entries verify: 8,514 regular files, 216 symlinks and 1,173 directories, in addition to the manifest/root wrappers. All 1,399 frozen candidate files match their hashes. Both official evidence manifests match after extraction, including generated link identities. Original production, validators and uploaded evidence were unchanged by review.

| Evidence | Result |
|---|---|
| Official v0.3.2 reports | Each seed: 1,277 PASS, three native-process BLOCKED, no FAIL |
| Official pair | FAIL because the seed reports are incomplete |
| Actual MG5 reader | `character*20` truncates the 23-character `.17e` token before its numeric read |
| Proposed diagnostic | Full module differs from immutable v0.3.2 by exactly `.17e` → `.17g` in parameter-card output |
| Value preservation | All five selected entries fit and round-trip to identical binary values; unrelated card lines are unchanged |
| Independent execution here | Copies of all six compiled official drivers fail with original cards and succeed after only the formatting change |
| Amplitude comparisons | 60 PASS per seed: native/Clifford and candidate/native, with coherent-spin controls exercised by the parser |
| Largest candidate residual | 1.6653345369377348e-16 for seed 1729; 1.942890293094024e-16 for seed 92741 |
| Retrospective complete native replay | 62 PASS per seed when reproducing the original Python summation order, as explained below |

The 388 focused derivation checks and 870 retained-assembly checks are included in each official total; do not add them again. The native 62-row diagnostic contains 60 amplitude comparisons plus phase-space and freshness records, not 62 new analytical derivations.

These checks cover photon-mediated `eq -> eq`, `eq -> eqg` and `eg -> eq qbar`, with coherent double transverse quark-spin transfer in the quark channels. They do not independently establish integrated one-loop matching, the full physical observable or full fixed-order NLO.

The local execution used supplied compiled binaries at their recorded kinematics. No MadGraph generation, Fortran compilation, fresh candidate extraction or Wolfram/Kira/SubTropica derivation was performed here. The archive supplies evidence of those original-machine steps. Retrospective results are not substituted for official acceptance reports.

## Patch and regression scope

The native code change is:

```python
# previous
line = f"  {key}  {value:.17e} # verifier benchmark"
# repaired
line = f"  {key}  {value:.17g} # verifier benchmark"
```

The fixed entries are inverse electromagnetic coupling, alpha_s and three zero external masses. Their binary values, amplitudes, normalizations, spin conventions, phase-space generator, coefficient oracles, proof inventory and tolerances are unchanged. The earlier ZERO declaration and generated-link guards are retained.

The release also updates output-state defaults and accepts the exact v0.3.2 installation issuer without resetting any protection. New tests use genuine `lha_read.f` and default-card bytes to check the original failure, all five exact encodings, idempotence and unrequested-line preservation. Another test checks the unchanged original lock.

## Python-version qualification

The delivered campaign used Python 3.10. Ordinary exact replay here under Python 3.12 fails at seeded-request equality: its different float-sum algorithm changes a few kinematic/spin components in the last bits. This is separate from the native card defect and amplitude agreement.

A retrospective explicit pre-3.12 left-to-right sum diagnostic independently regenerates the original seeded requests exactly for both seeds, without using stored points as answers. All 62 native checks then replay. The adapter exists only in the supplemental review script; it does not modify release code, identity checks or tolerances. Direct execution at recorded kinematics also passes all 60 amplitude comparisons per seed with current arithmetic.

Keep the existing Python interpreter consistent throughout the new workflow, verification and comparison. Do not rewrite archived requests, loosen exact comparisons or apply the retrospective adapter to official runs. No cross-version portability change is included in this patch.

## Analytical interpretation

The supplied source review now gives a scoped bare cut-diagram measurement/path argument for the common virtual TMD/collinear contribution, beyond the tautological subtraction of two identical expressions. It retains a common finite Wilson endpoint before composition and identifies regulator/boundary assumptions. Its 47 additional exact identities support the reasoning; they are not 47 newly derived reference equations.

The review distinguishes the physical-J0 construction from an uncomputed independently regulated finite-eta full-D endpoint, and the Collins EOM/gauge-completion calculation from full off-diagonal twist-three mixing. The retarded boundary and homogeneous projection remain explicit inputs. General all-b factorization and its small-b OPE retain separate domains. No production correction was indicated by the inspected review or native comparisons.

The 70-row comparison remains 7 EXACT, 33 converted-exact, 9 numerical, four MISMATCH and 17 UNVERIFIED. Keep the literal reference qualifications and unresolved identifications visible. SIDIS conventions remain pinned at commit `5062dcb2407594dafcc2f9f72800e96ff9e6d957`, with explicit extensions for TMD/Collins definitions absent from that repository.

## Install on the existing project

Place the ZIP and checksum sidecar in `/tmp`:

```bash
cd /tmp
sha256sum -c collins_ep_analytic_validation_v0_3_3.zip.sha256
```

After it prints `OK`, run:

```bash
unzip -n /tmp/collins_ep_analytic_validation_v0_3_3.zip -d /
export COLLINS_VALIDATOR=/Collins-ep-analytic-validation-v0.3.3
export OPENBLAS_NUM_THREADS=1 OMP_NUM_THREADS=1 MKL_NUM_THREADS=1
export PYTHONDONTWRITEBYTECODE=1
python3 "$COLLINS_VALIDATOR/selftest.py"
python3 "$COLLINS_VALIDATOR/workflow.py" doctor --repo /bigTMD
```

Expect 421 passing self-tests, no failures/errors/skips, and `PATHS_FOUND` from doctor on the configured machine. These are setup checks; official acceptance follows.

**Do not rerun `install.py` over the saved implementation.** Keep older validators, the original `/Collins-ep-analytic-state-v0.3.0/installation.json`, baselines and current runtime configuration. Selecting v0.3.3 requires no lock/runtime rewrite.

Launch `AGENT_PROMPT.md`, also supplied as `COLLINS_EP_ACCEPTANCE_v0_3_3.md`. It executes two fresh nonresumed d15 workflows, both official seeds and the pair comparator, under `/Collins-ep-analytic-state-v0.3.3`. The validator identity changed, so old run manifests cannot be relabeled; reuse the source programs and regenerate the evidence. No new analytical stage is planned.

## Reproduce the supplemental review

The release contains `review/received_v032_review.json` and the executable review script. Given the extracted original archive:

```bash
python3 "$COLLINS_VALIDATOR/review/review_received_v032.py" \
  --bundle /absolute/path/to/collins_ep_analytic_v0_3_2_acceptance_bundle \
  --output /absolute/path/to/new/review-output
```

Add `--execute-archived-binaries` to run working copies of the supplied Linux executables with original/repaired cards. This requires a compatible Fortran runtime and performs no compilation. Use a new output directory. Neither mode edits original evidence or creates official acceptance reports.

Full polarized fixed-order NLO is the next implementation milestone; organization and reverse unitarity follow later. Fitting and Figure 6 remain paused.
