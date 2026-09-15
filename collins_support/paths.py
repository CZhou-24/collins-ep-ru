"""Project-local access paths and exact identities for the authorized relocation.

Historical JSON is never rewritten. Call access() only at filesystem boundaries;
use same_path() only on explicitly declared path fields.
"""
import copy
import hashlib
import json
import os
import stat
from pathlib import Path
from functools import lru_cache

SUPPORT = Path(__file__).absolute().parent
PROJECT = SUPPORT.parent
ORIGIN_SHA256 = '9f12ec4f1ef0206403882315f1002430b4703d43635031e5450ba51d17e7f0cf'


def _read(path):
    return json.loads(Path(path).read_text())


def _sha(path):
    h = hashlib.sha256()
    with Path(path).open('rb') as stream:
        for block in iter(lambda: stream.read(1048576), b''):
            h.update(block)
    return h.hexdigest()


@lru_cache(maxsize=1)
def _layout():
    layout = _read(SUPPORT / 'relocation-map.json')
    if layout['schema'] != 1 or Path(layout['project_root']) != PROJECT:
        raise ValueError('wrong relocation map project/schema')
    pairs = [(Path(a), PROJECT / b) for a, b in layout['prefixes'].items()]
    for old, new in pairs:
        if not old.is_absolute() or '..' in new.parts or not new.is_relative_to(SUPPORT):
            raise ValueError('escaping relocation map entry')
    if len({new for _, new in pairs}) != len(pairs):
        raise ValueError('ambiguous relocation destinations')
    return pairs, [Path(p) for p in layout['unchanged_external_roots']]


def access(value, required=True):
    """Resolve an explicitly supported path; preserve its lexical final link.

    Relative configuration paths are relative to the project, never the cwd.
    Unknown absolute prefixes and any '..' component fail, including when the
    requested output does not yet exist. No old root directories are created.
    """
    text = os.fspath(value)
    if not text or '\\' in text or '..' in text.split('/'):
        raise ValueError('unsafe path: ' + str(text))
    p = Path(text)
    if not p.is_absolute():
        p = PROJECT / p
    pairs, external = _layout()
    matches = [(old, new) for old, new in pairs if p.is_relative_to(old)]
    if len(matches) > 1:
        raise ValueError('ambiguous historical path: ' + str(p))
    if matches:
        old, bound = matches[0]
        p = bound / p.relative_to(old)
    else:
        bounds = [r for r in [PROJECT, *external] if p.is_relative_to(r)]
        if not bounds:
            raise ValueError('unmapped path: ' + str(p))
        bound = max(bounds, key=lambda r: len(r.parts))
    # Resolve only for containment; callers inspecting links receive p itself.
    resolved = p.resolve(strict=False)
    allowed = [bound]
    if bound in external:
        allowed = external  # established /bin -> /usr/bin and native layouts
    if not any(resolved.is_relative_to(r.resolve()) for r in allowed):
        raise ValueError('path escapes its mapped destination: ' + str(p))
    if required and not os.path.lexists(p):
        raise FileNotFoundError('missing required relocated path: ' + str(p))
    return p


def same_path(a, b):
    return access(a, required=False).resolve() == access(b, required=False).resolve()


def historical_path(value):
    """Original identity of a relocated historical path, for a named field."""
    p = access(value, required=False)
    matches = [(old, new) for old, new in _layout()[0] if p.is_relative_to(new)]
    if len(matches) > 1:
        raise ValueError('ambiguous historical identity: ' + str(p))
    if matches:
        old, new = matches[0]
        return str(old / p.relative_to(new))
    return str(p)


@lru_cache(maxsize=1)
def _records():
    origin_file = SUPPORT / 'relocation-origin.json'
    if _sha(origin_file) != ORIGIN_SHA256:
        raise ValueError('relocation origin changed')
    origin = _read(origin_file)
    changes = _read(SUPPORT / 'relocation-changes.json')
    if changes.get('schema') != 1 or changes.get('origin_sha256') != ORIGIN_SHA256:
        raise ValueError('unbound relocation changes')
    for name, change in changes['files'].items():
        if change['before'] != origin['files'].get(name) or not change.get('reason'):
            raise ValueError('unbound or unexplained path edit: ' + name)
        if Path(name).name == 'MANIFEST.json':
            raise ValueError('release manifests are checked inside out, not exempted')
    return origin, changes['files']


def _change(path):
    p = access(path)
    if not p.is_relative_to(PROJECT):
        return None
    return _records()[1].get(p.relative_to(PROJECT).as_posix())


def check_file(path, expected_sha):
    """Accept only the literal hash or this file's recorded before -> after."""
    p = access(path)
    actual = _sha(p)
    if actual == expected_sha:
        return True
    change = _change(p)
    return bool(change and change['before']['kind'] == change['after']['kind'] == 'file'
                and expected_sha == change['before']['sha256']
                and actual == change['after']['sha256']
                and p.stat().st_size == change['after']['size'])


def same_snapshot(root, recorded, actual=None):
    """Check a hash/sized-file inventory, without changing recorded entries."""
    root = access(root)
    if actual is None:
        # Subset inventories (foundation/original-source locks) stay subsets.
        actual = {}
        for name, old in recorded.items():
            p = access(root / name)
            if isinstance(old, str):
                actual[name] = _sha(p)
            elif p.is_symlink():
                actual[name] = {'kind': 'symlink', 'target': os.readlink(p)}
            else:
                actual[name] = {'kind': 'file', 'sha256': _sha(p)}
                if 'size' in old:
                    actual[name]['size'] = p.stat().st_size
    if set(actual) != set(recorded):
        return False
    for name, before in recorded.items():
        after = actual[name]
        if before == after:
            continue
        change = _change(root / name)
        if not change or change['before']['kind'] != 'file' or change['after']['kind'] != 'file':
            return False
        if isinstance(before, str):
            if before != change['before']['sha256'] or after != change['after']['sha256']:
                return False
        elif isinstance(before, dict) and isinstance(after, dict):
            adjusted = dict(before)
            if before.get('sha256') != change['before']['sha256']:
                return False
            adjusted['sha256'] = change['after']['sha256']
            if 'size' in before:
                if before['size'] != change['before']['size']:
                    return False
                adjusted['size'] = change['after']['size']
            if adjusted != after:
                return False
        else:
            return False
        if not check_file(root / name, change['before']['sha256']):
            return False
    return True


def same_release(root, recorded_sha):
    """Old release identities remain old; only the captured predecessor qualifies."""
    root = access(root)
    manifest = _read(root / 'MANIFEST.json')
    actual = {p.relative_to(root).as_posix(): _sha(p) for p in root.rglob('*')
              if p.is_file() and '__pycache__' not in p.parts and p.suffix != '.pyc' and p != root / 'MANIFEST.json'}
    if actual != manifest['files']:
        raise ValueError('release contents changed: ' + str(root))
    verify_release_edits(root, actual)
    current = _sha(root / 'MANIFEST.json')
    original = _records()[0]['release_manifests'].get(root.relative_to(PROJECT).as_posix())
    if not original:
        raise ValueError('release absent from relocation origin: ' + str(root))
    return recorded_sha in (current, original['sha256'])


def verify_release_edits(root, actual):
    """Keep every original release member, allowing only listed file edits.

    Callers retain their original current-manifest/actual-inventory comparison.
    Nested manifest identities are checked against their own captured release.
    """
    root = access(root)
    origin, changes = _records()
    key = root.relative_to(PROJECT).as_posix()
    original_manifest = json.loads(origin['release_manifests'][key]['text'])
    old = original_manifest['files']
    if set(old) != set(actual):
        raise ValueError('release member inventory changed: ' + key)
    for name, old_sha in old.items():
        p = root / name
        if name.endswith('/MANIFEST.json') and str(p.parent.relative_to(PROJECT)) in origin['release_manifests']:
            nested = _read(p)
            # Parent pins the exact current child bytes; child checks preserve
            # all original non-path members and the original manifest meaning.
            verify_release_edits(p.parent, nested['files'])
            if actual[name] != _sha(p):
                raise ValueError('nested manifest hash mismatch')
        elif actual[name] != old_sha:
            c = changes.get(p.relative_to(PROJECT).as_posix())
            if not c or c['before']['sha256'] != old_sha or c['after']['sha256'] != actual[name]:
                raise ValueError('unrecorded release edit: ' + str(p))
    manifest = _read(root / 'MANIFEST.json')
    added_keys = {'relocation'} if root == SUPPORT / 'validators/analytic' else set()
    if set(manifest) != set(original_manifest) | added_keys or any(manifest[k] != v for k, v in original_manifest.items() if k != 'files'):
        raise ValueError('non-path release metadata changed: ' + key)
    if root == SUPPORT / 'validators/analytic':
        expected = {name: _sha(SUPPORT / name) for name in
                    ('paths.py', 'relocation-map.json', 'relocation-origin.json', 'relocation-changes.json')}
        if manifest.get('relocation') != expected:
            raise ValueError('shared relocation utility/identity records changed')


def output_path(value, repo=PROJECT, protected=(), area='states'):
    p = access(value, required=False)
    if access(repo) != PROJECT or area not in ('states', 'reports'):
        raise ValueError('invalid project output area')
    allowed = [SUPPORT / 'reports'] if area == 'reports' else [SUPPORT / 'states/runs', SUPPORT / 'states/relocation-check']
    if not any(p.is_relative_to(q) for q in allowed) or p in (SUPPORT / 'states', SUPPORT / 'reports'):
        raise ValueError('choose a fresh output below support ' + area)
    for q in protected:
        q = access(q, required=False)
        if q == PROJECT:
            continue  # exact approved output subtree above replaces old root ban
        if p.is_relative_to(q) or q.is_relative_to(p):
            raise ValueError('output overlaps protected inputs: ' + str(p))
    return p


def historical_runtime_equal(recorded, current):
    """Only known runtime path fields and the two edited config hashes convert."""
    old = copy.deepcopy(recorded)
    new = copy.deepcopy(current)
    path_fields = [
        ('config', k) for k in ('wolfram_kernel', 'kira', 'fermat', 'subtropica_root', 'feyncalc_root', 'feynarts_root', 'wolfram_init')
    ] + [('python', 'executable'), ('extension', 'polymake', 'path'), ('extension', 'legacy_analytic_state'),
         ('derivation', 'config', 'installation_lock'), ('derivation', 'config', 'madgraph', 'root')]
    def slot(obj, keys):
        for key in keys[:-1]:
            if not isinstance(obj, dict) or key not in obj:
                return None
            obj = obj[key]
        return obj if isinstance(obj, dict) and keys[-1] in obj else None
    for keys in path_fields:
        a, b = slot(old, keys), slot(new, keys)
        if a is None and b is None:
            continue
        if a is None or b is None:
            return False
        k = keys[-1]
        if a[k] != b[k]:
            if not isinstance(a[k], str) or not isinstance(b[k], str) or not same_path(a[k], b[k]):
                return False
            b[k] = a[k]
    for part, filename in [('extension', 'assembly_runtime.json'), ('derivation', 'derivation_runtime.json')]:
        if part in old and part in new and old[part].get('config_sha256') != new[part].get('config_sha256'):
            change = _change(PROJECT / 'collins_ep_analytic' / filename)
            if not change or old[part]['config_sha256'] != change['before']['sha256'] or new[part]['config_sha256'] != change['after']['sha256']:
                return False
            new[part]['config_sha256'] = old[part]['config_sha256']
    return old == new


def execution_context(context):
    """Translate known native-context fields in a new object, never saved JSON."""
    out = copy.deepcopy(context)
    def paths(obj, names, required=True):
        for name in names:
            if isinstance(obj, dict) and isinstance(obj.get(name), str):
                obj[name] = str(access(obj[name], required=required))
    paths(out, ('production', 'repo', 'run', 'output', 'input'), required=False)
    if isinstance(out.get('inputs'), dict):
        out['inputs'] = {k: str(access(v)) for k, v in out['inputs'].items()}
    native = ('wolfram_kernel', 'kira', 'fermat', 'subtropica_root', 'feyncalc_root', 'feynarts_root', 'wolfram_init', 'polymake')
    paths(out, native)
    paths(out, ('installation_lock', 'legacy_analytic_state'))
    if isinstance(out.get('madgraph'), dict):
        paths(out['madgraph'], ('root',))
    for name in ('runtime', 'native_runtime'):
        obj = out.get(name)
        paths(obj, native)
        if isinstance(obj, dict):
            paths(obj.get('config'), native)
    ext = out.get('extension_runtime')
    paths(ext, ('legacy_analytic_state',))
    if isinstance(ext, dict):
        paths(ext.get('polymake'), ('path',))
    der = out.get('derivation_runtime')
    if isinstance(der, dict):
        cfg = der.get('config', der)
        paths(cfg, ('installation_lock',))
        paths(cfg.get('madgraph'), ('root',))
    return out
