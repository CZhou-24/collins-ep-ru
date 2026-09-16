#!/usr/bin/env python3
"""Use the unchanged native exporter and exact certificate arithmetic locally.

This focused interface check does not create or assert a native workflow pass.
"""
import argparse
import hashlib
import json
import os
import subprocess
import sys
from pathlib import Path


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('directory', type=Path)
    args = ap.parse_args()
    root = Path(__file__).resolve().parents[3]
    validator = root/'collins_support'/'validators'/'analytic'
    sys.path.insert(0, str(validator))
    import algebra
    out = args.directory.resolve()
    rt = json.loads((root/'collins_ep_analytic_SIDIS'/'ru_runtime.json').read_text())
    evidence = dict(qualification='Focused native transport and exact algebra only; no native workflow acceptance',
                    source_sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest())
    for mode in ('masters', 'packet'):
        cp = out/(mode+'-context.json')
        cp.write_text(json.dumps(dict(input=str(out/(mode+'.wl')), output=str(out/(mode+'.json')), mode=mode), indent=2)+'\n')
        env = os.environ.copy()
        env.update(COLLINS_RU_REEXPORT=str(cp), OPENBLAS_NUM_THREADS='1', OMP_NUM_THREADS='1', MKL_NUM_THREADS='1')
        with (out/(mode+'-export.log')).open('x') as stream:
            result = subprocess.run([rt['wolfram_kernel'], '-noprompt', '-script', str(validator/'native_reexport.wls')],
                                    env=env, stdout=stream, stderr=subprocess.STDOUT)
        evidence[mode+'_exit_code'] = result.returncode
        (out/'result.json').write_text(json.dumps(evidence, indent=2)+'\n')
        if result.returncode:
            raise SystemExit('Native transport failed: '+mode)
    masters = {k: algebra.decode(v) for k, v in json.loads((out/'masters.json').read_text()).items()}
    packet = json.loads((out/'packet.json').read_text())
    values, recipes = {}, {}
    for key, value in packet['values'].items():
        print('EXACT_CERTIFICATE', key, flush=True)
        current, current_recipes = algebra.evaluate_values({'values': {key: value}}, dict(masters, **values))
        values.update(current)
        recipes.update(current_recipes)
        print("EXACT_CERTIFICATE_DONE", key, flush=True)
    print("EXACT_PRECISION_START", len(recipes), flush=True)
    algebra.check_precision(recipes, {k: 0 for k in masters})
    evidence.update(status='PASS', masters=len(masters), certificates=len(values))
    (out/'result.json').write_text(json.dumps(evidence, indent=2)+'\n')
    print(json.dumps(evidence))


if __name__ == '__main__':
    main()
