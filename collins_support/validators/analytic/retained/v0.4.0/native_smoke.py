#!/usr/bin/env python3
"""Test the real Wolfram packet transport before expensive candidate derivations."""
import argparse,json
from pathlib import Path
from nlo_support import *
import workflow
from symbolic import decode,zero,SYMBOLS as V
import sympy as s

def smoke(a):
    release_integrity();repo=Path(a.repo).resolve();prod=repo/'collins_ep_analytic';cfg=read(relative(prod,'runtime.json'))
    out=outside(a.output,[repo,ROOT],new=True,area='states');out.mkdir(parents=True)
    rt={'wolfram_kernel':cfg['wolfram_kernel'],'config':{'probe_timeout_seconds':120,'stage_timeout_seconds':120}}
    ctx=out/'context.json';write(ctx,{'stage':'d19','output':str(out),'encoder':str(ROOT/'candidate_api/nlo_io.wl')})
    report={'status':'BLOCKED','scope':'native synthetic expression transport only'}
    try:
        ex=execute([rt['wolfram_kernel'],'-noprompt','-script',ROOT/'native_smoke.wls'],out,out/'native.log',120,{'COLLINS_NLO_CONTEXT':str(ctx)})
        if ex['exit_code']!=0:raise ValueError('native smoke execution failed')
        workflow.reexport(out,out/'packet-replay',rt)
        workflow.reexport_observable(out,out/'observable-replay',rt)
        d=read(out/'packet.json')['data']['observable']
        if not zero(decode(d['UU1'])-V['CF']*(s.Rational(1,3)+s.log(V['u'])+s.polylog(2,V['v']))):raise ValueError('transcendental transport mismatch')
        if not zero(decode(d['UT1'])-V['CF']*(s.pi**2+1/V['u'])):raise ValueError('rational transport mismatch')
        report.update(status='SMOKE_PASS',execution=ex)
    except Exception as e:report.update(status='FAIL',detail=str(e))
    write(out/'report.json',report);print(json.dumps(report,indent=2));return 0 if report['status']=='SMOKE_PASS' else 1
if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--repo',default='/bigTMD');p.add_argument('--output',required=True)
    try:raise SystemExit(smoke(p.parse_args()))
    except (ValueError,Blocked,FileNotFoundError) as e:print(json.dumps({'status':'BLOCKED','detail':str(e)}));raise SystemExit(2)
