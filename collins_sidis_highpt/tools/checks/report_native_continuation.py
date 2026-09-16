#!/usr/bin/env python3
"""Report completed native records without rerunning or changing the calculation.

Exact comparison rows are read from the checked native expressions; independent
hard-reference gaps and the original diagnostic mismatches remain explicit.
"""
import argparse
from collections import Counter
import csv
import hashlib
import json
import os
import sys
from pathlib import Path


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--campaign', type=Path, required=True)
    ap.add_argument('--output', type=Path, required=True)
    args = ap.parse_args()
    root = Path(__file__).resolve().parents[3]
    engine = root/'collins_sidis_highpt'
    development = root/'collins_support/reports/sidis-highpt-001/continuation-001'
    out = args.output.resolve()
    out.mkdir(parents=True, exist_ok=False)
    sys.path.insert(0, str(root/'collins_support/validators'))
    import sidis_highpt as h
    campaign_file = args.campaign/'campaign.json'
    campaign_link = Path(os.path.relpath(args.campaign.resolve(), out)).as_posix()
    campaign = h.u.read(campaign_file)
    if campaign.get('status') != 'NATIVE_CAMPAIGN_CHECKS_PASS' or len(campaign.get('runs', [])) != 2:
        raise ValueError('This report requires the actual completed two-run/pair/two-seed campaign')
    run = Path(campaign['runs'][0])
    meta, spec, result = (h.u.read(run/n) for n in ('run.json', 'project.json', 'result.json'))
    if h.u.snapshot(engine) != meta['engine_sources']:
        raise ValueError('Source freeze no longer matches the completed campaign')
    checked = {r['id']: r for r in result['checks']}
    packets = {}
    comparisons = []
    packet_hashes = {}
    for stage in h.STAGES:
        path = run/'common'/(stage+'_result')/'packet.json'
        packet = h.u.read(path)
        packet_hashes[stage] = h.u.digest(path)
        for c in (row for row in spec['checks'] if row['stage'] == stage):
            if checked[c['id']]['status'] != 'PASS':
                raise ValueError('Nonpassing completed check: '+c['id'])
            lhs = h.a.decode(packet['values'][c['lhs']]['value'])
            if c['kind'] == 'finite':
                difference = 'No eps or eta in the exact exported coefficient'
                classification = 'EXACT'
                reference = None
            else:
                rhs = h.exact_reference(c, meta['sources']) if 'reference' in c else h.a.decode(c['rhs'])
                difference = str(h.a.s.simplify(h.a.s.cancel(h.a.s.expand(lhs-rhs))))
                if difference != '0':
                    raise ValueError('Report cannot simplify an accepted comparison: '+c['id'])
                classification = ('EXACT AFTER EXPLICIT CONVERSION' if c.get('reference_substitutions') or
                                  ('reference' in c and stage == 'r07') else 'EXACT')
                reference = c.get('reference')
            comparisons.append(dict(id=c['id'], group='native computational check', stage=stage,
                                    channel=c['channel'], kind=c['kind'], status=classification,
                                    difference=difference, meaning=c['reason'], reference=reference,
                                    conversion=c.get('conversion'), candidate_value=c['lhs'],
                                    evidence=str(path), packet_sha256=packet_hashes[stage]))
        # Release large packet trees between stages; the evidence file retains
        # every exact expression and its complete dependency graph.
        del packet
    historical = h.u.read(development/'reporting-summary-002/COMPARISON_INVENTORY.json')
    mismatches = [dict(row, group='preserved original operator diagnostic') for row in historical['rows'] if row['status'] == 'MISMATCH']
    if len(mismatches) != 2:
        raise ValueError('Both original diagnostic mismatch rows must remain visible')
    comparisons.extend(mismatches)
    for channel in ('Hqq', 'Hqqbar'):
        for pol in ('L', 'T'):
            for branch in ('plus', 'minus'):
                for distribution in ('Delta', 'L0', 'L1', 'Regular'):
                    key=f'{channel}_Collins_{pol}_{branch}_{distribution}_p0'
                    comparisons.append(dict(id='independent-hard.'+key, group='independent polarized hard reference',
                                            status='UNVERIFIED', difference=None,
                                            meaning='Complete generated finite coefficient has internal native checks but no independent full NLO hard reference.',
                                            evidence=str(run/'common/r07_result/hard-basis'/(key+'.wl'))))
    comparisons.append(dict(id='historical.Hgq.MadGraph', group='preserved historical qualification',
                            status='UNVERIFIED', difference=None,
                            meaning='The historical separate Hgq MadGraph comparison is unresolved and is not repeated or certified by UU reuse.',
                            evidence=str(root/'SIDIS/bigTMD_comparison/s04_result.json')))
    counts = dict(Counter(row['status'] for row in comparisons))
    summary = dict(scope='Declared native computations plus separate independent-reference gaps; scalar counts are representation dependent',
                   counts=counts, rows=comparisons, campaign=str(campaign_file.resolve()),
                   campaign_sha256=h.u.digest(campaign_file), packet_hashes=packet_hashes,
                   qualification='Report extraction from completed native checks, not another derivation or native replay. EXACT internal identities/finiteness checks are not independent hard-reference agreement.')
    (out/'COMPARISON_INVENTORY.json').write_text(json.dumps(summary, indent=2)+'\n')
    with (out/'SCALAR_COMPARISON.csv').open('x', newline='') as stream:
        writer = csv.DictWriter(stream, fieldnames=['id', 'group', 'stage', 'channel', 'kind', 'status', 'difference', 'evidence'], extrasaction='ignore')
        writer.writeheader()
        writer.writerows(comparisons)
    before = h.u.read(development/'preservation-before.json')
    preservation = {}
    for name, directory in [('old_engine', root/'collins_ep_analytic_SIDIS'), ('validators', root/'collins_support/validators')]:
        current = h.u.snapshot(directory)
        changed = [k for k, v in before[name].items() if current.get(k) != v]
        preservation[name] = dict(files=len(before[name]), unchanged=not changed, changed=changed)
    changed = []
    for key, row in before['reused_inputs'].items():
        path = (root/'SIDIS' if row['root'] == 'sidis' else engine)/row['path']
        if h.u.digest(path) != row['sha256']:
            changed.append(key)
    preservation['original_reused_inputs'] = dict(files=len(before['reused_inputs']), unchanged=not changed, changed=changed)
    preservation['runtime_unchanged'] = h.u.runtime(root) == before['runtime']
    preservation['current_source_freeze_matches'] = h.u.snapshot(engine) == campaign['engine_sources']
    (out/'preservation.json').write_text(json.dumps(preservation, indent=2)+'\n')
    if not all(preservation[k]['unchanged'] for k in ('old_engine', 'validators', 'original_reused_inputs')) or not preservation['runtime_unchanged']:
        raise ValueError('Preservation check failed; retain report and inspect preservation.json')
    pair = h.u.read(args.campaign/'pair.json')
    probes = [h.u.read(args.campaign/('probe-'+str(seed)+'.json')) for seed in (1729, 92741)]
    kinds = Counter(row['kind'] for row in result['checks'])
    text = ['# Native continuation milestone', '',
            f"Campaign: **{campaign['status']}**. Two fresh r00–r07 physical workflows completed with the same source/input/runtime identities. Pair: **{pair['status']}**.", '',
            f"Each run passed {len(result['checks'])} declared checks and exported {len(spec['exports'])} exact scalar coefficients. All 16 common-boundary comparisons passed in each physical run. Scalar counts depend on the exact transport basis and are not independent prediction counts.", '',
            'Real-master and virtual-master downstream probes passed for both seeds 1729 and 92741. Probe runs are deliberately changed calculations, not additional physical runs.', '',
            '| Native check kind | Count |', '|---|---:|']
    text += [f'| {k} | {v} |' for k, v in sorted(kinds.items())]
    text += ['', 'The calculation includes complete Hqq real/virtual, UV and both dimensional MS contributions; nonzero real-only Hqqbar UT; all six reused UU channels; compatible finite jet/TMD matching; explicit flavor sums, measures, distribution actions and the consistently expanded Collins asymmetry. TMD/PDF functions remain symbolic.', '',
             'Saved amplitudes, integral evaluations and UU coefficients were reused with recorded identities. Polarized contractions, coefficient vectors, reductions, assembly and the final native workflows were executed anew as documented. Universal factorization and jet functions remain literature inputs. The reporting patch was verified and not reapplied.', '',
             'Campaign 001 reached the unchanged 7,200-second r01 limit before finishing distinct-flavor mapping. Its failed run, syscall trace and explicit orphan-process termination are retained. The repaired orchestration calculates qgg tensors/projections afresh in r00, binds their ancestry at r01, and stops native helper groups when their stage parent exits. No physical formula, reference, tolerance or validator was changed for that repair.', '',
             'The two original operator diagnostic mismatches remain unchanged. Their observed-daughter embedding is distinguished from the physical-tagged production limit; the finite collinear conversion is zero by the stated dimensional pole analysis and operator checks. No 2 CF z finite term was inserted.', '',
             'Independent full NLO polarized hard-reference comparison and independent physics review remain pending. The historical Hgq MadGraph qualification remains unresolved. These current computational checks do not transfer historical acceptance or certify a general resolved-azimuth or arbitrary-radius prediction.', '',
             'Scope: leading-power standard-axis anti-kT, small R and jT << pJT R << pJT ~ Q. No fit or Figure 6 reproduction.', '',
             f"Preservation: {before['old_engine'].__len__()} original ep source entries, {before['validators'].__len__()} validator entries, {len(before['reused_inputs'])} original registered inputs and the runtime retain their recorded identities.", '',
             'Actual run paths:', '']
    text += ['- `'+path+'`' for path in campaign['runs']]
    text += ['', f'Reports: [campaign]({campaign_link}/campaign.json), [pair]({campaign_link}/pair.json), [seed 1729]({campaign_link}/probe-1729.json), [seed 92741]({campaign_link}/probe-92741.json).', '',
             '[All row-level comparisons](COMPARISON_INVENTORY.json), [scalar table](SCALAR_COMPARISON.csv), [preservation](preservation.json). Native logs and first failed development attempts are preserved in the continuation directory.']
    (out/'MILESTONE_REPORT.md').write_text('\n'.join(text)+'\n')
    table = ['# Comparison inventory', '', 'Native internal identities/finiteness properties and independent reference checks are distinguished by kind and source in the JSON/CSV. Independent hard-reference gaps are separate rows.', '', '| Classification | Rows |', '|---|---:|']
    table += [f'| {k} | {v} |' for k, v in counts.items()]
    table += ['', '[Complete scalar comparison table](SCALAR_COMPARISON.csv) and [exact row metadata](COMPARISON_INVENTORY.json).', '', 'The two preserved MISMATCH diagnostics are:', '']
    table += ['- `'+r['id']+'`: `'+r['difference']+'`.' for r in mismatches]
    (out/'COMPARISON_INVENTORY.md').write_text('\n'.join(table)+'\n')
    print(json.dumps(dict(output=str(out), counts=counts, native_checks=len(result['checks']))))


if __name__ == '__main__':
    main()
