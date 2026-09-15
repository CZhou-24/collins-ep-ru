#!/usr/bin/env python3
"""Completed historical v0.5.0 adoption command; no reinstallation is needed."""
import argparse,json

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.parse_args()
    print(json.dumps({'status':'HISTORICAL_COMMAND','detail':'The adoption is complete. Retired standalone validators and old root states are not required. See collins_support/reports/RELOCATION.md; use validators/analytic/workflow.py for current execution.'}))
    return 2

if __name__=='__main__':raise SystemExit(main())
