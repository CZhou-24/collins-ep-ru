"""Software-only acceptance and rejection tests. Synthetic algebra is not physics."""
import copy
import hashlib
import json
import os
import sys
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
import sidis_highpt as h


def write(path, value):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(value))


def value(constant=0, terms=(), result=0, order=0):
    return {'constant': constant, 'terms': [{'ref': k, 'factor': f} for k, f in terms],
            'value': result, 'eta_order': 0, 'eps_order': order, 'sectors': ['Hqq']}


class Fixture(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.root = Path(self.tmp.name)
        self.engine = self.root / 'engine'; self.engine.mkdir()
        self.sidis = self.root / 'SIDIS'; self.sidis.mkdir()
        (self.sidis / 'amplitudes.wl').write_text('<|"Born" -> Spinor[p]|>')
        (self.sidis / 'uu.wl').write_text('(* synthetic saved unpolarized coefficients *)')
        (self.sidis / 'uu_evidence.json').write_text('{"scope":"synthetic saved comparison evidence"}')
        (self.engine / 'scope.md').write_text('Synthetic test fixture, no physical result.')
        write(self.engine / 'reference.json', {'equations': {
            'UU': {'value': 2, 'source_url': 'fixture:independent', 'location': 'test', 'transcription': 'synthetic', 'independence': 'unpolarized_SIDIS'},
            'UT': {'value': 1, 'source_url': 'fixture:independent', 'location': 'test', 'transcription': 'synthetic', 'independence': 'independent_calculation'}}})
        for sid in h.STAGES:
            (self.engine / (sid + '.wls')).write_text('(* Fixture only *)')
        scope = {k: 'fixture' for k in ('spin_definition', 'azimuth_definition', 'jet_algorithm', 'jet_radius', 'jet_approximation', 'momentum_region', 'factorization_definition')}
        scope.update(frame='Breit', hard_orders={'LO': 1, 'NLO': 2}, observable='Collins_hadron_in_jet', documentation='scope.md')
        self.spec = {'schema': 1, 'profile': h.PROFILE, 'ready': True, 'scope': scope,
            'stages': {s: {'script': s + '.wls', 'roles': ['assembly']} for s in h.STAGES},
            'channels': {c: {'ut_active': c == 'Hqq', 'born': c == 'Hqq', 'reason': 'synthetic channel assignment'} for c in h.CHANNELS},
            'sources': {
                'amp': {'root': 'sidis', 'path': 'amplitudes.wl', 'role': 'amplitudes', 'sha256': h.u.digest(self.sidis / 'amplitudes.wl'), 'origin': 'test fixture'},
                'uu': {'root':'sidis','path':'uu.wl','role':'unpolarized_result','sha256':h.u.digest(self.sidis/'uu.wl'),'origin':'test fixture'},
                'uu_evidence': {'root':'sidis','path':'uu_evidence.json','role':'definitions','sha256':h.u.digest(self.sidis/'uu_evidence.json'),'origin':'test fixture'},
                'ref': {'root': 'engine', 'path': 'reference.json', 'role': 'reference', 'sha256': h.u.digest(self.engine / 'reference.json'), 'origin': 'test fixture'}},
            'master_imports': {}, 'checks': [], 'exports': {}}
        checks = [('uu_recovery','r00'), ('born_reference','r00'), ('ward','r00'), ('ward','r01'),
                  ('spin_basis','r00'), ('normalization','r00'), ('uv_poles','r06'), ('ir_poles','r07'),
                  ('scale_consistency','r07'), ('finite','r07'), ('factorization','r07'), ('jet_matching','r07')]
        self.packets = {s: {'schema': 5, 'stage': s, 'values': {}} for s in h.STAGES}
        for kind, stage in checks:
            ident = stage + '_' + kind
            row = {'id': ident, 'kind': kind, 'stage': stage, 'channel': 'Hqq', 'lhs': stage + '/' + kind, 'reason': 'fixture identity'}
            val = 0
            if kind in ('uu_recovery', 'born_reference'):
                row['reference'] = {'source': 'ref', 'equation': 'UU' if kind == 'uu_recovery' else 'UT'}
                val = 2 if kind == 'uu_recovery' else 1
            elif kind != 'finite': row['rhs'] = 0
            self.spec['checks'].append(row)
            self.packets[stage]['values'][row['lhs']] = value(val, result=val)
        for channel in sorted(h.CHANNELS - {'Hqq'}):
            ident = 'zero_' + channel
            self.spec['channels'][channel]['zero_check'] = ident
            self.spec['channels'][channel].update(uu_source='uu',uu_validation='uu_evidence')
            self.spec['checks'].append({'id': ident, 'kind': 'channel_zero', 'stage': 'r07', 'channel': channel,
                'lhs': 'r07/' + ident, 'rhs': 0, 'reason': 'synthetic zero'})
            self.packets['r07']['values']['r07/' + ident] = value()
            for kind in ('uu_recovery','finite','jet_matching'):
                cid = 'UU_' + channel + '_' + kind
                row = {'id':cid,'kind':kind,'stage':'r07','channel':channel,'lhs':'r07/'+cid,'reason':'retained UU fixture'}
                if kind == 'uu_recovery': row['reference'] = {'source':'ref','equation':'UU'}
                if kind == 'jet_matching': row['rhs'] = 2
                self.spec['checks'].append(row)
                self.packets['r07']['values']['r07/'+cid] = value(2,result=2)
        self.masters = {'master/r02/real/M': h.a.decode(2), 'master/r05/virtual/M': h.a.decode(3)}
        self.orders = {k: 2 for k in self.masters}
        self.packets['r07']['exports'] = {}
        for sector in ('UU', 'UT'):
            for order in (1, 2):
                name = sector + str(order)
                self.spec['exports'][name] = {'channel': 'Hqq', 'sector': sector, 'order': order}
                self.packets['r07']['exports'][name] = {'value': 'r07/' + name, 'evidence': 'r07/final'}
                self.packets['r07']['values']['r07/' + name] = value(1, result=1) if order == 1 else value(0, [(k, 1) for k in self.masters], 5)
        for channel in sorted(h.CHANNELS - {'Hqq'}):
            name = 'UU_' + channel
            self.spec['exports'][name] = {'channel':channel,'sector':'UU','order':2}
            self.packets['r07']['exports'][name] = {'value':'r07/'+name,'evidence':'r07/final'}
            self.packets['r07']['values']['r07/'+name] = value(2,result=2)

    def bound(self):
        return h.bind_sources(self.spec, self.engine, self.sidis)

    def audit(self, enforce=True):
        return h.audit_packets(self.spec, self.packets, self.masters, self.orders, self.bound(), enforce=enforce)


class SpecificationTests(Fixture):
    def test_complete_fixture(self):
        h.validate_spec(self.spec, self.engine)
        self.assertEqual(len(self.audit()['exports']), 9)

    def test_template_is_blocked(self):
        self.spec['ready'] = False
        with self.assertRaises(h.u.Blocked): h.validate_spec(self.spec, self.engine)

    def test_born_prefix_does_not_require_future_implementation(self):
        for sid in h.STAGES[1:]: (self.engine/(sid+'.wls')).unlink()
        self.spec['checks'] = [c for c in self.spec['checks'] if c['stage'] == 'r00']
        self.spec['exports'] = {}
        for name, ch in self.spec['channels'].items():
            if name != 'Hqq': ch['ut_active'] = None
        h.validate_spec(self.spec, self.engine, through='r00')
        with self.assertRaises((ValueError,h.u.Blocked)): h.validate_spec(self.spec,self.engine)

    def test_wrong_perturbative_order(self):
        self.spec['scope']['hard_orders'] = {'LO': 0, 'NLO': 1}
        with self.assertRaisesRegex(ValueError, 'orders'): h.validate_spec(self.spec, self.engine)

    def test_missing_measurement(self):
        self.spec['scope']['jet_algorithm'] = 'TODO'
        with self.assertRaisesRegex(ValueError, 'observable'): h.validate_spec(self.spec, self.engine)

    def test_channel_cannot_be_silently_dropped(self):
        del self.spec['channels']['Hgg']
        with self.assertRaisesRegex(ValueError, 'six'): h.validate_spec(self.spec, self.engine)

    def test_missing_exclusion_proof(self):
        self.spec['channels']['Hgg']['zero_check'] = 'missing'
        with self.assertRaisesRegex(ValueError, 'zero check'): h.validate_spec(self.spec, self.engine)

    def test_missing_pole_check(self):
        self.spec['checks'] = [x for x in self.spec['checks'] if x['kind'] != 'ir_poles']
        with self.assertRaisesRegex(ValueError, 'missing channel'): h.validate_spec(self.spec, self.engine)

    def test_nonzero_pole_target_rejected(self):
        next(x for x in self.spec['checks'] if x['kind'] == 'ir_poles')['rhs'] = 1
        with self.assertRaisesRegex(ValueError, 'requires zero'): h.validate_spec(self.spec, self.engine)

    def test_missing_ut_output(self):
        del self.spec['exports']['UT2']
        with self.assertRaisesRegex(ValueError, 'perturbative exports'): h.validate_spec(self.spec, self.engine)

    def test_zero_ut_cannot_remove_uu_denominator(self):
        del self.spec['exports']['UU_Hgg']
        with self.assertRaisesRegex(ValueError, 'perturbative exports'): h.validate_spec(self.spec, self.engine)

    def test_zero_ut_still_requires_uu_jet_matching(self):
        self.spec['checks'] = [c for c in self.spec['checks'] if not (c['channel']=='Hgg' and c['kind']=='jet_matching')]
        with self.assertRaisesRegex(ValueError,'unpolarized/jet checks'): h.validate_spec(self.spec,self.engine)

    def test_new_amplitude_bytes_rejected(self):
        (self.sidis / 'amplitudes.wl').write_text('changed')
        with self.assertRaisesRegex(ValueError, 'identity mismatch'): self.bound()

    def test_internal_upstream_symlink_supported(self):
        (self.sidis / 'alias.wl').symlink_to('amplitudes.wl')
        self.spec['sources']['amp']['path'] = 'alias.wl'
        self.assertEqual(self.bound()['amp']['resolved'], str(self.sidis / 'amplitudes.wl'))

    def test_external_upstream_symlink_rejected(self):
        (self.sidis / 'alias.wl').symlink_to(self.engine / 'scope.md')
        self.spec['sources']['amp']['path'] = 'alias.wl'
        with self.assertRaises(ValueError): self.bound()

    def test_import_requires_depth_evidence(self):
        self.spec['sources']['amp']['role'] = 'masters'
        self.spec['sources']['amp2'] = dict(self.spec['sources']['amp'], role='amplitudes')
        self.spec['master_imports'] = {'r02': {'saved': {'source': 'amp', 'selections': {'M': []}, 'orders': {'M': 1}, 'definition': 'same measure'}}}
        with self.assertRaisesRegex(ValueError, 'documentation'): h.validate_spec(self.spec, self.engine)


class ArithmeticTests(Fixture):
    def test_pass_string_cannot_override_bad_expression(self):
        self.packets['r00']['status'] = 'PASS'
        self.packets['r00']['values']['r00/born_reference'] = value(9, result=9)
        with self.assertRaisesRegex(ValueError, 'scientific checks failed'): self.audit()

    def test_reported_value_must_match_calculation(self):
        self.packets['r07']['values']['r07/UT2']['value'] = 6
        with self.assertRaisesRegex(ValueError, 'certificate mismatch'): self.audit()

    def test_nonzero_ir_residual_fails(self):
        self.packets['r07']['values']['r07/ir_poles'] = value('1/13', result='1/13')
        with self.assertRaisesRegex(ValueError, 'scientific checks failed'): self.audit()

    def test_finite_output_rejects_leftover_regulator(self):
        self.packets['r07']['values']['r07/UT1'] = value(['pow','eps',-1], result=['pow','eps',-1])
        with self.assertRaisesRegex(ValueError, 'regulator remains'): self.audit()

    def test_insufficient_master_depth(self):
        self.orders['master/r02/real/M'] = 0
        self.packets['r07']['values']['r07/UT2'] = value(0, [('master/r02/real/M',['pow','eps',-1]),('master/r05/virtual/M',1)], ['add',3,['mul',2,['pow','eps',-1]]])
        with self.assertRaisesRegex(ValueError, 'epsilon depth'): self.audit()

    def test_frozen_number_cannot_replace_nlo_ancestry(self):
        self.packets['r07']['values']['r07/UT2'] = value(5, result=5)
        with self.assertRaisesRegex(ValueError, 'real-master dependency'): self.audit()

    def test_distribution_components_can_have_separate_ancestry(self):
        self.packets['r07']['values']['r07/UT2'] = value(0, [('master/r02/real/M',1)], 2)
        self.spec['exports']['UT2delta'] = {'channel':'Hqq','sector':'UT','order':2}
        self.packets['r07']['exports']['UT2delta'] = {'value':'r07/UT2delta','evidence':'r07/final'}
        self.packets['r07']['values']['r07/UT2delta'] = value(0, [('master/r05/virtual/M',1)], 3)
        self.assertEqual(len(self.audit()['exports']), 10)

    def test_extra_export_rejected(self):
        self.packets['r07']['exports']['extra'] = dict(self.packets['r07']['exports']['UT1'])
        with self.assertRaisesRegex(ValueError, 'inventory'): self.audit()

    def test_wrong_stage_value(self):
        self.packets['r00']['values']['r07/injected'] = value()
        with self.assertRaisesRegex(ValueError, 'wrong value stage'): self.audit()

    def test_reference_change_rejected_by_hash(self):
        write(self.engine / 'reference.json', {'equations':{}})
        with self.assertRaisesRegex(ValueError, 'identity mismatch'): self.audit()

    def test_reference_conversion_must_be_explicit(self):
        check = next(c for c in self.spec['checks'] if c['kind'] == 'born_reference')
        check['reference_substitutions'] = {'s': 0}
        with self.assertRaisesRegex(ValueError, 'explanation'): self.audit()

    def test_r00_pilot_cannot_claim_nlo_exports(self):
        result = h.audit_packets(self.spec, self.packets, {}, {}, self.bound(), through='r00')
        self.assertFalse(result['exports'])
        self.assertEqual(len(result['checks']), 5)

    def test_native_dependency_response(self):
        before = copy.deepcopy(self.audit())
        self.masters['master/r02/real/M'] *= 2
        for name in ('UU2','UT2'):
            self.packets['r07']['values']['r07/' + name]['value'] = 7
        after = self.audit(enforce=False)
        changed = h.v.check_probe('real_master', before, after, 'master/r02/real/M', h.a.decode(2))
        self.assertEqual(set(changed), {'UU2','UT2'})

    def test_native_probe_rejects_cached_final(self):
        before = self.audit(); after = copy.deepcopy(before)
        after['masters']['master/r02/real/M'] *= 2
        with self.assertRaises(ValueError): h.v.check_probe('real_master', before, after, 'master/r02/real/M', h.a.decode(2))


class RunnerTests(Fixture):
    def fake_execute(self, command, cwd, log, timeout, env):
        # A software fixture, not a Wolfram/native acceptance test.
        log.parent.mkdir(parents=True, exist_ok=True)
        log.write_text('software execution fixture\n')
        context = h.u.read(env['SIDIS_HIGHPT_CONTEXT'])
        out = Path(context['output'])
        packet = copy.deepcopy(self.packets[context['stage']])
        packet['evidence'] = {context['stage'] + '/proof': {'path':'proof.txt', 'role':'assembly', 'parents':['source/' + context['stage'],'input/amp','input/uu']}}
        (out / 'proof.txt').write_text('synthetic arithmetic fixture')
        write(out / 'packet.wl', packet)
        return {'command':[str(x) for x in command], 'exit_code':0, 'log_sha256':h.u.digest(log), 'elapsed_seconds':0}

    def fake_export(self, src, dest, mode, rt, work):
        work.mkdir(parents=True, exist_ok=False)
        log = work / 'execution.log'; log.write_text('software transport fixture\n')
        write(dest, h.u.read(src))
        return {'command':['mock_transport'], 'exit_code':0, 'log_sha256':h.u.digest(log), 'elapsed_seconds':0}

    def do_run(self, execute=None):
        project = self.engine / 'project.json'; write(project, self.spec)
        rt = {'config':{'wolfram_kernel':'fixture','timeout_seconds':1}, 'identities':{'fixture':True}}
        with patch.object(h.u,'runtime',return_value=rt), patch.object(h.u,'execute',side_effect=execute or self.fake_execute), patch.object(h.w,'export_native',side_effect=self.fake_export):
            return h.run_project(project, self.sidis, self.root, self.root/'runs', 'r00')

    def test_partial_execution_is_development_only(self):
        run = self.do_run()
        self.assertEqual(h.u.read(run/'result.json')['status'], 'DEVELOPMENT_PASS')
        self.assertEqual(h.u.read(run/'result.json')['independent_physics_review'], 'PENDING')

    def test_nonzero_native_exit_cannot_pass(self):
        def fail(*args):
            result = self.fake_execute(*args); result['exit_code'] = 4; return result
        with self.assertRaisesRegex(ValueError, 'native stage failed'): self.do_run(fail)
        records = list((self.root/'runs').glob('*/run.json'))
        self.assertEqual(h.u.read(records[0])['status'], 'FAILED')
        self.assertFalse(list((self.root/'runs').glob('*/result.json')))

    def test_stage_cannot_modify_saved_amplitudes(self):
        def mutate(*args):
            result = self.fake_execute(*args)
            (self.sidis/'amplitudes.wl').write_text('unexpected mutation')
            return result
        with self.assertRaisesRegex(ValueError, 'source identity mismatch'): self.do_run(mutate)

    def test_stage_cannot_modify_implementation(self):
        def mutate(*args):
            result = self.fake_execute(*args)
            (self.engine/'r07.wls').write_text('changed source')
            return result
        with self.assertRaisesRegex(ValueError, 'implementation changed'): self.do_run(mutate)


class FullAdapterTests(RunnerTests):
    """End-to-end software wiring with explicitly mocked native tools."""
    def setUp(self):
        super().setUp()
        write(self.sidis/'bank.wl', {'real':2,'virtual':3})
        self.spec['sources']['bank'] = {'root':'sidis','path':'bank.wl','role':'masters','sha256':h.u.digest(self.sidis/'bank.wl'),'origin':'synthetic native-bank fixture'}
        self.spec['master_imports'] = {s:{name:{'source':'bank','selections':{'M':[name]},'orders':{'M':2},'definition':'fixture measure','precision_evidence':'synthetic exact constants'}} for s,name in [('r02','real'),('r05','virtual')]}
        for sid in ('r01','r04'):
            real = sid == 'r01'
            self.packets[sid]['families'] = [{'id':'F','denominators':['x'],'cuts':[0] if real else [],'positive_energy':real,'support_artifact':'proof.txt',
                'targets':[{'powers':[1],'integrand':['pow','x',-1],'numerator':1}]}]
            self.packets[sid]['jobs'] = [{'id':'reduce','inputs':['input.txt'],'outputs':['rules.m'],'families':['F'],'sectors':['Hqq'],'master_inventory':'rules.m'}]

    def fake_execute(self, command, cwd, log, timeout, env):
        log.parent.mkdir(parents=True, exist_ok=True); log.write_text('explicitly mocked native execution\n')
        if 'SIDIS_EXTRACT_CONTEXT' in env:
            c = h.u.read(env['SIDIS_EXTRACT_CONTEXT']); bank = h.u.read(c['input']); result = {}
            for key, path in c['selections'].items():
                value = bank
                for name in path: value = value[name]
                result[key] = value
            write(Path(c['output']), result)
        elif 'COLLINS_RU_MUTATION' in env:
            c = h.u.read(env['COLLINS_RU_MUTATION']); p = Path(c['path']); bank = h.u.read(p)
            bank[c['key']] = str(h.a.decode(bank[c['key']])*h.a.s.Rational(c['numerator'],c['denominator']))
            write(p, bank)
        else:
            c = h.u.read(env['SIDIS_HIGHPT_CONTEXT']); out = Path(c['output']); sid = c['stage']; packet = copy.deepcopy(self.packets[sid])
            parents = ['source/'+sid,'input/amp','input/bank','input/uu']
            for prior, directory in c['inputs'].items():
                parents.append(prior+'/proof')
                rec = h.u.read(Path(directory).parents[1]/'receipts'/(prior+'.json'))
                for jr in rec['jobs']:
                    parents.extend('tool/'+prior+'/'+jr['job']['id']+'/'+n for n in {**jr['outputs'],**jr['audited_outputs']})
            packet['evidence'] = {sid+'/proof':{'path':'proof.txt','role':'assembly','parents':parents}}
            if sid == 'r07':
                real = h.u.read(Path(c['inputs']['r02'])/'jobs/real/masters.json')['M']
                virtual = h.u.read(Path(c['inputs']['r05'])/'jobs/virtual/masters.json')['M']
                total = h.a.encode(h.a.decode(real)+h.a.decode(virtual))
                for name in ('UU2','UT2'): packet['values']['r07/'+name]['value'] = total
                for e in packet['exports'].values(): e['evidence'] = 'r07/proof'
            (out/'proof.txt').write_text('synthetic evidence fixture')
            write(out/'packet.wl',packet)
        return {'command':[str(x) for x in command],'exit_code':0,'log_sha256':h.u.digest(log),'elapsed_seconds':0}

    def fake_job(self, stage, job, out, rt, packet):
        work = out/'jobs'/job['id']; work.mkdir(parents=True)
        for name in ['input.txt','rules.m','tool.log','kira_audit.log','reduction_certificate.wl']:
            (work/name).write_text('mock Kira fixture')
        write(work/'reduction_audit.json',{'status':'PASS'})
        ex = {'exit_code':0,'log_sha256':h.u.digest(work/'tool.log'),'command':['mock_kira'],'elapsed_seconds':0}
        audit = dict(ex,log_sha256=h.u.digest(work/'kira_audit.log'))
        return {'kind':'kira','job':job,'execution':ex,'kira_audit':audit,'reexport':None,
                'inputs':{'input.txt':h.u.digest(work/'input.txt')},'outputs':{'rules.m':h.u.digest(work/'rules.m')},
                'audited_outputs':{n:h.u.digest(work/n) for n in ['reduction_certificate.wl','reduction_audit.json']}}

    def test_full_adapter_pair_and_both_dependency_probes(self):
        project = self.engine/'project.json'; write(project,self.spec)
        rt = {'config':{'wolfram_kernel':'fixture','timeout_seconds':1},'identities':{'fixture':True}}
        with patch.object(h.u,'runtime',return_value=rt), patch.object(h.u,'execute',side_effect=self.fake_execute), patch.object(h.w,'export_native',side_effect=self.fake_export), patch.object(h.w,'job_execute',side_effect=self.fake_job):
            first = h.run_project(project,self.sidis,self.root,self.root/'runs','r07')
            second = h.run_project(project,self.sidis,self.root,self.root/'runs','r07')
            self.assertEqual(h.compare_runs(first,second)['status'],'PAIR_CHECKS_PASS')
            self.assertEqual(h.dependency_probe(first,self.root/'probes',1729)['status'],'DEPENDENCY_CHECKS_PASS')
            self.assertEqual(h.dependency_probe(first,self.root/'probes2',92741)['status'],'DEPENDENCY_CHECKS_PASS')
            self.assertEqual(h.u.read(first/'result.json')['independent_physics_review'],'PENDING')


class PackageTests(unittest.TestCase):
    def test_existing_validator_manifest_is_unchanged(self):
        self.assertEqual(h.u.release_integrity(), h.BASE_RELEASE)

    def test_extension_identity(self):
        self.assertEqual(h.extension_identity()['base'], h.BASE_RELEASE)

    def test_incomplete_run_cannot_be_audited(self):
        with tempfile.TemporaryDirectory() as tmp:
            write(Path(tmp)/'run.json', {'schema':1,'profile':h.PROFILE,'run_path':str(Path(tmp).resolve()),'status':'RUNNING'})
            with self.assertRaisesRegex(ValueError, 'did not complete'): h.audit_run(tmp)

    def test_old_campaign_not_promoted_to_sidis(self):
        with tempfile.TemporaryDirectory() as tmp:
            write(Path(tmp)/'run.json', {'schema':5,'profile':'reverse_unitarity_current','status':'STAGES_PASS'})
            with self.assertRaisesRegex(ValueError, 'profile/schema'): h.audit_run(tmp)

    def test_aliasing_same_fresh_run_is_rejected(self):
        meta = {'through':'r07','run_id':'same','run_path':'same'}
        with patch.object(h,'audit_run',return_value=(meta,{})):
            with self.assertRaisesRegex(ValueError, 'distinct'): h.compare_runs('a','a')

    @unittest.skipUnless(os.environ.get('SIDIS_HANDOFF_BUNDLE'), 'optional supplied handoff ZIP')
    def test_supplied_native_handoff_integrity(self):
        result = h.inspect_handoff(os.environ['SIDIS_HANDOFF_BUNDLE'])
        self.assertEqual(result['status'], 'HANDOFF_INTEGRITY_PASS')
        self.assertFalse(result['native_replay'])


if __name__ == '__main__':
    unittest.main(verbosity=2)
