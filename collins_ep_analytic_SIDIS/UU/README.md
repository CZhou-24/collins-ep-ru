# UU: unpolarized spin projection

UU is the unpolarized projection of the Collins ep observable. The sectors below are beam matching, fragmentation matching and common hard/soft/jet operators; they are not labels for the original inclusive SIDIS photon channels. This directory is a navigation view. Canonical scientific sources remain in [common](../common/).

| Required sector | Generating source and physical content | Native/assembly route |
|---|---|---|
| `beam_fqq` | [ru_tmd_generation.wl](../common/ru_tmd_generation.wl): spacelike incoming-quark cut and spin/color average | Shared measured M family; qq subtraction and soft endpoint |
| `beam_fqg` | [ru_tmd_generation.wl](../common/ru_tmd_generation.wl): incoming gluon average and spacelike active quark | Same M family; qg subtraction and epsilon numerator |
| `fragment_dqq` | [ru_tmd_generation.wl](../common/ru_tmd_generation.wl): timelike parent, observed quark | Same M family; fragmentation Fourier/z factors and qq subtraction |
| `fragment_dgq` | [ru_tmd_generation.wl](../common/ru_tmd_generation.wl): observed-gluon channel with explicit crossing/color normalization | Same M family; gq subtraction and fragmentation measure |
| `recoil_soft` | [ru_soft_generation.wl](../common/ru_soft_generation.wl): beam/jet eikonal current and physical angular/rapidity measure | M at u=0; [transforms](../common/ru_soft_transforms.wl) and [soft assembly](../common/ru_soft_assembly.wl), eta cancellation before epsilon expansion |
| `jet_UU` | Same [soft/jet generating source](../common/ru_soft_generation.wl): joint leading-power region and measured cone | Nonzero bare and overlap constituents retained; common cancellation in the stated scope |
| `hard_virtual` | [ru_virtual_generate.wl](../common/ru_virtual_generate.wl): ordinary current and self-energy | Separate virtual Kira/Euler master; r04–r06 UV/IR and hard assembly |

[r00](../common/r00_definitions.wls) also regenerates the [Born](../common/ru_born_generation.wl) and [real](../common/ru_real_generation.wl) amplitudes. [r01](../common/r01_real_map.wls) builds `jobs/measured`; [r02](../common/r02_real_masters.wls) supplies its Euler input to protected SubTropica; [r03](../common/r03_real_assembly.wls) contracts the actual rules/master using [ru_measured_helpers.wl](../common/ru_measured_helpers.wl) and [ru_tmd_assembly.wl](../common/ru_tmd_assembly.wl). The same measured scalar master also serves the Collins sectors. Sector-specific numerators, Fourier/rapidity factors and subtraction operators remain separate.

The ordinary chain is [r04](../common/r04_virtual_map.wls) → [r05](../common/r05_virtual_masters.wls) → [r06](../common/r06_virtual_assembly.wls), with `jobs/virtual`. The separate `jobs/quark` inclusive moment does not establish fixed-fraction TMD matching.

[r07](../common/r07_assembly.wls) is the actual UU observable producer. It binds the full-scale beam/fragmentation kernels to symbolic PDF/FF convolutions, adds hard/recoil/jet coefficients at strict first order in `alpha_s/(2 pi)`, and retains Fourier measures. The identified-hadron fragmenting jet replaces the inclusive jet. Multiple exported zero jet labels are consequences of one calculated cancellation, not independent integrals. The preserved [ru_formal_assembly.wl](../common/ru_formal_assembly.wl) is unused historical source.

Use the [supported complete workflow command](../README.md#reproduce-this-organized-edition); stage `.wls` files need runner-generated contexts. The [output/equation index](../comparison/OUTPUT_TO_EQUATION_INDEX.md) connects scalar aliases to producing nodes and evidence. See [reports](../reports/README.md), [conventions](../CONVENTIONS.md) and [limitations](../../collins_ep_analytic_SIDIS_review/reverse-unitarity-002/LIMITATIONS.md). Scope remains leading power and narrow cone; no finite R=1 or unrestricted nonsingular fixed-order NLO certification follows.
