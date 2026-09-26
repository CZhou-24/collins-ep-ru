# Direct jet-interface equivalence checks

Inputs are the 15 byte-identical `sources/` fixtures pinned by `source_manifest.json` to
`fd46f4e6b00e4166984faf0fb57bab5369503068`. `jet_algebra.py` supplies the
existing source-algebra helper; fixture Wolfram scripts are read as text and
are never executed as production stages.

Use an existing Python environment with SymPy 1.14.0. From the repository
root, reproduce into an unused directory under `collins_support/reports/`:

```bash
python3 -B collins_support/checks/jet_equivalence/check_equivalence.py \
  --out collins_support/reports/jet-equivalence-replay-001
```

The expected result is **14/14**. All required source inputs are packaged;
no active `/bigTMD` checkout, original ZIP or native run state is required.
`MANIFEST.json` inventories the package and `source_manifest.json` retains its
pinned source identities. Generated outputs stay outside the check directory.
See the [compact review](../../reports/jet-checks-review/README.md) and
[convention note](../../reports/jet-checks-review/JET_EQUIVALENCE_NOTE.md).
No formulas or expected residuals changed.

The 14 checks cover soft, rapidity-scale and Fourier convention relations,
including expected nonzero semi-inclusive corrections. They do not establish
equality of complete jet operators, intrinsic NLO Collins coefficients or full
cross sections, and do not renew native acceptance.
