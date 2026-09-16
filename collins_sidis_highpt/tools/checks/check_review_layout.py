#!/usr/bin/env python3
"""Read-only layout, syntax and preserved-formula checks; no native execution."""
import ast
import hashlib
import importlib.util
import json
from pathlib import Path
import re
import subprocess
import sys

ROOT=Path(__file__).resolve().parents[3]
ENGINE=ROOT/'collins_sidis_highpt'
EVIDENCE=ROOT/'collins_support/reports/sidis-highpt-final-review'
sys.path.insert(0,str(ROOT/'collins_support/validators'))
import sidis_highpt as h

def main():
    record=json.loads((EVIDENCE/'OLD_NEW_FILE_MAP.json').read_text())
    original=json.loads(subprocess.check_output(['git','show','26b270b3:collins_sidis_highpt/project.json'],cwd=ROOT))
    current=json.loads((ENGINE/'project.json').read_text())
    # Original checks retain their exact definitions even after the follow-up.
    assert current['checks'][:len(original['checks'])]==original['checks']
    for key in ('exports','master_imports','stages','channels','scope'):
        assert current[key]==original[key],key
    for key,row in original['sources'].items():
        assert {k:v for k,v in row.items() if k!='origin'}=={
            k:v for k,v in current['sources'][key].items() if k!='origin'},key
    preserved=json.loads((EVIDENCE/'reviewed-source-preservation.json').read_text())['engine_files']
    physics=0
    for rel,row in preserved.items():
        if rel.startswith(('inputs/','references/')) or (
                rel.startswith('common/') and not re.fullmatch(r'common/r0[0-7]\.wls',rel)):
            assert hashlib.sha256((ENGINE/rel).read_bytes()).hexdigest()==row['sha256'],rel
            physics+=1
    for sid,row in current['stages'].items():
        path=ENGINE/row['script'];assert path.is_file()
        text=path.read_text()
        assert '"tools","pipeline","native_stage_driver.py"' in text,sid
    python_files=list(ENGINE.rglob('*.py'))+list((ROOT/'collins_support/validators').rglob('*.py'))
    for p in python_files:
        ast.parse(p.read_text(),filename=str(p))
        if p.is_relative_to(ENGINE/'tools'):
            for m in re.finditer(r'Path\(__file__\)\.resolve\(\)\.parents\[([0-9]+)\]',p.read_text()):
                resolved=p.resolve().parents[int(m[1])]
                assert resolved in (ROOT,ENGINE),(p,resolved)
    for row in record['rows']:
        assert not (ENGINE/row['old']).exists(),row['old']
        assert (ENGINE/row['new']).is_file(),row['new']
    # Resolve literal Wolfram helper loads and stage calls, including development paths.
    loads=0
    for p in list((ENGINE/'tools').rglob('*.wl'))+list((ENGINE/'tools').rglob('*.wls'))+list((ENGINE/'common').glob('*.wls')):
        text=p.read_text()
        for match in re.finditer(r'"tools",\s*"(pipeline|checks|development)",\s*"([^"]+)"',text):
            assert (ENGINE/'tools'/match[1]/match[2]).is_file(),(p,match[0]);loads+=1
        assert not re.search(r'"tools",\s*"[^"/]+\.(?:py|wl|wls)"',text),p
    driver=ENGINE/'tools/pipeline/native_stage_driver.py'
    for script in set(re.findall(r"'([^'/]+\.wls)'",driver.read_text())):
        assert (driver.parent/script).is_file(),script
    # Import only side-effect-free pipeline modules, not arbitrary calculation scripts.
    sys.path.insert(0,str(driver.parent))
    for name in ('native_process','prepare_native_reduction','native_stage_driver','native_project_spec'):
        module=__import__(name)
        assert Path(module.__file__).resolve().parent==driver.parent
    identity=h.extension_identity()
    h.validate_spec(current,ENGINE)
    sources=h.bind_sources(current,ENGINE,ROOT/'SIDIS')
    print(json.dumps(dict(status='PASS',scope='Focused layout/software only; no native campaign',
        python_syntax_files=len(python_files),moved_helpers=len(record['rows']),
        stable_stage_entries=8, resolved_wolfram_tool_paths=loads,
        byte_identical_physics_inputs_and_references=physics,
        preserved_original_checks=len(original['checks']),declared_checks=len(current['checks']),
        registered_inputs=len(sources),validator_identity=identity),indent=2))

if __name__=='__main__':main()
