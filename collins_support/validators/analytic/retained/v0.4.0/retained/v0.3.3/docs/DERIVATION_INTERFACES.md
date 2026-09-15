# Analytical derivation extension interfaces

This release supplies validation machinery and an implementation contract. It
does not supply the missing native derivations. A reference-generated fixture
passing these Python checks is a harness self-test, not evidence that a
candidate derived an equation.

The production convention baseline is the pinned
`NonHermitianMatrix/SIDIS_dsigma_till_NLO` repository, commit
`5062dcb2407594dafcc2f9f72800e96ff9e6d957`. Follow the independently checked
`sidis_convention_lock.json` and `conventions.py`. Inherited conventions are
retained; transverse spin, TMD Fourier definitions and rapidity subtraction
require documented extensions where the unpolarized repository has no
definition. Do not replace a production formula with a paper convention simply
to make a comparison pass. Preserve literal paper discrepancies in the ledger.

## Stage boundary and evidence

All paths below are relative to a fresh analytical run directory. The native
Wolfram sources live in the production package; their stage results live here.

| Stage | Required result files | Purpose |
|---|---|---|
| d13 | `common/d13_result/native_matching.wl`, `operator_inputs.json`, `projections.wl`, `regulated_integrals.wl`, `subtractions.wl`, `finite_matching.json`, `derivation_graph.json`, `proofs.wl` | Native finite matching derivation, intermediates, and explicitly converted comparison coefficients |
| d14 | `common/d14_result/conventions.json`, `normalization_derivation.wl`, `scheme_derivation.wl`, `regulated_scheme.wl`, `scheme_conversion.json`, `proofs.wl` | Convention ledger, normalization algebra, regulated-to-subtracted scheme derivation, comparison expressions |
| d15 | `common/d15_result/native_observable.wl`, `symbolic_observable.json`, `derivation_manifest.json`, `assembly_derivation.wl`, `proofs.wl` | Native symbolic UU/UT assembly, formal first-order comparison, full equation provenance |

`native_matching.wl` and `native_observable.wl` retain the SIDIS baseline plus
declared Collins/TMD extensions. `finite_matching.json` is a **reference-side
converted packet** at canonical KPSY/C11 scales. `scheme_conversion.json`
contains reference-side formulas and conversion checks. Neither comparison
packet is permission to overwrite native conventions. The convention ledger
must connect native output, explicit transformations and the comparison
packet with hashed native evidence. The d14 ledger may use d13/d14 evidence;
it must not depend on the later d15 output.

The dependency graph and hashes record a claimed chain. They cannot establish
by themselves that the native code computes the chain. Acceptance also needs
fresh native stage execution, proof replay, upstream response probes, and
independent source review. No fitted PDFs, fitted fragmentation functions,
LHAPDF grids or Figure 6 outputs are needed for this analytical contract.

## JSON expression language

An expression is an exact rational-function AST. No source code, candidate
Python import, `eval`, or arbitrary symbolic function is accepted.

```json
{"op":"rat","num":1,"den":2}
{"op":"sym","name":"CF"}
{"op":"add","args":[{"op":"sym","name":"CF"},{"op":"rat","num":1,"den":2}]}
{"op":"mul","args":[{"op":"sym","name":"CF"},{"op":"sym","name":"z"}]}
{"op":"pow","base":{"op":"sym","name":"z"},"exp":-1}
```

These are separate examples. Valid symbols are the module's fixed `SYMBOLS`
set. Powers are integers from -4 to 4. Rationals use integer numerators and
positive integer denominators, each bounded in magnitude by `10^12`. Trees,
depth and expanded polynomial sizes are bounded. Unknown keys, duplicate JSON
keys, nonfinite numbers and unsupported operations are rejected.

The symbol `ell` means `ln(z)` for coefficient comparisons, with `0 < z < 1`.
It is treated as an independent formal symbol during rational-function
equality. This proves the tested algebraic identity on its stated domain;
it is not a proof of arbitrary logarithmic or distributional identities.

A canonical distribution has exactly four entries:

```json
{
  "delta":{"op":"rat","num":0,"den":1},
  "D0":{"op":"rat","num":0,"den":1},
  "D1":{"op":"rat","num":0,"den":1},
  "regular":{"op":"rat","num":0,"den":1}
}
```

They multiply `delta(1-z)`, `[1/(1-z)]_+`,
`[ln(1-z)/(1-z)]_+`, and the ordinary function, respectively. Endpoint
coefficients may not contain `z` or `ell`; simplify them before exporting.
The numerator-plus versus denominator-plus conversion must be derived before
exporting this canonical basis. The checker compares all four parts,
including finite endpoint constants; point samples of regular terms are
insufficient.

## d13 finite matching packet

`reference_matching()` defines the machine-readable comparison schema. It has
exactly these top-level keys:

```text
schema = 1
coupling = "alpha_s/(2*pi)"
scheme = "KPSY_C11_canonical"
scale = "mu=mu_b; zeta=mu_b^2"
approximation = "diagonal_homogeneous_twist3"
coefficients = {fqq, fqg, dqq, dgq, hqq, collins}
splitting = {qq, qg, gq, transversity}
```

Each matching coefficient has `tree` and `one_loop`, both canonical
distributions. Each splitting function is one canonical distribution.
Expansion coefficients multiply `a = alpha_s/(2*pi)`. The quark-diagonal tree
terms are unit delta functions; `fqg` and `dgq` have zero tree terms.

The frozen finite regular terms are:

| Key | Coefficient multiplying `a` in the converted comparison packet |
|---|---|
| fqq | `CF (1-z)` |
| fqg | `2 TR z (1-z)` |
| dqq | `CF (1-z) + 2 CF (1+z^2) ln(z)/(1-z)` |
| dgq | `CF z + 2 CF [1+(1-z)^2] ln(z)/z` |
| hqq | `0` |
| collins | `4 CF z ln(z)/(1-z)` |

The finite delta, D0 and D1 comparison terms vanish in this named canonical
coefficient convention. This does **not** mean native finite endpoint terms
must vanish before subtraction/conversion or after hard-factor absorption.
The frozen source snippets and hashes are in `references.json` (KPSY
arXiv:1505.05589, labels `eq:cf`, `eq:cf1`, `eq:cd`, `eq:cd1`, `eq:ch1`,
`eq:ch1perp`, and corresponding splitting equations).

Use the reference helpers only to understand/test the contract. Copying their
output into a candidate exporter cannot meet derivation acceptance. Native
records must retain operator definitions, spin/color projections, regulator
dependence, integral reduction/evaluation, UV/collinear/rapidity subtraction,
and their finite limits. Full off-diagonal twist-three fragmentation mixing
is outside this milestone; do not imply its derivation from these diagonal
comparison coefficients.

`derivation_graph.json` has `{schema:1, chains:{...}}` with one chain for each
of the six coefficient keys. Each chain has five ordered nodes:

```text
operator_inputs -> projection -> regulated_integral -> subtraction -> finite_output
```

Every node has exactly `kind`, `path`, `sha256`, `depends_on`, `native_symbol`.
Paths map to the corresponding d13 filenames above; `finite_output` is the
converted `finite_matching.json`. `depends_on` is `[]` for the first node and
the preceding kind in a one-element list otherwise. Native symbols must name
actual intermediate definitions. The broader convention ledger additionally
binds `native_matching.wl` and its conversion; this five-node graph alone does
not validate that conversion.

## Fresh upstream numerator probes

Production must provide `common/d13_matching_library.wl`, defining:

```wl
CollinsMatchingFromOperatorInputs[input_Association, outputDirectory_String]
```

The same library/function must be used by the normal d13 computation. It
returns the comparison `finite_matching.json` association and writes
`projections.wl`, `regulated_integrals.wl`, `subtractions.wl` in the supplied
fresh output directory. It must derive the result from the supplied input;
it must not recognize a probe and return a stored expected answer.

`operator_inputs()` documents the exact input packet. Its D-dimensional
splitting kernels use `D=4-2 epsilon` at this comparison/probe boundary:

| Kernel | Epsilon-linear numerator |
|---|---|
| qq | `-CF (1-z)` |
| qg | `-2 TR z (1-z)` |
| gq | `-CF z` |

The corresponding epsilon-zero terms are the canonical splitting
distributions. These are diagnostic input coordinates. If native SIDIS
notation uses another regulator parameter, explicitly convert it at the
boundary and keep the native notation in production evidence. A direct input
packet equality check is not a derivation of the D-dimensional trace.

Two seeded probes add a nonzero rational perturbation to the qq or qg
epsilon-linear numerator. The independently predicted finite response is the
**negative** perturbation, from the residue in
`Gamma(-epsilon) = -1/epsilon + O(1)`. The qq perturbation affects the regular
parts of fqq and dqq; the qg perturbation affects fqg. Every other matching
piece and all splitting kernels must remain as expected. These changes are
deliberately unphysical diagnostics, never alternative physics inputs.

The probes verify numerator-to-finite-coefficient dependence. They do not
independently prove the preceding operator traces or test every possible
upstream dependency. A frozen exporter is rejected. The harness refuses to
reuse a probe directory, stores the changed input, native script/context/log,
exit record, scope record and artifact hashes, and checks that the production
library remains unchanged.

Runtime config needs an existing `wolfram_kernel` executable; optional
`wolfram_init` is loaded before the candidate library. Native failure or
timeout cannot become PASS. Missing tools/evidence are reported as BLOCKED.

## d14 scheme and normalization packet

`scheme_conversion.json` has exactly `schema`, `expressions`, `physical_map`,
and `conventions`. `schema` is 1. The expression names and comparison ASTs are
given by `reference_expressions()`. They include the ep hard/soft/inclusive-jet
formulas, the explicitly retained hard-constant difference from KPSY, radial
Fourier measures, Collins moment normalization, a complete hard-absorption
identity, compensating rapidity shifts, and a fixed-coupling Sudakov solution.

For hard functions, `LQ = ln(mu^2/Q^2)`. In
`sudakov_fixed_coupling` **only**, `LQ = ln(Q^2/mu_b^2)`, as the required
`conventions.sudakov_log` text states. Do not use a single unqualified native
log symbol for both definitions. The rank-one radial coefficient multiplies
`b^2 db J1(b*j/z)` after contraction with the transverse-momentum unit vector.
Powers of z, Fourier signs and the Collins mass/moment relation must be
derived as part of the named extension; no empirical `2z` adjustment belongs
here.

`physical_map` has exactly:

```text
status: "RESOLVED" or "UNRESOLVED"
from_scheme: named regulated scheme
to_scheme: named subtracted scheme
shift_uu: {hard: AST, soft: AST, beam: AST, fragment: AST}
shift_ut: {hard: AST, soft: AST, beam: AST, fragment: AST}
native_evidence: [run-relative filenames]
reference_note: nonempty source/definition description
```

For each polarization the first-order shifts must sum to zero. Evidence must
include `common/d14_result/regulated_scheme.wl`,
`common/d13_result/regulated_integrals.wl`, and
`common/d13_result/subtractions.wl`; the checker verifies files exist.
Their hashes are bound by the derivation manifest and convention ledger.

Cancellation of arbitrarily chosen shifts does not prove the individual
shifts. Merely assigning different scheme names, setting shifts to zero and
labelling the map RESOLVED is insufficient scientific evidence. The separate
native proofs and source review must derive these shifts from the regulated
operators and subtraction definitions. Hard absorption alone does not close
the regulator-to-subtracted-TMD conversion. UNRESOLVED remains BLOCKED even
when every frozen reference-side identity passes.

## d15 assembly and equation provenance

`symbolic_observable.json` has exactly `schema`, `coupling`, `expressions`,
`input_roles`, `truncation`, `inclusive_jet_multiplier`.
`reference_assembly()` defines six expression keys: `UU0`, `UU1`, `UT0`,
`UT1`, `A0`, `A1`. The comparison uses a strict first-order expansion:

```text
UU = UU0 + a UU1
UT = UT0 + a UT1
A0 = UT0/UU0
A1 = UT1/UU0 - UT0 UU1/UU0^2
```

Here `hard`, `soft` and the one-loop matching convolutions are the coefficients
of `a`. Products of two one-loop corrections must not appear in `UU1` or
`UT1`. Hadron-in-jet assembly uses a fragmenting jet function and must not
multiply by an additional inclusive jet function. Fitted matrix elements stay
symbolic, with exact roles:

```text
f0: symbolic_f1              f1: derived_matching_convolution
d0: symbolic_D1              d1: derived_matching_convolution
t0: symbolic_h1              t1: derived_matching_convolution
c0: symbolic_Hhat3           c1: derived_matching_convolution
```

The required metadata strings are `coupling="alpha_s/(2*pi)"`,
`truncation="O(a); A=A0+a*A1; no products of one-loop corrections"`,
and `inclusive_jet_multiplier=false`. These define this comparison contract;
production retains its explicitly documented equivalent native conventions.

`derivation_manifest.json` contains `{schema:1,equations:[...]}`. Every row of
the frozen `equation_inventory.json` must occur exactly once. Each row has:

```text
id, origin, agreement, evidence, reference, note
```

`origin` must match its required DERIVED/EXTERNAL/MODEL classification.
`agreement` is separately EXACT/CONVERTED/NUMERICAL/UNVERIFIED/MISMATCH.
NUMERICAL labels how an independently derived expression was checked; it
cannot substitute for derivation provenance. Each reference is nonempty text
identifying the source and equation/operator definition. Evidence is a map
from safe run-relative filenames to nonempty-file SHA-256 identities.

For d13/d14/d15 rows, evidence must include **all files required by that
stage**, except `derivation_manifest.json` itself (a file cannot hash its own
final content). This requirement intentionally prevents hashing only a final
export and claiming derivation. Required derived rows marked UNVERIFIED or
MISMATCH block acceptance. Apparent literal paper errors stay visible in the
ledger; an independently justified physical derivation and explicit
conversion/discrepancy evidence must explain the comparison result.

## Checker API and limits

```python
run_checks(repo, run, runtime, evidence_dir, seed)  # fresh native probes
replay_checks(run, evidence_dir, seed)            # no native execution
replay_upstream(evidence_dir, seed)               # only saved probe replay
check_matching(packet, prefix='matching', expected=None)
check_scheme(packet, run=None)
check_assembly(packet)
check_manifest(packet, run)
check_graph(graph, run)
```

`run_checks` writes `evidence_dir/derivation_checks.json` and returns individual
PASS/FAIL/BLOCKED rows. Replay recomputes the seeded input, independently
expected finite shift, packet comparisons and saved file identities. It
checks the saved exit code, script identity and context/log/script hashes.
It does not rerun Wolfram. The enclosing run manifest must protect replay
evidence; self-reported logs/hashes alone do not authenticate execution.

The numerical self-tests use synthetic packets and mocked native calls only
where clearly labelled. They test actual failure controls: finite endpoint
and sign mistakes, missing channels, dropped inventory rows, unsupported
origins, absent scheme evidence, unresolved maps, unwanted one-loop products,
fitted inputs, stale hashes, reused probe directories, ignored changed
numerators and tampered replay records. They do not establish completion of
the physical derivation milestone.

Run the focused harness tests with:

```sh
python -m unittest discover -s tests -p test_derivation_checks.py -v
```
