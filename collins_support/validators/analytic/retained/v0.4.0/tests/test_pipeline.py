"""Orchestration regression with explicitly mocked native/retained processes.

Real run/receipt/provenance/report arithmetic is exercised. These synthetic
processes are never native derivation or MadGraph acceptance evidence.
"""
import argparse,copy,contextlib,io,json,tempfile,unittest
from pathlib import Path
from unittest.mock import patch
import nlo_support as n,workflow,verify_nlo as verify,compare_nlo_reports as compare
import oracles
from symbolic import encode
from tests.fixtures import fixtures,perturbed,make_assembly

class PipelineTests(unittest.TestCase):
    def setUp(self):
        self.tmp=tempfile.TemporaryDirectory();self.root=Path(self.tmp.name)
        self.repo=self.root/'repo';self.prod=self.repo/'collins_ep_analytic';(self.prod/'common').mkdir(parents=True)
        self.state=self.root/'state';self.state.mkdir()
        self.ps,self.matching=fixtures();self.base_count=0;self.calls=[]
        self.rt={'wolfram_kernel':'MOCK_ONLY','config':{'stage_timeout_seconds':10,'probe_timeout_seconds':10}}
        for st in workflow.stages():
            (self.prod/st['script']).write_text('SOFTWARE FIXTURE; no native physics is implemented here.\n')
        self.patches=[]
        for module in (workflow,verify,compare):
            self.patches.extend([patch.object(module,'release_integrity',lambda:'mock-release'),
                                 patch.object(module,'execute',self.fake_execute)])
        self.patches.extend([patch.object(workflow,'preserve_accepted',lambda p:'mock-accepted'),
                             patch.object(workflow,'runtime',lambda p:copy.deepcopy(self.rt))])
        for p in self.patches:p.start()
        self.capture=contextlib.redirect_stdout(io.StringIO());self.capture.__enter__()

    def tearDown(self):
        self.capture.__exit__(None,None,None)
        for p in reversed(self.patches):p.stop()
        self.tmp.cleanup()

    def fake_execute(self,command,cwd,log,timeout=10,env=None):
        command=[str(x) for x in command];script=Path(command[1]).name if command[1]!='-noprompt' else Path(command[-1]).name
        self.calls.append(script);log=Path(log);log.parent.mkdir(parents=True,exist_ok=True)
        def arg(key):return command[command.index(key)+1]
        if script=='workflow.py':
            self.base_count+=1;base=Path(arg('--state'))/'runs'/('mock-native-'+str(self.base_count));base.mkdir(parents=True)
            for sid in ('d13','d14','d15','s11'):
                out=base/'common'/(sid+'_result');out.mkdir(parents=True)
                n.write(out/'context.json',{'runtime':{'MOCK':'NO NATIVE EXECUTION'},'extension_runtime':{},'derivation_runtime':{}})
                n.write(base/'receipts'/(sid+'.json'),{'stage':sid,'MOCK':True})
            n.write(base/'common/d13_result/finite_matching.json',self.matching)
            n.write(base/'run.json',{'status':'STAGES_PASS','resumed':False,'source_sha256':{k:v['sha256'] for k,v in n.snapshot(self.prod).items()}})
            log.write_text(json.dumps({'run':str(base)})+'\n')
        elif script=='verify_derivation.py':
            dest=Path(arg('--report'));n.write(dest,{'status':'CHECKS_PASS','seed':int(arg('--seed')),'run':arg('--run'),'MOCK_ONLY':True})
            # Preserve a generated internal link through the new enclosing seal.
            tree=dest.with_name(dest.stem+'-evidence');tree.mkdir();(tree/'source.f').write_text('MOCK ONLY')
            (tree/'generated.f').symlink_to('source.f');log.write_text('MOCK retained verifier; no native execution\n')
        elif script=='compare_derivation_reports.py':
            n.write(arg('--report'),{'status':'CHECKS_PASS','MOCK_ONLY':True});log.write_text('MOCK retained comparator\n')
        elif script=='reexport.wls':
            c=n.read(env['COLLINS_NLO_REEXPORT_CONTEXT']);n.write(c['output'],n.read(Path(c['packet']).parent/'packet.json'))
            log.write_text('MOCK native reexport\n')
        elif script=='reexport_observable.wls':
            c=n.read(env['COLLINS_NLO_REEXPORT_CONTEXT']);p=n.read(Path(c['packet']).parent/'packet.json')['data']
            n.write(c['output'],{k:p[k] for k in ('observable','HF_integrand','ratio','paper_limit','scheme_variation')})
            log.write_text('MOCK native observable reexport\n')
        else:
            c=n.read(env['COLLINS_NLO_CONTEXT']);sid=c['stage'];out=Path(c['output'])
            self.assertEqual(n.read(env['COLLINS_ANALYTIC_CONTEXT'])['runtime'],c['native_runtime'])
            if sid=='d19':
                pkt=make_assembly(n.read(Path(c['inputs']['d17'])/'packet.json'),n.read(Path(c['inputs']['d18'])/'packet.json'))
            elif c['probe']:
                kind='HF' if sid=='d17' else 'jet'
                seed=next(s for s in (1729,92741) if encode(oracles.probe_density(s,kind))==c['probe']['delta'])
                pkt=perturbed(self.ps,kind,seed)[sid]
            else:pkt=copy.deepcopy(self.ps[sid])
            n.write(out/'packet.json',pkt)
            (out/'packet.wl').write_text('MOCK NATIVE TRANSPORT\n'+json.dumps(pkt,sort_keys=True))
            stage=next(x for x in workflow.stages() if x['id']==sid)
            for name in stage['artifacts']:
                if name not in ('packet.json','packet.wl','provenance.json'):(out/name).write_text('MOCK SOFTWARE EVIDENCE; NOT A NATIVE DERIVATION.\n')
            def node(key,role,parents,root,path):
                folder=self.prod if root=='production' else out
                return {'id':key,'role':role,'parents':parents,'explanation':'MOCK SOFTWARE GRAPH; not a physical derivation.',
                        'file':{'root':root,'path':path,'sha256':n.sha(folder/path)}}
            nodes=[node('source','source',[],'production',stage['script'])]
            for role in stage['roles']:
                name='mock-'+role+'.wl';(out/name).write_text('MOCK '+role+'\n')
                nodes.append(node(role,role,['source'],'output',name))
            nodes.append(node('packet','transport',stage['roles'],'output','packet.wl'))
            n.write(out/'provenance.json',{'schema':1,'stage':sid,'nodes':nodes,'exports':['packet']})
            log.write_text('MOCK native stage '+sid+'\n')
        return {'command':command,'exit_code':0,'log_sha256':n.sha(log),'elapsed_seconds':0.0}

    def fresh_runs(self):
        a=argparse.Namespace(repo=str(self.repo),state=str(self.state),through='d19',base_run=None,numerical_state=str(self.root/'historical-state'))
        for _ in range(2):self.assertEqual(workflow.run_workflow(a),0)
        return sorted((self.state/'runs').iterdir())

    def test_mocked_pair_lifecycle_and_tamper_rejections(self):
        runs=self.fresh_runs();reports=[]
        for seed in (1729,92741):
            dest=self.state/('nlo-'+str(seed)+'.json');reports.append(dest)
            args=argparse.Namespace(repo=str(self.repo),run=str(runs[0]),replay=str(runs[1]),seed=seed,report=str(dest))
            self.assertEqual(verify.verify(args),0)
            result=n.read(dest);self.assertEqual(result['qualifications'],verify.QUALIFICATIONS)
            self.assertEqual(n.status(result['checks']),'CHECKS_PASS')
            self.assertTrue(any(v['kind']=='symlink' for v in result['evidence_snapshot'].values()))
        args=argparse.Namespace(repo=str(self.repo),reports=[str(p) for p in reports],report=str(self.state/'pair.json'))
        self.assertEqual(compare.compare(args),0)
        self.assertEqual(n.read(args.report)['status'],'CHECKS_PASS')
        self.assertEqual(self.calls.count('workflow.py'),2)
        self.assertEqual(self.calls.count('verify_derivation.py'),2)
        self.assertEqual(self.calls.count('compare_derivation_reports.py'),1)
        self.assertEqual(self.calls.count('d19_nlo.wls'),6)
        saved=n.read(reports[0])
        for change in ('scope','row','evidence'):
            r=copy.deepcopy(saved)
            if change=='scope':r['qualifications']['radius_R1_certification']='GRANTED'
            if change=='row':r['checks'][0]['status']='FAIL'
            if change=='evidence':r['evidence_snapshot']={}
            n.write(reports[0],r)
            with self.subTest(change=change),self.assertRaises(ValueError):compare.check(self.repo,reports[0])
        n.write(reports[0],saved)
        raw=runs[0]/'common/d17_result/mock-integrands.wl';raw.write_text('changed after freeze')
        with self.assertRaises(ValueError):verify.fresh_pair(self.repo,*runs)

    def test_retained_blocker_cannot_be_promoted(self):
        runs=self.fresh_runs();original=self.fake_execute
        def blocked(command,cwd,log,timeout=10,env=None):
            ex=original(command,cwd,log,timeout,env)
            if str(command[1]).endswith('verify_derivation.py'):ex['exit_code']=2
            return ex
        args=argparse.Namespace(repo=str(self.repo),run=str(runs[0]),replay=str(runs[1]),seed=1729,report=str(self.state/'blocked.json'))
        with patch.object(verify,'execute',blocked):self.assertEqual(verify.verify(args),2)
        self.assertEqual(n.read(args.report)['status'],'BLOCKED')

    def test_raw_native_maps_cannot_omit_zero_or_contact_entries(self):
        data=self.ps['d19']['data'];keys=('observable','HF_integrand','ratio','paper_limit','scheme_variation')
        actual={k:copy.deepcopy(data[k]) for k in keys}
        workflow.check_observable_export(actual,data)
        for key,name in (('HF_integrand','v_derivative_delta'),('observable','UU0'),('ratio','A1')):
            changed=copy.deepcopy(actual);del changed[key][name]
            with self.subTest(key=key),self.assertRaises(ValueError):workflow.check_observable_export(changed,data)

    def test_unrequested_higher_order_coefficient_is_not_accepted(self):
        import nlo_checks
        changed=copy.deepcopy(self.ps['d19']);changed['data']['observable']['UU2']=0
        with self.assertRaises(ValueError):nlo_checks.d19_checks(changed,self.ps['d17'],self.ps['d18'])

    def test_same_or_shared_retained_run_is_rejected(self):
        with self.assertRaises(ValueError):verify.fresh_pair(self.repo,self.root/'a',self.root/'a')
        ma={'run_id':'a','base_run':'shared'};mb={'run_id':'b','base_run':'shared'}
        with patch.object(workflow,'audit',side_effect=[(ma,{}),(mb,{})]):
            with self.assertRaises(ValueError):verify.fresh_pair(self.repo,self.root/'a',self.root/'b')
