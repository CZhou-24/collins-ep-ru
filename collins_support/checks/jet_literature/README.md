# Jet literature comparison

`check_jets.py` compares parsed source formulas with the existing reference
expressions. Inputs are the eight byte-identical `sources/` fixtures listed
in `source_manifest.json` at revision
`fd46f4e6b00e4166984faf0fb57bab5369503068`, plus
`archived_ep_values.json`. In particular, `sources/.../r07_assembly.wls`
is a pinned test fixture, not a runnable production stage.

Use an existing Python environment with SymPy 1.14.0. From the repository
root, choose an unused output directory under `collins_support/reports/`:

```bash
python3 -B collins_support/checks/jet_literature/check_jets.py \
  --out collins_support/reports/jet-literature-replay-001
```

The expected result is **74/74**. The source snapshots and small archived-value
input are included in this package; no active `/bigTMD` checkout, original ZIP,
native run directory, Wolfram installation or network download is needed.
Generated outputs stay outside this directory. `MANIFEST.json` inventories the
current package; `source_manifest.json` retains the pinned fixture identities.

See the [compact jet-checks review](../../reports/jet-checks-review/README.md)
for publication-checkout results and qualifications. Formulas, tolerances and
expected results are unchanged. Source algebra and selected archived-value
agreement do not certify a native run, complete Collins OPE or finite-radius
physics.
