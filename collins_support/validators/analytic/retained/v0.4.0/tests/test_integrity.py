import copy,json,os,sys,tempfile,unittest
from pathlib import Path
from unittest.mock import patch
import nlo_support as n,provenance,install,workflow

class IntegrityTests(unittest.TestCase):
    def setUp(self):self.tmp=tempfile.TemporaryDirectory();self.root=Path(self.tmp.name)
    def tearDown(self):self.tmp.cleanup()
    def test_strict_json(self):
        p=self.root/'x.json'
        for text in ['{"a":1,"a":2}','{"a":NaN}','{"a":Infinity}']:
            p.write_text(text)
            with self.assertRaises(ValueError):n.read(p)
    def test_safe_relative_files(self):
        p=self.root/'a';p.write_text('source')
        self.assertEqual(n.relative(self.root,'a'),p)
        (self.root/'linked').symlink_to(p)
        for name in ['../x','/etc/passwd','linked','a\\x','']:
            with self.subTest(name=name):
                with self.assertRaises((ValueError,n.Blocked)):n.relative(self.root,name)
    def test_snapshot_keeps_internal_links_rejects_escape(self):
        (self.root/'a').write_text('data');(self.root/'link').symlink_to('a')
        self.assertEqual(n.snapshot(self.root)['link'],{'kind':'symlink','target':'a'})
        (self.root/'bad').symlink_to('/etc/passwd')
        with self.assertRaises(ValueError):n.snapshot(self.root)
    def test_source_preservation_allows_only_additions(self):
        r=self.root/'release';p=self.root/'production';r.mkdir();p.mkdir();(p/'old').write_text('frozen')
        n.write(r/'accepted_sources.json',{'files':{'old':n.sha(p/'old')}})
        with patch.object(n,'ROOT',r):
            before=n.preserve_accepted(p);(p/'new').write_text('new derivation')
            self.assertEqual(n.preserve_accepted(p),before)
            (p/'old').write_text('changed')
            with self.assertRaises(ValueError):n.preserve_accepted(p)
    def test_output_guards_resolve_links(self):
        p=self.root/'protected';p.mkdir();(self.root/'alias').symlink_to(p,target_is_directory=True)
        for out in [p/'new',self.root/'alias/new']:
            with self.assertRaises(ValueError):n.outside(out,[p],True)
        f=self.root/'existing';f.write_text('keep')
        with self.assertRaises(ValueError):n.outside(f,[],True)
    def test_status_exact_unique_coverage(self):
        for rows in [[],[{'id':'x','status':'PASS'},{'id':'x','status':'PASS'}],[{'id':'x','status':'SKIPPED'}],[{'id':'x','status':'FAIL'}]]:
            self.assertEqual(n.status(rows),'FAIL')
        self.assertEqual(n.status([{'id':'x','status':'BLOCKED'}]),'BLOCKED')
        self.assertEqual(n.status([{'id':'x','status':'PASS'}]),'CHECKS_PASS')
    def graph(self):
        prod=self.root/'prod';out=self.root/'out';prod.mkdir();out.mkdir();(prod/'stage.wls').write_text('MOCK SOURCE ONLY')
        (out/'raw.wl').write_text('MOCK INTEGRAND');(out/'finite.wl').write_text('MOCK FINITE');(out/'other.wl').write_text('MOCK OTHER')
        def node(i,role,root,path,parents):
            base=prod if root=='production' else out
            return {'id':i,'role':role,'file':{'root':root,'path':path,'sha256':n.sha(base/path)},'parents':parents,'explanation':'Transport test graph only; this does not demonstrate a physical derivation.'}
        g={'schema':1,'stage':'d17','nodes':[node('source','operators','production','stage.wls',[]),node('raw','integrands','output','raw.wl',['source']),
           node('finite','finite_export','output','finite.wl',['raw']),node('other','independent_route','output','other.wl',['source'])],'exports':['finite','other']}
        n.write(out/'provenance.json',g)
        stage={'id':'d17','roles':['operators','integrands','finite_export','independent_route']}
        return prod,out,g,stage
    def test_provenance_graph_mutations(self):
        prod,out,g,stage=self.graph();self.assertEqual(provenance.check(stage,out,prod,{})['nodes'],4)
        bad=[]
        x=copy.deepcopy(g);x['nodes'][0]['parents']=['finite'];bad.append(x)
        x=copy.deepcopy(g);x['nodes'][2]['parents']=['absent'];bad.append(x)
        x=copy.deepcopy(g);x['nodes'][1]['file']['sha256']='0'*64;bad.append(x)
        x=copy.deepcopy(g);x['nodes'][1]['role']='other';bad.append(x)
        x=copy.deepcopy(g);x['exports']=['finite'];bad.append(x)
        x=copy.deepcopy(g);x['nodes'][3]['file']=x['nodes'][2]['file'];bad.append(x)
        for i,x in enumerate(bad):
            with self.subTest(mutant=i):
                n.write(out/'provenance.json',x)
                with self.assertRaises(ValueError):provenance.check(stage,out,prod,{})
    def test_execute_logs_actual_exit_and_timeout(self):
        ex=n.execute([sys.executable,'-c','print("actual process");raise SystemExit(2)'],self.root,self.root/'one.log',5)
        self.assertEqual(ex['exit_code'],2);self.assertEqual(ex['log_sha256'],n.sha(self.root/'one.log'))
        ex=n.execute([sys.executable,'-c','import time;time.sleep(10)'],self.root,self.root/'timeout.log',0.1)
        self.assertEqual(ex['exit_code'],124)
    def test_command_arguments_no_shell(self):
        sentinel='literal $(touch UNEXPECTED) `echo nope`'
        ex=n.execute([sys.executable,'-c','import sys;print(sys.argv[1])',sentinel],self.root,self.root/'literal.log',5)
        self.assertEqual(ex['exit_code'],0);self.assertEqual((self.root/'literal.log').read_text().strip(),sentinel)
        self.assertFalse((self.root/'UNEXPECTED').exists())
    def test_write_atomic_json(self):
        p=self.root/'write.json';n.write(p,{'x':1});n.write(p,{'x':2})
        self.assertEqual(n.read(p),{'x':2});self.assertFalse(p.with_name('write.json.tmp').exists())
    def test_doctor_unknown_stage_is_not_pass(self):
        with self.assertRaises(ValueError):workflow.stages('unimplemented')

class ReleaseTests(unittest.TestCase):
    def test_retained_manifest_exact(self):
        expected=n.read(n.BASE/'MANIFEST.json')['files']
        actual={p.relative_to(n.BASE).as_posix():n.sha(p) for p in n.BASE.rglob('*') if p.is_file() and '__pycache__' not in p.parts and p.suffix!='.pyc' and p!=n.BASE/'MANIFEST.json'}
        self.assertEqual(actual,expected)
        self.assertEqual(n.sha(n.BASE/'MANIFEST.json'),n.read(n.ROOT/'retained_identity.json')['manifest_sha256'])
    def test_scope_is_not_promoted(self):
        c=n.read(n.ROOT/'contract.json');self.assertEqual(len(c['new_obligations']),26)
        self.assertEqual(len(set(c['new_obligations'])),26)
        self.assertEqual(c['scope']['unrestricted_fixed_order_NLO'],'OUTSIDE_SCOPE')
        self.assertEqual(c['scope']['figure6'],'PAUSED');self.assertEqual(c['scope']['reverse_unitarity'],'DEFERRED')
    def test_no_protected_missing_evaluator(self):
        c=n.read(n.ROOT/'contract.json')
        self.assertEqual([x['script'] for x in c['stages']],['common/d16_nlo.wls','common/d17_nlo.wls','common/d18_nlo.wls','common/d19_nlo.wls'])
        self.assertFalse((n.ROOT/'candidate_api/d17_nlo.wls').exists())
