"""Current project paths. Historical relocation records are not runtime inputs."""
import os
from pathlib import Path

SUPPORT = Path(__file__).resolve().parent
PROJECT = SUPPORT.parent


def access(value, required=True):
    """Resolve relative inputs from this checkout; allow configured native tools."""
    text = os.fspath(value)
    if not text or '\\' in text or '..' in text.split('/'):
        raise ValueError('unsafe path: ' + str(text))
    p = Path(text)
    if not p.is_absolute():
        p = PROJECT / p
    if p.is_relative_to(PROJECT) and not p.resolve().is_relative_to(PROJECT):
        raise ValueError('path escapes project: ' + str(p))
    if required and not os.path.lexists(p):
        raise FileNotFoundError('missing required path: ' + str(p))
    return p


def same_path(a, b):
    return access(a, required=False).resolve() == access(b, required=False).resolve()


def output_path(value, repo=PROJECT, protected=(), area='states'):
    """Confine new output to the project's runs/reports, with no source overlap."""
    repo = access(repo).resolve()
    p = Path(value)
    p = access(p if p.is_absolute() else repo/p, required=False)
    if area not in ('states', 'reports'):
        raise ValueError('invalid output area')
    allowed = repo/'collins_support'/('states/runs' if area == 'states' else 'reports')
    if not p.is_relative_to(allowed) or not p.resolve().is_relative_to(allowed):
        raise ValueError('output must be below ' + str(allowed))
    if p == allowed and area == 'reports':
        raise ValueError('choose a report path below ' + str(allowed))
    # No output may be redirected through a symlink, even inside the project.
    if any(q.is_symlink() for q in (p, *p.parents) if q.is_relative_to(repo)):
        raise ValueError('symlink in output path: ' + str(p))
    for item in protected:
        q = access(item, required=False).resolve()
        if q == repo:
            continue  # The explicit output subtree above excludes source trees.
        if p.resolve().is_relative_to(q) or q.is_relative_to(p.resolve()):
            raise ValueError('output overlaps protected input: ' + str(p))
    return p
