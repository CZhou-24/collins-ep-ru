# Jet ingredients in the ep and high-pT SIDIS workflows

26 September 2026 · source revision `fd46f4e6b00e4166984faf0fb57bab5369503068`

**Result.** The inspected soft and Fourier interfaces are consistent after an explicit convention conversion. The **complete jet functions are not identical**: high-pT SIDIS has an additional semi-inclusive matching coefficient for radiation outside the jet. Fourteen focused algebra checks pass. This is a source-level comparison, not a new native campaign or a proof of equality of the two cross sections.

## What is common, and what differs

Let \(a=\alpha_s/(2\pi)\), \(z_J\) be the jet/parent momentum fraction, and \(z_h\) the hadron/jet fraction. In a common TMD and angular convention, denote the intrinsic, soft-subtracted fragmentation factor by \(F_i\). The relation to compare is

\[
G_i^{\rm ep}=F_i,\qquad
G_c^{\rm SI}(z_J)=\sum_i\left[\delta_{ci}\delta(1-z_J)+a h_{c\to i}(z_J,L)\right]F_i+O(a^2),
\quad L=\ln\frac{\mu^2}{p_{JT}^2R^2}.
\]

The right-hand side is expanded consistently through first order, including any expansion of \(F_i\). This is the shared factorization structure, not an independent numerical determination of the unspecified TMD input. The exclusive versus semi-inclusive distinction is explicit in [2311.00672v2, Eqs. (97)-(105), (114)-(126), (142)-(150)](https://arxiv.org/html/2311.00672v2). The ep recoil soft factor depends on the electron-jet imbalance and remains outside this comparison.

For transverse quark matching, the high-pT source gives

\[
h^T_{q\to q}=C_F\left[
\left(-\frac{L^2}{2}+\frac{\pi^2}{12}\right)\delta(1-z_J)
+2L\,\mathcal L_0(1-z_J)-4\mathcal L_1(1-z_J)
-2L+4\ln(1-z_J)\right],
\]

where \(\mathcal L_n(1-z)=[\ln^n(1-z)/(1-z)]_+\) on \([0,1]\). This is nonzero even at the natural scale: acting on the constant test function at \(L=0\) gives \(C_F(\pi^2/12-4)\). Both quark UU and UT actions were checked. Taking a distribution's point value at \(z_J=1\) cannot remove this correction.

## Direct checks and convention map

The ep soft expression, reconstructed from its source with the documented analytic sphere normalization, obeys

\[
S_{\rm in}^{(1)}=C_F\left[-\frac{B^2}{2}+B(V-g)-\frac{\pi^2}{12}\right],\qquad
S_{\rm in}^{(1)}(B,V,g)=\tfrac12 S_{\rm standard}^{(1)}(B,V-g)
\]

at one loop in the coefficient convention used here, including the regulated poles. Here \(B=\ln(\mu^2b^2e^{2\gamma_E}/4)\), \(V=\ln(\mu^2/\nu^2)\), and \(g=\ln[R^2/(4\cosh^2Y)]\). The extra ep jet remainder is therefore zero; **the soft function itself is not zero**. Its rapidity derivative is \(-2C_FB\), exactly the high-pT source's in-jet soft anomalous dimension, cancelling that source's unsubtracted TMD rapidity term. Both assemblies use \(\zeta_J=p_{JT}^2R^2\) when the same local jet momentum is used.

The Fourier definitions require the following map for the **same momentum-space input**:

| Quantity | Definition-level conversion |
|---|---|
| Unpolarized forward transform | \(D_{\rm ep}=z_h^2\widetilde D_{\rm highpt}\) |
| Native Collins vector coefficient | \(C_{\rm ep}=-2z_h^4 M_h\widetilde H_{\rm highpt}^{\perp(1)}\) |
| Native scalar UT radial action | Minus the high-pT Trento/analyzer radial action |

Here \(C_{\rm ep}\) multiplies \(-ib^i/(2z_h)\) in the native vector transform. The sign follows from the ep source's declared \(H_C=-H_{\rm Trento}/z_h\); the tree moment is \(\widehat H^{(3)}=-2z_hM_hH_{\rm Trento}^{(1)}\). It is a conversion to carry with the spin/analyzer convention, **not a diagnosed sign bug**. A global angular-frame/hard-tensor equivalence was not tested. Powers of \(z_h\), the signed radial integrands, and forward/inverse transforms were checked exactly with a Gaussian test function; no phenomenological model was fitted. Its finite \(b\to0\) moment is only a transform test, not a statement about UV-divergent physical TMD moments.

| Executed check group | Result |
|---|---:|
| Soft overlap and rapidity relations | 3/3 |
| Common local jet rapidity scale | 1/1 |
| Fourier normalization, native moment and signed conversion | 8/8 |
| Nonzero semi-inclusive UU/UT distribution actions | 2/2 |
| **Total** | **14/14 exact algebra checks** |

The count includes related identities and expected nonzero differences checked against explicit formulas; it is not 14 independent physics predictions. The earlier 74-check literature audit is separate and is not relabelled as this direct comparison.

## Scope and next step

The ep workflow computes a restricted small-b Collins expansion; the high-pT workflow leaves its soft-subtracted Collins TMD symbolic. Therefore their **complete intrinsic NLO Collins coefficients have not been compared independently**. Generic twist-three endpoint contacts, finite-radius corrections, nonperturbative inputs and the full angular observables remain outside this check. The narrow-cone relation is not a finite-R=1 certification.

No production changes are indicated by the checked relations. Before sharing fitted inputs, implement the explicit normalization/sign adapter and keep the extra semi-inclusive matching in the high-pT observable. The next planned benchmark can be Figure 3 of [1505.05589](https://arxiv.org/pdf/1505.05589), which tests fitted collinear inputs and their evolution; this note does not claim those curves have been reproduced.

## Reproduce and inspect

From the repository root, use an existing Python environment with SymPy 1.14 and an unused report directory:

```bash
python3 -B collins_support/checks/jet_equivalence/check_equivalence.py \
  --out collins_support/reports/jet-equivalence-replay-001
```

Use a new output directory. The script verifies all 15 pinned source snapshots, then writes `summary.json` and `checks.csv`. The native Wolfram/Kira/SubTropica calculation is not rerun; the analytic soft reconstruction supplies the sphere normalization explicitly. The comparison does not change production source or historical evidence. Its packaged snapshots are the inputs; active engine directories are not read.

Primary code at [the pinned revision](https://github.com/CZhou-24/collins-ep-ru/tree/fd46f4e6b00e4166984faf0fb57bab5369503068):

- ep: `common/ru_soft_assembly.wl`, `common/r07_assembly.wls`, `common/ru_hf_projection.wl`, `CONVENTIONS.md` under `collins_ep_analytic_SIDIS/`.
- high-pT: `common/jet_matching.wl`, `common/fragmentation.wl`, `common/tmd_evolution.wl`, `common/observable_assembly.wl` under `collins_sidis_highpt/`.
- `collins_support/checks/jet_equivalence/source_manifest.json` records Git blob and SHA-256 identities; this review's fresh results are in `equivalence/`.
