# Breit-frame polarized derivation: implemented results and boundary

This note describes the implemented Born, real/virtual and finite NLO assembly
for the Collins moment fixed in [SCOPE.md](SCOPE.md). Earlier development
observations below retain their context; the continuation summary at the end
states the current implementation. [COMPLETION_INVENTORY.md](COMPLETION_INVENTORY.md)
and [NATIVE_VALIDATION.md](NATIVE_VALIDATION.md) distinguish implemented equations
from the separate full native campaign and pending independent physics review.

## Normalization and the two tagged spins

The input is the saved off-shell-photon Hqq amplitude, not the old elastic ep
hard factor. Electromagnetic model charge removal is tied to the saved
`ModelChargeSquared=4/9`; the initial factor is `1/(2 Nc)`. Artificial momentum
tags are inserted only inside the incoming/observed external Spinor heads.
The subsequent spin sum replaces only those tag slashes by the selected density.
Internal propagator numerators and unobserved spin sums remain unchanged.

With metric (+---), `gamma5=i gamma0 gamma1 gamma2 gamma3`, use
`rho(p,S)=slash(p)(1+gamma5 slash(S))/2`. The spin coefficient uses the bilinear
densities alongside the usual initial unpolarized average. The four fixed-spin
squares independently reconstruct UU and the spin tensor with their factors
of two retained in `projectors.wl`. The native calculation checks basis Gram
matrices, momentum orthogonality, independent basis rotations and Ward identities.
The independent reference constructs both diagrams directly with 4x4 matrices;
it loads neither the saved amplitudes nor producing output.

The incoming and outgoing bases are separately right-handed as specified in
SCOPE. The complete q-transverse photon basis is L,X,Y. All nine UU and all
36 transverse-spin/photon components are compared exactly at D=4. Dimensional
UU Pg/Ppp are recovered after the explicit invariant and color conversion.
The stored BMHV tensor retains D dependence; D=4 agreement is not a finite
operator-scheme proof.

For Hqqbar, the physical-point sum of all eight diagrams gives the nonzero
spin-trace coefficient `ee^2 eq^2 gs^4*(11050-11050 y+5081 y^2)/4590` at
`p=(5,0,0,5)`, `q=(0,0,0,-2)`, `k1=(1,1,0,0)`,
`k2=(3/4,0,3/4,0)`, `k3=(13/4,-1,-3/4,3)`, Nc=3.
The common lepton factor `Q^2/y^2`, symmetry weight and phase/flux factors are
not applied to this diagnostic coefficient. All external final momenta are
massless and have positive energy; the recoil invariant is w=6. An independent
Clifford charge-conjugation calculation checks the antiquark density without
an extra transverse-spin sign, consistent with hep-ph/9706511v2 Sec.3.
This establishes that the channel cannot be discarded; one physical point
does not establish its full dimensional NLO coefficient.

## Lepton contraction and angular coefficient

Write `phi=-phi_J`, `kappa^2=1-y`, and
`l=Q/(2y)*(2-y,2 kappa cos(phi),2 kappa sin(phi),-y)`, `l'=l-q`.
The code constructs `L^{mu nu}=2(l^mu l'^nu+l^nu l'^mu-g^{mu nu} Q^2/2)`.
Its effective density in the L,X,Y amplitude basis is

\[
\rho={Q^2\over y^2}\begin{pmatrix}
4(1-y)&2(2-y)\kappa\cos\phi&2(2-y)\kappa\sin\phi\\
2(2-y)\kappa\cos\phi&y^2+4(1-y)\cos^2\phi&4(1-y)\sin\phi\cos\phi\\
2(2-y)\kappa\sin\phi&4(1-y)\sin\phi\cos\phi&y^2+4(1-y)\sin^2\phi
\end{pmatrix}.
\]

The Collins correlator, with epsilon_T^{12}=+1, supplies the analyzer
`j_T/(z_h M_h)*(-sin(phi_h),cos(phi_h))`. The explicit matrix check of its
sigma/gamma5 projection fixes this sign. Its unweighted hadron-azimuth integral
vanishes. The coefficient-defining independent three-angle Fourier projection
reduces to the photon-contracted spin trace `(T_11+T_22)/2` averaged over phi.
For Born Hqq, with electroweak/strong couplings and flux/phase space still
stripped, it gives

\[
{8 C_F Q^2\over y^2}\,[1+(1-y)^2].
\]

This number is a contracted Born coefficient, not a differential cross section.
The native resolved tensor contains the additional lepton-angle harmonics;
it is retained explicitly rather than inferred from UU F1/F2.

## A fresh real-sector calculation

The implemented diagnostic is Hqq RealDistinct with physical Y,Yprime spins.
With `a=(p-k2)^2`, `b=(k1+k2)^2`, the two cuts remain `k2^2=k3^2=0`, both
positive energy, and `w=(k2+k3)^2`. External tagged momenta are physical;
unresolved momenta retain their evanescent parts. The residual angular space
has dimension D-3. Its even moments are calculated as

\[
\langle n_y^{2j}\rangle=(-G_\perp)^j
{(1/2)_j\over((D-3)/2)_j},\qquad \langle n_y^{2j+1}\rangle=0.
\]

Thirty actual unordered-pair contractions supply Pg, Ppp and photon Ward.
The photon-bearing fermion line fixes the charge degree of each amplitude;
three degree sums are kept separately. The associated flavor weights are
`Nf-1`, `sum_{q' != q} e_{q'}/e_q`, and `sum_{q' != q} e_{q'}^2/e_q^2`.
The distinct-flavor tagging/symmetry weight is derived from the saved species.
The three photon Ward sums vanish individually.

The algebraic mapper is narrowly adapted from the saved SIDIS partial-fraction
code and consumes the new polarized integrands. Every family map reconstructs
its input rational function. Fresh Kira reduction covers 46 targets and closes
on `R01[1,1,0,0]` and `R03[1,1,0,1]`; 42 overlapping archived reductions agree
exactly and four targets receive fresh coverage. This does not import a UU
coefficient vector into UT.

Both master definitions, cuts and family propagators match the saved Euler
representations. From the actual new coefficient valuations the volume needs
epsilon order 1 (2 available); the single-massive class needs order 0 (1
available). Their archived series are reused without claiming a new SubTropica
evaluation. The measure is `d^D r delta_+(r^2) delta_+((P-r)^2)`, without 2pi
factors. The six partial charge/projector distributions use
`L_n=[log(w/B)^n/w]_+` on `[0,B]`. Three independent regulated monomial actions
check the endpoint identity. Phase factors, the other topologies, virtual terms
and counterterms are not included in these partial distributions.

## Universal imports and the unresolved finite matching

The literal pinned 2311.00672v2 equations and macros are kept under references.
Finite jet functions implement Eqs.114–117 and 126. The separate coefficient
conversion is `f(z) D_n=f(1) D_n+(f(z)-f(1))*log^n(1-z)/(1-z)`; the paper's
formula is not rewritten. Eq.32 supplies the transversity kernel. The earlier
snippet label saying 30 was a metadata error, corrected without changing the
literal equation or any coefficient.

Eqs.98–99 implement the Fourier pair with their z_h and M_h factors. An analytic
Gaussian is used only to test forward/inverse identities for n=0,1. The
renormalized soft-subtracted Collins TMD remains a symbolic input. Eq.90 assigns
the in-jet soft contribution to that TMD; multiplying the old electron–jet
imbalance soft function would double count a different measurement.

The native collinear diagnostic gives

\[
K_{\rm NDR}(z,D)={2C_Fz\over1-z}
 +{C_F(D-4)^2(1-z)\over2(D-2)},
\quad
K_{\rm BMHV}^{\rm out}-K_{\rm NDR}
 ={C_F(D-4)(4-D-6z+Dz)\over D-2}
 =2C_Fz\epsilon+O(\epsilon^2).
\]

The spacelike diagnostic has zero BMHV-minus-NDR difference. Both NDR
arrangements agree with the literal hep-ph/9706511v2 Eq.36 through epsilon
order 1; their all-D expression has the displayed order-epsilon-squared
difference. It is retained, not promoted to literal all-D equality or silently
removed from the reference. The outgoing diagnostic is not yet a proven
scheme conversion for the physical observed-leg prescription used in the
real amplitude. Its off-shell/observed momentum embedding and the renormalized
operator definitions must be matched first. Consequently neither adding
`2 C_F z` as a guessed finite counterterm nor simply dropping the evanescent
term establishes the requested NLO coefficient.

This unresolved matching is a scientific acceptance gap. The remaining real
topologies and the full virtual interference are also unfinished. There is no
claim that these calculations are impossible, no full r07 output, and no
two-run pair or dependency-probe verdict for the new process.

## Continuation: new dimensional tensors and operator limits

The earlier sections describe the original development boundary. The new native
evidence is under `collins_support/reports/sidis-highpt-001/continuation-001/`.
All unordered open photon/spin pairs have now been calculated for qgg (36),
same flavor (36), distinct flavor (10), and Hqqbar (36). The underlying saved
amplitudes are imports; these contractions are new. Their complete finite real
coefficients are still being assembled.

The matching gap described in the earlier development snapshot has since been
resolved for the explicitly defined one-loop collinear quark operators. The
native evidence in `general-collinear-001`, `initial-collinear-001/002`,
`tagged-collinear-001`, `operator-virtual-001`, and
`collinear-scheme-match-001` keeps all six diagonal photon/spin components.
The actual outgoing residue is `2 Born_D K/(lambda^2 m2)` and the incoming
residue is `2 Born_D K/(x lambda^2 m2)`. In the incoming limit, stronger gauge
powers cancel only after summing all diagram pairs. Here
`K=2 CF z/(1-z)+CF epsilon^2 (1-z)/(1-epsilon)`.
The physical-tagged real BMHV/NDR averages agree, as do the virtual vertex and
Wilson attachment numerators after the common transverse angular average.
The operator is `slash(n) gamma5 slash(S)`, with the same Born normalization
and MSbar pole subtraction. The integrable `(1-z)` difference has a simple
radial pole and produces no finite delta, plus or regular conversion.
The original evanescent-observed-daughter diagnostic does not define this
production embedding and has not been replaced or set to zero.

`jet-scheme-match-001.json` connects this spin kernel to the anti-kT out-of-jet
matching. Using the pinned paper's lower transverse scale
`kT_min^2=(pJT R)^2 (1-z)^2`, the radial integral is
`(kT_min^2)^(-epsilon)/epsilon`. With
`exp(gamma_E epsilon)/Gamma(1-epsilon)` and
`L=log(mu^2/(pJT R)^2)`, the finite transverse coefficients are
`delta: CF(-L^2/2+pi^2/12)`, `D0: 2 CF L`, `D1: -4 CF`,
and `regular: -2 CF L+4 CF log(1-z)`.
All four equal the separately transcribed literal jet formula after the stated
plus-distribution conversion. Four independently expanded regulated beta-function
actions agree. This is a symbolic radial/distribution derivation with an imported
universal jet geometry, not a fresh derivation of the factorization theorem.

The distinct-flavor tensor has six diagonal spin/photon projections in each of
three charge sectors, with 46 reconstructed scalar targets. Fresh Kira reduction
closes on two masters: 42 overlapping archived reductions agree exactly, and four
targets receive fresh coverage. The master definitions and required epsilon
orders have been checked for the new coefficients. The exchange-odd charge
interference is retained before the exact change of dummy variables
`k2 <-> k3`; its integrated zero is not a pointwise zero.

The new Born–virtual interference covers all 15 saved loop amplitudes, 210
scalar targets and seven masters. All 202 overlapping archived reductions agree
exactly; eight targets have no archived comparison. Six one-sided photon Ward
projections vanish coefficient by coefficient in the reduced master basis.
The master chord definitions match, and the four bubbles supply the needed
epsilon order 1 while the three boxes supply the needed finite term.

The UV pole was derived separately from the unreduced large-loop integrands,
using a weighted rational quotient expansion and D-dimensional angular moments.
An auxiliary massive logarithmic radial integral separates UV from scaleless IR.
All six UV residues cancel against the imported field/coupling constants times
the new Born tensors. The successful virtual assembly retains the IR poles and
finite term; it does not use UV residues inferred from IR-reduced massless bubbles.
Its two dilogarithms above the principal branch point are explicitly converted by

\[
\operatorname{Li}_2(x)=\frac{\pi^2}{3}-\frac{\log^2 x}{2}
 -\operatorname{Li}_2(1/x)-i\pi\log x,\qquad x>1.
\]

The archived master expressions stay unchanged. Domain checks and numerical
conversion residuals are saved separately from the exact tensor checks.

The outgoing collinear limit is now tested on the actual qgg tensor at arbitrary
Born `Q,r,z`, for all six diagonal components. The observed daughter is physical;
the unobserved pair carries opposite evanescent momentum. With splitting fraction
`zc`, the exact residue agrees with

\[
K_{\rm physical}(z_c,D)=\frac{2C_Fz_c}{1-z_c}
 +\frac{C_F(D-4)^2(1-z_c)}{2(D-2)}.
\]

The independent physical-daughter operator trace gives the same expression in
BMHV and NDR. The original diagnostic with an evanescent observed daughter and
its nonzero `2 CF z epsilon` term remain archived. No finite `2 CF z` counterterm
has been inserted. The literal paper's all-D difference remains a mismatch,
even though its epsilon expansion agrees through order 1. The initial-state
limit is a separate full-36-pair calculation: its axial reference is singular,
so stronger gauge-dependent poles may only be discarded after the diagram sum.

Both dimensional Born MS convolutions have been evaluated with independent
renormalization, PDF and fragmentation scales. The initial development assembly retained unfixed finite scheme functionals.
The subsequent virtual-operator check, production collinear limits and pole-depth
proof fix the one-loop collinear quark-line conversion to zero; the separate
original diagnostic mismatches remain unchanged.

## Invariant measurement and convolution bounds

The independent measure calculation uses `u=exp(eta_J)>0`, a massless jet with
transverse momentum `p_JT`, `P=Q/(2 x_B)(1,0,0,1)`, incoming parton `x P`, and
observed hard parton `p_J/z_J`. It derives

\[
s=Q^2(x/x_B-1),\quad
t=-Q^2-\frac{Qp_{JT}}{z_J}(u-u^{-1}),\quad
w=\frac{x}{x_B}\left(Q^2-\frac{Qp_{JT}}{u z_J}\right)
 -Q^2-\frac{Qp_{JT}}{z_J}(u-u^{-1}).
\]

Positive recoil light-cone components and `w>=0` give

\[
z_{J,\min}=\frac{p_{JT}}{Q}
 \left(\frac1u+\frac{x_Bu}{1-x_B}\right),\qquad
x_{\min}(z_J)=x_B\frac{Q^2z_J+Qp_{JT}(u-u^{-1})}
 {Q^2z_J-Qp_{JT}/u}.
\]

The integrations are `z_J_min <= z_J <= 1` and `x_min(z_J) <= x <= 1` in the
physical region `z_J_min<1`. The invariant flux and observed-state Jacobians
give `dx/x` and `dz_J/z_J^2`. The lepton and jet measures are respectively
`dQ^2 dy dphi_l/[4(2pi)^3]` and
`p_JT dp_JT deta_J dphi_J/[2(2pi)^3]`. Eighteen exact residuals, including the
UU photon-basis conversion, are in `invariant-measures-002/measures.json`.
These measure identities are applied to the completed finite hard coefficients;
they do not independently validate those coefficients. The archived Fhats include `(2pi)^(-4)`; that normalization must
be undone when using a raw current tensor with the displayed phase measures.

## Reproduction and evidence

From `/bigTMD`, a new development reproduction (including the slow partial real
chain) uses one physical command line:

`PYTHONDONTWRITEBYTECODE=1 python3 collins_sidis_highpt/tools/development/reproduce_development.py --reports /bigTMD/collins_support/reports/sidis-highpt-001/reproduction-next --partial-real`

Choose an unused output path. The driver invokes the installed additive
validator for a fresh r00 run, then the focused native diagnostics; all BLAS
and Kira jobs are single-threaded. It deliberately reports development scope.
Removing `--partial-real` replays the current r00 and universal-function checks.
Results and exact row-level comparisons are in the external campaign report
directory. Original failed development logs and available source versions are
retained. The old analytic validator and the accepted ep calculation remain
separate and unchanged.

## Continuation: finite real-only channel and complete real maps

The tagged-antiquark channel is nonzero and finite in `collins_support/reports/sidis-highpt-001/continuation-001/hqqbar-finite-001/hqqbar-finite.wl`. Its 182 new targets reduce to seven compatible cut masters; every endpoint coefficient and IR pole cancels, and no scale logarithm remains at this first hard order. The same production tagged-density routine recovers 72 archived independent D-dimensional UU pair contractions exactly. This validates that normalization check without substituting UU coefficients for UT.

The full qgg map has 97 actual targets, three masters, exact physical cut and closure checks, both open-amplitude gluon Ward identities, and all delta/plus/regular distributions in both branches. A raw transverse reconstruction residual proportional to `Log[B]-Log[w]+Log[w/B]` is retained and proved zero at positive B,w. No source equation or coefficient was changed. A rational Laurent recurrence replaces generic expansion of large rational coefficients, with exact quotient reconstruction and nine completed-prefix overlaps.

The full same-flavor map has 180 targets, completed coefficient collection and both endpoint branches. Finite Hqq, the t=-s boundary and the full measured convolution are implemented and have focused native evidence. Full r00–r07 acceptance is a separate campaign; the observable sources require actual evaluated inputs and do not supply fallback hard coefficients.

## Executed finite open-branch hard assembly

Both Hqq Collins projections now have a finite native hard coefficient on each open branch after all real topologies, UV-renormalized virtual and dimensional PDF/FF subtraction terms are combined. The 16 delta/plus/regular coefficients and 48 zero scale residuals are recorded in continuation-001/hard-summary-001/summary.json. The subsequent native series check establishes all 16 common-boundary limits, and the full symbolic UU/UT convolution and consistently expanded asymmetry are assembled. The two-run/pair/dependency-probe campaign is a separate acceptance requirement. Original operator diagnostic differences and the literal all-D reference mismatch remain visible.


## Current native assembly and exact representation

`tools/pipeline/native_stage_driver.py` connects the actual r01–r07 producing chain. r01
contracts all real topologies and maps their union of 253 targets; the official
runner owns Kira execution and its audit. r02 checks the four reductions and
imports 158 exact scalar coefficients of the required archived real master
Laurent/function basis. r04 contracts and maps 210 virtual targets, with the
explicit additional terminal-export target retained. r05 imports 378 virtual
master coefficients. These are saved integral evaluations, not new integrations.
The parent banks record cuts, measures, coordinates, analytic branches, required
Laurent orders and exact function reconstruction.

r03 retains all six incoming/outgoing collinear components, the dimensional
Born tensor and both MS actions. With the conventional transversity kernel,
the canonical coefficients are delta `3 CF/2`, plus `2 CF`, regular `-2 CF`.
The actual changes of variable are `eta=t/(t-w)` for the PDF and
`zeta=(s-w)/s` for fragmentation, with `deta/eta` and `dzeta/zeta^2`.
The real-only Hqqbar term has no Born MS counterterm. r06 uses the separately
derived large-loop UV residue and principal-branch complex virtual masters.
The nominal and intentionally changed master inputs enter the same formulas.

r07 combines the real and virtual affine recipes, both factorization terms
and the explicit zero finite collinear conversion. Each delta, L0, L1 and
regular coefficient is retained separately for L/T and both open branches.
Pole and independent muR/muPDF/muFF derivative residuals are calculated from
those recipes. All 16 physical common-boundary comparisons are separately
required in each completed campaign run. The symbolic observable keeps the
one-sided limit explicit, alongside its evaluated boundary evidence.

The exact scalar transport separates logarithm/dilogarithm functions and
eligible polynomial color/kinematic powers. Only nominal archived inputs fix
the representation; a dependency probe cannot change its basis or formulas.
Positive-domain log conversions are proved factor by factor. Fixed master
numerator normalizations have explicit dependent certificates; there is no
answer/master ratio. The unchanged decoder limits and precision checks remain
in force. Oversized imported UU sums are partitioned additively with exact
reconstruction residuals. Each fresh UU import must equal all 102 recorded
full hard expressions before that representation is reused.

In terms of `a=alpha_s/(2 Pi)`, the actual symbolic observable uses
`a C0 J0 + a^2(C1 J0+C0 J1)`. Hqq and Hqqbar contribute UT; all six channels
contribute UU. Flavor, charge and tagged-antiquark assignments are explicit.
The common measured prefactor is `e^4 p_JT/[16 S (Q^2)^2 (2 Pi)^6]`, with the
azimuth-averaged density convention of SCOPE. The source retains `dx/x` and
`dz_J/z_J^2`, physical lower limits and all lower-limit plus-distribution terms.
The TMDs are symbolic soft-subtracted inputs at `zeta_J=(p_JT R)^2` with the
pinned Collins Fourier convention. No fit, small-b model or extra soft factor
is inserted. Writing the four convolved coefficients as U0,U1,T0,T1, the
asymmetry is `T0/U0 + a (T1/U0-T0 U1/U0^2)`.

The universal finite jet functions and factorization theorem remain imported
literature ingredients. Their finite distribution coefficients, scale and
rapidity identities are checked independently. The new polarized finite hard
coefficients have extensive internal identities but no independent full NLO
hard reference. The original two operator diagnostic MISMATCH rows and the
historical Hgq MadGraph qualification remain. Current computational agreement
cannot transfer historical acceptance or certify broader physical accuracy.

## Current native scheduling after campaign 001

The initial full workflow timed out at the unchanged 7,200-second r01 limit during the distinct-flavor charge-two map. Its qgg and same-flavor tensors, projections and maps, and all ten distinct-flavor tensors, remain as incomplete-run evidence. No full native acceptance followed from that attempt. The read-only syscall trace identifies the validator termination; the separately surviving Python/Wolfram group was explicitly stopped and recorded.

The current workflow executes the identical qgg tensor and Collins-projection scripts afresh in r00, after Born contraction. New r00 evidence nodes bind the actual tensor/projection outputs and driver log. r01 records their same-run input identities, generates the qgg integral map, and executes the other real topologies and combined Kira job. The collinear checks consume those actual qgg tensors from r00. No cached or archived polarized numerator is substituted, and no counterterm, master definition, reference, tolerance, observable convention or validator is changed by this scheduling adjustment.

The Python driver now owns each native helper group and checks the lifetime of its original stage parent. Parent termination and direct driver signals stop the helper, including a SIGKILL fallback for a child that ignores SIGTERM. This repairs the observed orphan process without editing the shared validator or Wolfram licensing configuration. Native campaign 002 must still complete two fresh full workflows, the exact pair and both real/virtual probe seeds.
