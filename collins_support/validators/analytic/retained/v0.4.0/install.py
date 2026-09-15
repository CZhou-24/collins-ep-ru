#!/usr/bin/env python3
"""Historical completed NLO adoption helper; current engines run without reinstalling."""
import argparse,json,sys
from pathlib import Path
from nlo_support import *

def acceptance_identity(state):
    state=access(state);pair=read(state/'derivation-pair.json')
    if pair.get('status')!='CHECKS_PASS' or pair.get('profile')!='derivation' or not same_release(BASE,pair.get('validator_manifest_sha256')) or pair.get('seeds')!=[1729,92741]:
        raise Blocked('the accepted v0.3.3 official pair is required')
    refs=pair.get('reports',[])
    if len(refs)!=2:raise ValueError('incomplete accepted pair')
    snapshots=[];seeds=[]
    frozen=read(ROOT/'accepted_sources.json')['files']
    for item in refs:
        p=access(item['path'])
        if not p.is_relative_to(state):raise ValueError('accepted report is outside accepted state')
        if sha(p)!=item['sha256']:raise ValueError('accepted report hash changed')
        r=read(p);seeds.append(r.get('seed'))
        if (r.get('status')!='CHECKS_PASS' or r.get('profile')!='derivation' or r.get('sources')!=frozen
           or not same_release(BASE,r.get('validator_manifest_sha256')) or status(r.get('checks'))!='CHECKS_PASS' or len(r['checks'])!=1337):
            raise ValueError('wrong accepted candidate or report scope')
        snapshots.append({'path':str(p),'sha256':sha(p)})
    if set(seeds)!={1729,92741}:raise ValueError('accepted seeds incomplete')
    return {'pair':str(state/'derivation-pair.json'),'pair_sha256':sha(state/'derivation-pair.json'),'reports':snapshots}

def install(a):
    release=release_integrity();repo=Path(a.repo).resolve();prod=repo/'collins_ep_analytic'
    accepted=preserve_accepted(prod);previous=acceptance_identity(a.accepted_state)
    state=outside(a.state,[repo,ROOT,access(a.accepted_state)],area='states')
    lock=state/'adoption.json'
    additions={'common/nlo_io.wl':(ROOT/'candidate_api/nlo_io.wl').read_bytes(),
               'nlo_runtime.example.json':(json.dumps({'schema':1,'stage_timeout_seconds':7200,'probe_timeout_seconds':3600},indent=2)+'\n').encode()}
    for name,content in additions.items():
        p=prod/name
        if p.exists() or p.is_symlink():raise ValueError('installer will not overwrite '+str(p)+'; use the saved implementation directly')
        if not p.resolve().is_relative_to(prod):raise ValueError('installation path escapes production')
    if lock.exists():raise ValueError('adoption already recorded; do not reinstall over implementation')
    result={'schema':4,'status':'DRY_RUN' if a.dry_run else 'INSTALLED_ADDITIVE_INTERFACE',
       'release_sha256':release,'accepted_source_hash':accepted,'accepted_v033':previous,
       'repo':str(repo),'additions':{k:__import__('hashlib').sha256(v).hexdigest() for k,v in additions.items()},
       'note':'No physics implementation, native stage stub, baseline reset or runtime replacement is installed.'}
    if not a.dry_run:
        state.mkdir(parents=True,exist_ok=True)
        for name,content in additions.items():
            p=prod/name;p.parent.mkdir(parents=True,exist_ok=True)
            with p.open('xb') as f:f.write(content)
        preserve_accepted(prod);write(lock,result)
    print(json.dumps(result,indent=2));return 0

def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--repo',default='/bigTMD');p.add_argument('--state',default='collins_support/states/runs/nlo-adoption')
    p.add_argument('--accepted-state',default='collins_support/states/Collins-ep-analytic-state-v0.3.3');p.add_argument('--dry-run',action='store_true')
    try:return install(p.parse_args())
    except Exception as e:st='BLOCKED' if isinstance(e,(Blocked,FileNotFoundError)) else 'FAIL';print(json.dumps({'status':st,'detail':str(e)}));return 2 if st=='BLOCKED' else 1
if __name__=='__main__':raise SystemExit(main())
