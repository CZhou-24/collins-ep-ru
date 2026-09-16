#!/usr/bin/env python3
"""Two fresh complete native runs, exact pair, and both dependency-probe seeds.

Uses only the installed documented SIDIS CLI. Sources must remain frozen for
the entire campaign. Reports are external to the engine and saved input trees.
"""
import argparse
import datetime as dt
import hashlib
import json
import os
import subprocess
import sys
from pathlib import Path


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--reports', type=Path, required=True)
    parser.add_argument('--state', type=Path, required=True)
    args = parser.parse_args()
    root = Path(__file__).resolve().parents[3]
    engine = root/'collins_sidis_highpt'
    out, state = args.reports.resolve(), args.state.resolve()
    if any(p.is_relative_to(engine) or p.is_relative_to(root/'SIDIS') for p in (out, state)):
        raise ValueError('Campaign evidence must be outside implementation and saved-input trees')
    out.mkdir(parents=True, exist_ok=False)
    state.mkdir(parents=True, exist_ok=False)
    sys.path.insert(0, str(root/'collins_support/validators'))
    import sidis_highpt as h
    frozen = h.u.snapshot(engine)
    spec = h.validate_spec(h.u.read(engine/'project.json'), engine)
    sources = h.bind_sources(spec, engine, root/'SIDIS')
    runtime, validator = h.u.runtime(root), h.extension_identity()
    env = os.environ.copy()
    env.update(OPENBLAS_NUM_THREADS='1', OMP_NUM_THREADS='1', MKL_NUM_THREADS='1',
               PYTHONDONTWRITEBYTECODE='1', COLLINS_ANALYTIC_NO_CACHE='1')
    cli = [sys.executable, str(root/'collins_support/validators/sidis_highpt.py')]
    report = dict(status='RUNNING', scope='Complete native computational campaign for the declared small-R/small-jT Collins moment',
                  engine_sources=frozen, saved_inputs=sources, runtime=runtime, validator=validator,
                  commands=[], runs=[], independent_physics_review='PENDING', historical_acceptance_transferred=False)

    def save():
        (out/'campaign.json').write_text(json.dumps(report, indent=2)+'\n')

    def invariant():
        if h.u.snapshot(engine) != frozen:
            raise RuntimeError('Implementation changed during campaign')
        if h.bind_sources(spec, engine, root/'SIDIS') != sources:
            raise RuntimeError('Saved input changed during campaign')
        if h.extension_identity() != validator or h.u.runtime(root) != runtime:
            raise RuntimeError('Validator/runtime identity changed during campaign')

    def execute(name, arguments):
        invariant()
        log = out/(name+'.log')
        row = dict(name=name, command=cli+arguments,
                   started_utc=dt.datetime.now(dt.timezone.utc).isoformat(),
                   blas_threads=1, status='RUNNING')
        report['commands'].append(row)
        save()
        print('CAMPAIGN_STEP', name, flush=True)
        with log.open('x') as stream:
            result = subprocess.run(row['command'], cwd=root, env=env, stdout=stream, stderr=subprocess.STDOUT)
        row.update(exit_code=result.returncode, status='PASS' if result.returncode == 0 else 'FAIL',
                   finished_utc=dt.datetime.now(dt.timezone.utc).isoformat(),
                   log_sha256=hashlib.sha256(log.read_bytes()).hexdigest())
        save()
        if result.returncode:
            raise RuntimeError('First failing command: '+name+'; see '+str(log))
        invariant()
        return log

    save()
    try:
        execute('check-inputs', ['check-inputs', '--project', str(engine/'project.json'), '--sidis-root', str(root/'SIDIS')])
        for index in (1, 2):
            log = execute('run-'+str(index), ['run', '--project', str(engine/'project.json'), '--sidis-root', str(root/'SIDIS'),
                                            '--repo', str(root), '--state', str(state/'physical'), '--through', 'r07'])
            runs = set()
            for line in log.read_text().splitlines():
                try:
                    row = json.loads(line)
                except json.JSONDecodeError:
                    continue
                if isinstance(row, dict) and 'run' in row:
                    runs.add(str(Path(row['run']).resolve()))
            if len(runs) != 1:
                raise RuntimeError('Expected one distinct completed run in '+str(log))
            run = Path(runs.pop())
            result = h.u.read(run/'result.json')
            if result.get('status') != 'NATIVE_CHECKS_PASS':
                raise RuntimeError('Full native checks did not pass: '+str(run))
            boundary = h.u.read(run/'common/r07_result/boundary/summary.json')
            if (boundary.get('complete_boundary_inventory') is not True or
                    boundary.get('all_completed_pass') is not True or len(boundary.get('rows', {})) != 16):
                raise RuntimeError('Physical common-boundary check failed: '+str(run))
            report['runs'].append(str(run))
            report.setdefault('physical_boundary_checks', {})[str(run)] = boundary
            save()
        log = execute('pair', ['pair', '--run-a', report['runs'][0], '--run-b', report['runs'][1]])
        pair = json.loads(log.read_text())
        if pair.get('status') != 'PAIR_CHECKS_PASS':
            raise RuntimeError('Pair verdict not PASS')
        (out/'pair.json').write_text(json.dumps(pair, indent=2)+'\n')
        for seed in (1729, 92741):
            log = execute('probe-'+str(seed), ['probe', '--run', report['runs'][0],
                                              '--state', str(state/('probe-'+str(seed))), '--seed', str(seed)])
            probe = json.loads(log.read_text())
            if probe.get('status') != 'DEPENDENCY_CHECKS_PASS':
                raise RuntimeError('Dependency verdict not PASS: '+str(seed))
            (out/('probe-'+str(seed)+'.json')).write_text(json.dumps(probe, indent=2)+'\n')
        invariant()
        report.update(status='NATIVE_CAMPAIGN_CHECKS_PASS',
                      qualification='Current internal/reference computational checks and master-response probes; independent physics review remains pending. No finite-R accuracy or historical acceptance is certified.')
        save()
    except BaseException as exc:
        report.update(status='FAILED' if isinstance(exc, Exception) else 'INTERRUPTED', first_failure=str(exc))
        save()
        raise
    print(json.dumps(dict(status=report['status'], reports=str(out), runs=report['runs'])), flush=True)


if __name__ == '__main__':
    main()
