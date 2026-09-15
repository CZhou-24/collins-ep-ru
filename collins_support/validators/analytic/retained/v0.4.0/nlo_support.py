"""Immutable release, add-only adoption and contained evidence utilities."""
import hashlib,json,os,signal,stat,subprocess,sys,time
from pathlib import Path

SUPPORT=next(p for p in Path(__file__).resolve().parents if p.name=='collins_support')
if str(SUPPORT) not in sys.path:sys.path.insert(0,str(SUPPORT))
from paths import access,same_path,same_snapshot,same_release,check_file,execution_context,historical_runtime_equal,output_path,verify_release_edits

ROOT=Path(__file__).resolve().parent
BASE=ROOT/'retained/v0.3.3'
class Blocked(Exception):pass

def sha(path):return hashlib.sha256(access(path).read_bytes()).hexdigest()
def read(path):
    def unique(pairs):
        d={}
        for k,v in pairs:
            if k in d:raise ValueError('duplicate JSON key: '+k)
            d[k]=v
        return d
    return json.loads(access(path).read_text(),object_pairs_hook=unique,
                      parse_constant=lambda x: (_ for _ in ()).throw(ValueError('nonfinite JSON')))
def write(path,obj):
    p=access(path,required=False);p.parent.mkdir(parents=True,exist_ok=True)
    data=json.dumps(obj,sort_keys=True,indent=2,allow_nan=False)+'\n'
    temp=p.with_name(p.name+'.tmp')
    with open(temp,'x') as f:f.write(data)
    os.replace(temp,p)
def canonical_hash(obj):
    return hashlib.sha256(json.dumps(obj,sort_keys=True,separators=(',',':'),allow_nan=False).encode()).hexdigest()
def relative(root,name,allow_link=False):
    if type(name) is not str or not name or '\\' in name:raise ValueError('invalid relative path')
    rel=Path(name)
    if rel.is_absolute() or '..' in rel.parts:raise ValueError('unsafe relative path')
    root=access(root);p=root/rel
    if not p.resolve().is_relative_to(root):raise ValueError('path escapes root')
    if not allow_link and any(x.is_symlink() for x in [p,*p.parents] if x.is_relative_to(root) and x!=root):
        raise ValueError('link not allowed for new analytical evidence')
    if not p.is_file():raise Blocked('missing file: '+str(p))
    return p
def snapshot(root):
    root=access(root);result={}
    for parent,dirs,files in os.walk(root,followlinks=False):
        dirs[:]=sorted(d for d in dirs if d != '__pycache__')
        for name in sorted(files+list(dirs)):
            p=Path(parent)/name
            if name.endswith('.pyc'):continue
            rel=p.relative_to(root).as_posix()
            if p.is_symlink():
                if not p.resolve().is_relative_to(root):raise ValueError('escaping source/evidence link: '+rel)
                result[rel]={'kind':'symlink','target':os.readlink(p)}
            elif p.is_file():result[rel]={'kind':'file','sha256':sha(p),'size':p.stat().st_size}
            elif not p.is_dir():raise ValueError('special filesystem entry: '+rel)
    return result
def release_integrity():
    manifest=read(ROOT/'MANIFEST.json')
    actual={p.relative_to(ROOT).as_posix():sha(p) for p in ROOT.rglob('*')
            if p.is_file() and '__pycache__' not in p.parts and p.suffix!='.pyc' and p!=ROOT/'MANIFEST.json'}
    if actual!=manifest['files']:raise ValueError('v0.4.0 release content changed')
    verify_release_edits(ROOT,actual)
    identity=read(ROOT/'retained_identity.json')
    if not same_release(BASE,identity['manifest_sha256']):raise ValueError('retained release changed')
    return sha(ROOT/'MANIFEST.json')
def preserve_accepted(production):
    frozen=read(ROOT/'accepted_sources.json')['files']
    for name,digest in frozen.items():
        if not check_file(relative(production,name),digest):raise ValueError('accepted source changed: '+name)
    return canonical_hash(frozen)
def outside(path,protected,new=False,area='reports'):
    p=output_path(path,SUPPORT.parent,protected=protected,area=area)
    if new and p.exists():raise ValueError('choose an unused output path: '+str(p))
    return p
def execute(command,cwd,log,timeout=7200,env=None):
    cwd=access(cwd);log=access(log,required=False);log.parent.mkdir(parents=True,exist_ok=True)
    context=os.environ.copy();context.update({'OPENBLAS_NUM_THREADS':'1','OMP_NUM_THREADS':'1','MKL_NUM_THREADS':'1','PYTHONDONTWRITEBYTECODE':'1'})
    if env:context.update(env)
    start=time.monotonic()
    with open(log,'xb') as out:
        proc=subprocess.Popen([str(x) for x in command],cwd=cwd,env=context,stdout=out,stderr=subprocess.STDOUT,start_new_session=True)
        try:rc=proc.wait(timeout=timeout)
        except BaseException as exc:
            try:os.killpg(proc.pid,signal.SIGTERM)
            except ProcessLookupError:pass
            try:proc.wait(timeout=3)
            except subprocess.TimeoutExpired:
                try:os.killpg(proc.pid,signal.SIGKILL)
                except ProcessLookupError:pass
                proc.wait()
            if isinstance(exc,subprocess.TimeoutExpired):rc=124
            else:raise
    return {'command':[str(x) for x in command],'exit_code':rc,'log_sha256':sha(log),'elapsed_seconds':round(time.monotonic()-start,3)}
def last_json(log,key):
    found=[]
    for line in access(log).read_text(errors='replace').splitlines():
        try:v=json.loads(line)
        except ValueError:continue
        if type(v) is dict and key in v:found.append(v)
    if not found:raise ValueError('missing subprocess result '+key)
    return found[-1]
def retained_audit(repo,run,log):
    run=access(run)
    ex=execute([sys.executable,BASE/'workflow.py','status','--repo',repo,'--run',run],repo,log,7200)
    if ex['exit_code']!=0:raise ValueError('retained audit failed; see '+str(log))
    m=read(Path(run)/'run.json')
    if m.get('status')!='STAGES_PASS' or m.get('resumed') is not False:raise Blocked('retained run is not fresh/complete')
    return ex,m
def runtime(production):
    cfg=read(relative(production,'nlo_runtime.json'))
    if set(cfg)!={'schema','stage_timeout_seconds','probe_timeout_seconds'} or cfg['schema']!=1:raise ValueError('invalid nlo_runtime.json')
    for k in ('stage_timeout_seconds','probe_timeout_seconds'):
        if type(cfg[k]) is not int or not 1<=cfg[k]<=86400:raise ValueError('invalid timeout')
    old=read(relative(production,'runtime.json'));kernel=access(old['wolfram_kernel'])
    if not kernel.is_file():raise Blocked('Wolfram kernel unavailable')
    import sympy
    return {'config':cfg,'wolfram_kernel':str(kernel.resolve()),'kernel_sha256':sha(kernel),
            'python':str(Path(sys.executable).resolve()),'python_version':sys.version,
            'python_sha256':sha(Path(sys.executable).resolve()),
            'symbolic_backend':{'name':'sympy','version':sympy.__version__,'init_sha256':sha(sympy.__file__)}}
def status(rows):
    if type(rows) is not list or not rows or any(type(r) is not dict for r in rows):return 'FAIL'
    ids=[r.get('id') for r in rows]
    if any(type(i) is not str or not i for i in ids) or len(ids)!=len(set(ids)):return 'FAIL'
    states={r.get('status') for r in rows}
    if states-{'PASS','FAIL','BLOCKED'} or 'FAIL' in states:return 'FAIL'
    return 'BLOCKED' if 'BLOCKED' in states else 'CHECKS_PASS'
