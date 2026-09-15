#!/usr/bin/env python3
"""Execute real Kira/SubTropica repair regressions; no Collins workflow acceptance."""
import argparse,json,shutil
from pathlib import Path
import workflow as w
import verify_ru as v
from ru_support import *

def kernel(script,context,env,rt,work):
    work.mkdir(parents=True,exist_ok=False);cp=work/'context.json';write(cp,context)
    ex=execute([rt['config']['wolfram_kernel'],'-noprompt','-script',script],work,work/'execution.log',rt['config']['timeout_seconds'],{env:cp})
    write(work/'receipt.json',ex)
    if ex['exit_code']!=0:raise Blocked('native regression command failed: '+str(work))
    return ex

def make_kira_inputs(out):
    work=out/'jobs/quark';(work/'config').mkdir(parents=True)
    (work/'jobs.yaml').write_text('''jobs:
  - reduce_sectors:
      reduce:
        - {topologies: [R1], sectors: [7], r: 5, s: 1}
      select_integrals:
        select_mandatory_list:
          - [targets]
      preferred_masters: preferred
      run_initiate: true
      run_triangular: true
      run_back_substitution: true
  - kira2math:
      target:
        - [targets]
''')
    (work/'config/integralfamilies.yaml').write_text('''integralfamilies:
  - name: R1
    loop_momenta: [r]
    top_level_sectors: [7]
    propagators:
      - ["r", 0]
      - ["p-r", 0]
      - ["r-n", 0]
    cut_propagators: [1,2]
''')
    (work/'config/kinematics.yaml').write_text('''kinematics:
  incoming_momenta: [p,n]
  outgoing_momenta: []
  kinematic_invariants:
    - [w, 2]
  scalarproduct_rules:
    - [[p,p], w]
    - [[p,n], w/2]
    - [[n,n], 0]
''')
    (work/'targets').write_text('R1[1,1,0]\nR1[1,1,1]\nR1[1,1,2]\nR1[1,1,-1]\n')
    (work/'preferred').write_text('R1[1,1,0]\n')
    family={'id':'R1','denominators':['c1','c2','c3'],'cuts':[0,1],
            'targets':[{'powers':x} for x in ([1,1,0],[1,1,1],[1,1,2],[1,1,-1])]}
    job={'id':'quark','inputs':['jobs.yaml','config/integralfamilies.yaml','config/kinematics.yaml','targets','preferred'],
         'outputs':['results/R1/kira_targets.m','tmp/R1/masters'],'master_inventory':'tmp/R1/masters','families':['R1'],'sectors':['beam_fqq']}
    return job,{'families':[family]}

def regression(a):
    release=release_integrity();rt=runtime(a.repo);prod=Path(a.repo)/ENGINE
    sources=snapshot(prod);dest=output_path(a.output,a.repo,protected=[ROOT,Path(a.repo)/ENGINE,Path(a.repo)/OLD_ENGINE],area='states');dest.mkdir(parents=True,exist_ok=False)
    result={'schema':5,'release':release,'scope':'native repair regression only; no complete RU/Collins acceptance','status':'BLOCKED','runtime':rt}
    try:
        baseline=dest/'baseline';out=baseline/'common/r01_result'
        job,packet=make_kira_inputs(out);write(out/'context.json',{'runtime':rt['config'],'output':str(out)})
        jr=w.job_execute({'id':'r01','tool':'kira'},job,out,rt,packet)
        write(baseline/'receipts/r01.json',{'stage':'r01','jobs':[jr],'tree':snapshot(out)})
        st=dest/'subtropica';volume=st/'jobs/volume';null=st/'jobs/null'
        volume.mkdir(parents=True);null.mkdir(parents=True)
        write(st/'context.json',{'runtime':rt['config'],'output':str(st)})
        geometry={'volume_input':str(volume/'euler_inputs.wl'),'null_input':str(null/'euler_inputs.wl'),'geometry':str(dest/'geometry.wl')}
        kernel(ROOT/'native_regression_inputs.wls',geometry,'COLLINS_RU_REGRESSION',rt,dest/'input-derivation')
        # Negative control: a disclosed disposable helper with periods disabled.
        # It must fail without a PASS receipt; the released evaluator is untouched.
        neg=dest/'periods-disabled';neg.mkdir();shutil.copy2(volume/'euler_inputs.wl',neg/'euler_inputs.wl')
        src=(ROOT/'native_subtropica.wls').read_text();needle='SetOptions[HyperIntica`HyperInt, "EvaluatePeriodsQ" -> True];'
        if src.count(needle)!=1:raise ValueError('period-setting regression fixture is stale')
        (neg/'native_subtropica.wls').write_text(src.replace(needle,needle.replace('True','False')))
        shutil.copy2(ROOT/'native_io.wl',neg/'native_io.wl')
        ex=execute([rt['config']['wolfram_kernel'],'-noprompt','-script',neg/'native_subtropica.wls'],neg,neg/'execution.log',rt['config']['timeout_seconds'],{'COLLINS_RU_TOOL_CONTEXT':st/'context.json'})
        write(neg/'receipt.json',ex)
        if ex['exit_code']!=1 or not (neg/'masters.wl').is_file() or 'Unsupported exact expression' not in (neg/'execution.log').read_text() or (neg/'subtropica_execution.json').exists():
            raise ValueError('period-disabled negative control did not fail at exact-master validation')
        for name in ('volume','null'):
            sj={'id':name,'inputs':['euler_inputs.wl'],'outputs':['masters.wl','raw_results.wl','subtropica_execution.json'],'families':['R1'],'sectors':['beam_fqq']}
            receipt=w.job_execute({'id':'r02','tool':'subtropica'},sj,st,rt,{})
            write(st/(name+'-receipt.json'),receipt)
        cert=out/'jobs/quark/reduction_certificate.wl';probes=[]
        for seed in (1729,92741):
            probe=dest/('probe-'+str(seed))
            # Copy the real native r01 result only; this is a mutation fixture,
            # never a fresh r00-r07 workflow or an accepted run.
            shutil.copytree(out,probe/'common/r01_result')
            (probe/'receipts').mkdir();shutil.copy2(baseline/'receipts/r01.json',probe/'receipts/r01.json')
            jobs=v.kira_mutation_jobs(baseline,probe,read(probe/'receipts/r01.json'))
            factor=v.decode(str(seed%5+7)+'/6')
            mutation={'kind':'kira','scope':'complete_audited_reduction_map','numerator':int(factor.p),'denominator':int(factor.q),
                      'jobs':jobs,'paths':[p for j in jobs for p in j['paths']],'audit_output':str(probe/'reduction-response.json')}
            write(probe/'mutation-context.json',mutation)
            ex=execute([rt['config']['wolfram_kernel'],'-noprompt','-script',ROOT/'native_mutate.wls'],probe,probe/'mutation.log',rt['config']['timeout_seconds'],{'COLLINS_RU_MUTATION':probe/'mutation-context.json'})
            if ex['exit_code']!=0:raise Blocked('native map mutation failed')
            write(probe/'mutation-receipt.json',ex)
            v.reseal_derived_prefix(probe,'r01',['quark'],rt)
            response=v.audit_reduction_response(mutation,rt,probe);write(probe/'response-receipt.json',response)
            if read(probe/'reduction-response.json')['jobs'][0]['identity_rules']!=1:raise ValueError('regression did not exercise implicit master identity')
            probes.append({'certificate':jobs[0]['probe_certificate'],'numerator':int(factor.p),'denominator':int(factor.q)})
        checks={'volume':str(volume/'masters.wl'),'null':str(null/'masters.wl'),'certificate':str(cert),'probes':probes,
                'native_output':str(dest/'checks.wl'),'output':str(dest/'checks.json')}
        kernel(ROOT/'native_regression_checks.wls',checks,'COLLINS_RU_REGRESSION_CHECKS',rt,dest/'checks-execution')
        checked=read(dest/'checks.json')
        if checked.get('status')!='PASS' or checked.get('checks')!=10 or checked.get('residuals')!=['0']*10:raise ValueError('incomplete native regression checks')
        result.update(status='NATIVE_REGRESSION_PASS',exact_residuals=10,negative_period_control='EXPECTED_REJECTION',complete_map_probe_seeds=[1729,92741])
    except Exception as exc:result.update(error_result(exc)[0])
    try:
        if snapshot(prod)!=sources or runtime(a.repo)!=rt or release_integrity()!=release:raise ValueError('native regression changed protected inputs')
    except Exception as exc:result.update(status='FAIL',preservation_error=str(exc))
    result['evidence_snapshot']=snapshot(dest);write(dest/'result.json',result)
    print(json.dumps({k:val for k,val in result.items() if k not in ('runtime','evidence_snapshot')},indent=2))
    return 0 if result['status']=='NATIVE_REGRESSION_PASS' else 2 if result['status']=='BLOCKED' else 1

def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--repo',default='/bigTMD');p.add_argument('--output',required=True)
    try:return regression(p.parse_args())
    except Exception as exc:r,c=error_result(exc);print(json.dumps(r));return c
if __name__=='__main__':raise SystemExit(main())
