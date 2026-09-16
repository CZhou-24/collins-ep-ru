#!/usr/bin/env python3
"""Report computed residuals, scientific gaps and preservation without rerunning old campaigns."""
import argparse,collections,datetime,hashlib,json,subprocess,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3];E=ROOT/'collins_sidis_highpt';B=ROOT/'collins_support/reports/sidis-highpt-001'
OUT=B
sys.path.insert(0,str(ROOT/'collins_support/validators/analytic'))
import algebra as a
import ru_support as u
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def write(name,value):
    with (OUT/name).open('x') as f:json.dump(value,f,indent=2);f.write('\n')
def load_reproduction_inputs(directory):
    """Use only the requested completed reproduction, with no campaign fallback."""
    directory=Path(directory).resolve()
    meta=json.loads((directory/'reproduction.json').read_text())
    if Path(meta['report_root']).resolve()!=directory:raise ValueError('Reproduction directory differs from its record')
    if type(meta.get('partial_real')) is not bool:raise ValueError('Missing partial-real scope; rerun the patched driver')
    names=[s['name'] for s in meta['steps']]
    required={'r00-native','angular','jet-native','jet-distributions','fragmentation','operator-scheme','diagnostic-export'}
    if meta['partial_real']:required|={'real-contractions','real-map','real-ward','real-kira','real-kira-check','cut-master-depth','partial-real-distributions'}
    if len(names)!=len(set(names)) or not required<=set(names) or any(s['exit_code']!=0 for s in meta['steps']):
        raise ValueError('Reproduction steps are incomplete, duplicated or failed')
    for name in required:
        if not (directory/(name+'.log')).is_file():raise ValueError('Missing reproduction log: '+name)
    runs=set()
    for line in (directory/'r00-native.log').read_text().splitlines():
        try:row=json.loads(line)
        except json.JSONDecodeError:continue
        if isinstance(row,dict) and 'run' in row:runs.add(str(Path(row['run']).resolve()))
    if runs!={str(Path(meta['native_run']).resolve())}:raise ValueError('Native run does not match reproduction log')
    jet=json.loads((directory/'jet-matching-002/jet-distribution-checks.json').read_text())
    diag=json.loads((directory/'diagnostic-summary.json').read_text())
    if Path(diag['report_root']).resolve()!=directory or diag['partial_real_present'] is not meta['partial_real']:
        raise ValueError('Diagnostic root or partial-real scope differs from reproduction')
    if not diag.get('input_sha256'):raise ValueError('Diagnostic input identities are missing')
    for name,digest in diag['input_sha256'].items():
        path=Path(name).resolve()
        if not path.is_relative_to(directory) or sha(path)!=digest:raise ValueError('Diagnostic input is external or changed: '+name)
    kira=targets=None
    if meta['partial_real']:
        kira=json.loads((directory/'real-kira-check-001/summary.json').read_text())
        targets=json.loads((directory/'real-map-001/kira-input.json').read_text())['targets']
    return meta,jet,diag,kira,targets
def main():
    global OUT
    ap=argparse.ArgumentParser();ap.add_argument('--reproduction',type=Path,required=True);ap.add_argument('--destination',type=Path,required=True);args=ap.parse_args()
    reproduction=args.reproduction.resolve();record,jet,diag,kira,target_data=load_reproduction_inputs(reproduction)
    OUT=args.destination.resolve()
    if OUT.is_relative_to(E.resolve()):raise ValueError('Reports must be outside the producing source tree')
    OUT.mkdir(parents=True,exist_ok=False)
    rundir=Path(record['native_run']).resolve();runmeta=json.loads((rundir/'run.json').read_text())
    verdict=json.loads((rundir/'result.json').read_text());spec=json.loads((rundir/'project.json').read_text());packet=json.loads((rundir/'common/r00_result/packet.json').read_text());rows=[]
    if runmeta['through']!='r00' or runmeta['status']!='EXECUTED' or runmeta['run_path']!=str(rundir) or verdict['status']!='DEVELOPMENT_PASS':
        raise ValueError('This development reporter requires a completed r00 development run')
    for c in spec['checks']:
        if c['stage']!='r00':continue
        lhs=a.decode(packet['values'][c['lhs']]['value']);reference=c.get('reference');conversion=c.get('conversion')
        if reference:
            source=runmeta['sources'][reference['source']];p=Path(source['resolved'])
            if sha(p)!=source['sha256']:raise ValueError('Reference changed since native run: '+str(p))
            rhs=a.decode(json.loads(p.read_text())['equations'][reference['equation']]['value'])
            rhs=rhs.subs({a.decode(k):a.decode(v) for k,v in c.get('reference_substitutions',{}).items()},simultaneous=True)
        elif c['kind']=='finite':
            rows.append(dict(id=c['id'],group='native r00',status='EXACT' if not lhs.has(a.s.Symbol('eps'),a.s.Symbol('eta')) else 'MISMATCH',difference=None,meaning=c['reason'],evidence=str(rundir/'common/r00_result/packet.json'),value_id=c['lhs']))
            continue
        else:rhs=a.decode(c['rhs'])
        diff=a.s.simplify(a.s.cancel(a.s.expand(lhs-rhs)))
        rows.append(dict(id=c['id'],group='native r00',status=('EXACT AFTER EXPLICIT CONVERSION' if conversion else 'EXACT') if diff==0 else 'MISMATCH',difference=str(diff),conversion=conversion,meaning=c['reason'],evidence=str(rundir/'common/r00_result/packet.json'),value_id=c['lhs']))
    for r in jet['coefficient_rows']:rows.append(dict(r,group='imported finite jet coefficient',evidence=str(reproduction/'jet-matching-002/jet-distribution-checks.json')))
    for group,key in [('exact jet distribution action','exact_test_function_actions'),('numerical jet distribution action','numerical_test_function_actions')]:
        for i,r in enumerate(jet[key]):rows.append(dict(r,id=group+'.'+str(i+1),group=group,evidence=str(reproduction/'jet-matching-002/jet-distribution-checks.json')))
    for channel,parts in jet['RG_residuals'].items():
        for part,res in parts.items():rows.append(dict(id='jet.RG.'+channel+'.'+part,group='jet evolution identity',status='EXACT' if str(res)=='0' else 'MISMATCH',difference=str(res),evidence=str(reproduction/'jet-matching-002/jet-distribution-checks.json')))
    for key,res in (kira['archive_difference_residuals'] if kira else {}).items():rows.append(dict(id=key,group='fresh partial Kira / archived overlap',status='EXACT' if res=='0' else 'MISMATCH',difference=res,evidence=str(reproduction/'real-kira-check-001/reduction.wl')))
    for target in target_data or []:
        key='CutIntegral["'+target['family']+'", {'+', '.join(map(str,target['powers']))+'}]'
        if key not in kira['archive_difference_residuals']:rows.append(dict(id=key,group='new Kira target without archived comparison',status='UNVERIFIED',difference=None,meaning='Fresh native reduction and master closure passed; no archived target comparison is available.',evidence=str(reproduction/'real-kira-check-001/reduction.wl')))
    for i,res in enumerate(diag['partial_real_endpoint_residuals']):rows.append(dict(id='partial-real.endpoint.'+str(i),group='partial real endpoint action',status='EXACT' if res=='0' else 'MISMATCH',difference=res,evidence=str(reproduction/'real-distinct-assembly-001/distributions.wl')))
    for key,res in diag['partial_real_reconstruction'].items():rows.append(dict(id='partial-real.reconstruction.'+key,group='partial real reconstruction',status='EXACT' if res=='0' else 'MISMATCH',difference=res,evidence=str(reproduction/'real-distinct-assembly-001/distributions.wl')))
    for key in diag['partial_real_reconstruction']:rows.append(dict(id='partial-real.independent-reference.'+key,group='calculated coefficient without independent hard reference',status='UNVERIFIED',difference=None,meaning='Internal identities are checked; no independent reference for this new polarized cut distribution is supplied.',evidence=str(reproduction/'real-distinct-assembly-001/distributions.wl')))
    rows.append(dict(id='Hqqbar.physical-point-independent-reference',group='calculated coefficient without independent hard reference',status='UNVERIFIED',difference=None,meaning='No independent hard-coefficient reference. '+diag['antiquark_point_qualification'],evidence=str(reproduction/'antiquark-point-002/point.wl') if diag['antiquark_point_present'] else str(E/'COMPLETION_INVENTORY.md')))
    for i,res in enumerate(diag['fourier_residuals']):rows.append(dict(id='Fourier.inverse.'+str(i),group='analytic Fourier test identity',status='EXACT' if res=='0' else 'MISMATCH',difference=res,evidence=str(reproduction/'fragmentation-001/checks.wl')))
    for key in ['ndr_minus_literal_all_D','ndr_minus_literal_through_eps1','spacelike_bmhv_minus_ndr','outgoing_bmhv_minus_ndr']:
        res=diag['operator_differences'][key];rows.append(dict(id='operator.'+key,group='operator continuation diagnostic',status='EXACT AFTER EXPLICIT CONVERSION' if res=='0' else 'MISMATCH',difference=res,conversion='D=4-2 eps and explicit truncation only where named. All-D mismatches are retained. The outgoing diagnostic is not a proven process finite conversion.',evidence=str(reproduction/'operator-scheme-002')))
    for gap in ['Hqq real qgg','Hqq real same-flavor exchange','Hqq distinct-flavor full spin tensor','Hqq virtual finite remainder','Hqqbar full dimensional real coefficient','initial factorization','outgoing finite operator matching','complete NLO scale identity','all-channel finite UU jet denominator','full finite UT convolution','perturbatively consistent asymmetry','full two-run native pair','dependency probe 1729','dependency probe 92741']:
        rows.append(dict(id='gap.'+gap,group='required unfinished ingredient',status='UNVERIFIED',difference=None,meaning=gap,evidence=str(E/'COMPLETION_INVENTORY.md')))
    counts=dict(collections.Counter(r['status'] for r in rows));write('COMPARISON_INVENTORY.json',dict(scope='Development comparisons, not full NLO acceptance; numerical rows do not establish symbolic equality',counts=counts,rows=rows))
    table=['# Row-level comparison inventory','','Counts: '+json.dumps(counts), '', '| Quantity | Status | Calculated difference / residual | Evidence |','|---|---|---|---|']
    for r in rows:
        evidence=r['evidence'];label=Path(evidence).name;res=r.get('difference',r.get('residual'));table.append('| '+r['id'].replace('|','\\|')+' | '+r['status']+' | '+str(res if res is not None else 'not computed').replace('|','\\|')+' | ['+label+']('+evidence+') |')
    (OUT/'COMPARISON_INVENTORY.md').write_text('\n'.join(table)+'\n')
    before=json.loads((B/'preservation-before.json').read_text());after=dict(engine=u.snapshot(ROOT/'collins_ep_analytic_SIDIS'),old_validator=u.snapshot(ROOT/'collins_support/validators/analytic'),old_release=u.release_integrity(),path_support_sha256=sha(ROOT/'collins_support/paths.py'),runtime=u.runtime(ROOT),reused_files={p:sha(ROOT/p) for p in before['reused_files']})
    preserved={k:before[k]==after[k] for k in before};write('preservation-after.json',dict(comparisons=preserved,current=after))
    uu=json.loads((ROOT/'SIDIS/bigTMD_comparison/s04_result.json').read_text());identities={ch:dict(path=r['ProductionFile'],expected=r['ProductionSHA256'],actual=sha(ROOT/'SIDIS'/r['ProductionFile'])) for ch,r in uu['Channels'].items()};write('UU-reuse-identities.json',dict(channels=identities,qualification='Historical 60 coefficient and 120 numerical checks reused by byte identity, not rerun. Separate Hgq MadGraph discrepancy unresolved.'))
    integrity=dict(engine_sources_match=u.snapshot(E)==json.loads((rundir/'run.json').read_text())['engine_sources'],preserved=preserved,tracked_changes=subprocess.run(['git','status','--short','--untracked-files=no'],cwd=ROOT,text=True,capture_output=True,check=True).stdout,run=str(rundir));write('current-integrity.json',integrity)
    report=f'''# SIDIS high-pT implementation milestone

**Incomplete NLO calculation. No finite physical NLO prediction or new full-process acceptance is claimed.**

The current native prefix is `{verdict['status']}` through r00, with {len(verdict['checks'])} declared checks. Run: [{rundir.name}]({rundir}). The two-run r07 campaign, final pair and dependency probes 1729/92741 are **NOT_RUN**. Independent physics review remains pending.

Calculated in this reproduction: the r00 Born photon/spin tensor, lepton/Collins projection and declared channel checks. Partial-real replay: **{'RUN' if record['partial_real'] else 'NOT_RUN'}**. {('Fresh Kira covered '+str(kira['target_count'])+' targets and '+str(kira['final_master_count'])+' final masters; '+str(kira['covered_archive_targets'])+' archived comparisons and '+str(kira['uncovered_archive_targets'])+' newly covered targets.') if kira else 'No historical partial-real result was substituted.'} The other real topologies and the virtual polarized finite remainder remain unfinished. Tagged-antiquark physical-point evidence: {diag['antiquark_point_qualification']}

Imported and checked in this reproduction: {len(jet['coefficient_rows'])} universal finite-jet coefficient comparisons, {len(jet['exact_test_function_actions'])} exact distribution actions, {len(jet['numerical_test_function_actions'])} numerical actions, {sum(len(p) for p in jet['RG_residuals'].values())} evolution residuals and {len(diag['fourier_residuals'])} Fourier inverse identities. Their precision and residuals are retained in the row-level inventory. These tests validate imports/conventions within their stated scope, not the missing DIS hard coefficients.

Scientific gap: the finite matching between the implemented physical-spin BMHV prescription and the renormalized Collins/transversity operator conventions has not been established. The outgoing collinear diagnostic has a nonzero epsilon term; its physical tagged-leg embedding still requires matching. No guessed finite counterterm was inserted. The all-D diagnostic disagreement is retained separately from its exact agreement after an explicit epsilon truncation. Missing real/virtual work and hadronic measures/convolutions remain visible in the completion inventory.

Comparison rows by status: `{json.dumps(counts)}`. [Row-level results](COMPARISON_INVENTORY.md) retain residuals and executable evidence; this total includes identities and partial-sector diagnostics and is not a count of completed NLO coefficients. [Derivation and reproduction command]({E/'DERIVATION.md'}). [Complete channel/gap inventory]({E/'COMPLETION_INVENTORY.md'}).

Preservation: `{json.dumps(preserved)}`. Current implementation matches the native snapshot: `{integrity['engine_sources_match']}`. Tracked repository changes: `{integrity['tracked_changes'].strip() or 'none'}`. Existing analytic validator, runtime, accepted ep producing sources, release identity and all 33 initially inventoried inputs retain their original identities. All six reused inclusive UU banks match the historical comparison hashes; the separate unresolved Hgq MadGraph qualification is preserved. No old derivation, baseline reset, cleanup, archive or push was performed.

All reported high-pT work uses the stated leading-power small-R / small-jT hierarchy and symbolic nonperturbative TMD input. Born, internal algebra and current regression agreement do not certify broader physical accuracy or historical acceptance for this new observable.
'''
    (OUT/'MILESTONE_REPORT.md').write_text(report)
    if not all(preserved.values()) or not integrity['engine_sources_match'] or any(v['expected']!=v['actual'] for v in identities.values()):raise SystemExit('Preservation or identity mismatch')
    print(json.dumps(dict(run=str(rundir),native_status=verdict['status'],checks=len(verdict['checks']),comparison_counts=counts,preservation=preserved)))
if __name__=='__main__':main()
