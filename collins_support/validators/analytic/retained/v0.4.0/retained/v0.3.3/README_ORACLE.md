# Analytic-export coefficient oracle

`oracle.py` is a standard-library-only independent numerical comparator for the
first analytic campaign. `validate_export(payload, seed)` returns a list of
checks with `id`, `status`, and diagnostics. An invalid export returns a failure;
it cannot fall through to an empty successful result. `loads_export(text)` loads
bounded JSON and rejects duplicate keys and nonfinite JSON numbers. The caller
should use that loader, rather than unrestricted `json.load`.

The four top-level fields are exactly `schema`, `component`, `conventions`, and
`expressions`. The schema is `collins-ep-analytic-export/v1`. The frozen convention
maps and expression names are in `CONVENTIONS` and `EXPRESSION_KEYS`.

## Restricted expression language

Only these JSON objects are accepted:

- `{"op":"rat","num":2,"den":3}`: rational coefficient; bounded integer numerator
  and strictly positive integer denominator. Floats and booleans are rejected.
- `{"op":"sym","name":"s"}`: component-specific symbol.
- `{"op":"add","args":[a,b]}` and `{"op":"mul","args":[a,b]}`: two or more operands.
- `{"op":"pow","base":a,"exp":-2}`: bounded integer exponent, including negative powers.

The Born component allows `s,t,u`; its outputs are `H_UU,H_UT`. The one-loop
component allows `L,CF,pi`; its output is `h1`. Thus a squared pi constant is a
power node with base `{"op":"sym","name":"pi"}` and exponent 2. Code strings,
calls, filenames, lookup tables, conditionals, arbitrary functions, unknown
symbols, and extra object fields are rejected. The parser/evaluator enforces
byte, node, depth, exponent, integer-size, and numerical-range limits. This is an
expression data format; it never evaluates source code or imports production.

## What is compared

Born references are evaluated through the physical inelasticity variable y:

H_UU = 2[1+(1-y)^2]/y^2, H_UT = 4(1-y)/y^2,

with t=-s*y, u=-s*(1-y). These are equivalent to the declared couplings-stripped
invariant formulas H_UU=2(s^2+u^2)/t^2 and H_UT=-4*s*u/t^2. Euler homogeneity under
simultaneous scaling of all invariants is also checked. Equivalent expressions
on the declared massless support are accepted.

The one-loop reference is arXiv:2007.07281 Appendix A Eq. (A1):

H_q = 1 + alpha_s/(2*pi) * h1 + O(alpha_s^2),
h1 = CF[-L^2 - 3L - 8 + pi^2/6], L=ln(mu^2/Q^2).

This is the **squared spacelike hard matching function** in the paper's declared
convention, not the amplitude coefficient and not a timelike continuation. The
expression must retain CF symbolically; Nc=2,3,5 points are used to expose hidden
Nc=3 specialization. If another intermediate scheme is used in production, the
analytic workflow must separately derive and record its finite conversion into
this comparison convention. Do not fit a finite conversion to force agreement.

Dual-number algebra calculates the candidate's first and second L derivatives,
which are compared to CF(-2L-3) and -2CF. These are partial derivatives at fixed
CF. They are not a test of an all-orders RGE or a running-alpha_s derivative.
Color linearity is also checked. Relative and absolute tolerances are both
2e-11 for binary64 arithmetic; this is numerical agreement, not exact algebraic
proof or a 1e-17 claim.

Each component makes 73 checks, including schema validation. They are correlated
checks of two Born functions or one one-loop function, not 73 independent
derivations. A deterministic PRNG generates physical scales and angles or hard
logarithms. Reviewer-chosen additional seeds should be chosen after the source is
frozen. Public selftest seeds are not confidential challenges.

## Mandatory interpretation limits

A fabricated copy of a known coefficient passes this module. Its purpose is to
validate exported coefficients **after separate evidence establishes their
derivation**. Require generated amplitude/operator inputs, nontrivial traces,
integrand reconstruction, integral reductions and evaluations, regulator and
counterterm bookkeeping, source-bound execution records, and clean replay.

Appendix A introduces Eq. (A1) for the unpolarized case. A polarized implementation
must independently establish that its chosen virtual spin projection is
proportional to the Born tensor with the corresponding quark-current factor.
Passing the h1 comparator alone does not establish that statement.

These component checks do not certify the full measured soft function, the jet
function, full TMD assembly, the paper's Figure 6, a matched fit, or polarized
NLO. The other harness stages must preserve those boundaries.

## Measured soft pilot recommendation

For a finite feasibility pilot, compare a specified beam-jet dipole integral over
kT in [Kmin,Kmax], u=eta-yjet in [-Y,Y], phi in [-pi,pi], excluding the anti-kt
single-soft disk u^2+phi^2 < R^2. The reduced integrand is

exp(u)/(cosh(u)-cos(phi)) * dkT/kT * du * dphi,

with 0<R<min(Y,pi). Parent validation can integrate kT analytically as
ln(Kmax/Kmin) and compare an angular primitive or independent domain splitting
against production quadrature. A symmetric u window also offers an exp(u) +
exp(-u) = 2*cosh(u) consistency check. Require a nontrivial R dependence and
independence of yjet when the integration window is defined in relative u.

This tests the actual measurement region on a nonsingular finite domain. It
does not determine dimensional/rapidity poles, endpoint distributions,
zero-bin/overlap subtractions, a Fourier-space soft coefficient, or a
renormalized physical soft function. The overall eikonal normalization and
measure are explicitly stripped and must not be inferred from this pilot.

## Selftests

Run `python3 selftest_oracle.py`. The fixture constructors are deliberately known
reference formulas and belong only to validator selftests. They are never
production derivation artifacts. Tests include sign, factor-two, missing finite
term, wrong logarithm sign, timelike constant, fixed-color mutants, malformed
exports, resource bounds, dual algebra, and repeatability.

Primary source inspected: https://arxiv.org/pdf/2007.07281 (Appendix A Eq. A1;
main text states anti-kt R=1). The acceptance pilot allows additional R values to
exercise the measurement before selecting the paper setting.
