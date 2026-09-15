"""Tests of altered-export dependency probes and numerical failure controls."""
import copy,json,tempfile,unittest
from pathlib import Path
from unittest.mock import patch
import bridge_probes as bp
import assembly_oracle as ao
from assembly_reference import references
from algebra import value
from support import read,write,sha

class DependencyProbeTests(unittest.TestCase):
    def test_mutation_does_not_change_original(self):
        r,o,a,_=references();data={'operators.json':ao.packet('operators',o),'assembly.json':ao.packet('assembly',{'expressions':a}),
            'spacelike_hard_one_loop.json':{'expressions':{'h1':{'op':'rat','num':0,'den':1}}}}
        original=copy.deepcopy(data)
        for kind in ('soft','hard','assembly'):
            altered=bp.mutate(data,kind);self.assertNotEqual(altered,data);self.assertEqual(data,original)
    def test_changed_inputs_have_expected_effect(self):
        for kind in ('soft','hard','assembly'):
            req=bp.probe_requests(1729,kind)
            payload={'run_id':'n','status':'PASS','responses':[{'id':r['id'],'values':bp.target(r,kind)} for r in req]}
            self.assertTrue(all(c['status']=='PASS' for c in bp.compare(req,payload,'n',kind)))
    def test_bridge_ignoring_inputs_fails_all_three_probes(self):
        for kind in ('soft','hard','assembly'):
            req=bp.probe_requests(92741,kind)
            payload={'run_id':'n','status':'PASS','responses':[{'id':r['id'],'values':ao.expected(r)} for r in req]}
            self.assertTrue(any(c['status']=='FAIL' for c in bp.compare(req,payload,'n',kind)))
    def test_old_probe_nonce_rejected(self):
        req=bp.probe_requests(1729,'soft');p={'run_id':'old','status':'PASS','responses':[]}
        with self.assertRaises(ValueError):bp.compare(req,p,'n','soft')
    def test_probe_file_orchestration(self):
        with tempfile.TemporaryDirectory() as d:
            root=Path(d);production=root/'source';(production/'numerics').mkdir(parents=True);(production/'numerics/evaluate_assembly.py').write_text('# MOCKED bridge')
            export=root/'export';export.mkdir();work=root/'work';work.mkdir()
            r,o,a,_=references()
            for name,data in {'operators.json':ao.packet('operators',o),'assembly.json':ao.packet('assembly',{'expressions':a}),
                'born_hard.json':{},'spacelike_hard_one_loop.json':{'expressions':{'h1':{'op':'rat','num':0,'den':1}}}}.items():write(export/name,data)
            old={p.name:sha(p) for p in export.iterdir()}
            def fake(cmd,cwd,log,timeout):
                req=read(cmd[-1]);kind=Path(cmd[cmd.index('--export-dir')+1]).parent.name.removeprefix('bridge-probe-')
                data=read(Path(cmd[cmd.index('--export-dir')+1])/'operators.json')
                if kind=='soft':self.assertNotEqual(data,read(export/'operators.json'))
                write(log,{'run_id':req['run_id'],'status':'PASS','responses':[{'id':r['id'],'values':bp.target(r,kind)} for r in req['requests']]})
                return {'exit_code':0,'argv':cmd,'log_sha256':sha(log),'scope':'MOCKED bridge execution'}
            with patch.object(bp,'execute',fake):checks=bp.run(production,export,work,1729,'n',30)
            self.assertEqual(len(checks),14);self.assertTrue(all(c['status']=='PASS' for c in checks))
            self.assertEqual(bp.replay(work,1729,'n'),checks)
            self.assertEqual(old,{p.name:sha(p) for p in export.iterdir()})

class NumericalMutants(unittest.TestCase):
    def reject(self,edit):
        r=next(r for r in ao.requests(1729) if r['kind']=='gaussian');v=copy.deepcopy(ao.expected(r));edit(r,v)
        p={'run_id':'n','status':'PASS','responses':[{'id':r['id'],'values':v}]}
        self.assertTrue(any(c['status']=='FAIL' for c in ao.compare_response([r],p,'n')))
    def test_missing_z_jacobian(self):self.reject(lambda r,v:v.update({k:x*r['z']**2 for k,x in v.items()}))
    def test_wrong_spin_sign(self):self.reject(lambda r,v:v.update(UT0=-v['UT0'],UT1=-v['UT1']))
    def test_collapsed_fourier_variables(self):
        self.reject(lambda r,v:v.update(ao.expected(dict(r,q=r['j']/r['z'],j=r['q']*r['z']))))
    def test_missing_rank_one(self):self.reject(lambda r,v:v.update(UT0=v['UU0'],UT1=v['UU1']))
    def test_extra_coupling(self):self.reject(lambda r,v:v.update(UU1=.03*v['UU1'],UT1=.03*v['UT1']))
    def test_common_soft_cancellation(self):self.reject(lambda r,v:v.update(UT1=v['UT0']*v['UU1']/v['UU0']))

if __name__=='__main__':unittest.main()
