"""Final acceptance integration with synthetic packets and MOCKED native tools.

The real finite-kernel, scheme, inventory, graph, upstream-replay and report
coverage code runs here. Native Wolfram/MadGraph and the already separately
covered retained verifier are mocked. No fixture certifies production physics.
"""
import argparse, contextlib, copy, io, tempfile, unittest
from fractions import Fraction
from pathlib import Path
from unittest.mock import patch
import derivation_checks as dc
import verify_derivation as vd
import compare_derivation_reports as pair
import madgraph_checks as mg
from support import read,write,sha,snapshot
from native_evidence import snapshot_derivation_evidence
from test_derivation_checks import scheme_packet,assembly_packet


def populate(run):
    for stage in vd.workflow.stage_list():
        if stage['id'] not in vd.NEW_IDS:continue
        for name in stage['artifacts']:
            p=run/'common'/(stage['id']+'_result')/name;p.parent.mkdir(parents=True,exist_ok=True)
            if name.endswith('.json'):write(p,{'scope':'SYNTHETIC native artifact'})
            else:p.write_text('(* SYNTHETIC native artifact, no calculation *)\n')
    write(run/'common/d13_result/operator_inputs.json',dc.operator_inputs())
    write(run/'common/d13_result/finite_matching.json',dc.reference_matching())
    write(run/'common/d14_result/scheme_conversion.json',scheme_packet(True))
    write(run/'common/d15_result/symbolic_observable.json',assembly_packet())
    names=('operator_inputs','projection','regulated_integral','subtraction','finite_output')
    files=('operator_inputs.json','projections.wl','regulated_integrals.wl','subtractions.wl','finite_matching.json')
    chain=[]
    for i,(kind,name) in enumerate(zip(names,files)):
        rel='common/d13_result/'+name
        chain.append({'kind':kind,'path':rel,'sha256':sha(run/rel),'depends_on':[] if i==0 else [names[i-1]],'native_symbol':'SYNTHETIC'})
    write(run/'common/d13_result/derivation_graph.json',{'schema':1,'chains':{k:copy.deepcopy(chain) for k in dc.KERNELS}})
    evidence={}
    for sid,names in dc.REQUIRED_ARTIFACTS.items():
        for name in names:
            if name=='derivation_manifest.json':continue
            rel='common/'+sid+'_result/'+name;evidence[rel]=sha(run/rel)
    inv=read(dc.ROOT/'equation_inventory.json')['equations']
    write(run/'common/d15_result/derivation_manifest.json',{'schema':1,'equations':[
        {'id':item['id'],'origin':item['required_origin'],'agreement':'EXACT','evidence':copy.deepcopy(evidence),
         'reference':item['reference']+'; SYNTHETIC TEST','note':'Not a derivation or production acceptance'} for item in inv]})


class DerivationAcceptanceTests(unittest.TestCase):
    def setUp(self):
        self.temp=tempfile.TemporaryDirectory();self.addCleanup(self.temp.cleanup);self.root=Path(self.temp.name)
        self.repo=self.root/'repo';self.production=self.repo/'collins_ep_analytic';self.production.mkdir(parents=True)
        (self.repo/'collins_ep').mkdir();(self.repo/'collins_ep/__init__.py').write_text('raise RuntimeError("fitted provider import forbidden")\n')
        library=self.production/'common/d13_matching_library.wl';library.parent.mkdir();library.write_text('(* SYNTHETIC native library *)\n')
        self.state=self.root/'state';write(self.state/'old.json',{'historical':'protected'})
        self.rt={'wolfram_kernel':'/MOCKED/WolframKernel','stage_timeout_seconds':30}
        self.runs=[self.root/'run-a',self.root/'run-b'];self.manifests={}
        for i,run in enumerate(self.runs):
            populate(run)
            m={'run_id':f'MOCKED-fresh-{i}','status':'STAGES_PASS','resumed':False,'source_sha256':snapshot(self.production),
               'runtime':{'config':self.rt},'validator_manifest_sha256':'MOCKED release',
               'baseline_before':{'SYNTHETIC':'baseline'},'baseline_after':{'SYNTHETIC':'baseline'}}
            write(run/'run.json',m);self.manifests[str(run)]=m
        self.mode=None;self.forwarded=[];self.native_calls=[]
        for obj,name,value in [
            (vd,'release_integrity',lambda *_:'MOCKED release'),(pair,'release_integrity',lambda *_:'MOCKED release'),
            (vd,'baseline_check',lambda *_:{'SYNTHETIC':'baseline'}),(vd.workflow,'audit_run',self.audit),
            (vd.verify_assembly,'compare_new_runs',lambda *_:{'scope':'MOCKED already tested retained replay'}),
            (vd,'check_conventions',lambda *_:[dc.row('conventions.SYNTHETIC',True)]),
            (pair,'check_conventions',lambda *_:[dc.row('conventions.SYNTHETIC',True)]),
            (vd,'runtime_for_checks',lambda *_:self.rt),(vd,'execute',self.proof),
            (dc,'native_call',self.native),(mg,'run_checks',self.madgraph),(mg,'replay_checks',self.madgraph_replay),
            (vd.verify_assembly,'verify',self.retained),(pair.old,'compare',self.retained_pair)]:
            self.mock(obj,name,value)
        self.real_mg_run=mg_run_original
        sentinel=patch.object(vd.verify_assembly.foundation,'legacy_check',side_effect=AssertionError('fitted regression must not execute'))
        self.fitted_sentinel=sentinel.start();self.addCleanup(sentinel.stop)
    def mock(self,obj,name,value):
        p=patch.object(obj,name,value);p.start();self.addCleanup(p.stop)
    def audit(self,path,production):
        self.assertEqual(Path(production),self.production)
        m=self.manifests[str(Path(path).resolve())]
        if snapshot(self.production)!=m['source_sha256']:raise ValueError('Changed synthetic source')
        return m,{s['id']:{'no_cache_requested':True} for s in vd.workflow.stage_list()}
    def proof(self,cmd,cwd,log,timeout,env):
        if self.mode=='missing_wolfram':raise FileNotFoundError('MOCKED unavailable Wolfram kernel')
        c=read(env['COLLINS_ANALYTIC_CONTEXT']);self.native_calls.append(c['stage'])
        ids=c['proof_ids']+c['proof_ids'][:1] if self.mode=='duplicate_proof' else c['proof_ids']
        write(c['proof_report'],{'run_id':c['run_id'],'stage':c['stage'],'status':'PASS','proof_ids':ids})
        Path(log).write_text('MOCKED fresh native proof process\n')
        return {'exit_code':0,'argv':cmd,'log_sha256':sha(log)}
    def native(self,runtime,script,context,work):
        work=Path(work);kind=work.name.removeprefix('upstream-');self.native_calls.append(kind)
        delta=Fraction(read(work/'SCOPE.json')['delta']);write(context['output'],dc.mutation(kind,delta)[1])
        for name in ('projections.wl','regulated_integrals.wl','subtractions.wl'):(work/name).write_text('SYNTHETIC regenerated native evidence\n')
        (work/'probe.wls').write_text(script);write(work/'context.json',context);(work/'native.log').write_text('MOCKED native process\n')
        write(work/'execution.json',{'exit_code':0,'context_sha256':sha(work/'context.json'),'script_sha256':sha(work/'probe.wls'),'log_sha256':sha(work/'native.log')})
    def madgraph(self,repo,run,runtime,work,seed):
        if self.mode=='missing_mg':return self.real_mg_run(repo,run,{},work,seed)
        if self.mode=='empty_mg':return []
        self.native_calls.append('madgraph')
        write(Path(work)/'SYNTHETIC-native.json',{'scope':'MOCKED native boundary; actual adapter covered separately','seed':seed,'answer':seed+1})
        return self.madgraph_replay(work,seed)
    def madgraph_replay(self,work,seed):
        p=Path(work)/'SYNTHETIC-native.json';data=read(p)
        return [mg.record('SYNTHETIC.native','PASS' if data['seed']==seed and data['answer']==seed+1 else 'FAIL',{'evidence_sha256':sha(p)})]
    def retained(self,args):
        self.forwarded.append(args.profile)
        checks=[] if self.mode=='empty_retained' else [dc.row('SYNTHETIC.retained_complete',True)]
        m=self.manifests[str(self.runs[0])]
        write(args.report,{'status':'CHECKS_PASS','profile':args.profile,'seed':args.seed,'sources':m['source_sha256'],
            'runtime':m['runtime'],'run':str(self.runs[0]),'checks':checks})
        return 0
    def retained_pair(self,repo,paths):
        self.assertEqual(len(paths),2)
        reports=[read(p) for p in paths]
        if {r.get('seed') for r in reports}!={1729,92741} or any(r.get('profile')!='analytic_assembly' or not r.get('checks') for r in reports):
            raise ValueError('Synthetic retained pair rejected')
        return {'status':'CHECKS_PASS'}
    def report(self,seed=1729,tag=''):
        p=self.root/(f'derivation-{seed}'+tag+'.json')
        args=argparse.Namespace(repo=str(self.repo),run=str(self.runs[0]),replay=str(self.runs[1]),seed=seed,report=str(p),
            numerical_state=str(self.state),numerical_validator='/NOT_USED',numerical_timeout=10,timeout=10)
        with contextlib.redirect_stdout(io.StringIO()):rc=vd.verify(args)
        return rc,p,read(p)
    def reports(self):
        paths=[]
        for seed in (1729,92741):
            rc,p,r=self.report(seed);self.assertEqual(rc,0,r);paths.append(p)
        return paths
    def reseal(self,p,edit=None):
        r=read(p)
        if edit:edit(r)
        r['evidence_files']=snapshot_derivation_evidence(p.with_name(p.stem+'-evidence'));write(p,r)
    def rejects(self,paths):
        with self.assertRaises((ValueError,FileNotFoundError)):pair.compare(self.repo,paths)
    def test_full_dispatch_and_pair(self):
        paths=self.reports();result=pair.compare(self.repo,paths)
        self.assertEqual(result['status'],'CHECKS_PASS');self.assertEqual(self.forwarded,['analytic_assembly']*2)
        self.assertEqual(set(self.native_calls),{'d13','d14','d15','qq_epsilon','qg_epsilon','madgraph'})
        ids={c['id'] for c in read(paths[0])['checks']}
        self.assertIn('upstream.qq_epsilon.library_unchanged',ids)
        self.assertIn('upstream.qg_epsilon.regenerated.projections.wl',ids)
        self.assertNotIn('numerical.regression',ids);self.fitted_sentinel.assert_not_called()
    def test_missing_madgraph_blocks(self):
        self.mode='missing_mg';rc,_,r=self.report();self.assertEqual(rc,2,r)
        self.assertIn('madgraph.native.runtime',{c['id'] for c in r['checks'] if c['status']=='BLOCKED'})
    def test_missing_wolfram_blocks(self):
        self.mode='missing_wolfram';rc,_,r=self.report();self.assertEqual(rc,2,r)
        self.assertIn('unavailable Wolfram',r['detail']);self.fitted_sentinel.assert_not_called()
    def test_empty_derivation_checker_cannot_pass(self):
        with patch.object(dc,'run_checks',return_value=[]):rc,_,r=self.report()
        self.assertEqual(rc,1,r)
    def test_empty_madgraph_cannot_pass(self):
        self.mode='empty_mg';rc,_,r=self.report();self.assertEqual(rc,1,r)
    def test_empty_retained_cannot_pass(self):
        self.mode='empty_retained';rc,_,r=self.report();self.assertEqual(rc,1,r)
    def test_repeated_fresh_proof_ids_fail(self):
        self.mode='duplicate_proof';rc,_,r=self.report();self.assertEqual(rc,1,r)
    def test_missing_final_check_rejected(self):
        paths=self.reports();self.reseal(paths[0],lambda r:r['checks'].pop());self.rejects(paths)
    def test_duplicate_final_check_rejected(self):
        paths=self.reports();self.reseal(paths[0],lambda r:r['checks'].append(r['checks'][0]));self.rejects(paths)
    def test_empty_final_report_rejected(self):
        paths=self.reports();self.reseal(paths[0],lambda r:r.update(checks=[]));self.rejects(paths)
    def test_partial_final_report_rejected(self):
        paths=self.reports();self.reseal(paths[0],lambda r:r.update(checks=r['checks'][:1]));self.rejects(paths)
    def test_same_seeds_rejected(self):
        paths=[]
        for tag in ('-a','-b'):
            rc,p,r=self.report(tag=tag);self.assertEqual(rc,0,r);paths.append(p)
        self.rejects(paths)
    def test_same_report_path_rejected(self):
        _,p,_=self.report();self.rejects([p,p])
    def test_changed_evidence_hash_rejected(self):
        paths=self.reports();p=paths[0].with_name(paths[0].stem+'-evidence')/'d13/proof.log';p.write_text('changed');self.rejects(paths)
    def test_changed_upstream_even_if_outer_resealed(self):
        paths=self.reports();p=paths[0].with_name(paths[0].stem+'-evidence')/'derivation/upstream-qq_epsilon/finite_matching.json'
        data=read(p);data['coefficients']['fqq']['one_loop']['delta']=dc.rat(123);write(p,data)
        self.reseal(paths[0]);self.rejects(paths)
    def test_changed_madgraph_even_if_outer_resealed(self):
        paths=self.reports();p=paths[0].with_name(paths[0].stem+'-evidence')/'madgraph/SYNTHETIC-native.json'
        data=read(p);data['answer']+=1;write(p,data);self.reseal(paths[0]);self.rejects(paths)
    def test_changed_reported_core_arithmetic_rejected(self):
        paths=self.reports()
        self.reseal(paths[0],lambda r:next(c for c in r['checks'] if c['id']=='matching.schema').update(detail='invented'))
        self.rejects(paths)
    def test_removed_native_evidence_rejected(self):
        paths=self.reports();p=paths[0].with_name(paths[0].stem+'-evidence')/'d14/proof-check.json';p.unlink()
        self.reseal(paths[0]);self.rejects(paths)
    def test_pair_output_cannot_modify_second_replay(self):
        paths=self.reports()
        for root in [self.repo,*self.runs,pair.ROOT]:
            with self.assertRaises(ValueError):pair.guard_output(self.repo,root/'new-pair.json',paths)
        self.assertEqual(pair.guard_output(self.repo,self.root/'pair.json',paths),self.root/'pair.json')
    def test_same_run_rejected(self):
        with self.assertRaises(ValueError):vd.compare_runs(self.runs[0],self.runs[0],self.production)
    def test_malformed_status_rows_fail(self):
        for rows in ([],[None],[{}],[{'id':'x','status':'SKIP'}]):self.assertEqual(vd.combine_status(rows),'FAIL')


    def native_links(self,work):
        tree=Path(work)/'born_eq/standalone'
        (tree/'Source/MODEL').mkdir(parents=True)
        (tree/'Source/MODEL/coupl.inc').write_text('MOCKED generated include')
        (tree/'Source/coupl.inc').symlink_to('MODEL/coupl.inc')
        (tree/'Source/optional.inc').symlink_to('not_generated.inc')

    def test_generated_links_survive_report_and_pair(self):
        original=self.madgraph
        def generated(*args):
            rows=original(*args);self.native_links(args[3]);return rows
        self.mock(mg,'run_checks',generated)
        paths=self.reports()
        self.assertEqual(pair.compare(self.repo,paths)['status'],'CHECKS_PASS')
        records=read(paths[0])['evidence_files']['files']
        self.assertEqual(sum(v['kind']=='symlink' for v in records.values()),2)

    def test_native_block_with_links_writes_blocked_report(self):
        def blocked(repo,run,runtime,work,seed):
            self.native_links(work)
            return [mg.record('compile','BLOCKED','MOCKED native build failed')]
        self.mock(mg,'run_checks',blocked)
        rc,path,result=self.report()
        self.assertEqual(rc,2);self.assertTrue(path.is_file())
        self.assertEqual(result['status'],'BLOCKED')
        self.assertIsNotNone(result['evidence_files'])

    def test_rejected_link_writes_failed_report_with_checks(self):
        original=self.madgraph
        def invalid(*args):
            rows=original(*args)
            (Path(args[3])/'outside-native').symlink_to('SYNTHETIC-native.json')
            return rows
        self.mock(mg,'run_checks',invalid)
        rc,path,result=self.report()
        self.assertEqual(rc,1);self.assertTrue(path.is_file())
        self.assertEqual(result['status'],'FAIL')
        self.assertIsNone(result['evidence_files'])
        self.assertTrue(result['checks'])
        self.assertIn('outside native evidence scope',result['evidence_capture_error'])

    def test_changed_native_link_blocks_comparator(self):
        original=self.madgraph
        def generated(*args):
            rows=original(*args);self.native_links(args[3]);return rows
        self.mock(mg,'run_checks',generated)
        paths=self.reports()
        link=paths[0].with_name(paths[0].stem+'-evidence')/'madgraph/born_eq/standalone/Source/coupl.inc'
        link.unlink();link.symlink_to('./MODEL/coupl.inc')
        self.rejects(paths)

    def test_pair_failure_is_written_after_safe_output_guard(self):
        paths=self.reports()
        result=read(paths[0]);result['status']='BLOCKED';write(paths[0],result)
        dest=self.root/'failed-pair.json'
        with patch('sys.argv',['compare_derivation_reports.py','--repo',str(self.repo),'--report',str(dest),*[str(p) for p in paths]]),contextlib.redirect_stdout(io.StringIO()):
            rc=pair.main()
        self.assertEqual(rc,1);self.assertEqual(read(dest)['status'],'FAIL')

mg_run_original=mg.run_checks

if __name__=='__main__':unittest.main()
