#!/usr/bin/env python3
"""Read-only archive replay, never native execution or final acceptance."""
import argparse,collections,hashlib,json,sys
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parents[1]))
import derivation_checks as dc
from native_evidence import snapshot_derivation_evidence

p=argparse.ArgumentParser(description=__doc__)
p.add_argument('--bundle',type=Path,required=True,help='Extracted archive root containing filesystem/')
a=p.parse_args()
b=a.bundle.resolve()/"filesystem"
s=b/"Collins-ep-analytic-state-v0.3.1"
prod=b/"bigTMD/collins_ep_analytic"
freeze=json.loads((s/"final-source-freeze-v2.json").read_text())
for name,expected in freeze["sources"].items():
    path=prod/name
    if path.is_symlink() or not path.resolve().is_relative_to(prod.resolve()):
        raise ValueError('Unsafe frozen source path: '+name)
    if hashlib.sha256(path.read_bytes()).hexdigest()!=expected:
        raise ValueError('Frozen source changed: '+name)
run=s/"final-acceptance-v2/runs/20260913T021432Z-041186e849a0"
results=[]
for seed in (1729,92741):
    ev=s/f"final-acceptance-v2/derivation-{seed}-evidence"
    captured=snapshot_derivation_evidence(ev)
    links=[entry for entry in captured['files'].values() if entry['kind']=='symlink']
    replay=dc.replay_checks(run,ev/"derivation",seed)
    stored={}
    for name in ("derivation/derivation_checks.json","assembly.json"):
        saved=json.loads((ev/name).read_text())
        stored[name]=dict(collections.Counter(row['status'] for row in saved['checks']))
    results.append({'seed':seed,'captured_entries':len(captured['files']),
        'links':len(links),'dangling':sum(x['target_kind']=='missing' for x in links),
        'arithmetic_replay':dict(collections.Counter(row['status'] for row in replay)),
        'nonpass':[row for row in replay if row['status']!='PASS'],
        'stored_component_counts':stored})
receipt={'scope':'Read-only saved arithmetic and evidence identity; no native engines executed',
         'frozen_source_files_checked':len(freeze['sources']),'results':results}
print(json.dumps(receipt,indent=2,sort_keys=True))
raise SystemExit(1 if any(row['nonpass'] for row in results) else 0)
