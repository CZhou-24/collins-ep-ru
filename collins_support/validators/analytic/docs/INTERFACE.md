# Current execution interface

`workflow.py` supplies the schema-5 context for each native stage and runs fresh Kira/SubTropica jobs. The stage contract, packet format, integral reconstruction, positive-energy cut support, ordered eta/epsilon expansion, exact comparison expressions and native dependency probes retain their existing definitions.

Native outputs are regenerated in a fresh run directory. Jobs cannot prepopulate required outputs or change their declared inputs. Receipts record native execution, input/output hashes and tree snapshots. The final audit requires connected real and virtual master ancestry, all declared sectors and conventions, and agreement with the complete scalar reference inventory.

Top-level runs and reports use `profile: reverse_unitarity_current`. This profile does not replay historical validators or require their state trees. Historical `reverse_unitarity` reports must not be presented as results of the current profile. Native packet/context schema remains 5, so the producing Wolfram code is unchanged.

Paths are relative to the current checkout unless a native tool has an absolute configured path. Outputs are restricted to `collins_support/states/runs/` and `collins_support/reports/`; existing reports and protected inputs cannot be overwritten by launch commands.

See [runner commands](../../../README.md) and [scientific qualifications](SCIENTIFIC_REVIEW.md). The latter records the historical scientific review, not a fresh execution of this packaging revision.
