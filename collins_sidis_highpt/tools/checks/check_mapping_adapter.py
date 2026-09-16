#!/usr/bin/env python3
"""Focused official transport/family check; optional runner-owned Kira job.

Existing native map replay is explicitly not a fresh contraction workflow.
"""
import argparse
import hashlib
import json
import sys
from pathlib import Path


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('directory', type=Path)
    ap.add_argument('--execute-reduction', action='store_true')
    args = ap.parse_args()
    root = Path(__file__).resolve().parents[3]
    sys.path.insert(0, str(root/'collins_support'/'validators'/'analytic'))
    import algebra
    import workflow
    rt = dict(config=json.loads((root/'collins_ep_analytic_SIDIS'/'ru_runtime.json').read_text()))
    out = args.directory.resolve()
    execution = workflow.export_native(out/'packet.wl', out/'packet.json', 'packet', rt, out/'native-export')
    packet = json.loads((out/'packet.json').read_text())
    count = algebra.check_families(packet, packet['stage'] == 'r01')
    values, recipes = algebra.evaluate_values(packet, {})
    report = dict(qualification='Focused adapter check of recorded maps; no fresh amplitude contraction or full workflow acceptance',
                  source_sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
                  native_export=execution, reconstructed_targets=count, native_scalar_certificates=len(values))
    (out/'adapter-result.json').write_text(json.dumps(report, indent=2)+'\n')
    if args.execute_reduction:
        report['jobs'] = [workflow.job_execute(dict(id=packet['stage'], tool='kira'), j, out, rt, packet)
                          for j in packet['jobs']]
    report['status'] = 'PASS'
    (out/'adapter-result.json').write_text(json.dumps(report, indent=2)+'\n')
    print(json.dumps({k: v for k, v in report.items() if k not in ('jobs', 'native_export')}))


if __name__ == '__main__':
    main()
