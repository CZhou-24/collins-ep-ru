# Milestone — reverse-unitarity-003

**Final pair verdict: CHECKS_PASS**, using `reverse_unitarity_current`. This is current regression verification; historical acceptance was not replayed.

`selftest.py`: 101 tests passed, 0 failures, 0 errors. `workflow.py doctor`: `READY_TO_EXECUTE`. All seven official commands exited zero; [commands, timestamps and log hashes](campaign.json).

Two new workflows ran sequentially through r07 with single-threaded BLAS. All 16 stage contexts declare `no_cache=true` and `validation_probe=false`. Each workflow executed three Kira and three SubTropica jobs. The [live process observation](live-thread-observation.json) also records thread limits and the no-cache environment.

| Fresh run | Result | Reference comparisons |
|---|---|---:|
| `20260915T063100Z-b8feba4db8fd` | STAGES_PASS | 167/167 |
| `20260915T063447Z-d46543c6f44c` | STAGES_PASS | 167/167 |

At restart, `main-cleanup` and the stopped attempt directories were absent, and no workflow/verifier/Wolfram process was running. Neither was used or counted. Its earlier terminal status was observed in the preceding session; that is not fresh evidence for this campaign.

The 167 scalar results are **165 EXACT** and **2 EXACT AFTER EXPLICIT CONVERSION**, with zero mismatches. Each run/reference residual and every A−B residual is exactly zero. No floating-point tolerance or numerical sampling was used. The two Born comparisons apply `u=-s-t` to both sides; all other entries match in the existing exported comparison basis.

The [167-row scalar table](SCALAR_COMPARISON.md), [expressions side by side in CSV](SCALAR_COMPARISON.csv), and [exact trees/residuals/source bindings in JSON](SCALAR_COMPARISON.json) retain every entry. Delta, plus and regular coefficients are separate rows. [Explicit convention notes](CONVENTION_CONVERSIONS.md) preserve all 15 fresh r00 statements and the r07 conversion evidence. These scalar entries include shared zero aliases and are not 167 independent derivations.

| Seed | Report | Checks | Native packet / master-group reexports |
|---|---|---:|---:|
| 1729 | CHECKS_PASS | 182/182 | 8 / 3 |
| 92741 | CHECKS_PASS | 182/182 | 8 / 3 |

| Seed | Dependency probe | Factor | Changed exports | Result |
|---|---|---|---:|---|
| 1729 | `kira_real_rules` | `11/6` | 25 | PASS |
| 1729 | `real_master` | `11/6` | 25 | PASS |
| 1729 | `virtual_master` | `11/6` | 5 | PASS |
| 92741 | `kira_real_rules` | `4/3` | 25 | PASS |
| 92741 | `real_master` | `4/3` | 25 | PASS |
| 92741 | `virtual_master` | `4/3` | 5 | PASS |

For each seed, the complete Kira reduction-map response has seven exact-zero residuals: three quark rules and four measured rules, including one identity rule in each job. The master probes select `r02/measured/FixedRadiusSphere` and `r05/virtual/B`. Deliberately mutated copied inputs feed fresh downstream execution; these probes are not additional fresh baseline workflows. [Native evidence, selected masters and complete changed-export lists](native-evidence.json).

Both seeds bind the same two fresh runs. The official pair comparator recomputed both reports, reference arithmetic and probe responses, and checked report/evidence hashes and run/source/runtime bindings. Native packet/master reexports were executed by Wolfram during each seed verification. No retired `--accepted-pair` argument was supplied.

Source/runtime integrity: **PASS**. The 108-entry engine snapshot, 33-entry validator snapshot, path support, all 20 pinned SIDIS source entries, runtime identities, references and qualifications were unchanged: [before](integrity-before.json), [after](integrity-after.json), [comparison](integrity-comparison.json). Runtime records include Wolfram, Kira, Fermat, SubTropica, FeynCalc/FeynArts, polymake, Python and SymPy.

Validator manifest SHA-256: `c016a289ceb0dbe5019373efcc23fea7d23f5adc5efed8664610f63663e0ecd3`. Frozen scalar reference SHA-256: `2bd3deea176c3ae00413118d3d7fde9f393dfa242650ed24245c0af196477ef6`.

Scientific qualifications remain: Born plus one loop, leading power and narrow cone; shared source/operator definitions and conditional polarized/Fourier conversions limit independence. Generic HF contacts, R=1 accuracy, unrestricted nonsingular fixed-order NLO, NNLO and closed full twist-three evolution remain uncertified. Hadronic inputs remain symbolic; no fitting, Figure 6 or new MadGraph certification was performed. Source review is still required.

The preserved historical literature inventory remains 14 EXACT, 35 EXACT AFTER EXPLICIT CONVERSION, 4 MISMATCH and 32 UNVERIFIED. Those statuses were not retested or promoted. Regression agreement does not certify broader physical accuracy or renew historical acceptance.

No failures occurred, no scientific sources/references/tolerances were patched, and no cleanup or GitHub push was performed. [Official reports and logs](../../collins_support/reports/reverse-unitarity-003/) and [reproduction record](REPRODUCE.md).
