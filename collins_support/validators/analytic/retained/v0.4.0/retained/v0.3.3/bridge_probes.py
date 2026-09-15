"""Deliberately altered disposable inputs test the bridge's actual data path.

These are arithmetic dependency probes, never certified physical exports.
Accepted stage files are not modified.
"""
import copy,sys
from pathlib import Path
from algebra import add,mul,rat,sym,check
from assembly_oracle import requests,expected
from support import read,write,execute,relative_file

DELTA=3/7

def mutate(data,kind):
    d=copy.deepcopy(data)
    if kind=='soft':d['operators.json']['renormalized']['soft']=add(d['operators.json']['renormalized']['soft'],rat(3,7))
    elif kind=='hard':d['spacelike_hard_one_loop.json']['expressions']['h1']=add(d['spacelike_hard_one_loop.json']['expressions']['h1'],rat(3,7))
    elif kind=='assembly':d['assembly.json']['expressions']['UU1']=add(d['assembly.json']['expressions']['UU1'],mul(rat(3,7),sym('HUU'),sym('f0'),sym('d0')))
    else:raise ValueError('Unknown probe')
    return d

def target(r,kind):
    v=dict(expected(r))
    if r['kind']=='gaussian':
        v['UU1']+=DELTA*v['UU0']
        if kind!='assembly':v['UT1']+=DELTA*v['UT0']
    elif kind=='soft':v['value']+=DELTA
    elif kind=='assembly':
        p=r['point'];v['value']+=DELTA*p['HUU']*p['f0']*p['d0']
    return v

def probe_requests(seed,kind):
    allreq=requests(seed);out=[next(r for r in allreq if r['kind']=='gaussian')]
    if kind=='soft':out.append(next(r for r in allreq if r['kind']=='coefficient' and r['source']=='operators' and r['path']==['renormalized','soft']))
    if kind=='assembly':out.append(next(r for r in allreq if r['kind']=='coefficient' and r['source']=='assembly' and r['path']==['expressions','UU1']))
    return out

def compare(req,response,nonce,kind):
    if type(response) is not dict or set(response)!={'run_id','status','responses'} or response['run_id']!=nonce or response['status']!='PASS':raise ValueError('Wrong dependency-probe response')
    rows={}
    for row in response['responses']:
        if type(row) is not dict or set(row)!={'id','values'} or row['id'] in rows:raise ValueError('Wrong dependency-probe row')
        rows[row['id']]=row['values']
    if set(rows)!={r['id'] for r in req}:raise ValueError('Missing dependency-probe rows')
    checks=[]
    for r in req:
        v=target(r,kind);got=rows[r['id']]
        if type(got) is not dict or set(got)!=set(v):raise ValueError('Wrong dependency-probe component set')
        for k,x in v.items():checks.append(check(f'bridge_dependency.{kind}.{r["id"]}.{k}',got[k],x,4e-7))
    return checks

def run(production,export,work,seed,nonce,timeout):
    source={name:read(Path(export)/name) for name in ('assembly.json','operators.json','born_hard.json','spacelike_hard_one_loop.json')}
    checks=[]
    for kind in ('soft','hard','assembly'):
        root=Path(work)/('bridge-probe-'+kind);root.mkdir()
        dest=root/'inputs';dest.mkdir()
        for name,data in mutate(source,kind).items():write(dest/name,data)
        req=probe_requests(seed,kind);request=root/'requests.json';write(request,{'run_id':nonce+'-'+kind,'requests':req})
        write(root/'SCOPE.json',{'scope':'ALTERED_INPUT_ARITHMETIC_PROBE_ONLY; not accepted physics'})
        result=execute([sys.executable,str(relative_file(production,'numerics/evaluate_assembly.py')),'--export-dir',str(dest),'--requests',str(request)],production,root/'response.json',timeout)
        if result['exit_code']!=0:raise ValueError('Generated bridge did not accept the dependency probe: '+kind)
        write(root/'execution.json',result)
        checks+=compare(req,read(root/'response.json'),nonce+'-'+kind,kind)
    return checks

def replay(work,seed,nonce):
    checks=[]
    for kind in ('soft','hard','assembly'):
        root=Path(work)/('bridge-probe-'+kind);req=probe_requests(seed,kind)
        if read(root/'requests.json')!={'run_id':nonce+'-'+kind,'requests':req}:raise ValueError('Changed probe request')
        checks+=compare(req,read(root/'response.json'),nonce+'-'+kind,kind)
    return checks
