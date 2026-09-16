#!/usr/bin/env python3
"""Apply the unchanged installed native Kira auditor to a focused reduction.

This checks terminal rules, target coverage and surviving physical cuts. It is
not a full stage packet audit or a substitute for native campaign acceptance.
"""
import argparse
import hashlib
import json
import os
from pathlib import Path
import subprocess


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--mapping', type=Path, required=True)
    parser.add_argument('--work', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    root = Path(__file__).resolve().parents[3]
    mapping = (args.mapping / 'kira-input.json').resolve()
    data = json.loads(mapping.read_text())
    work = args.work.resolve()
    out = args.output.resolve()
    out.mkdir(parents=True, exist_ok=False)
    rule_files = sorted(work.glob('results/*/kira_targets.m'))
    inventory = work / 'tmp' / sorted(f['id'] for f in data['families'])[-1] / 'masters'
    families = [dict(id=f['id'],
                     denominators=[f'({p})^2-({m})' for p, m in f['propagators']],
                     cuts=[c-1 for c in f['cut_positions']],
                     targets=[dict(powers=t['powers']) for t in data['targets']
                              if t['family'] == f['id']]) for f in data['families']]
    context = dict(rule_files=[str(p) for p in rule_files],
                   master_inventory=str(inventory), families=families,
                   native_output=str(out / 'certificate.wl'), output=str(out / 'audit.json'))
    context_file = out / 'context.json'
    context_file.write_text(json.dumps(context, indent=2)+'\n')
    runtime_file = root / 'collins_ep_analytic_SIDIS/ru_runtime.json'
    runtime = json.loads(runtime_file.read_text())
    auditor = root / 'collins_support/validators/analytic/native_kira_audit.wls'
    env = os.environ.copy()
    env.update(OPENBLAS_NUM_THREADS='1', OMP_NUM_THREADS='1', MKL_NUM_THREADS='1',
               COLLINS_RU_KIRA_AUDIT=str(context_file))
    with (out / 'execution.log').open('x') as log:
        completed = subprocess.run([runtime['wolfram_kernel'], '-noprompt', '-script', str(auditor)],
                                   env=env, cwd=out, stdout=log, stderr=subprocess.STDOUT,
                                   timeout=runtime['timeout_seconds'])
    identity = dict(exit_code=completed.returncode,
                    source_sha256={str(p):digest(p) for p in [Path(__file__), auditor, runtime_file,
                                                             mapping, inventory, *rule_files]},
                    qualification='Focused terminal rule/cut audit only; numerator reconstruction '
                                  'and complete native workflow remain separate checks')
    (out / 'identity.json').write_text(json.dumps(identity, indent=2)+'\n')
    if completed.returncode:
        raise SystemExit(completed.returncode)
    report = json.loads((out / 'audit.json').read_text())
    if report.get('status') != 'PASS':
        raise SystemExit('Native rule/cut audit did not pass')
    print(json.dumps(report))


if __name__ == '__main__':
    main()
