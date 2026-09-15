#!/usr/bin/env python3
"""Completed historical installer; the existing engine needs no reinstallation."""
import argparse, json, shutil
from pathlib import Path
from ru_support import *

def install(a):
    rel=release_integrity();repo=Path(a.repo).resolve();old=repo/OLD_ENGINE;target=repo/ENGINE
    state=output_path(a.state,repo,protected=[ROOT,old,target,access(a.accepted_pair).parent],area='states')
    accepted=accepted_pair(repo,a.accepted_pair)
    if target.exists() or target.is_symlink():raise ValueError('new engine already exists; installer will not overwrite it')
    if (state/'adoption.json').exists():raise ValueError('adoption already exists')
    legacy=read(old/'runtime.json')
    defaults={'wolfram_kernel':'/opt/Wolfram/WolframEngine/15.0/Executables/WolframKernel','kira':'/bigTMD/SIDIS/common/software/kira-3.1','fermat':'/bigTMD/SIDIS/common/software/fermat/Ferl7/fer64','subtropica_root':'/bigTMD/SIDIS/common/software/SubTropica-1.2.10','feyncalc_root':'/factorization-and-loops/Addon/Mathematica_Addon/FeynCalc','feynarts_root':'/factorization-and-loops/Addon/Mathematica_Addon/FeynCalc/FeynArts','polymake':'/usr/bin/polymake'}
    config={'schema':1,'timeout_seconds':7200,**{k:legacy.get(k,v) for k,v in defaults.items()}}
    result={'schema':5,'status':'DRY_RUN' if a.dry_run else 'INSTALLED_INTERFACE','release':rel,'repo':str(repo),'implementation':str(target),'accepted':accepted,'additions':['common/ru_io.wl','ru_runtime.example.json'],'note':'No physics stage or acceptance stub is installed. The implementation agent writes r00-r07.'}
    if not a.dry_run:
        (target/'common').mkdir(parents=True,exist_ok=False)
        shutil.copyfile(ROOT/'native_io.wl',target/'common/ru_io.wl')
        write(target/'ru_runtime.example.json',config)
        preserve_old(repo);write(state/'adoption.json',result)
    print(json.dumps(result,indent=2));return 0

def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--repo',default='/bigTMD');p.add_argument('--state',default='collins_support/states/runs/historical-install');p.add_argument('--accepted-pair',default='collins_support/states/Collins-ep-analytic-state-v0.4.0/literature-revalidation-001/nlo-pair.json');p.add_argument('--dry-run',action='store_true')
    try:return install(p.parse_args())
    except Exception as exc:r,c=error_result(exc);print(json.dumps(r));return c
if __name__=='__main__':raise SystemExit(main())
