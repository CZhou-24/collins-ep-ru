# Breit-frame high-pT Collins hadron in jet

This is the definition of the new calculation, not a certificate of its completion.
Completion and gaps are tracked in `COMPLETION_INVENTORY.md`. The existing electron–jet
back-to-back calculation has a different measurement and is preserved separately.

## Measurement and power counting

The incoming electron is unpolarized. The proton has transverse spin. Work in the
Breit frame, neglect proton/parton masses in the hard scattering, with metric
`(+---)`, `q=(0,0,0,-Q)`, and proton along positive z. A semi-inclusive anti-kT jet
uses the usual rapidity–azimuth distance and four-vector E-scheme recombination.
Its standard axis is its momentum direction; no veto is imposed on additional jets.
The measured hard transverse momentum is the jet momentum transverse to the
photon–proton axis, not a small electron–jet imbalance. The unpolarized hadron has
light-cone fraction `z_h = p_h^-/p_J^-` and transverse vector `j_T` about this axis.

The factorization being implemented is the leading-power small-radius,
`j_T << p_JT R << p_JT ~ Q`, description, with `p_JT R >> Lambda_QCD`.
`R` stays symbolic. The reason for the narrow-jet expansion is the universal
semi-inclusive TMD fragmenting-jet factorization of arXiv:2311.00672v2, Sec. 3.1,
including its standard-axis recoil and in/out-of-jet matching. This does not
describe arbitrary R or the region `j_T ~ p_JT R`; power corrections in R and
`j_T/(p_JT R)` are outside that theorem. Hard endpoints are treated as
distributions, not discarded. Numerical PDFs, Collins fits, and Figure 6 are
outside this assignment.

The jet azimuth relative to the lepton plane, `phi_J`, is distinct from both the
proton spin azimuth about the proton axis and the hadron azimuth about the jet.
The production tensor retains a complete photon basis. The implemented Born
angular extraction defines the Collins Fourier coefficient by
`2 <sin(phi_S-phi_h) W_UT>_(phi,phi_S,phi_h)`, where `phi=-phi_J` is the
lepton-plane azimuth in production-plane coordinates and all three coefficient-
defining angles are independently averaged on `[0,2 pi]`. After extracting
`j_T/(z_h M_h)`, this is `<(T_11+T_22)/2>_phi`. This coefficient definition
selects the named Collins spin-transfer harmonic, while the full resolved Born
tensor is also exported. It is not equivalent to integrating jet azimuth with
a fixed laboratory spin angle and silently treating `phi_S` as independent;
that experimental integration can mix other harmonics. The saved UU F1/F2 can
supply the azimuth-averaged inclusive denominator, but are not evidence for
all resolved-azimuth UU coefficients. The continuation implements this named finite NLO moment. Its native acceptance
status is recorded externally in the continuation campaign report. A full
resolved-azimuth NLO prediction is not supplied by this moment.

## Born coordinates and spin convention

Use `r=s/Q^2 > 0`, `z=(Q^2+s+t)/(Q^2+s)` with `0<z<1`, and positive
`h=sqrt(r z (1-z))`. This Born invariant z is distinct from the jet-to-parent
fraction `z_J` and the hadron fraction `z_h`.

```
p  = Q/2 (1+r, 0, 0, 1+r)
q  = (0,0,0,-Q)
k1 = (Q/2 (r+(1-r)z), Q h, 0, Q/2 (r-(1+r)z))
k2 = p+q-k1
s=Q^2 r; t=-Q^2(1+r)(1-z); p_JT=Q h at Born level.
```

The hard production plane is xz with k1x positive. Incoming spin bases are
`e1=(0,1,0,0)`, `e2=(0,0,1,0)`. The outgoing bases are
`e1'=(0,k1z/E1,0,-k1x/E1)`, `e2'=e2`. Thus `(e1',e2',k1/E1)` is
right-handed. Photon L,X,Y bases are `(1,0,0,0)`, e1, e2 and span q-perpendicular
space. Every spin basis is spacelike unit length and orthogonal to its own
tagged momentum; the code evaluates these residuals. An incoming spin at angle
`phi_S` about p is `cos(phi_S)e1+sin(phi_S)e2`; a hadron at `phi_h` has
`j_T(cos(phi_h)e1'+sin(phi_h)e2')`.

Use `gamma5=i gamma0 gamma1 gamma2 gamma3` and density
`rho(p,S)=slash(p)(1+gamma5 slash(S))/2`. The producing method tags the actual
external Spinor heads before FermionSpinSum and replaces only the artificial
tag slashes. Internal numerator slashes and spectator spin sums are untouched.
The independent route constructs both diagrams with explicit 4x4 matrices.
The original initial factor is `1/(2 Nc)`; the tagged outgoing spin is summed
for UU and analyzed for the spin-transfer coefficient. A fixed-spin square
with both densities contains `1/(4 Nc)`; twice its bilinear four-orientation
coefficient gives the spin-transfer normalization used beside the usual UU.
This normalization is subject to the native and independent residual checks.
The saved Hqq amplitude carries the model charge 2/3; removing it must be tied
to the saved charge-vertex/Born-normalization evidence, not to a numerical fit.

Dimensional production uses BMHV gamma5, physical four-dimensional tagged
momenta and spin vectors, and D-dimensional unresolved polarization sums and
integration, D=4-2 epsilon. Born evanescent terms are retained. For real radiation
the unobserved momentum's evanescent components cannot be set to zero.
Agreement at D=4 alone does not establish the finite NLO factorization-scheme
conversion; the appropriate operator counterterms and any finite conversion
must be derived or independently sourced before assembly is accepted.
`tools/checks/operator_scheme_check.wls` exposes an outgoing collinear diagnostic
difference of `2 C_F z epsilon + O(epsilon^2)` between its BMHV and
anticommuting-gamma5 continuations. This is not a derived finite conversion
for the physical tagged-jet process: the diagnostic's off-shell/observed
momentum embedding still has to be matched to that process and its operator
definitions. It is evidence that setting epsilon to zero before subtraction
would not establish the required finite result. The literal ancillary source
hep-ph/9706511v2 is pinned separately. Its kernels are not DIS hard coefficients.

Continuation evidence now resolves the collinear quark-line part of that gap:
all six production incoming/outgoing components match the physical-tagged
operator kernel, whose BMHV and NDR angular averages agree. The one-loop virtual
operator differences also vanish after the same transverse average. The
remaining literal all-D difference is order epsilon squared and soft-integrable;
its actual simple radial pole produces no finite conversion. The independent
anti-kT out-of-jet calculation gives the same zero finite conversion. These
results retain the original diagnostic and literal all-D mismatch, and do not
constitute independent physics acceptance of the implemented finite observable.

## Jet matching, soft subtraction and perturbative expansion

The independently pinned source `references/2311.00672v2/source/main.tex`
contains the literal formulas. Its Eq. (70) defines the Collins correlator for
an **unpolarized hadron**. Eq. (105) uses transverse *parton* jet matching
`Hhat^T` and the Collins TMD `H1perp`, not the transversity fragmentation
function for a polarized hadron. Eqs. (98)–(100) and Sec. 3.1.2 fix the Fourier
measure, finite matching, and plus-prescription. Production uses `z_J` for that
paper's jet-to-parent z. With `L=ln(mu^2/(p_JT R)^2)`, both diagonal and
off-diagonal UU jet matching and the diagonal quark spin-transfer matching
are needed at one loop.

The input TMDs are renormalized, soft-subtracted nonperturbative functions at
`(mu,zeta_J)`, with natural `sqrt(zeta_J)=p_JT R`. They remain symbolic; no
small-b OPE into twist-three fragmentation correlators is assumed. In this
representation the in-jet soft function is already included in the TMD
(paper Eq. (90)); it must not be multiplied a second time. Its rapidity
anomalous dimension cancels that of the unsubtracted TMD. At one loop it is
the square root of the standard soft function with the explicit rapidity
scale replacement in Sec. 3.1.1. The old electron–jet imbalance soft function
does not enter this hard-production formula.

The intended inclusive-hard/FJF organization uses collinear hard coefficients
with their outgoing collinear subtraction, convolved with the corresponding
renormalized FJF. This separation assigns hard wide-angle radiation to the
inclusive coefficient and the narrow-jet in/out radiation to the FJF. It
requires matching of measures and subtraction schemes; importing an inclusive
coefficient alone is insufficient. An explicit jet cut must not also be applied
to the same inclusive real contribution after its FJF matching is included.

For `a=alpha_s/(2 pi)`, the producing algebra must retain
`a C0 J0 + a^2 (C1 J0 + C0 J1)`, with the appropriate PDF, flavor/charge sums,
photon/spin contraction and symbolic TMD convolution. `C1 J1` is order a^3.
The PDF is f1 in UU and h1 in the Collins term. Initial and outgoing
factorization scales and the renormalization scale are independent until a
documented common-scale choice. The derived measures, phase-space Jacobians and Collins sign are implemented in
the finite native assembly and checked separately. The derivation and native
campaign evidence, rather than this scope statement, establish the actual checks.

## Scientific acceptance

All six SIDIS channels are retained in the UU inventory. Their UT assignments
are derived from their tagged lines and operator/helicity structure, including
identical-flavor interference; a missing channel is never assigned zero for
convenience. Saved amplitudes, masters and UU evidence are reused artifacts.
New Born contractions, new real/virtual polarized numerators and their reductions
are fresh derivations only when their execution evidence exists. Literature
matching imports are separately labeled. The unresolved historical Hgq MadGraph
comparison is not resolved by reusing the separate BigTMD coefficient comparisons.
An eventual native pass covers declared computations; independent physics
review remains pending and no broader physical accuracy is certified by it.
