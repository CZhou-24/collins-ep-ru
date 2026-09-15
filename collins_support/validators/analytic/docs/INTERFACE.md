# Native candidate interface

This is the implemented v0.5.1 interface. Read the source-reuse instructions before adapting the SIDIS scripts. The external validator is frozen; candidate stages and helpers belong in the new engine.

## Stage sequence

| Stage/script in `common/` | Candidate produces | Validator then executes |
|---|---|---|
| `r00_definitions.wls` | Process, measurement, spin/operator definitions, regenerated amplitudes and convention evidence | Independent native packet export |
| `r01_real_map.wls` | Rational cut-family maps and Kira job inputs | Kira, native target/master/cut audit |
| `r02_real_masters.wls` | Euler inputs derived from the actual r01 reductions and cut measure | SubTropica on those inputs |
| `r03_real_assembly.wls` | Real-master contractions, distribution expansion, subtraction coefficients | Independent certificate arithmetic |
| `r04_virtual_map.wls` | Ordinary virtual families and Kira inputs | Kira and native target/master audit |
| `r05_virtual_masters.wls` | Virtual Euler inputs derived from actual r04 reductions | SubTropica on those inputs |
| `r06_virtual_assembly.wls` | Loop measure, continuation, UV/IR separation and virtual coefficients | Independent certificate arithmetic |
| `r07_assembly.wls` | Symbolic UU/UT, explicit convention conversions and comparison exports | Complete arithmetic, coverage and reference checks |

The listed stages may call adapted shared SIDIS programs; the numbered stage wrappers are not an invitation to rewrite that machinery. Shared jobs run once and may cover several projections/sectors. The candidate may implement additional helpers. No native stage stub is installed.

## Context and packet

Each stage is launched with `WolframKernel -noprompt -script <stage>`. Read:

```wolfram
c = Import[Environment["COLLINS_RU_CONTEXT"], "RawJSON"];
```

The context has `schema=5`, `stage`, `production`, `output`, `inputs` (earlier stage IDs to actual result directories), `runtime`, `no_cache=true`, `validation_probe` and `scope`. Write only under `output`. Code and definitions come from `production`; the adapter must use the supplied input directories rather than hard-coded historical run paths.

Write `packet.wl` using `Put`. It must evaluate to an Association with:

- `schema -> 5`, `stage -> current ID`;
- `values -> Association`, normally empty in setup-only stages;
- `evidence -> Association`, containing the native source/derivation graph described below;
- `jobs -> List`, empty except in r01, r02, r04 and r05;
- the stage-specific fields described below.

The validator creates `packet.json` itself in a new native process. Do not create that file or the validator's `native-export/`, job logs, audit outputs or receipts. Mathematical fields in native packets must be **raw Wolfram expressions wrapped in `RUExact[...]`**, not a pre-encoded copy of a reference tree. The installed `common/ru_io.wl` helper contains exact transport definitions only.

Metadata may contain strings, integers, Booleans, lists and associations. The exact expression transport supports rational numbers, symbols, addition, multiplication, rational powers, logs, polylogs of integer weight up to eight, zeta values through weight eight and exact complex numbers. It rejects machine reals and arbitrary text evaluation. Transform unsupported special functions through a justified identity or report the representational limitation; do not approximate them to obtain an exact status.

## Integral-family packets: r01 and r04

`families` is a nonempty list of Associations. Each contains:

- `id`: the exact Kira family head, using ASCII letters/digits and starting with a letter;
- `denominators`: a nonempty list of `RUExact` expressions in a declared independent scalar-product basis;
- `cuts`: **zero-based indices** into that list; nonempty for real families and empty for ordinary virtual families;
- `positive_energy -> True` and `support_artifact -> "relative/path.wl"` for real families, with the actual physical support argument;
- `targets`: a nonempty list of `{powers, numerator, integrand}` associations. `powers` is an integer index vector; the other two fields contain `RUExact` expressions. The checker reconstructs `numerator / product(denominator^power)` and compares it exactly with `integrand`.

Every specified cut must have a positive index in every target and surviving master. Distinguish physical on-shell cuts, measurement deltas and theta boundaries in the supporting derivation. A positive index does not prove that a theta boundary has been handled correctly.

The native Kira auditor reads actual `.m` rules and the final master inventory. A target without an explicit rule must be a declared master. All surviving masters must occur in the final inventory, have the declared number of indices, and retain the specified cuts. This checks the reduction result; it does not prove the physical validity of the integral map.

## Native tool jobs

Each job has `id`, `inputs`, `outputs`, `families` and `sectors`. File paths are relative to `output/jobs/<id>/`. Inputs must exist before execution; outputs must not. Inputs and outputs may not overlap. All declared files must be regular contained files. `families` identifies the mapped family IDs; r01/r04 jobs must collectively cover their family list. `sectors` records the physical uses.

For **Kira**, add `master_inventory`, naming its actual final master-inventory output. Required inputs are:

```text
jobs.yaml
config/integralfamilies.yaml
config/kinematics.yaml
targets
```

Declare any extra inputs such as preferred masters. Outputs must include the actual `results/.../kira_*.m` files and the inventory named by `master_inventory`, for example `tmp/R2/masters`. Do not use wildcards in the job manifest. Generate target bounds and cut declarations from the mapped integrals. The validator runs the configured Kira executable with `--parallel=1 jobs.yaml`, sets `FERMATPATH`, and records the command, exit, input/output hashes and log.

The validator also writes `reduction_certificate.wl` (rules, masters, targets) and `reduction_audit.json`. These are available to the next stage and are added to the evidence graph automatically. They are not candidate-declared outputs and must not exist before the native audit. A parser/format limitation is a blocker, not permission to skip the native check.

For **SubTropica**, required input is `euler_inputs.wl`; required outputs are:

```text
masters.wl
raw_results.wl
subtropica_execution.json
```

The validator runs its own `native_subtropica.wls`; the candidate does not implement an evaluator that can substitute final answers. It uses the SubTropica/HyperIntica invocation and normalization pattern from the approved SIDIS sources, with reuse disabled. The Euler input file evaluates to an Association:

```wolfram
<|"M1" -> <|
  "order" -> 0,
  "terms" -> {
    <|"tuple" -> actualSubTropicaTuple,
      "prefactor" -> derivedRegulatedPrefactor,
      "order" -> 2,
      "assumptions" -> derivedParameterConditions|>
  }
|>|>
```

Use string master IDs. `tuple` has the native `STIntegrate` structure derived from the reduced integral. `terms` permits several Euler contributions to one master. `order` on a term requests the integration depth; `order` on the master requests the result depth after its regulated prefactors. The runner checks SeriesData precision before dropping its order term. It also saves algebraic-letter definitions and raw integration results. Continuation and physical phase factors may be applied in the later native assembly, with explicit evidence.

The native helper explicitly enables `HyperIntica` period evaluation, as the approved SIDIS s10/s13 scripts do. It validates exact scalar representability before writing its local PASS receipt; failed native artifacts are retained. The validator still independently reexports the resulting `masters.wl` Association into exact `masters.json`. A master is identified in coefficient certificates by:

```text
master/r02/<job-id>/<master-id>
master/r05/<job-id>/<master-id>
```

Do not list generated `masters.json`, `tool.log`, native export directories or audit files as candidate inputs/outputs. The native helper currently supports the ordinary Euler classes accepted by the installed SubTropica route. If a required family is outside those capabilities, retain its exact map and report the blocker instead of using a previously evaluated integral as a substitute.

## Exact coefficient certificates

Every `values` entry has a globally unique ID starting with its producing stage, such as `r03/fqq_delta_bare`. The associated object has exactly:

```wolfram
<|"constant" -> RUExact[0],
  "terms" -> {<|"ref" -> "master/r02/quark/M1", "factor" -> RUExact[CF/eps]|>},
  "eta_order" -> 0, "eps_order" -> 0,
  "value" -> RUExact[actualDerivedExpression],
  "sectors" -> {"beam_fqq"}|>
```

The validator independently computes `constant + sum(factor * referenced value)`, expands eta before epsilon to the requested orders, and compares it with the raw native `value`. References may identify evaluated masters or earlier coefficient IDs. Forward references within one packet are allowed if the graph is acyclic. Duplicate terms, missing references and insufficient upstream epsilon depth fail.

Certificates describe the actual contraction/assembly performed by the native code. They must not be invented after copying a final coefficient. A genuinely derived tree term, counterterm or normalization may enter as `constant` with its native derivation in the evidence graph. Do not store an integrated real/virtual answer there merely to remove its master dependence. The fixed-order assembled coefficients are linear in the evaluated masters; perform justified endpoint expansions/conversions before expressing them in this form, and preserve all distribution components separately.

In r03, `integrated_values` must list **every direct real-master contraction**. These entries have zero constant and reference only r02 masters; they are the pre-subtraction integral coefficients used by the Kira dependency test. Subsequent subtraction/renormalization nodes reference them. Select sufficient epsilon depth at each node, retaining O(epsilon) numerator times pole contributions.

## Evidence graph

`evidence` maps stage-prefixed IDs to objects with exactly `path`, `role`, `parents`. The path refers to a nonempty native artifact relative to the current stage output. Parents are evidence IDs from this or an earlier stage, or validator-created IDs:

- `source/r00` through `source/r07` for executed stage sources;
- `tool/<stage>/<job>/<output-path>` for each native job output and audited Kira output.

Each stage's required roles are in `contract.json`. Produce them before its tool jobs; same-stage evidence may not depend on that stage's future tool outputs. Job output nodes automatically descend from that stage's input evidence. The later Euler-input evidence must point to the actual preceding Kira outputs; the later coefficient evidence must point to evaluated masters. Every tool output and stage source must be an ancestor of the final exported evidence.

This is a file/identity and connectivity check. A meaningful physical derivation inside those files remains a source-review requirement. Record fresh input traces and intermediate definitions, not merely text assertions that a calculation was performed.

## r00 conventions and r07 exports

r00 `conventions` must enumerate exactly the keys in `contract.json`. Each entry contains nonempty strings `sidis_source`, `collins_definition`, `conversion`, and an `evidence` ID in the native graph. State explicitly when SIDIS has no polarized analogue. The baseline is the applicable SIDIS convention; the old engine's comparison basis is reached through derived transformations. Describe these in `CONVENTIONS.md`.

r07 `exports` maps every key of `reference_values.json` to `{value, evidence}` IDs. Its inventory is frozen at 167 scalar entries, including zeros and endpoint contacts. Compare in the stated reference basis; Born Mandelstam dependence is compared after imposing `u=-s-t`. This is a comparison to the accepted calculation, separate from the literature-equation audit.

r07 `sector_results` lists native coefficient IDs for each of the eleven required sectors in `contract.json`. Include bare/overlap coefficients when a physical finite remainder vanishes. Every sector must have evaluated-integral ancestry; real and virtual masters must have a nonzero influence on some compared coefficients.

## Dependency probes

At each seed, the validator:

1. Copies the required prefix of a fresh run and scales the **complete audited real reduction map** by a seeded rational factor. This includes the actual Kira right-hand sides and any implicit `M -> M` rule for a target already in the final master inventory. The mutator verifies copied raw rules against the baseline native certificate; it inserts the scaled implicit identities only into a disposable raw-rule copy. The independent Kira auditor regenerates the certificate, and a second native audit requires every resulting rule to equal the seeded factor times its baseline rule, with unchanged targets and master inventory. It then reruns r02-r07. Direct real-master contraction coefficients must scale, evaluated master values must stay unchanged, and downstream assembly must use those new contractions.
2. Changes a nonzero real master in the native `masters.wl`, independently reexports it, and reruns r03-r07.
3. Changes a nonzero virtual master and reruns r06-r07.

The last two probes keep the contraction/assembly recipes fixed and independently predict the complete response. Every probe must change at least one compared coefficient. Ignoring the mutated native result or applying an unrelated direct correction to the final coefficient fails.

These intentionally nonphysical dependency tests can leave uncancelled poles. `validation_probe=true` permits saving those diagnostic expressions instead of stopping at a physical pole-cancellation gate. It never permits changing the computation, recipes, conventions or inventory in an unrelated way. Normal fresh runs have `validation_probe=false` and must pass all ordinary physical comparisons. Probe copies are labelled derived diagnostic inputs, never fresh complete workflows.

## Development and final runs

`workflow.py run --through r03` can exercise a partial implementation. Its success is `DEVELOPMENT_PASS` and cannot be used in official acceptance. Final acceptance requires two different complete runs through r07 with unchanged sources and runtime, seeds 1729 and 92741, and the official comparator. Finish source/document edits before freezing. Put final human reports in the separate review directory named in the agent prompt so writing them does not alter the frozen implementation snapshot.

## v0.5.1 continuation compatibility

Schema 5 packets, job formats, convention inventory, all eleven sectors, all 167 comparison targets and all three probe kinds are unchanged. Existing producing stages need no workaround for this repair. In particular, r03 must continue consuming the full native `reduction_certificate.wl`, including master identities; do not rescale an identity in producing code or remove its legitimate direct-master contribution. `native_mutate.wls` and the new `native_probe_audit.wls` implement the nonphysical probe inside disposable copies.

The new `upgrade.py` writes only a new state's adoption and preservation snapshots. It does not install or change a candidate source, runtime, old state or old validator. Version 0.5.0 runs remain historical; run fresh stages with v0.5.1 before making a new acceptance claim. The separate `native_regression.py` checks real Kira/SubTropica execution, the evaluator's negative control, beta identities and complete-map mutations. It never substitutes for a complete fresh candidate workflow.
