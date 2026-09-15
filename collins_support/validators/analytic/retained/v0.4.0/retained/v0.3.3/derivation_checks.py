"""Independent finite-coefficient, convention, provenance and upstream checks.

No candidate Python imports, eval, fitted providers, or phenomenology dependencies.
Exact rational-function comparisons do not certify the provenance of an equation.
Native proof replay and source review remain separate requirements. KPSY/C11
packets below are REFERENCE-SIDE conversion targets, never a request to change
the SIDIS-till-NLO production conventions. The independent convention lock must
bind the native export to its explicitly converted comparison packet.
"""
from __future__ import annotations
import hashlib, json, math, os, random, re, subprocess, time
from fractions import Fraction
from pathlib import Path

ROOT=Path(__file__).resolve().parent
SYMBOLS=set('CF TR z ell pi LQ LJ Bq Y r chi HUU HUT hard soft f0 f1 d0 d1 t0 t1 c0 c1 b Mh Q mu x y s t u alpha'.split())
FIELDS=('delta','D0','D1','regular')
KERNELS=('fqq','fqg','dqq','dgq','hqq','collins')
PROOF_IDS={
 'd13':tuple('matching.'+x for x in KERNELS)+tuple('splitting.'+x for x in ('qq','qg','gq','transversity'))+('matching.pole_cancellation',),
 'd14':('convention.fourier_rank0','convention.fourier_rank1','convention.collins_moment','scheme.hard_absorption_uu','scheme.hard_absorption_ut','scheme.rapidity_compensation','evolution.sudakov_measure','scheme.regulator_to_tmd_uu','scheme.regulator_to_tmd_ut'),
 'd15':('assembly.uu_first_order','assembly.ut_first_order','assembly.no_extra_inclusive_jet','assembly.no_fitted_inputs','assembly.asymmetry_ratio')}
REQUIRED_ARTIFACTS={
 'd13':('native_matching.wl','finite_matching.json','operator_inputs.json','projections.wl','regulated_integrals.wl','subtractions.wl','derivation_graph.json','proofs.wl'),
 'd14':('conventions.json','scheme_conversion.json','normalization_derivation.wl','scheme_derivation.wl','regulated_scheme.wl','proofs.wl'),
 'd15':('native_observable.wl','symbolic_observable.json','derivation_manifest.json','assembly_derivation.wl','proofs.wl')}

class PacketError(ValueError): pass

def _pairs(items):
 out={}
 for k,v in items:
  if k in out: raise PacketError('Duplicate JSON key: '+k)
  out[k]=v
 return out

def read(path):
 p=Path(path)
 if p.stat().st_size>16*1024*1024: raise PacketError('JSON packet exceeds 16 MiB')
 return json.loads(p.read_text(),object_pairs_hook=_pairs,parse_constant=lambda s: (_ for _ in ()).throw(PacketError('Nonfinite '+s)))
def write(path,obj):
 p=Path(path);p.parent.mkdir(parents=True,exist_ok=True);p.write_text(json.dumps(obj,indent=2,sort_keys=True,allow_nan=False)+'\n')
def sha(path):return hashlib.sha256(Path(path).read_bytes()).hexdigest()
def safe(root,name):
 if not isinstance(name,str) or not name or Path(name).is_absolute() or '..' in Path(name).parts:raise PacketError('Unsafe evidence path')
 root=Path(root).resolve();p=root/name
 for q in (p,*p.parents):
  if q==root:break
  if q.is_symlink():raise PacketError('Evidence symlink rejected: '+name)
 if not p.is_file() or not p.resolve().is_relative_to(root):raise FileNotFoundError(name)
 return p

def evidence_hashes(evidence,run):
 """Validate supplied identities, not the scientific content of the files."""
 if type(evidence) is not dict or not evidence:raise PacketError('Empty or malformed evidence map')
 for name,digest in evidence.items():
  if not isinstance(digest,str) or re.fullmatch('[0-9a-f]{64}',digest) is None:raise PacketError('Malformed evidence SHA-256')
  p=safe(run,name)
  if p.stat().st_size==0:raise PacketError('Empty evidence artifact: '+name)
  if sha(p)!=digest:return False
 return True

def rat(n,d=1):
 q=Fraction(n,d);return {'op':'rat','num':q.numerator,'den':q.denominator}
def sym(n):return {'op':'sym','name':n}
def co(x):return x if isinstance(x,dict) else rat(x)
def add(*args):return {'op':'add','args':[co(x) for x in args]}
def mul(*args):return {'op':'mul','args':[co(x) for x in args]}
def pow_(a,n):return {'op':'pow','base':co(a),'exp':n}
def neg(a):return mul(-1,a)
def div(a,b):return mul(a,pow_(b,-1))

def validate(tree):
 count=[0]
 def walk(x,depth):
  count[0]+=1
  if count[0]>2048 or depth>32 or type(x) is not dict:raise PacketError('AST budget/schema')
  op=x.get('op')
  if op=='rat':
   if set(x)!={'op','num','den'} or type(x['num']) is not int or type(x['den']) is not int or not 0<x['den']<=10**12 or abs(x['num'])>10**12:raise PacketError('Rational token')
  elif op=='sym':
   if set(x)!={'op','name'} or x['name'] not in SYMBOLS:raise PacketError('Unknown symbol')
  elif op in ('add','mul'):
   if set(x)!={'op','args'} or type(x['args']) is not list or not 1<=len(x['args'])<=32:raise PacketError('Arithmetic args')
   for c in x['args']:walk(c,depth+1)
  elif op=='pow':
   if set(x)!={'op','base','exp'} or type(x['exp']) is not int or not -4<=x['exp']<=4:raise PacketError('Power token')
   walk(x['base'],depth+1)
  else:raise PacketError('Unknown AST operation')
 walk(tree,0)

def _plus(a,b):
 out=dict(a)
 for k,v in b.items():
  out[k]=out.get(k,Fraction(0))+v
  if not out[k]:del out[k]
 if len(out)>4096:raise PacketError('Polynomial budget')
 return out

def _times(a,b):
 if len(a)*len(b)>100000:raise PacketError('Polynomial product budget')
 out={}
 for k,v in a.items():
  for l,w in b.items():
   ex=dict(k)
   for n,p in l:ex[n]=ex.get(n,0)+p
   if sum(ex.values())>48:raise PacketError('Polynomial degree budget')
   key=tuple(sorted(ex.items()));out[key]=out.get(key,Fraction(0))+v*w
 out={k:v for k,v in out.items() if v}
 if len(out)>4096:raise PacketError('Polynomial budget')
 return out
ONE={():Fraction(1)}

def rational(tree):
 validate(tree)
 def walk(x):
  op=x['op']
  if op=='rat':return ({():Fraction(x['num'],x['den'])} if x['num'] else {}),ONE
  if op=='sym':return {((x['name'],1),):Fraction(1)},ONE
  if op=='add':
   n,d={},ONE
   for a in x['args']:
    u,v=walk(a);n,d=_plus(_times(n,v),_times(u,d)),_times(d,v)
   return n,d
  if op=='mul':
   n,d=ONE,ONE
   for a in x['args']:
    u,v=walk(a);n,d=_times(n,u),_times(d,v)
   return n,d
  n,d=walk(x['base']);e=x['exp']
  if e<0:
   if not n:raise PacketError('Division by identically zero expression')
   n,d=d,n;e=-e
  u,v=ONE,ONE
  for _ in range(e):u,v=_times(u,n),_times(v,d)
  return u,v
 return walk(tree)

def equal(a,b):
 n,d=rational(a);u,v=rational(b);return _times(n,v)==_times(u,d)

def value(t,p):
 validate(t)
 def f(x):
  if x['op']=='rat':return x['num']/x['den']
  if x['op']=='sym':return p[x['name']]
  if x['op']=='add':return sum(f(a) for a in x['args'])
  if x['op']=='mul':return math.prod(f(a) for a in x['args'])
  return f(x['base'])**x['exp']
 return f(t)

def distribution(regular=0,delta=0,D0=0,D1=0):return {k:co(v) for k,v in zip(FIELDS,(delta,D0,D1,regular))}
def validate_distribution(d):
 if type(d) is not dict or set(d)!=set(FIELDS):raise PacketError('Expected canonical delta,D0,D1,regular distribution')
 for k,v in d.items():
  rational(v)
  if k!='regular' and any(n in ('z','ell') for m in rational(v) for term in m for n,_ in term):raise PacketError('Endpoint coefficients cannot depend on z or ln(z)')
 return d

def dist_equal(a,b):
 validate_distribution(a);validate_distribution(b)
 return all(equal(a[k],b[k]) for k in FIELDS)

def reference_matching():
 """Canonical *comparison* coefficients after an explicit reference conversion.

 Native production expressions retain the SIDIS repository convention. The
 matching packet checked here must be emitted by the conversion, not used as a
 hidden replacement for the native derivation or its observable assembly.
 """
 C,T,z,l=map(sym,('CF','TR','z','ell'));w=add(1,neg(z))
 fin={'fqq':mul(C,w),'fqg':mul(2,T,z,w),'dqq':add(mul(C,w),div(mul(2,C,add(1,pow_(z,2)),l),w)),
 'dgq':add(mul(C,z),div(mul(2,C,add(1,pow_(w,2)),l),z)),'hqq':rat(0),'collins':div(mul(4,C,z,l),w)}
 splitting={'qq':distribution(neg(mul(C,add(1,z))),mul(rat(3,2),C),mul(2,C)),
 'qg':distribution(mul(T,add(pow_(z,2),pow_(w,2)))),'gq':distribution(div(mul(C,add(1,pow_(w,2))),z)),
 'transversity':distribution(mul(-2,C),mul(rat(3,2),C),mul(2,C))}
 return {'schema':1,'coupling':'alpha_s/(2*pi)','scheme':'KPSY_C11_canonical','scale':'mu=mu_b; zeta=mu_b^2',
 'approximation':'diagonal_homogeneous_twist3','coefficients':{k:{'tree':distribution(delta=0 if k in ('fqg','dgq') else 1),'one_loop':distribution(v)} for k,v in fin.items()},'splitting':splitting}

def operator_inputs():
 C,T,z=map(sym,('CF','TR','z'));w=add(1,neg(z));p=reference_matching()['splitting']
 return {'schema':1,'d_dimensional_splitting':{k:{'epsilon0':p[k],'epsilon1':v} for k,v in {'qq':neg(mul(C,w)),'qg':mul(-2,T,z,w),'gq':neg(mul(C,z))}.items()},
 'normalization':'azimuth-averaged CDR real-emission kernels; transverse-trace convention fixed before integration',
 'integration_pole':'Gamma(-epsilon)=-1/epsilon+O(1)'}

def row(id,ok,detail=''):return {'id':id,'status':'PASS' if ok else 'FAIL','detail':detail}

def check_matching(packet,prefix='matching',expected=None):
 expected=reference_matching() if expected is None else expected
 if set(packet)!=set(expected):raise PacketError('Wrong finite_matching top-level keys')
 checks=[]
 for k in ('schema','coupling','scheme','scale','approximation'):checks.append(row(prefix+'.'+k,type(packet[k]) is type(expected[k]) and packet[k]==expected[k],expected[k]))
 for group in ('coefficients','splitting'):
  if set(packet[group])!=set(expected[group]):raise PacketError('Missing/extra '+group)
 for k in KERNELS:
  if set(packet['coefficients'][k])!={'tree','one_loop'}:raise PacketError('Wrong kernel orders')
  for order in ('tree','one_loop'):
   for part in FIELDS:
    d=validate_distribution(packet['coefficients'][k][order]);checks.append(row(f'{prefix}.{k}.{order}.{part}',equal(d[part],expected['coefficients'][k][order][part]),'Reference-side converted coefficient comparison only; ell=ln(z), 0<z<1; native conventions locked separately'))
 for k,v in expected['splitting'].items():checks.append(row(prefix+'.splitting.'+k,dist_equal(packet['splitting'][k],v),'Canonical plus distribution: D0=[1/(1-z)]_+; numerator-plus convention converted explicitly'))
 return checks

def reference_expressions():
 """Reference-side formulas and explicitly named convention identities."""
 C,z,pi,L,LJ,B,Y,r,chi=map(sym,('CF','z','pi','LQ','LJ','Bq','Y','r','chi'))
 hard=mul(C,add(neg(pow_(L,2)),mul(-3,L),-8,mul(rat(1,6),pow_(pi,2))))
 soft=mul(C,add(mul(add(mul(2,Y),r),B),mul(rat(-1,2),pow_(r,2))))
 return {'hard_ep':hard,'hard_kpsy':add(hard,mul(rat(-1,6),C,pow_(pi,2))), 'literal_hard_difference':mul(rat(1,6),C,pow_(pi,2)),
 'soft_ep':soft,'jet_inclusive':mul(C,add(mul(rat(1,2),pow_(LJ,2)),mul(rat(3,2),LJ),rat(13,2),mul(rat(-3,4),pow_(pi,2)))),
 'fourier_rank0_radial':div(1,mul(2,pi,pow_(z,2))),'fourier_rank1_radial':div(1,mul(4,pi,pow_(z,3))),
 'collins_vector_prefactor_without_i_b':div(-1,mul(2,z)),'Hhat3_over_Trento_first_moment':mul(-2,z,sym('Mh')),
 'hard_absorption_beam':mul(rat(1,2),hard),'hard_absorption_fragment':mul(rat(1,2),hard),'hard_after_absorption':rat(0),
 'rapidity_beam_shift':neg(mul(C,B,chi)),'rapidity_soft_shift':mul(C,B,chi),
 'sudakov_fixed_coupling':mul(C,add(pow_(L,2),mul(-3,L)))}

def check_scheme(p,run=None):
 if set(p)!={'schema','expressions','physical_map','conventions'} or type(p['schema']) is not int or p['schema']!=1:raise PacketError('Wrong scheme packet')
 expected=reference_expressions()
 if set(p['expressions'])!=set(expected):raise PacketError('Missing/extra scheme expressions')
 checks=[row('scheme.'+k,equal(p['expressions'][k],v),'Reference-side converted comparison; a=alpha_s/(2pi); does not select native production conventions') for k,v in expected.items()]
 conv={'fragmentation_fourier':'z^-2 integral d2b/(2pi)^2 exp(+i j.b/z)', 'collins_vector':'-i b^alpha Hhat3/(2z)', 'radial_rank1':'contract with jhat; coefficient multiplies b^2 db J1(b*j/z)', 'sudakov_log':'LQ here denotes ln(Q^2/mu_b^2) for sudakov_fixed_coupling only', 'rapidity_parameter':'chi=ln(zeta_new/zeta_old); same b and mu; finite NP prescription external'}
 checks.append(row('scheme.conventions',p['conventions']==conv,'Frozen signs, Jacobians and log definitions'))
 m=p['physical_map']
 if type(m) is not dict or set(m)!={'status','from_scheme','to_scheme','shift_uu','shift_ut','native_evidence','reference_note'}:raise PacketError('Wrong physical_map schema')
 if m['status'] not in ('RESOLVED','UNRESOLVED'):raise PacketError('physical_map status must be RESOLVED or UNRESOLVED')
 if m['status']!='RESOLVED':checks.append({'id':'scheme.physical_map','status':'BLOCKED','detail':'Finite regulator-to-subtracted-TMD map is unresolved. Hard absorption alone is not completion.'})
 else:
  checks.append(row('scheme.physical_map.named',all(isinstance(m[k],str) and m[k].strip() for k in ('from_scheme','to_scheme','reference_note')) and m['from_scheme']!=m['to_scheme']))
  for pol in ('uu','ut'):
   shifts=m['shift_'+pol]
   if set(shifts)!={'hard','soft','beam','fragment'}:raise PacketError('Scheme map must include all four factors')
   for a in shifts.values():rational(a)
   checks.append(row('scheme.physical_map.compensation.'+pol,equal(add(*shifts.values()),rat(0)),'O(a) compensation is necessary; regulator proof replay and source review establish the individual shifts'))
  ev=m['native_evidence']
  required={'common/d14_result/regulated_scheme.wl','common/d13_result/regulated_integrals.wl','common/d13_result/subtractions.wl'}
  if not isinstance(ev,list) or not all(isinstance(name,str) for name in ev) or len(ev)!=len(set(ev)):raise PacketError('Malformed native scheme evidence list')
  checks.append(row('scheme.physical_map.evidence',required<=set(ev),'Named evidence is only a provenance contract; native proof replay and independent source review are required'))
  if run is not None:
   for name in ev:checks.append(row('scheme.physical_map.evidence_file.'+name,safe(run,name).stat().st_size>0))
 return checks

def reference_assembly():
 H,U,h,s,f,F,d,D,t,T,c,C=map(sym,('HUU','HUT','hard','soft','f0','f1','d0','d1','t0','t1','c0','c1'))
 uu0=mul(H,f,d);ut0=mul(U,t,c)
 uu1=mul(H,add(mul(add(h,s),f,d),mul(F,d),mul(f,D)))
 ut1=mul(U,add(mul(add(h,s),t,c),mul(T,c),mul(t,C)))
 return {'UU0':uu0,'UU1':uu1,'UT0':ut0,'UT1':ut1,'A0':div(ut0,uu0),'A1':add(div(ut1,uu0),neg(div(mul(ut0,uu1),pow_(uu0,2))))}

def check_assembly(p):
 if set(p)!={'schema','coupling','expressions','input_roles','truncation','inclusive_jet_multiplier'}:raise PacketError('Wrong symbolic observable schema')
 ref=reference_assembly()
 if set(p['expressions'])!=set(ref):raise PacketError('Wrong observable coefficient set')
 checks=[row('assembly.'+k,equal(p['expressions'][k],v),'Exact formal expansion in a; symbolic matrix elements unevaluated') for k,v in ref.items()]
 checks += [row('assembly.schema',type(p['schema']) is int and p['schema']==1),row('assembly.coupling',p['coupling']=='alpha_s/(2*pi)'),row('assembly.truncation',p['truncation']=='O(a); A=A0+a*A1; no products of one-loop corrections'),row('assembly.no_extra_inclusive_jet',p['inclusive_jet_multiplier'] is False),row('assembly.input_roles',p['input_roles']=={'f0':'symbolic_f1','d0':'symbolic_D1','t0':'symbolic_h1','c0':'symbolic_Hhat3','f1':'derived_matching_convolution','d1':'derived_matching_convolution','t1':'derived_matching_convolution','c1':'derived_matching_convolution'})]
 return checks

def check_manifest(p,run):
 inv=read(ROOT/'equation_inventory.json')['equations'];expected={r['id']:r for r in inv}
 if set(p)!={'schema','equations'} or type(p['schema']) is not int or p['schema']!=1 or not isinstance(p['equations'],list):raise PacketError('Wrong derivation manifest')
 rows={}
 for r in p['equations']:
  if set(r)!={'id','origin','agreement','evidence','reference','note'} or r['id'] in rows:raise PacketError('Malformed/duplicate manifest row')
  rows[r['id']]=r
 if set(rows)!=set(expected):raise PacketError('Equation inventory cannot drop or add rows')
 checks=[]
 for id,item in expected.items():
  r=rows[id];checks.append(row('inventory.origin.'+id,r['origin']==item['required_origin'],'Required origin '+item['required_origin']))
  checks.append(row('inventory.agreement_label.'+id,r['agreement'] in ('EXACT','CONVERTED','NUMERICAL','UNVERIFIED','MISMATCH')))
  if item['required_origin']=='DERIVED' and r['agreement'] in ('UNVERIFIED','MISMATCH'):checks.append({'id':'inventory.unclosed.'+id,'status':'BLOCKED','detail':'Required derived expression not established; literal reference mismatch belongs in note plus explicit conversion evidence.'})
  checks.append(row('inventory.reference.'+id,isinstance(r['reference'],str) and bool(r['reference'].strip()),'Citation and equation identifier or explicit operator-definition citation required'))
  if not isinstance(r['note'],str):raise PacketError('Equation note must be text '+id)
  checks.append(row('inventory.hash.'+id,evidence_hashes(r['evidence'],run),'File identities bind evidence; hashes alone do not establish derivation'))
  stage=item['stage']
  if stage in REQUIRED_ARTIFACTS:
   required={'common/'+stage+'_result/'+name for name in REQUIRED_ARTIFACTS[stage]}
   # The manifest cannot hash itself. The other stage evidence must be present.
   required.discard('common/d15_result/derivation_manifest.json')
   checks.append(row('inventory.derivation_evidence.'+id,required<=set(r['evidence']),'Required native intermediate files and proof packet; semantic proof replay checked separately'))
 return checks

def check_graph(graph,run):
 if set(graph)!={'schema','chains'} or type(graph['schema']) is not int or graph['schema']!=1 or set(graph['chains'])!=set(KERNELS):raise PacketError('Wrong operator dependency graph')
 checks=[]
 names=('operator_inputs','projection','regulated_integral','subtraction','finite_output')
 required={'operator_inputs':'common/d13_result/operator_inputs.json','projection':'common/d13_result/projections.wl','regulated_integral':'common/d13_result/regulated_integrals.wl','subtraction':'common/d13_result/subtractions.wl','finite_output':'common/d13_result/finite_matching.json'}
 for k,chain in graph['chains'].items():
  if not isinstance(chain,list) or len(chain)!=5:raise PacketError('Incomplete matching chain '+k)
  for i,node in enumerate(chain):
   if set(node)!={'kind','path','sha256','depends_on','native_symbol'}:raise PacketError('Malformed dependency node')
   checks.append(row(f'dependency.{k}.{i}',node['kind']==names[i] and node['path']==required[names[i]] and node['depends_on']==([] if i==0 else [names[i-1]]) and isinstance(node['native_symbol'],str) and bool(node['native_symbol'].strip()) and evidence_hashes({node['path']:node['sha256']},run),'Declared chain and file identity only; fresh replay, perturbations and source review provide separate evidence'))
 return checks

# These perturbations change the D-dimensional splitting numerator entering the
# same native integration/subtraction function used by d13. They do not prove
# that an earlier operator trace was itself derived. They are not physics.
def mutation(kind,delta):
 inp=operator_inputs();ref=reference_matching();C,T,z=map(sym,('CF','TR','z'));w=add(1,neg(z))
 if kind=='qq_epsilon':key='qq';shift=mul(co(delta),C,w);targets=('fqq','dqq')
 elif kind=='qg_epsilon':key='qg';shift=mul(co(delta),T,z,w);targets=('fqg',)
 else:raise PacketError('Unknown upstream perturbation')
 inp['d_dimensional_splitting'][key]['epsilon1']=add(inp['d_dimensional_splitting'][key]['epsilon1'],shift)
 for k in targets:ref['coefficients'][k]['one_loop']['regular']=add(ref['coefficients'][k]['one_loop']['regular'],neg(shift))
 return inp,ref

MUTATION_WL=r'''$HistoryLength=0;
c=Import[Environment["COLLINS_DERIVATION_PROBE_CONTEXT"],"RawJSON"];
If[StringQ[c["wolfram_init"]],Get[c["wolfram_init"]]];
Get[c["library"]];
If[Length[DownValues[CollinsMatchingFromOperatorInputs]]==0,Quit[83]];
p=Import[c["input"],"RawJSON"];
result=CollinsMatchingFromOperatorInputs[p,c["output_directory"]];
If[!AssociationQ[result],Quit[84]];
Export[c["output"],result,"RawJSON"];Quit[0];
'''

def native_call(runtime,script,context,work):
 rt=runtime.get('config',runtime);kernel=rt.get('wolfram_kernel')
 if not isinstance(kernel,str) or not Path(kernel).is_file():raise FileNotFoundError('Configured Wolfram kernel required for upstream derivation probes')
 work=Path(work);work.mkdir(parents=True,exist_ok=True);scriptpath=work/'probe.wls';scriptpath.write_text(script)
 contextfile=work/'context.json';write(contextfile,context);env=dict(os.environ);env['COLLINS_DERIVATION_PROBE_CONTEXT']=str(contextfile)
 timeout=min(int(rt.get('stage_timeout_seconds',1800)),7200)
 command=[kernel,'-noprompt','-script',str(scriptpath)];start=time.monotonic()
 with (work/'native.log').open('wb') as log:
  process=subprocess.Popen(command,cwd=work,env=env,stdout=log,stderr=subprocess.STDOUT,start_new_session=True)
  try:rc=process.wait(timeout=timeout)
  except subprocess.TimeoutExpired:
   import signal
   os.killpg(process.pid,signal.SIGKILL);process.wait();raise PacketError('Native derivation probe timed out')
 write(work/'execution.json',{'argv':command,'exit_code':rc,'elapsed_seconds':time.monotonic()-start,'context_sha256':sha(contextfile),'script_sha256':sha(scriptpath),'log_sha256':sha(work/'native.log')})
 if rc:raise PacketError('Native derivation probe failed; see '+str(work/'native.log'))

def upstream_checks(repo,run,runtime,evidence_dir,seed):
 library=safe(Path(repo)/'collins_ep_analytic','common/d13_matching_library.wl')
 base=read(safe(run,'common/d13_result/operator_inputs.json'))
 if base!=operator_inputs():raise PacketError('Baseline D-dimensional operator input does not match declared CDR convention')
 checks=[];rng=random.Random(seed)
 for kind in ('qq_epsilon','qg_epsilon'):
  delta=Fraction(rng.choice([-1,1])*rng.randrange(1,7),rng.choice([7,11,13]));inp,expected=mutation(kind,delta)
  work=Path(evidence_dir)/('upstream-'+kind)
  if work.exists():raise PacketError('Refusing to reuse upstream probe directory')
  work.mkdir(parents=True);write(work/'operator_inputs.json',inp)
  library_before=sha(library)
  write(work/'SCOPE.json',{'scope':'ALTERED_D_DIMENSIONAL_NUMERATOR_DIAGNOSTIC_ONLY','delta':str(delta),'library_sha256':library_before,'expected_response':'Gamma(-eps) pole multiplies changed eps numerator; independent negative finite shift','limitation':'Tests numerator-to-finite-coefficient dependence, not independent derivation of the preceding operator traces'})
  rt=runtime.get('config',runtime);context={'library':str(library),'input':str(work/'operator_inputs.json'),'output':str(work/'finite_matching.json'),'output_directory':str(work),'wolfram_init':rt.get('wolfram_init')}
  native_call(runtime,MUTATION_WL,context,work)
  checks+=check_matching(read(safe(work,'finite_matching.json')),'upstream.'+kind,expected)
  for name in ('projections.wl','regulated_integrals.wl','subtractions.wl'):
   p=safe(work,name);checks.append(row('upstream.'+kind+'.regenerated.'+name,p.stat().st_size>0))
  checks.append(row('upstream.'+kind+'.library_unchanged',sha(library)==library_before))
  write(work/'artifact_hashes.json',{name:sha(safe(work,name)) for name in ('operator_inputs.json','finite_matching.json','projections.wl','regulated_integrals.wl','subtractions.wl','SCOPE.json')})
 return checks

def _static_tasks(run):
 return [('finite_matching',lambda:check_matching(read(safe(run,'common/d13_result/finite_matching.json')))),('scheme',lambda:check_scheme(read(safe(run,'common/d14_result/scheme_conversion.json')),run)),('observable',lambda:check_assembly(read(safe(run,'common/d15_result/symbolic_observable.json')))),('inventory',lambda:check_manifest(read(safe(run,'common/d15_result/derivation_manifest.json')),run)),('dependency_graph',lambda:check_graph(read(safe(run,'common/d13_result/derivation_graph.json')),run))]

def _collect(tasks):
 checks=[]
 for id,func in tasks:
  try:checks.extend(func())
  except FileNotFoundError as e:checks.append({'id':'derivation.'+id,'status':'BLOCKED','detail':str(e)})
  except (PacketError,ValueError,TypeError,KeyError,OSError) as e:checks.append({'id':'derivation.'+id,'status':'FAIL','detail':str(e)})
 return checks

def run_checks(repo,run,runtime,evidence_dir,seed):
 checks=_collect(_static_tasks(Path(run))+[('upstream_native',lambda:upstream_checks(repo,run,runtime,evidence_dir,seed))])
 write(Path(evidence_dir)/'derivation_checks.json',{'schema':1,'seed':seed,'checks':checks,'scope':'Fixed one-loop coefficient arithmetic, provenance contract and fresh upstream native dependency probes; no fitted input required. Source review required; full twist-three mixing/NLO excluded.'})
 return checks

def replay_upstream(evidence_dir,seed):
 """Recalculate saved probe comparisons without claiming a fresh native run.

 The enclosing run manifest must protect saved execution/evidence identities.
 Replaying hashes cannot independently authenticate who ran a native program.
 """
 checks=[];rng=random.Random(seed)
 for kind in ('qq_epsilon','qg_epsilon'):
  delta=Fraction(rng.choice([-1,1])*rng.randrange(1,7),rng.choice([7,11,13]));inp,expected=mutation(kind,delta)
  work=Path(evidence_dir)/('upstream-'+kind)
  checks.append(row('replay.upstream.'+kind+'.input',read(safe(work,'operator_inputs.json'))==inp,'Input must be regenerated from the report seed'))
  scope=read(safe(work,'SCOPE.json'))
  checks.append(row('replay.upstream.'+kind+'.scope',scope.get('scope')=='ALTERED_D_DIMENSIONAL_NUMERATOR_DIAGNOSTIC_ONLY' and scope.get('delta')==str(delta)))
  hashes=read(safe(work,'artifact_hashes.json'))
  required={'operator_inputs.json','finite_matching.json','projections.wl','regulated_integrals.wl','subtractions.wl','SCOPE.json'}
  if type(hashes) is not dict or set(hashes)!=required:raise PacketError('Incomplete saved upstream artifact hashes')
  checks.append(row('replay.upstream.'+kind+'.artifacts',evidence_hashes(hashes,work)))
  checks+=check_matching(read(safe(work,'finite_matching.json')),'upstream.'+kind,expected)
  execution=read(safe(work,'execution.json'))
  checks.append(row('replay.upstream.'+kind+'.native_exit',type(execution.get('exit_code')) is int and execution['exit_code']==0))
  for label,name in (('context','context.json'),('script','probe.wls'),('log','native.log')):
   checks.append(row('replay.upstream.'+kind+'.'+label,sha(safe(work,name))==execution.get(label+'_sha256')))
  checks.append(row('replay.upstream.'+kind+'.script_identity',safe(work,'probe.wls').read_text()==MUTATION_WL))
 return checks

def replay_checks(run,evidence_dir,seed):
 """Read-only replay of packet arithmetic and seeded saved dependency probes."""
 return _collect(_static_tasks(Path(run))+[('upstream_replay',lambda:replay_upstream(evidence_dir,seed))])
