#!/usr/bin/env python3
"""Review the supplied v0.3.2 evidence; never official acceptance.

Optional native execution uses copies of the archived compiled executables.
It does not regenerate diagrams or compile code. The explicit legacy-sum
context is a retrospective Python-version diagnostic, not a release change.
"""
import argparse,collections,hashlib,json,os,shutil,subprocess,sys
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parents[1]))
import madgraph_checks as m
import real_oracle as clifford
from native_evidence import snapshot_derivation_evidence


def digest(p):
    return hashlib.sha256(Path(p).read_bytes()).hexdigest()


def counts(rows):
    return dict(collections.Counter(row['status'] for row in rows))


def legacy_sum(items,start=0):
    total=start
    for item in items:
        total+=item
    return total


def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--bundle',type=Path,required=True)
    p.add_argument('--output',type=Path,required=True)
    p.add_argument('--execute-archived-binaries',action='store_true')
    a=p.parse_args()
    a.output=a.output.resolve();a.output.mkdir(parents=True,exist_ok=False)
    fs=a.bundle.resolve()/'filesystem';s=fs/'Collins-ep-analytic-state-v0.3.2'
    freeze=json.loads((s/'final-source-freeze.json').read_text())
    prod=fs/'bigTMD/collins_ep_analytic'
    for name,expected in freeze['sources'].items():
        path=prod/name
        if path.is_symlink() or not path.resolve().is_relative_to(prod) or digest(path)!=expected:
            raise ValueError('Frozen source mismatch: '+name)
    old=(fs/'Collins-ep-analytic-validation-v0.3.2/madgraph_checks.py').read_text()
    diagnostic=(s/'validator-defects/parameter-card-width/madgraph_checks_format_candidate.py').read_text()
    assert old.count('value:.17e')==1 and old.replace('value:.17e','value:.17g')==diagnostic
    assert Path(m.__file__).read_text()==diagnostic, 'Review must use the exact formatting-only native module'
    result={'scope':'Archive/source review, retrospective arithmetic and optional archived-binary execution; not official acceptance',
            'fresh_compilation':False,'frozen_source_files_checked':len(freeze['sources']),
            'one_line_diagnostic_verified':True,'seeds':[]}
    for seed in (1729,92741):
        ev=s/f'diagnostic-native-format-{seed}'
        req=json.loads((ev/'requests.json').read_text())['rows']
        report=json.loads((s/f'derivation-{seed}.json').read_text())
        sealed=snapshot_derivation_evidence(s/f'derivation-{seed}-evidence')
        assert sealed==report['evidence_files'], 'Official evidence identity mismatch'
        ordinary=m.replay_checks(ev,seed)
        entry={'seed':seed,'official_status':report['status'],'official_counts':counts(report['checks']),
               'official_evidence_identity_matches':True,'current_interpreter_replay':counts(ordinary),
               'current_interpreter_nonpass':[row for row in ordinary if row['status']!='PASS']}
        # Test the suspected cause without reading the stored points as answers.
        # The same independent RNG is retained; only pre-3.12 sum order is reproduced.
        clifford.sum=legacy_sum;m.sum=legacy_sum
        try:
            entry['independent_pre312_seed_points_exact']=m.points(seed)==req
            rows=m.replay_checks(ev,seed)
            entry['retrospective_pre312_replay']=counts(rows)
            entry['retrospective_nonpass']=[row for row in rows if row['status']!='PASS']
        finally:
            del clifford.sum;del m.sum
        assert entry['independent_pre312_seed_points_exact'] and entry['retrospective_pre312_replay']=={'PASS':62}
        if a.execute_archived_binaries:
            native={};checks=[];execution=[]
            original_ev=s/f'derivation-{seed}-evidence/madgraph'
            original_requests=json.loads((original_ev/'requests.json').read_text())['rows']
            assert original_requests==req
            response=json.loads((original_ev/'candidate-response.json').read_text())
            actual=m.validate_candidate(response,req)
            for process in m.PROCESSES:
                src=original_ev/process
                dst=a.output/f'native-{seed}'/process
                shutil.copytree(src/'standalone',dst/'standalone',symlinks=True)
                subdirs=list((dst/'standalone/SubProcesses').glob('P*'))
                assert len(subdirs)==1
                sub=subdirs[0];exe=sub/'check';before=digest(exe)
                data=(src/'momenta.txt').read_text()
                oldrun=subprocess.run([str(exe)],cwd=sub,input=data,text=True,capture_output=True,timeout=30)
                (dst/'original.stdout').write_text(oldrun.stdout);(dst/'original.stderr').write_text(oldrun.stderr)
                assert oldrun.returncode!=0 and 'Bad real number' in oldrun.stderr
                card=dst/'standalone/Cards/param_card.dat';oldcard=card.read_text()
                card.write_text(m.parameter_card(oldcard))
                newrun=subprocess.run([str(exe)],cwd=sub,input=data,text=True,capture_output=True,timeout=30)
                (dst/'corrected.stdout').write_text(newrun.stdout);(dst/'corrected.stderr').write_text(newrun.stderr)
                assert newrun.returncode==0, newrun.stderr
                assert digest(exe)==before
                selected=[row for row in req if row['process']==process]
                parsed=m.parse_native(newrun.stdout,selected)
                for index,request in enumerate(selected,1):
                    value=parsed[index];checks.extend(m.native_comparisons(request,value))
                    native[request['id']]={key:value[key] for key in (('UU',) if process=='real_eg' else ('UU','UT'))}
                execution.append({'process':process,'executable_sha256':before,'executable_unchanged':True,
                    'original_exit':oldrun.returncode,'corrected_exit':newrun.returncode,
                    'old_card_sha256':hashlib.sha256(oldcard.encode()).hexdigest(),
                    'corrected_card_sha256':digest(card),
                    'corrected_stdout_sha256':digest(dst/'corrected.stdout')})
            checks.extend(m.candidate_comparisons(req,actual,native))
            assert len(checks)==60 and counts(checks)=={'PASS':60}
            residuals=[row['detail']['absolute_error'] for row in checks if 'absolute_error' in row.get('detail',{})]
            entry['archived_binary_execution']={'processes':execution,'comparison_counts':counts(checks),
                'maximum_candidate_absolute_residual':max(residuals),'comparisons':checks,
                'kinematics':'Original recorded phase-space points; no regeneration/compilation or new candidate extraction'}
        result['seeds'].append(entry)
    (a.output/'review.json').write_text(json.dumps(result,indent=2,sort_keys=True)+'\n')
    print(json.dumps({'status':'SCOPED_REVIEW_PASS','official_acceptance':'STILL_BLOCKED',
        'source_files':result['frozen_source_files_checked'],
        'retrospective_replay':[x['retrospective_pre312_replay'] for x in result['seeds']],
        'archived_binary_comparisons':[x.get('archived_binary_execution',{}).get('comparison_counts') for x in result['seeds']],
        'maximum_residuals':[x.get('archived_binary_execution',{}).get('maximum_candidate_absolute_residual') for x in result['seeds']]},indent=2))


if __name__=='__main__':
    main()
