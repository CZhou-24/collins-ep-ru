"""Versioned derivation-extension identities; no fitted provider is imported."""
import os
import shutil
from pathlib import Path
from support import Blocked, read, sha, retained_files,access,execution_context,same_release

ROOT = Path(__file__).resolve().parent
DEFAULT_STATE = '/bigTMD/collins_support/states/runs/legacy-installation'

# This native-interface patch may verify an existing v0.3.0/v0.3.1/v0.3.2 installation in place.
# The predecessor identity is the exact shipped MANIFEST.json SHA-256, not a
# version-string match.  Its original preservation inventory remains authoritative:
# accepting the ancestor neither rewrites its lock/runtime nor snapshots candidate
# additions into a new baseline.  Fresh runs still record this release's identity.
COMPATIBLE_PREDECESSOR_MANIFEST_SHA256 = (
    'e87f8da47802f37d61e0e9cf7c07f75b66c374bba258d2e4044d93d50cbbed08'
)


def runtime_extension(production):
    p = Path(production) / 'derivation_runtime.json'
    if not p.is_file():
        raise Blocked('Install the v0.3.0 additive scaffold first')
    d = read(p)
    required = {'schema', 'stage_timeout_seconds', 'installation_lock',
                'madgraph', 'madgraph_candidate_command'}
    if type(d) is not dict or set(d) != required or d['schema'] != 1:
        raise ValueError('Wrong derivation_runtime.json schema')
    if type(d['stage_timeout_seconds']) is not int or not 1 <= d['stage_timeout_seconds'] <= 86400:
        raise ValueError('Invalid derivation timeout')
    lock = access(d['installation_lock'])
    if not lock.is_absolute() or not lock.is_file() or lock.is_symlink():
        raise Blocked('Missing independent installation lock; use install.py, not baseline init')
    if type(d['madgraph']) is not dict:
        raise ValueError('madgraph must be a configuration object')
    command = d['madgraph_candidate_command']
    if type(command) is not list or not command or not all(type(x) is str and x for x in command):
        raise ValueError('madgraph_candidate_command must be an argv array')
    identities = {}
    mg = d['madgraph']
    if mg.get('root'):
        mgroot = access(mg['root'])
        # Hash source/model/compiler inputs, not generated runs or caches.
        for folder in ('madgraph', 'aloha', 'models/sm', 'Template/LO', 'bin'):
            q = mgroot / folder
            if q.exists():
                for f in sorted(q.rglob('*')):
                    if f.is_file() and '__pycache__' not in f.parts and f.suffix != '.pyc':
                        identities[str(f.relative_to(mgroot))] = sha(f.resolve())
    for name in ('python', 'make', 'fortran_compiler'):
        val = mg.get(name)
        resolved = shutil.which(val) if isinstance(val, str) else None
        if resolved:
            identities['executable:' + name] = sha(Path(resolved).resolve())
    return {'config': d, 'config_sha256': sha(p), 'installation_lock_sha256': sha(lock),
            'madgraph_identities': identities}


def check_installation(production):
    production = Path(production).resolve()
    d = read(production / 'derivation_runtime.json')
    lock = access(d['installation_lock'])
    if lock.is_relative_to(production):
        raise ValueError('Installation lock must be outside production')
    data = read(lock)
    accepted_manifests = (
        sha(ROOT / 'MANIFEST.json'), COMPATIBLE_PREDECESSOR_MANIFEST_SHA256,
        'fc169985cd5634d8c8ef3ab3faa99b1857603617f088b4897ffdc4fe9b196ffa',
        '4b8ef224916cae97bba765567b0ba3f565bed7b5d70f3dbb2f588c6172416ae8',
    )
    if (data.get('schema') != 1 or data.get('repo') != str(production.parent)
            or (data.get('validator_manifest_sha256') not in accepted_manifests and not same_release(ROOT,data.get('validator_manifest_sha256')))):
        raise ValueError('Installation lock belongs to another repository/release')
    if not isinstance(data.get('production_before'), dict) or not data['production_before']:
        raise ValueError('Empty installation preservation inventory')
    retained_files(production, data['production_before'])
    retained_files(production.parent / 'collins_ep', data['numerical_before'])
    return data


def runtime_for_checks(manifest):
    """One plain configuration for independent checker modules."""
    return execution_context({**manifest['runtime']['config'], **manifest['runtime']['derivation']['config']})
