# SIDIS through NLO: two calculation workflows

This repository contains symbolic partonic structure functions `F1hat` and `F2hat` for six massless, unpolarized SIDIS channels at nonzero transverse momentum, together with their numerical convolutions and plots.

The current calculation is in **[SIDIS](SIDIS/README.md)**. It uses reverse unitarity for real-emission integration and Kira/SubTropica for the required real, virtual and self-energy master integrals. The previous published calculation is preserved in **[partial_fraction_based_workflow](partial_fraction_based_workflow/)**.

The first channel label denotes the incoming parton; the second denotes the observed, fragmenting parton, with momentum `k1`. LO at nonzero transverse momentum is order `alpha_s`; the NLO correction is order `alpha_s^2`.

The **[37-page calculation report](SIDIS/SIDIS_calculation_report.pdf)** explains the equations, normalization, channel bookkeeping and numerical method. Its **[LaTeX source](SIDIS/SIDIS_calculation_report.tex)** is included.

## Repository layout

~~~text
.
├── README.md
├── .gitattributes
├── partial_fraction_based_workflow/
│   ├── Hgg_v2/
│   ├── Hgq_v4/
│   ├── Hqg_v3/
│   ├── Hqq_v4/
│   ├── Hqqbar_v2/
│   ├── Hqqprime_v2/
│   └── numerics/
└── SIDIS/
    ├── Hqq/
    ├── Hqg/
    ├── Hgq/
    ├── Hgg/
    ├── Hqqbar/
    ├── Hqqprime/
    ├── common/
    ├── bigTMD_comparison/
    ├── numerics/
    ├── .cluster/
    ├── README.md
    ├── SIDIS_calculation_report.tex
    └── SIDIS_calculation_report.pdf
~~~

The archive preserves every previously published entry at commit `87088bbc52a39b5cacbbe806418c1814c346f7e2`, including its empty `.gitattributes`. Its entire subtree is identical to that commit's root tree. Git history is retained. Empty SIDIS directories have `.gitkeep` placeholders.

## Previous workflow and its results

| Folder | Calculation and full result |
| --- | --- |
| [Hqq_v4](partial_fraction_based_workflow/Hqq_v4/README.md) | Incoming quark, observed same-flavor quark: [s10_result.wl](partial_fraction_based_workflow/Hqq_v4/s10_result.wl). |
| [Hqg_v3](partial_fraction_based_workflow/Hqg_v3/README.md) | Incoming quark, observed gluon: [s12_result.wl](partial_fraction_based_workflow/Hqg_v3/s12_result.wl). |
| [Hgq_v4](partial_fraction_based_workflow/Hgq_v4/README.md) | Incoming gluon, observed fixed-flavor quark: [s10_result.wl](partial_fraction_based_workflow/Hgq_v4/s10_result.wl). |
| [Hgg_v2](partial_fraction_based_workflow/Hgg_v2/README.md) | Incoming gluon, observed gluon: [s05_result/Fhats.wl](partial_fraction_based_workflow/Hgg_v2/s05_result/Fhats.wl). |
| [Hqqbar_v2](partial_fraction_based_workflow/Hqqbar_v2/README.md) | Incoming quark, observed same-flavor antiquark: [s05_result/Fhats.wl](partial_fraction_based_workflow/Hqqbar_v2/s05_result/Fhats.wl). |
| [Hqqprime_v2](partial_fraction_based_workflow/Hqqprime_v2/README.md) | Incoming quark, observed distinct-flavor quark: [s05_result/Fhats.wl](partial_fraction_based_workflow/Hqqprime_v2/s05_result/Fhats.wl). |
| [numerics](partial_fraction_based_workflow/numerics/README.md) | Previous six-channel convolutions, frozen inputs, validation and bin results. Main numerical results are `s09_result` and `s11_result`; figures are in `dsigmapibydpt/`. |

The earlier real integration uses denominator partial fractions and the angular-integral method associated with the supplied SIDIS paper. Its virtual integrations use the recorded PaVe/FeynHelpers/Package-X route where applicable. Each archived channel retains its sources, results, caches and available `bigTMD_check`, `bigTMD` or `madgraph_check` directories.

Archived READMEs and execution records describe the original working layout. Relative links between archived sibling channels remain within the archive. Original absolute execution paths, and links to material outside the previous GitHub tree, remain provenance; the archive has not been rewritten as a new calculation generation.

## Current SIDIS folders

| Folder | Contents and channel bookkeeping |
| --- | --- |
| [Hqq](SIDIS/Hqq/README.md) | Same-flavor observed quark. Separate `qgg`, same-flavor quark-pair and distinct-flavor quark-pair sectors; charge moments, virtual correction and subtractions. |
| [Hqg](SIDIS/Hqg/README.md) | Observed gluon from an incoming quark. Its own gluon-tagged Born, real and virtual tensors and fragmentation routes. |
| [Hgq](SIDIS/Hgq/README.md) | Observed fixed-flavor quark from an incoming gluon. Its dimensional gluon average, photon–gluon-fusion tensors and subtraction routes. |
| [Hgg](SIDIS/Hgg/README.md) | Observed gluon with an unobserved quark–antiquark pair. Summed squared flavor charges and real/factorization contribution. |
| [Hqqbar](SIDIS/Hqqbar/README.md) | Observed same-flavor antiquark with two identical spectator quarks. Fixed charge and spectator counting. |
| [Hqqprime](SIDIS/Hqqprime/README.md) | Observed distinct-flavor quark. Independent incoming/observed charges and all three charge-polynomial components. |
| [common](SIDIS/common/README.md) | Shared stages, invariant definitions, Kira reductions, master inputs and evaluations, software, assembly and execution evidence. |
| [bigTMD_comparison](SIDIS/bigTMD_comparison/README.md) | Frozen reference coefficients, source-bound conversions, exact differences, high-precision checks, proof caches and comparison reports. |
| [numerics](SIDIS/numerics/README.md) | New-hat convolutions with PDFs and FFs, physical maps, acceptance, native evaluators, bin integration, validation and plots. |
| `.cluster` | Reserved cluster-support directory. This snapshot has no connection file in it; execution receipts and logs are retained with their owning stages. |

Each channel README records its conventions, inputs, normalization, accepted checkpoints and downstream consumers. Read it before rerunning a stage.

## How the calculation works

### Generated amplitudes and contractions

FeynArts supplies process amplitudes. FeynCalc performs spin sums, color algebra, interferences and the two contractions with the photon metric and incoming momentum pair. The final structure functions use the paper's projection of these scalar contractions.

The new calculation reuses unchanged generated amplitudes, unintegrated tensors, Born tensors, projectors and loop-independent factorization definitions from the previous channels, with recorded input hashes. Incoming averages, observed-particle assignments, spectator weights and charge conventions are retained for their own channels.

### Real emission: reverse unitarity

The observed momentum is fixed. The two unobserved momenta are routed as `r` and `P_X-r`, with `P_X=p+q-k1` and `w=P_X^2`. Their positive-energy on-shell constraints become cut propagators. The cut-master measure is `d^D r delta_+(r^2) delta_+((P_X-r)^2)`, with the phase-space and `2 pi` normalization retained explicitly. The observed parton is not integrated as another cut.

The code maps the contracted integrands to independent scalar propagator families and checks exact reconstruction. Kira applies integration-by-parts identities with both physical cuts retained. The accepted shared reduction maps **315 requested real integrals to eight cut masters**.

Dependent propagators still require algebraic removal to define valid families. The actual phase-space values come from the physical cut-master calculation, rather than the old evaluated angular tables.

### SubTropica master evaluation and endpoints

The programs construct the physical cut Euler inputs, Jacobians, prefactors and geometric substitutions. SubTropica evaluates these parameter integrals with its HyperIntica backend to the regulator orders needed by their coefficients. Raw output, root definitions, parameter measures and analytic continuation accompany the evaluated values.

SubTropica is an integration engine supplied with explicit inputs here; a master name is not an automatic lookup of every integral in the literature. Soft-region stages retain regulated recoil powers before constructing delta, plus and ordinary terms. Endpoint and branch limits are part of the symbolic calculation.

### Virtual integrals, self energies and UV renormalization

Hqq, Hqg and Hgq have Born contributions and one-loop corrections. Their virtual targets pass through Kira and fresh SubTropica bubble/box parent inputs. The accepted reduction has **252 canonical targets and seven scalar masters**, reached from 1625 original targets.

Quark, gluon/ghost and fermion self-energy inputs also pass through Kira/SubTropica to obtain the UV bookkeeping. Physical continuation is applied before the Hermitian interference; UV cancellation is checked before the renormalized virtual term enters final assembly.

Hgg, Hqqbar and Hqqprime first contribute at order `alpha_s^2` and have no virtual contribution at this order.

### Factorization and final F hats

The integrated real terms, renormalized virtual terms where present, and initial-PDF/final-FF factorization terms are combined in the paper's conventions. Born tensors in pole-multiplied terms retain their dimensional dependence. Every required negative regulator coefficient must cancel before the finite tensor is projected and exported.

~~~text
Real:
FeynArts → FeynCalc → reverse unitarity → Kira → SubTropica
         → regulated endpoint distributions → factorization/final assembly

Virtual and self energies:
FeynArts → FeynCalc → Kira → SubTropica
         → physical continuation and UV renormalization → final assembly
~~~

The supplied SIDIS paper defines the observable and conventions. The standalone QCD reference supplies the reverse-unitarity/Kira/SubTropica approach. Accepted current master values do not come from Package-X/PaVe or the paper's evaluated angular tables. Historical excluded attempts remain identifiable under `previous_runs/`.

## New final F hats

| Channel | Full result and conventions | F1 hat | F2 hat |
| --- | --- | --- | --- |
| Hqq | [s17_result.wl](SIDIS/Hqq/s17_result/s17_result.wl) | [s17_F1_hat.wl](SIDIS/Hqq/s17_result/s17_F1_hat.wl) | [s17_F2_hat.wl](SIDIS/Hqq/s17_result/s17_F2_hat.wl) |
| Hqg | [s17_result.wl](SIDIS/Hqg/s17_result/s17_result.wl) | [s17_F1_hat.wl](SIDIS/Hqg/s17_result/s17_F1_hat.wl) | [s17_F2_hat.wl](SIDIS/Hqg/s17_result/s17_F2_hat.wl) |
| Hgq | [s17_result.wl](SIDIS/Hgq/s17_result/s17_result.wl) | [s17_F1_hat.wl](SIDIS/Hgq/s17_result/s17_F1_hat.wl) | [s17_F2_hat.wl](SIDIS/Hgq/s17_result/s17_F2_hat.wl) |
| Hgg | [s11_result.wl](SIDIS/Hgg/s11_result/s11_result.wl) | [s11_F1_hat.wl](SIDIS/Hgg/s11_result/s11_F1_hat.wl) | [s11_F2_hat.wl](SIDIS/Hgg/s11_result/s11_F2_hat.wl) |
| Hqqbar | [s11_result.wl](SIDIS/Hqqbar/s11_result/s11_result.wl) | [s11_F1_hat.wl](SIDIS/Hqqbar/s11_result/s11_F1_hat.wl) | [s11_F2_hat.wl](SIDIS/Hqqbar/s11_result/s11_F2_hat.wl) |
| Hqqprime | [s11_result.wl](SIDIS/Hqqprime/s11_result/s11_result.wl) | [s11_F1_hat.wl](SIDIS/Hqqprime/s11_result/s11_F1_hat.wl) | [s11_F2_hat.wl](SIDIS/Hqqprime/s11_result/s11_F2_hat.wl) |

Keep the full result with the direct F1/F2 files: it records physical support, charges, color/flavor symbols, scales, distributions, branches and source identities. The core channels retain LO delta and NLO delta/plus/ordinary pieces with their branch boundary. The three real-only channels have ordinary finite NLO coefficients; the calculation checked their vanishing endpoint coefficients.

From the repository root, a licensed Wolfram kernel can load the saved Hqq expressions directly:

~~~wolfram
result = Get["SIDIS/Hqq/s17_result/s17_result.wl"];
f1 = Get["SIDIS/Hqq/s17_result/s17_F1_hat.wl"];
f2 = Get["SIDIS/Hqq/s17_result/s17_F2_hat.wl"];
Keys[result]
~~~

Reading these expressions does not require rerunning diagram generation or integration.

## Stages and rerunning

Channels contain consecutive `sNN_<program>` entries and `sNN_result/` directories. Many programs and `shared` result entries are relative symbolic links into `SIDIS/common/`. Preserve those links. Shared programs run once for their applicable channel group; invoking every channel's link separately repeats shared work.

| Operation | Hqq/Hqg/Hgq | Hgg/Hqqbar/Hqqprime |
| --- | --- | --- |
| Preserved inputs and kinematics | s01–s02 | s01–s02 |
| Real families and Kira reduction | s03–s04 | s03–s04 |
| Physical cut inputs and evaluation | s06, s08 | s05–s06 |
| Real coefficients and soft regions | s09, s13 | s07–s08 |
| Virtual families, reduction, inputs and evaluation | s05, s07, s10–s11 | Not required |
| New self-energy/UV input | s12 | Not required |
| Collinear input | Preserved in s01 | s09 |
| Real assembly | s14 | s10 |
| Virtual coefficients and renormalized assembly | s15–s16 | Not required |
| Final cancellation and F-hat export | s17 | s11 |

This table groups operations by purpose. Use the owning README for exact dependency order. The active shared route uses common `s02–s05` and `s08–s20`, with dependencies in their sources. Common s06/s07 describe the earlier uncut-parent attempt and are not the accepted physical-cut backend. Layout organization stages are not physics stages to repeat.

### Runtime and existing checkpoints

Accepted physics execution used Hoffman2 compute nodes and a licensed Wolfram runtime with FeynCalc/FeynArts. [common/software](SIDIS/common/software/) contains the pinned Kira 3.1, Fermat, SubTropica 1.2.10/HyperIntica and recorded Polymake/SCIP dependencies, with sources, binaries, installation records and the Polymake container. Wolfram and its license are external requirements.

This is a research execution snapshot with recorded cluster paths and package assumptions. `common/s22_paths.wl` relocates SIDIS paths and verifies source identities. Kernel paths, dynamic-library setup and wrappers still require a matching runtime on another machine. Follow the execution receipts and package checks. Changes require new source identities; checkpoint gates must not be bypassed.

For an already configured runtime and the included accepted imports, set `WOLFRAM_KERNEL` to the licensed executable and invoke a stage directly:

~~~bash
"$WOLFRAM_KERNEL" -noprompt -script SIDIS/common/s02_definitions.wl
~~~

Initial imported inputs are already included in each `s01_result/`. The original importer refers to former sibling channel names. A fresh reimport must map those locations to `partial_fraction_based_workflow/` in its run environment and regenerate its manifest. It is unnecessary for reading saved results or using accepted imports.

Run expensive physics stages in a scheduler allocation with stage-specific memory bounds, bounded concurrency and a persistent process/output monitor. A checkpoint is reusable only when its source, inputs, regulator order and conventions match its identity.

### Results, caches and provenance

Shared `common/sNN_result/` folders contain Kira configurations, targets, rules, logs and databases, or SubTropica inputs, raw output, evaluated series and caches. Channels retain their own coefficients and final results. All-six final acceptance is in [common/s20_result](SIDIS/common/s20_result/).

`previous_runs/` retains superseded work for provenance, not alternate accepted final hats. `common/previous_runs/layout_sources/` contains the original sources that produced accepted artifacts; [common/s21_result/layout.json](SIDIS/common/s21_result/layout.json) records the path-only organization. Keep these identities with relocated sources because the adapter uses them.

## Numerics and plots

[SIDIS/numerics](SIDIS/numerics/README.md) consumes the new F hats. It uses retained MRST2002 NLO PDFs, KKP and Kretzer neutral-pion FFs, H1 binning/cuts and `mu^2=(Q^2+p_T^2)/2`. All six channels contribute. The uniform-azimuth F1/F2 approximation is documented in the report.

| Numerical location | Contents |
| --- | --- |
| `Fhats/` | Frozen new coefficients, producer identities, pole evidence and conventions. |
| `references/` | Frozen experimental/paper inputs, source snapshots, unchanged definitions and validation coordinates. |
| `vendor/` | PDF/FF Fortran routines and grids, model flavor/charge definitions. |
| `runtime/` | Requirements and accepted Python/compiler/package versions. |
| `sNN_cache/` | Symbolic exports, native builds, precision checks and resumable integration records. |
| [s09_result](SIDIS/numerics/s09_result) | Accepted bin cross sections, signed channel components, covariance and integration information. |
| [s11_result](SIDIS/numerics/s11_result) | Final aggregation and input checks. |
| [dsigmapibydpt](SIDIS/numerics/dsigmapibydpt/README.md) | Data/reference carriers, plotting code and receipts, PDF and PNG figures. |

The [numerical run order](SIDIS/numerics/README.md#stages-and-run-order) includes the separate inverse-map mode before hard-function export. It derives physical maps and luminosities, exports native evaluators, validates precision, applies the full plus-distribution endpoint subtraction, and integrates channels jointly with recorded seeds and covariance.

The accepted environment records Python 3.10.9, GCC/GFortran 12.5.0, Boost 1.82 and VEGAS 6.3. See [runtime/s01_result.json](SIDIS/numerics/runtime/s01_result.json) and [requirements.txt](SIDIS/numerics/runtime/requirements.txt). Execution receipts contain stage-specific commands. Rebuild PDF/FF interfaces and hard-function/convolution libraries in a different runtime; saved native libraries retain cluster paths. Individual import helpers also require the Python interfaces they call.

To redraw the included accepted bins with plotting dependencies installed:

~~~bash
SIDIS_CLUSTER_RUN=1 python SIDIS/numerics/dsigmapibydpt/s03_plot_comparison.py
~~~

The flag sends progress to the console. This redraws saved predictions without recomputing the F hats or integration. In the original project, `scripts/progress.md` is the sole live status record; archived relative progress links describe that layout, not an additional physics input.

- Cross sections: [PDF](SIDIS/numerics/dsigmapibydpt/s03_cross_section.pdf), [PNG](SIDIS/numerics/dsigmapibydpt/s03_cross_section.png).
- Theory/H1 ratios: [PDF](SIDIS/numerics/dsigmapibydpt/s03_ratios.pdf), [PNG](SIDIS/numerics/dsigmapibydpt/s03_ratios.png).

All 17 accepted H1 bins passed the saved numerical gates. Theory error bars are numerical integration errors only; scale, PDF and FF uncertainties are not included. SIDIS and BigTMD predictions are bin averages; paper-curve ratios use bin-centre values. SIDIS figures retain the full BigTMD overlay; archived numerics also contains its separately published public-driver selection comparison.

## Comparisons and remaining caveat

The [overall BigTMD report](SIDIS/bigTMD_comparison/s04_result.md) records **60/60 exact coefficient comparisons and 120/120 high-precision checks passing**, under its documented rational reconstruction of printed decimals, SU(3), matched scales/charges and distribution conventions. Reference coefficients are compared after production, not used to tune a result.

The inherited **Hgq MadGraph real-emission sign comparison remains unresolved**. Passed coefficient and pole checks do not close that separate comparison. The channel README and numerical report preserve the limitation.

## Git LFS and the report

Two included paths use Git LFS: the large Polymake container, `SIDIS/common/software/polymake-4.4.sif`, and the vendored macOS HyperFLINT library, `SIDIS/common/software/SubTropica-1.2.10/HyperFLINT/dist/macos-arm64/libhyperflint_librarylink.dylib`. The latter retains its upstream pointer; its matching payload was supplied to this repository's LFS storage. Other SIDIS files are regular Git objects or internal symbolic links, including results, caches, archives, report and plots.

A source ZIP may contain LFS pointers. For a fresh checkout with repository access configured:

~~~bash
git lfs install
git clone git@github.com:NonHermitianMatrix/SIDIS_dsigma_till_NLO.git
cd SIDIS_dsigma_till_NLO
git lfs pull
~~~

The report embeds the two saved vector-PDF plots by relative path. With its declared TeX packages installed, rebuild it from SIDIS:

~~~bash
cd SIDIS
pdflatex -no-shell-escape -interaction=nonstopmode -halt-on-error SIDIS_calculation_report.tex
pdflatex -no-shell-escape -interaction=nonstopmode -halt-on-error SIDIS_calculation_report.tex
pdflatex -no-shell-escape -interaction=nonstopmode -halt-on-error SIDIS_calculation_report.tex
~~~

Typesetting uses saved results and figures; it does not run the physics. This calculation is through NLO. NNLO requires its own amplitudes, families, masters, subtraction inputs and cancellation checks.
