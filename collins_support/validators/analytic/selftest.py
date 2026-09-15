#!/usr/bin/env python3
"""Validator software tests only. Never grants native or physics acceptance."""
import json,sys,unittest
from pathlib import Path
from ru_support import release_integrity

def main():
    release_integrity()
    suite=unittest.defaultTestLoader.discover(str(Path(__file__).parent/'tests'))
    r=unittest.TextTestRunner(verbosity=2).run(suite)
    print(json.dumps({'status':'PASS' if r.wasSuccessful() else 'FAIL','tests':r.testsRun,'failures':len(r.failures),'errors':len(r.errors),'scope':'validator software only; no native reverse-unitarity or physics acceptance'}))
    return 0 if r.wasSuccessful() else 1
if __name__=='__main__':raise SystemExit(main())
