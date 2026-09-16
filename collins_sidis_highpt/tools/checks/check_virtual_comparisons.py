#!/usr/bin/env python3
"""Focused r06 packet/check replay on saved certificates, never native acceptance.

Reads a successful original run; writes copies into a new external report
directory. No native producer, Kira, master mutation, full arithmetic audit,
or workflow execution is launched. Nonzero cases alter only test copies.
"""
import argparse
import hashlib
import json
import os
from pathlib import Path
import shutil
import signal
import subprocess
import sys

ROOT=Path(__file__).resolve().parents[3]
ENGINE=ROOT/'collins_sidis_highpt'
sys.path.insert(0,str(ROOT/'collins_support/validators'))
sys.path.insert(0,str(ENGINE/'tools/pipeline'))
import sidis_highpt as h
from native_project_spec import virtual_comparison_checks

def write(p,value):p.write_text(json.dumps(value,indent=2)+'\n')

def main():
    ap=argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--run',type=Path,required=True)
    ap.add_argument('--output',type=Path,required=True)
    args=ap.parse_args();run=args.run.resolve();out=args.output.resolve()
    if not out.is_relative_to(ROOT/'collins_support/reports') or out.is_relative_to(run):
        raise ValueError('Use a new external collins_support/reports/ directory')
    out.mkdir(parents=True,exist_ok=False)
    inputs=run/'common/r06_result'
    receipt=json.loads((run/'receipts/r06.json').read_text())
    baseline=json.loads((run/'run.json').read_text())
    checks=virtual_comparison_checks();expected={r['lhs'] for r in checks}
    assert len(checks)==len(expected)==54
    spec=json.loads((ENGINE/'project.json').read_text())
    assert spec['checks'][-54:]==checks and len(spec['checks'])==16470
    rt=json.loads((ROOT/'collins_ep_analytic_SIDIS/ru_runtime.json').read_text())
    env=dict(os.environ,PYTHONDONTWRITEBYTECODE='1',OPENBLAS_NUM_THREADS='1',OMP_NUM_THREADS='1',MKL_NUM_THREADS='1')
    commands=[];sources={};cases=[]
    def execute(name,script,settings,expected_rc=0):
        cmd=[rt['wolfram_kernel'],'-noprompt','-script',str(script)]
        logfile=out/(name+'.log')
        with logfile.open('x') as stream:
            p=subprocess.Popen(cmd,cwd=ROOT,env=dict(env,**{k:str(v) for k,v in settings.items()}),
                               stdout=stream,stderr=subprocess.STDOUT,start_new_session=True)
            try:rc=p.wait(timeout=90)
            except BaseException:
                os.killpg(p.pid,signal.SIGTERM)
                try:p.wait(timeout=3)
                except subprocess.TimeoutExpired:os.killpg(p.pid,signal.SIGKILL);p.wait()
                raise
        commands.append(dict(name=name,command=cmd,settings={k:str(v) for k,v in settings.items()},
                             exit_code=rc,expected_exit_code=expected_rc,log_sha256=h.u.digest(logfile)))
        write(out/'commands.json',commands)
        assert rc==expected_rc,(name,rc,logfile)
    files=[f'linear-{label}/certificates.wl' for label in ('generic','plus','minus')]+['uv/uv.wl']
    for name in files+['packet-unpartitioned.wl']:
        p=inputs/name;digest=h.u.digest(p)
        assert digest==receipt['tree'][name]['sha256'],name
        sources[name]=dict(path=str(p),sha256=digest,size=p.stat().st_size)
    assert 'SIDIS_LINEAR_CHECK_COMPARISON=\'false\'' in (ENGINE/'tools/pipeline/native_stage_driver.py').read_text()
    for case in ('nominal','nonzero','missing','extra'):
        dest=out/case;dest.mkdir()
        for name in files:
            target=dest/name;target.parent.mkdir(parents=True,exist_ok=True)
            shutil.copy2(inputs/name,target)
        context=dest/'context.json'
        write(context,dict(production=str(ENGINE),output=str(dest),stage='r06',case=case))
        if case!='nominal':
            execute(case+'-fixture',Path(__file__).with_name('prepare_virtual_comparison_case.wls'),
                    dict(SIDIS_REVIEW_CASE_CONTEXT=context))
        execute(case+'-emitter',ENGINE/'tools/pipeline/emit_native_mapping_packet.wls',
                dict(SIDIS_HIGHPT_CONTEXT=context),2 if case in ('missing','extra') else 0)
        if case in ('missing','extra'):
            assert 'complete virtual comparison inventory' in (out/(case+'-emitter.log')).read_text()
            cases.append(dict(case=case,status='PASS',meaning='Malformed inventory rejected by producer'))
            continue
        inspect=dest/'inspect-context.json'
        write(inspect,dict(repo=str(ROOT),packet=str(dest/'packet.wl'),
              original_packet=str(inputs/'packet-unpartitioned.wl'),expected_keys=sorted(expected),
              focused_packet=str(dest/'focused.wl'),summary=str(dest/'unchanged-original.json')))
        execute(case+'-inspect',Path(__file__).with_name('check_virtual_comparison_packet.wls'),
                dict(SIDIS_REVIEW_PACKET_CONTEXT=inspect))
        export=dest/'export-context.json'
        write(export,dict(input=str(dest/'focused.wl'),output=str(dest/'focused.json'),mode='packet'))
        execute(case+'-export',ROOT/'collins_support/validators/analytic/native_reexport.wls',
                dict(COLLINS_RU_REEXPORT=export))
        packet=json.loads((dest/'focused.json').read_text())
        known,_=h.a.evaluate_values(packet,{})
        assert set(known)==expected
        if case=='nominal':
            assert all(v==0 for v in known.values())
            rows=h.run_checks(dict(checks=checks),known,{},'r06',enforce=True)
            assert all(r['status']=='PASS' for r in rows)
            cases.append(dict(case=case,status='PASS',identity_passes=54,integer_zeros=54,
                              meaning='Saved residual serialization/check replay, not recalculation'))
        else:
            changed={f'r06/virtualComparison_{b}_11_LL_m2'+('' if b=='generic' else '_'+b)
                     for b in ('generic','plus','minus')}
            assert {k for k,v in known.items() if v!=0}==changed
            assert all(known[k]==h.a.decode('1/7') for k in changed)
            try:h.run_checks(dict(checks=checks),known,{},'r06',enforce=True)
            except ValueError as exc:rejection=str(exc)
            else:raise AssertionError('Nonzero residual accepted in nominal mode')
            rows=h.run_checks(dict(checks=checks),known,{},'r06',enforce=False)
            assert {r['id'] for r in rows if r['status']=='FAIL'}=={k.replace('/','.')+'.check' for k in changed}
            cases.append(dict(case=case,status='PASS',nominal_rejection=rejection,
                recorded_failures=3,remaining_passes=51,
                meaning='Synthetic residual injection accepted for recording, rejected for nominal enforcement; not a master probe'))
        write(dest/'check-rows.json',rows)
    assert all(h.u.digest(Path(row['path']))==row['sha256'] for row in sources.values())
    write(out/'result.json',dict(status='FOCUSED_CHECKS_PASS',cases=cases,source_files=sources,
          original_run=baseline['run_id'],original_native_checks=16416,new_declared_checks=16470,
          original_inputs_unchanged=True,validator_identity=h.extension_identity(),
          producer_sha256=h.u.digest(ENGINE/'tools/pipeline/emit_native_mapping_packet.wls'),
          generator_sha256=h.u.digest(ENGINE/'tools/pipeline/native_project_spec.py'),
          qualification='Serialization/check replay and synthetic rejection tests only. Full new native run, pair, master probes and independent physics review NOT_RUN.'))
    print(json.dumps(dict(status='FOCUSED_CHECKS_PASS',result=str(out/'result.json'))))

if __name__=='__main__':main()
