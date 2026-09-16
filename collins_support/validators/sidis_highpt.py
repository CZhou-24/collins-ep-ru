#!/usr/bin/env python3
"""Additive high-pT SIDIS runner. Reuses analytic/ without changing its contract.

The implementation supplies native stages and a frozen project specification.
This module owns execution, extraction, arithmetic checks and acceptance labels.
"""
import argparse
import copy
import datetime as dt
import hashlib
import json
import re
import shutil
import sys
import tempfile
import uuid
import zipfile
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE / 'analytic'))
import algebra as a
import ru_support as u
import workflow as w
import verify_ru as v

PROFILE = 'sidis_highpt_collins'
BASE_RELEASE = 'c016a289ceb0dbe5019373efcc23fea7d23f5adc5efed8664610f63663e0ecd3'
STAGES = tuple('r%02d' % i for i in range(8))
TOOLS = {'r01': 'kira', 'r02': 'subtropica', 'r04': 'kira', 'r05': 'subtropica'}
CHANNELS = {'Hqq', 'Hqg', 'Hgq', 'Hgg', 'Hqqbar', 'Hqqprime'}
KINDS = {'uu_recovery', 'born_reference', 'ward', 'spin_basis', 'normalization',
         'uv_poles', 'ir_poles', 'scale_consistency', 'finite', 'literature',
         'channel_zero', 'jet_matching', 'factorization', 'identity'}
SOURCE_ROLES = {'amplitudes', 'masters', 'reference', 'definitions', 'unpolarized_result'}
SHA = re.compile(r'[0-9a-f]{64}\Z')


def require(ok, message):
    if not ok:
        raise ValueError(message)


def named(s):
    return isinstance(s, str) and re.fullmatch(r'[A-Za-z][A-Za-z0-9_]*', s) is not None


def extension_identity():
    old = u.release_integrity()
    require(old == BASE_RELEASE, 'base validator differs from reviewed handoff; reconcile explicitly')
    manifest = u.read(HERE / 'sidis_highpt_files.json')
    require(manifest['base_release'] == BASE_RELEASE, 'wrong base release')
    for name, expected in manifest['files'].items():
        require(u.digest(u.contained(HERE, name)) == expected, 'extension changed: ' + name)
    return {'base': old, 'extension': u.digest(HERE / 'sidis_highpt_files.json')}


def validate_spec(spec, engine, through='r07'):
    full = through == 'r07'
    require(spec.get('schema') == 1 and spec.get('profile') == PROFILE, 'wrong project schema/profile')
    if spec.get('ready') is not True:
        raise u.Blocked('project specification is a template; implement stages and define the observable first')
    scope = spec['scope']
    require(scope.get('frame') == 'Breit' and scope.get('hard_orders') == {'LO': 1, 'NLO': 2},
            'high-pT SIDIS requires Breit-frame definition and alpha_s^1/alpha_s^2 orders')
    require(scope.get('observable') == 'Collins_hadron_in_jet', 'this adapter targets Collins hadron-in-jet only')
    for key in ('spin_definition', 'azimuth_definition', 'jet_algorithm', 'jet_radius',
                'jet_approximation', 'momentum_region', 'factorization_definition'):
        require(isinstance(scope.get(key), str) and scope[key].strip() and 'TODO' not in scope[key],
                'missing observable definition: ' + key)
    u.contained(engine, scope['documentation'])
    require(set(spec['stages']) == set(STAGES), 'all eight native stage paths must be declared')
    for sid, entry in spec['stages'].items():
        require(set(entry) == {'script', 'roles'} and entry['roles'], 'invalid stage definition: ' + sid)
        require(entry['script'].endswith('.wls'), 'native stage must be a Wolfram script')
        if STAGES.index(sid) <= STAGES.index(through):
            u.contained(engine, entry['script'])
    channels = spec['channels']
    require(set(channels) == CHANNELS, 'review all six SIDIS channel assignments explicitly')
    require(any(x.get('ut_active') is True and x.get('born') is True for x in channels.values()),
            'at least one active Born channel is required')
    for name, ch in channels.items():
        require((type(ch.get('ut_active')) is bool or (not full and ch.get('ut_active') is None))
                and type(ch.get('born')) is bool and ch.get('reason'),
                'missing channel reasoning: ' + name)
    sources = spec['sources']
    require(sources and all(named(k) for k in sources), 'invalid source IDs')
    for key, row in sources.items():
        require(row.get('root') in ('sidis', 'engine') and row.get('role') in SOURCE_ROLES,
                'invalid source role/root: ' + key)
        require(isinstance(row.get('sha256'), str) and SHA.fullmatch(row['sha256']), 'source needs SHA256: ' + key)
        require(isinstance(row.get('origin'), str) and row['origin'].strip(), 'source needs origin: ' + key)
    require(any(s['role'] == 'amplitudes' for s in sources.values()), 'saved amplitude inputs required')
    checks = spec['checks']
    require(checks and len({x['id'] for x in checks}) == len(checks), 'empty/duplicate check inventory')
    for c in checks:
        require(c.get('kind') in KINDS and c.get('stage') in STAGES and c.get('channel') in CHANNELS,
                'invalid check assignment: ' + c['id'])
        require(isinstance(c.get('lhs'), str) and c['lhs'].startswith(c['stage'] + '/'), 'check lhs needs stage value ID')
        if c['kind'] in ('uu_recovery', 'born_reference', 'literature'):
            ref = c.get('reference', {})
            require(ref.get('source') in sources and sources[ref['source']]['role'] == 'reference'
                    and isinstance(ref.get('equation'), str), 'comparison needs a pinned reference: ' + c['id'])
        elif c['kind'] != 'finite':
            require('rhs' in c, 'identity needs exact rhs: ' + c['id'])
            a.decode(c['rhs'])
            if c['kind'] in ('ward', 'uv_poles', 'ir_poles', 'channel_zero', 'scale_consistency'):
                require(a.equal(a.decode(c['rhs']), a.s.Integer(0)), 'this check requires zero: ' + c['id'])
        require(isinstance(c.get('reason'), str) and c['reason'].strip(), 'check requires a meaning: ' + c['id'])
    for name, ch in channels.items():
        rows = [x for x in checks if x['channel'] == name]
        kinds = {x['kind'] for x in rows}
        if not full:
            if ch['ut_active'] is True and ch['born']:
                require({'uu_recovery', 'born_reference', 'spin_basis', 'normalization', 'ward'} <=
                        {x['kind'] for x in rows if x['stage'] == 'r00'}, 'Born pilot checks must be available at r00: ' + name)
            continue
        require({'uu_recovery', 'finite', 'jet_matching'} <= kinds, 'unpolarized/jet checks required for every channel: ' + name)
        if ch.get('uu_source'):
            require(ch['uu_source'] in sources and sources[ch['uu_source']]['role'] == 'unpolarized_result', 'invalid reused UU source: ' + name)
            require(ch.get('uu_validation') in sources and sources[ch['uu_validation']]['role'] == 'definitions', 'reused UU requires its saved validation evidence: ' + name)
        if not ch['ut_active']:
            require(any(x['kind'] == 'channel_zero' and x['id'] == ch.get('zero_check') for x in rows),
                    'excluded channel needs a computed zero check: ' + name)
            require(ch.get('uu_source'), 'inactive UT still needs the validated UU contribution: ' + name)
            continue
        required = {'uu_recovery', 'ward', 'ir_poles', 'finite', 'factorization', 'jet_matching'}
        if ch['born']:
            required |= {'born_reference', 'spin_basis', 'normalization', 'uv_poles', 'scale_consistency'}
        require(required <= kinds, 'missing channel checks for ' + name + ': ' + ', '.join(sorted(required - kinds)))
        if ch['born']:
            require({'uu_recovery', 'born_reference', 'spin_basis', 'normalization', 'ward'} <=
                    {x['kind'] for x in rows if x['stage'] == 'r00'}, 'Born pilot checks must be available at r00: ' + name)
        require(any(x['kind'] == 'ward' and x['stage'] == 'r01' for x in rows), 'real Ward check required: ' + name)
    require(not full or spec['exports'], 'final export inventory is empty')
    for name, item in spec['exports'].items():
        require(item.get('channel') in channels
                and item.get('order') in (1, 2) and item.get('sector') in ('UU', 'UT'), 'invalid export: ' + name)
        require(item['sector'] == 'UU' or channels[item['channel']]['ut_active'], 'inactive UT is represented by its zero proof, not a nonzero export')
    for name, ch in channels.items():
        if not full:
            continue
        found = {(e['sector'], e['order']) for e in spec['exports'].values() if e['channel'] == name}
        needed = {(s, n) for s in (('UU', 'UT') if ch['ut_active'] else ('UU',)) for n in ((1, 2) if ch['born'] else (2,))}
        require(needed <= found, 'missing UU/UT perturbative exports: ' + name)
    for sid, imports in spec.get('master_imports', {}).items():
        require(sid in ('r02', 'r05') and isinstance(imports, dict), 'masters belong to r02/r05')
        for jid, item in imports.items():
            require(named(jid) and item.get('source') in sources, 'invalid imported master source')
            require(sources[item['source']]['role'] == 'masters', 'master import has wrong source role')
            require(item.get('selections') and set(item['selections']) == set(item.get('orders', {})), 'master selectors/orders mismatch')
            for key, path in item['selections'].items():
                require(named(key) and isinstance(path, list) and all(type(x) is str or (type(x) is int and x > 0) for x in path), 'invalid selector')
                require(type(item['orders'][key]) is int and 0 <= item['orders'][key] <= 4, 'invalid imported epsilon depth')
            require(item.get('definition') and item.get('precision_evidence'), 'imported masters need measure/depth documentation')
    return spec


def bind_sources(spec, engine, sidis):
    bound = {}
    for key, row in spec['sources'].items():
        path = u.contained(sidis if row['root'] == 'sidis' else engine, row['path'], links=True)
        require(u.digest(path) == row['sha256'], 'source identity mismatch: ' + key)
        bound[key] = {**row, 'resolved': str(path.resolve())}
    return bound


def exact_reference(check, sources):
    ref = check['reference']
    data = u.read(sources[ref['source']]['resolved'])
    eq = data['equations'][ref['equation']]
    require(eq.get('source_url') and eq.get('location') and eq.get('transcription'), 'reference provenance incomplete')
    require(eq.get('independence') in ('literature', 'independent_calculation', 'unpolarized_SIDIS'), 'invalid reference provenance')
    if check['kind'] == 'born_reference':
        require(eq['independence'] != 'unpolarized_SIDIS', 'polarized Born needs a separate reference calculation')
    value = a.decode(eq['value'])
    substitutions = {a.decode(k): a.decode(vv) for k, vv in check.get('reference_substitutions', {}).items()}
    require(all(k.is_Symbol for k in substitutions), 'reference conversion keys must be symbols')
    if substitutions:
        require(check.get('conversion'), 'reference substitutions require an explicit convention explanation')
        value = value.subs(substitutions, simultaneous=True)
    return value


def run_checks(spec, known, sources, through, enforce=True):
    rows = []
    for c in spec['checks']:
        if STAGES.index(c['stage']) > STAGES.index(through):
            continue
        require(c['lhs'] in known, 'missing check expression: ' + c['id'])
        lhs = known[c['lhs']]
        if c['kind'] == 'finite':
            ok = not lhs.has(a.s.Symbol('eps'), a.s.Symbol('eta'))
        else:
            rhs = exact_reference(c, sources) if 'reference' in c else a.decode(c['rhs'])
            ok = a.equal(lhs, rhs)
        rows.append({'id': c['id'], 'kind': c['kind'], 'channel': c['channel'], 'status': 'PASS' if ok else 'FAIL'})
    require(rows, 'no applicable scientific checks')
    if enforce:
        require(all(r['status'] == 'PASS' for r in rows), 'scientific checks failed: ' + ', '.join(r['id'] for r in rows if r['status'] != 'PASS'))
    return rows


def audit_packets(spec, packets, masters, orders, sources, through='r07', enforce=True):
    known = dict(masters)
    recipes = {}
    for sid in STAGES[:STAGES.index(through) + 1]:
        packet = packets[sid]
        require(packet.get('schema') == 5 and packet.get('stage') == sid, 'wrong native packet identity')
        require(all(k.startswith(sid + '/') for k in packet.get('values', {})), 'wrong value stage')
        done, new = a.evaluate_values(packet, known)
        known.update(done)
        recipes.update(new)
    a.check_precision(recipes, orders)
    rows = run_checks(spec, known, sources, through, enforce)
    exports = packets[through].get('exports', {}) if through == 'r07' else {}
    if through == 'r07':
        require(set(exports) == set(spec['exports']), 'wrong high-pT export inventory')
        for name, out in exports.items():
            require(set(out) == {'value', 'evidence'} and out['value'] in known, 'invalid export: ' + name)
            require(not known[out['value']].has(a.s.Symbol('eps'), a.s.Symbol('eta')), 'regulator remains in finite output: ' + name)
        # Check each channel/sector collectively: individual delta/plus/regular
        # coefficients can legitimately have only real or only virtual terms.
        for channel, ch in spec['channels'].items():
            for sector in ('UU', 'UT'):
                if (sector == 'UT' and not ch['ut_active']) or (sector == 'UU' and ch.get('uu_source')):
                    continue
                dependencies = set().union(*(a.dependencies(exports[n]['value'], recipes)
                    for n, e in spec['exports'].items()
                    if e['channel'] == channel and e['sector'] == sector and e['order'] == 2))
                require(any(k.startswith('master/r02/') for k in dependencies), 'NLO sector has no real-master dependency: ' + channel + '/' + sector)
                if ch['born']:
                    require(any(k.startswith('master/r05/') for k in dependencies), 'NLO sector has no virtual-master dependency: ' + channel + '/' + sector)
    return {'values': known, 'recipes': recipes, 'masters': masters, 'exports': exports, 'packets': packets, 'checks': rows}


def extract_masters(sid, jid, item, sources, out, rt):
    work = out / 'jobs' / jid
    work.mkdir(parents=True, exist_ok=False)
    context = {'input': sources[item['source']]['resolved'], 'selections': item['selections'], 'orders': item['orders'],
               'output': str(work / 'masters.wl')}
    u.write(work / 'extract_context.json', context)
    ex = u.execute([rt['config']['wolfram_kernel'], '-noprompt', '-script', HERE / 'sidis_highpt_extract.wls'],
                   work, work / 'extract.log', rt['config']['timeout_seconds'], {'SIDIS_EXTRACT_CONTEXT': work / 'extract_context.json'})
    require(ex['exit_code'] == 0, 'native saved-master extraction failed')
    nx = w.export_native(work / 'masters.wl', work / 'masters.json', 'masters', rt, work / 'native-export')
    actual = u.read(work / 'masters.json')
    require(set(actual) == set(item['selections']), 'imported master inventory mismatch')
    return {'kind': 'imported_master', 'job': {'id': jid}, 'source': item['source'], 'orders': item['orders'],
            'execution': ex, 'reexport': nx, 'outputs': {n: u.digest(work / n) for n in ('masters.wl', 'masters.json', 'extract_context.json')},
            'audited_outputs': {}, 'definition': item['definition'], 'precision_evidence': item['precision_evidence'],
            'fresh_integration': False}


def stage_record(spec, sid):
    return {'id': sid, **spec['stages'][sid], 'tool': TOOLS.get(sid)}


def execute_stage(spec, sid, engine, run, sources, rt, probe=False):
    out = run / 'common' / (sid + '_result')
    out.mkdir(parents=True, exist_ok=False)
    # References are deliberately absent from the producing-stage context.
    context = {'schema': 5, 'stage': sid, 'profile': PROFILE, 'production': str(engine), 'output': str(out),
               'inputs': {s: str(run / 'common' / (s + '_result')) for s in STAGES if s < sid},
               'saved_inputs': {k: row for k, row in sources.items() if row['role'] != 'reference'},
               'master_imports': spec.get('master_imports', {}).get(sid, {}), 'channels': spec['channels'],
               'export_inventory': spec['exports'],
               'runtime': rt['config'], 'scope': spec['scope'], 'no_cache': True, 'validation_probe': probe}
    u.write(out / 'context.json', context)
    ex = u.execute([rt['config']['wolfram_kernel'], '-noprompt', '-script', u.contained(engine, spec['stages'][sid]['script'])],
                   engine, out / 'execution.log', rt['config']['timeout_seconds'],
                   {'COLLINS_RU_CONTEXT': out / 'context.json', 'SIDIS_HIGHPT_CONTEXT': out / 'context.json', 'COLLINS_ANALYTIC_NO_CACHE': '1'})
    require(ex['exit_code'] == 0, 'native stage failed: ' + sid)
    nx = w.export_native(out / 'packet.wl', out / 'packet.json', 'packet', rt, out / 'native-export')
    packet = u.read(out / 'packet.json')
    require(packet.get('schema') == 5 and packet.get('stage') == sid, 'wrong stage packet')
    jobs = packet.get('jobs', [])
    require(isinstance(jobs, list) and (not jobs or sid in TOOLS), 'unexpected tool jobs')
    imports = spec.get('master_imports', {}).get(sid, {})
    ids = [j['id'] for j in jobs] + list(imports)
    require(len(set(ids)) == len(ids), 'duplicate native/import job IDs')
    if sid in ('r01', 'r04'):
        a.check_families(packet, sid == 'r01')
        require(jobs and {f['id'] for f in packet['families']} == {f for j in jobs for f in j['families']}, 'incomplete reduction coverage')
    if sid in ('r02', 'r05'):
        require(jobs or imports, 'no fresh or imported masters')
    receipts = [w.job_execute(stage_record(spec, sid), j, out, rt, packet) for j in jobs]
    receipts += [extract_masters(sid, jid, item, sources, out, rt) for jid, item in imports.items()]
    return {'stage': sid, 'execution': ex, 'native_export': nx, 'jobs': receipts, 'tree': u.snapshot(out)}


def receipt_ok(ex, log):
    require(ex['exit_code'] == 0 and ex['log_sha256'] == u.digest(log), 'native execution/log changed')


def audit_run(run, allow_probe=False, check_runtime=True):
    run = Path(run).resolve()
    meta = u.read(run / 'run.json')
    require(meta.get('profile') == PROFILE and meta.get('schema') == 1, 'wrong run profile/schema')
    require(meta.get('run_path') == str(run), 'run was copied or moved; use its original evidence location')
    require(meta.get('status') == 'EXECUTED', 'native run did not complete')
    probe = meta.get('mode') == 'dependency_probe'
    require(not probe or allow_probe, 'dependency probe is not a fresh physical run')
    require(probe or meta.get('mode') == 'fresh', 'unknown execution mode')
    require(meta['validator'] == extension_identity(), 'validator identity changed')
    engine, sidis = Path(meta['engine']), Path(meta['sidis_root'])
    spec = validate_spec(u.read(run / 'project.json'), engine, through=meta['through'])
    require(u.identity(spec) == meta['project_identity'], 'run specification changed')
    require(u.snapshot(engine) == meta['engine_sources'], 'implementation changed after execution')
    sources = bind_sources(spec, engine, sidis)
    require(sources == meta['sources'], 'saved inputs changed')
    if check_runtime:
        require(u.runtime(meta['repo']) == meta['runtime'], 'native runtime changed')
    packets, masters, orders, graph, locations = {}, {}, {}, {}, {}
    for name, source in sources.items():
        graph['input/' + name] = {'parents': [], 'role': source['role'], 'sha256': source['sha256']}
    for sid in STAGES[:STAGES.index(meta['through']) + 1]:
        out = run / 'common' / (sid + '_result')
        receipt = u.read(run / 'receipts' / (sid + '.json'))
        packet = u.read(out / 'packet.json')
        packets[sid] = packet
        require(receipt['stage'] == sid and receipt['tree'] == u.snapshot(out), 'changed native stage: ' + sid)
        receipt_ok(receipt['execution'], out / 'execution.log')
        receipt_ok(receipt['native_export'], out / 'native-export' / 'execution.log')
        context = u.read(out / 'context.json')
        if not probe:
            require(context['output'] == str(out) and context.get('profile') == PROFILE and context['validation_probe'] is False,
                    'fresh stage context mismatch')
        expected_ids = {j['id'] for j in packet.get('jobs', [])} | set(spec.get('master_imports', {}).get(sid, {}))
        require(expected_ids == {r['job']['id'] for r in receipt['jobs']}, 'changed native job coverage')
        for jr in receipt['jobs']:
            jid = jr['job']['id']
            work = out / 'jobs' / jid
            for name, digest in {**jr['outputs'], **jr['audited_outputs']}.items():
                require(u.digest(u.contained(work, name)) == digest, 'native output changed')
            if jr['kind'] == 'imported_master':
                entry = spec['master_imports'][sid][jid]
                require(entry['source'] == jr['source'] and entry['orders'] == jr['orders'], 'master import identity changed')
                receipt_ok(jr['execution'], work / 'extract.log')
                ec = u.read(work / 'extract_context.json')
                require(ec['input'] == sources[entry['source']]['resolved'] and ec['selections'] == entry['selections'] and ec['orders'] == entry['orders'], 'wrong imported-master selection')
                available = jr['orders']
            else:
                require(jr['job'] in packet['jobs'], 'job differs from native packet')
                for name, digest in jr['inputs'].items():
                    require(u.digest(u.contained(work, name)) == digest, 'tool input changed')
                receipt_ok(jr['execution'], work / 'tool.log')
                if jr['kind'] == 'kira':
                    receipt_ok(jr['kira_audit'], work / 'kira_audit.log')
                    require(u.read(work / 'reduction_audit.json')['status'] == 'PASS', 'native reduction audit failed')
                    continue
                require(jr['kind'] == 'subtropica', 'unknown native job kind')
                available = u.read(work / 'subtropica_execution.json')['orders']
            receipt_ok(jr['reexport'], work / 'native-export' / 'execution.log')
            values = u.read(work / 'masters.json')
            require(set(values) == set(available), 'master precision inventory mismatch')
            for name, val in values.items():
                require(named(name) and type(available[name]) is int and 0 <= available[name] <= 4, 'invalid master name/depth')
                key = 'master/' + sid + '/' + jid + '/' + name
                masters[key] = a.decode(val)
                orders[key] = available[name]
                locations[key] = {'stage': sid, 'job': jid, 'key': name, 'path': str(work / 'masters.wl')}
        if sid in ('r01', 'r04'):
            a.check_families(packet, sid == 'r01')
        w.graph_add(packet, out, stage_record(spec, sid), graph, receipt['jobs'], engine)
    data = audit_packets(spec, packets, masters, orders, sources, meta['through'], enforce=not probe)
    def ancestors(key, seen=None):
        require(key in graph, 'missing evidence: ' + key)
        seen = set() if seen is None else seen
        if key not in seen:
            seen.add(key)
            for parent in graph[key]['parents']:
                ancestors(parent, seen)
        return seen
    if meta['through'] == 'r07':
        reached = set().union(*(ancestors(x['evidence']) for x in data['exports'].values()))
        require(all('input/' + k in reached for k, s in sources.items() if s['role'] in ('amplitudes', 'masters', 'unpolarized_result')), 'saved amplitudes/masters/UU results absent from output provenance')
        require({k for k in graph if k.startswith('tool/')} <= reached, 'tool evidence disconnected from final outputs')
        require(all('source/' + sid in reached for sid in STAGES), 'source stage disconnected from final outputs')
    data['locations'] = locations
    return meta, data


def run_project(project, sidis_root, repo, state, through):
    project = Path(project).resolve()
    engine, sidis = project.parent, Path(sidis_root).resolve()
    spec = validate_spec(u.read(project), engine, through=through)
    sources = bind_sources(spec, engine, sidis)
    state = Path(state).resolve()
    require(not state.is_relative_to(engine) and not state.is_relative_to(sidis), 'state must be outside implementation/upstream trees')
    ident = extension_identity()
    rt = u.runtime(repo)
    stamp = dt.datetime.now(dt.timezone.utc).strftime('%Y%m%dT%H%M%SZ') + '-' + uuid.uuid4().hex[:12]
    run = state / stamp
    run.mkdir(parents=True, exist_ok=False)
    meta = {'schema': 1, 'profile': PROFILE, 'mode': 'fresh', 'status': 'RUNNING', 'run_id': stamp,
            'run_path': str(run), 'repo': str(Path(repo).resolve()), 'engine': str(engine), 'sidis_root': str(sidis),
            'through': through, 'validator': ident, 'runtime': rt, 'sources': sources,
            'project_identity': u.identity(spec), 'engine_sources': u.snapshot(engine)}
    u.write(run / 'project.json', spec)
    u.write(run / 'run.json', meta)
    print(json.dumps({'run': str(run)}), flush=True)
    try:
        for sid in STAGES[:STAGES.index(through) + 1]:
            print(sid + ': native SIDIS stage', flush=True)
            rec = execute_stage(spec, sid, engine, run, sources, rt)
            require(u.snapshot(engine) == meta['engine_sources'], 'implementation changed during run')
            require(bind_sources(spec, engine, sidis) == sources, 'saved inputs changed during run')
            require(extension_identity() == ident, 'validator changed during run')
            u.write(run / 'receipts' / (sid + '.json'), rec)
        meta['status'] = 'EXECUTED'
        u.write(run / 'run.json', meta, replace=True)
        _, data = audit_run(run)
        result = {'status': 'NATIVE_CHECKS_PASS' if through == 'r07' else 'DEVELOPMENT_PASS',
                  'profile': PROFILE, 'through': through, 'checks': data['checks'],
                  'independent_physics_review': 'PENDING', 'pair_and_dependency_probes': 'NOT_RUN',
                  'scope': spec['scope'], 'run': str(run)}
        u.write(run / 'result.json', result)
        print(json.dumps(result), flush=True)
        return run
    except Exception as exc:
        meta.update(status='FAILED', error=str(exc))
        u.write(run / 'run.json', meta, replace=True)
        raise


def compare_runs(first, second):
    ma, aa = audit_run(first)
    mb, bb = audit_run(second)
    require(ma['through'] == mb['through'] == 'r07', 'complete r07 runs required')
    require(ma['run_id'] != mb['run_id'] and ma['run_path'] != mb['run_path'], 'two distinct fresh runs required')
    for key in ('project_identity', 'engine_sources', 'sources', 'validator', 'runtime'):
        require(ma[key] == mb[key], 'pair identity differs: ' + key)
    require(set(aa['exports']) == set(bb['exports']), 'pair export inventory differs')
    for key in aa['exports']:
        require(a.equal(aa['values'][aa['exports'][key]['value']], bb['values'][bb['exports'][key]['value']]), 'pair output mismatch: ' + key)
    return {'status': 'PAIR_CHECKS_PASS', 'profile': PROFILE, 'runs': [ma['run_path'], mb['run_path']],
            'exports': len(aa['exports']), 'independent_physics_review': 'PENDING'}


def dependency_probe(baseline, state, seed):
    require(seed in (1729, 92741), 'supported probe seeds: 1729, 92741')
    baseline = Path(baseline).resolve()
    meta, data = audit_run(baseline)
    require(meta['through'] == 'r07', 'complete baseline required')
    spec = u.read(baseline / 'project.json')
    state = Path(state).resolve()
    protected = [baseline, Path(meta['engine']), Path(meta['sidis_root']), HERE]
    require(not any(state.is_relative_to(p) or p.is_relative_to(state) for p in protected), 'probe destination overlaps inputs')
    rows = []
    for kind, sid in [('real_master', 'r02'), ('virtual_master', 'r05')]:
        key = v.choose_master(data, sid, seed)
        loc = data['locations'][key]
        factor = a.s.Rational(seed % 5 + 7, 6)
        run = state / (kind + '-' + uuid.uuid4().hex[:12])
        run.mkdir(parents=True, exist_ok=False)
        prefix = STAGES[:STAGES.index(sid) + 1]
        for stage in prefix:
            shutil.copytree(baseline / 'common' / (stage + '_result'), run / 'common' / (stage + '_result'))
            u.write(run / 'receipts' / (stage + '.json'), u.read(baseline / 'receipts' / (stage + '.json')))
        m = copy.deepcopy(meta)
        m.update(mode='dependency_probe', status='RUNNING', run_id=run.name, run_path=str(run), baseline=str(baseline))
        u.write(run / 'run.json', m)
        u.write(run / 'project.json', spec)
        work = run / 'common' / (sid + '_result') / 'jobs' / loc['job']
        mutation = {'kind': 'master', 'path': str(work / 'masters.wl'), 'key': loc['key'], 'numerator': int(factor.p), 'denominator': int(factor.q)}
        u.write(run / 'mutation-context.json', mutation)
        ex = u.execute([meta['runtime']['config']['wolfram_kernel'], '-noprompt', '-script', HERE / 'analytic' / 'native_mutate.wls'],
                       run, run / 'mutation.log', meta['runtime']['config']['timeout_seconds'], {'COLLINS_RU_MUTATION': run / 'mutation-context.json'})
        require(ex['exit_code'] == 0, 'master mutation failed')
        (work / 'masters.json').unlink()
        shutil.rmtree(work / 'native-export')  # Disposable copied probe only.
        nx = w.export_native(work / 'masters.wl', work / 'masters.json', 'masters', meta['runtime'], work / 'native-export')
        rec = u.read(run / 'receipts' / (sid + '.json'))
        jr = next(j for j in rec['jobs'] if j['job']['id'] == loc['job'])
        jr['reexport'] = nx
        jr['outputs'] = {name: u.digest(work / name) for name in jr['outputs']}
        rec['tree'] = u.snapshot(run / 'common' / (sid + '_result'))
        u.write(run / 'receipts' / (sid + '.json'), rec, replace=True)
        for stage in STAGES[len(prefix):]:
            receipt = execute_stage(spec, stage, Path(meta['engine']), run, meta['sources'], meta['runtime'], probe=True)
            u.write(run / 'receipts' / (stage + '.json'), receipt)
        m['status'] = 'EXECUTED'
        u.write(run / 'run.json', m, replace=True)
        _, actual = audit_run(run, allow_probe=True)
        changed = v.check_probe(kind, data, actual, key, factor)
        rows.append({'kind': kind, 'run': str(run), 'master': key, 'factor': str(factor), 'changed_exports': changed,
                     'status': 'PASS', 'fresh_physical_run': False})
    return {'status': 'DEPENDENCY_CHECKS_PASS', 'seed': seed, 'baseline': str(baseline), 'probes': rows}


def inspect_handoff(root):
    root = Path(root).resolve()
    if root.is_file():
        with tempfile.TemporaryDirectory(prefix='sidis-handoff-') as tmp:
            with zipfile.ZipFile(root) as z:
                for entry in z.infolist():
                    p = Path(entry.filename)
                    require(not p.is_absolute() and '..' not in p.parts and '\\' not in entry.filename, 'unsafe handoff archive path')
                z.extractall(tmp)
            return inspect_handoff(tmp)
    manifest = u.read(root / 'BUNDLE_MANIFEST.json')
    for name, entry in manifest['files'].items():
        f = u.contained(root, name)
        require(f.stat().st_size == entry['size'] and u.digest(f) == entry['sha256'], 'handoff hash mismatch: ' + name)
    run = u.read(root / 'run.json')
    require(run['release'] == BASE_RELEASE and run['profile'] == 'reverse_unitarity_current', 'wrong handoff baseline')
    for sid in STAGES:
        rec = u.read(root / 'receipts' / (sid + '.json'))
        for name in ('packet.json', 'packet.wl'):
            require(u.digest(root / 'common' / (sid + '_result') / name) == rec['tree'][name]['sha256'], 'packet/receipt mismatch')
        require(u.read(root / 'common' / (sid + '_result') / 'packet.json')['stage'] == sid, 'packet stage mismatch')
    pair = u.read(root / 'reports' / 'pair.json')
    require(pair['release'] == BASE_RELEASE and pair['status'] == 'CHECKS_PASS', 'wrong reported pair')
    for seed, row in zip((1729, 92741), pair['reports']):
        f = root / 'reports' / ('ru-%d.json' % seed)
        require(u.digest(f) == row['sha256'], 'report alias/hash mismatch')
        report = u.read(f)
        require(report['seed'] == seed and report['status'] == 'CHECKS_PASS', 'wrong report identity/status')
    return {'status': 'HANDOFF_INTEGRITY_PASS', 'files': len(manifest['files']),
            'native_replay': False, 'scope': 'provided subset integrity only; missing raw evidence is not replayed'}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    sub = parser.add_subparsers(dest='command', required=True)
    handoff = sub.add_parser('inspect-handoff'); handoff.add_argument('--bundle', required=True)
    check = sub.add_parser('check-inputs'); check.add_argument('--project', required=True); check.add_argument('--sidis-root', required=True)
    run = sub.add_parser('run'); run.add_argument('--project', required=True); run.add_argument('--sidis-root', required=True)
    run.add_argument('--repo', default=str(HERE.parents[1])); run.add_argument('--state', required=True); run.add_argument('--through', choices=STAGES, default='r07')
    audit = sub.add_parser('audit'); audit.add_argument('--run', required=True)
    pair = sub.add_parser('pair'); pair.add_argument('--run-a', required=True); pair.add_argument('--run-b', required=True)
    probe = sub.add_parser('probe'); probe.add_argument('--run', required=True); probe.add_argument('--state', required=True); probe.add_argument('--seed', type=int, required=True)
    args = parser.parse_args()
    try:
        extension_identity()
        if args.command == 'inspect-handoff':
            result = inspect_handoff(args.bundle)
        elif args.command == 'check-inputs':
            engine = Path(args.project).resolve().parent
            spec = validate_spec(u.read(args.project), engine)
            result = {'status': 'INPUTS_READY', 'sources': len(bind_sources(spec, engine, Path(args.sidis_root).resolve())), 'native_execution': False}
        elif args.command == 'run':
            run_project(args.project, args.sidis_root, args.repo, args.state, args.through)
            return 0
        elif args.command == 'audit':
            meta, data = audit_run(args.run)
            result = {'status': 'NATIVE_CHECKS_PASS' if meta['through'] == 'r07' else 'DEVELOPMENT_PASS', 'checks': data['checks'], 'independent_physics_review': 'PENDING'}
        elif args.command == 'pair':
            result = compare_runs(args.run_a, args.run_b)
        else:
            result = dependency_probe(args.run, args.state, args.seed)
        print(json.dumps(result, indent=2))
        return 0
    except Exception as exc:
        result, code = u.error_result(exc)
        print(json.dumps(result))
        return code


if __name__ == '__main__':
    raise SystemExit(main())
