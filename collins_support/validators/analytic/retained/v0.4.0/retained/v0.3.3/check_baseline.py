#!/usr/bin/env python3
"""Read-only audit of the existing numerical baseline; requires no physics tools."""
import argparse
import json
from pathlib import Path

from support import Blocked, baseline_check, read, release_integrity


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--repo', default='/bigTMD')
    parser.add_argument('--numerical-state', default='/bigTMD/collins_support/baselines/SIDIS-validation-state')
    args = parser.parse_args()
    result = {'scope': 'Original tracked-file preservation only; no physics stages executed'}
    try:
        result['validator_manifest_sha256'] = release_integrity(Path(__file__).resolve().parent)
        result.update(baseline_check(args.repo, args.numerical_state))
        baseline = read(Path(args.numerical_state) / 'baseline.json')
        result['tracked_symlinks'] = sum(row['is_symlink'] for row in baseline['files'].values())
        result['status'] = 'PASS'
        code = 0
    except Exception as exc:
        blocked = isinstance(exc, (Blocked, FileNotFoundError))
        result.update(status='BLOCKED' if blocked else 'FAIL', detail=str(exc))
        code = 2 if blocked else 1
    print(json.dumps(result, indent=2, sort_keys=True))
    return code


if __name__ == '__main__':
    raise SystemExit(main())
