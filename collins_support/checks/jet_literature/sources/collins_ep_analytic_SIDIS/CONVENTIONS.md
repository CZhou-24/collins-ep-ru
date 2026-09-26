# Conventions for the Collins ep reverse-unitarity route

The pinned SIDIS source is the baseline only where it actually defines the operation. This document states required definitions and explicit conversions before integration; it is not a claim that every integration, boundary argument, or native amplitude binding has been completed. Exact source identities are in `provenance/CONVENTION_SOURCES.json`; actual source reuse is declared separately. No accepted final coefficient export or `reference_values.json` is producing data.

The upstream revision is `5062dcb2407594dafcc2f9f72800e96ff9e6d957`. The accepted comparison pair is `/Collins-ep-analytic-state-v0.4.0/literature-revalidation-001/nlo-pair.json`, verified against the v0.5.1 adoption record. Historical comparison statuses remain historical until a new comparison supplies distinct evidence.

The v0.5.1 measured family has D0=k²−2u k·p, D1=k·n−1 and D2=k²−2k·p+tau, with p·n=1. Only D0 is a physical emitted-gluon cut. D1/D2 are longitudinal/radial measurements. The actual radius satisfies rho−tau=2(k·p)D1−D2; raised cuts therefore use the explicit derivative-distribution transport, not the unit-delta identity alone. Fragmentation uses parent k and observed u p. Beam crossing instead uses emitted l=k−u p, incoming p and active q=p−l, with q²=−tau/(1−u). Independently generated spacelike spin/color traces establish the beam conversion.

Splitting the measured transverse sphere into the physical plane and −2epsilon evanescent dimensions gives its genuine positive Euler density y^(−1−epsilon)(1+y)^(epsilon−1). The protected native evaluator computes the normalized sphere N. Its normalization is exp(gamma_E epsilon)/Gamma(1−epsilon), while its evaluated value is always consumed from the fresh output. Fourier/rapidity operations act analytically on the resulting fixed-radius density. The soft u=0 specialization restores a=k·n>0 with measure da/a=dy. Beam/jet conditional angular weights, cone boundaries and eta cancellation are derived before the epsilon expansion.

For scalar matching the declared physical-J0 operator continuation divides the full transverse Fourier result by Gamma(1−epsilon)Gamma(1+epsilon), for both rank zero and rank one. It is distinct from replacing a full-dimensional tensor angular average by a physical average. The generating beam trace has an epsilon-squared angular difference and hence no finite one-loop shift after its single radial pole. HF requires its own full-dimensional trace and rank-one Fourier/Beta argument; its separate executable proof is retained. No all-epsilon or higher-order equality follows from a vanishing finite one-loop difference.

Comparison log names are explicit dummy-variable conversions: LQ→L for log(mu²/Q²), and the dedicated HF log B is Bh=log(mu² bh² exp(2gamma_E)/4). Jet comparison constituents use the derived shifted standard-soft argument Vstandard=V−g=0. These substitutions re-contract the same native master, rather than adjusting an evaluated coefficient.

## D_algebra

**Pinned baseline.** SIDIS/common/s02_definitions.wl: Dimension D; s08_cut_master_inputs.wl and s20_final_hats.wl: D=4-2 eps. No polarized gamma5 prescription is defined there.

**Collins definition.** Keep D=4-2 eps in internal unresolved algebra. Physical external spin and Levi-Civita have four dimensions (two transverse components); accepted Collins LoadFC fixes BMHV. Retain evanescent numerator terms through the required regulator order.

**Explicit conversion and scope.** No epsilon-sign conversion. The physical external spin plane is a Collins extension. Contract internal D tensors before external spin projection; finite terms from O(eps) numerators times poles cannot be dropped.

Sources: `SIDIS/common/s02_definitions.wl`, `SIDIS/common/s08_cut_master_inputs.wl`, `collins_ep_analytic/common/s02_definitions.wl`, `collins_ep_analytic/common/physics_helpers.wl`.

## metric_and_routing

**Pinned baseline.** SIDIS/common/s02_definitions.wl: p^2=k1^2=0, q^2=-Q2, sSIDIS=(p+q)^2, tSIDIS=(q-k1)^2, recoil=p+q-k1, recoil^2=w.

**Collins definition.** Use metric diag(1,-1,-1,-1), q=l-lprime, epS=(l+p)^2, epT=q^2=-Q2, epU=(p-lprime)^2. Elastic epS+epT+epU=0; tagged real radiation requires its additional scalar products.

**Explicit conversion and scope.** sSIDIS=epS+epT+epU, tSIDIS=epT-2(l-lprime).k1, uSIDIS=-2p.k1; sSIDIS+tSIDIS+uSIDIS=-Q2+w. Elastic photon invariants are (0,0,-Q2). Do not identify the SIDIS photon-parton names s,t,u with electron-parton invariants.

Sources: `SIDIS/common/s02_definitions.wl`, `collins_ep_analytic/common/d14_convention_library.wl`, `collins_ep_analytic/common/physics_helpers.wl`.

## spin_and_color_averaging

**Pinned baseline.** SIDIS/common/s05_virtual_families.wl contract uses FermionSpinSum ExtraFactor=initialAverage. Read-only SIDIS/Hqq/s01_result/s01_inputs/s02_born_and_projectors.wl derives quark states=2 Nc, gluon states=(D-2)(Nc^2-1); photon is an open current.

**Collins definition.** The unpolarized incoming electron contributes a further 1/2. eq average is 1/(4Nc); eg is 1/[2(D-2)(Nc^2-1)]. Polarized quark dependence is extracted coherently from density slash(p)(1+gamma5 slash(S))/2 and outgoing analyzer, with the same declared normalization.

**Explicit conversion and scope.** For Nc=3,D=4 the eq and eg averages are 1/12 and 1/32. Do not add a photon polarization average. Native amplitude checks exclude flux and phase space and retain complex helicity interference for UT.

Sources: `SIDIS/common/s05_virtual_families.wl`, `SIDIS/Hqq/s01_result/s01_inputs/s02_born_and_projectors.wl`, `collins_ep_analytic/common/s03_born.wl`, `collins_ep_analytic/common/d14_convention_library.wl`.

## coupling_powers

**Pinned baseline.** SIDIS/common/s05_virtual_families.wl explicitly strips model charge and eq^2 gs^4 for photon-parton virtual interference; s20_final_hats.wl restores gs^2=4 Pi alphaS. These are original photon-parton channels.

**Collins definition.** e^2=4 Pi alphaEM, gs^2=4 Pi alphaS. Elastic ep has two QED vertices: squared coupling (4 Pi alphaEM)^2 eq^2; real gluon emission adds 4 Pi alphaS. Define a=alphaS/(2Pi); an amplitude expansion in alphaS/(4Pi) must be converted before interference.

**Explicit conversion and scope.** Contract the open hadronic current with (e^2/Q^4) times spin-averaged lepton tensor. One-loop amplitude plus its conjugate gives 2 Re; account for this before a conversion. Preserve the literal EP alpha*alpha_s versus derived alphaEM^2 discrepancy.

Sources: `SIDIS/common/s05_virtual_families.wl`, `SIDIS/common/s20_final_hats.wl`, `collins_ep_analytic/common/s03_born.wl`, `collins_ep_analytic/common/d14_convention_library.wl`.

## loop_measure

**Pinned baseline.** SIDIS/common/s12_virtual_master_inputs.wl uses FCFeynmanParametrize FeynmanIntegralPrefactor="Unity": unnormalized Minkowski d^D ell. s05 and s19 multiply mu^(2eps)/(2Pi)^(4-2eps) in interference assembly.

**Collins definition.** Keep this raw master convention for the migrated virtual route. Track i pi^(D/2), (2Pi)^(-D), mu^(2eps) and the actual amplitude i factors explicitly. The accepted comparison basis uses d^D ell/(i pi^(D/2)) with exp(EulerGamma eps) (mu^2)^eps.

**Explicit conversion and scope.** For an identical routed integrand Iraw=Integrate[d^D ell integrand] and Ibar=Iraw/[i pi^(D/2)]: mu^(2eps) Iraw/(2Pi)^D = i mu^(2eps) Ibar/(4Pi)^(D/2). To reach e^(gammaE eps) mu_bar^(2eps) Ibar multiply/divide the recorded normalization and convert mu_bare^2=mu_bar^2 e^(gammaE)/(4Pi) where this convention is chosen. Never remove the physical i0/phase with a real-only substitution.

Sources: `SIDIS/common/s12_virtual_master_inputs.wl`, `SIDIS/common/s05_virtual_families.wl`, `SIDIS/common/s19_assemble_virtual.wl`, `collins_ep_analytic/common/s02_definitions.wl`.

## phase_space_measure

**Pinned baseline.** SIDIS/common/s08_cut_master_inputs.wl derives positive-energy cuts from their Jacobian and sphere area. s20_final_hats.wl: stateNormalization=(2Pi)^D Product[(2Pi)^(-(D-1)),cutMomenta].

**Collins definition.** dPhi_n=(2Pi)^D delta^D(P-sum k_i) Product[d^D k_i delta_+(k_i^2)/(2Pi)^(D-1)], delta_+(k^2)=theta(k0)delta(k^2). Flux for massless incoming ep is 1/(2 epS). Measurement deltas are separate from physical on-shell cuts.

**Explicit conversion and scope.** For two massless cuts and P^2=w>0, the raw cut measure is w^(D/2-2)/2^(D-1) times the solid-angle integral; at D=4 it is pi/2. Multiplying (2Pi)^(2-D) gives the standard integrated two-body phase space 1/(8Pi). No old F-hat hard-normalization factor may be multiplied into an already complete exclusive ep phase space.

Sources: `SIDIS/common/s08_cut_master_inputs.wl`, `SIDIS/common/s20_final_hats.wl`, `collins_ep_analytic/common/d15_physical_factors.wl`.

## MSbar

**Pinned baseline.** SIDIS/common/s14_uv_residues.wl explicitly defines MSPole=1/eps-EulerGamma+Log[4Pi]. No C11 TMD operator scheme is defined by the inclusive SIDIS workflow.

**Collins definition.** Use standard MSbar and distinguish epsUV from epsIR until scaleless UV/IR bookkeeping is complete. The native accepted Collins basis also uses standard MSbar; C11 is an explicit comparison-side finite operator conversion.

**Explicit conversion and scope.** A scaleless integral is 0 only after identifying epsUV=epsIR; it can carry c(1/epsUV-1/epsIR). The C11/additive-MSbar ratio is exp(gammaE eps)/Gamma(1-eps)=1-pi^2 eps^2/12+O(eps^3). Apply it to the freshly derived additive counterterm, not to an invented finite shift.

Sources: `SIDIS/common/s14_uv_residues.wl`, `SIDIS/common/s19_assemble_virtual.wl`, `collins_ep_analytic/common/d14_regulated_scheme_library.wl`.

## positive_energy_cuts

**Pinned baseline.** SIDIS/common/s02_definitions.wl stores energy[r]>0 and energy[recoil-r]>0; s08 independently solves both cuts and selects the unique positive-energy root for w>0.

**Collins definition.** For a real scalar x, delta(x)=[1/(x-i0)-1/(x+i0)]/(2Pi i). Thus delta_+(k^2-m^2)=theta(k0) times this discontinuity. Each declared physical cut retains this orientation and positive-energy support; measurement deltas and theta boundaries are separately documented.

**Explicit conversion and scope.** The method paper hep-ph/0207004v3 Eq17 prints the opposite discontinuity ordering. Retain its literal equation unchanged and display this orientation difference explicitly. Positive cut indices in Kira enforce algebraic cut survival; they do not prove physical support or absence of measurement boundary terms.

Sources: `SIDIS/common/s02_definitions.wl`, `SIDIS/common/s08_cut_master_inputs.wl`.

## i0

**Pinned baseline.** SIDIS/common/s12_virtual_master_inputs.wl constructs Euclidean chord parameters; s19_assemble_virtual.wl performs the physical continuation and preserves phases before Hermitian interference.

**Collins definition.** Uncut Feynman denominators use +i0. Physical cuts are the declared difference of opposite prescriptions; future-pointing Wilson-line/eikonal denominators retain their own ray orientation and common damping regulator.

**Explicit conversion and scope.** For a timelike invariant s>0, Log(-s-i0)=Log(s)-i Pi; (-s-i0)^lambda=s^lambda Exp(-i Pi lambda). The h.c./2 in the HF operator is Re of the same complex projected cut, with conjugated ray prescriptions. Do not replace all denominators by absolute values or count an additional mirror twice.

Sources: `SIDIS/common/s12_virtual_master_inputs.wl`, `SIDIS/common/s19_assemble_virtual.wl`, `collins_ep_analytic/common/d17_endpoint_completion.wl`, `collins_ep_analytic/common/d16_projection_normalization.wl`.

## endpoint_intervals

**Pinned baseline.** SIDIS/common/s17_assemble_real.wl: Ln=[Log(w/B)^n/w]_+ on [0,B]. s15 derives endpoint regions from actual cut-master input.

**Collins definition.** Define Collins diagonal plus distributions on [0,1] by integral [f(x)]_+ phi(x)=integral f(x)(phi(x)-phi(1)); keep delta, plus and regular pieces separately. HF variables u=zh/z and v=z/z1 have zh<=u<=1,0<v<1.

**Explicit conversion and scope.** For w=B(1-x), the pushforward of Ln with dw is [Log(1-x)^n/(1-x)]_+ dx with test phi(B(1-x)); delta(w)dw maps to delta(1-x)dx. w^(-1-k eps)=-B^(-k eps)delta(w)/(k eps)+B^(-k eps)sum_n(-k eps)^n Ln/n!. HF generic c0 Phi(u,1)-c1 d_v Phi(u,1) remains unresolved; the physical class additionally needs |Phi|<=C(u)(1-v)^(1+alpha),alpha>0, both boundary zeros, and uniform joint-endpoint/regulator control.

Sources: `SIDIS/common/s17_assemble_real.wl`, `SIDIS/common/s15_cut_soft_regions.wl`, `collins_ep_analytic/common/d17_endpoint_completion.wl`, `collins_ep_analytic/common/d16_spectral_support.wl`.

## transverse_projectors

**Pinned baseline.** No transverse-spin, gamma5, epsilon-plane or Collins projector is defined in pinned unpolarized SIDIS.

**Collins definition.** Accepted Collins physical bases: N is beam cross jet, Xi=N cross beam, Xo=N cross jet, epsilon0123 upper=+1, epsilon12=+1. The analyzer is (-j_y,j_x), giving sy*hx-sx*hy=sin(phiS-phiH). Use physical BMHV external projectors with full D-dimensional unresolved numerator.

**Explicit conversion and scope.** This is a declared polarized extension. Reusing the same current/projector reduces independence to the integration route. A new or modified amplitude/spin adapter needs a direct check against its new outputs including coherent helicity interference; old MadGraph counts do not provide that binding.

Sources: `collins_ep_analytic/common/s02_definitions.wl`, `collins_ep_analytic/common/physics_helpers.wl`, `collins_ep_analytic/common/d15_physical_factors.wl`, `collins_ep_analytic/common/d13_projection_derivation.wl`.

## Collins_moment

**Pinned baseline.** No Collins fragmentation matrix element, hadron-mass factor or moment is defined in pinned unpolarized SIDIS.

**Collins definition.** Define HC=-HTrento/z, Hhat3(z)=integral d2p p^2 HC(z,p^2)/Mh, and HTrento^(1)=integral d2p p^2 HTrento/(2z^2 Mh^2). The physical first transverse moment gives vector coefficient -i b^alpha Hhat3/(2z).

**Explicit conversion and scope.** Hhat3=-2z Mh HTrento^(1). Accepted native and Kang raw cut-matrix conventions B/z versus B/(2z) give both HhatNative/HhatKang=2 and HFNative/HFKang=2: the relative mixing-basis factor is one. This definition-level conversion does not silently fix printed upper-index/Wilson-link conventions or the literal CA-kernel discrepancy. EP-to-Trento identification remains explicitly conditional.

Sources: `collins_ep_analytic/common/d14_convention_library.wl`, `collins_ep_analytic/common/d16_projection_normalization.wl`.

## Fourier_and_z

**Pinned baseline.** No TMD Fourier transform is defined in pinned inclusive SIDIS.

**Collins definition.** Fragmentation forward phase exp(-i p.b/z), inverse z^(-2) d2b/(2Pi)^2 exp(+i p.b/z). Beam uses its own bq phase without fragmentation z. Physical observed transverse plane has two components.

**Explicit conversion and scope.** The coordinate Jacobian is z^-2. Rank-zero radial measure is b db J0/(2Pi z^2); with -i b Hhat3/(2z) the rank-one radial measure is b^2 db J1/(4Pi z^3). The full dT versus accepted physical-J0 continuation ratio is Gamma(1-eps)Gamma(1+eps); divide both scalar and vector by that same b-independent ratio after its actual derivation. This Fourier operation may remain analytic outside Kira only when its connection to newly evaluated cut masters is proved; the old radial route cannot be renamed reverse unitarity.

Sources: `collins_ep_analytic/common/d14_convention_library.wl`, `collins_ep_analytic/common/d14_regulated_scheme_library.wl`, `collins_ep_analytic/common/d13_collins_derivation.wl`.

## rapidity_subtraction

**Pinned baseline.** Pinned inclusive SIDIS has dimensional collinear/soft endpoints, but no TMD rapidity regulator, Collins-Soper scale, or standard-soft square-root subtraction.

**Collins definition.** Collins extension uses eta before eps, future staples, and one standard-soft square root. V=ln(mu^2/nu^2), T=ln(mu^2/zeta), g=ln[R^2/(4cosh(Y)^2)], zetaJ=zeta0 exp(g). Keep nu regulator scale and zeta physical rapidity scale distinct.

**Explicit conversion and scope.** Conventions d/dln(mu^2),d/dln(zeta) imply a factor 1/2 from a kernel defined with d/dln(sqrt(zeta)). A finite separator shift chi=ln(zetaNew/zetaOld) is derived as a native eikonal shell and the opposite residual domain; arbitrary compensating finite polynomials are not a derivation. Eta cancellation must occur at fixed eps before expanding eps.

Sources: `collins_ep_analytic/common/d14_regulated_scheme_library.wl`, `collins_ep_analytic/common/d15_physical_factors.wl`.

## finite_scheme_allocation

**Pinned baseline.** SIDIS/common/s17,s19,s20 separate real/virtual/UV/collinear pieces and check poles before finite export; photon F1/F2 hats do not define Collins TMD finite matching.

**Collins definition.** Assemble the actual native beam, fragmentation/HF, residual soft and hard factors at strict O(a), a=alphaS/(2Pi). Fragmenting jet replaces the inclusive jet; no inclusive-J times fragmenting-G product. Intrinsic matching, overlap and common allocations precede any claim of zero additional jet remainder.

**Explicit conversion and scope.** UU=UU0+a UU1 and UT=UT0+a UT1; A=UT0/UU0+a(UT1/UU0-UT0 UU1/UU0^2). Scheme-converted factors must retain full-product compensation. The accepted physical HF zero contacts are representative choices on the qualified physical class, not generic distribution identities. R=1, unrestricted nonsingular NLO, closed twist-three evolution and Figure6 remain uncertified.

Sources: `SIDIS/common/s17_assemble_real.wl`, `SIDIS/common/s19_assemble_virtual.wl`, `SIDIS/common/s20_final_hats.wl`, `collins_ep_analytic/common/d18_jet_derivation.wl`, `collins_ep_analytic/common/d19_assembly_library.wl`.

## Integration and measurement review gates

Every cut family must distinguish physical on-shell delta functions, measurement delta functions, theta-domain restrictions and the i0 prescriptions of uncut and Wilson-line propagators. Ordinary IBP on an integrand multiplied by a measurement/regulator differentiates that weight as well: boundary terms or a justified tangent IBP must be included. Positive master indices alone do not prove that this step is valid. A Fourier or rapidity manipulation outside the rational family is permitted only with an explicit map from the new cut result and its measure; it cannot supply a disconnected physical answer.

The original s08 unit-index/Euler classes have limited denominator geometry. New classes, raised cuts or linear measurement constraints require their own derivation and native capability check. Do not force them into the old two-cut scalar inventory. The first nonzero quark pilot must show its actual numerator, Kira target/rules, unevaluated Euler tuple, SubTropica output and distribution/finite assembly.

The method reference is pinned as hep-ph/0207004v3. Its Eq. (17) and Eq. (42) are retained literally under the separate review reference directory. The printed discontinuity orientation in Eq. (17) and shifted powers/variable in Eq. (42) are documented separately from the independently established distribution identities; no paper text is silently corrected.

The NLO HF virtual zero requires a whole-branch translation/Wilson-line proof, not a claim of separately integrated individual zero loops. The extra finite jet remainder may vanish only after its explicit bare, overlap, intrinsic and common allocations. Neither statement extends the accepted leading-power/narrow-cone or physical endpoint scope.
