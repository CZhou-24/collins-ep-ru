# Scientific contract and qualifications

**Target:** the complete O(alpha_s) operator matching and assembly of the declared leading-power Collins ep factorization, extending the accepted homogeneous result with an independent two-fraction fragmentation correlator and the finite fragmenting-jet conversion. Born photon exchange is O(alpha_EM^2). This is not the unrestricted real-emission fixed-order cross section over arbitrary recoil or arbitrary hadron transverse momentum.

The ep paper is the observable specification. The pp paper 1707.00913 explicitly uses LO UU/UT hard scattering, NLO TMD coefficients and NLL evolution with a narrow-jet approximation. The additional HF matching in this mission goes beyond its implemented homogeneous phenomenological treatment. Preserve a labelled paper approximation so that this extension does not silently alter a future reproduction target.

## Radius

The accepted code expands the cone geometry and discards R^2 terms. The ep paper uses R=1 and states R~O(1) below A3; nevertheless our exported H, J and S exactly match its written A1–A3. Those facts establish neither a missing coefficient nor a finite-R validity proof. A derivation-versus-paper validity analysis is required, with evidence saved by d18, while the automatic certificate remains qualified. Do not derive arbitrary-R corrections solely to change a status field. If the correct NLO ep measurement requires a structure beyond the frozen scalar quark jet/TMD relation, preserve that result and propose the necessary interface extension; do not project it away to pass.

The scalar d18 relation is the quark fragmenting-jet coefficient **after** intrinsic quark/gluon TMD fragmentation matching and the beam/jet soft allocation, at zeta_J=pT_jet^2 R^2. Its finite remainder is spin independent in this stated operator organization. A proof of that reduction is part of source review, not something the Boolean packet can establish. In particular, the semi-inclusive pp hard function in 1705.08443 cannot simply be transplanted into the small-qT ep formula.

## Operator basis and evolution

Retain the independent imaginary chiral-odd quark-gluon fragmentation matrix element HF as well as Hhat. The precise factors, gauge completion, signs and Fourier conventions must be derived and related to the existing native/KPSY convention. SIDIS defines applicable renormalization conventions; its unpolarized calculation does not define every new transverse-spin or rapidity convention.

At O(alpha_s), the new HF coefficient starts at first order. The evolution of Hhat including the HF term is needed for matching-scale consistency. A separate closed evolution system for all two-fraction twist-three operators would be an additional target; it is not claimed here. No gluon transversity or gluon Collins function is introduced for the polarized proton channel. Existing unpolarized quark/gluon matching remains intact.

Two-fraction kernels must be treated as distributions, including endpoint contact terms. A pointwise comparison away from z1=z does not establish their endpoint extension. The new interface retains these contacts explicitly; see `INTERFACES.md`. Nonperturbative support properties may be used only with a derivation and after displaying the complete operator action.

## Accuracy, inputs and outputs

- Complete native one-loop derivations are required for the new perturbative ingredients. Literal literature equations are comparison targets; their origin must never be relabelled DERIVED simply because they match.
- Standard A2 and beta-function coefficients remain cited EXTERNAL inputs. This mission does not derive two-loop amplitudes or a non-global-logarithm resummation. Track explicit retained coefficients rather than relying on ambiguous uses of “NLL-prime” across papers.
- PDFs, transversity, D1, Hhat and HF remain symbolic matrix elements. No fit or physical provider is required. A numerical integral of a perturbative master or a synthetic test distribution is legitimate verification.
- The all-b factorization uses renormalized TMD operators. Its local small-b OPE must not be extrapolated over all b without a separately identified physical prescription.
- The “paper limit” used for regression is the retained native homogeneous coefficient assembly with the additional finite jet remainder set to zero. It is not an assertion of author-confirmed conventions or of Figure 6 agreement.
- Keep the previous 70 rows and 31-obligation evidence; add the 26 new obligations. Full fixed-order recoil, power corrections, broad organization changes, reverse unitarity and Figure 6 remain outside this implementation.

## Meaning of acceptance

STAGES_PASS records execution, identity and native exports. CHECKS_PASS additionally requires all retained acceptance, new coefficient identities, two-run equality, fresh native reexports, new upstream probes and pair replay. Scientific acceptance requires source review of what produced the coefficients, especially their finite parts, independent routes, endpoint extension and measurement. The automatic report preserves those qualifications even if a later human review accepts the derivations within their scope.
