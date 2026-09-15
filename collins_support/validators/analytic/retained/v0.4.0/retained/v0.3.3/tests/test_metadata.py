"""Filesystem-based provenance/accuracy metadata tests; no backend execution."""
import copy,tempfile,unittest
from pathlib import Path
from support import write,read,sha
from verify_assembly import backend_evidence,producer_map,ACCURACY

class MetadataTests(unittest.TestCase):
    def setUp(self):
        self.t=tempfile.TemporaryDirectory();self.addCleanup(self.t.cleanup);self.root=Path(self.t.name)
        s=self.root/'common/s10_result';s.mkdir(parents=True);self.s=s
        for name in ('input.yaml','rule.wl','input.wls','master.wl','kira.log','subtropica.log'):(s/name).write_text('MOCKED INPUT/OUTPUT FOR PROVENANCE TEST ONLY\n')
        self.rt={'kira':'/MOCK/kira','wolfram_kernel':'/MOCK/WolframKernel'}
        self.data={'schema':2,'jobs':[]}
        for backend,exe,inp,out in [('kira','/MOCK/kira','input.yaml','rule.wl'),('subtropica','/MOCK/WolframKernel','input.wls','master.wl')]:
            self.data['jobs'].append({'backend':backend,'purpose':'MOCKED legitimate-shaped calculation receipt','argv':[exe,inp],
                'exit_code':0,'inputs':{inp:sha(s/inp)},'outputs':{out:sha(s/out)},'log':backend+'.log'})
        self.save()
    def save(self):write(self.s/'backend_jobs.json',self.data)
    def test_backend_record_shape(self):self.assertEqual(backend_evidence(self.root,self.rt)['status'],'PASS')
    def test_version_query_rejected(self):
        self.data['jobs'][0]['argv']=['/MOCK/kira','--version'];self.save()
        with self.assertRaises(ValueError):backend_evidence(self.root,self.rt)
    def test_missing_inputs(self):
        self.data['jobs'][0]['inputs']={};self.save()
        with self.assertRaises(ValueError):backend_evidence(self.root,self.rt)
    def test_wrong_executable(self):
        self.data['jobs'][0]['argv'][0]='/OTHER/kira';self.save()
        with self.assertRaises(ValueError):backend_evidence(self.root,self.rt)
    def test_changed_rules(self):
        (self.s/'rule.wl').write_text('changed')
        with self.assertRaises(ValueError):backend_evidence(self.root,self.rt)
    def test_missing_backend(self):
        self.data['jobs'].pop();self.save()
        with self.assertRaises(ValueError):backend_evidence(self.root,self.rt)
    def test_artifact_traversal(self):
        self.data['jobs'][0]['inputs']={'../secret':sha(self.s/'input.yaml')};self.save()
        with self.assertRaises(ValueError):backend_evidence(self.root,self.rt)
    def mapping(self):
        producers={'radiation':'common/s10_result/radiation.wl','operators':'common/s11_result/operators.wl',
                   'assembly':'common/s12_result/assembly.wl','HUU':'common/s03_result/tensors.wl',
                   'HUT':'common/s03_result/tensors.wl','hard1':'common/s07_result/hard.wl',
                   'real_eq':'common/s10_result/real_amplitudes.wl','real_eg':'common/s10_result/real_amplitudes.wl',
                   'primitives':'common/s10_result/masters.wl'}
        data={'schema':2,'entries':{},'external_inputs':[]}
        for key,path in producers.items():
            p=self.root/path;p.parent.mkdir(parents=True,exist_ok=True);p.write_text('MOCKED '+path)
            data['entries'][key]={'artifact':path,'sha256':sha(p),'description':'MOCKED provenance fixture'}
        for name,stage in [('operators.json','s11'),('born_hard.json','s09'),('spacelike_hard_one_loop.json','s09')]:
            write(self.root/'common'/f'{stage}_result'/name,{'scope':'MOCKED'});write(self.root/'common/s12_result'/name,{'scope':'MOCKED'})
        write(self.root/'common/s12_result/derivation_map.json',data);write(self.root/'common/s12_result/accuracy_ledger.json',ACCURACY)
        return data
    def test_producer_map(self):
        self.mapping();self.assertEqual(producer_map(self.root)['status'],'PASS')
    def test_wrong_upstream(self):
        d=self.mapping();d['entries']['hard1']['artifact']='common/s12_result/assembly.wl';write(self.root/'common/s12_result/derivation_map.json',d)
        with self.assertRaises(ValueError):producer_map(self.root)
    def test_changed_copy(self):
        self.mapping();write(self.root/'common/s12_result/operators.json',{'changed':True})
        with self.assertRaises(ValueError):producer_map(self.root)
    def test_overclaim_radius(self):
        self.mapping();write(self.root/'common/s12_result/accuracy_ledger.json',{**ACCURACY,'finite_R_certified':True})
        with self.assertRaises(ValueError):producer_map(self.root)
    def test_missing_producer(self):
        d=self.mapping();d['entries'].pop('primitives');write(self.root/'common/s12_result/derivation_map.json',d)
        with self.assertRaises(ValueError):producer_map(self.root)

if __name__=='__main__':unittest.main()
