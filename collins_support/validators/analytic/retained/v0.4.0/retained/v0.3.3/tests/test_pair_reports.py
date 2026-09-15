"""Report-pair checks with real files/hashes/arithmetic and MOCKED execution.

No fixture here represents a completed production calculation.
"""
import copy,tempfile,unittest
from pathlib import Path
from unittest.mock import patch
import compare_assembly_reports as pair
import assembly_oracle as ao
import bridge_probes as bp
from assembly_reference import references
from support import read,write,sha,snapshot
from retained_fixture import populate_run,foundation_report
import verify as foundation

class PairReportTests(unittest.TestCase):
    profile="assembly"
    def setUp(self):
        self.t=tempfile.TemporaryDirectory();self.addCleanup(self.t.cleanup);self.root=Path(self.t.name)
        self.repo=self.root/'repo';self.repo.mkdir();self.runs=[self.root/'run-a',self.root/'run-b']
        self.manifest={'run_id':'MOCKED first','source_sha256':{'scope':'MOCKED source identity'},'runtime':{'config':{'wolfram_kernel':'/MOCKED/WolframKernel','stage_timeout_seconds':30}},'baseline_before':{'MOCKED':'baseline'},'baseline_after':{'MOCKED':'baseline'},'status':'STAGES_PASS','resumed':False}
        rad,op,ass,_=references()
        self.packets=[ao.packet('radiation',rad),ao.packet('operators',op),ao.packet('assembly',{'expressions':ass})]
        for run in self.runs:
            write(run/'run.json',self.manifest);populate_run(run)
            for sid,name,data in zip(('s10','s11','s12'),('radiation','operators','assembly'),self.packets):write(run/'common'/f'{sid}_result'/f'{name}.json',data)
        self.replay={'id':'assembly.clean_replay','status':'PASS','run_paths':list(map(str,self.runs)),
                     'run_manifest_sha256':[sha(r/'run.json') for r in self.runs]}
        for name,value in [('release_integrity',lambda p:'MOCKED release'),('audit_run',lambda *x:(self.manifest,{})),('compare_new_runs',lambda *x:self.replay)]:
            p=patch.object(pair,name,value);p.start();self.addCleanup(p.stop)
        for name,value in [('audit_run',lambda *x:(self.manifest,{sid:{} for sid in foundation.RETAINED_STAGE_IDS})),('compare_runs',lambda *x:{'id':'replay.semantic_outputs','status':'PASS','compared':sum(map(len,foundation.SEMANTIC.values()))})]:
            p=patch.object(foundation,name,value);p.start();self.addCleanup(p.stop)
        self.paths=[]
        for seed in (1729,92741):self.paths.append(self.make_report(seed))

    def make_report(self,seed):
        path=self.root/f'assembly-{seed}.json';work=path.with_name(path.stem+'-evidence');nonce=f'mocked-{seed}'
        req=ao.requests(seed);write(work/'context.json',{'run_id':nonce,'requests':req})
        response={'run_id':nonce,'status':'PASS','responses':[{'id':r['id'],'values':ao.expected(r)} for r in req]}
        write(work/'response.json',response)
        br=[r for r in req if r['kind']=='gaussian' or (r['kind']=='coefficient' and r['source'] in ('operators','assembly'))]
        bridge={'run_id':nonce,'status':'PASS','responses':[{'id':r['id'],'values':ao.expected(r)} for r in br]}
        write(work/'bridge-response.json',bridge)
        for kind in ('soft','hard','assembly'):
            root=work/('bridge-probe-'+kind);pr=bp.probe_requests(seed,kind)
            write(root/'requests.json',{'run_id':nonce+'-'+kind,'requests':pr})
            write(root/'response.json',{'run_id':nonce+'-'+kind,'status':'PASS','responses':[{'id':r['id'],'values':bp.target(r,kind)} for r in pr]})
        fp=work/'foundation.json'
        rc,f,_,_=foundation_report(self.repo,self.runs[0],self.runs[1],self.root/'state',fp,seed,
            'analytic_foundation' if self.profile=='analytic_assembly' else 'foundation',self.manifest)
        self.assertEqual(rc,0,f);old=f['checks']
        checks=ao.coefficients(*self.packets,seed)+ao.compare_response(req,response,nonce)+ao.compare_response(br,bridge,nonce,'bridge')+bp.replay(work,seed,nonce)
        checks+=[copy.deepcopy(self.replay)]+[{'id':x,'status':'PASS'} for x in ('assembly.backend_records','assembly.producer_map','assembly.proof.s10','assembly.proof.s11','assembly.proof.s12')]
        checks+=[{**c,'id':'retained.'+c['id']} for c in old]
        write(path,{'status':'CHECKS_PASS','profile':self.profile,'scope':pair.SCOPE,'validator_manifest_sha256':'MOCKED release',
                    'seed':seed,'run_id':self.manifest['run_id'],'baseline_before':self.manifest['baseline_before'],'baseline_after':self.manifest['baseline_after'],'checks':checks,'evidence_files':snapshot(work),'run':str(self.runs[0]),
                    'sources':self.manifest['source_sha256'],'runtime':self.manifest['runtime'],'run_manifest_sha256':sha(self.runs[0]/'run.json'),
                    'foundation_report':{'path':str(fp),'sha256':sha(fp),'checks':len(old)},
                    **({'numerical_regression':'NOT_REQUESTED_ANALYTICAL_ONLY'} if self.profile=='analytic_assembly' else {})})
        return path

    def edit(self,fn):
        p=self.paths[0];r=read(p);fn(r);write(p,r)
    def rejects(self):
        with self.assertRaises(ValueError):pair.compare(self.repo,self.paths)
    def test_complete_mock_pair(self):self.assertEqual(pair.compare(self.repo,self.paths)['status'],'CHECKS_PASS')
    def test_duplicate_seed(self):self.edit(lambda r:r.update(seed=92741));self.rejects()
    def test_missing_check(self):self.edit(lambda r:r['checks'].pop());self.rejects()
    def test_extra_pass_check(self):self.edit(lambda r:r['checks'].append({'id':'invented','status':'PASS'}));self.rejects()
    def test_failed_check(self):self.edit(lambda r:r['checks'][0].update(status='FAIL'));self.rejects()
    def test_changed_runtime(self):self.edit(lambda r:r.update(runtime={'changed':True}));self.rejects()
    def test_changed_evidence(self):
        p=self.paths[0];work=p.with_name(p.stem+'-evidence');r=read(work/'response.json');r['run_id']='stale';write(work/'response.json',r);self.rejects()
    def test_wrong_arithmetic_even_if_resealed(self):
        p=self.paths[0];work=p.with_name(p.stem+'-evidence');r=read(work/'response.json');next(x for x in r['responses'] if 'value' in x['values'])['values']['value']+=1;write(work/'response.json',r)
        self.edit(lambda r:r.update(evidence_files=snapshot(work)));self.rejects()
    def test_incomplete_numeric_even_if_resealed(self):
        if self.profile=='analytic_assembly':return
        p=self.paths[0];work=p.with_name(p.stem+'-evidence');nf=work/'foundation-evidence/numerical-1729.json';nr=read(nf);nr['checks'].pop();write(nf,nr)
        fp=work/'foundation.json';f=read(fp);f['checks'][-1]['report_sha256']=sha(nf);f['evidence_files']=snapshot(fp.with_name(fp.stem+'-evidence'));write(fp,f)
        self.edit(lambda r:r.update(evidence_files=snapshot(work),foundation_report={'path':str(fp),'sha256':sha(fp),'checks':len(f['checks'])}));self.rejects()
    def test_changed_check_id(self):self.edit(lambda r:r['checks'][0].update(id='wrong'));self.rejects()
    def test_missing_replay(self):self.edit(lambda r:r.update(checks=[c for c in r['checks'] if c['id']!='assembly.clean_replay']));self.rejects()
    def test_changed_sources(self):self.edit(lambda r:r.update(sources={'wrong':'source'}));self.rejects()
    def test_changed_run_identity(self):self.edit(lambda r:r.update(run_id='wrong'));self.rejects()
    def test_mixed_profiles(self):self.edit(lambda r:r.update(profile='analytic_assembly' if self.profile=='assembly' else 'assembly'));self.rejects()
    def test_deleted_analytic_response(self):
        work=self.paths[0].with_name(self.paths[0].stem+'-evidence');(work/'response.json').unlink();self.rejects()
    def edit_foundation(self,fn):
        report=read(self.paths[0]);fp=Path(report['foundation_report']['path']);f=read(fp);fn(f)
        f['evidence_files']=snapshot(fp.with_name(fp.stem+'-evidence'));write(fp,f)
        report['foundation_report'].update(sha256=sha(fp),checks=len(f['checks']))
        report['checks']=[c for c in report['checks'] if not c['id'].startswith('retained.')]+[{**c,'id':'retained.'+c['id']} for c in f['checks']]
        report['evidence_files']=snapshot(self.paths[0].with_name(self.paths[0].stem+'-evidence'));write(self.paths[0],report)
    def test_changed_foundation_id_even_if_resealed(self):
        self.edit_foundation(lambda f:f['checks'][0].update(id='wrong'));self.rejects()
    def test_removed_foundation_replay_even_if_resealed(self):
        self.edit_foundation(lambda f:f.update(checks=[c for c in f['checks'] if c['id']!='replay.semantic_outputs']));self.rejects()
    def test_changed_foundation_profile_even_if_resealed(self):
        self.edit_foundation(lambda f:f.update(profile='coefficients'));self.rejects()
    def test_changed_foundation_response_even_if_resealed(self):
        fp=Path(read(self.paths[0])['foundation_report']['path']);p=fp.with_name(fp.stem+'-evidence')/'response.json'
        data=read(p);data['responses'][0]['values']['H_UU']*=2;write(p,data)
        self.edit_foundation(lambda f:None);self.rejects()
    def test_pair_output_protection(self):
        for root in [self.repo,*self.runs]:
            with self.assertRaises(ValueError):pair.guard_output(self.repo,root/'new.json',self.paths)
        with self.assertRaises(ValueError):pair.guard_output(self.repo,self.paths[0],self.paths)
        self.assertEqual(pair.guard_output(self.repo,self.root/'pair.json',self.paths),self.root/'pair.json')

class AnalyticPairReportTests(PairReportTests):
    profile='analytic_assembly'
    def test_inserted_numerical_check_even_if_resealed(self):
        self.edit_foundation(lambda f:f['checks'].append({'id':'numerical.regression','status':'PASS','checks':457}));self.rejects()
    def test_missing_omission_metadata_even_if_resealed(self):
        self.edit_foundation(lambda f:f.pop('numerical_regression'));self.rejects()

if __name__=='__main__':unittest.main()
