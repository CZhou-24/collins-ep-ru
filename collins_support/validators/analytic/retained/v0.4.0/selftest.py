#!/usr/bin/env python3
"""Software tests only. Does not execute or certify native physics derivations."""
import json,sys,unittest
from pathlib import Path
ROOT=Path(__file__).resolve().parent
if __name__=='__main__':
    suite=unittest.defaultTestLoader.discover(str(ROOT/'tests'),top_level_dir=str(ROOT))
    result=unittest.TextTestRunner(verbosity=2).run(suite)
    print(json.dumps({'status':'PASS' if result.wasSuccessful() else 'FAIL','tests':result.testsRun,
        'failures':len(result.failures),'errors':len(result.errors),'scope':'validator software only; no native/NLO acceptance'}))
    raise SystemExit(0 if result.wasSuccessful() else 1)
