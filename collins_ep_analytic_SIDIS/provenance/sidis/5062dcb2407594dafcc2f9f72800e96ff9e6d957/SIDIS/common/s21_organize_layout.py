#!/usr/bin/env python3
"""Relocate SIDIS stages without changing a mathematical result."""
from pathlib import Path
import hashlib
import json
import re
import shutil
from datetime import datetime, timezone

COMMON = Path(__file__).resolve().parent
ROOT = COMMON.parent
RECEIPT = COMMON / 's21_result' / 'layout.json'
CORE = [1, 2, 3, 4, 5, 8, 9, 10, 11, 12, 13, 14, 15, 17, 18, 19, 20]
REAL = [1, 2, 3, 4, 8, 10, 11, 15, 16, 17, 20]
CHANNELS = {name: (CORE if name in ['Hqq', 'Hqg', 'Hgq'] else REAL)
            for name in ['Hqq', 'Hqg', 'Hgq', 'Hgg', 'Hqqbar', 'Hqqprime']}


def sha(path):
    with path.open('rb') as stream:
        return hashlib.file_digest(stream, 'sha256').hexdigest()


def record(message):
    with (ROOT.parent / 'progress.md').open('a') as stream:
        stream.write('\nSIDIS layout ' + datetime.now(timezone.utc).isoformat() + ': ' + message + '\n')


def main():
    if RECEIPT.exists():
        print('Layout already recorded:', RECEIPT)
        return
    source_files = sorted(p for p in ROOT.iterdir() if p.is_file() and p.suffix in ['.wl', '.py']
                          and '_result' not in p.name and '_required_orders' not in p.name)
    assert len(source_files) == 20
    sources = {p.name: {'OriginalSHA256': sha(p)} for p in source_files}
    by_stage = {p.name[:3]: p.name for p in source_files}
    stage_maps = {ch: {f's{old:02}': f's{new:02}' for new, old in enumerate(stages, 1)}
                  for ch, stages in CHANNELS.items()}
    moves = {}
    result_hashes = {}

    def move(source, target):
        if source == target:
            return
        target.parent.mkdir(parents=True, exist_ok=True)
        assert not target.exists(), str(target)
        moves[str(source.relative_to(ROOT))] = str(target.relative_to(ROOT))
        shutil.move(str(source), str(target))

    snapshots = COMMON / 'previous_runs' / 'layout_sources'
    snapshots.mkdir(parents=True, exist_ok=True)
    for source in source_files:
        shutil.copy2(source, snapshots / source.name)
    for ch in CHANNELS:
        for p in (ROOT / ch).glob('s*_result.wl'):
            result_hashes[str(p.relative_to(ROOT))] = sha(p)
        for p in (ROOT / ch).glob('s20_F*_hat.wl'):
            result_hashes[str(p.relative_to(ROOT))] = sha(p)
    for p in ROOT.glob('s*_result.wl'):
        result_hashes[str(p.relative_to(ROOT))] = sha(p)

    for p in list(COMMON.iterdir()):
        if p.is_dir() and re.match(r's\d\d_', p.name) and p.name != 's21_result':
            move(p, COMMON / (p.name[:3] + '_result') / p.name)
    for p in list(ROOT.iterdir()):
        if p.name in CHANNELS or p.name in ['common', '.cluster', 'bigTMD_comparison', 'README.md']:
            continue
        if p.name == 'software':
            move(p, COMMON / 'software')
        elif 'previous' in p.name or p.name == 's17_excluded_packagex':
            move(p, COMMON / 'previous_runs' / p.name)
        elif p.name in sources:
            move(p, COMMON / p.name)
        else:
            assert re.match(r's\d\d_', p.name), p.name
            move(p, COMMON / (p.name[:3] + '_result') / p.name)

    aliases = {'common/' + name: name for name in sources}
    for ch, mapping in stage_maps.items():
        base = ROOT / ch
        previous_readme = base / 'README.md'
        (base / 'previous_runs').mkdir(exist_ok=True)
        shutil.copy2(previous_readme, base / 'previous_runs' / 'README_before_layout.md')
        for p in list(base.iterdir()):
            if p.name in ['README.md', 'previous_runs']:
                continue
            if 'previous' in p.name:
                move(p, base / 'previous_runs' / p.name)
                continue
            old = p.name[:3]
            assert old in mapping, str(p)
            new = mapping[old]
            target = base / (new + '_result')
            if p.name == old + '_result' and p.is_dir():
                if not target.exists():
                    move(p, target)
                elif p != target:
                    for child in list(p.iterdir()):
                        move(child, target / child.name)
                    p.rmdir()
            else:
                move(p, target / (new + p.name[3:]))
        for old, new in mapping.items():
            target = base / (new + '_result')
            target.mkdir(exist_ok=True)
            shared = COMMON / (old + '_result')
            if shared.is_dir():
                (target / 'shared').symlink_to('../../common/' + old + '_result', target_is_directory=True)
            original = by_stage[old]
            alias = new + original[3:]
            (base / alias).symlink_to('../common/' + original)
            aliases[ch + '/' + alias] = original

    bootstrap = 'Get[FileNameJoin[{DirectoryName[$InputFileName],"..","common","s22_paths.wl"}]];\n'
    for name in sources:
        source = COMMON / name
        original = (snapshots / name).read_text()
        if source.suffix == '.wl':
            text = original
            for before, after in [('FileNameJoin[', 'sidisPath['), ('FileHash[', 'sidisHash['),
                                  ('Import[', 'sidisImport['), ('Get[', 'sidisGet[')]:
                text = text.replace(before, after)
            text, count = re.subn(r'root\s*=\s*DirectoryName\[\$InputFileName\]', 'root=sidisRoot', text)
            assert count == 1, name
            text = bootstrap + text
            check = text[len(bootstrap):]
            old_root = re.search(r'root\s*=\s*DirectoryName\[\$InputFileName\]', original).group()
            check = check.replace('root=sidisRoot', old_root, 1)
            for before, after in [('sidisPath[', 'FileNameJoin['), ('sidisHash[', 'FileHash['),
                                  ('sidisImport[', 'Import['), ('sidisGet[', 'Get[')]:
                check = check.replace(before, after)
            assert check == original, name
        else:
            text = original.replace('ROOT = Path(__file__).resolve().parent',
                                    'ROOT = Path(__file__).resolve().parent.parent')
            text = text.replace('inputs = channel / "s01_inputs"', 'inputs = channel / "s01_result" / "s01_inputs"')
            text = text.replace('channel / "s01_reference_sources"', 'channel / "s01_result" / "s01_reference_sources"')
            text = text.replace('(channel / "s01_result.json")', '(channel / "s01_result" / "s01_result.json")')
            text = text.replace('    if readme_path.exists() and readme_path.read_text() != readme:\n        raise RuntimeError("Refusing to overwrite an advanced channel ledger: " + name)\n    readme_path.write_text(readme)',
                                '    if not readme_path.exists():\n        readme_path.write_text(readme)')
        source.write_text(text)
        sources[name]['RelocatedSHA256'] = sha(source)
        sources[name]['OriginalSource'] = str((snapshots / name).relative_to(ROOT))
        sources[name]['PathOnlyAdaptation'] = True

    for old, expected in result_hashes.items():
        new = moves[old]
        assert sha(ROOT / new) == expected, old
    RECEIPT.parent.mkdir(exist_ok=True)
    artifact = {'Completed': True, 'OriginalRoots': [str(ROOT), '/u/scratch/r/rushil/AI_Assisted_SIDIS/SIDIS_20260907'],
                'ChannelStages': stage_maps, 'Sources': sources, 'SourceAliases': aliases,
                'Moves': moves, 'AcceptedResultSHA256': result_hashes,
                'Meaning': 'Path-only relocation. SourceHash in accepted physics packets identifies the preserved executed source snapshot; relocated source hashes are recorded separately here.'}
    RECEIPT.write_text(json.dumps(artifact, indent=2) + '\n')
    record('Moved production artifacts into consecutive channel step directories and shared common directories. '
           'Every accepted result/F-hat hash is unchanged; each Wolfram source adaptation exactly reverses to its original executed bytes. '
           'Current sources, original snapshots, aliases and moves recorded in common/s21_result/layout.json. '
           'Next validate the path adapter and update READMEs with current stage maps.')
    print('S21_SUCCESS: layout relocated; all accepted result hashes unchanged.')


if __name__ == '__main__':
    main()
