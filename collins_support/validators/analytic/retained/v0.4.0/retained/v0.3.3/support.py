"""Shared release utilities; no production physics is evaluated here."""
import hashlib,json,os,signal,subprocess,time,sys
from pathlib import Path
SUPPORT_ROOT=next(p for p in Path(__file__).resolve().parents if p.name=='collins_support')
sys.path.insert(0,str(SUPPORT_ROOT))
from paths import access,same_path,same_snapshot,same_release,check_file,execution_context,historical_runtime_equal,output_path,verify_release_edits

class Blocked(RuntimeError): pass

def loads(text):
    def pairs(items):
        out={}
        for k,v in items:
            if k in out: raise ValueError('Duplicate JSON key: '+k)
            out[k]=v
        return out
    return json.loads(text,object_pairs_hook=pairs,parse_constant=lambda x: (_ for _ in ()).throw(ValueError('Nonfinite JSON: '+x)))

def read(path): return loads(access(path).read_text())
def sha(path):
    p=access(path)
    if p.is_symlink(): return hashlib.sha256(os.readlink(p).encode()).hexdigest()
    h=hashlib.sha256()
    with p.open('rb') as f:
        for block in iter(lambda:f.read(1024*1024),b''): h.update(block)
    return h.hexdigest()
def write(path,data):
    p=Path(path); p.parent.mkdir(parents=True,exist_ok=True)
    tmp=p.with_name(p.name+'.tmp')
    tmp.write_text(json.dumps(data,indent=2,sort_keys=True,allow_nan=False)+'\n'); os.replace(tmp,p)

def relative_file(root,name):
    p=Path(name)
    if not isinstance(name,str) or not name or p.is_absolute() or '..' in p.parts or '.'==name: raise ValueError('Unsafe relative path')
    root=access(root); q=root/p
    for parent in [q,*q.parents]:
        if parent==root: break
        if parent.is_symlink(): raise ValueError('Symlink is not an accepted artifact: '+name)
    if not q.is_file() or not q.resolve().is_relative_to(root): raise ValueError('Missing regular artifact: '+name)
    return q

def snapshot(root):
    root=access(root); out={}
    for p in sorted(root.rglob('*')):
        if '__pycache__' in p.parts or p.suffix=='.pyc': continue
        if p.is_symlink(): raise ValueError('Symlink in source tree: '+str(p))
        if p.is_file(): out[str(p.relative_to(root))]=sha(p)
    return out

def release_integrity(root):
    root=access(root); manifest=read(root/'MANIFEST.json'); expected=manifest['files']
    actual=snapshot(root); actual.pop('MANIFEST.json',None)
    if actual!=expected: raise Blocked('External validator changed; restore the shipped release')
    verify_release_edits(root,actual)
    return sha(root/'MANIFEST.json')

def execute(command,cwd,log,timeout,env=None):
    """No shell; bounded POSIX process group; output streams directly to disk."""
    if not command or not all(isinstance(x,str) and x for x in command): raise ValueError('Invalid argv')
    log=Path(log); log.parent.mkdir(parents=True,exist_ok=True)
    started=time.monotonic()
    with log.open('wb') as stream:
        p=subprocess.Popen(command,cwd=cwd,stdout=stream,stderr=subprocess.STDOUT,env=env,start_new_session=True)
        try: rc=p.wait(timeout=timeout)
        except BaseException:
            try: os.killpg(p.pid,signal.SIGTERM)
            except ProcessLookupError: pass
            try: p.wait(timeout=3)
            except subprocess.TimeoutExpired:
                try: os.killpg(p.pid,signal.SIGKILL)
                except ProcessLookupError: pass
                p.wait()
            raise
    return {'argv':command,'exit_code':rc,'elapsed_seconds':time.monotonic()-started,'log_sha256':sha(log)}

def baseline_check(repo,state):
    repo=access(repo); p=access(state)/'baseline.json'
    if not p.is_file(): raise Blocked('Existing numerical baseline is missing; do not initialize a replacement')
    data=read(p)
    if data.get('repo')!=str(repo): raise Blocked('Baseline belongs to a different repository path')
    r=subprocess.run(['git','-C',str(repo),'ls-files','--stage','-z'],capture_output=True,check=True)
    tracked={}
    for line in r.stdout.decode().split('\0'):
        if not line: continue
        meta,name=line.split('\t',1); mode,blob,stage=meta.split()
        if stage!='0': raise Blocked('Unresolved Git index entries')
        tracked[name]=mode
    bad=[]
    for name,old in data['files'].items():
        q=repo/name
        if not q.exists() and not q.is_symlink(): bad.append(name); continue
        # Match the retained numerical baseline's tagged link-target format.
        # os.fsencode preserves arbitrary POSIX target bytes; never follow links.
        current_sha = (hashlib.sha256(b'symlink\0' + os.fsencode(os.readlink(q))).hexdigest()
                       if q.is_symlink() else sha(q))
        current={'sha256':current_sha,'git_mode':tracked.get(name),'is_symlink':q.is_symlink(),'executable':bool(q.lstat().st_mode&0o111)}
        if current!=old: bad.append(name)
    if bad: raise ValueError('Original tracked files changed: '+', '.join(bad[:12]))
    return {'baseline_sha256':sha(p),'head':data['head'],'tracked_files':len(data['files'])}

def runtime_record(config):
    d=read(config)
    keys={'wolfram_kernel','kira','fermat','subtropica_root','feyncalc_root','feynarts_root','wolfram_init','stage_timeout_seconds'}
    if set(d)!=keys: raise Blocked('runtime.json must have exactly the keys in runtime.example.json')
    hashes={}
    for key in ('wolfram_kernel','kira','fermat'):
        p=access(d[key])
        if not p.is_file() or not os.access(p,os.X_OK): raise Blocked('Missing executable: '+key)
        d[key]=str(p); hashes[key]=sha(p)
    for key in ('subtropica_root','feyncalc_root','feynarts_root'):
        p=access(d[key])
        if not p.is_dir(): raise Blocked('Missing package directory: '+key)
        files={str(x.relative_to(p)):sha(x.resolve()) for x in sorted(p.rglob('*')) if x.is_file() and not any(k in x.parts for k in ('.git','__pycache__'))}
        if not files: raise Blocked('No Wolfram source in '+key)
        d[key]=str(p); hashes[key]=files
    if d['wolfram_init'] is not None:
        p=access(d['wolfram_init'])
        if not p.is_file(): raise Blocked('Missing wolfram_init file')
        d['wolfram_init']=str(p); hashes['wolfram_init']=sha(p)
    t=d['stage_timeout_seconds']
    if type(t) is not int or not 1<=t<=86400: raise ValueError('Stage timeout must be an integer in [1,86400]')
    return {'config':d,'hashes':hashes,'python':{'executable':sys.executable,'sha256':sha(Path(sys.executable).resolve()),'version':sys.version}}


def existing_records(state):
    root=access(state)
    return {str(p.relative_to(root)):sha(p) for p in sorted(root.rglob('*.json')) if p.is_file() and '.git' not in p.parts}

def retained_files(root,inventory):
    root=access(root)
    for name,digest in inventory.items():
        p=root/name
        if not p.is_file() or p.is_symlink() or not check_file(p,digest): raise ValueError('Protected file changed: '+str(p))
    return True
