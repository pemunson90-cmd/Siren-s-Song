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
manifest_path = out_dir / 'manifest.json'
archive_prefix = 'baseline-development'
max_part_uncompressed = 44 * 1024 * 1024
root_extensions = {'.log', '.gd', '.json', '.ps1', '.md'}

# Collect every eligible direct evidence file. Probe scripts are the direct .gd files.
sources: list[tuple[str, Path]] = []
for p in sorted(root.iterdir()):
    if p.is_file() and p.suffix.lower() in root_extensions:
        sources.append((f'root/{p.name}', p))

capture_dirs = [p for p in sorted(root.iterdir()) if p.is_dir() and p != out_dir and 'capture' in p.name.lower()]
for folder in capture_dirs:
    for p in sorted(folder.rglob('*.png')):
        if p.is_file():
            sources.append((f'captures/{folder.name}/{p.relative_to(folder).as_posix()}', p))

# Record excluded top-level directories without traversing the active independent review subtree.
excluded_dirs = []
for p in sorted(root.iterdir()):
    if not p.is_dir() or p == out_dir or p in capture_dirs:
        continue
    low = p.name.lower()
    if p.name == 'independent-b7addc':
        reason = 'active independent reviewer subtree explicitly excluded; not traversed'
    elif 'userdata' in low or 'data' in low:
        reason = 'isolated user-data/test-data tree excluded'
    elif '.godot' in low or 'cache' in low or 'import' in low:
        reason = 'Godot cache/import tree excluded'
    else:
        reason = 'not a named native/capture PNG folder; directory tree excluded'
    excluded_dirs.append({'path': str(p.resolve()), 'reason': reason})

# Hash and deduplicate only exact byte-identical files. Hash collisions are disambiguated by byte comparison.
unique = []
by_digest: dict[tuple[str, int], list[int]] = {}
originals = []
for arc_source, src in sources:
    data = src.read_bytes()
    digest = hashlib.sha256(data).hexdigest()
    key = (digest, len(data))
    match = None
    for index in by_digest.get(key, []):
        if unique[index]['bytes'] == data:
            match = index
            break
    if match is None:
        match = len(unique)
        member_name = 'evidence/' + arc_source
        unique.append({
            'member': member_name,
            'bytes': data,
            'size_bytes': len(data),
            'sha256': digest,
            'crc32': f'{zlib.crc32(data) & 0xffffffff:08x}',
            'sources': [],
        })
        by_digest.setdefault(key, []).append(match)
    unique[match]['sources'].append(str(src.resolve()))
    originals.append({
        'source_absolute': str(src.resolve()),
        'source_relative': str(src.relative_to(root)),
        'size_bytes': len(data),
        'sha256': digest,
        'crc32': f'{zlib.crc32(data) & 0xffffffff:08x}',
        'stored_member': unique[match]['member'],
    })

# Greedy split by raw bytes at 44 MiB, leaving room for ZIP headers/directories below 45 MiB.
parts = []
current = []
current_bytes = 0
for item in unique:
    if current and current_bytes + item['size_bytes'] > max_part_uncompressed:
        parts.append(current)
        current = []
        current_bytes = 0
    if item['size_bytes'] > max_part_uncompressed:
        raise RuntimeError(f'One evidence file exceeds part limit: {item["member"]}')
    current.append(item)
    current_bytes += item['size_bytes']
if current:
    parts.append(current)

part_records = []
member_to_part = {}
for part_number, group in enumerate(parts, start=1):
    archive = out_dir / f'{archive_prefix}-{part_number:02d}.zip'
    with ZipFile(archive, 'w', compression=ZIP_DEFLATED, compresslevel=9) as zf:
        for item in group:
            zf.writestr(item['member'], item['bytes'])
    if archive.stat().st_size >= 45 * 1024 * 1024:
        raise RuntimeError(f'ZIP exceeds 45 MiB: {archive.name} ({archive.stat().st_size})')
    with ZipFile(archive, 'r') as zf:
        bad = zf.testzip()
        if bad is not None:
            raise RuntimeError(f'ZIP CRC test failed: {archive.name}:{bad}')
        if set(zf.namelist()) != {item['member'] for item in group}:
            raise RuntimeError(f'ZIP member set mismatch: {archive.name}')
        for item in group:
            payload = zf.read(item['member'])
            if payload != item['bytes'] or hashlib.sha256(payload).hexdigest() != item['sha256']:
                raise RuntimeError(f'Archive bytes/hash mismatch: {archive.name}:{item["member"]}')
            for source_path in item['sources']:
                if Path(source_path).read_bytes() != payload:
                    raise RuntimeError(f'Source bytes mismatch: {source_path}')
            member_to_part[item['member']] = part_number
    part_records.append({
        'part': part_number,
        'path': str(archive.resolve()),
        'size_bytes': archive.stat().st_size,
        'sha256': hashlib.sha256(archive.read_bytes()).hexdigest(),
        'crc32': f'{zlib.crc32(archive.read_bytes()) & 0xffffffff:08x}',
        'member_count': len(group),
        'zip_testzip': 'passed',
        'all_members_compared_to_every_source': True,
    })

for item in unique:
    item['part'] = member_to_part[item['member']]
    del item['bytes']

log_summaries = []
for arc_source, src in sources:
    if src.suffix.lower() != '.log':
        continue
    lines = src.read_text(encoding='utf-8', errors='replace').splitlines()
    check_lines = [line.strip() for line in lines if re.search(r'CHECKS\s+\d+\s+FAILURES\s+\d+', line, re.I)]
    error_lines = [line.strip() for line in lines if re.search(r'^(?:FAIL\b|ERROR:|SCRIPT ERROR|PARSE ERROR|Parse Error|WARNING:)|resources still in use|ObjectDB instances leaked', line.strip(), re.I)]
    log_summaries.append({
        'source': str(src.resolve()),
        'stored_member': next(o['stored_member'] for o in originals if o['source_absolute'] == str(src.resolve())),
        'check_summaries': check_lines[-8:],
        'error_marker_count': len(error_lines),
        'error_marker_samples': error_lines[:20],
    })

expected_final_logs = [
    'final-import.log', 'final-core.log', 'final-native.log',
    'final-hunt_pressure_tests.log', 'final-hunt_pressure_integration_tests.log',
    'final-hunt_meter_ui_tests.log', 'final-opening_depth_journeys.log',
    'final-opening-off.log', 'freeze-integration.log',
]
for suffix in ['bell_name','boat_keel','buoy_blind','bus_cable','feed_room','keel_mark','locker_latch','relay_blink','shutter_order','slide_mark','spindle_wear','structure_edge','tender_door','vane_crack']:
    expected_final_logs.append(f'hunt-photo_row_{suffix}_journey_tests.log')
existing_names = {p.name for p in root.iterdir() if p.is_file()}
missing_final_logs = [name for name in expected_final_logs if name not in existing_names]

manifest = {
    'created_utc': datetime.now(timezone.utc).isoformat(),
    'source': {'head': 'b7addca49c997772d8704afbda33ff6485d42b40', 'pull_request': 147},
    'scope': {
        'included': 'Every completed direct root .log/.gd/.json/.ps1/.md file plus every PNG under each direct top-level directory whose name contains capture.',
        'excluded': 'Active independent-b7addc subtree (not traversed), isolated userdata/test-data directories, cache/import directories, other non-capture subtrees, generated UID/import files.',
        'capture_directories': [str(p.resolve()) for p in capture_dirs],
        'excluded_top_level_directories': excluded_dirs,
        'expected_final_logs': expected_final_logs,
        'missing_expected_final_logs': missing_final_logs,
    },
    'counts': {
        'original_paths': len(originals),
        'unique_stored_members': len(unique),
        'byte_identical_duplicates_mapped': len(originals) - len(unique),
        'log_files': len(log_summaries),
        'parts': len(part_records),
    },
    'parts': part_records,
    'original_to_member_map': originals,
    'unique_members': unique,
    'log_check_and_error_summaries': log_summaries,
    'claims': 'Evidence packaging only; no test suite or feature outcome is certified by this manifest.',
}
manifest_path.write_text(json.dumps(manifest, indent=2) + '\n', encoding='utf-8')
red_summaries = []
for row in log_summaries:
    failed = [line for line in row['check_summaries'] if re.search(r'FAILURES\s+[1-9]\d*', line)]
    if failed or row['error_marker_count']:
        red_summaries.append({'log': Path(row['source']).name, 'checks': failed, 'error_count': row['error_marker_count'], 'samples': row['error_marker_samples'][:3]})
print(json.dumps({
    'package_dir': str(out_dir.resolve()),
    'manifest': str(manifest_path.resolve()),
    'original_paths': len(originals),
    'unique_members': len(unique),
    'duplicates_mapped': len(originals)-len(unique),
    'parts': part_records,
    'missing_expected_final_logs': missing_final_logs,
    'red_summaries': red_summaries,
}, indent=2))
