#!/usr/bin/env python3
"""Locate expensive exact-depth rows without changing validator arithmetic."""
import argparse
import json
import signal
import sys
import time
from pathlib import Path


def main():
    p = argparse.ArgumentParser()
    p.add_argument('directory', type=Path)
    p.add_argument('--output', type=Path, required=True)
    p.add_argument('--row-seconds', type=int, default=10)
    p.add_argument('--max-rows', type=int, default=300)
    args = p.parse_args()
    if args.output.exists():
        raise FileExistsError(args.output)
    root = Path(__file__).resolve().parents[3]
    sys.path.insert(0, str(root/'collins_support/validators/analytic'))
    import algebra
    available = {k: 0 for k in json.loads((args.directory/'masters.json').read_text())}
    packet = json.loads((args.directory/'packet.json').read_text())
    rows = []
    def expired(signum, frame):
        raise TimeoutError('Focused per-row diagnostic time bound')
    signal.signal(signal.SIGALRM, expired)
    for key, recipe in list(packet['values'].items())[:args.max_rows]:
        start = time.monotonic()
        signal.alarm(args.row_seconds)
        try:
            available = algebra.check_precision({key: recipe}, available)
            status = 'PASS'
        except TimeoutError:
            status = 'TIME_BOUND'
        finally:
            signal.alarm(0)
        row = dict(id=key, seconds=time.monotonic()-start, status=status, terms=len(recipe['terms']))
        rows.append(row)
        print(json.dumps(row), flush=True)
        if status != 'PASS':
            break
    args.output.write_text(json.dumps(dict(qualification='Bounded performance diagnostic using unchanged exact depth checker; no complete native acceptance', rows=rows), indent=2)+'\n')


if __name__ == '__main__':
    main()
