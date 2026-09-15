# Collins ep analytical engine

The unpolarized UU and Collins UT derivations for electron scattering from a transversely polarized proton are implemented in `common/`. Scope: Born plus one loop, leading power in the joint small transverse momenta, narrow cone, and the documented physical HF endpoint class. Hadronic functions remain symbolic.

Start with [conventions](CONVENTIONS.md), [UU](UU/README.md), [Collins](Collins/README.md), the [output/equation index](comparison/OUTPUT_TO_EQUATION_INDEX.md), and the [comparison reports](reports/README.md). Source reuse and adapted definitions are recorded under [provenance](provenance/).

The producing analytical source files are unchanged by the publication cleanup. The source implementation is v0.5.1; its historical scientific review and current execution checks have distinct scopes.

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

Ten measured sectors share `jobs/measured` and its one scalar master M111; `hard_virtual` uses `jobs/virtual`. The `jobs/quark` inclusive moment is a separate pilot. Native state stores jobs under each run's `common/rNN_result/`. [ru_formal_assembly.wl](common/ru_formal_assembly.wl) is an unused historical scaffold; the actual final producer is r07 and [ru_observable_helpers.wl](common/ru_observable_helpers.wl).

## Execute

Use the current [runner and verification commands](../collins_support/README.md) from the repository root. The runner constructs required contexts; the stage `.wls` files should not be launched directly.

Python/SymPy and configured Wolfram, FeynCalc/FeynArts, Kira/Fermat, SubTropica/HyperIntica and polymake installations are required. Update native paths in [ru_runtime.json](ru_runtime.json) for the machine being used. Earlier Collins engines, retired validators and historical state directories are not current runtime inputs.

New runs produce their own native intermediate evidence, reductions, masters and final exports. The 167 scalar targets are fixed regression references, not independent literature proofs or inputs to the generating stages. Current reports do not renew the historical full acceptance or its MadGraph checks.

Generic HF contacts, finite R=1 accuracy, unrestricted nonsingular NLO, NNLO and a closed full twist-three system remain uncertified. Shared operator definitions and qualified polarized/Fourier conversions limit independence; see the [scientific review](../collins_ep_analytic_SIDIS_review/reverse-unitarity-002/SCIENTIFIC_REVIEW.md) and [limitations](../collins_ep_analytic_SIDIS_review/reverse-unitarity-002/LIMITATIONS.md).
