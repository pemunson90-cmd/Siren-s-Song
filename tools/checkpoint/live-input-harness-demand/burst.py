#!/usr/bin/env python3
"""A manually chosen live-input run interval with raw pause in the same process.
No actor/state writes, tactical decisions, or automatic winning policy.
"""
import argparse
import json
from pathlib import Path
import subprocess
import sys

CLI = Path(__file__).with_name('play.py')

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--session', required=True)
    parser.add_argument('--seconds', required=True, type=float)
    args = parser.parse_args()
    if not 0 < args.seconds <= 10:
        parser.error('Choose one interval greater than zero and at most10 seconds.')
    base = [sys.executable, str(CLI), '--session', args.session]
    def call(*action):
        result = subprocess.run(base + list(action), capture_output=True, text=True, timeout=55)
        if result.returncode:
            raise RuntimeError(result.stderr or result.stdout)
        return json.loads(result.stdout)
    state = call('status')
    m = state['metrics']
    if m['screen'] != 'mission' or not m['paused'] or m['outcome']:
        raise SystemExit('Start this interval from the ordinary paused active mission.')
    running = None
    try:
        call('key', 'Space')
        running = call('wait', str(args.seconds))
    finally:
        # Pause immediately after the run response; another screenshot/status
        # would itself consume unobserved live simulation time.
        state = running if running is not None else call('status')
        m = state['metrics']
        if m['screen'] == 'mission' and not m['paused']:
            state = call('key', 'Space')
        print(json.dumps({'running_capture':running, 'final':state}, indent=2))
        if state['metrics']['screen'] == 'mission' and not state['metrics']['paused']:
            raise RuntimeError('Raw pause did not take effect; inspect this session immediately.')

if __name__ == '__main__':
    main()
