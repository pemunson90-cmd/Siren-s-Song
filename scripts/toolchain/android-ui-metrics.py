#!/usr/bin/env python3
"""Validate one atomic native layout snapshot against PNG pixels and OS density.

48 dp is an accessibility recommendation, not a platform-enforced physical minimum.
No nominal panel ppi is used for the gate. Exit 2 means a fresh snapshot is missing.
"""
import argparse
import json
import math
from pathlib import Path
import re
import struct
import sys

MISSION_ACTIONS = 'pause,sub,droneA,droneB,ping,camera,silent,queue,hold,emp,home,menu,more_orders,zoom_out,zoom_in,fit'
SECONDARY_ACTIONS = 'pause,sub,droneA,droneB,zoom_out,zoom_in,fit,more_orders,camera,emp,home,recon,decoy,contact_hold,wait_drone,waypoint_mode'


def numbers(value, count, label):
    if not isinstance(value, list) or len(value) != count or any(isinstance(x, bool) or not isinstance(x, (int, float)) or not math.isfinite(x) for x in value):
        raise ValueError(f'{label} must contain {count} finite numbers')
    return value


def rect(value, label):
    x, y, width, height = numbers(value, 4, label)
    if width <= 0 or height <= 0:
        raise ValueError(f'{label} must have positive area')
    return [x, y, width, height]


def contains(outer, inner, tolerance=0.5):
    return (inner[0] >= outer[0] - tolerance and inner[1] >= outer[1] - tolerance and
            inner[0] + inner[2] <= outer[0] + outer[2] + tolerance and
            inner[1] + inner[3] <= outer[1] + outer[3] + tolerance)


def os_density(text):
    entries = re.findall(r'^\s*(Physical|Override) density:\s*(\d+)\s*$', text, re.M)
    values = {}
    for kind, value in entries:
        if kind in values:
            raise ValueError('Ambiguous wm density output')
        values[kind] = int(value)
    result = values.get('Override', values.get('Physical', 0))
    if not 0 < result <= 10000:
        raise ValueError('No positive effective Android wm density')
    return result


def evaluate(layout, size, density, required):
    if layout.get('schema') != 1 or not isinstance(layout.get('screen'), str):
        raise ValueError('Unsupported SS_UI_METRICS schema/screen')
    width, height = numbers(layout.get('window'), 2, 'window')
    logical_width, logical_height = numbers(layout.get('viewport'), 2, 'viewport')
    if min(width, height, logical_width, logical_height) <= 0 or [width, height] != list(size):
        raise ValueError('Reported window must equal actual PNG dimensions')
    if layout.get('density_source') != 'android_display_metrics_density_dpi':
        raise ValueError('Native density_source must be Android DisplayMetrics.densityDpi')
    reported_density = layout.get('density_dpi')
    if isinstance(reported_density, bool) or not isinstance(reported_density, (int, float)) or reported_density != density:
        raise ValueError('Game density_dpi disagrees with effective Android wm density')
    sx, sy = width / logical_width, height / logical_height
    if abs(sx / sy - 1) > 0.0001:
        raise ValueError('Nonuniform/rounded canvas transform; report precise full viewport floats')
    safe = rect(layout.get('safe_rect'), 'safe_rect')
    if not contains([0, 0, width, height], safe):
        raise ValueError('Physical safe_rect lies outside window')
    chart = rect(layout.get('chart_rect'), 'chart_rect') if layout.get('chart_rect') is not None else None
    if layout['screen'] == 'mission' and chart is None:
        raise ValueError('Mission must report a positive actual chart_rect')
    controls = layout.get('controls')
    if not isinstance(controls, list) or not controls:
        raise ValueError('No actual visible controls reported')
    errors, results, actions = [], [], set()
    for control in controls:
        if not isinstance(control, dict):
            raise ValueError('Control must be an object')
        action = control.get('action')
        if not isinstance(action, str) or not action or action in actions:
            raise ValueError('Missing or duplicate control action')
        actions.add(action)
        hit = rect(control.get('hit_rect'), action + ' hit_rect')
        visual = rect(control.get('visual_rect'), action + ' visual_rect')
        physical = [hit[0] * sx, hit[1] * sy, hit[2] * sx, hit[3] * sy]
        dp = [physical[2] * 160 / density, physical[3] * 160 / density]
        clipped = control.get('clipped', False)
        if not isinstance(clipped, bool):
            raise ValueError('clipped must be boolean')
        exempt = False
        if clipped:
            reduced = hit[2] * hit[3] < visual[2] * visual[3] - 0.001
            if layout['screen'] == 'mission' or action in required or not reduced or not contains(visual, hit, 0.001):
                errors.append(f'{action}: invalid clipping exemption for HUD/required/full hit region')
            else:
                exempt = True
        if not exempt and min(dp) < 48 - 0.001:
            errors.append(f'{action}: hit region {dp[0]:.3f} x {dp[1]:.3f} dp is below the 48 dp recommendation')
        if not contains(safe, physical):
            errors.append(f'{action}: hit region lies outside physical safe_rect')
        results.append({'action': action, 'visual_logical': visual, 'hit_logical': hit, 'hit_physical': physical, 'hit_dp': dp, 'size_exempt_clipped': exempt})
    for missing in sorted(required - actions):
        errors.append('Missing required fully exposed control: ' + missing)
    for i, first in enumerate(results):
        a = first['hit_physical']
        for second in results[i + 1:]:
            b = second['hit_physical']
            overlap_x = min(a[0] + a[2], b[0] + b[2]) - max(a[0], b[0])
            overlap_y = min(a[1] + a[3], b[1] + b[3]) - max(a[1], b[1])
            if overlap_x > 0.5 and overlap_y > 0.5:
                errors.append(f'Overlapping hit regions: {first["action"]}, {second["action"]}')
    chart_dp = [chart[2] * sx * 160 / density, chart[3] * sy * 160 / density] if chart else None
    if chart and not contains(safe, [chart[0] * sx, chart[1] * sy, chart[2] * sx, chart[3] * sy]):
        errors.append('Chart lies outside physical safe_rect')
    return {'gate_passed': not errors, 'recommendation_dp': 48, 'density_dpi': density, 'density_reference': 'effective adb shell wm density; game Android DisplayMetrics.densityDpi must agree', 'window_physical': [width, height], 'viewport_logical': [logical_width, logical_height], 'canvas_scale': [sx, sy], 'safe_physical': safe, 'screen': layout['screen'], 'chart_dp': chart_dp, 'controls': results, 'errors': errors, 'limits': 'No physical panel-mm, Android OS multi-touch, finger comfort or performance claim.'}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('log')
    parser.add_argument('png')
    parser.add_argument('--screen', default='mission', help='Expected current game screen name')
    parser.add_argument('--density', required=True, help='Raw adb shell wm density output')
    parser.add_argument('--orders-page', choices=['primary', 'secondary'], default='primary', help='Explicit expected mission command page')
    parser.add_argument('--required-actions', default=None, help='Comma-separated fully exposed controls; explicit empty string for scroll-menu measurement')
    args = parser.parse_args()
    try:
        lines = Path(args.log).read_text(errors='replace').splitlines()
        boundary = max((i for i, line in enumerate(lines) if any(x in line for x in ('SS_SCREEN ', 'SS_MISSION_SELECT ', 'SS_VIEW '))), default=-1)
        snapshots = [line.split('SS_UI_METRICS ', 1)[1] for line in lines[boundary + 1:] if 'SS_UI_METRICS ' in line]
        if not snapshots:
            print('Waiting for fresh atomic SS_UI_METRICS after screen/view change', file=sys.stderr)
            return 2
        layout = json.loads(snapshots[-1])
        if not isinstance(layout, dict):
            raise ValueError('SS_UI_METRICS must be an object')
        if layout.get('screen') != args.screen:
            raise ValueError('Snapshot screen differs from requested current screen')
        png = Path(args.png).read_bytes()
        if len(png) < 24 or png[:8] != b'\x89PNG\r\n\x1a\n':
            raise ValueError('Invalid actual PNG header')
        size = struct.unpack('>II', png[16:24])
        if args.screen == 'mission' and layout.get('orders_page') != args.orders_page:
            raise ValueError('Snapshot command page differs from requested current page')
        required_text = args.required_actions if args.required_actions is not None else (MISSION_ACTIONS if args.orders_page == 'primary' else SECONDARY_ACTIONS)
        required = set(filter(None, required_text.split(',')))
        report = evaluate(layout, size, os_density(Path(args.density).read_text()), required)
        report['orders_page'] = layout.get('orders_page')
        print(json.dumps(report, indent=2, allow_nan=False))
        return 0 if report['gate_passed'] else 1
    except (OSError, ValueError, TypeError, KeyError) as error:
        print(f'Invalid native UI evidence: {error}', file=sys.stderr)
        return 1


if __name__ == '__main__':
    raise SystemExit(main())
