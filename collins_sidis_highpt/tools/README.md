# Helper organization

`common/r00.wls`–`r07.wls` remain the public stage entry points.

| Directory | Actual usage |
|---|---|
| `pipeline/` | 35 helpers reached by the native producing chain, plus `build_project.py` and `native_project_spec.py` for its input/check declarations |
| `checks/` | Standalone comparisons, diagnostic exporters, reporting utilities and software tests; the extended campaign driver is optional |
| `development/` | Retained input/reference preparation, early partial-sector pilots and alternative assembly/transport routes; not the default r00–r07 execution chain |

Names such as `pipeline/check_real_reduction.wls`,
`pipeline/check_native_boundary_series.wls` and `pipeline/jet_matching_check.wls`
are production dependencies. They were classified by their callers rather
than their names. Common Wolfram physics definitions remain in `common/`.

The complete old-to-new map (retained locally; [publication summary](../../collins_support/reports/sidis-highpt-review/README.md))
and its usage/hash record (retained locally; [publication summary](../../collins_support/reports/sidis-highpt-review/README.md))
describe every moved helper. Direct helper paths change; stage paths do not.
Fixed-depth root discovery was adjusted by one directory. Python imports
remain local to their category; cross-category diagnostic calls use explicit
paths. Wolfram `Get` paths and project provenance descriptions are updated.

## Retained development routes

- `reproduce_development.py` runs r00 and selected diagnostics, with optional
  partial RealDistinct calculation. It never replaces a full r00–r07 run.
- `pilot_born.wls`, `nlo_pilot.wls`, `real_map_pilot.wls` and
  `real_distinct_assembly.wls` retain early/partial calculations.
- Alternative tensor, pair, monomial and streaming maps retain experiments
  preceding `pipeline/project_collins_pairs.wls` and `map_collins_linear.wls`.
- Alternative hard assembly/color/polynomial and transport helpers preserve
  representation experiments preceding `pipeline/assemble_native_hard_compact.wls`.
- Input/master/reference preparation helpers preserve how current registered
  representations were constructed. Ordinary runs consume the pinned inputs
  rather than regenerate or download references. Historical output directories
  in these helpers are deliberate provenance defaults; supply fresh explicit
  output/context paths before optional use. Some initial setup scripts write
  pinned inputs, so they are not installation steps.

`checks/run_native_campaign.py` retains the original two-run, pair and
two-seed protocol. It is an optional extended campaign, separate from the
recorded single-run scope. Do not run it merely to install or review paths.
