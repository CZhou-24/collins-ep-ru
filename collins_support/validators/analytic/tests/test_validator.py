import copy,json,os,sys,tempfile,unittest
from pathlib import Path
from unittest.mock import patch

sys.path.insert(0,str(Path(__file__).resolve().parents[1]))
import algebra as a
import ru_support as u
import workflow as w
import verify_ru as v

def value(constant=0,terms=(),result=0,sectors=('beam_fqq',)):
    return {'constant':constant,'terms':[{'ref':k,'factor':f} for k,f in terms],'eta_order':0,'eps_order':0,'value':result,'sectors':list(sectors)}

def family(real=True):
    return {'id':'R1','denominators':['x',['add','x',1]],'cuts':[0] if real else [],'positive_energy':True,'support_artifact':'support.wl','targets':[{'powers':[1,1],'numerator':1,'integrand':['mul',['pow','x',-1],['pow',['add','x',1],-1]]}]}

class Arithmetic(unittest.TestCase):
    def test_rational(self):self.assertEqual(a.decode(['add','1/3','2/3']),1)
    def test_complex(self):self.assertEqual(a.decode(['complex',0,1])**2,-1)
    def test_log(self):self.assertTrue(a.equal(a.decode(['log',1]),a.decode(0)))
    def test_polylog(self):self.assertEqual(a.decode(['polylog',3,0]),0)
    def test_float_rejected(self):
        with self.assertRaises(ValueError):a.decode(0.5)
    def test_bool_rejected(self):
        with self.assertRaises(ValueError):a.decode(True)
    def test_code_rejected(self):
        with self.assertRaises(ValueError):a.decode('__import__("os")')
    def test_infinite_rejected(self):
        with self.assertRaises(ValueError):a.decode(['pow',0,-1])
    def test_huge_power(self):
        with self.assertRaises(ValueError):a.decode(['pow','z',1000])
    def test_empty_operation(self):
        with self.assertRaises(ValueError):a.decode(['add'])
    def test_series_keeps_epsilon_times_pole(self):
        x=a.decode(['mul',['add',1,['mul',2,'eps']],['pow','eps',-1]])
        self.assertTrue(a.equal(a.truncate(x,0,0),a.decode(['add',['pow','eps',-1],2])))
    def test_cut_sign(self):self.assertTrue(a.check_cut_rule())
    def test_roundtrip(self):
        x=a.decode(['add',['complex',0,1],['zeta',3],['pow','z',-2]])
        self.assertTrue(a.equal(x,a.decode(a.encode(x))))

class IntegralCertificates(unittest.TestCase):
    def test_real_family(self):self.assertEqual(a.check_families({'families':[family()]},True),1)
    def test_virtual_family(self):self.assertEqual(a.check_families({'families':[family(False)]},False),1)
    def test_missing_cut(self):
        f=family();f['cuts']=[]
        with self.assertRaises(ValueError):a.check_families({'families':[f]},True)
    def test_cut_removed(self):
        f=family();f['targets'][0]['powers'][0]=0
        with self.assertRaises(ValueError):a.check_families({'families':[f]},True)
    def test_wrong_cut_position(self):
        f=family();f['cuts']=[2]
        with self.assertRaises(ValueError):a.check_families({'families':[f]},True)
    def test_missing_energy_support(self):
        f=family();f['positive_energy']=False
        with self.assertRaises(ValueError):a.check_families({'families':[f]},True)
    def test_wrong_reconstruction(self):
        f=family();f['targets'][0]['numerator']=2
        with self.assertRaises(ValueError):a.check_families({'families':[f]},True)
    def test_nonintegral_index(self):
        f=family();f['targets'][0]['powers'][0]=0.5
        with self.assertRaises(ValueError):a.check_families({'families':[f]},True)
    def test_zero_denominator(self):
        f=family();f['denominators'][0]=0
        with self.assertRaises(ValueError):a.check_families({'families':[f]},True)

class Assembly(unittest.TestCase):
    def test_connected_assembly(self):
        p={'values':{'r03/x':value(1,[('master/r02/A/M',2)],7)}}
        d,r=a.evaluate_values(p,{'master/r02/A/M':a.decode(3)})
        self.assertEqual(d['r03/x'],7)
    def test_false_value_rejected(self):
        p={'values':{'r03/x':value(1,[('master/r02/A/M',2)],8)}}
        with self.assertRaises(ValueError):a.evaluate_values(p,{'master/r02/A/M':a.decode(3)})
    def test_cycle(self):
        p={'values':{'r03/x':value(0,[('r03/y',1)],1),'r03/y':value(0,[('r03/x',1)],1)}}
        with self.assertRaises(ValueError):a.evaluate_values(p,{})
    def test_missing_master(self):
        p={'values':{'r03/x':value(0,[('master/r02/A/M',1)],1)}}
        with self.assertRaises(ValueError):a.evaluate_values(p,{})
    def test_duplicate_ref(self):
        p={'values':{'r03/x':value(0,[('master/r02/A/M',1),('master/r02/A/M',1)],2)}}
        with self.assertRaises(ValueError):a.evaluate_values(p,{'master/r02/A/M':a.decode(1)})
    def test_zero_link_not_dependency(self):
        r={'r03/x':value(1,[('master/r02/A/M',0)],1)}
        self.assertEqual(a.dependencies('r03/x',r),set())
    def test_probe_detects_wrong_constant(self):
        r={'r03/x':value(0,[('master/r02/A/M',1)],2)};q=copy.deepcopy(r);q['r03/x']['constant']=1
        with self.assertRaises(ValueError):v.recipes_equal(r,q)
    def test_probe_detects_wrong_factor(self):
        r={'r03/x':value(0,[('master/r02/A/M',1)],2)};q=copy.deepcopy(r);q['r03/x']['terms'][0]['factor']=2
        with self.assertRaises(ValueError):v.recipes_equal(r,q)
    def test_kira_scaled_factor(self):
        r={'r03/x':value(0,[('master/r02/A/M',1)],2)};q=copy.deepcopy(r);q['r03/x']['terms'][0]['factor']=2
        v.recipes_equal(r,q,['r03/x'],a.decode(2))
    def test_recompute(self):
        r={'r03/x':value(0,[('master/r02/A/M',2)],2),'r07/x':value(1,[('r03/x',3)],7)}
        self.assertEqual(a.recompute(r,{'master/r02/A/M':a.decode(2)})['r07/x'],13)
    def test_master_precision_missing_finite_term(self):
        r={'r03/x':value(0,[('master/r02/A/M',['pow','eps',-1])],0)}
        with self.assertRaises(ValueError):a.check_precision(r,{'master/r02/A/M':0})
    def test_master_precision_sufficient(self):
        r={'r03/x':value(0,[('master/r02/A/M',['pow','eps',-1])],0)}
        self.assertEqual(a.check_precision(r,{'master/r02/A/M':1})['r03/x'],0)
    def test_precision_tracks_epsilon_projection(self):
        r={'r03/x':value(0,[('master/r02/A/M','eps')],0)}
        self.assertEqual(a.check_precision(r,{'master/r02/A/M':0})['r03/x'],0)

class Filesystem(unittest.TestCase):
    def setUp(self):self.tmp=tempfile.TemporaryDirectory();self.root=Path(self.tmp.name)
    def tearDown(self):self.tmp.cleanup()
    def test_duplicate_json(self):
        p=self.root/'a.json';p.write_text('{"a":1,"a":2}')
        with self.assertRaises(ValueError):u.read(p)
    def test_nan_json(self):
        p=self.root/'a.json';p.write_text('{"a":NaN}')
        with self.assertRaises(ValueError):u.read(p)
    def test_traversal(self):
        with self.assertRaises(ValueError):u.contained(self.root,'../x',False)
    def test_absolute_path(self):
        with self.assertRaises(ValueError):u.contained(self.root,'/etc/passwd')
    def test_output_parent_overlap(self):
        with self.assertRaises(ValueError):u.disjoint(self.root,[self.root/'child'])
    def test_output_child_overlap(self):
        with self.assertRaises(ValueError):u.disjoint(self.root/'child',[self.root])
    def test_internal_symlink_preserved(self):
        (self.root/'real').write_text('data');(self.root/'alias').symlink_to('real')
        self.assertEqual(u.snapshot(self.root)['alias']['kind'],'symlink')
    def test_external_symlink_rejected(self):
        (self.root/'alias').symlink_to('/etc/passwd')
        with self.assertRaises(ValueError):u.snapshot(self.root)
    def test_evidence_link_rejected(self):
        (self.root/'real').write_text('data');(self.root/'alias').symlink_to('real')
        with self.assertRaises(ValueError):u.contained(self.root,'alias')
    def test_write_preserves_existing(self):
        p=self.root/'a.json';u.write(p,{'x':1})
        with self.assertRaises(ValueError):u.write(p,{'x':2})
        self.assertEqual(u.read(p),{'x':1})
    def test_process_failure(self):
        r=u.execute([sys.executable,'-c','raise SystemExit(7)'],self.root,self.root/'log',5)
        self.assertEqual(r['exit_code'],7)
    def test_process_timeout(self):
        r=u.execute([sys.executable,'-c','import time; time.sleep(5)'],self.root,self.root/'log',0.1)
        self.assertEqual(r['exit_code'],124)

class ReportIntegrity(unittest.TestCase):
    def test_empty_checks_not_pass(self):self.assertEqual(u.rows_status([]),'FAIL')
    def test_duplicate_checks_not_pass(self):self.assertEqual(u.rows_status([{'id':'x','status':'PASS'}]*2),'FAIL')
    def test_blocked_retained(self):self.assertEqual(u.rows_status([{'id':'x','status':'BLOCKED'}]),'BLOCKED')
    def test_unknown_status(self):self.assertEqual(u.rows_status([{'id':'x','status':'SKIP'}]),'FAIL')
    def test_reference_inventory(self):
        p=u.read(u.ROOT/'reference_values.json');contract=u.read(u.ROOT/'contract.json')
        self.assertEqual(len(p['values']),contract['required_comparison_values'])
        for x in p['values'].values():a.decode(x)
    def test_preserved_validator_manifest(self):
        self.assertEqual(u.digest(u.RETAINED/'MANIFEST.json'),u.read(u.ROOT/'accepted_v040.json')['validator_manifest_sha256'])
    def test_source_allowlist(self):
        p=u.read(u.ROOT/'sidis_reuse.json');self.assertEqual(len(p['files']),20)
        self.assertEqual(len({f['source'] for f in p['files']}),20)
        self.assertFalse(any('s06_' in f['source'] or 's07_' in f['source'] for f in p['files']))

if __name__=='__main__':unittest.main()
