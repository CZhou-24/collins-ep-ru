# Collins ep reverse unitarity — v0.5.1, organization-001

This is the analytical engine for unpolarized **UU** and Collins **UT** spin projections in electron–proton scattering with an identified hadron inside the measured jet. Its accepted scope is leading-power Born plus one loop, joint small recoil/hadron transverse momentum and the narrow-cone approximation, with a qualified physical HF endpoint class. PDFs, fragmentation functions and nonperturbative inputs remain symbolic. Fitting and Figure 6 are paused.

The scientific version remains **v0.5.1**. **organization-001** added navigation, an output/equation index and a reproduction entry point around the same 101 original engine file entries. Scientific programs stay canonical in [common](common/). The original freezes remain unchanged; [relocation records](../collins_support/reports/RELOCATION.md) identify the authorized path/configuration edits. The earlier comparison engine remains [collins_ep_analytic](../collins_ep_analytic/README.md).

## Start here

| Purpose | Guide |
|---|---|
| Unpolarized partonic/operator sectors | [UU stage view](UU/README.md) |
| Transversity, diagonal Collins and two-fraction HF sectors | [Collins stage view](Collins/README.md) |
| All 167 scalar outputs and all 85 equation groups | [Comparison guide](comparison/README.md), [output/equation index](comparison/OUTPUT_TO_EQUATION_INDEX.md) |
| Accepted checkpoint and this edition's fresh results | [Reports guide](reports/README.md) |
| Signs, dimensions, scales, measures and explicit conversions | [CONVENTIONS.md](CONVENTIONS.md) |
| Scientific qualifications | [Accepted scientific review](../collins_ep_analytic_SIDIS_review/reverse-unitarity-002/SCIENTIFIC_REVIEW.md), [limitations](../collins_ep_analytic_SIDIS_review/reverse-unitarity-002/LIMITATIONS.md) |

The accepted v0.5.1 checkpoint has 167 passing scalar comparisons and 11 sector views. These counts include shared coefficients, definitions and conditional zero representatives. They do not count independent literature derivations. The [archived milestone](../collins_ep_analytic_SIDIS_review/reverse-unitarity-002/MILESTONE_REPORT.md) and [archived pair](../collins_support/states/Collins-ep-analytic-state-v0.5.1/ru-pair.json) record that checkpoint. The [organization reproduction report](../collins_ep_analytic_SIDIS_review/organization-001/REPRODUCTION_REPORT.md) identifies the distinct fresh runs and their actual outcomes.

## Canonical stage map

The official workflow executes all eight stages and supplies their input/output contexts. Source links below are for inspection; the `.wls` programs require that context and are not standalone commands.

| Stage | Canonical source | Producing work |
|---|---|---|
| r00 | [r00_definitions.wls](common/r00_definitions.wls) | FeynArts/FeynCalc Born and real amplitudes; spacelike beam, fragmentation/Collins, HF and soft/jet operators |
| r01 | [r01_real_map.wls](common/r01_real_map.wls) | Fixed-fraction/radius measured family and separate inclusive pilot; native Kira jobs, targets and reductions |
| r02 | [r02_real_masters.wls](common/r02_real_masters.wls) | Unevaluated Euler inputs from the actual cut measures; protected native SubTropica evaluation |
| r03 | [r03_real_assembly.wls](common/r03_real_assembly.wls) | Actual reduction/master contraction; Fourier/rapidity/cone transforms, distributions, subtractions and finite matching |
| r04 | [r04_virtual_map.wls](common/r04_virtual_map.wls) | Fresh ordinary current/self-energy integrand, scalar reconstruction and native virtual Kira reduction |
| r05 | [r05_virtual_masters.wls](common/r05_virtual_masters.wls) | Ordinary virtual Euler master input and protected native evaluation |
| r06 | [r06_virtual_assembly.wls](common/r06_virtual_assembly.wls) | Hermitian interference, loop normalization, UV/IR allocation and hard coefficient |
| r07 | [r07_assembly.wls](common/r07_assembly.wls) | Strict first-order UU/UT and asymmetry, matching/HF convolutions, explicit conversions and 167 scalar exports |

Ten measured sectors share `jobs/measured` and its one scalar master M111; `hard_virtual` uses `jobs/virtual`. The `jobs/quark` inclusive moment is a separate pilot. Native state stores jobs under each run's `common/rNN_result/`. The [complete sector record](../collins_ep_analytic_SIDIS_review/reverse-unitarity-002/SECTOR_COMPLETION.md) distinguishes the generating numerators, shared integration and subtractions. [ru_formal_assembly.wl](common/ru_formal_assembly.wl) is an unused historical scaffold; the actual final producer is r07 and [ru_observable_helpers.wl](common/ru_observable_helpers.wl).

## Reproduce this organized edition

Current launch commands and relocation verification are recorded in [RELOCATION.md](../collins_support/reports/RELOCATION.md). For one fresh r00–r07 workflow:

```bash
cd /bigTMD
PYTHONDONTWRITEBYTECODE=1 OPENBLAS_NUM_THREADS=1 OMP_NUM_THREADS=1 MKL_NUM_THREADS=1 \
  /usr/bin/python3.10 collins_support/validators/analytic/workflow.py run \
  --repo /bigTMD --state collins_support/states/runs/my-run --through r07
```

Use a new run ID under `collins_support/states/runs/`. The workflow prints the actual native run path. The [organization runner](tools/reproduce_organization.py) remains available for a deliberately requested complete two-run/two-seed campaign with `--state collins_support/states/runs/<unused run ID>`. Its seed/pair reports default to `collins_support/reports/organization-<run ID>`; `--reports` can select another unused directory there. It checks the historical original and organized freezes through the exact recorded relocation changes. That larger campaign is unnecessary for the bounded relocation check.

The old accepted review's `audit/reproduce.py` and historical preservation/packaging scripts remain unchanged historical commands. Use the current official local workflow and comparator. New workflow evidence belongs under `collins_support/states/runs/`; current reports belong under `collins_support/reports/`. Historical report paths and recorded hashes are preserved and resolved explicitly at filesystem access.

## Prerequisites and preserved evidence

This is not a standalone runtime installer. Reproduction uses `collins_support/validators/analytic`, Python 3.10, configured Wolfram/FeynArts/FeynCalc, Kira/Fermat, SubTropica/HyperIntica and polymake installations, the original pinned SIDIS checkout, the accepted earlier engine and retained validator/MadGraph evidence. [ru_runtime.json](ru_runtime.json) records configured native paths. The earlier accepted pair is `collins_support/states/Collins-ep-analytic-state-v0.4.0/literature-revalidation-001/nlo-pair.json`. MadGraph remains inside the moved v0.3.0 state's `native-runtime/`.

The [accepted package guide](../collins_ep_analytic_SIDIS_review/reverse-unitarity-002/PACKAGE_README.md) retains its historical archive contract. Completed installers, archived packaging campaigns and the abandoned dependency-migration adapter are not current launch requirements. Current required analytical evidence is checked by the retained official verifier. Reference and provenance inputs remain in [provenance](provenance/) and the accepted review.

Generic HF contacts, finite R=1 accuracy, unrestricted nonsingular NLO, NNLO and a closed full twist-three system remain uncertified. Shared generating/operator definitions and conditional polarized/Fourier conversions limit independence. Analytical agreement alone does not certify a final physical prediction.
