"""Release, process and filesystem support for the separate RU engine."""
import hashlib, json, os, signal, stat, subprocess, sys, time
from pathlib import Path

SUPPORT = next(p for p in Path(__file__).resolve().parents if p.name == 'collins_support')
sys.path.insert(0, str(SUPPORT))
from paths import access, same_path, historical_path, same_snapshot, same_release, check_file, execution_context, historical_runtime_equal, output_path, verify_release_edits

ROOT = Path(__file__).resolve().parent
RETAINED = ROOT / 'retained/v0.4.0'
ENGINE = 'collins_ep_analytic_SIDIS'
OLD_ENGINE = 'collins_ep_analytic'
QUALIFICATIONS = {
    'scientific_source_review': 'REQUIRED',
    'independence': 'integration route; shared source components must be disclosed',
    'radius_R1': 'NOT_CERTIFIED',
    'unrestricted_fixed_order_NLO': 'OUTSIDE_SCOPE',
    'generic_HF_endpoint_contacts': 'NOT_CERTIFIED',
    'figure6': 'PAUSED', 'fitted_providers': 'NOT_REQUIRED',
    'new_modified_amplitudes_MadGraph': 'NOT_AUTOMATICALLY_CERTIFIED_BY_RETAINED_CHECKS'
}

class Blocked(Exception):
    pass

def read(path):
    def pairs(items):
        out = {}
        for key, value in items:
            if key in out: raise ValueError('duplicate JSON key: ' + key)
            out[key] = value
        return out
    def bad(value): raise ValueError('nonfinite JSON: ' + value)
    return json.loads(access(path).read_text(), object_pairs_hook=pairs, parse_constant=bad)

def digest(path):
    h = hashlib.sha256()
    with access(path).open('rb') as f:
        for b in iter(lambda: f.read(1024*1024), b''): h.update(b)
    return h.hexdigest()

def identity(obj):
    return hashlib.sha256(json.dumps(obj, sort_keys=True, separators=(',', ':'), allow_nan=False).encode()).hexdigest()

def write(path, obj, replace=False):
    p = access(path, required=False); p.parent.mkdir(parents=True, exist_ok=True)
    if p.exists() and not replace: raise ValueError('refusing overwrite: ' + str(p))
    temp = p.with_name(p.name + '.writing')
    with temp.open('x') as f:
        json.dump(obj, f, indent=2, sort_keys=True, allow_nan=False); f.write('\n')
    os.replace(temp, p)

def contained(root, name, exists=True, links=False):
    if type(name) is not str or not name or '\\' in name: raise ValueError('invalid relative path')
    rel = Path(name); root = access(root)
    if rel.is_absolute() or any(x in ('..', '.') for x in name.split('/')): raise ValueError('unsafe relative path')
    p = root / rel
    if not p.resolve().is_relative_to(root): raise ValueError('escaping path: ' + name)
    if not links and any(x.is_symlink() for x in [p, *p.parents] if x.is_relative_to(root)):
        raise ValueError('symlink not allowed here: ' + name)
    if exists and not p.is_file(): raise Blocked('missing file: ' + str(p))
    return p

def disjoint(path, protected):
    return output_path(path, SUPPORT.parent, protected=protected, area='reports')

def snapshot(root):
    root = access(root); out = {}
    if not root.is_dir(): raise Blocked('missing directory: ' + str(root))
    for parent, dirs, files in os.walk(root, followlinks=False):
        dirs[:] = sorted(d for d in dirs if d != '__pycache__')
        for name in sorted(set(dirs + files)):
            p = Path(parent) / name
            if p.suffix == '.pyc': continue
            rel = p.relative_to(root).as_posix()
            if p.is_symlink():
                if not p.resolve().is_relative_to(root) or not p.exists(): raise ValueError('escaping/broken symlink: ' + rel)
                out[rel] = {'kind':'symlink','target':os.readlink(p)}
            elif p.is_file(): out[rel] = {'kind':'file','sha256':digest(p),'size':p.stat().st_size}
            elif not p.is_dir(): raise ValueError('special filesystem entry: ' + rel)
    return out

def release_integrity():
    m = read(ROOT/'MANIFEST.json')
    actual = {p.relative_to(ROOT).as_posix():digest(p) for p in ROOT.rglob('*')
              if p.is_file() and '__pycache__' not in p.parts and p.suffix != '.pyc' and p != ROOT/'MANIFEST.json'}
    if actual != m['files']: raise ValueError('v0.5.1 release changed')
    verify_release_edits(ROOT, actual)
    pin = read(ROOT/'accepted_v040.json')
    if not same_release(RETAINED, pin['validator_manifest_sha256']): raise ValueError('retained validator changed')
    return digest(ROOT/'MANIFEST.json')

def preserve_old(repo):
    prod = Path(repo).resolve()/OLD_ENGINE
    expected = read(ROOT/'accepted_v040.json')['sources']
    for name, item in expected.items():
        p = contained(prod, name, links=item['kind']=='symlink')
        if item['kind']=='file' and not check_file(p,item['sha256']): raise ValueError('accepted source changed: ' + name)
        if item['kind']=='symlink' and (not p.is_symlink() or os.readlink(p)!=item['target']): raise ValueError('accepted symlink changed')
    return identity(expected)

def upstream_source_state(repo):
    """Preserve the approved files in the existing SIDIS tree, if present."""
    out={}
    for item in read(ROOT/'sidis_reuse.json')['files']:
        p=Path(repo)/item['source']
        if p.is_symlink():
            out[item['source']]={'kind':'symlink','target':os.readlink(p),'sha256':digest(p) if p.is_file() else None}
        elif p.is_file():out[item['source']]={'kind':'file','sha256':digest(p)}
        elif p.exists():raise ValueError('SIDIS source path is not a file')
        else:out[item['source']]={'kind':'absent'}
    return out

def rows_status(rows):
    if not isinstance(rows,list) or not rows: return 'FAIL'
    ids = [r.get('id') for r in rows]
    if any(type(i)!=str or not i for i in ids) or len(set(ids))!=len(ids): return 'FAIL'
    st = {r.get('status') for r in rows}
    if st-{'PASS','FAIL','BLOCKED'} or 'FAIL' in st: return 'FAIL'
    return 'BLOCKED' if 'BLOCKED' in st else 'CHECKS_PASS'

def accepted_pair(repo, path):
    """Identity gate only; official arithmetic replay is a separate command."""
    path = access(path); p = read(path); pin = read(ROOT/'accepted_v040.json')
    if p.get('schema')!=4 or p.get('profile')!='leading_power_nlo_extension' or p.get('status')!='CHECKS_PASS' or p.get('seeds')!=[1729,92741] or p.get('release_sha256')!=pin['validator_manifest_sha256'] or p.get('qualifications')!=pin['qualifications']:
        raise Blocked('accepted v0.4.0 two-seed pair required')
    entries = p.get('reports',[])
    if len(entries)!=2: raise ValueError('incomplete accepted pair')
    reports=[]; seeds=set()
    for entry in entries:
        f = access(entry['path'])
        if not f.is_relative_to(path.parent) or digest(f)!=entry['sha256']: raise ValueError('accepted report path/hash mismatch')
        r = read(f); seeds.add(r.get('seed'))
        if r.get('schema')!=4 or r.get('profile')!='leading_power_nlo_extension' or r.get('status')!='CHECKS_PASS' or rows_status(r.get('checks'))!='CHECKS_PASS' or len(r.get('checks',[]))!=pin['check_count'] or r.get('sources')!=pin['sources'] or r.get('release_sha256')!=pin['validator_manifest_sha256']:
            raise ValueError('wrong accepted report identity/scope')
        if r.get('qualifications')!=pin['qualifications']: raise ValueError('changed accepted scientific qualifications')
        reports.append({'path':entry['path'],'sha256':digest(f)})
    if seeds!={1729,92741}: raise ValueError('wrong accepted seeds')
    return {'pair':historical_path(path),'pair_sha256':digest(path),'reports':reports,'source_hash':preserve_old(repo)}

def execute(command, cwd, log, timeout, env=None):
    """No shell; receipts are written by the validator, never by a job."""
    log=access(log,required=False);log.parent.mkdir(parents=True,exist_ok=True)
    cwd=access(cwd)
    context=os.environ.copy();context.update({'OPENBLAS_NUM_THREADS':'1','MKL_NUM_THREADS':'1','OMP_NUM_THREADS':'1','PYTHONDONTWRITEBYTECODE':'1'})
    if env: context.update({k:str(v) for k,v in env.items()})
    begin=time.monotonic()
    with log.open('xb') as f:
        process=subprocess.Popen([str(x) for x in command],cwd=cwd,stdout=f,stderr=subprocess.STDOUT,env=context,start_new_session=True)
        try: rc=process.wait(timeout=timeout)
        except BaseException as exc:
            try: os.killpg(process.pid,signal.SIGTERM)
            except ProcessLookupError: pass
            try: process.wait(timeout=3)
            except subprocess.TimeoutExpired:
                try: os.killpg(process.pid,signal.SIGKILL)
                except ProcessLookupError: pass
                process.wait()
            if not isinstance(exc,subprocess.TimeoutExpired): raise
            rc=124
    return {'command':[str(x) for x in command],'exit_code':rc,'log_sha256':digest(log),'elapsed_seconds':round(time.monotonic()-begin,3)}

def runtime(repo):
    p=Path(repo)/ENGINE/'ru_runtime.json';r=read(p)
    if set(r)!={'schema','wolfram_kernel','kira','fermat','subtropica_root','feyncalc_root','feynarts_root','polymake','timeout_seconds'} or r['schema']!=1:
        raise ValueError('ru_runtime.json has wrong keys/schema')
    if type(r['timeout_seconds']) is not int or not 1<=r['timeout_seconds']<=86400: raise ValueError('invalid timeout')
    identities={}
    for name in ('wolfram_kernel','kira','fermat','polymake'):
        f=access(r[name]).resolve()
        if not f.is_file() or not os.access(f,os.X_OK): raise Blocked('executable unavailable: '+name)
        identities[name]={'path':str(f),'sha256':digest(f)}
    for name in ('subtropica_root','feyncalc_root','feynarts_root'):
        folder=access(r[name]).resolve()
        if not folder.is_dir(): raise Blocked('tool root unavailable: '+name)
        # Native tool roots may contain links to shared installations. Pin the
        # actual source bytes, without rejecting established tool layouts.
        src={p.relative_to(folder).as_posix():digest(p) for p in folder.rglob('*') if p.is_file() and p.suffix.lower() in ('.wl','.wls','.m','.mod','.gen','.mx')}
        if not src: raise Blocked('no Wolfram sources in '+name)
        identities[name]={'path':str(folder),'source_hash':identity(src)}
    import sympy
    identities['python']={'path':str(Path(sys.executable).resolve()),'version':sys.version,'sha256':digest(Path(sys.executable).resolve()),'sympy':sympy.__version__}
    return {'config':r,'identities':identities}

def error_result(exc):
    status='BLOCKED' if isinstance(exc,(Blocked,FileNotFoundError)) else 'FAIL'
    return {'status':status,'detail':str(exc)}, 2 if status=='BLOCKED' else 1
