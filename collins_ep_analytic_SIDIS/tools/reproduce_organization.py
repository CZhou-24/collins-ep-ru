#!/usr/bin/python3.10
"""Reproduce the organized engine with the relocated v0.5.1 official tools.

Run from /bigTMD, with an unused --state below collins_support/states/runs.
Historical freezes retain their original identities; the relocation record
admits only the specifically recorded path/configuration changes.
"""
import argparse
import hashlib
import json
import os
from pathlib import Path
import stat
import subprocess
import sys

sys.dont_write_bytecode = True
PROJECT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(PROJECT/'collins_support'))
from paths import access, check_file, same_snapshot, same_release, output_path

VALIDATOR = access('collins_support/validators/analytic')
ACCEPTED = PROJECT/'collins_ep_analytic_SIDIS_review/reverse-unitarity-002'
REVIEW = PROJECT/'collins_ep_analytic_SIDIS_review/organization-001'
PINS = {
    ACCEPTED/'audit/SOURCE_FREEZE_001.json': '10862558e20c4b5e20a0248453301655e2c4c10e7351535e50c4707e43db3ded',
    PROJECT/'collins_support/states/Collins-ep-analytic-state-v0.5.1/ru-pair.json': 'fe8d570c605e6b4bae43b108ee9f76b7dfb86a2198345c388ebe9d2d0d6ba8f8',
    VALIDATOR/'MANIFEST.json': '7bd929a50ea81b8af7d58c91063205d5047cc1bf60b7aa6c449d7661d2f79f0f',
}


def digest(path):
    h = hashlib.sha256()
    with access(path).open('rb') as stream:
        for block in iter(lambda: stream.read(1048576), b''):
            h.update(block)
    return h.hexdigest()


def read(path):
    return json.loads(access(path).read_text())


def write(path, data):
    Path(path).write_text(json.dumps(data, indent=2, sort_keys=True)+'\n')


def strict_snapshot(root):
    """Include every file/link, including caches ignored by the official scanner."""
    result = {}
    for parent, dirs, files in os.walk(root, followlinks=False):
        for name in sorted(set(dirs+files)):
            path = Path(parent)/name
            info = path.lstat()
            key = path.relative_to(root).as_posix()
            if stat.S_ISLNK(info.st_mode):
                result[key] = {'kind': 'symlink', 'target': os.readlink(path)}
            elif stat.S_ISREG(info.st_mode):
                result[key] = {'kind': 'file', 'size': info.st_size, 'sha256': digest(path)}
            elif not stat.S_ISDIR(info.st_mode):
                raise ValueError('Special source entry: '+key)
    return result


def check_inputs(repo, require_freeze=True):
    sys.path.insert(0, str(VALIDATOR))
    import workflow
    for path, expected in PINS.items():
        valid = same_release(VALIDATOR, expected) if path == VALIDATOR/'MANIFEST.json' else check_file(path, expected)
        if not valid:
            raise ValueError('Accepted checkpoint identity changed: '+str(path))
    old = read(ACCEPTED/'audit/SOURCE_FREEZE_001.json')
    original = read(REVIEW/'ORIGINAL_FILE_PRESERVATION.json')
    if original['sources'] != old['sources'] or len(old['sources']) != 101:
        raise ValueError('Original preservation inventory changed')
    current = strict_snapshot(repo/'collins_ep_analytic_SIDIS')
    allowed = read(REVIEW/'ADDITIONS_MANIFEST.json')['allowed_additions']
    if len(set(allowed)) != len(allowed) or set(allowed) & set(old['sources']):
        raise ValueError('Invalid additions allowlist')
    if set(current) != set(old['sources']) | set(allowed):
        raise ValueError('Missing or unlisted source addition')
    if not same_snapshot(repo/'collins_ep_analytic_SIDIS', old['sources'],
                         {name: current[name] for name in old['sources']}):
        raise ValueError('Original entry changed beyond recorded relocation edits')
    release = workflow.release_integrity()
    if not same_release(VALIDATOR, old['release']):
        raise ValueError('Preserved release identity changed beyond relocation edits')
    for key, actual in (
        ('runtime', workflow.runtime(repo)),
        ('accepted_source_hash', workflow.preserve_old(repo)),
        ('sidis_sources', workflow.upstream_source_state(repo)),
        ('reuse', workflow.check_reuse(repo/'collins_ep_analytic_SIDIS')),
    ):
        if actual != old[key]:
            raise ValueError('Preserved identity changed: '+key)
    cleanup = read(REVIEW/'CLEANUP_RESULT.json')
    if cleanup['status'] != 'COMPLETE':
        raise ValueError('Cleanup is incomplete')
    # This receipt remains historical evidence, not an active archive-deletion
    # contract. Current source/input checks are enforced above and below.
    identity = {
        'sources': current, 'runtime': old['runtime'], 'release': release,
        'accepted_source_hash': old['accepted_source_hash'],
        'sidis_sources': old['sidis_sources'], 'reuse': old['reuse'],
        'original_manifest_sha256': digest(REVIEW/'ORIGINAL_FILE_PRESERVATION.json'),
        'additions_manifest_sha256': digest(REVIEW/'ADDITIONS_MANIFEST.json'),
        'cleanup_result_sha256': digest(REVIEW/'CLEANUP_RESULT.json'),
    }
    if require_freeze:
        frozen = read(REVIEW/'ORGANIZED_SOURCE_FREEZE.json')['identity']
        if not same_snapshot(repo/'collins_ep_analytic_SIDIS', frozen['sources'], current):
            raise ValueError('Organized source freeze changed beyond relocation edits')
        if not same_release(VALIDATOR, frozen['release']):
            raise ValueError('Organized release freeze changed beyond relocation edits')
        if {k:v for k,v in frozen.items() if k not in ('sources','release')} != {
                k:v for k,v in identity.items() if k not in ('sources','release')}:
            raise ValueError('Organized input freeze changed')
    return identity


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--state', required=True, type=Path)
    parser.add_argument('--repo', default='/bigTMD', type=Path)
    parser.add_argument('--reports', type=Path,
                        help='Unused current-report directory under collins_support/reports')
    parser.add_argument('--accepted-pair', type=Path,
                        default='collins_support/states/Collins-ep-analytic-state-v0.4.0/literature-revalidation-001/nlo-pair.json')
    args = parser.parse_args()
    repo = args.repo.resolve()
    args.accepted_pair = access(args.accepted_pair)
    state = output_path(args.state, repo,
                        protected=(VALIDATOR, args.accepted_pair.parent), area='states')
    if repo != Path('/bigTMD') or Path.cwd().resolve() != repo:
        raise ValueError('This pinned edition runs from /bigTMD with --repo /bigTMD')
    if os.path.lexists(state):
        raise ValueError('Choose an unused state directory')
    runs = repo/'collins_support/states/runs'
    if not state.is_relative_to(runs) or state == runs:
        raise ValueError('Use collins_support/states/runs/<unused run ID>')
    reports = output_path(args.reports or repo/'collins_support/reports'/('organization-'+state.name),
                          repo, protected=(VALIDATOR, args.accepted_pair.parent), area='reports')
    if os.path.lexists(reports):
        raise ValueError('Choose an unused current-report directory')
    before = check_inputs(repo)
    state.mkdir(parents=True, exist_ok=False)
    reports.mkdir(parents=True, exist_ok=False)
    logs = state/'reproduction-logs'
    logs.mkdir()
    write(state/'INPUT_PRESERVATION_BEFORE.json', {'status': 'PASS', 'identity': before})
    env = dict(os.environ, PYTHONDONTWRITEBYTECODE='1', OPENBLAS_NUM_THREADS='1',
               OMP_NUM_THREADS='1', MKL_NUM_THREADS='1')
    commands = []

    def run(name, script, *arguments):
        command = ['/usr/bin/python3.10', str(VALIDATOR/script), *map(str, arguments)]
        log = logs/(name+'.log')
        print('Executing '+name, flush=True)
        with log.open('x') as stream:
            completed = subprocess.run(command, cwd=repo, env=env,
                                       stdout=stream, stderr=subprocess.STDOUT)
        commands.append({'name': name, 'argv': command, 'cwd': str(repo),
                         'environment': {k: env[k] for k in ('PYTHONDONTWRITEBYTECODE',
                                         'OPENBLAS_NUM_THREADS', 'OMP_NUM_THREADS', 'MKL_NUM_THREADS')},
                         'exit_code': completed.returncode, 'log': str(log),
                         'log_sha256': digest(log)})
        write(state/'REPRODUCTION_COMMANDS.json', commands)
        if completed.returncode:
            raise RuntimeError('Stopped on '+name+'; retain '+str(log))
        objects = []
        for line in log.read_text().splitlines():
            try:
                value = json.loads(line)
                if isinstance(value, dict):
                    objects.append(value)
            except json.JSONDecodeError:
                pass
        return objects

    run('selftest', 'selftest.py')
    run('doctor', 'workflow.py', 'doctor', '--repo', repo)
    paths = []
    for letter in ('A', 'B'):
        values = run('run-'+letter, 'workflow.py', 'run', '--repo', repo, '--state', state)
        result = next(value for value in reversed(values) if 'status' in value)
        if result['status'] != 'STAGES_PASS':
            raise RuntimeError(str(result))
        actual = Path(result['run']).resolve()
        if not actual.is_relative_to(state/'runs') or str(actual) in paths:
            raise ValueError('Unexpected or reused printed native run path')
        paths.append(str(actual))
        write(state/'RUN_LOCATIONS.json', {'runs': paths})
    for seed in (1729, 92741):
        report = reports/('ru-'+str(seed)+'.json')
        run('verify-'+str(seed), 'verify_ru.py', '--repo', repo, '--run', paths[0],
            '--replay', paths[1], '--seed', seed, '--accepted-pair', args.accepted_pair,
            '--report', report)
        if read(report)['status'] != 'CHECKS_PASS':
            raise RuntimeError('Seed report did not pass')
    run('compare', 'compare_ru_reports.py', '--repo', repo, '--report', reports/'ru-pair.json',
        reports/'ru-1729.json', reports/'ru-92741.json')
    if read(reports/'ru-pair.json')['status'] != 'CHECKS_PASS':
        raise RuntimeError('Official pair did not pass')
    after = check_inputs(repo)
    if after != before:
        raise ValueError('Inputs changed during reproduction')
    write(state/'INPUT_PRESERVATION_AFTER.json', {'status': 'PASS', 'identity': after})
    result = {'status': 'CHECKS_PASS', 'runs': paths, 'pair': str(reports/'ru-pair.json'),
              'pair_sha256': digest(reports/'ru-pair.json'),
              'organized_freeze_sha256': digest(REVIEW/'ORGANIZED_SOURCE_FREEZE.json'),
              'note': 'Official checks with explicit relocation identities; scientific qualifications are unchanged.'}
    write(reports/'REPRODUCTION_RESULT.json', result)
    print(json.dumps(result), flush=True)


if __name__ == '__main__':
    main()
