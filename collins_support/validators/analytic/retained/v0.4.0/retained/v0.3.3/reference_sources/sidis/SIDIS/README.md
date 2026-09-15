# SIDIS through NLO with reverse unitarity

All six channels have final symbolic F hats from the new integral workflow. The [BigTMD comparison](bigTMD_comparison/s04_result.md) passes all 60 exact comparisons and all 120 high-precision checks, under its stated rational-reference reconstruction and comparison conventions.

## What is in this folder

| Folder | Contents |
|---|---|
| [Hqq](Hqq/README.md) | Incoming quark, observed same-flavor quark; 17 consecutive stages |
| [Hqg](Hqg/README.md) | Incoming quark, observed gluon; 17 consecutive stages |
| [Hgq](Hgq/README.md) | Incoming gluon, observed quark; 17 consecutive stages |
| [Hgg](Hgg/README.md) | Incoming gluon, observed gluon; 11 consecutive stages |
| [Hqqbar](Hqqbar/README.md) | Incoming quark, observed same-flavor antiquark; 11 consecutive stages |
| [Hqqprime](Hqqprime/README.md) | Incoming quark, observed distinct-flavor quark; 11 consecutive stages |
| [common](common/README.md) | Shared programs, Kira reductions, SubTropica masters, software and shared previous runs |
| [bigTMD_comparison](bigTMD_comparison/README.md) | The explicitly requested comparison folder: frozen reference inputs, fresh differences, proof caches and reports |
| [numerics](numerics/README.md) | Numerical convolution of the SIDIS F hats, frozen PDF/fragmentation and experimental inputs, and the requested cross-section and ratio plots |
| `.cluster` | Cluster connection and execution support files |

Channel-specific superseded runs are in each channel's `previous_runs/`. Former root folders such as `s03_previous_14692745` are in `common/previous_runs/`. Valid production and proof caches are retained with their owning stage. There are no other top-level folders.

## Final F hats

| Channel | Full result and conventions | F1 hat | F2 hat |
|---|---|---|---|
| Hqq | [result](Hqq/s17_result/s17_result.wl) | [F1](Hqq/s17_result/s17_F1_hat.wl) | [F2](Hqq/s17_result/s17_F2_hat.wl) |
| Hqg | [result](Hqg/s17_result/s17_result.wl) | [F1](Hqg/s17_result/s17_F1_hat.wl) | [F2](Hqg/s17_result/s17_F2_hat.wl) |
| Hgq | [result](Hgq/s17_result/s17_result.wl) | [F1](Hgq/s17_result/s17_F1_hat.wl) | [F2](Hgq/s17_result/s17_F2_hat.wl) |
| Hgg | [result](Hgg/s11_result/s11_result.wl) | [F1](Hgg/s11_result/s11_F1_hat.wl) | [F2](Hgg/s11_result/s11_F2_hat.wl) |
| Hqqbar | [result](Hqqbar/s11_result/s11_result.wl) | [F1](Hqqbar/s11_result/s11_F1_hat.wl) | [F2](Hqqbar/s11_result/s11_F2_hat.wl) |
| Hqqprime | [result](Hqqprime/s11_result/s11_result.wl) | [F1](Hqqprime/s11_result/s11_F1_hat.wl) | [F2](Hqqprime/s11_result/s11_F2_hat.wl) |

Keep each full result with its direct F1/F2 files: it defines kinematics, charges, scales, support, plus distributions and branch limits. Colors, flavors, charges and kinematics remain symbolic in production. The comparison fixes the reference's SU(3) convention and retains the complete coefficient functions; the existing public-driver omissions are explained in its reports.

## Actual workflow

**Real:** FeynArts → FeynCalc → reverse unitarity → Kira → SubTropica → factorization and final F-hat projection.

**Virtual and self energies:** FeynArts → FeynCalc → Kira → SubTropica → UV renormalization and final assembly.

The generated amplitudes, unintegrated contractions, Born/projector definitions and loop-independent factorization inputs are preserved from the six existing channels with exact file hashes. They were reused wherever unchanged. Both positive-energy cut propagators are retained in the real Kira targets and masters. SubTropica evaluates the required cut Euler integrals, soft regions, virtual masters and self-energy masters. The cut constraints, parameter measures, normalization, analytic continuation and regulator orders are checked in the programs.

The supplied standalone reverse-unitarity reference supplies the integration interfaces. The SIDIS paper supplies the observable and F-hat conventions. Its evaluated angular tables and Package-X/PaVe values are not the integration backend here. Algebraic removal of dependent propagators only constructs valid Kira families.

IR pole cancellation passed for every required channel/projector/component before the final projection. The core channels also passed the common branch-boundary gates. The inherited Hgq MadGraph sign-comparison caveat remains separate from the passed coefficient comparison.

## Files and execution

Each channel has consecutive `sNN_<program>` links and `sNN_result/` directories. The programs point to the shared implementation in `common/`; shared stages run once for their applicable channel group. Each channel README gives the exact stage map and full physics/convention ledger. Shared source numbers retain their original execution identities.

Physics ran on Hoffman2 compute nodes with scheduler allocations, bounded operations, process-tree RSS guards and persistent monitors. Local folders retain the main sources, results, logs, Kira databases, raw SubTropica outputs and resumable caches. The two BigTMD algebra jobs peaked at 2325.1 MiB and 1511.3 MiB respectively; no OOM occurred.

The [layout manifest](common/s21_result/layout.json) records every move and both original and relocated source hashes. Accepted result bytes are unchanged. Original executed sources are preserved in `common/previous_runs/layout_sources/`; `common/s22_paths.wl` maps their recorded paths and checks current source identities. Only `../progress.md` is the live status record.
