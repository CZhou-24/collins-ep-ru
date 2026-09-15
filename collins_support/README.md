# Collins support inside the project

The active analytical validator is `validators/analytic/`. Its required v0.4.0 and v0.3.3 checkers remain nested under `retained/`; no separate validator release or root compatibility link is required. Engines remain in `../collins_ep_analytic_SIDIS/` and `../collins_ep_analytic/`.

Use [reports/RELOCATION.md](reports/RELOCATION.md) for exact changed files, origin identities, final replay/run locations, verification outcomes and scientific qualifications. The relocation changes filesystem access and configuration; analytical formulas, coefficients, tolerances and scope qualifications remain unchanged.

| Location | Role |
|---|---|
| `validators/analytic/` | Current RU workflow and official comparator, with retained analytical checks |
| `validators/numerical/` | Optional numerical validator; currently absent and not reinstalled |
| `states/Collins-ep-analytic-state-*/` | Moved historical states with original reports and hashes |
| `states/runs/` | Future workflow output under a chosen run ID |
| `states/relocation-check/` | The bounded fresh relocation workflow |
| `baselines/` | Moved SIDIS analytical/numerical baseline evidence |
| `phenomenology/` | Existing moved Figure 6/physical-review evidence; no new fitted campaign |
| `reports/` | Current reports and relocation evidence |

From `/bigTMD`:

```bash
export PYTHONDONTWRITEBYTECODE=1
export OPENBLAS_NUM_THREADS=1 OMP_NUM_THREADS=1 MKL_NUM_THREADS=1
export COLLINS_PYTHON=/usr/bin/python3.10
export COLLINS_VALIDATOR=/bigTMD/collins_support/validators/analytic
"$COLLINS_PYTHON" "$COLLINS_VALIDATOR/workflow.py" doctor --repo /bigTMD
"$COLLINS_PYTHON" "$COLLINS_VALIDATOR/workflow.py" run --repo /bigTMD \
  --state collins_support/states/runs/my-run --through r07
```

Choose a new run ID. The workflow prints the actual generated run path. Full two-run/two-seed reproduction is available via `collins_ep_analytic_SIDIS/tools/reproduce_organization.py --state collins_support/states/runs/<unused run ID>` from `/bigTMD` when separately requested. Its seed/pair reports default to `collins_support/reports/organization-<run ID>`; `--reports` selects another unused current-report directory. It is larger than the bounded relocation verification.

Historical JSON, reports, manifests and logs retain their original path strings and hashes. `paths.py` resolves complete prefixes through `relocation-map.json`, preserves suffixes and rejects escapes, ambiguous destinations and missing required inputs. Current runtime configurations use project-relative paths for moved inputs. Historical identities are checked through the exact recorded source/configuration changes; mathematical bytes and coefficient data remain protected.

Wolfram, FeynCalc/FeynArts, Kira, Fermat, SubTropica/HyperIntica and system installations remain at their existing external/configured locations. MadGraph remains inside `states/Collins-ep-analytic-state-v0.3.0/native-runtime/`. The original SIDIS/partial-fraction sources stay in place.

Completed install/upgrade prompts and archival packaging/preservation commands describe historical operations. Do not reinstall absent retired packages, run the abandoned dependency-migration adapter, or create root-level support directories. Use the installed local workflow and comparator; see the relocation report for the exact replay command.
