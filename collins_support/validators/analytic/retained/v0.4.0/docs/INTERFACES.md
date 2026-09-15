# Candidate interfaces

The fixed scripts are `common/d16_nlo.wls` through `common/d19_nlo.wls`. They are editable candidate implementation paths, not supplied/frozen placeholder programs. Shared new libraries may be added under `common/` with new names. The installer adds the coefficient-free `common/nlo_io.wl` helper. Original accepted files remain unchanged.

## Execution and native transport

The runner sets `COLLINS_NLO_CONTEXT` to a JSON file with:

- `stage`, `run_id`, `production`, `output`, `inputs` (stage ID -> result directory);
- `runtime` (new timeout/interpreter settings), `native_runtime`, `extension_runtime`, `derivation_runtime` (retained configurations);
- `no_cache: true`, the frozen `scope`, and `probe` (null in the unperturbed run).

It also sets `COLLINS_ANALYTIC_CONTEXT` to a compatible context for existing native libraries, with its `runtime` field containing the original native configuration. `COLLINS_ANALYTIC_NO_CACHE=1` is set. Read dependencies from the supplied directories. Write only inside `output`. Exit 0 after complete output, 2 for a concrete incomplete/blocked implementation, and 1 for a calculation failure. Never report a skipped stage as successful.

Each stage writes all artifacts listed in `contract.json`, including:

```json
{
  "schema": 1,
  "stage": "d17",
  "purpose": "DERIVATION",
  "coupling": "alpha_s/(2*pi)",
  "data": {"...": "stage-specific fields below"}
}
```

`packet.wl` evaluates to the same Wolfram Association as `packet.json`. `NLOWritePacket[data]` creates both. The external `reexport.wls` independently reads the native file and compares its JSON export. Scientific packets must be deterministic and exclude run IDs, absolute paths and timestamps; put those in context/provenance instead.

Scalar expressions use exact prefix trees: integers, strings such as `"-2/3"`, permitted symbol names, and arrays `['add', ...]`, `['mul', ...]`, `['pow', base, rational_power]`, `['log', arg]`, `['li2', arg]`, `['zeta', integer]`. Use double quotes in actual JSON. Floats, arbitrary source strings and eval are forbidden. `NLOTree[expr]` converts native expressions; explicitly map native dummy symbols to the stable names first. The complete accepted symbol list is `symbolic.NAMES`; it includes fraction/color/log variables and formal assembly inputs. Intermediate native files may use richer Wolfram expressions.

The log conventions are B=ln(mu^2 b_fragment^2/c0^2), **Bq=ln(mu^2 b_recoil^2/c0^2)**, T=ln(mu^2/zeta_fragment), L=ln(mu^2/Q^2), r=ln(R^2), with c0=2 exp(-EulerGamma). B and Bq are independent symbols; do not identify their Fourier variables. LJ is ln(mu^2/(pT_jet^2 R^2)); Y is the jet rapidity in the retained native soft function. Keep the distinct physical variables in `NATIVE_OBSERVABLE.wl` and the full operator formula.

## One- and two-fraction distributions

Every u distribution has exactly `regular`, `delta`, `D0`, `D1`. They multiply respectively the regular density, delta(1-u), [1/(1-u)]+ and [ln(1-u)/(1-u)]+. Endpoint coefficients are independent of u; first reduce whole-numerator plus prescriptions explicitly. The convolution's test function includes its 1/u measure. Preserve lower-limit boundary terms when integrating from zh rather than zero.

For HF use u=zh/z and v=z/z1. The positive ordered branch z1>=z maps to 0<v<=1. Derive its physical support and any necessary crossed contribution; do not assume another support branch is absent without an operator argument. The absolute dz1/z1^2 Jacobian is dv/z, and its product with the written inverse-fraction PV factor is dv/(1-v). The `reference_B` comparison is the **bulk** kernel before that measure, in the explicitly mapped reference basis.

The v action is represented with two endpoint subtractions and explicit contacts:

\[
\int_0^1 dv\,K(u,v)\,[\Phi(u,v)-\Phi(u,1)-(v-1)\partial_v\Phi(u,1)]
+c_0(u)\Phi(u,1)-c_1(u)\partial_v\Phi(u,1).
\]

Thus `v_delta` is c0 and `v_derivative` is the coefficient c1 of delta'(v-1). Apply the u distribution to each term. This is a **transport convention**: derive the conversion from the regulated/native PV prescription and retain all contact terms. It does not assert that a printed pointwise kernel fixes c0/c1. A smooth bulk density represented this way generally has nonzero c0 and c1. Keep generic endpoint test fields until the complete operator action is displayed; HF(z,z)=0 alone cannot justify discarding every derivative/contact term.

## d16 data

`definitions` contains exactly the fixed values tested in `nlo_checks.d16_checks`: process `ep_Collins`; unpolarized electron/transverse proton; anti-kt/standard_E_scheme; the fixed SIDIS commit; coupling `alpha_s/(2*pi)` and Born `alpha_EM^2`; operator basis `["Hhat","HF"]`; `HF_diagonal="zero"`; `rapidity_order="eta_then_epsilon"`; radius qualification `narrow_cone_derivation_R1_not_certified`; paper limit `HF_zero_and_jet_finite_extension_zero`; all-b `renormalized_symbolic_TMDs`; small-b `local_OPE_only`.

`identities` exports `dz1_measure=1/z`, `PV_combined_measure=1/(1-v)`, `delta_inverse_fraction=z^2`, `EOM_contact=1` after using delta support, `Fourier_rank0_relative=1/z^2`, and `Collins_rank1_relative=1/(2*z^3)`. The last coefficient is the retained native KPSY-normalized rank-one coefficient after removing b^2 db J1/(2*pi); it is not an automatic identification of the paper's differently named Collins function. `independent_HF` is true.

`review` records `operator_identification`, `gauge_boundary`, `support_and_EOM`, `finite_jet_scope`, with references to actual native evidence. Write the detailed argument in `OPERATORS_AND_MEASUREMENT.md`. Narrative fields are review evidence, not an algebraic proof.

## d17 data

Provide:

- `reference_B`: actual derived bulk coefficient converted into the reference comparison basis. `oracles.py` preserves both explicit literal alternatives. `native_basis_factor`: the derived ratio converting the reference Hhat/HF operator normalizations to the native density. It may depend on u,v,zh, must be nonzero, and cannot contain color factors or scale logarithms. Explain and derive it; no empirical rescaling.
- `bare`, `counterterm`, `finite`, `independent_finite`, `mixing`, `epsilon_projection`: u-distribution dictionaries whose coefficients may depend on v. These are the two-subtracted v bulk densities.
- `v_delta` and `v_derivative`: each contains the same six u-distribution dictionaries, with coefficients independent of v. No endpoint field may be omitted, even if its derived value is zero.
- `v_prescription="two_subtractions_plus_explicit_delta_and_delta_prime"`.
- `diagonal_canonical`: the unchanged `coefficients.collins` object from the actual d13 `finite_matching.json`; `diagonal_splitting`: its actual `splitting.transversity` object. Reuse the accepted derivation rather than copying reference coefficients into a replacement.
- `closed_full_twist3_RG=false`; `routes.primary` and `routes.independent` explain the two native calculations and point to their distinct artifacts.

Here `bare` is the pre-collinear-matching TMD coefficient **after** the separately documented TMD UV/rapidity subtraction. Store the original bare regulated operator, its UV/IR separation and those subtractions in the provenance graph. Since the independent HF channel has no tree coefficient in this basis, its remaining collinear counterterm is `mixing/eps`. Check `bare+counterterm=finite`, `d(finite)/dB=-mixing`, and `d(finite)/dT=0`, component by component, including contacts. The u-regular bulk mixing density equals `native_basis_factor*B(zh,zh/u,zh/(u*v))/(1-v)`; the other u endpoint pieces of that bulk are zero in this reference organization. Endpoint extension in v is independently derived and reviewed.

Keep `epsilon_projection` at the numerator position normalized to a transverse master with pole -1/eps. Its role is a genuine upstream dependency test, not a finite-output parameter. The finite coefficient can contain rational functions/logarithms in u,v,zh and color factors; its B dependence is fixed by mixing. Use B,T only for the fragment matching field.

The independent route must recover the finite term, including the D-dimensional information multiplying poles. Comparing only a four-dimensional transverse tail or only the mixing kernel is incomplete. Write `REFERENCE_DISCREPANCIES.md`, preserving both literal reference equations and both computed residuals, with an operator-based interpretation. The checker requires a supported literal bulk comparison; disagreement with both requires an explicit proposed reference-check extension and independent derivation, not a tuned coefficient.

## d18 data

`UU` and `UT` each contain scalar `bare`, `counterterm`, `overlap`, `finite`, `independent_finite`, `epsilon_projection`, `gamma_G_minus_TMD`. These describe the additional quark jet/TMD conversion **after** the retained intrinsic TMD matching and at zeta_J=pT_jet^2 R^2. The convention is `finite=bare+counterterm-overlap`; derive every part. The remainder is scale independent in this organization and may depend on CF,CA,r. `gamma_G_minus_TMD=0` and the two physical finite remainders agree after the stated projections/conversions.

Set `multiply_inclusive_J=false`, `import_pp_out_of_jet_H=false`, and `radius_qualification="narrow_cone_derivation_R1_not_certified"`. `review` provides `operator_scope`, `out_of_jet_overlap`, `radius_validity`, `independent_route`; write `RADIUS_VALIDITY.md`. If a rigorous derivation disproves the scalar reduction or requires a new distribution/partonic channel at the declared accuracy, preserve it and propose the interface correction instead of deleting the new term.

## d19 data and native observable

`input_packet_hashes.d17/d18` are canonical JSON SHA256 values of the full upstream packets (sorted keys, compact separators; `nlo_support.canonical_hash`). They are not hashes of a copied reference.

Use independent formal symbols f0,f1,h0,h1,D0,D1,C0,C1 for retained collinear/TMD coefficient convolutions. HUU/HUT are the generated Born factors. `observable` contains UU0,UT0,UU1,UT1, where the last excludes the **separately exported** HF contribution. With h=the ep A1 coefficient, s=the ep A3 soft coefficient and jU/jT from d18:

\[
UU_1=HUU[f_1D_0+f_0D_1+(h+s+j_U)f_0D_0],\qquad
UT_1=HUT[h_1C_0+h_0C_1+(h+s+j_T)h_0C_0].
\]

`HF_integrand` has 12 keys: regular/delta/D0/D1 plus those four with `v_delta_` and `v_derivative_` prefixes. Bulk entries are HUT*h0*finite_part*HF0; delta-v entries use HFend, and derivative-v entries use **-HFderiv**. These symbols distinguish the bulk field, its endpoint value and its endpoint derivative. Retain the actual two-fraction convolution, support, Fourier measures and common kinematic integration in the full native operator expression.

`ratio` contains A0=N0/U0 and A1=N1/U0-N0*U1/U0^2, where N/U are the separately integrated UT/UU coefficients and U0 is nonzero. `paper_limit` repeats the four observable coefficients with the new finite jet remainder and independent HF set to zero. `scheme_variation.UU/UT` is the corresponding tree coefficient times `(kH+kB+kF+kS)` for arbitrary independent shifts. This checks compensation without silently retaining higher-order products.

Required Booleans: `fitted_inputs_evaluated=false`, `all_b_OPE_extrapolation=false`, `HF_independent=true`, `ratio_after_common_linear_integral=true`, `paper_limit_is_full_NLO=false`, `full_fixed_order_NLO=false`.

`NATIVE_OBSERVABLE.wl` evaluates to an Association with `observable`, `HF_integrand`, `ratio`, `paper_limit` and `scheme_variation` containing the **raw symbolic Wolfram expressions**, not prefix arrays. It may additionally contain the full all-b and local-OPE operator formulas with their separate variables and domains. The external encoder independently extracts the five coefficient maps and compares them with the tested packet. Derive them from the same upstream exports used by the full operator formula.

## Provenance

`provenance.json` has schema=1, stage, nodes and exports. Every node has a unique id, role, parents, explanation and `file={root,path,sha256}`. Roots are `production`, `output`, or an input stage ID. Paths are contained regular files. Every node must reach an exported result; cycles, missing parents, missing roles and disconnected evidence fail. At least one producing source and one fresh output must be present. Required roles are in `contract.json`. The independent-route artifact must be distinct and must not depend on the primary finite export.

Include actual diagrams/operator insertions, regulated projectors and integrands, reduction/master results, epsilon expansions, counterterms, endpoint extensions and finite exports as appropriate. A graph of files is not a derivation proof: source review checks whether the files and code perform those operations. No direct reading of reference answers into production coefficients is permitted.

## Upstream probes

The verifier reruns d17 or d18 with `probe.kind` equal to `HF_epsilon_projector` or `jet_epsilon_projector`. `probe.delta` is an exact tree. Insert **eps*delta in the normalized upstream numerator** before the master with pole -1/eps and propagate it. The bulk finite response must be -delta; the collinear mixing kernel is unchanged. The jet delta is a scalar and changes both spin projections identically.

For HF the delta is proportional to u^3(1-u)^2 v^2(1-v)^2. In the two-subtraction transport basis, its explicit contacts are integral(delta,dv) and integral((1-v)*delta,dv). They equal the u-dependent prefactor divided by 30 and 60. The epsilon-projection contacts shift by these values and the finite contacts by their negatives. Do not omit them just because the smooth density itself vanishes at v=1.

The verifier then reruns d19 with `probe.kind="recompute_from_replaced_dependency"`, replacing only the changed upstream result directory. All coefficient and input-hash checks must respond to the actual new exports. A probe may not read a precomputed finite answer or implement a special direct subtraction from the final output. Its insertion point and native propagation are mandatory source-review items.
