# Collins ep reverse-unitarity validation v0.5.1

This is the active installed validator at `/bigTMD/collins_support/validators/analytic`. Use the [project-local support guide](../../README.md) and [relocation report](../../reports/RELOCATION.md) for current commands. Historical report identities remain unchanged; exact recorded path/configuration edits are checked separately. Scientific qualifications are unchanged.

This release supplies a **separate validator and an implementation mission**, not the new physical calculation. The new engine belongs in `/bigTMD/collins_ep_analytic_SIDIS`; the accepted engine remains in `/bigTMD/collins_ep_analytic`.

The installation and implementation mission are complete. `INSTALL.md`, `AGENT_PROMPT.md` and `upgrade.py` document those historical operations; they are not prerequisites for using the existing engine. Do not restore retired downloads or standalone validator releases.

## Repair and continuation

The completed v0.5.1 upgrade restored SubTropica period evaluation, rejected malformed native masters before a local PASS receipt, fixed pair reporting for early BLOCKED inputs, and repaired the complete-map Kira dependency probe. Current execution uses `workflow.py` directly; do not rerun installers over the existing engine. No physics coefficient, convention, source-reuse permission or scientific scope is changed.

`native_regression.py` now runs an actual two-cut Kira reduction and actual SubTropica volume/eikonal integrals, with independent beta/Gamma checks, both seeded map probes and a period-disabled negative control. It needs the existing native installation; the authoring environment could not execute it. See RELEASE_TESTING.md.

## Included machinery

- The accepted v0.4.0 validator and its retained v0.3.3/MadGraph machinery under `retained/v0.4.0`, with only the explicitly recorded relocation edits and corresponding release bookkeeping.
- A frozen list of 20 approved SIDIS source files at commit `5062dcb2407594dafcc2f9f72800e96ff9e6d957`, with source identities and per-file adaptation instructions.
- Eight new stage interfaces, from fresh definitions/amplitudes through cut reduction, master evaluation, virtual integration and formal assembly.
- Validator-owned native Kira and SubTropica execution. Kira rules, target coverage, final master inventory and survival of the specified cuts are checked from actual native output. SubTropica receives unevaluated Euler tuples and saves raw output and evaluated masters.
- Exact arithmetic for integrand reconstruction and coefficient assembly; 167 frozen scalar comparison entries from the accepted engine, including Born, hard, finite matching, HF bulk/contact entries, jet subtraction and symbolic UU/UT assembly. These are scalar entries, **not 167 independently verified literature equations**.
- Two fresh runs, independent native reexports, seeded changes to actual Kira rules and evaluated masters, downstream replay, sealed evidence and a two-report comparator.
- Software tests for arithmetic, path containment, preservation, installation and rejection of malformed, cached or disconnected inputs.

## Acceptance and scope

`CHECKS_PASS` means the specified automated checks passed. It does not automatically grant scientific certification of the operator definitions, physical cut prescription, integration boundaries or derivation completeness. File graphs and exact arithmetic cannot establish the truth of a supplied physical starting point. The source-review questions in `docs/SCIENTIFIC_REVIEW.md` remain mandatory.

The comparison baseline is the accepted v0.4.0 calculation and the declared comparison convention. The implementation's applicable conventions must follow SIDIS; any conversion to the old Collins basis must be explicit. New mathematical disagreements are to be reported, not tuned away.

The inherited scope is the leading-power, Born/one-loop Collins ep treatment with its narrow-cone and physical HF endpoint qualifications. R=1 and unrestricted nonsingular fixed-order NLO remain uncertified. Fitted providers and Figure 6 remain outside this mission. Two-loop calculations are not implemented by adopting reverse unitarity.

The retained MadGraph checks belong to the preserved amplitude implementation. They do not automatically validate newly changed projectors or amplitudes. Such changes need a direct comparison bound to the new outputs and must remain qualified until that comparison is reviewed.

## Files

| File | Purpose |
|---|---|
| `contract.json` | Frozen stages, sectors, conventions, seeds and scope |
| `sidis_reuse.json`, `SIDIS_REUSE.md` | Exact approved upstream source list and adaptation instructions |
| `accepted_v040.json` | Frozen identity of the 1,436 files in the accepted comparison-engine snapshot |
| `reference_values.json` | Exact comparison targets and originating artifact hashes; verification only |
| `workflow.py` | Fresh native stage/tool orchestration and evidence audit |
| `verify_ru.py`, `compare_ru_reports.py` | Native replay, dependency tests and two-seed acceptance |
| `native_kira_audit.wls`, `native_subtropica.wls` | Actual native reduction/master evaluation boundary |
| `algebra.py` | Restricted exact transport and independent certificate arithmetic |
| `upgrade.py`, `install.py` | Continue an existing engine, or add the interface to an absent engine |
| `native_regression.py`, `native_smoke.py`, `selftest.py` | Native integration/mutation regression, transport smoke and software tests |
| `docs/INTERFACE.md` | Complete candidate interface |
| `RELEASE_TESTING.md` | Tests actually run and native checks still requiring the host environment |

The old 1,399-file milestone freeze remains inside the retained validator. The 1,436-file comparison snapshot additionally includes the later accepted NLO implementation; these counts describe different snapshots.
