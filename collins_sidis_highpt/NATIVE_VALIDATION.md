# Native validation and reproduction

## Actual completed scope

Reviewed source commit `26b270b3` has one successful fresh r00–r07 run:
`20260916T095719Z-1584d7f6dd71`. It passed 16,416 declared checks and all
16 physical common-boundary comparisons. The second run was cancelled;
dependency probes were cancelled during the initial baseline audit before
master mutation/replay; pair comparison and seed 92741 were omitted.
The campaign is `ENDED_AT_USER_REQUEST`, not a two-run campaign PASS.

See the preserved milestone (retained locally; [publication summary](../collins_support/reports/sidis-highpt-review/README.md))
and artifact index (retained locally; [publication summary](../collins_support/reports/sidis-highpt-review/README.md)).
Original run paths and files are preserved. Copies retain old absolute paths
and old hashes deliberately. Do not rewrite receipts to match this source revision.

The additional 54 virtual residuals are a [separate follow-up](VIRTUAL_COMPARISON_FOLLOWUP.md).
The historical count remains 16,416. Path organization and focused software
checks do not constitute a new native acceptance run.

## Ordinary single run

Use the installation guide and single-run commands in [README.md](README.md).
The validator binds all 34 input identities, freezes the engine, executes the
stages, and writes native receipts. It does not fit inputs or reproduce a figure.
Require `NATIVE_CHECKS_PASS` plus the separate 16-row passing boundary summary.
Run outputs belong under `collins_support/states/runs/`; reports belong under
`collins_support/reports/`. Always choose unused output locations.

## Optional extended campaign

The retained driver performs two full sequential runs, exact pair comparison,
and both real/virtual master probes for seeds 1729 and 92741. This is more
work than ordinary execution and was not completed by the recorded campaign:

```bash
PYTHONDONTWRITEBYTECODE=1 OPENBLAS_NUM_THREADS=1 OMP_NUM_THREADS=1 MKL_NUM_THREADS=1 \
python3 collins_sidis_highpt/tools/checks/run_native_campaign.py \
  --reports collins_support/reports/sidis-highpt-001/extended-new \
  --state collins_support/states/runs/sidis-highpt-extended-new
```

A `probe --seed 1729` command already contains both the real-master and
virtual-master replay. Structural graph inspection is not a substitute for
these dynamic probes. No retired `--accepted-pair` argument is used.
A standalone `audit --run PATH` also performs substantial exact arithmetic;
it is not an installation smoke test. None of these commands was restarted
for publication preparation.

## Qualifications and scheduling history

The scope is leading power in small R and small jT. Scalar checks are
representation dependent, with 13,113 finiteness rows in the recorded run.
All 73 referenced rows, 28 explicit conversions, two operator MISMATCH rows,
33 UNVERIFIED rows, and the independent-physics-review qualification remain.
Saved amplitudes, master integrals and UU banks are reused explicitly.
Reverse unitarity is used for the real phase-space reductions.

Campaign 001 hit the unchanged two-hour r01 limit. The reviewed implementation
moved fresh qgg preparation into r00 of the same run, with r01 consuming its
recorded ancestry, and added parent/child process lifetime handling. Neither
repair changed the formulas or counted the failed attempt as completed.
Virtual supplementary numerics emitted precision warnings but passed their
stated gates; numerical agreement is separate from exact identities.
