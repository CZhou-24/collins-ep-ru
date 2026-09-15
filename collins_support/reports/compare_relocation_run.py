#!/usr/bin/env python3
"""Compare one completed relocation RU run with the unchanged 167 references.

This reads native evidence and recomputes the official certificate arithmetic.
It neither executes native tools nor changes historical reports or references.
"""
import argparse
import json
import os
import sys
from pathlib import Path

for name in ('OPENBLAS_NUM_THREADS', 'OMP_NUM_THREADS', 'MKL_NUM_THREADS'):
    os.environ[name] = '1'
sys.dont_write_bytecode = True

SUPPORT = Path(__file__).resolve().parents[1]
VALIDATOR = SUPPORT / 'validators/analytic'
sys.path.insert(0, str(VALIDATOR))
sys.path.insert(0, str(SUPPORT))

import sympy as sy
import workflow
from algebra import decode, encode, equal
from paths import ORIGIN_SHA256, access, output_path
from ru_support import ENGINE, QUALIFICATIONS, digest, read, rows_status, snapshot, write


def compare(run, report):
    repo = SUPPORT.parent
    run = access(run)
    if not run.is_relative_to(SUPPORT / 'states/relocation-check'):
        raise ValueError('the fresh run must be below support states/relocation-check')
    reference_path = VALIDATOR / 'reference_values.json'
    report = output_path(report, repo, protected=[run, VALIDATOR, repo / ENGINE], area='reports')
    if report.exists() or report.is_symlink():
        raise ValueError('choose an unused comparison report path')
    result = {
        'schema': 1,
        'status': 'FAIL',
        'kind': 'fresh_relocation_run_scalar_comparison',
        'run': str(run),
        'script_sha256': digest(__file__),
        'native_execution_in_this_command': False,
        'qualifications': QUALIFICATIONS,
        'scientific_qualifications_changed': False,
        'new_independent_physics_acceptance': False,
        'settings': {
            'arithmetic': 'exact official algebra; cancel(expand(our-reference)), then simplify if needed',
            'numerical_tolerance': None,
            'conversion': {
                'quantities': 's09/H_*',
                'identity': 's+t+u=0',
                'operation': 'substitute u=-s-t in both candidate and reference before comparison',
                'other_quantities': 'identity conversion',
            },
        },
        'rows': [],
    }
    try:
        manifest_path = run / 'run.json'
        manifest = read(manifest_path)
        result['run_manifest_sha256'] = digest(manifest_path)
        if (manifest.get('schema') != 5 or manifest.get('profile') != 'reverse_unitarity'
                or manifest.get('status') != 'STAGES_PASS' or manifest.get('fresh') is not True
                or manifest.get('through') != 'r07' or manifest.get('repo') != str(repo)
                or manifest.get('qualifications') != QUALIFICATIONS):
            raise ValueError('a completed fresh RU run through r07 with unchanged scope is required')

        release_path = VALIDATOR / 'MANIFEST.json'
        release_sha = digest(release_path)
        if manifest['release'] != release_sha:
            raise ValueError('the fresh run did not use the exact current validator release')
        # Only the small current engine tree is inventoried here. Runtime/tool
        # identities were already checked by the completed official workflow.
        if manifest['sources'] != snapshot(repo / ENGINE):
            raise ValueError('fresh run source metadata differs from the current RU engine')
        result['release_manifest_sha256'] = release_sha
        result['source_entries_checked'] = len(manifest['sources'])

        origin_path = SUPPORT / 'relocation-origin.json'
        if digest(origin_path) != ORIGIN_SHA256:
            raise ValueError('the captured relocation origin changed')
        origin = read(origin_path)
        original_release = json.loads(origin['release_manifests'][VALIDATOR.relative_to(repo).as_posix()]['text'])
        reference_sha = digest(reference_path)
        if (reference_sha != original_release['files']['reference_values.json']
                or reference_sha != read(release_path)['files']['reference_values.json']):
            raise ValueError('the accepted reference bytes changed')
        reference = read(reference_path)['values']
        result['reference'] = {
            'path': str(reference_path),
            'sha256': reference_sha,
            'original_sha256': original_release['files']['reference_values.json'],
            'unchanged': True,
        }

        # This is the existing official arithmetic/evidence audit, without its
        # runtime discovery wrapper and without any fresh native execution.
        data = workflow.scientific_audit(run, repo)
        official_rows = [row for row in data['rows'] if row['id'].startswith('reference.')]
        expected_ids = {'reference.' + name for name in reference}
        if (len(reference) != 167 or len(official_rows) != 167
                or {row['id'] for row in official_rows} != expected_ids
                or set(data['exports']) != set(reference)):
            raise ValueError('the comparison must contain exactly the unchanged 167 scalar outputs')
        result['official_scientific_rows'] = data['rows']
        result['official_scientific_status'] = rows_status(data['rows'])

        u, s, t = sy.symbols('u s t')
        official_statuses = {row['id']: row['status'] for row in official_rows}
        for name in sorted(reference):
            candidate = data['values'][data['exports'][name]['value']]
            expected = decode(reference[name])
            converted = name.startswith('s09/H_')
            if converted:
                candidate = candidate.subs(u, -s-t)
                expected = expected.subs(u, -s-t)
            residual = sy.cancel(sy.expand(candidate-expected))
            if residual != 0:
                residual = sy.simplify(residual)
            passed = equal(candidate, expected)
            status = 'PASS' if passed else 'FAIL'
            if status != official_statuses['reference.' + name]:
                raise ValueError('residual calculation disagrees with the official comparison: ' + name)
            result['rows'].append({
                'quantity': name,
                'status': status,
                'residual': encode(residual),
                'conversion': 'u=-s-t in both expressions' if converted else 'identity',
            })
        result['counts'] = {
            'total': len(result['rows']),
            'PASS': sum(row['status'] == 'PASS' for row in result['rows']),
            'FAIL': sum(row['status'] == 'FAIL' for row in result['rows']),
        }
        if result['counts'] != {'total': 167, 'PASS': 167, 'FAIL': 0}:
            raise ValueError('one or more scalar comparisons failed')
        if result['official_scientific_status'] != 'CHECKS_PASS':
            raise ValueError('the official native evidence/certificate checks failed')
        if digest(manifest_path) != result['run_manifest_sha256'] or digest(reference_path) != reference_sha:
            raise ValueError('the run manifest or reference changed during comparison')
        result['status'] = 'PASS'
    except Exception as exc:
        result['detail'] = str(exc)
    write(report, result)
    print(json.dumps({'status': result['status'], 'report': str(report),
                      'counts': result.get('counts'), 'detail': result.get('detail')}))
    return 0 if result['status'] == 'PASS' else 1


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--run', required=True)
    parser.add_argument('--report', required=True)
    args = parser.parse_args()
    try:
        return compare(args.run, args.report)
    except Exception as exc:
        print(json.dumps({'status': 'FAIL', 'detail': str(exc)}))
        return 1


if __name__ == '__main__':
    raise SystemExit(main())
