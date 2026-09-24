# Independent comparison against Congyue's polarized hard coefficients

Scope: our **inclusive polarized hard coefficients before any jet/TMD
matching** — the `Hqq` and `Hqqbar` transverse-spin-transfer coefficients
produced at r07 — against Congyue's `SIDIS_HighPT_TT_HardCoefficients`
package (prepared 17 September 2026).

Congyue's files are used only as comparison inputs. No coefficient of ours was
replaced by one of theirs, and no tolerance or convention was changed to force
agreement. Verdicts distinguish symbolic equality, numerical agreement and
unresolved rows.

**This verdict is separate from the historical native pass.** The preserved run
`20260916T095719Z-1584d7f6dd71` and its recorded `NATIVE_CHECKS_PASS`,
16,416 declared checks, 16 boundary comparisons, `ENDED_AT_USER_REQUEST`
campaign disposition and pending independent physics review are unchanged and
are not reissued here. This comparison is an independent cross-check of one
part of that calculation; it is not a campaign result.

## Conversions, derived from both implementations

Congyue: `Q2`, `x`, `z`, `w` with `S = 2 p.q = Q2/x`,
`W = (p+q-k)^2 = S(1-x)(1-z)(1-w)`, `pT^2 = S z(1-x)(1-z) w`; distributions in
`w` with the endpoint at `w = 1`. Ours: `Q2`, `s`, `t`, `w = W`, plus-endpoint
scale `B`, branch `t = sign*omega - s`.

| item | conversion | how it was fixed |
|---|---|---|
| invariants | `s = Q2(1-x)/x`, `W = Q2(1-x)(1-z)(1-w)/x`, `t = W - Q2(1-z)/x` | derived from both definitions; note `t` depends on `w` at fixed `(x,z)`, and `z_ours = z + x W/Q2` |
| branch | `sign = Sign[t+s]`, `omega = |t+s|`; `t+s = W + Q2(z-x)/x` | our `HSPhysicalBranch`; at `W -> 0` the branch boundary is exactly `x = z` |
| endpoint scale | `B -> A` with `A = Q2(1-x)(1-z)/x` | `A` is the upper limit of `W` at fixed `(x,z)`. Our `Delta` is `B`-independent; our `L0` satisfies `L0(B') = L0(B) + L1 Log[B'/B]`, so only `B = A` reproduces Congyue's `P_0`. Verified: `L0` matches at `B = A` and not at `2A` or `A/2`. |
| distribution basis | `Log[W/B] = Log[1-w]`, `[1/W]_+ dW = [1/(1-w)]_+ dw` | follows from `B = A` |
| endpoint Jacobian | `Delta`, `L0`, `L1`: **ours = A * kappa * theirs**; interior density: **ours(dW) = kappa * theirs(dw)** | `delta(W) dW = delta(1-w) dw` gives no Jacobian for the point mass, but our coefficient multiplies `delta(W)` in `dW` while theirs multiplies `delta(1-w)` in `dw`, so the coefficients differ by `A`. Delta distributions are never compared as point values. |
| photon | `kappa_T = 2`, `kappa_L = 1` | our transverse component is the **sum** over the two physical photon polarizations, Congyue's is the **average**; both use `(T11+T22)/2` for the spin indices |
| couplings | `LO = aS * 16 Pi^3 eq^2 * Born_D4`, `NLO = aS^2 * 64 Pi^4 eq^2 * finite_candidate`, `aS = alpha_s/(2 Pi)` | our hard has `eq^2 gs^(2n)` stripped (`CouplingsRemoved = eq^2 gs^4`); `gs^2 = 8 Pi^2 aS = 4 Pi alpha_s`; Born cut phase `2 Pi delta(w)`. Congyue includes `alpha_s` and charges already. |
| charge | `eq -> eU` (external quark up-type) | Congyue's supplied quark is up-type |
| flavor | `otherChargeMoment_n -> nU eU^n + nD eD^n - eU^n`, `Nf -> nU + nD` | our `HSOtherChargeMoment[q,n,nf] = Sum_f e_f^n - e_q^n` |
| colour | `SUNN -> CA`, `CF -> (CA^2-1)/(2 CA)` | both; `TR = 1/2` already substituted on Congyue's side |
| scales | `muR -> Sqrt[muR2]`, `muPDF -> Sqrt[muF2]`, `muFF -> Sqrt[muD2]` | renormalization, incoming-PDF, outgoing-FF |
| endpoint reading | `Delta`, `L0`, `L1` read at `W -> 0` (`w -> 1`), which also fixes `t -> -Q2(1-z)/x` | Congyue's `Delta`/`Plus` are `w`-independent; ours are not, because `t` depends on `w` at fixed `(x,z)` |

### Born normalization, checked first

| component | ours, couplings restored | `A * kappa_pol *` Congyue | residual |
|---|---|---|---|
| transverse | `32 (CA^2-1) eU^2 Pi^2 alpha_s / CA` | `32 (CA^2-1) eU^2 Pi^2 alpha_s / CA` | **0, symbolic** |
| longitudinal | `0` | `0` | **0, symbolic** |

`Born_D4[Collins_T] = 4(CA^2-1)/CA = 8 CF` is a constant in our normalization;
the whole `x, z, Q2` dependence of Congyue's LO delta coefficient is the factor
`A`. The Born match is what fixes the overall conversion; everything below uses
the same conversion with no further freedom.

## Results

126 rows. Every row is in [comparison-table.md](comparison-table.md);
[reproduce.sh](reproduce.sh) is the command. This is the result **after the
scalar-export fix (C5)**; the pre-fix table and log are kept in
[pre-idfix/](pre-idfix/).

| verdict | rows |
|---|---|
| numerical agreement, `rel < 1e-40` at 60-digit working precision | 57 |
| numerical agreement, quadrature-limited (`rel ~ 1e-19`) — the action rows | 12 |
| both sides identically zero | 45 |
| removable-limit convergence at `x = z`, ratio `1.000e4` over offsets `1e-6 -> 1e-10` | 8 |
| exact at the `x = z` boundary, offset-independent | 4 |
| discrepancy or unresolved | **0** |

A symbol audit on both sides after conversion reports **no residual free
symbols** in any compared expression, so the conversion dictionary is complete.
The `EulerGamma` that appears in Congyue's `Hqq` transverse delta coefficient
has coefficient exactly `0`, so there is no MS-versus-MSbar convention residue
between the two.

### Symbolic equality

* LO `q-q` delta coefficient, both photon components.

### Numerical agreement at 60-digit working precision, relative difference below `1e-40`

* `Hqq` NLO `Delta`, `L0`, `L1`, both photon components, both branches, five
  interior `(x,z)` points including one with all three scales equal.
* `Hqq` NLO interior, **both** photon components, eight points including the
  removable `x = z` and `x = z = 1/2` cases and the `x = 7/10, z = 1/5` point
  that was 5% off before the export fix.
* `Hqqbar` NLO `Delta`, `L0`, `L1` (all zero on both sides) and both photon
  components of the interior, eight points each.
* Congyue's longitudinal `Plus[0]` is nonzero as stored but cancels identically
  once its `Piecewise` removable form is resolved; ours is `0`. Agreement.

### Removable boundaries

At `W -> 0` our branch boundary `t + s = 0` coincides with Congyue's removable
surface `x = z`, and Congyue's `Piecewise` discriminant `1 - 4xz/D^2` vanishes
there and only there in the physical region. Our two one-sided branch
expressions both converge to Congyue's value at `x = z`, linearly in the offset:
relative error `~3e-6` at offset `1e-6` and `~2e-10` at offset `1e-10`, for
`Delta` and `L0` at `z = 2/5` and `z = 1/2`. `L1` is `x`-independent and is
exact at any offset.

### Distribution actions on smooth test functions

This is the test that the endpoint *conversion*, not just the coefficient list,
is right: comparing coefficients alone cannot catch a mistake in how `delta(W)`
and `[1/W]_+` map onto `delta(1-w)` and `[1/(1-w)]_+`.

Both distributions are acted on `t = 1`, `t = w` and `t = e^w`, with our side
written as

    Delta*t(1) + Int dw { A*interior(w)*t(w) - [L0(0) + L1 Log(1-w)] t(1)/(1-w) }

and Congyue's with its own plus prescription and its own coefficients. The
target identity is `S_ours[t] = A * kappa_pol * S_Congyue[t]`.

The integration runs over `w` in `(1/10, 1)`. The `w -> 1` end is where the
delta and plus structure lives and is the point of the test. The `w -> 0` end is
the zero-transverse-momentum limit: the interior carries a `1/(s t + Q2 W)` pole
there — the physical boundary `W -> A`, equivalently `pT -> 0` — so the `w`
integral converges for neither implementation, and Congyue's README already
flags that boundary as needing a separate limit analysis. Since the integrand
identity is pointwise in `w`, restricting both sides to the same sub-range tests
the endpoint conversion exactly. Agreement is quadrature-limited rather than
exact.

### The residual, and what it was

The first pass of this comparison found one unresolved discrepancy: the `Hqq`
transverse interior (the `Regular` term), `3e-4` to `5e-2` relative in the bulk
and growing toward `w -> 0`, exactly independent of `muR2, muF2, muD2, nU, nD`,
with everything that fixes the conversion — Born, `Delta`, `L0`, `L1`, the whole
longitudinal channel, the whole `Hqqbar` channel — agreeing exactly. Precision,
normalization, the plus scale, scale and flavor conventions, an alternative
`Log[zeta]` argument and the unfixed finite FF scheme kernel were each tested
and excluded.

The cause was a defect in our scalar exporter, not in either calculation:
`IntegerString[n,10,3]` truncated coefficient identifiers to three digits, so
in the two transverse `Regular` blocks with 1149 coefficients each, index 1000
became `_c000` and 1001 onwards silently overwrote 001 onwards. Evaluating the
recipe directly and subtracting the truncated export reproduces the benchmark
residual digit for digit, `0.09103198892753964850191237749766114126` at
`x=1/3, z=2/5, w=3/4`. The fix, its guards, its regression test and the
rebuild are recorded in
[CORRECTION_PROVENANCE.md](../../../collins_sidis_highpt/CORRECTION_PROVENANCE.md),
section C5. The recorded historical run carries the same defect.

## Qualifications

* Both sides are inclusive collinear hard coefficients. Neither includes jet
  matching, TMD convolution, lepton flux or the QED coupling.
* Congyue's package states that a complete external finite polarized NLO
  coefficient comparison had not been completed on their side either.
* The `w -> 0` and `pT -> 0` boundaries are excluded from the agreement claims
  on both sides.
* Agreement here concerns the coefficients compared. It is not a physics
  acceptance of the full Collins moment, and the engine's independent physics
  review remains pending.
