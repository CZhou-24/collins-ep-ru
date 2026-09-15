"""SIDIS source pin and evidence ledger checks, separate from equality checks."""
from pathlib import Path
from support import read,sha,relative_file
ROOT=Path(__file__).resolve().parent
LINKS={'common/d13_result/native_matching.wl','common/d13_result/finite_matching.json',
       'common/d14_result/normalization_derivation.wl','common/d14_result/scheme_derivation.wl',
       'common/d14_result/regulated_scheme.wl','common/d14_result/scheme_conversion.json',
       'common/d14_result/proofs.wl'}

def check_conventions(run):
    lock=read(ROOT/'sidis_convention_lock.json')
    for name,rec in lock['files'].items():
        if sha(relative_file(ROOT/'reference_sources/sidis',name))!=rec['sha256']:
            raise ValueError('Pinned SIDIS source changed: '+name)
    ledger=read(relative_file(run,'common/d14_result/conventions.json'))
    if set(ledger)!={'schema','baseline_commit','baseline_files','rows'} or ledger['schema']!=1:
        raise ValueError('Wrong SIDIS convention ledger schema')
    if ledger['baseline_commit']!=lock['commit'] or ledger['baseline_files']!={k:v['sha256'] for k,v in lock['files'].items()}:
        raise ValueError('SIDIS convention baseline changed')
    if not isinstance(ledger['rows'],list):raise ValueError('Convention rows must be a list')
    rows={}
    keys={'id','status','baseline_definition','production_definition','reference_definition','evidence','note'}
    for row in ledger['rows']:
        if not isinstance(row,dict) or set(row)!=keys or row['id'] in rows:raise ValueError('Malformed or duplicated convention row')
        rows[row['id']]=row
    if set(rows)!=set(lock['rows']):raise ValueError('Missing/extra convention obligation')
    checks=[];seen=set()
    for name,kind in lock['rows'].items():
        r=rows[name]
        for field in ('baseline_definition','production_definition','reference_definition','note'):
            if not isinstance(r[field],str) or not r[field].strip():raise ValueError('Empty convention definition: '+name)
        if not isinstance(r['evidence'],dict) or not r['evidence']:raise ValueError('No convention evidence: '+name)
        for path,digest in r['evidence'].items():
            p=relative_file(run,path)
            if p.stat().st_size==0 or sha(p)!=digest:raise ValueError('Missing/changed convention evidence: '+name)
            seen.add(path)
        status=r['status']
        allowed=('EXPLICIT_EXTENSION',) if kind=='EXPLICIT_EXTENSION' else ('INHERITED','CONVERTED')
        if status=='UNRESOLVED':
            checks.append({'id':'conventions.'+name,'status':'BLOCKED','detail':'Unresolved SIDIS/native/reference map'})
        elif status not in allowed:raise ValueError('Wrong convention classification: '+name)
        else:checks.append({'id':'conventions.'+name,'status':'PASS','detail':'Source-pinned evidence present; mapping correctness requires native proofs and independent source review'})
    if not LINKS<=seen:raise ValueError('Convention evidence must link native matching, conversion proofs, reference packets')
    checks.append({'id':'conventions.baseline','status':'PASS','detail':lock['commit']})
    return checks
