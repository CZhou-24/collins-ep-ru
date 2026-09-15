# Project-local Collins validation relocation

**Complete.** The existing analytical validator and its retained v0.4.0/v0.3.3 checker chain now operate from `collins_support`. The official organization pair replay returned `CHECKS_PASS`; one fresh native RU workflow completed through `r07`; all **167 scalar outputs** matched the unchanged accepted references with **zero exact residuals**.

**Scientific qualifications are unchanged.** This is path/configuration migration and execution/replay verification, not new independent physics acceptance. Source review remains required; the integration route shares source components; radius R=1, generic HF endpoint contacts and newly modified amplitudes are not automatically certified; unrestricted fixed-order NLO remains outside scope. Figure 6 is paused and fitted providers remain unnecessary. No analytical formula, coefficient/reference value, convention, tolerance or qualification was changed.

No data deletion, reinstallation, new validator version, duplicate validator tree, distribution archive, abandoned adapter invocation or historical packaging/preservation campaign was performed. The seven original project directories remain in place.

## Layout and resolution

| Historical prefix | Current project-relative location |
|---|---|
| `/Collins-ep-analytic-state-v0.3.0` | `collins_support/states/Collins-ep-analytic-state-v0.3.0` |
| `/Collins-ep-analytic-state-v0.3.3` | `collins_support/states/Collins-ep-analytic-state-v0.3.3` |
| `/Collins-ep-analytic-state-v0.4.0` | `collins_support/states/Collins-ep-analytic-state-v0.4.0` |
| `/Collins-ep-analytic-state-v0.5.1` | `collins_support/states/Collins-ep-analytic-state-v0.5.1` |
| `/Collins-ep-analytic-state-v0.5.1-organization-001` | `collins_support/states/Collins-ep-analytic-state-v0.5.1-organization-001` |
| `/Collins-ep-analytic-validation-v0.5.1` | `collins_support/validators/analytic` |
| `/Collins-ep-figure6-state` | `collins_support/phenomenology/Collins-ep-figure6-state` |
| `/Collins-ep-physical-review-state` | `collins_support/phenomenology/Collins-ep-physical-review-state` |
| `/SIDIS-analytic-state` | `collins_support/baselines/SIDIS-analytic-state` |
| `/SIDIS-validation-state` | `collins_support/baselines/SIDIS-validation-state` |
| `/SIDIS-validation-v0.3.0` | `collins_support/validators/numerical` (optional; absent) |

The one shared resolver is [collins_support/paths.py](/bigTMD/collins_support/paths.py), with the explicit map in [collins_support/relocation-map.json](/bigTMD/collins_support/relocation-map.json). Complete path prefixes match with suffix preservation. Unknown absolute prefixes, parent escapes, escaping links and ambiguous destinations fail. Required missing paths fail instead of triggering reinstallation. New configurations are project-relative. Historical JSON, recorded path identities, hashes, native outputs and logs are read unchanged; only explicitly declared access/path fields are resolved. Existing external native installations remain in place.

MadGraph stays in the v0.3.0 state’s `native-runtime/MG5_aMC_v3_7_0`; it was not moved again. Both phenomenology directories are present. The optional numerical validator is absent and was not restored; analytical acceptance did not invoke a fitted numerical campaign.

Current outputs use `collins_support/states/runs/` and `collins_support/reports/`. The one bounded fresh execution for this migration used the explicitly requested `states/relocation-check/` subtree. No old root compatibility paths or mount namespaces were created.

## Origin and identity bookkeeping

Before the first edit, [collins_support/relocation-origin.json](/bigTMD/collins_support/relocation-origin.json) captured 1,765 existing file identities and the exact text/hash of all three existing release manifests. Origin SHA-256: `9f12ec4f1ef0206403882315f1002430b4703d43635031e5450ba51d17e7f0cf`. No package source trees were copied.

[collins_support/relocation-changes.json](/bigTMD/collins_support/relocation-changes.json) records every authorized non-manifest edit with its before/after SHA-256, size, mode and path-related reason. Current source checks admit only those exact transitions; unchanged mathematical files and coefficient data remain subject to their original checks. Historical report/run identities stay historical and are not replaced with current hashes. Existing manifests were updated inside out while retaining their version, scientific metadata and member sets. Full manifest transitions: [collins_support/reports/relocation-release-identities.json](/bigTMD/collins_support/reports/relocation-release-identities.json).

| Existing manifest | Original SHA-256 | Current SHA-256 |
|---|---|---|
| [collins_support/validators/analytic/MANIFEST.json](/bigTMD/collins_support/validators/analytic/MANIFEST.json) | `7bd929a50ea81b8af7d58c91063205d5047cc1bf60b7aa6c449d7661d2f79f0f` | `caafd1ee5c477f0b159797979f625b75b18299007a87eeac1f6c2a99042a00ff` |
| [collins_support/validators/analytic/retained/v0.4.0/MANIFEST.json](/bigTMD/collins_support/validators/analytic/retained/v0.4.0/MANIFEST.json) | `221a7a7eb52b3cb441759c30819bce0eb7b8841bd25013027f81da7d512df17a` | `2d64a893028115a266d7d29a43fdb61a73a5c75b19319cb616245fa4edaa715f` |
| [collins_support/validators/analytic/retained/v0.4.0/retained/v0.3.3/MANIFEST.json](/bigTMD/collins_support/validators/analytic/retained/v0.4.0/retained/v0.3.3/MANIFEST.json) | `2813ac93295e31355485995b5df49575120fbd2ca6203596a15dc96b31f65ffb` | `94424d255e5b7c886b1c6c998f41ba2274aeed64d059d93063d045d7e248facd` |

## Changed files and reasons

There are **41 existing path/configuration/documentation file edits**, plus the three existing manifests above. Exact identities are in the linked change record. No `.wl`, `.wls` or `.m` generating source was edited.

| Existing file | Reason |
|---|---|
| [collins_ep_analytic/README.md](/bigTMD/collins_ep_analytic/README.md) | Update current project-local commands and guide links; label completed install/upgrade/report campaigns historical. |
| [collins_ep_analytic/assembly_runtime.json](/bigTMD/collins_ep_analytic/assembly_runtime.json) | Express the moved legacy analytical-state input as a project-relative configuration path. |
| [collins_ep_analytic/derivation_runtime.json](/bigTMD/collins_ep_analytic/derivation_runtime.json) | Express the moved installation lock and MadGraph root as project-relative configuration paths. |
| [collins_ep_analytic/numerics/physical_inputs.py](/bigTMD/collins_ep_analytic/numerics/physical_inputs.py) | Resolve moved provider manifest, library and input paths at access boundaries while retaining recorded manifest values. |
| [collins_ep_analytic/run.py](/bigTMD/collins_ep_analytic/run.py) | Point the comparison-engine wrapper to the existing bundled retained validator using the shared resolver. |
| [collins_ep_analytic_SIDIS/README.md](/bigTMD/collins_ep_analytic_SIDIS/README.md) | Update current project-local commands and guide links; label completed install/upgrade/report campaigns historical. |
| [collins_ep_analytic_SIDIS/comparison/README.md](/bigTMD/collins_ep_analytic_SIDIS/comparison/README.md) | Update current project-local commands and guide links; label completed install/upgrade/report campaigns historical. |
| [collins_ep_analytic_SIDIS/reports/README.md](/bigTMD/collins_ep_analytic_SIDIS/reports/README.md) | Update current project-local commands and guide links; label completed install/upgrade/report campaigns historical. |
| [collins_ep_analytic_SIDIS/tools/reproduce_organization.py](/bigTMD/collins_ep_analytic_SIDIS/tools/reproduce_organization.py) | Use the stable validator/accepted paths, exact path-edit identity records and separate local state/report outputs; historical cleanup is not a live archive gate. |
| [collins_support/validators/analytic/INSTALL.md](/bigTMD/collins_support/validators/analytic/INSTALL.md) | Update current project-local commands and guide links; label completed install/upgrade/report campaigns historical. |
| [collins_support/validators/analytic/README.md](/bigTMD/collins_support/validators/analytic/README.md) | Update current project-local commands and guide links; label completed install/upgrade/report campaigns historical. |
| [collins_support/validators/analytic/compare_ru_reports.py](/bigTMD/collins_support/validators/analytic/compare_ru_reports.py) | Replay moved seed reports using original release identities and unchanged report content; write current pair output locally. |
| [collins_support/validators/analytic/install.py](/bigTMD/collins_support/validators/analytic/install.py) | Label completed installation as historical and remove filesystem-root state defaults/writes. |
| [collins_support/validators/analytic/native_regression.py](/bigTMD/collins_support/validators/analytic/native_regression.py) | Use only designated project-local state output for optional native regression checks. |
| [collins_support/validators/analytic/native_smoke.py](/bigTMD/collins_support/validators/analytic/native_smoke.py) | Use only designated project-local state output for optional native smoke checks. |
| [collins_support/validators/analytic/retained/v0.4.0/INSTALL.md](/bigTMD/collins_support/validators/analytic/retained/v0.4.0/INSTALL.md) | Update current project-local commands and guide links; label completed install/upgrade/report campaigns historical. |
| [collins_support/validators/analytic/retained/v0.4.0/README.md](/bigTMD/collins_support/validators/analytic/retained/v0.4.0/README.md) | Update current project-local commands and guide links; label completed install/upgrade/report campaigns historical. |
| [collins_support/validators/analytic/retained/v0.4.0/compare_nlo_reports.py](/bigTMD/collins_support/validators/analytic/retained/v0.4.0/compare_nlo_reports.py) | Resolve retained report paths and original manifest identities without rewriting saved reports. |
| [collins_support/validators/analytic/retained/v0.4.0/install.py](/bigTMD/collins_support/validators/analytic/retained/v0.4.0/install.py) | Label completed installation as historical and remove filesystem-root state defaults/writes. |
| [collins_support/validators/analytic/retained/v0.4.0/native_smoke.py](/bigTMD/collins_support/validators/analytic/retained/v0.4.0/native_smoke.py) | Use only designated project-local state output for optional native smoke checks. |
| [collins_support/validators/analytic/retained/v0.4.0/nlo_support.py](/bigTMD/collins_support/validators/analytic/retained/v0.4.0/nlo_support.py) | Resolve moved filesystem inputs, record-scoped source/release transitions and local report/state output guards. |
| [collins_support/validators/analytic/retained/v0.4.0/retained/v0.3.3/README.md](/bigTMD/collins_support/validators/analytic/retained/v0.4.0/retained/v0.3.3/README.md) | Update current project-local commands and guide links; label completed install/upgrade/report campaigns historical. |
| [collins_support/validators/analytic/retained/v0.4.0/retained/v0.3.3/check_baseline.py](/bigTMD/collins_support/validators/analytic/retained/v0.4.0/retained/v0.3.3/check_baseline.py) | Resolve the moved existing baseline; no initialization or baseline reset. |
| [collins_support/validators/analytic/retained/v0.4.0/retained/v0.3.3/compare_assembly_reports.py](/bigTMD/collins_support/validators/analytic/retained/v0.4.0/retained/v0.3.3/compare_assembly_reports.py) | Resolve historical evidence and bound release identity; compare explicit path fields and protect local outputs. |
| [collins_support/validators/analytic/retained/v0.4.0/retained/v0.3.3/compare_derivation_reports.py](/bigTMD/collins_support/validators/analytic/retained/v0.4.0/retained/v0.3.3/compare_derivation_reports.py) | Resolve historical evidence and compare only declared run_paths/detail fields across relocation. |
| [collins_support/validators/analytic/retained/v0.4.0/retained/v0.3.3/derivation_support.py](/bigTMD/collins_support/validators/analytic/retained/v0.4.0/retained/v0.3.3/derivation_support.py) | Resolve the installation lock and MadGraph paths for access/native contexts; preserve installation and native identities. |
| [collins_support/validators/analytic/retained/v0.4.0/retained/v0.3.3/extension_inputs.py](/bigTMD/collins_support/validators/analytic/retained/v0.4.0/retained/v0.3.3/extension_inputs.py) | Resolve the moved analytical history and admit only recorded configuration/wrapper hash changes in the original foundation lock. |
| [collins_support/validators/analytic/retained/v0.4.0/retained/v0.3.3/install.py](/bigTMD/collins_support/validators/analytic/retained/v0.4.0/retained/v0.3.3/install.py) | Label completed installation as historical and remove filesystem-root state defaults/writes. |
| [collins_support/validators/analytic/retained/v0.4.0/retained/v0.3.3/madgraph_checks.py](/bigTMD/collins_support/validators/analytic/retained/v0.4.0/retained/v0.3.3/madgraph_checks.py) | Resolve the existing moved MadGraph installation at its filesystem access boundary; arithmetic/evidence logic unchanged. |
| [collins_support/validators/analytic/retained/v0.4.0/retained/v0.3.3/support.py](/bigTMD/collins_support/validators/analytic/retained/v0.4.0/retained/v0.3.3/support.py) | Resolve baseline/history/native access and enforce exact recorded source/release transitions while keeping all baseline and evidence checks. |
| [collins_support/validators/analytic/retained/v0.4.0/retained/v0.3.3/tests/test_patch_compatibility.py](/bigTMD/collins_support/validators/analytic/retained/v0.4.0/retained/v0.3.3/tests/test_patch_compatibility.py) | Update only the expected relocated installation-state default. |
| [collins_support/validators/analytic/retained/v0.4.0/retained/v0.3.3/verify.py](/bigTMD/collins_support/validators/analytic/retained/v0.4.0/retained/v0.3.3/verify.py) | Resolve moved foundation/numerical input paths and execution-only native context fields. |
| [collins_support/validators/analytic/retained/v0.4.0/retained/v0.3.3/verify_assembly.py](/bigTMD/collins_support/validators/analytic/retained/v0.4.0/retained/v0.3.3/verify_assembly.py) | Resolve saved run inputs and native context paths; local report guard and optional numerical default. |
| [collins_support/validators/analytic/retained/v0.4.0/retained/v0.3.3/verify_derivation.py](/bigTMD/collins_support/validators/analytic/retained/v0.4.0/retained/v0.3.3/verify_derivation.py) | Resolve saved run inputs and execution-only runtime; local report guard and baseline default. |
| [collins_support/validators/analytic/retained/v0.4.0/retained/v0.3.3/workflow.py](/bigTMD/collins_support/validators/analytic/retained/v0.4.0/retained/v0.3.3/workflow.py) | Resolve saved run paths and explicit native contexts, preserve original source/runtime/release meaning, and constrain new states to project support. |
| [collins_support/validators/analytic/retained/v0.4.0/verify_nlo.py](/bigTMD/collins_support/validators/analytic/retained/v0.4.0/verify_nlo.py) | Resolve saved run inputs and compare declared context input paths explicitly; scientific rows remain unchanged. |
| [collins_support/validators/analytic/retained/v0.4.0/workflow.py](/bigTMD/collins_support/validators/analytic/retained/v0.4.0/workflow.py) | Resolve saved run paths and explicit native contexts, preserve original source/runtime/release meaning, and constrain new states to project support. |
| [collins_support/validators/analytic/ru_support.py](/bigTMD/collins_support/validators/analytic/ru_support.py) | Resolve moved filesystem inputs, preserve old accepted identities, admit only recorded source/release edits, and guard local report outputs. |
| [collins_support/validators/analytic/upgrade.py](/bigTMD/collins_support/validators/analytic/upgrade.py) | Retire the completed adoption command so missing standalone releases are not restored and root directories cannot be recreated. |
| [collins_support/validators/analytic/verify_ru.py](/bigTMD/collins_support/validators/analytic/verify_ru.py) | Resolve replay inputs and compare only declared mutation-certificate path identities; keep saved evidence hashes and scientific comparisons exact. |
| [collins_support/validators/analytic/workflow.py](/bigTMD/collins_support/validators/analytic/workflow.py) | Resolve saved run paths and explicit native contexts, preserve original source/runtime/release meaning, and constrain new states to project support. |

New files are limited to the shared resolver/map, compact origin/change records, the support guide, focused fixture/scalar-report scripts and this mission’s reports/logs. Current engine/support guides link to this report. Original freezes, output/equation indexes, lock files, numerical baselines, accepted reports and native evidence remain unchanged. The original root README hash is unchanged.

## Verification and exact output locations

| Check | Outcome / evidence |
|---|---|
| Focused access and integrity fixtures | **9/9 PASS**: [collins_support/reports/relocation-focused-tests-001.json](/bigTMD/collins_support/reports/relocation-focused-tests-001.json). Moved record, unmapped prefix, parent escape, ambiguous destination, symlink escape, valid/changed source fixtures, intact release inventory and changed coefficient data. Accepted files were not mutated. |
| Static active-path review | **PASS**, 168 Python/Wolfram files and zero unresolved root literals: [collins_support/reports/relocation-static-paths.json](/bigTMD/collins_support/reports/relocation-static-paths.json). Includes imported helpers and paths loaded from reports/contexts, not only CLI defaults. |
| Runtime/installation discovery | **PASS**: [collins_support/reports/relocation-runtime-discovery-001.json](/bigTMD/collins_support/reports/relocation-runtime-discovery-001.json). Preserved 32 foundation, 57 numerical and 1,337 installation-source entries; all 462 MadGraph identities; original runtime identities match after explicit configuration-path conversions. |
| Official saved organization pair | **CHECKS_PASS**: [collins_support/reports/relocation-pair-001.json](/bigTMD/collins_support/reports/relocation-pair-001.json); [log](/bigTMD/collins_support/reports/relocation-pair-001.log). Seeds 1729 and 92741, 182 saved rows each, with the original retained analytical evidence. |
| Retained v0.4.0 and v0.3.3 pairs | Both **CHECKS_PASS**: [v0.4.0 result](/bigTMD/collins_support/reports/relocation-pair-001-evidence/retained/pair.json), [v0.3.3 result](/bigTMD/collins_support/reports/relocation-pair-001-evidence/retained/pair-evidence/retained-pair.json). |
| One fresh native RU workflow | **STAGES_PASS**, r00 through r07: [fresh run manifest](/bigTMD/collins_support/states/relocation-check/runs/20260915T021821Z-835a7cdd734f/run.json); [workflow log](/bigTMD/collins_support/reports/relocation-fresh-workflow-001.log). |
| Fresh scalar comparison | **167/167 PASS**, all residuals exactly `0`: [collins_support/reports/relocation-fresh-comparison-001.json](/bigTMD/collins_support/reports/relocation-fresh-comparison-001.json). Existing `u=-s-t` substitution applies only to `s09/H_UU` and `s09/H_UT`; other quantities use the identity conversion. No floating-point tolerance substitutes for equality. |
| Preservation and root boundary | **PASS**: [collins_support/reports/relocation-preservation-and-layout.json](/bigTMD/collins_support/reports/relocation-preservation-and-layout.json). Original organization report hashes match, all seven original directories remain, no root support entries/links/mounts exist. |

Exact fresh run: `/bigTMD/collins_support/states/relocation-check/runs/20260915T021821Z-835a7cdd734f`. The final pair replay and scalar comparison locations above are new outputs. The pair operation is **saved-report replay**; the fresh workflow is a separate **single native execution**. No second native campaign, MadGraph rebuild, fitted regression, PDF rebuild or Figure 6 run was performed.

Exact executed argv, environment, locations and result/log hashes are in [collins_support/reports/relocation-commands.json](/bigTMD/collins_support/reports/relocation-commands.json). The original accepted organization reports remain at `/bigTMD/collins_support/states/Collins-ep-analytic-state-v0.5.1-organization-001` with their original hashes. Validation passed without a failed/restarted pair replay or native workflow. Optional verification stopped after the required checks passed.

## Current commands

Run from `/bigTMD` with the existing Python 3.10 environment. Choose an unused report filename.

```bash
cd /bigTMD
export PYTHONDONTWRITEBYTECODE=1 OPENBLAS_NUM_THREADS=1 OMP_NUM_THREADS=1 MKL_NUM_THREADS=1 GIT_OPTIONAL_LOCKS=0

# Current environment/source readiness (no native campaign)
/usr/bin/python3.10 collins_support/validators/analytic/workflow.py doctor --repo /bigTMD

# One future fresh RU workflow; creates a unique run below states/runs
/usr/bin/python3.10 collins_support/validators/analytic/workflow.py run --repo /bigTMD --state collins_support/states/runs --through r07

# Replay the retained organization seed reports into a new result
/usr/bin/python3.10 collins_support/validators/analytic/compare_ru_reports.py --repo /bigTMD --report collins_support/reports/pair-next.json collins_support/states/Collins-ep-analytic-state-v0.5.1-organization-001/ru-1729.json collins_support/states/Collins-ep-analytic-state-v0.5.1-organization-001/ru-92741.json

# Reproduce the scalar report from this already-completed fresh run
/usr/bin/python3.10 collins_support/reports/compare_relocation_run.py --run /bigTMD/collins_support/states/relocation-check/runs/20260915T021821Z-835a7cdd734f --report collins_support/reports/scalars-next.json
```

| Entry point / command | Status |
|---|---|
| `validators/analytic/workflow.py` and `compare_ru_reports.py` | Current native workflow and saved-report replay. |
| `validators/analytic/verify_ru.py` | Retained official full two-run verification API; not invoked as an additional campaign here. New report outputs use `reports/`. |
| `collins_ep_analytic_SIDIS/tools/reproduce_organization.py` | Current optional full organization reproduction command; `--state` must be an unused child of `states/runs`, and `--reports` selects an unused reports child. It performs two fresh runs and is outside this mission’s single-run verification. |
| `collins_ep_analytic/run.py` | Current comparison-engine wrapper; `COLLINS_ANALYTIC_VALIDATOR` defaults to the bundled `validators/analytic/retained/v0.4.0/retained/v0.3.3`. |
| Bundled retained v0.4.0/v0.3.3 comparators | Required analytical evidence chain; remains enabled and was exercised by the final pair. |
| Historical `install.py` helpers | Completed campaigns, clearly labeled; defaults/output guards stay project-local. No reinstall is needed. |
| `validators/analytic/upgrade.py` | Completed adoption command; returns `HISTORICAL_COMMAND` and does not recreate retired validators/states. |
| Archived comparison report builders, root install/upgrade instructions, packaging scripts and dependency-migration adapter | Historical; not current prerequisites or acceptance gates. |
| Optional numerical validator / phenomenology commands | Numerical validator absent; current provider-manifest filesystem access supports moved phenomenology paths. No fitted/phenomenology calculation was run. |

## Required native installations

| Component | Existing location |
|---|---|
| `fermat` | `/bigTMD/SIDIS/common/software/fermat/Ferl7/fer64` |
| `feynarts_root` | `/factorization-and-loops/Addon/Mathematica_Addon/FeynCalc/FeynArts` |
| `feyncalc_root` | `/factorization-and-loops/Addon/Mathematica_Addon/FeynCalc` |
| `kira` | `/bigTMD/SIDIS/common/software/kira-3.1` |
| `polymake` | `/usr/bin/polymake` |
| `python` | `/usr/bin/python3.10` |
| `subtropica_root` | `/bigTMD/SIDIS/common/software/SubTropica-1.2.10` |
| `wolfram_kernel` | `/opt/Wolfram/WolframEngine/15.0/Executables/WolframKernel` |
| Retained MadGraph | `/bigTMD/collins_support/states/Collins-ep-analytic-state-v0.3.0/native-runtime/MG5_aMC_v3_7_0` |

Wolfram remains under `/opt`; FeynCalc/FeynArts remain under `/factorization-and-loops`; Python 3.10/SymPy, polymake, make and gfortran remain system installations. Kira, Fermat and SubTropica retain their existing project SIDIS installation paths. MadGraph stays with the moved v0.3.0 state. No external native installation was relocated or reinstalled.

**Remaining required blockers: none.** The existing scientific qualifications above continue to apply.
