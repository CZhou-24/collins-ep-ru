# Release testing — v0.4.0

This release supplies validator machinery and an implementation contract. No new d16–d19 physical derivation is shipped or certified.

| Check executed in the release environment | Result and scope |
|---|---|
| Software self-tests | 41 tests passed; exact algebra, distribution actions, deliberate mutations, provenance, output protection and orchestration |
| New report lifecycle | Two mock native workflows, both seeded verification paths and pair replay passed; missing native map entries, changed evidence, scope promotion and retained blockers were rejected |
| Installation against accepted files | Passed on a disposable copy of all 1,399 accepted candidate files and the actual accepted seed reports; only the pair copy's absolute report paths were relocated |
| Additive preservation | All 1,399 hashes unchanged; exactly the transport helper and configuration example added; dry run wrote no candidate/state files and repeat installation refused overwrites |
| Initial doctor result | IMPLEMENTATION_REQUIRED, naming d16–d19; not represented as a physics pass |
| Retained validator identity | Original v0.3.3 file inventory and manifest preserved byte-for-byte |
| Reference arithmetic | Both literal Collins kernels retained with their nonzero discrepancy; no silent replacement of either printed numerator |
| Known finite-term limitation | A common finite shift in both synthetic routes can pass consistency identities; source review remains REQUIRED |

The software environment used Python 3.12.14 and SymPy 1.14.0 (with NumPy 2.3.5 and SciPy 1.17.0 available). These tests use synthetic expressions and mock native processes where explicitly labelled. They do not establish that the new Wolfram stages exist, that a candidate performs a genuine derivation, or that a new NLO coefficient is correct. Use the accepted Python 3.10 campaign environment for the user-side runs; the historical retained request-replay behavior is left unchanged. Do not upgrade the accepted NumPy/SciPy environment just to match this software-test environment.

**Not executed in this environment:** the new native Wolfram transport smoke, fresh FeynArts/FeynCalc/Kira/SubTropica derivations, or fresh MadGraph generation/build/evaluation. Those installed native tools are unavailable here. `native_smoke.py` is supplied as a mandatory short check before the user/agent starts the expensive native mission. The retained MadGraph implementation and its checks are included unchanged, not replaced by a placeholder.

Run the reproducible software suite with:

```bash
python3 /Collins-ep-analytic-validation-v0.4.0/selftest.py
```

Follow `INSTALL.md` for the actual native smoke, additive installation and final two-run/two-seed acceptance. A later source review must assess the finite terms, operator/convention identification, endpoint extension and scalar jet reduction. The R=1 qualification, absence of a closed full twist-three RG system, and distinction from unrestricted fixed-order NLO remain explicit.

The archive's `MANIFEST.json` seals all included files, including the complete retained release. The accompanying SHA256 sidecar identifies the ZIP itself. Self-tests deliberately ignore Python bytecode caches; no generated physics result is excluded from a candidate run's evidence seal on that account.
