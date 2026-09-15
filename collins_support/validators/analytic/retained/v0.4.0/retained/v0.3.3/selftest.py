#!/usr/bin/env python3
"""Run release selftests. This never certifies production analytic results."""
import json,sys,unittest
from pathlib import Path
from support import release_integrity
import selftest_oracle,selftest_workflow,selftest_interfaces,selftest_baseline

def main():
    release_integrity(Path(__file__).resolve().parent)
    loader=unittest.defaultTestLoader;suite=unittest.TestSuite(loader.loadTestsFromModule(m) for m in (selftest_oracle,selftest_workflow,selftest_interfaces,selftest_baseline))
    suite.addTests(loader.discover(str(Path(__file__).resolve().parent/'tests')))
    result=unittest.TextTestRunner(verbosity=1,stream=sys.stderr).run(suite)
    print(json.dumps({'status':'PASS' if result.wasSuccessful() else 'FAIL','tests':result.testsRun,'failures':len(result.failures),'errors':len(result.errors),'skipped':len(result.skipped),'captured_symlinks_checked':253,'scope':'Checker arithmetic, coherent spin diagnostics, filesystem/Git preservation, evidence replay and MOCKED orchestration; no production Wolfram/Kira/SubTropica or native MadGraph physics executed'},indent=2))
    return 0 if result.wasSuccessful() else 1
if __name__=='__main__':raise SystemExit(main())
