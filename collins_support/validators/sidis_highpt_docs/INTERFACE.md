# High-pT SIDIS adapter interface

## What is implemented

`sidis_highpt.py` owns execution, receipts, source identities, saved-master extraction, exact arithmetic checks, fresh-run comparison and real/virtual dependency probes. It imports `algebra`, `ru_support`, `workflow.job_execute`, `workflow.export_native`, `workflow.graph_add`, and the existing probe arithmetic from the unchanged `analytic/` package. It does not supply polarized amplitudes or physics results.

Files are additive beside `analytic/`, so its manifest remains valid for existing runs. `sidis_highpt_files.json` identifies the new executable files and tests. A necessary change to a new file requires updating that file's extension hash; never change the old manifest to make a new SIDIS result pass.

The specification and all native source files are frozen before each run. Runs live outside the engine and original SIDIS trees. `audit` rejects changed inputs, changed implementation, a different runtime, moved runs, incomplete execution and native failures. Source review is still necessary: provenance and algebraic identities cannot prove that the chosen operators describe the requested observable.

## Project specification

Copy and complete `sidis_highpt_project.example.json` as `collins_sidis_highpt/project.json`. Its containing directory is the implementation root. Set `ready` to `true` after the measurement definition, actual inputs/references and scripts for the requested prefix exist. The example is blocked by construction. A development prefix requires only its scripts; future script paths may be declared before those scripts exist. All eight scripts and the complete channel/check/output inventory are mandatory for r07 and `check-inputs`.

Required scope fields specify Breit frame; hard LO/NLO orders 1/2 in alpha_s; Collins hadron-in-jet; the proton and parton spin bases; the azimuthal harmonic; jet algorithm/radius/approximation; momentum regions; factorization conventions; and a local explanatory document. Resolve these using the requested physics, not by copying the electron–jet recoil formula into another frame.

All six original channel labels must be reviewed before r07. `ut_active` means the channel contributes to the polarized numerator. It does **not** control the unpolarized denominator. `born` records whether that hard channel begins at order alpha_s. For an inactive UT channel, give a reason and a `zero_check` ID. Retain that channel's UU contribution through `uu_source` and `uu_validation` source IDs. An active channel may also reuse its validated UU result. A complete run requires UU exports for every channel, plus UT exports for active channels, at their applicable perturbative orders. During a development prefix, unfinished UT channel assignments can be null and final exports can be empty; at least one active Born channel with all r00 checks is required, and the result is always development-only.

`sources` maps stable identifiers to records:

```json
{
  "root": "sidis",
  "path": "Hqq/s01_result/s01_inputs/s01_result.wl",
  "role": "amplitudes",
  "sha256": "ACTUAL_64_CHARACTER_SHA256",
  "origin": "Repository, revision and meaning of this saved artifact"
}
```

The available roots are `sidis` (the CLI `--sidis-root`) and `engine` (the project directory). Roles are `amplitudes`, `masters`, `reference`, `definitions`, and `unpolarized_result`. Internal SIDIS symlinks are supported; escaping links are rejected. Each file is checked against its declared SHA256 before and after execution. Native Wolfram files are trusted code artifacts, not an untrusted file format.

For reused UU coefficients, `uu_source` must identify an `unpolarized_result` source and `uu_validation` must identify a `definitions` source containing the saved comparison evidence. This records reuse of the established unpolarized result; it does not claim to redo its historical verification. Include a coefficient comparison in the new `uu_recovery` checks as well. Every channel also needs a jet-matching check, including channels with zero UT: importing a verified inclusive partonic coefficient does not by itself implement its jet/hadron measurement.

## Native stages

The same eight-stage arrangement is available, with new process-specific scripts:

| Stage | Work | Runner-owned tools |
|---|---|---|
| r00 | Saved inputs, Breit definitions, Born spin contractions | Wolfram |
| r01 | Polarized real numerators, cut-family maps, Ward checks | Kira |
| r02 | Required real masters, either exact saved imports or new Euler inputs | Extraction and/or SubTropica |
| r03 | Real distributions, endpoint operations and subtractions | Wolfram |
| r04 | Polarized virtual interference and loop-family maps | Kira |
| r05 | Required virtual masters, saved or new | Extraction and/or SubTropica |
| r06 | Virtual normalization and UV assembly | Wolfram |
| r07 | IR/factorization checks, finite hard coefficients and observable assembly | Wolfram |

Each stage reads the JSON path in `SIDIS_HIGHPT_CONTEXT` (also supplied as `COLLINS_RU_CONTEXT`). It contains `production`, `output`, preceding-stage `inputs`, hash-bound `saved_inputs`, the current stage's `master_imports`, `channels`, `export_inventory`, `scope`, `runtime`, `no_cache` and `validation_probe`. Reference sources are excluded from `saved_inputs`.

Stages write only under `output`. They emit `packet.wl` using the existing schema-5 transport, and raw derivation evidence. Load the existing `native_io.wl` to use `RUExact`. The runner executes the protected native reexport, never an engine-supplied JSON-only substitute.

Packets contain:

- `schema: 5` and the exact `stage` ID.
- `values`: exact linear certificates with `constant`, `terms`, `value`, `eta_order`, `eps_order`, `sectors`; all value IDs start with the stage ID and `/`.
- `evidence`: stage-prefixed IDs pointing to nonempty files, with `role` and `parents`. `source/rNN` identifies the script; `input/SOURCE_ID` identifies saved inputs. Later evidence must connect the actual native tool outputs to final results.
- `jobs`: the existing Kira/SubTropica job schema when fresh integration is needed. r01/r04 require actual Kira jobs and `families`; physical real cuts and each rational integrand are checked. Fresh r02/r05 jobs use the unchanged Euler interface.
- At r07, `exports`: exactly the declared names, each mapping to `{"value": "r07/valueID", "evidence": "r07/evidenceID"}`.

Example exact certificate in Wolfram:

```wolfram
<|"constant" -> RUExact[c0],
  "terms" -> {<|"ref" -> "master/r02/cut/M1", "factor" -> RUExact[c1]|>},
  "value" -> RUExact[c0 + c1 actualMaster],
  "eta_order" -> 0, "eps_order" -> 0, "sectors" -> {"Hqq"}|>
```

The values `c0`, `c1` and `actualMaster` must be the calculated expressions from the producing chain. This example is syntax, not a physical coefficient. Do not replace a calculated NLO output with a reference constant. Certificates and regulator-depth checks also apply to intermediate residues and checks. Do not omit epsilon terms needed when multiplied by poles.

`exports` in the project maps each scalar name to `channel`, `sector` (`UU` or `UT`) and `order` (1 or 2). Encode delta/plus/regular pieces as separate scalar coefficients with their distribution definitions in native evidence. Real and virtual master ancestry is checked collectively per new channel/sector, so a particular delta or regular coefficient can correctly have only one kind of contribution. Validated, explicitly imported UU results are exempt from new-master ancestry; their source and earlier verification evidence remain recorded.

Save the symbolic hadronic convolution and its measurement definition as native evidence at r07. The scalar transport is for hard coefficients and check expressions; it is not a general parser for arbitrary PDF/FF functionals.

## Reusing saved masters

Declare selections under `master_imports.r02` or `.r05`. The import ID must not collide with a fresh job ID:

```json
{
  "cut": {
    "source": "saved_cut_bank",
    "selections": {"M1": ["portable", "M1"]},
    "orders": {"M1": 1},
    "definition": "Exact measure, variables, branch, cuts and normalization; why they match the new family",
    "precision_evidence": "Source field or accompanying record proving the available epsilon order"
  }
}
```

Selectors use association string keys and positive, one-based list indices. They are never interpreted as Wolfram code. `sidis_highpt_extract.wls` loads the hash-bound native file, extracts the selected expression and writes `masters.wl`. A top-level exact `SeriesData` in `eps` is accepted only when its retained order exceeds the declared available order, then transported as `Normal`. Plain exact expressions require the saved expansion-depth evidence. No normalization or branch conversion is guessed by the extractor: apply explicit factors/conversions in the producing certificates and document them.

Imported IDs have exactly the same dependency form as fresh masters, for example `master/r02/cut/M1`. Imported master values are recorded as reused, not as fresh integration. Kira still checks the new numerator targets; reuse of a master value does not establish that a new target reduces to it.

## Scientific checks

The specification declares each check's `id`, `kind`, `stage`, `channel`, `lhs` value ID and `reason`. Identity checks have an exact prefix-expression `rhs`. For example:

```json
{"id":"Hqq.realWard", "kind":"ward", "stage":"r01", "channel":"Hqq", "lhs":"r01/HqqRealWardResidual", "rhs":0, "reason":"Photon Ward identity of the polarized real tensor"}
```

`ward`, `uv_poles`, `ir_poles`, `channel_zero`, and `scale_consistency` require RHS zero. `finite` checks reject residual `eps`/`eta`. Additional identity types are `spin_basis`, `normalization`, `factorization`, `jet_matching`, and `identity`. Supply the actual residuals of derived tensors or assembled coefficients, not literal zero placeholders. Scalarize tensor identities component by component with a declared basis. Check inventories are minimum coverage, not a substitute for the complete set of independent coefficients/charge structures.

An active Born channel requires r00 UU recovery, an independent polarized Born reference, Ward, spin-basis and normalization checks. Every active channel also requires a real Ward check at r01 and the applicable NLO pole, factorization, finite and jet-matching checks. Scale consistency means the appropriate RG/factorization identity with its convolution kernels; it does not mean demanding that every hard coefficient be scale-independent.

For `uu_recovery`, `born_reference` and `literature`, give `reference: {"source":"SOURCE_ID", "equation":"KEY"}`. The reference source is a hash-bound JSON file:

```json
{
  "equations": {
    "KEY": {
      "value": ["add", "s", "t"],
      "source_url": "Primary source URL or the independently calculated local reference",
      "location": "Equation or calculation identifier",
      "transcription": "How the literal formula was entered independently of production",
      "independence": "literature"
    }
  }
}
```

The displayed expression is syntax only. Allowed independence labels are `literature`, `independent_calculation`, and `unpolarized_SIDIS`; the polarized Born reference cannot use the last label. A separately coded physical spinor/Clifford or helicity calculation is a valid Born comparison if it does not load the production answer. `reference_substitutions` apply symbol substitutions only to the reference; a nonempty map requires a written `conversion`. Keep original references literal and conversions explicit. A comparison status cannot be made to pass by changing a reference to match production.

The checker recomputes certificate arithmetic with the existing exact decoder. A packet's `status: PASS` has no authority. An unrecognized function/transport form is an explicit interface limitation to resolve with a tested extension, not permission to approximate it silently.

## Acceptance and dependency probes

`DEVELOPMENT_PASS` means a prefix completed and its applicable checks passed. `NATIVE_CHECKS_PASS` means all declared checks, exact finite exports, receipts and dependency coverage passed for one completed calculation. It is not a claim of independent physical certification. Every result retains `independent_physics_review: PENDING`.

`pair` re-audits two distinct fresh runs with identical source/runtime/specification identities and compares every exported coefficient exactly. `probe` tests one real and one virtual master per seed. It mutates copied evaluated master files, reruns downstream native stages and compares the result with the predicted algebraic response using unchanged assembly recipes. It detects stale answers, ignored masters and direct answer adjustments. The original current-profile Kira-rule mutation campaign remains intact; the new command adds real/virtual master probes for this new route and does not claim to renew the old campaign.

A deliberately altered master can spoil a Ward/pole/reference identity. Stages should emit those calculated residuals; leave their final acceptance to the validator. During a probe, identity failure is expected and the validator checks the precise dependency response instead. `validation_probe` must never select different generating formulas or force a desired response. Native errors, missing outputs, source changes, reconstruction errors and precision errors remain failures.

No native result is included with this update. The tests use synthetic algebra and explicitly mocked native tools for control-flow coverage. Real Wolfram/Kira/SubTropica execution is a required gate for the implementation agent.
