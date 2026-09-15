# Derivation completion contract v0.3.0

Read the external validator README, docs/DERIVATION_INTERFACES.md, docs/CONVENTIONS.md and docs/MADGRAPH.md. The installed files intentionally fail until implemented. Keep earlier stages and numerical providers unchanged. New stages must consume upstream definitions and regenerate native results; the comparison JSON is a converted reference-side projection.

SIDIS convention baseline: commit `5062dcb2407594dafcc2f9f72800e96ff9e6d957`. Preserve applicable source conventions. Explicitly document TMD and spin extensions and comparisons in `d14_result/conventions.json`. No correction to a reference equation is implicit.

The stage context is the JSON path in `COLLINS_ANALYTIC_CONTEXT`. It contains `production`, `output`, `inputs` by stage, `runtime` and `derivation_runtime`. Emit `evidence.json` exactly `{schema:1,stage:<id>,run_id:<context run_id>,status:"CANDIDATE_COMPLETE"}` and the required artifacts in `stages.json`. This envelope is not an acceptance result.

Native proof packets use an Association keyed by the stage proof IDs; each entry is `<|"lhs"->HoldComplete[...],"rhs"->HoldComplete[...],"assumptions"->...|>`. Load generated native intermediates and independently formed reference expressions. A `0 == 0` packet, comparison-reference lookup or supplied boolean is not a derivation.

Do not import fitted PDFs/FFs in the analytical workflow. Leave operator matrix elements symbolic. Full off-diagonal twist-three mixing, two-loop derivation and nonsingular matched NLO are excluded, not claimed complete. Preserve every original 70-row audit entry in the final table and crosswalk it to the 31 frozen obligations.
