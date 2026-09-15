import copy,io,json,shutil,tempfile,unittest
from contextlib import redirect_stdout
from pathlib import Path
from types import SimpleNamespace
from unittest.mock import patch
import sympy as sy
import algebra as a
import ru_support as u
import verify_ru as v
import compare_ru_reports as comparator
import upgrade as upgrade_tool
from test_execution import probe_data

FIXTURES=Path(__file__).parent/'fixtures/v050'

class BlockedComparator(unittest.TestCase):
    def setUp(self):
        self.tmp=tempfile.TemporaryDirectory();self.root=Path(self.tmp.name)
        self.repo=self.root/'repo';self.repo.mkdir();self.paths=[]
        for seed in (1729,92741):
            p=self.root/('ru-'+str(seed)+'.json');shutil.copy2(FIXTURES/p.name,p);self.paths.append(p)
        self.dest=self.root/'pair.json';self.before={str(p):u.digest(p) for p in self.paths}
    def tearDown(self):self.tmp.cleanup()
    def invoke(self):
        args=SimpleNamespace(repo=str(self.repo),report=str(self.dest),reports=[str(p) for p in self.paths])
        with redirect_stdout(io.StringIO()):return comparator.compare(args)
    def alter(self,index,**kwargs):
        r=u.read(self.paths[index]);r.update(kwargs);u.write(self.paths[index],r,replace=True)
    def test_actual_early_blocked_reports_write_pair(self):
        self.assertEqual(self.invoke(),2);r=u.read(self.dest)
        self.assertEqual(r['status'],'BLOCKED');self.assertNotIn('retained',r)
        self.assertEqual(self.before,{str(p):u.digest(p) for p in self.paths})
    def test_early_block_never_runs_retained_or_native(self):
        with patch.object(comparator,'check_report',side_effect=AssertionError('must not replay')):
            self.assertEqual(self.invoke(),2)
    def test_fail_dominates_blocked(self):
        self.alter(0,status='FAIL');self.assertEqual(self.invoke(),1);self.assertEqual(u.read(self.dest)['status'],'FAIL')
    def test_missing_seed_is_not_a_legitimate_block(self):
        self.alter(0,seed=None);self.assertEqual(self.invoke(),1)
    def test_duplicate_seed_rejected(self):
        self.alter(0,seed=92741);self.assertEqual(self.invoke(),1)
    def test_bad_profile_rejected(self):
        self.alter(0,profile='other');self.assertEqual(self.invoke(),1)
    def test_changed_qualifications_rejected(self):
        self.alter(0,qualifications={});self.assertEqual(self.invoke(),1)
    def test_forged_pass_without_evidence_rejected(self):
        self.alter(0,status='CHECKS_PASS');self.alter(1,status='CHECKS_PASS')
        self.assertEqual(self.invoke(),1);self.assertEqual(u.read(self.dest)['status'],'FAIL')
    def test_malformed_optional_retained_does_not_crash(self):
        self.alter(0,retained=7);self.assertEqual(self.invoke(),2)
    def test_nonobject_input_fails_with_report(self):
        u.write(self.paths[0],[],replace=True);self.assertEqual(self.invoke(),1)
        self.assertEqual(u.read(self.dest)['status'],'FAIL')
    def test_refuses_report_overwrite(self):
        self.invoke()
        with self.assertRaises(ValueError):self.invoke()
    def test_still_protects_retained_paths(self):
        self.alter(0,retained={'identity':{'pair':str(self.root/'retained/pair.json')}})
        self.dest=self.root/'retained/overwrite.json'
        with self.assertRaises(ValueError):self.invoke()

class CompleteReductionResponse(unittest.TestCase):
    def test_mixed_direct_and_reduced_pilot(self):
        eps,cf=sy.symbols('eps CF');scale=sy.Rational(11,6)
        reducible=cf*((1-eps)/2-2*(1-2*eps)/eps);identity=-2*cf
        b=probe_data(factor=0);c=copy.deepcopy(b)
        key='r03/I';master='master/r02/A/M'
        b['recipes'][key]['terms'][0]['factor']=a.encode(reducible+identity)
        c['recipes'][key]['terms'][0]['factor']=a.encode(scale*reducible+scale*identity)
        b['values']=a.recompute(b['recipes'],b['masters']);c['values']=a.recompute(c['recipes'],c['masters'])
        self.assertEqual(v.check_probe('kira_real_rules',b,c,None,scale),['C'])
        # v0.5.0 scaled the raw rules but recreated the master identity unchanged.
        c['recipes'][key]['terms'][0]['factor']=a.encode(scale*reducible+identity)
        c['values']=a.recompute(c['recipes'],c['masters'])
        with self.assertRaises(ValueError):v.check_probe('kira_real_rules',b,c,None,scale)
    def test_direct_master_only_contract_responds(self):
        b=probe_data(factor=-2);c=probe_data(factor=-4)
        self.assertEqual(v.check_probe('kira_real_rules',b,c,None,sy.Integer(2)),['C'])
    def setUp(self):
        self.mutation={'numerator':11,'denominator':6,'jobs':[{'id':'quark'}]}
        self.good={'status':'PASS','scope':'complete_audited_reduction_map','factor':[11,6],
                   'jobs':[{'id':'quark','rules':3,'identity_rules':1,'residuals':['0']*3}]}
    def test_native_response_complete(self):v.validate_reduction_response(self.good,self.mutation)
    def test_native_response_nonzero_rejected(self):
        self.good['jobs'][0]['residuals'][1]='1'
        with self.assertRaises(ValueError):v.validate_reduction_response(self.good,self.mutation)
    def test_missing_native_job_rejected(self):
        self.good['jobs']=[]
        with self.assertRaises(ValueError):v.validate_reduction_response(self.good,self.mutation)
    def test_truncated_residuals_rejected(self):
        self.good['jobs'][0]['residuals']=['0']
        with self.assertRaises(ValueError):v.validate_reduction_response(self.good,self.mutation)
    def test_wrong_factor_rejected(self):
        self.good['factor']=[8,6]
        with self.assertRaises(ValueError):v.validate_reduction_response(self.good,self.mutation)
    def test_wrong_map_scope_rejected(self):
        self.good['scope']='raw_rules_only'
        with self.assertRaises(ValueError):v.validate_reduction_response(self.good,self.mutation)
    def test_no_rules_rejected(self):
        self.good['jobs'][0].update(rules=0,identity_rules=0,residuals=[])
        with self.assertRaises(ValueError):v.validate_reduction_response(self.good,self.mutation)
    def test_invalid_identity_count_rejected(self):
        self.good['jobs'][0]['identity_rules']=4
        with self.assertRaises(ValueError):v.validate_reduction_response(self.good,self.mutation)

class MutationBindings(unittest.TestCase):
    def test_uses_audited_rule_files_and_original_certificate(self):
        with tempfile.TemporaryDirectory() as t:
            root=Path(t);base=root/'base';probe=root/'probe';rel=Path('common/r01_result/jobs/quark')
            for tree in (base,probe):
                (tree/rel/'results/R1').mkdir(parents=True)
                (tree/rel/'results/R1/kira_targets.m').write_text('{R[1]->R[0]}')
                (tree/rel/'reduction_certificate.wl').write_text('audited map')
            receipt={'jobs':[{'job':{'id':'quark'},'outputs':{'results/R1/kira_targets.m':'x','helper.m':'not-a-rule','tmp/R1/masters':'z'}}]}
            jobs=v.kira_mutation_jobs(base,probe,receipt)
            self.assertEqual(jobs,[{'id':'quark','paths':[str(probe/rel/'results/R1/kira_targets.m')],
                                    'certificate':str(base/rel/'reduction_certificate.wl'),'probe_certificate':str(probe/rel/'reduction_certificate.wl')}])
    def test_empty_jobs_rejected(self):
        with self.assertRaises(ValueError):v.kira_mutation_jobs(Path('/x'),Path('/y'),{'jobs':[]})

class UpgradeFootprint(unittest.TestCase):
    def setUp(self):
        self.tmp=tempfile.TemporaryDirectory();self.root=Path(self.tmp.name)
        self.repo=self.root/'repo';self.prod=self.repo/u.ENGINE;self.prod.mkdir(parents=True)
        (self.prod/'common').mkdir();shutil.copy2(u.ROOT/'native_io.wl',self.prod/'common/ru_io.wl')
        (self.prod/'common/r07_assembly.wls').write_text('unfinished production remains byte-identical')
        self.previous=self.root/'old-state';self.previous.mkdir();(self.previous/'failure.log').write_text('old failure')
        self.pair=self.root/'accepted/pair.json';self.accepted={'pair':str(self.pair),'source_hash':'accepted'}
        self.oldvalidator=self.root/'old-validator';self.oldvalidator.mkdir()
        self.oldrel={'path':str(self.oldvalidator),'manifest_sha256':'oldrelease','files':167}
        u.write(self.previous/'adoption.json',{'schema':5,'status':'INSTALLED_INTERFACE','repo':str(self.repo),'implementation':str(self.prod),'release':'oldrelease','accepted':self.accepted})
        self.args=SimpleNamespace(repo=str(self.repo),state=str(self.root/'new-state'),previous_state=str(self.previous),previous_validator=str(self.oldvalidator),accepted_pair=None,dry_run=False)
    def tearDown(self):self.tmp.cleanup()
    def invoke(self):
        with redirect_stdout(io.StringIO()),patch.object(upgrade_tool,'release_integrity',return_value='newrelease'),patch.object(upgrade_tool,'check_previous_release',return_value=self.oldrel),patch.object(upgrade_tool,'accepted_pair',return_value=self.accepted),patch.object(upgrade_tool,'preserve_old',return_value='accepted'),patch.object(upgrade_tool,'check_reuse',return_value={'used':12}),patch.object(upgrade_tool,'runtime',return_value={'fixture':True}),patch.object(upgrade_tool,'upstream_source_state',return_value={'unchanged':True}):
            return upgrade_tool.upgrade(self.args)
    def test_upgrade_only_writes_new_state(self):
        before=u.snapshot(self.repo);old=u.snapshot(self.previous)
        self.assertEqual(self.invoke(),0);self.assertEqual(before,u.snapshot(self.repo));self.assertEqual(old,u.snapshot(self.previous))
        state=Path(self.args.state)
        self.assertEqual(set(u.snapshot(state)),{'adoption.json','initial-engine-snapshot.json','previous-state-snapshot.json'})
        self.assertEqual(u.read(state/'adoption.json')['status'],'UPGRADE_READY')
    def test_upgrade_dry_run_writes_nothing(self):
        self.args.dry_run=True;before=u.snapshot(self.root);self.invoke();self.assertEqual(before,u.snapshot(self.root))
    def test_upgrade_refuses_existing_state(self):
        self.invoke()
        with self.assertRaises(ValueError):self.invoke()
    def test_upgrade_cannot_overwrite_previous_state(self):
        self.args.state=str(self.previous/'new')
        with self.assertRaises(ValueError):self.invoke()
    def test_upgrade_cannot_write_inside_repo(self):
        self.args.state=str(self.repo/'state')
        with self.assertRaises(ValueError):self.invoke()
    def test_upgrade_wrong_adoption_release(self):
        p=self.previous/'adoption.json';r=u.read(p);r['release']='changed';u.write(p,r,replace=True)
        with self.assertRaises(ValueError):self.invoke()
    def test_upgrade_changed_accepted_pair(self):
        self.accepted['source_hash']='changed'
        with self.assertRaises(ValueError):self.invoke()
    def test_upgrade_never_replaces_helper(self):
        (self.prod/'common/ru_io.wl').write_text('different helper')
        with self.assertRaises(ValueError):self.invoke()

class PreviousReleaseIntegrity(unittest.TestCase):
    def test_checks_actual_old_bytes_and_extra_files(self):
        with tempfile.TemporaryDirectory() as t:
            root=Path(t);package=root/'new';previous=root/'old';(package/'history').mkdir(parents=True);previous.mkdir()
            (previous/'driver.py').write_text('original')
            m={'schema':1,'version':'0.5.0','files':{'driver.py':u.digest(previous/'driver.py')}}
            u.write(previous/'MANIFEST.json',m);shutil.copy2(previous/'MANIFEST.json',package/'history/v0.5.0-MANIFEST.json')
            u.write(package/'previous_v050.json',{'manifest_sha256':u.digest(previous/'MANIFEST.json')})
            with patch.object(upgrade_tool,'ROOT',package):
                self.assertEqual(upgrade_tool.check_previous_release(previous)['files'],1)
                (previous/'extra').write_text('not allowed')
                with self.assertRaises(ValueError):upgrade_tool.check_previous_release(previous)
                (previous/'extra').unlink();(previous/'driver.py').write_text('changed')
                with self.assertRaises(ValueError):upgrade_tool.check_previous_release(previous)

class ArchivedNativeDiagnostic(unittest.TestCase):
    def test_archived_corrected_volume_matches_gamma_expansion(self):
        # Rechecks saved mathematical evidence, not a new native execution.
        eps=sy.Symbol('eps');got=a.decode(u.read(FIXTURES/'volume-masters.json')['CutVolume'])
        got=got.subs(sy.Symbol('EulerGamma'),sy.EulerGamma)
        ref=sy.series(sy.pi**(1-eps)*sy.gamma(1-eps)/(2*sy.gamma(2-2*eps)),eps,0,3).removeO()
        self.assertTrue(a.equal(got,ref))

if __name__=='__main__':unittest.main()
