#!/usr/bin/env python3
"""Focused relocation fixtures; never changes accepted files or invokes native tools."""
import argparse
import copy
import hashlib
import json
import sys
import tempfile
from pathlib import Path
from unittest.mock import patch

SUPPORT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(SUPPORT))
import paths

ROOT = SUPPORT / 'validators/analytic'
REPORTS = SUPPORT / 'reports'


def digest(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def require(condition, message):
    if not condition:
        raise AssertionError(message)


def rejects(action, message):
    try:
        action()
    except ValueError as exc:
        require(message in str(exc), 'Unexpected rejection: ' + str(exc))
        return
    raise AssertionError('Invalid fixture was accepted')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--report', help='Optional unused JSON path below support/reports')
    args = parser.parse_args()
    output = paths.output_path(args.report, area='reports') if args.report else None
    if output is not None and output.exists():
        raise FileExistsError('Choose a new test report')
    checks = []

    def case(name, action):
        try:
            action()
            checks.append({'id': name, 'status': 'PASS'})
        except Exception as exc:
            checks.append({'id': name, 'status': 'FAIL', 'detail': str(exc)})

    old = '/Collins-ep-analytic-state-v0.5.1-organization-001/ru-1729.json'
    moved = SUPPORT / 'states/Collins-ep-analytic-state-v0.5.1-organization-001/ru-1729.json'
    case('historical_seed_access', lambda: require(paths.access(old) == moved and moved.is_file(), 'Wrong moved seed'))
    case('unmapped_prefix', lambda: rejects(lambda: paths.access('/Collins-ep-analytic-state-v0.5.1-unmapped/file', False), 'unmapped path'))
    case('parent_escape', lambda: rejects(lambda: paths.access(old + '/../outside', False), 'unsafe path'))

    def ambiguous():
        original_read = paths._read
        map_path = SUPPORT / 'relocation-map.json'
        altered = copy.deepcopy(original_read(map_path))
        keys = list(altered['prefixes'])
        altered['prefixes'][keys[1]] = altered['prefixes'][keys[0]]
        paths._layout.cache_clear()
        try:
            with patch.object(paths, '_read', side_effect=lambda p: altered if Path(p) == map_path else original_read(p)):
                rejects(lambda: paths.access(old), 'ambiguous relocation destinations')
        finally:
            paths._layout.cache_clear()

    case('ambiguous_destinations', ambiguous)
    with tempfile.TemporaryDirectory(prefix='relocation-fixture-', dir=REPORTS) as temporary:
        fixture = Path(temporary)
        escape = fixture / 'outside-link'
        escape.symlink_to('/usr/bin/python3')
        case('symlink_escape', lambda: rejects(lambda: paths.access(escape), 'path escapes'))
        source = fixture / 'source.wl'
        source.write_bytes((SUPPORT.parent / 'collins_ep_analytic_SIDIS/common/ru_formal_assembly.wl').read_bytes())
        original_sha = digest(source)
        case('source_fixture_unchanged', lambda: require(paths.check_file(source, original_sha) and paths.same_snapshot(fixture, {'source.wl': original_sha}), 'Unchanged source fixture rejected'))
        source.write_bytes(source.read_bytes() + b'\n(* unauthorized fixture-only byte change *)\n')
        case('source_fixture_changed', lambda: require(not paths.check_file(source, original_sha) and not paths.same_snapshot(fixture, {'source.wl': original_sha}), 'Changed source bytes accepted'))

        manifest = json.loads((ROOT / 'MANIFEST.json').read_text())
        actual = {name: digest(ROOT / name) for name in manifest['files']}

        def unchanged_release():
            require(actual == manifest['files'], 'Current release content differs from its manifest')
            paths.verify_release_edits(ROOT, actual)

        case('release_inventory_unchanged', unchanged_release)
        reference = json.loads((ROOT / 'reference_values.json').read_text())
        coefficient = sorted(reference['values'])[0]
        reference['values'][coefficient] = '123456789/1'
        changed = fixture / 'reference_values.json'
        changed.write_text(json.dumps(reference, sort_keys=True) + '\n')
        bad = dict(actual, **{'reference_values.json': digest(changed)})
        case('coefficient_reference_changed', lambda: rejects(lambda: paths.verify_release_edits(ROOT, bad), 'unrecorded release edit: ' + str(ROOT / 'reference_values.json')))
    result = {'schema': 1, 'status': 'PASS' if all(c['status'] == 'PASS' for c in checks) else 'FAIL', 'checks': checks,
              'scope': 'Focused path/identity fixtures; no native execution or new physics acceptance', 'validator_files_read': len(actual)}
    text = json.dumps(result, indent=2, sort_keys=True) + '\n'
    if output is not None:
        output.parent.mkdir(parents=True, exist_ok=True)
        with output.open('x') as stream:
            stream.write(text)
    print(text, end='')
    return 0 if result['status'] == 'PASS' else 1


if __name__ == '__main__':
    raise SystemExit(main())
