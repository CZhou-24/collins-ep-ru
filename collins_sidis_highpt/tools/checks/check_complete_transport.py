#!/usr/bin/env python3
"""Focused exact check using the native whole-packet dependency resolver."""
import argparse
import hashlib
import json
import sys
from pathlib import Path


def main():
    p = argparse.ArgumentParser()
    p.add_argument('directory', type=Path)
    args = p.parse_args()
    root = Path(__file__).resolve().parents[3]
    sys.path.insert(0, str(root/'collins_support/validators/analytic'))
    import algebra
    import workflow
    out = args.directory.resolve()
    rt = dict(config=json.loads((root/'collins_ep_analytic_SIDIS/ru_runtime.json').read_text()))
    report = dict(qualification='Focused complete packet arithmetic and precision only; no fresh workflow acceptance',
                  source_sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest())
    for mode in ('masters', 'packet'):
        report[mode+'_export'] = workflow.export_native(out/(mode+'.wl'), out/(mode+'.json'), mode, rt, out/(mode+'-native-export'))
        (out/'result.json').write_text(json.dumps(report, indent=2)+'\n')
    masters = {k: algebra.decode(v) for k, v in json.loads((out/'masters.json').read_text()).items()}
    packet = json.loads((out/'packet.json').read_text())
    print('EXACT_PACKET_ARITHMETIC_START', len(packet['values']), flush=True)
    values, recipes = algebra.evaluate_values(packet, masters)
    print('EXACT_PACKET_ARITHMETIC_PASS', len(values), flush=True)
    print('EXACT_PRECISION_START', flush=True)
    algebra.check_precision(recipes, {k: 0 for k in masters})
    report.update(status='PASS', masters=len(masters), certificates=len(values))
    (out/'result.json').write_text(json.dumps(report, indent=2)+'\n')
    print(json.dumps({k: v for k, v in report.items() if not k.endswith('_export')}), flush=True)


if __name__ == '__main__':
    main()
