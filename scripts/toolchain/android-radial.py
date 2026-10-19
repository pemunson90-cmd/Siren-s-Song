#!/usr/bin/env python3
"""Choose only disclosure steps for the current native radial HUD snapshot.

This is smoke automation, not an alternate gameplay command path. Actual taps
still use measured SS_TARGET coordinates, then require a new app acknowledgment.
"""
import json
from pathlib import Path
import sys
sys.dont_write_bytecode=True
from android_metric_records import read_records

PAGES = {
    'tools': {'decoy', 'emp', 'recon', 'knock'},
    'route': {'queue', 'hold', 'waypoint_mode', 'home', 'program'},
    'guard': {'contact_hold', 'wait_drone', 'hold'},
}
CRAFT = {'camera', 'ping', 'silent', 'program', 'tools_menu', 'route_menu', 'guard_menu', 'inspect'}
STATIONS = {'sub', 'droneA', 'droneB', 'menu'}

def next_action(layout, target):
    if layout.get('screen') != 'mission' or layout.get('hud_layout') != 'radial':
        return None
    if target in {c.get('action') for c in layout.get('controls', [])}:
        return None
    page = layout.get('context_page')
    if page == 'water':
        contextual = CRAFT | STATIONS | set().union(*PAGES.values())
        return 'more_orders' if target in contextual else None
    if page == 'fleet':
        if target in CRAFT | set().union(*PAGES.values()):
            selected = layout.get('capture_state', {}).get('selected')
            if type(selected) is not int or selected not in range(3):
                raise ValueError('Missing selected own station')
            return ['sub', 'droneA', 'droneB'][selected]
        return 'radial_back'
    if page == 'craft':
        for destination, actions in PAGES.items():
            if target in actions:
                return destination + '_menu'
        return 'radial_back'
    if page in {'tools', 'route', 'guard', 'object', 'inspect'}:
        return 'radial_back'
    raise ValueError('Unknown radial context page')

def main():
    try:
        text = Path(sys.argv[1]).read_text(errors='replace')
        records = read_records(text)
        boundary = max((i for i, line in enumerate(text.splitlines()) if any(marker in line for marker in ('SS_SCREEN ', 'SS_VIEW ', 'SS_MISSION_SELECT '))), default=-1)
        if not records or records[-1][1] is None or records[-1][0] <= boundary:
            return 2
        print(next_action(json.loads(records[-1][1]), sys.argv[2]) or '')
        return 0
    except (OSError, ValueError, TypeError, KeyError) as error:
        print(str(error), file=sys.stderr)
        return 1
if __name__ == '__main__':
    raise SystemExit(main())
