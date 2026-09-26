# Native jet comparison: ep and high-pT SIDIS

**FOCUSED_COMPARISON_COMPLETE_WITH_DISCREPANCIES**. Fresh Wolfram checks of actual saved expressions and native assemblies; this is not a native campaign or renewed historical acceptance.

| Check group | Results |
|---|---|
| native_saved_reassembly | 38 EXACT |
| soft_separation | 3 EXACT |
| conventions | 2 EXACT |
| Fourier_conversion | 6 EXACT |
| test_input_scope | 2 EXACT |
| assembly_order | 3 EXACT |
| distribution_actions | 6 EXACT |
| auxiliary_helper_discrepancy | 2 DISCREPANCY |
| semiinclusive_difference | 18 EXPECTED_NONZERO_DIFFERENCE |
| HF_test_integration | 6 EXACT; 12 NUMERICAL_AGREEMENT |
| common_intrinsic_native_assemblies | 12 NUMERICAL_AGREEMENT |
| weighted_semiinclusive_difference | 6 EXPECTED_NONZERO_DIFFERENCE |
| recoil_expected_difference | 3 EXPECTED_NONZERO_DIFFERENCE |

Total: **119 rows**. 66 EXACT; 2 DISCREPANCY; 27 EXPECTED_NONZERO_DIFFERENCE; 24 NUMERICAL_AGREEMENT.

Exact rows retain the simplified difference. Numerical comparisons use 60-digit working precision, 40-digit accuracy/precision goals and `abs(left-right)/max(1,abs(left),abs(right)) < 1e-30`. Expected nonzero rows compare two evaluations of the correction itself; their residual is the difference between those evaluations, not the correction's difference from zero.

## Findings

The ep soft assembly recontracts the saved native sphere and reproduces the archived constituent expressions, including regulated poles. Its in-jet soft equals half the standard soft after the explicit rapidity shift; the additional UU and UT jet remainders vanish. The soft factor itself does not vanish. The nonzero recoil soft stays outside fragmentation. High-pT has no independent regulated in-jet soft export: its rapidity functions are checked, and its soft-subtracted intrinsic TMD remains an input.

The saved high-pT `LO`, `Born_times_jet_NLO` and `TMD_input` expressions are compared with fresh `HSBuildChannelObservable` output using the actual saved Born banks and an explicitly zero hard-NLO isolation input. No hard coefficient is recomputed or inferred to vanish. Quark UU/UT fragmentation inputs are then evaluated through native Fourier/assembly routines. The high-pT intrinsic TMD is supplied from the ep result: agreement is an assembly/convention test, not an independent calculation of that intrinsic matching.

The high-pT Uqq, Tqq and Uqg out-of-jet distributions are nonzero, including at the natural scale. Delta, plus and regular coefficients are read from native exports; their smooth polynomial and exponential test actions are evaluated without assigning point values to plus distributions. The production Born-times-jet action is also tested with a physical PDF/kinematic weight and an independently solved delta(w) Jacobian, normalized by the saved Born weight.

**Discrepancies / unresolved rows (not patched):**

| Quantity | Native difference, left minus right |
|---|---|
| `auxiliary_distribution_helper/Uqq` | `(CF*(8 + 3*L))/2` |
| `auxiliary_distribution_helper/Tqq` | `2*CF*(2 + L)` |

The auxiliary `HSJetDistributionAction` in `common/jet_matching.wl:23` has a complete SetDelayed expression before a newline. Wolfram reads the following `+Inactive[Integrate][...]` as a separate expression, so the actual DownValue contains only the delta term. On the constant test at L=0 its missing contribution is `-4 CF` for both Uqq and Tqq; auxiliary minus production is `4 CF = 16/3` at Nc=3. The inspected production engine has no caller of this auxiliary helper: `HSBuildChannelObservable` calls `HSBreitBornJetAction` and `HSDistributionOneAction`, which retain the distribution integrals. Its exact DownValue is saved in `comparison-expressions.wl`. This finding was invisible to a purely source-parsing comparison. Production code and historical verdicts remain unchanged.

## Common domain and explicit conversions

Common standard jet axis, leading narrow-cone and small-jT power limit; `R << 1`, `jT << pJT R`, positive scales and interior `0 < zh < 1`. The ep electron-jet imbalance and high-pT inclusive hard process are different observables. No Mandelstam/hard-tensor equivalence is imposed.

| Convention | Explicit map |
|---|---|
| Fractions | ep `zh` = high-pT `zh` (hadron/jet); `zJ` is the separate high-pT jet/parent fraction; ep intrinsic convolution variable is not `zJ`. |
| Coupling/order | `a = alpha_s/(2 pi)`; `gs^2 = 8 pi^2 a`. Fragmentation is `F0+a F1`; high-pT hard Born begins at a, ep at a^0 after its EM prefactor. Drop products beyond relative O(a). |
| Scales | ep `pT` = high-pT local `pJT`; `zetaJ=(pJT R)^2`, `Th=L=ln(mu^2/zetaJ)`, `Bh=ln(mu^2 b^2 exp(2 gammaE)/4)`. |
| Soft subtraction | `V=ln(mu^2/nu^2)`, `g=ln(R^2/(4 cosh(Y)^2))`; `Vstandard=V-g`; eta expanded before eps. Exactly one soft subtraction; no inclusive jet multiplied onto the identified-hadron FJF. |
| Fourier UU | phase `exp(-i p.b/zh)`; ep inverse measure `b J0/(2 pi zh^2)`; `D_ep = zh^2 Dtilde_HP`. |
| Collins | `HC=-HTrento/zh`, `Hhat3=-2 zh Mh HTrento^(1)`; finite-b native vector coefficient `C_ep=-2 zh^4 Mh Htilde_HP^(1)`. Native vector is `-i b^i C_ep/(2 zh)`. |
| Radial/angular sign | ep UT radial measure `b^2 J1/(4 pi zh^3)`; after the input conversion, native ep scalar radial action is minus high-pT Trento/analyzer action. Local analyzer gives `sin(phiS-phiH)`. This is a declared conditional map, not proof of a global hard-frame equivalence. |
| Scheme | Saved full-scale ep coefficients and physical-J0 scalar/rank continuation; no silent C11 finite shift or fitted TMD boundary. High-pT accepts this same soft-subtracted input. |

## Explicit test inputs and kinematics

`FFq(t)=t(1-t)^2`, `FFg(t)=2t(1-t)^3/5`, `Hhatq(t)=3 Mh t^2(1-t)^3/5`, `HF(t1,t2)=Mh t1(1-t1)^2(t1/t2)^2(1-t1/t2)^2/7`, with `Mh=7/50`, `Nc=3`. Both polarized inputs are nonzero. HF and its first v derivative vanish at v=1, within the inherited contact class. It enters the ep local expansion once and is included once in the intrinsic high-pT input. These test functions are not fits or independently predicted TMDs.

Small-b radial actions use the nonnegative C1 window `W(b)=(b-bmin)^2(bmax-b)^2/(bmax-bmin)^4` on `[bmin,bmax]`, zero elsewhere. They do not extend the local OPE to all b. Independent Gaussian identities test the full Fourier conventions with arbitrary nonzero amplitudes.

| Case | zh | pJT | R | mu | jT | Y | b window |
|---|---|---|---|---|---|---|---|
| k1 | 1/3 | 20 | 1/10 | 2 | 1/5 | 0 | [1/20, 1/4] |
| k2 | 1/2 | 30 | 3/20 | 9 | 2/5 | 1/3 | [1/25, 1/5] |
| k3 | 2/3 | 40 | 1/5 | 4 | 3/5 | -1/2 | [1/30, 3/20] |

Distribution tests use `1`, `zJ`, `1+zJ+zJ^2` on `[0,1]` and `exp(-zJ)(1+zJ^2)` on `[1/5,1]`, `[2/5,1]`, with `L=0, log(4), -log(4)`. Production-weight tests use `Q2=10000`, `xB=1/10`, `exp(etaJ)=6/5`, `y=2/5` and `PDF(x)=x(1-x)^3` (UT times 2/5), one selected quark species. Recoil examples use the separate `bq=1/7`.

## Provenance, reuse and remaining scope

- **Reused:** ep run `20260915T063100Z-b8feba4db8fd` measured TMD/soft/Fourier, evaluated sphere and r07 assembly; high-pT run `20260916T095719Z-1584d7f6dd71` finite jet and actual UU/UT assemblies/Born banks. Selected receipt hashes, generating sources, inputs and completion evidence are checked in [provenance.json](provenance.json).
- **Fresh:** native soft coefficient recontraction and Fourier helper integrals, isolated ep/high-pT fragmentation/jet assemblies, symbolic differences and high-precision distribution/radial actions. No full stage/campaign, dependency probe, hard-function, amplitude or reduction calculation.
- **Independence:** ep intrinsic matching comes from its archived native route, with shared operator definitions and archived scalar integration evidence. High-pT finite out-of-jet matching and evolution are literature imports. The common intrinsic TMD and fragmentation/PDF test functions are supplied inputs. Two native action implementations and the explicit delta(w) Jacobian provide assembly checks, not independent QCD calculations of every ingredient.
- **Preservation:** selected production/runtime/source inputs and original evidence hashes were checked unchanged. Relocated helper bodies match their original source hashes after undoing only the documented extra root-discovery level. Historical 16,416 native checks are historical; the later 54-comparison and subtraction changes do not requalify that run or enter this jet test.
- **Open:** independent high-pT intrinsic Collins OPE, generic twist-three contacts, nonperturbative all-b inputs, finite-R corrections (including R=1), full hard/angular-frame equivalence, full cross sections and independent physics review. Do not interpret these comparisons as broader physical accuracy or new acceptance.

[comparison.csv](comparison.csv) contains all expressions/residuals; [summary.json](summary.json) contains status, settings and execution records. [native-extract.wl](native-extract.wl) and [comparison-expressions.wl](comparison-expressions.wl) retain executable expressions; [extract_native.log](extract_native.log) and [compare_native.log](compare_native.log) retain fresh logs.

Reproduce from `/bigTMD` into an unused report directory:

```bash
python3 -B collins_support/checks/jet_native_comparison/run.py \
  --out collins_support/reports/jet-native-comparison-replay-001
```

The command returns exit 2 when it reports discrepancies; read the completed report. No publication sync, commit or push is performed.
