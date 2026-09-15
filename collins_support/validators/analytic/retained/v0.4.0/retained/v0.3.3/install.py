#!/usr/bin/env python3
"""Historical scaffold installer; current paths stay inside collins_support."""
import argparse
import json
from pathlib import Path
from support import baseline_check, read, release_integrity, sha, snapshot, write,access,same_path,output_path
from extension_inputs import check_foundation
from derivation_support import DEFAULT_STATE, check_installation

ROOT = Path(__file__).resolve().parent


def install(repo, baseline_state='/bigTMD/collins_support/baselines/SIDIS-validation-state', state=DEFAULT_STATE, dry_run=False):
    digest = release_integrity(ROOT)
    repo = Path(repo).resolve()
    production = repo / 'collins_ep_analytic'
    if not production.is_dir() or production.is_symlink():
        raise ValueError('Existing /bigTMD/collins_ep_analytic installation required')
    state = output_path(state,repo,protected=(production,ROOT),area='states')
    if state.is_relative_to(production) or state.is_relative_to(ROOT):
        raise ValueError('State must be outside production and validator')
    before = baseline_check(repo, baseline_state)
    foundation = check_foundation(production)
    lock = state / 'installation.json'
    if lock.exists():
        old = check_installation(production)
        if not same_path(read(production/'derivation_runtime.json')['installation_lock'],lock):
            raise ValueError('Existing installation uses a different state directory')
        if old['baseline'] != before:
            raise ValueError('Original baseline identity changed')
        return {'status': 'ALREADY_INSTALLED', 'mutated': False, 'repo': str(repo),
                'validator': str(ROOT), 'installation_lock': str(lock)}
    if (production/'derivation_runtime.json').exists():
        raise ValueError('Runtime exists without installation lock; do not overwrite or reinitialize')
    inventory = snapshot(ROOT / 'scaffold')
    pending = []
    for name in inventory:
        target = production / name
        for parent in [target, *target.parents]:
            if parent == production:
                break
            if parent.is_symlink():
                raise ValueError('Symlink in installation path: ' + str(parent))
        if target.exists():
            raise ValueError('New scaffold path already exists: ' + str(target))
        pending.append(name)
    original = snapshot(production)
    numeric = snapshot(repo/'collins_ep')
    record = {'schema': 1, 'repo': str(repo), 'validator_manifest_sha256': digest,
              'production_before': original, 'numerical_before': numeric,
              'baseline': before, 'installed_files': inventory}
    if not dry_run:
        made = []
        try:
            for name in pending:
                payload = (ROOT/'scaffold'/name).read_bytes()
                if name == 'derivation_runtime.json':
                    cfg = json.loads(payload)
                    cfg['installation_lock'] = str(lock)
                    payload = (json.dumps(cfg, indent=2)+'\n').encode()
                target = production/name
                target.parent.mkdir(parents=True, exist_ok=True)
                with target.open('xb') as stream:
                    stream.write(payload)
                made.append(target)
            if baseline_check(repo, baseline_state) != before:
                raise ValueError('Baseline changed during installation')
            check_foundation(production)
            state.mkdir(parents=True, exist_ok=True)
            with lock.open('x') as stream:
                json.dump(record, stream, indent=2, sort_keys=True)
                stream.write('\n')
        except BaseException:
            for target in reversed(made):
                target.unlink()
            raise
    return {'status': 'DRY_RUN_READY' if dry_run else 'INSTALLED', 'mutated': not dry_run,
            'repo': str(repo), 'candidate': str(production), 'validator': str(ROOT),
            'installation_lock': str(lock), 'new_files': pending, 'baseline': before,
            'preserved_production_files': len(original), 'foundation': foundation,
            'scope': 'Scaffold installation only; no derivation or MadGraph result certified'}


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--repo', default='/bigTMD')
    p.add_argument('--baseline-state', '--numerical-state', dest='baseline_state', default='/bigTMD/collins_support/baselines/SIDIS-validation-state')
    p.add_argument('--state', default=DEFAULT_STATE)
    p.add_argument('--dry-run', action='store_true')
    a = p.parse_args()
    try:
        print(json.dumps(install(a.repo, a.baseline_state, a.state, a.dry_run), indent=2))
        return 0
    except Exception as exc:
        print(json.dumps({'status': 'BLOCKED', 'detail': str(exc)}))
        return 2


if __name__ == '__main__':
    raise SystemExit(main())
