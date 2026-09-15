# v0.5.1 release testing

## Executed in the authoring environment

- 111/111 top-level Python software tests passed: all 77 v0.5.0 tests retained unchanged, plus 34 repair tests.
- 41/41 unchanged retained v0.4.0 software tests passed.
- The actual archived early-BLOCKED reports now yield a saved BLOCKED pair with no retained/native replay attempted. Malformed reports and forged incomplete PASS reports still fail, and input/output preservation protections remain.
- Exact Python checks cover the mixed quark reduction with a direct-master term, unchanged evaluated masters, complete-map response scope/coverage, failure to mutate an identity, and rejection of unrelated downstream changes. The native mutation implementation itself still requires the host-native regression.
- New upgrade tests check its new-state-only footprint, no-op dry run, changed old acceptance/adoption/helper, overlapping outputs, previous-release bytes and overwrite refusal. These use controlled fixture identities; no real /bigTMD installation or native environment was claimed here.
- The saved diagnostic cut-volume output was independently compared to its Gamma expansion in SymPy. This checks archived evidence, not a new native evaluation.
- Top-level Python sources parse with Python 3.10 grammar. Tests ran under Python 3.12.14, SymPy 1.14.0, NumPy 1.26.4 and mpmath 1.3.0. Use the original accepted Python 3.10 environment for the user's retained replay.
- Exact byte comparison preserves accepted_v040.json, reference_values.json, literature_inventory.json, sidis_reuse.json, algebra.py, native_io.wl, native_kira_audit.wls and the entire retained validator tree. contract.json changes only its version.

## Required host checks

WolframKernel, Kira and the configured native installations were unavailable in this authoring environment. No new native script, actual integration or complete Collins workflow was executed here. The inspected v0.5.0 bundle supports the evaluator option correction, but it does not replace a fresh test of this release.

Run native_regression.py on the host. It executes the configured Kira on a two-cut family, runs SubTropica on derived volume/eikonal Euler tuples, tests a deliberately period-disabled copy, checks ten exact residuals and both complete-map probe factors. Successful output is NATIVE_REGRESSION_PASS. Its native inputs and beta comparisons follow the pinned SIDIS cut construction and the inspected prior pilot; it does not import a prior master into the evaluation.

The agent must then run the actual producing pilot through r03 with the frozen v0.5.1 helper, complete the measured sectors and obtain two fresh full workflows plus seeded/pair acceptance. Source review and the inherited physical qualifications remain required. Software PASS and the native regression are distinct from full route acceptance.

## Packaging

The release manifest covers every payload file. The ZIP and its SHA-256 sidecar are generated from that manifest and checked after extraction; packaged Python tests and CLI smoke checks are run as the final release gate. Existing source, runtime and historical acceptance files are not changed by the upgrade.
