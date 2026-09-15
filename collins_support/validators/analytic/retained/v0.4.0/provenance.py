"""Check file identities and a connected native derivation graph; not a physics proof."""
from nlo_support import read,relative,sha

def check(stage,out,production,inputs):
    p=read(relative(out,'provenance.json'))
    if p.get('schema')!=1 or p.get('stage')!=stage['id']:raise ValueError('wrong provenance stage')
    nodes=p.get('nodes')
    if not isinstance(nodes,list) or not nodes:raise ValueError('empty derivation graph')
    ids=[n.get('id') for n in nodes]
    if any(type(i) is not str or not i for i in ids) or len(set(ids))!=len(ids):raise ValueError('invalid graph IDs')
    mapping={n['id']:n for n in nodes};roots={'production':production,'output':out,**inputs}
    reached=set();visiting=set()
    def visit(key):
        if key in reached:return
        if key in visiting or key not in mapping:raise ValueError('cyclic/missing graph dependency')
        visiting.add(key);n=mapping[key]
        if type(n.get('parents')) is not list:raise ValueError('invalid graph parents')
        for parent in n['parents']:visit(parent)
        f=n['file'];root=roots.get(f.get('root'))
        if root is None:raise ValueError('unknown graph file root')
        path=relative(root,f['path'])
        if sha(path)!=f['sha256'] or path.stat().st_size==0:raise ValueError('changed/empty native graph file')
        if type(n.get('explanation')) is not str or len(n['explanation'].strip())<20:raise ValueError('missing graph explanation')
        visiting.remove(key);reached.add(key)
    exports=p.get('exports')
    if not isinstance(exports,list) or not exports:raise ValueError('missing graph exports')
    for key in exports:visit(key)
    if reached!=set(ids):raise ValueError('unconnected evidence nodes')
    roles={mapping[k]['role'] for k in reached}
    if not set(stage['roles'])<=roles:raise ValueError('missing native derivation roles: '+str(set(stage['roles'])-roles))
    if not any(n['file']['root']=='production' for n in nodes):raise ValueError('no producing source identity')
    if not any(n['file']['root']=='output' for n in nodes):raise ValueError('no regenerated native evidence')
    if stage['id'] in ('d17','d18'):
        primary={n['file']['path'] for n in nodes if n['role']=='finite_export'}
        second={n['file']['path'] for n in nodes if n['role']=='independent_route'}
        if not primary or not second or primary&second:raise ValueError('independent route must have separate native artifact')
        def ancestors(key):
            result=set()
            for parent in mapping[key]['parents']:
                result.add(parent);result.update(ancestors(parent))
            return result
        for node in nodes:
            if node['role']=='independent_route' and any(mapping[k]['role']=='finite_export' for k in ancestors(node['id'])):
                raise ValueError('independent route depends on the primary finite export')
    return {'nodes':len(nodes),'roles':sorted(roles),'sha256':sha(out/'provenance.json')}
