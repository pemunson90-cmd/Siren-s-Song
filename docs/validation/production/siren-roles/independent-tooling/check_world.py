#!/usr/bin/env python3
"""Validate the independent role-aware world log, without rerunning gameplay."""
import json
from pathlib import Path

text = Path(__file__).with_name('world.log').read_text()
assert 'ROLE WORLD AUDIT COMPLETE' in text
assert 'SCRIPT ERROR:' not in text and 'ERROR:' not in text
rows = [json.loads(line[7:]) for line in text.splitlines() if line.startswith('RESULT ')]
assert len(rows) == 13
patrollers = [r for r in rows if r['type'] == 'patroller']
stations = [r for r in rows if r['type'] != 'patroller']
assert len(patrollers) == 10 and len(stations) == 3
for r in rows:
    assert abs(r['elapsed'] - 600) < 1e-6 and r['outcome'] == ''
    assert r['detected_seconds'] == 0
for r in patrollers:
    assert r['travel'] > 14000 and r['longest_stationary'] == 0
    assert min(r['waypoint_visits']) >= 10
    assert r['blocked_goal_seconds'] == 0 and r['empty_route_seconds'] == 0
for r in stations:
    assert r['travel'] == 0 and r['max_home_distance'] == 0
    assert abs(r['mode_seconds']['DORMANT'] - 600) < 1e-6
margin = [(r['mission'], r['siren'], r['blocked_position_seconds']) for r in rows if r['blocked_position_seconds'] > 0]
assert len(margin) == 1 and margin[0][:2] == (4, 0) and abs(margin[0][2] - 28.05) < 1e-6
print('24-unit planning-margin incursion retained:', margin)
print('WORLD: 13 roles / 600 seconds each; 10 circulating patrollers, 3 dormant station roles; liveness and waypoint assertions pass')

clearance = Path(__file__).with_name('clearance.log').read_text()
assert 'ROLE CLEARANCE AUDIT COMPLETE' in clearance
assert 'SCRIPT ERROR:' not in clearance and 'ERROR:' not in clearance
body = [json.loads(line[7:]) for line in clearance.splitlines() if line.startswith('RESULT ')]
assert len(body) == 3 and all(r['blocked_body_seconds'] == 0 for r in body)
print('Focused Well replay: actual 12-unit collision radius remains clear for 600 seconds')
