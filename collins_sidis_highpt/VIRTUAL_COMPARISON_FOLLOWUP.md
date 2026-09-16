# Separate 54-check virtual-comparison follow-up

The reviewed run saved 18 generic, 18 plus and 18 minus comparison residuals
as exact integer zeros. Its 16,416 declared checks did not include these
54 residuals. The original count, receipts, sources and verdicts are unchanged.
See the original supplement (retained locally; [publication summary](../collins_support/reports/sidis-highpt-review/README.md)).

This separate source revision exports the producer-calculated
`comparison_residuals` in `tools/pipeline/emit_native_mapping_packet.wls`
and appends 54 zero-target `identity` checks via
`tools/pipeline/native_project_spec.py`. The generated `project.json` now
has **16,470** checks. The previous 16,416 definitions, 13,113 exports,
physics helpers, registered input hashes, references, and tolerances remain
unchanged. No candidate answer or hard formula has been substituted.

`SIDIS_LINEAR_CHECK_COMPARISON=false` remains intentional: the producer saves
actual residuals for nominal and master-mutated runs; the existing validator
enforces zero for nominal runs and can record failures in probe mode. The
emitter rejects missing/extra residual names but does not assert zero itself.
There is no validator source or manifest change.

## Focused checks completed

The focused result (retained locally; [publication summary](../collins_support/reports/sidis-highpt-review/README.md))
records receipt-verified original full certificate hashes and all settings:

- Actual saved generic/plus/minus certificates yielded 54 exact integer-zero
  values through the changed emitter and unchanged native exporter/checker.
- Every pre-existing r06 packet value and all packet metadata compared
  identically to the original unpartitioned packet.
- Synthetic `1/7` residuals injected into one entry of each branch survived
  emission unchanged. Nominal enforcement rejected all three; probe-mode
  checking returned three FAIL and 51 PASS rows without an unconditional
  producer abort. This tests the interface, not master dependence.
- Missing and extra residual names were rejected by the emitter.
- The original full input files remained byte-identical. Layout, Python and
  Wolfram syntax checks passed; project regeneration was byte-idempotent.

To reproduce only these focused tests using the full original run or the
`original-run/` subset in the separate follow-up evidence artifact:

```bash
PYTHONDONTWRITEBYTECODE=1 OPENBLAS_NUM_THREADS=1 OMP_NUM_THREADS=1 MKL_NUM_THREADS=1 \
python3 collins_sidis_highpt/tools/checks/check_virtual_comparisons.py \
  --run /path/to/original-run \
  --output collins_support/reports/sidis-highpt-001/virtual-followup-new
```

The command emits packets from saved inputs and uses synthetic residual
injections for rejection tests. It does not run the native stage driver,
Kira, contractions, master mutation, or the full arithmetic audit. Existing
files are read only; a new external output directory is required.

**Not performed:** a full native run with this 16,470-check revision, pair
comparison, either dependency replay, or independent physics review. These
focused results are separate from the historical single-run acceptance and
cannot be represented as completion of the cancelled original campaign.
