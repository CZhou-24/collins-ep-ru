# Current local high-pT installation and publication review

The active `/bigTMD` checkout is authoritative. It uses the prepared
`dbca9c383fdb599f1a07cbca5baa714c1f3656df` organization, including the separate
54-comparison follow-up, without a new physics implementation. Both complete
engines are present: `collins_sidis_highpt/` and `collins_ep_analytic_SIDIS/`.
The existing publication checkout is a selected copy for review, not the
authoritative development tree.

The historical accepted record is one full high-pT native run with 16,416
declared checks and 16 boundary comparisons. The current revision declares
16,470 checks and has focused packet/check validation, **not a full native
campaign**. The second historical run and dependency command were cancelled;
pair comparison and the additional seed were omitted. Independent physics
review, the two operator diagnostic MISMATCH rows and 33 UNVERIFIED rows remain.

The original flat engine is preserved in the reviewed Git snapshot, original
review archive and a verified pre-installation backup outside both mirrored
checkouts. Historical run files, receipts, frozen specifications, archive
hashes and verdicts are unchanged. Their recorded source paths and hashes
belong to the old revision and must not be rewritten to match this revision.

The prepared installation/review documents retain the results of preparation
in an isolated worktree, where the separate ep engine was absent. That
limitation is historical: both complete engines are now supplied to the active
and publication checkouts, and the shared base software suite is tested here
with those actual sources. See the current synchronization report for results.

## Installation and execution

See the [engine README](../collins_sidis_highpt/README.md) and
[installation instructions](validators/sidis_highpt_docs/INSTALL.md) for
software dependencies and the ordinary one-run command. Native binaries and
licensed Wolfram/FeynCalc installations remain separately configured in
`collins_ep_analytic_SIDIS/ru_runtime.json`. Working runtime settings are
preserved; the prepared worktree's runtime-only ep directory is never used
as a replacement for a complete engine.

The publication sync copies the exact 24 registered upstream SIDIS files to
their required relative `SIDIS/` paths, alongside the ten engine-local inputs.
It does not copy the entire upstream SIDIS tree or installed tools. Each
registered hash is checked in the publication checkout itself. Native tool
paths in this local review copy refer to existing installations; another
machine needs those tools installed and explicitly configured before a new
run. No new native run or dependency probe was launched for synchronization.

The prepared `tools/checks/check_review_layout.py` also uses Git object
`26b270b3` to compare the original check definitions. This object exists in
the active repository but is not assumed to exist in the separate publication
repository. It is a preparation-specific comparison helper, not a runtime
dependency. The publication copy is checked with its registered manifests,
validator input binding and file identities, without changing that helper.

## Review records

- [Prepared review and move map](reports/sidis-highpt-final-review/README.md)
- [Current install/synchronization report](reports/sidis-highpt-install-001/INSTALL_SYNC_REPORT.md)
- [Reusable local-to-publication commands](reports/sidis-highpt-install-001/RSYNC_COMMANDS.md)

Large original results and detailed evidence remain separately packaged under
`/bigTMD`; their identities are in the compact prepared review. Run states,
caches and Kira databases are excluded from publication transfers. No commit,
push, upload or publication is performed by these synchronization commands.
