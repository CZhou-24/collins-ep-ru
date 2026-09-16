#!/usr/bin/env python3
"""Export intermediate Kira rules from the same completed native database.

This does not insert archived rules or accept a residual master without a rule.
Symbolic substitution and coefficient checks are performed by the native checker.
"""
import argparse
import hashlib
import json
import os
import re
import subprocess
from pathlib import Path

import yaml

ATOM = re.compile(r'[VR]\d+\[[\d, -]+\]')


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def rhs_atoms(path):
    raw = path.read_text().strip()[1:-1]
    rows = re.split(r',\s*(?=[VR]\d+\[)', raw)
    return {atom for row in rows if '->' in row
            for atom in ATOM.findall(row.split('->', 1)[1])}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--work', type=Path, required=True)
    args = ap.parse_args()
    work = args.work.resolve()
    identity = json.loads((work / 'identity.json').read_text())
    runtime = identity['runtime']
    names = sorted(identity['bounds'])
    declared = set(ATOM.findall((work / 'tmp' / names[-1] / 'masters').read_text()))
    frontier = set().union(*(rhs_atoms(p) for p in work.glob('results/*/kira_targets.m'))) - declared
    records = []
    env = os.environ.copy()
    env.update(FERMATPATH=runtime['fermat'], OMP_NUM_THREADS='1', OPENBLAS_NUM_THREADS='1', MKL_NUM_THREADS='1')
    for attempt in range(1, 6):
        if not frontier:
            break
        name = f'closure_{attempt}'
        target = work / name
        with target.open('x') as handle:
            handle.write('\n'.join(sorted(frontier)) + '\n')
        job = work / f'{name}.yaml'
        with job.open('x') as handle:
            yaml.safe_dump({'jobs': [{'kira2math': {'target': [[name]]}}]}, handle, sort_keys=False)
        with (work / f'{name}.stdout.log').open('x') as stdout, (work / f'{name}.stderr.log').open('x') as stderr:
            proc = subprocess.run([runtime['kira'], '--parallel=1', job.name], cwd=work, env=env, stdout=stdout, stderr=stderr)
        files = sorted(work.glob(f'results/*/kira_{name}.m'))
        new_frontier = set().union(*(rhs_atoms(p) for p in files)) - declared if files else frontier
        records.append(dict(targets=sorted(frontier), exit_code=proc.returncode,
                            source_sha256=sha(Path(__file__)), files={str(p.relative_to(work)): sha(p) for p in files},
                            remaining=sorted(new_frontier)))
        (work / f'{name}.json').write_text(json.dumps(records[-1], indent=2) + '\n')
        if proc.returncode or not files or new_frontier == frontier:
            raise SystemExit('Intermediate export did not close; inspect retained native logs')
        frontier = new_frontier
    summary = dict(closed=not frontier, remaining=sorted(frontier), exports=records,
                   qualification='Supplementary export from the fresh Kira database; symbolic composition still required')
    with (work / 'export-closure.json').open('x') as handle:
        json.dump(summary, handle, indent=2)
        handle.write('\n')
    print(json.dumps(summary))
    if frontier:
        raise SystemExit(2)


if __name__ == '__main__':
    main()
