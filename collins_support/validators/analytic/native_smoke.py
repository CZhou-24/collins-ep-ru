#!/usr/bin/env python3
"""Native exact-expression transport test only; not a RU/physics acceptance."""
import argparse,json
from pathlib import Path
from ru_support import *
from workflow import export_native
from algebra import decode,equal

def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--repo',default='/bigTMD');p.add_argument('--output',required=True);a=p.parse_args()
    try:
        release_integrity();rt=runtime(a.repo);dest=output_path(a.output,a.repo,protected=[ROOT,Path(a.repo)/ENGINE,Path(a.repo)/OLD_ENGINE],area='states');dest.mkdir(parents=True,exist_ok=False)
        src=dest/'synthetic.wl';src.write_text('<|"schema"->5,"value"->RUExact[CF (1-z)/eps + Pi^2/6],"flag"->True|>\n')
        ex=export_native(src,dest/'synthetic.json','packet',rt,dest/'transport')
        got=read(dest/'synthetic.json');expected=decode(['add',['mul','CF',['add',1,['mul',-1,'z']],['pow','eps',-1]],['mul','1/6',['pow','pi',2]]])
        if got['schema']!=5 or got['flag'] is not True or not equal(decode(got['value']),expected):raise ValueError('native transport mismatch')
        write(dest/'smoke.json',{'status':'SMOKE_PASS','scope':'synthetic native expression transport only','execution':ex})
        print(json.dumps({'status':'SMOKE_PASS','scope':'synthetic native expression transport only'}));return 0
    except Exception as exc:r,c=error_result(exc);print(json.dumps(r));return c
if __name__=='__main__':raise SystemExit(main())
