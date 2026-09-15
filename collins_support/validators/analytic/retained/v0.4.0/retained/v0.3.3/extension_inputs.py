"""Preserve the reviewed foundation; hash additional executable dependencies."""
import os
from pathlib import Path
from support import read,sha,relative_file,Blocked,existing_records,retained_files,access,check_file
ROOT=Path(__file__).resolve().parent

def check_foundation(production):
    data=read(ROOT/'foundation_lock.json')
    for name,digest in data['files'].items():
        p=relative_file(production,name)
        if not check_file(p,digest):raise ValueError('Reviewed foundation file changed: '+name+'; restore it or obtain a separately reviewed correction')
    numerical=read(ROOT/'numerical_lock.json')['files']
    retained_files(Path(production).parent/'collins_ep',numerical)
    return {'source_identity':data['reviewed_source_identity'],'files':len(data['files']),'numerical_files':len(numerical)}

def extra_runtime(production):
    p=Path(production)/'assembly_runtime.json'
    if not p.is_file():raise Blocked('Install the v0.2.0 additive scaffold (assembly_runtime.json is missing)')
    data=read(p)
    if type(data) is not dict or set(data)!={'polymake','stage_timeout_seconds','legacy_analytic_state'} or not isinstance(data['polymake'],str):raise ValueError('Wrong assembly_runtime.json schema')
    path=access(data['polymake'])
    if not path.is_file() or not os.access(path,os.X_OK):raise Blocked('Configured polymake executable is missing')
    timeout=data['stage_timeout_seconds']
    if type(timeout) is not int or not 1<=timeout<=86400:raise ValueError('Assembly timeout must be in [1,86400] seconds')
    history=access(data['legacy_analytic_state'])
    retained_files(history,read(ROOT/'history_lock.json')['files'])
    return {'polymake':{'path':str(path),'sha256':sha(path)},'config_sha256':sha(p),
            'stage_timeout_seconds':timeout,'legacy_analytic_state':str(history),'historical_json':existing_records(history)}
