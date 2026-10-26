from __future__ import annotations
import hashlib
import json
import re
import zlib
from datetime import datetime, timezone
from pathlib import Path
from zipfile import ZIP_DEFLATED, ZipFile

root = Path(__file__).resolve().parent.parent
out_dir = Path(__file__).resolve().parent
archive = out_dir / 'baseline-development.zip'
manifest_path = out_dir / 'manifest.json'
# Include root-level evidence logs, summaries, and probe scripts. Include baseline/native
# captures only from explicitly named capture directories; never include userdata/cache trees.
root_suffixes = {'.log', '.gd', '.json', '.ps1'}
capture_dirs = {
    'native-baseline-captures-1', 'native-baseline-captures-2', 'native-baseline-captures-3',
    'status-ui-native-captures-1', 'status-ui-native-captures-2',
}
excluded_dir_names = []
for p in sorted(root.iterdir()):
    if not p.is_dir() or p == out_dir:
        continue
    if p.name in capture_dirs:
        continue
    if p.name.startswith('independent-fa13'):
        excluded_dir_names.append({'path': str(p.resolve()), 'reason': 'independent-fa13 subtree explicitly excluded while in progress'})
    elif 'userdata' in p.name.lower() or '-data-' in p.name.lower() or p.name.startswith('iso-'):
        excluded_dir_names.append({'path': str(p.resolve()), 'reason': 'isolated user-data/test data tree excluded'})
    elif p.name.lower().startswith('.godot'):
        excluded_dir_names.append({'path': str(p.resolve()), 'reason': 'Godot cache excluded'})
    else:
        excluded_dir_names.append({'path': str(p.resolve()), 'reason': 'outside requested root logs/probes and named baseline/native capture scope'})

sources = []
for p in sorted(root.iterdir()):
    if p.is_file() and p.suffix.lower() in root_suffixes:
        sources.append((f'root/{p.name}', p))
for dirname in sorted(capture_dirs):
    folder = root / dirname
    if not folder.exists():
        continue
    for p in sorted(folder.rglob('*.png')):
        if p.is_file():
            sources.append((f'captures/{dirname}/{p.relative_to(folder).as_posix()}', p))

members = []
with ZipFile(archive, 'w', compression=ZIP_DEFLATED, compresslevel=9) as zf:
    for arcname, src in sources:
        data = src.read_bytes()
        zf.writestr(arcname, data)
        members.append({
            'member': arcname,
            'source_absolute': str(src.resolve()),
            'source_relative': str(src.relative_to(root)),
            'size_bytes': len(data),
            'sha256': hashlib.sha256(data).hexdigest(),
            'crc32': f'{zlib.crc32(data) & 0xffffffff:08x}',
        })

with ZipFile(archive, 'r') as zf:
    bad = zf.testzip()
    if bad is not None:
        raise RuntimeError(f'ZIP CRC failure in {bad}')
    if set(zf.namelist()) != {m['member'] for m in members}:
        raise RuntimeError('ZIP member set mismatch')
    for item in members:
        archived = zf.read(item['member'])
        source = Path(item['source_absolute']).read_bytes()
        if archived != source:
            raise RuntimeError(f'Byte mismatch for {item["source_relative"]}')
        if hashlib.sha256(archived).hexdigest() != item['sha256']:
            raise RuntimeError(f'SHA-256 mismatch for {item["member"]}')

log_summaries = []
for item in members:
    if not item['member'].lower().endswith('.log'):
        continue
    path = Path(item['source_absolute'])
    lines = path.read_text(encoding='utf-8', errors='replace').splitlines()
    check_lines = [line.strip() for line in lines if re.search(r'CHECKS\s+\d+\s+FAILURES\s+\d+', line, re.I)]
    error_lines = [line.strip() for line in lines if re.search(r'^(?:FAIL\\b|ERROR:|SCRIPT ERROR|PARSE ERROR|Parse Error)', line.strip(), re.I)]
    log_summaries.append({
        'member': item['member'],
        'check_summaries': check_lines[-5:],
        'error_marker_count': len(error_lines),
        'error_marker_samples': error_lines[:12],
    })

root_direct = [p for p in root.iterdir() if p.is_file() and p.suffix.lower() in root_suffixes]
found_fa13 = [p.name for p in root.iterdir() if p.is_dir() and p.name.startswith('independent-fa13')]
manifest = {
    'created_utc': datetime.now(timezone.utc).isoformat(),
    'scope': {
        'included': 'Every direct 048-evidence file with .log/.gd/.json/.ps1 extension, plus every PNG in native-baseline-captures-1/2/3 and status-ui-native-captures-1/2.',
        'excluded': 'All isolated user-data/test-data trees, Godot caches, all non-capture subtrees, temporary output directory, and independent-fa13 if present.',
        'root_direct_selected_count': len(root_direct),
        'capture_png_count': sum(1 for m in members if m['member'].startswith('captures/')),
        'independent_fa13_found': found_fa13,
        'excluded_top_level_directories': excluded_dir_names,
    },
    'archive': {
        'path': str(archive.resolve()),
        'size_bytes': archive.stat().st_size,
        'sha256': hashlib.sha256(archive.read_bytes()).hexdigest(),
        'crc32': f'{zlib.crc32(archive.read_bytes()) & 0xffffffff:08x}',
        'member_count': len(members),
        'zip_testzip': 'passed',
        'all_member_source_bytes_verified': True,
    },
    'members': members,
    'log_error_and_check_summary_scan': log_summaries,
    'missing_logs': 'No authoritative expected-file checklist was present in the directory; all direct matching logs/probes and requested capture PNGs present at inventory time were included.',
    'claims': 'This is evidence packaging only. It does not claim any test suite passed, a complete product state, or human/phone usability.',
}
manifest_path.write_text(json.dumps(manifest, indent=2) + '\n', encoding='utf-8')
print(json.dumps({'archive': str(archive.resolve()), 'manifest': str(manifest_path.resolve()), 'member_count': len(members), 'bytes': archive.stat().st_size, 'sha256': manifest['archive']['sha256'], 'crc32': manifest['archive']['crc32'], 'log_count': len(log_summaries), 'capture_png_count': manifest['scope']['capture_png_count'], 'fa13_found': found_fa13}, indent=2))
