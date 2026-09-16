#!/usr/bin/env python3
"""Focused final assembly/reference check, with prior transport checks explicit.

This does not replace the complete native audit, source graph or dependency
campaign. The large hard/UU certificates have their own focused arithmetic
checks; this check tests the additional conversion/observable values and every
r07 scientific row using the unmodified installed validator functions.
"""
import argparse
import hashlib
import json
import sys
from pathlib import Path


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--packet-directory', type=Path, required=True)
    ap.add_argument('--hard-check', type=Path, required=True)
    ap.add_argument('--uu-check', type=Path, required=True)
    args = ap.parse_args()
    root = Path(__file__).resolve().parents[3]
    sys.path.insert(0, str(root/'collins_support/validators'))
    import sidis_highpt as h
    out = args.packet_directory.resolve()
    rt = dict(config=json.loads((root/'collins_ep_analytic_SIDIS/ru_runtime.json').read_text()))
    h.w.export_native(out/'packet.wl', out/'packet.json', 'packet', rt, out/'native-export')
    packet = h.u.read(out/'packet.json')
    known, checks = {}, {}
    for name, directory in [('hard', args.hard_check), ('UU', args.uu_check)]:
        prior = h.u.read(directory/'packet.json')
        for key, row in prior['values'].items():
            if packet['values'][key] != row:
                raise ValueError('Final packet changed previously checked input: '+key)
            known[key] = h.a.decode(row['value'])
        checks[name] = dict(directory=str(directory.resolve()),
                           packet_sha256=h.u.digest(directory/'packet.json'),
                           result=h.u.read(directory/'result.json'))
    additions = {k: v for k, v in packet['values'].items() if k not in known}
    values, recipes = h.a.evaluate_values({'values': additions}, known)
    h.a.check_precision(recipes, {key: 0 for key in known})
    known.update(values)
    contract = h.u.read(out/'native-contract-r07.json')
    references = {name: dict(resolved=str(root/'collins_sidis_highpt/references'/file))
                  for name, file in [('uu_literal_native', 'uu-inclusive-native.json'),
                                     ('jet_literal_coefficients', 'jet_matching.json')]}
    rows = h.run_checks(contract, known, references, 'r07', enforce=False)
    result = dict(status='PASS' if all(r['status'] == 'PASS' for r in rows) else 'FAIL',
                  checks=rows, additional_certificates=len(values), prior_checks=checks,
                  source_sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
                  qualification='Focused final additions and reference checks. Prior hard/UU arithmetic and precision statuses are recorded separately; not a full workflow, provenance audit or pair/probe acceptance.')
    (out/'focused-final-result.json').write_text(json.dumps(result, indent=2)+'\n')
    print(json.dumps({k: v for k, v in result.items() if k not in ('checks', 'prior_checks')}))
    for row in rows:
        if row['status'] != 'PASS':
            print('FAILED_CHECK', row['id'])
    if result['status'] != 'PASS':
        raise SystemExit(2)


if __name__ == '__main__':
    main()
