#!/usr/bin/env python3
"""Prepare actual mapped Kira targets for execution by the installed runner.

This does not execute Kira. It preserves the focused development driver's
target-derived bounds, with explicit optional auxiliary terminal-export targets.
"""
import argparse
import hashlib
import itertools
import json
import re
from pathlib import Path

import yaml


def prepare(mapping, output, job_id, sectors, auxiliary=None):
    source = mapping / 'kira-input.json'
    data = json.loads(source.read_text())
    actual = list(data['targets'])
    added = []
    if auxiliary:
        for line in auxiliary.read_text().splitlines():
            match = re.fullmatch(r'([VR]\d+)\[([\d, -]+)\]', line.strip())
            if not match:
                raise ValueError('Invalid explicit auxiliary target: ' + line)
            row = dict(family=match[1], powers=[int(v) for v in match[2].split(',')])
            family = next(f for f in data['families'] if f['id'] == row['family'])
            if len(row['powers']) != len(family['propagators']):
                raise ValueError('Auxiliary target arity differs')
            if row not in data['targets']:
                data['targets'].append(row)
                added.append(row)
    output.mkdir(parents=True, exist_ok=False)
    (output / 'config').mkdir()
    families, reductions, preferred, bounds = [], [], [], {}

    def integral(name, powers):
        return name + '[' + ','.join(map(str, powers)) + ']'

    for family in data['families']:
        name = family['id']
        targets = [r['powers'] for r in data['targets'] if r['family'] == name]
        if not targets or any(any(p[i-1] <= 0 for i in family['cut_positions']) for p in targets):
            raise ValueError('Missing physical target/cut')
        supported = sorted({sum(1 << i for i, n in enumerate(p) if n > 0) for p in targets})
        top = [s for s in supported if not any(s != t and s & t == s for t in supported)]
        rb = max(sum(max(0, n) for n in p) for p in targets) + len(family['loop_momenta'])
        sb = max(sum(max(0, -n) for n in p) for p in targets)
        bounds[name] = dict(r=rb, s=sb, sectors=supported, top_sectors=top, targets=len(targets))
        record = dict(name=name, loop_momenta=family['loop_momenta'], top_level_sectors=top,
                      propagators=family['propagators'])
        if family['cut_positions']:
            record['cut_propagators'] = family['cut_positions']
        families.append(record)
        reductions.append(dict(topologies=[name], sectors=top, r=rb, s=sb))
        noncuts = [i for i in range(1, len(family['propagators'])+1) if i not in family['cut_positions']]
        for count in range(len(noncuts)+1):
            for support in itertools.combinations(noncuts, count):
                preferred.append(integral(name, [int(i in family['cut_positions'] or i in support)
                                                  for i in range(1, len(family['propagators'])+1)]))
    kinematics = dict(incoming_momenta=data['external'], outgoing_momenta=[],
                      kinematic_invariants=[[x, 2] for x in data['invariants']],
                      scalarproduct_rules=[[[a, b], value] for a, b, value in data['scalarproducts']])
    configs = {
        'config/kinematics.yaml': {'kinematics': kinematics},
        'config/integralfamilies.yaml': {'integralfamilies': families},
        'jobs.yaml': {'jobs': [
            {'reduce_sectors': dict(reduce=reductions, select_integrals={'select_mandatory_list': [['targets']]},
                                    preferred_masters='preferred', run_initiate=True,
                                    run_triangular=True, run_back_substitution=True)},
            {'kira2math': {'target': [['targets']]}}]}}
    for name, value in configs.items():
        (output / name).write_text(yaml.safe_dump(value, sort_keys=False))
    (output / 'targets').write_text('\n'.join(integral(r['family'], r['powers']) for r in data['targets'])+'\n')
    (output / 'preferred').write_text('\n'.join(preferred)+'\n')
    names = sorted(f['id'] for f in data['families'])
    job = dict(id=job_id, inputs=list(configs)+['targets', 'preferred'],
               # Kira consolidates this cross-family target-list export under
               # the first family, as verified on the actual union reduction.
               outputs=['results/'+names[0]+'/kira_targets.m', 'tmp/'+names[-1]+'/masters'],
               families=names, sectors=sectors, master_inventory='tmp/'+names[-1]+'/masters')
    identity = dict(mapping_input_sha256=hashlib.sha256(source.read_bytes()).hexdigest(),
                    driver_sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
                    actual_numerator_targets=actual, auxiliary_export_targets=added, bounds=bounds,
                    execution='NOT_EXECUTED: runner must execute and audit this job')
    (output / 'preparation.json').write_text(json.dumps(identity, indent=2)+'\n')
    return job


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--mapping', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--job-id', required=True)
    parser.add_argument('--sectors', nargs='+', required=True)
    parser.add_argument('--auxiliary-targets', type=Path)
    args = parser.parse_args()
    job = prepare(args.mapping, args.output, args.job_id, args.sectors, args.auxiliary_targets)
    (args.output / 'job.json').write_text(json.dumps(job, indent=2)+'\n')
    print(json.dumps(job))


if __name__ == '__main__':
    main()
