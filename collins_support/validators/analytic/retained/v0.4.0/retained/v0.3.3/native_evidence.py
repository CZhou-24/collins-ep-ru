"""Identity of generated MG evidence; production/source snapshots stay strict.

An internal dangling link is evidence of the generator's tree, not evidence of
a successful build. Native compilation, required artifacts and amplitude replay
remain independent acceptance gates. No directory symlinks are traversed.
"""
import hashlib
import os
import stat
from pathlib import Path

POLICY = 'derivation-evidence-contained-native-links-v1'
NATIVE_POLICY = 'madgraph-standalone-contained-native-links-v1'
NATIVE_PROCESSES = frozenset({'born_eq', 'real_eq', 'real_eg'})


def _digest(path):
    h = hashlib.sha256()
    with path.open('rb') as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b''):
            h.update(chunk)
    return h.hexdigest()


def _resolve_contained(native_root, link):
    """Resolve each link hop inside one tree, including a missing final leaf.

    Do not follow an escaping intermediate link even if a later link would
    return to the tree. A missing parent or directory link is unsupported.
    """
    pending = list(link.relative_to(native_root).parts)
    resolved = []
    seen = set()
    while pending:
        part = pending.pop(0)
        if part == '.':
            continue
        if part == '..':
            if not resolved:
                raise ValueError('Native evidence link escapes its standalone tree')
            resolved.pop()
            continue
        target = native_root.joinpath(*resolved, part)
        try:
            mode = target.lstat().st_mode
        except FileNotFoundError:
            if pending:
                raise ValueError('Missing parent in native evidence link')
            return target, None
        if stat.S_ISLNK(mode):
            if target in seen or len(seen) >= 128:
                raise ValueError('Cyclic or excessively chained native evidence link')
            seen.add(target)
            text = os.readlink(target)
            if not text or Path(text).is_absolute():
                raise ValueError('Absolute/empty native evidence link')
            lexical = Path(os.path.normpath(str(target.parent / text)))
            if not lexical.is_relative_to(native_root):
                raise ValueError('Native evidence link escapes its standalone tree')
            pending = list(Path(text).parts) + pending
            continue
        if pending and not stat.S_ISDIR(mode):
            raise ValueError('Non-directory parent in native evidence link')
        resolved.append(part)
    target = native_root.joinpath(*resolved)
    mode = target.lstat().st_mode
    if not stat.S_ISREG(mode):
        raise ValueError('Native evidence link must target a regular file or missing leaf')
    return target, mode


def _scan(root, policy, standalone):
    supplied = Path(root)
    if supplied.is_symlink():
        raise ValueError('Symlink evidence root is forbidden')
    root = supplied.resolve(strict=True)
    if not root.is_dir():
        raise ValueError('Evidence root must be a directory')
    records = {}

    def walk_error(error):
        raise error

    for folder, directories, filenames in os.walk(root, followlinks=False, onerror=walk_error):
        directories.sort()
        filenames.sort()
        for name in sorted(directories + filenames):
            path = Path(folder) / name
            relative = path.relative_to(root)
            key = relative.as_posix()
            mode = path.lstat().st_mode
            if stat.S_ISLNK(mode):
                if standalone:
                    native_root = root
                else:
                    parts = relative.parts
                    if (len(parts) < 4 or parts[0] != 'madgraph'
                            or parts[1] not in NATIVE_PROCESSES or parts[2] != 'standalone'):
                        raise ValueError('Symlink outside native evidence scope: ' + key)
                    native_root = root.joinpath(*parts[:3])
                text = os.readlink(path)
                target, target_mode = _resolve_contained(native_root, path)
                records[key] = {
                    'kind': 'symlink', 'link_text': text,
                    'link_text_sha256': hashlib.sha256(b'symlink\0' + os.fsencode(text)).hexdigest(),
                    'resolved_target': target.relative_to(root).as_posix(),
                    'target_kind': 'missing' if target_mode is None else 'file',
                    'target_sha256': None if target_mode is None else _digest(target),
                    'target_executable': None if target_mode is None else bool(target_mode & 0o111),
                }
            elif stat.S_ISREG(mode):
                records[key] = {'kind': 'file', 'sha256': _digest(path),
                                'executable': bool(mode & 0o111)}
            elif not stat.S_ISDIR(mode):
                raise ValueError('Special node in acceptance evidence: ' + key)
    return {'schema': 1, 'policy': policy, 'files': dict(sorted(records.items()))}


def snapshot_derivation_evidence(root):
    """Only madgraph/{known process}/standalone may contain generated links."""
    return _scan(root, POLICY, standalone=False)


def snapshot_native_tree(root):
    """Capture one generated standalone build before native evidence replay."""
    return _scan(root, NATIVE_POLICY, standalone=True)
