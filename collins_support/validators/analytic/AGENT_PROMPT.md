# Collins ep reverse-unitarity continuation mission — v0.5.1

Continue and validate the partially implemented integration route under **/bigTMD/collins_ep_analytic_SIDIS**, using /bigTMD as the working repository. Preserve /bigTMD/collins_ep_analytic as the accepted comparison engine and preserve the original SIDIS checkout, validators, baselines and historical evidence. This mission requires analytical implementation and new code, not just execution.

The external validator is /Collins-ep-analytic-validation-v0.5.1. Its contract is frozen. Read README.md, INSTALL.md, contract.json, docs/INTERFACE.md, SIDIS_REUSE.md and docs/SCIENTIFIC_REVIEW.md there before coding. Use the existing Python/native environment that passed v0.4.0. Inspect `/Collins-ep-analytic-state-v0.5.1/adoption.json` for the actual accepted pair location and the previous-release preservation record.

## Starting point and repair boundary

The reviewed v0.5.0 attempt is incomplete. Keep its original review under `/bigTMD/collins_ep_analytic_SIDIS_review/reverse-unitarity-001/` and its state under `/Collins-ep-analytic-state-v0.5.0/` unchanged. Do not delete, relabel or replace either blocked full run. The v0.5.1 upgrader adopts the existing new engine; do not run the initial installer, overwrite `ru_runtime.json`, or discard the implemented source.

Read the previous MILESTONE_REPORT.md, SCIENTIFIC_REVIEW.md, LIMITATIONS.md and these focused reviews:

- `audit/native-pilot-001/NATIVE_INTERFACE_REVIEW.md` and its saved failed/diagnostic inputs.
- `audit/hf-route-review-001/HF_ROUTE_REVIEW.md`, especially fixed-(u,v,tau) geometry, raised measurement cuts and boundary terms.
- `audit/virtual-001/VIRTUAL_SOURCE_REVIEW.md`.
- `audit/amplitude-binding-001/comparison-001/BINDING_RESULT.json`.

Existing useful work: fresh Born/real generation, actual quark Kira cut reduction, a derived cut-volume Euler input, bare inclusive-moment assembly, ordinary virtual generating/reduction/assembly source, and formal first-order UU/UT algebra. The old native evaluator and pair-report defects are repaired here. The Kira probe now mutates the complete audited map, including implicit master identities, in disposable copies and checks that map natively. Do not implement a compensating identity rescaling in candidate code.

The old pilot integrated its longitudinal measurement over 0<z<1. It is an inclusive moment, not the full fixed-z TMD coefficient. The two-cut timelike volume is not the Collins/HF measured family. r07's explicit incomplete guard must remain until the missing physical expressions actually exist. Repairing the evaluator is not permission to fill 167 exports from the accepted answer table.

Before changing physics sources, inspect the new state's adoption record and run the software tests. Reuse a successful installed-release/runtime-matched `native_regression.py` setup receipt if the user already ran it; otherwise run it into a new output directory. Then execute a fresh candidate pilot with:

```bash
cd /bigTMD
export COLLINS_VALIDATOR=/Collins-ep-analytic-validation-v0.5.1
export COLLINS_STATE=/Collins-ep-analytic-state-v0.5.1
export COLLINS_PYTHON=/usr/bin/python3.10
export PYTHONDONTWRITEBYTECODE=1
export OPENBLAS_NUM_THREADS=1 OMP_NUM_THREADS=1 MKL_NUM_THREADS=1
"$COLLINS_PYTHON" "$COLLINS_VALIDATOR/workflow.py" run \
  --repo /bigTMD --state "$COLLINS_STATE" --through r03
```

`DEVELOPMENT_PASS` establishes that the repaired native boundary executes this pilot. Check its actual master, Kira contraction and bare endpoint coefficients against the saved independent beta/Gamma derivation. Do not stop the mission at this setup milestone: continue the missing measured-sector implementation.

## Goal and scope

Regenerate the declared Born/one-loop, leading-power Collins ep ingredients with the SIDIS-style integration machinery: FeynArts/FeynCalc for amplitudes and spin/color algebra; reverse-unitarity cut families for applicable real contributions; Kira for reductions; SubTropica for the corresponding Euler masters; explicit endpoint distributions, subtractions and formal UU/UT assembly. Ordinary virtual integrals use Kira and SubTropica. Do not use PaVe/Package-X evaluated integrals as the integration backend.

This is a method migration and comparison within the accepted narrow-cone and physical HF endpoint scope. It does not certify R=1, unrestricted nonsingular fixed-order NLO, generic HF contacts, closed full twist-three evolution or NNLO. Fitted PDFs/FFs remain symbolic; Figure 6 stays paused.

Reuse applicable source machinery rather than duplicating it. A fresh derivation means rerunning generating programs and their reductions/master evaluations from fresh inputs. Reusing a program is allowed; importing an earlier final coefficient and describing it as freshly derived is not.

## Explicit SIDIS source-reuse approval

Upstream repository: https://github.com/NonHermitianMatrix/SIDIS_dsigma_till_NLO
Pinned revision: **5062dcb2407594dafcc2f9f72800e96ff9e6d957**

These are the **20 individually approved SIDIS source files**:

- `SIDIS/common/s01_import_inputs.py`
- `SIDIS/common/s02_definitions.wl`
- `SIDIS/common/s03_real_families.wl`
- `SIDIS/common/s04_reduce_real.wl`
- `SIDIS/common/s05_virtual_families.wl`
- `SIDIS/common/s08_cut_master_inputs.wl`
- `SIDIS/common/s09_reduce_virtual.wl`
- `SIDIS/common/s10_evaluate_cut_masters.wl`
- `SIDIS/common/s11_real_master_coefficients.wl`
- `SIDIS/common/s12_virtual_master_inputs.wl`
- `SIDIS/common/s13_evaluate_virtual_masters.wl`
- `SIDIS/common/s14_uv_residues.wl`
- `SIDIS/common/s15_cut_soft_regions.wl`
- `SIDIS/common/s16_collinear_inputs.wl`
- `SIDIS/common/s17_assemble_real.wl`
- `SIDIS/common/s18_virtual_coefficients.wl`
- `SIDIS/common/s19_assemble_virtual.wl`
- `SIDIS/common/s20_final_hats.wl`
- `SIDIS/common/s21_organize_layout.py`
- `SIDIS/common/s22_paths.wl`

SIDIS_REUSE.md specifies what each file provides and every required adaptation; sidis_reuse.json contains its Git blob identity and default destination. This list approves source algorithms, not inherited unpolarized answers or every physical assumption in a driver. Preserve original attribution and exact upstream snapshots. Copy/adapt in the new engine; do not execute the historical six-channel migration on either existing tree.

Write provenance/SIDIS_REUSE_MANIFEST.json exactly as documented in docs/INTERFACE.md and workflow.check_reuse: commit plus a files object enumerating all 20 source paths. For a used file give used=true, adaptation and destinations mapping each adapted relative path to its SHA-256. For an unused file give used=false and a concrete reason. Put the exact used upstream bytes under provenance/sidis/<commit>/<upstream-path>. Identify actual functions reused and their consuming stages in additional descriptive records.

New Collins-specific helpers and routine edits in the new engine are authorized. Read-only inspection of other SIDIS files is allowed. Record any proposed additional reuse by exact path/revision/purpose; do not silently import the rest of the repository. Existing tool installations are runtime dependencies and are not to be rebuilt or replaced by this mission.

The historical uncut-parent programs s06_cut_parent_inputs.wl and s07_evaluate_cut_parents.wl, prior result tables, Kira caches and final F-hats are not fresh integration inputs. Adapt s01/s16 historical-input loaders, s14's inherited UV-map shortcut, channel-specific projectors/couplings, and s21/s22 path/identity logic as described in SIDIS_REUSE.md.

You may adapt the accepted Collins generating/operator source needed for this process, with exact source/destination hashes in a separate provenance/COLLINS_SOURCE_REUSE.json. Enumerate those files before using them; preserve the original sources. Do not import the old coefficient exports into the production calculation. Declare shared amplitudes/projectors so the second route's independence is described accurately.

## Implementation sequence

1. Establish the new engine's conventions and dependency map. Keep applicable SIDIS conventions fixed: D-dimensional algebra, measures, spin/color averages, coupling normalization, cut signs, positive-energy support, MS-bar factors and endpoint intervals. Define additional transverse-spin, Collins-moment, z/Fourier and rapidity conventions explicitly. Write CONVENTIONS.md with source definitions and exact conversions into the accepted comparison basis. Do not invent a SIDIS convention for a quantity absent from that implementation.

2. Retain and rerun the existing r00 and real-integration pilot through r03 first; correct any producing-source defects revealed by the repaired native execution. Use a nonzero physical quark example that exercises the required cut mapping, actual Kira rules, an actual SubTropica Euler evaluation and distribution/finite assembly. Exercise the native tool boundary early. Preserve exact failed inputs if a native representation is unsupported. Do not conceal an unsupported integral by loading the old answer or relabelling the old radial route as reverse unitarity.

3. Extend the real route to every declared beam, fragmentation/HF, soft and jet/overlap sector. Keep the fixed longitudinal fractions and independent transverse measurements until the appropriate distribution/Fourier operations. Extend r01/r02 beyond the hard-coded timelike-volume family. For HF, regenerate the operator normalization, gauge-completed QCD/Wilson current, both cut placements, color branches and BMHV projection from defining source; retain the independent u,v fractions and common prescriptions. The emitted gluon is a physical cut; coherent operator legs and measurement deltas are not extra positive-energy final particles. Use the previous HF review's geometry as a proposal to verify, not a completed integral. Raised measurement cuts require the derivative-distribution map; off-cut changes of variables cannot silently drop their terms. Reapply the inherited physical endpoint class and its uniform bound to newly generated expressions. Generic contacts remain qualified. For recoil/jet sectors, implement the actual Fourier/rapidity/cone measurements and boundary-safe reductions, with bare/common/overlap allocations before asserting a zero finite remainder. Derive measurement deltas, theta boundaries, operator/gauge completion and endpoints. Identify operations that legitimately remain analytic outside the cut-integral reduction, including Fourier/rapidity manipulations, and connect them to the cut result. Do not assume ordinary IBP can discard measurement boundary terms.

4. Retain and rerun r04-r06 using the repaired official ordinary virtual Kira/SubTropica route and explicit UV/IR separation; their previous corrected-copy diagnostics are comparison evidence, not new official acceptance. Reuse the already applicable machinery. If a branch vanishes, supply its actual derivation rather than a manufactured nonzero integral.

5. Implement r07 formal first-order UU/UT assembly and explicit convention conversion. Build the exact certificates from the same native expressions actually used in the operator formula. Preserve all delta/plus/regular and HF endpoint entries. Provide bare/overlap evidence when a finite remainder vanishes. The generic contact action remains qualified outside the proved physical class.

The precise scripts, job schemas and native packet format are in docs/INTERFACE.md. The validator owns tool execution: candidate stages generate Kira jobs and unevaluated Euler inputs; they do not write successful tool receipts or replace the protected native evaluators. Outputs come from the requested fresh run directories, never fixed old paths.

Development runs may use workflow.py run --through r03 (or another listed stage); DEVELOPMENT_PASS is not milestone acceptance. Fix routine candidate/interface implementation mistakes autonomously. If the frozen validator itself is demonstrably defective, preserve a minimal reproducer and unapplied patch, keep the official result BLOCKED/FAIL, and continue independent useful work. Do not modify the validator or lower its requirements.

## Independent comparison and review

The 167 entries in reference_values.json are exact scalar comparisons to the accepted engine, not 167 independent literature equations. Keep those references out of producing code. Regenerate the new expressions before comparing them. The old validator's numerical/MadGraph evidence is replayed separately.

For new or modified amplitudes/projectors, provide a direct check bound to their new outputs. Retained MadGraph checks alone do not certify those modifications. Reuse the existing native amplitude-check machinery where applicable, and retain complex helicity interference for transverse spin. If this binding is not completed, report it explicitly and do not claim new native MadGraph acceptance.

Use literature_inventory.json to retain the 85 historical analytical equation groups and their unresolved rows. It currently records 14 EXACT, 35 EXACT AFTER EXPLICIT CONVERSION, 4 MISMATCH and 32 UNVERIFIED; these are historical statuses, not targets for a desired pass count. Preserve the electromagnetic-prefactor, printed Sudakov and literal CA-kernel discrepancies unless a new derivation establishes a correction.

References to use, with the specified observable conventions and approximation:

- 2007.07281v1 — ep Collins observable and Appendix A: https://arxiv.org/abs/2007.07281v1
- 1707.00913 — polarized pp hadron-in-jet comparison, with its process-dependent ingredients distinguished: https://arxiv.org/abs/1707.00913
- 1505.05589 — KPSY matching, TMD/Collins definitions and evolution: https://arxiv.org/abs/1505.05589
- 1303.2129 and 1512.07233 — the retained scheme/evolution references: https://arxiv.org/abs/1303.2129 and https://arxiv.org/abs/1512.07233
- 0903.4680 and 1012.3419 — Collins tail/operator mixing and the literal off-diagonal discrepancy: https://arxiv.org/abs/0903.4680 and https://arxiv.org/abs/1012.3419
- 1705.08443 — jet/TMD matching, with the ep measurement conversion derived: https://arxiv.org/abs/1705.08443
- The pinned SIDIS notes and source programs; reverse-unitarity method reference: https://arxiv.org/abs/hep-ph/0207004

Consult the retained references.json files for the already pinned source identities and equation locations. Preserve reference equations as printed. Show an explicit algebraic conversion instead of changing the reference text.

Perform the source review in docs/SCIENTIFIC_REVIEW.md. Trace at least one nonzero UU chain and one Collins/HF chain from the native input through cuts, reduction, masters, subtractions and assembly. Review all additional sectors for support, normalization and scope. Do not treat checks of filenames/roles as proof that the physical derivation is correct.

## Freeze and final acceptance

Complete implementation-source edits first. Keep final human reports outside the frozen engine, under **/bigTMD/collins_ep_analytic_SIDIS_review/reverse-unitarity-002/**. The validator's native state and official reports stay under /Collins-ep-analytic-state-v0.5.1.

Use these actual entry points:

```bash
export COLLINS_VALIDATOR=/Collins-ep-analytic-validation-v0.5.1
export COLLINS_STATE=/Collins-ep-analytic-state-v0.5.1
export COLLINS_PYTHON=/usr/bin/python3.10
export COLLINS_ACCEPTED_PAIR=/Collins-ep-analytic-state-v0.4.0/literature-revalidation-001/nlo-pair.json
export PYTHONDONTWRITEBYTECODE=1
export OPENBLAS_NUM_THREADS=1 OMP_NUM_THREADS=1 MKL_NUM_THREADS=1

cd /bigTMD
"$COLLINS_PYTHON" "$COLLINS_VALIDATOR/selftest.py"
"$COLLINS_PYTHON" "$COLLINS_VALIDATOR/workflow.py" doctor --repo /bigTMD
"$COLLINS_PYTHON" "$COLLINS_VALIDATOR/workflow.py" run --repo /bigTMD --state "$COLLINS_STATE"
"$COLLINS_PYTHON" "$COLLINS_VALIDATOR/workflow.py" run --repo /bigTMD --state "$COLLINS_STATE"
```

Record the two actual printed run paths as RU_RUN_A and RU_RUN_B. Use the actual accepted pair path from adoption if it differs from the example; do not alter reports to fit it.

```bash
"$COLLINS_PYTHON" "$COLLINS_VALIDATOR/verify_ru.py" --repo /bigTMD \
  --run "$RU_RUN_A" --replay "$RU_RUN_B" --seed 1729 \
  --accepted-pair "$COLLINS_ACCEPTED_PAIR" --report "$COLLINS_STATE/ru-1729.json"
"$COLLINS_PYTHON" "$COLLINS_VALIDATOR/verify_ru.py" --repo /bigTMD \
  --run "$RU_RUN_A" --replay "$RU_RUN_B" --seed 92741 \
  --accepted-pair "$COLLINS_ACCEPTED_PAIR" --report "$COLLINS_STATE/ru-92741.json"
"$COLLINS_PYTHON" "$COLLINS_VALIDATOR/compare_ru_reports.py" --repo /bigTMD \
  --report "$COLLINS_STATE/ru-pair.json" \
  "$COLLINS_STATE/ru-1729.json" "$COLLINS_STATE/ru-92741.json"
```

The verifier changes the complete audited Kira reduction map (raw rules plus any implicit master identities) and evaluated masters in disposable copies, then reruns downstream stages. Native map-response certificates and downstream fixed-recipe checks are both required. These diagnostic inputs are intentionally not physical complete runs; retain the resulting uncancelled poles when validation_probe=true rather than changing the recipe or pretending the probe is a physical prediction. They must never replace either fresh acceptance run.

Fix candidate code and update reuse/source ledgers before freezing. After an implementation change, use new run/report paths and repeat affected final acceptance; do not overwrite an earlier report. Preserve every official failure alongside the eventual passing evidence.

## Deliverables

Under the separate review directory, provide:

- MILESTONE_REPORT.md with exact acceptance results, remaining blockers and scope.
- REUSE_AND_WORKFLOW.md listing reused functions, adapted files and new pieces; use SIDIS-style common programs with explicit UU/Collins sector views, avoiding copies of shared jobs.
- EQUATION_COMPARISON_ANALYTICAL_RU.tex, .pdf and .md: new expression, old-engine expression, exact reference equation, explicit convention conversion, derivation provenance, verification status and equation citation. Keep numerical checks out of this analytical PDF.
- EQUATION_COMPARISON_NUMERICAL_RU.tex, .pdf and .md: supporting amplitude/master/distribution checks, retained evidence, dependency probes and tolerances.
- SCIENTIFIC_REVIEW.md and a limitations register, including R=1, endpoint class, literal paper discrepancies and any uncompleted new-amplitude comparison.
- A review archive, SHA-256 sidecar, file/symlink manifest and reproduction commands containing new sources, exact reused snapshots, native job inputs/results, logs, reductions, raw master evidence and official reports. Preserve symlinks. Reference the unchanged old bundle explicitly if it remains an external dependency; do not claim a self-contained archive when required evidence is external.

Compile and visually inspect both PDFs. Verify the archive manifest and distinguish software PASS, native execution, automated CHECKS_PASS and qualified scientific conclusions. Do not claim the new integration route resolves every historical unverified expression or certifies Figure 6.


## Continuation acceptance boundary

Preserve the 85 historical equation groups and their statuses. The previous fresh-route comparison had only six available groups against the old engine and five converted literature comparisons; do not relabel historical results as new-route derivations. Retain an explicit sector-completion table showing what was generated, cut, reduced, evaluated, subtracted and assembled. A complete-looking file layout or `READY_TO_EXECUTE` does not complete those rows.

The previous new-r00/retained-MadGraph comparison may support identical native outputs if its exact source/output/evidence bindings remain valid. Any changed amplitude/projector needs renewed direct binding; numerical complex-helicity checks stay in the supporting numerical PDF. Neither old PASS totals nor a successful repaired master certify the missing epsilon/HF/TMD pieces.

Keep working on all authorized candidate changes. If a frozen interface or native-tool limitation truly prevents a required family, preserve its minimal native input, raw output and exact blocker; continue other independent sectors. Do not replace reverse-unitarity integration by an old evaluated radial result or declare the total mission complete after the pilot.
