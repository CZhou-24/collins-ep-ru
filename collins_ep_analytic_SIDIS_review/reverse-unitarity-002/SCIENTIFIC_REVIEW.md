# Scientific source review, v0.5.1

The new route supplies the declared Born/one-loop leading-power coefficients and strict first-order symbolic observable in the accepted narrow-cone and physical HF endpoint scope. The final milestone separates source generation, actual native execution, automated acceptance and qualified scientific conclusions. Agreement with the accepted scalar exports does not establish every paper equation or a physical prediction.

The frozen-source review is bound by `audit/SOURCE_FREEZE_001.json`. The first final native chain is `/Collins-ep-analytic-state-v0.5.1/runs/20260914T181858Z-de31606fa32d`; the second run and official seed reports are recorded in `audit/FINAL_ACCEPTANCE.json`. All references below to rNN refer to that run's `common/rNN_result`, unless a diagnostic path is explicit. `SECTOR_COMPLETION.md` and `.json` give the full per-sector matrix. The following review covers the nine requirements of the unchanged validator's `docs/SCIENTIFIC_REVIEW.md`.

## 1. Generating operators, cuts and dimensional numerators

r00 regenerates the FeynArts Born/real amplitudes and evaluates the open spin/color algebra with the installed FeynCalc/BMHV runtime. It preserves the two physical transverse external spin directions while retaining D=4−2epsilon internal algebra. The Born hard factors are stripped of their separately documented common electromagnetic/flux factors. Its regenerated unchanged amplitude outputs have an exact source/output/retained-evidence binding; new operator projections require their own direct checks.

The beam and fragmentation traces are separate. The beam uses incoming p, emitted l=k−u p and active q=p−l=(1+u)p−k, so q²=−tau/(1−u); it is not an unannounced timelike substitution. The qq, qg and transverse-spin numerators are freshly contracted with their appropriate D-dimensional spin/color averages. The fragmentation gq crossing and diagonal Collins derivative/intrinsic-EOM cut sum have explicit separate normalizations. The Collins kernel is obtained from that cut sum and its gauge contact, rather than copied from transversity.

The newly retained common virtual operator contains actual left/right Wilson-sail matrix integrands and the generated D-dimensional even/odd self-energy numerator. Its cancellation is equality of the same complete operator before subtraction. This is not evidence for two separate virtual integrations. The soft Wilson current has physical beam/jet directions, zero hat contraction, and an explicit normalized square. These source-level identities fix the common local endpoint allocation used by matching.

HF regenerates three q→qgg skeletons, ordered QCD/Wilson emissions and the Wilson three-gluon term. The coherent F index and external transversity tensor are physical, while internal metrics and hat-gamma crossings remain D-dimensional. Both cut placements are independently contracted: the reversed-chain Clifford computation is compared with the new FeynCalc density, including terms that multiply poles. Emitted/coherent Ward tests apply to each ordered color branch, and the finite-damping parent inverse-propagator remainder is retained before the physical endpoint limit. See `audit/hf-route-review-002/HF_ROUTE_REVIEW.md` and the supporting numerical report.

The full-D HF continuation uses the actual current with GSD/FVD momentum dependence. Its rank-one Fourier phase is applied before the evanescent angular average. The generated density difference starts at epsilon²,

```
−epsilon² (1−u)² [CA−2CF+2CF v]/(1−v)²,
```

so its finite one-loop shift after the single radial pole is zero on the uniform physical endpoint class. The beam transverse-spin difference is CF epsilon²(z−1)/(1−epsilon), also with zero finite one-loop shift and zero endpoint residue. These are finite-order results in the explicit physical-J0 continuation; no all-epsilon or higher-order equivalence is asserted. The earlier invalid square-root-branch diagnostic and naive angle-average-first result remain marked as superseded.

## 2. Physical support, cut orientation and boundary terms

For real x the adopted delta is `[1/(x−i0)−1/(x+i0)]/(2 pi i)`. A physical emitted massless state additionally carries theta(l0). The reverse-unitarity method paper prints the opposite ordering in its Eq. (17); that reference is retained literally, and the conversion is separate. Positive integral indices do not by themselves establish positive-energy support.

The measured family uses p²=n²=0, p·n=1, alpha=k·n, beta=k·p and K=k²:

```
D0 = K − 2u beta        physical gluon l=k−u p
D1 = alpha − 1         longitudinal measurement
D2 = K − 2beta + tau   transverse-radius proxy measurement
rho − tau = 2beta D1 − D2,  rho = 2alpha beta − K.
```

Only D0 denotes a positive-energy final particle. Coherent operator legs and measurement deltas are distinct. On the physical interior, 0<u<1, 0<v<1, tau>0, the cuts give alpha=1, beta=tau/[2(1−u)], K=u tau/(1−u), with Jacobian 1/[2(1−u)]. The longitudinal fractions remain independent through the relevant distribution/Fourier operations. The retained two-cut quark moment separately integrates its fraction; it is explicitly not the fixed-z TMD coefficient.

Raised measurement cuts use the generated derivative-distribution map. For normalized cuts C_a(D)=(-1)^(a−1)delta^(a−1)(D)/(a−1)!, the map for C_a(D1)C_b(rho−tau) retains the sum of powers (2beta)^j multiplying higher D2 cuts. Beta remains an off-cut coefficient while deriving the action. Its on-surface replacement is not made before differentiating. The actual implementation checks 32 polynomial actions; changes of smooth numerator lift vanish for unit cuts but are propagated consistently for raised-cut relations.

The physical scalar coefficient uses M111. The additional raised targets check the same family's derivative relations; they are not artificial observable contributions. The measured support/theta weights lie outside integer-index Kira operations wherever differentiation would generate a boundary term. Cone theta derivatives explicitly retain their nonzero surface contribution, canceled by the corresponding bulk derivative. Eikonal angular, Fourier and noninteger rapidity operations are calculated analytically with their own domains. No ordinary IBP is used to discard a cone boundary or physical endpoint contact.

## 3. Nonzero UU chain: actual cut → reduction → master → matching → observable

1. r00 `measured_tmd_operators.wl` contains the independently generated beam and final-state kernels. For example the final quark density is CF[(1+z²)/(1−z)−epsilon(1−z)], with the initial-state result separately generated and normalized. This is a derived numerator, not a comparison input.
2. r01 `measured_integrands.wl` records the actual sector numerators multiplying M111 and the true cut geometry. `jobs/measured/targets`, YAML, Kira raw rules, master inventory and native reduction audit are preserved. M111 is the sole scalar master; its implicit identity is part of the complete audited map. r03 consumes the recorded mapped numerator and the actual contracted M111 rule.
3. r02 derives the remaining measured transverse angular integral by splitting two physical and −2epsilon evanescent dimensions. With tHat=y/(1+y), the positive Euler density is `y^(−1−epsilon)(1+y)^(epsilon−1)`. Its prefactor exp(gamma_E epsilon)/Gamma(−epsilon) and physical cut Jacobian fix the sphere normalization. The protected SubTropica evaluator generates N=1−pi² epsilon²/12 through order two in the final native output. This N is a geometric integral of the cut family, not a dummy factor wrapped around an old radial answer.
4. r03 `measured_coefficients.wl` consumes that actual N through `r03/measured_normalization`. The analytic Fourier ratio to the normalized sphere is `−exp[epsilon(B−2gamma_E)] Gamma(1−epsilon)/(epsilon Gamma(1+epsilon))`, with the fragmentation z^(−2epsilon) scale explicitly retained. These transforms are freshly evaluated from their integral definitions and are connected to the fixed-radius measure. The old evaluated radial library is not loaded.
5. At fixed noninteger epsilon, the eta residues cancel against the standard-soft allocation. Local collinear/UV terms remain separate and use the independently defined local sphere residues N0=1,N1=0. The delta, D0, D1 and regular pieces are retained. The explicit C11 normalization acts on the additive counterterm; the canonical qq regular coefficient includes the generated epsilon numerator and the 2 log(z) splitting term. Delta/plus terms are compared independently.
6. r07 binds the full-scale kernels to symbolic PDF/FF convolutions and the canonical coefficients to comparison exports. Lower-limit plus actions include their log(1−x) and log²(1−x)/2 tails and the 1/xi Jacobian. The strict O(alpha_s) UU product consumes the same actual hard/recoil/jet nodes. Its Fourier integrals are applied after this common linear assembly.

The scalar normalization is shared across sectors because the fixed measurements leave one common angular master. This is an economy of the real geometry, not eleven independent integral evaluations. Fixed-recipe dependency checks mutate the actual native master and the complete Kira map in disposable runs; the physical counterterms are not adjusted to erase the probe response. Diagnostic uncancelled poles are retained.

## 4. Nonzero Collins/HF chain, virtual zero and endpoint class

r00 `hf/operator.wl`, `generated_graphs.wl`, `gauge_completion.wl`, `primary_cut.wl`, `independent_cut.wl`, `regulated_cut.wl`, `regulated_endpoint_action.wl`, `virtual_completion.wl`, `angular_continuation.wl` and `generated_density.wl` form the generating evidence. The operator inverse projection, native/Kang normalization, h.c./2 prescription and both cut placements remain separate factors. r01 carries the actual generated two-fraction density and derivative-measurement map to M111. r02 evaluates its genuine fixed-radius sphere; r03 contracts the actual map and master with the new Fourier/Mellin transform. The independent fractions u and v, inverse-fraction PV measure, u^(−2epsilon) scale and dedicated logarithm B remain explicit. In the physical observable, B=Bh is a documented dummy-variable conversion.

The complete future-Wilson translation/Taylor identity makes the rank-one no-additional-state virtual branch zero. Its generated 37-current inventory is retained. This is a zero of the whole branch, including separate UV/IR numerators and epsilon terms, not the assertion that each loop integral vanishes independently. The genuine tree HF zero also prevents an order-one soft factor from manufacturing a one-loop HF contribution.

The endpoint action assumes Phi(u,1)=d_v Phi(u,1)=0 and a uniform bound `|Phi(u,1−x)| <= C(u)x^(1+alpha)`, alpha>0, or the stated Dini alternative. Joint u/v domination and lower-fraction integrability are additional hypotheses. Two pointwise zeros alone are insufficient. The newly generated joint numerator supplies the required endpoint estimates. Zero delta/derivative coefficients exported in the physical comparison are representatives on this class; generic contacts remain UNVERIFIED.

r03 retains bare, collinear, epsilon, finite, independent and mixing nodes with delta/plus/regular and contact entries. r07 inserts the off-diagonal HF action once in the small-b Collins expansion, with its derivative-contact sign and the correct two-fraction measure. The already complete all-b Collins operator is not given a second HF term. The strict UT coefficient and formal asymmetry use those same native values. The literal Yuan–Zhou/Kang CA discrepancy and operator-definition qualifications remain unchanged; agreement with the accepted generated kernel does not repair the printed equation.

## 5. Hard, rapidity, soft, matching and scheme allocation

The ordinary r04-r06 route generates its own current/self-energy numerator, reduces the rational integral with actual Kira rules and evaluates the corresponding ordinary Euler master with protected SubTropica. It preserves the raw loop measure, spacelike continuation and amplitude/interference factors. The large-loop angular UV projection and local self-field UV/IR split establish the current allocation before identifying regulators. The additional comparison node substitutes LQ→L inside the same master contraction and local IR operator; it is not a fitted finite shift.

The soft r00 current gives the actual conditional angular weight and positive-energy rapidity measure. The generated beam/jet geometry, conditional Gamma factor and rapidity shift feed r03's analytic transforms. The global/standard eta residues and the in-jet/shifted-standard finite eta part cancel at fixed epsilon before epsilon expansion. Cone boundary bulk and surface are displayed separately. Bare global, standard, in-jet and out-of-jet collinear-soft factors remain available. Their recoil combination gives the finite coefficient CF[Bq r−r²/2+2Bq Y], with local UV subtraction explicitly recorded.

Matching keeps the physical versus C11 finite operator convention separate. The scalar/rank-one physical Fourier continuation and finite operator conversion are definitions with an explicit algebraic map. Poles times epsilon numerators and the measured sphere's epsilon² term are retained to the needed depth. Independent test-function convolutions supplement the coefficient-by-coefficient distribution checks. Review-only derivatives of the native matching/hard/soft expressions establish specified anomalous-dimension/rapidity/integrability identities, with all derivative conventions stated; they are not separate engine evolution-generating stages.

## 6. Jet replacement and scope

The identified-hadron fragmenting-jet operator replaces the inclusive jet. The implementation does not multiply both into the observable. The joint small-qT/small-jT region excludes a hard out-of-jet or hard boundary split away from its soft endpoints; those soft endpoints are retained in their actual regulated allocation. Common virtual/intrinsic operators cancel before the residual is formed. The nonzero in-jet bare term equals the standard-soft overlap with its derived V→V−g shift, so the extra finite remainder vanishes in this scope.

Five jet comparison labels are aliases/consequences of this common cancellation, not five independent integrations. Both nonzero constituents are retained. This result requires the joint leading-power and narrow-cone approximation and does not establish R=1 or omitted nonsingular NLO terms. The pp hard factors are not ep references.

## 7. Formal observable, signs and powers

The expansion is a=alpha_s/(2pi), UU=UU0+a UU1 and UT=UT0+a UT1. The asymmetry coefficient is UT1/UU0−UT0 UU1/UU0² after the same linear flavor/Fourier operations. No pointwise cancellation of distinct b-space convolutions is used to infer a physical asymmetry.

The stated forward phase and inverse Jacobian give rank-zero `b db J0/(2pi z²)` and rank-one `b² db J1/(4pi z³)` with the first transverse moment `−i b^alpha Hhat3/(2z)`. The native/Trento sign and hadron mass conversion are shown separately, together with the physical spin-analyzer basis. Common flavor charges, electromagnetic prefactors and phase-space normalization remain outside the stripped polynomial. The historical printed electromagnetic discrepancy is not removed. PDFs, FFs and nonperturbative functions stay symbolic.

## 8. Direct and retained numerical evidence

The supporting numerical PDF distinguishes exact output/source rebinding of unchanged amplitudes to the retained MadGraph/complex-helicity evidence from new direct spacelike, diagonal Collins and HF algebra/current checks. Independent Clifford conjugate-cut and regulated complex-current checks apply to the exact newly generated HF outputs. They are not described as a new MadGraph HF process. New operator coverage and its limitations are listed row by row.

The software selftest, repaired regression receipt, inclusive pilot check, ordinary virtual dependency diagnostic, measured test-function checks, final native packet/master replay and official complete-map/master probes have separate evidence identities. Floating-point residuals and tolerances remain numerical evidence, not symbolic equality. Previously reported totals are not substitutes for rerun inputs and their current bindings.

## 9. Literature and preservation

The analytical PDF retains all 85 historical equation groups, with the original counts 14 EXACT, 35 EXACT AFTER EXPLICIT CONVERSION, 4 MISMATCH and 32 UNVERIFIED. New-route versus old-engine results and new-route versus printed-paper results are separate columns/counts. Original source snippets and macros are preserved; explicit conversions do not alter reference equations. Electromagnetic-prefactor, printed Sudakov and literal CA-kernel discrepancies remain visible. The reverse-unitarity method's suspected Eq. (42) typo is displayed unchanged with a separate distribution derivation.

The old review, old state, accepted sources and both validators are compared byte-for-byte/file-for-file against the pre-edit preservation inventory. Official checks separately bind the runtime and original SIDIS source state. The archive contains all new sources/snapshots, new-state inputs/results, development failures, final reports and human-review evidence, preserving symbolic links. Unchanged old bundles and native installations remain explicitly external dependencies. See `LIMITATIONS.md` and `PACKAGE_README.md`.
