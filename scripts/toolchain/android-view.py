#!/usr/bin/env python3
"""Validate current native chart state, rather than marker presence alone."""
import argparse
import math
import pathlib
import re

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("log", type=pathlib.Path)
parser.add_argument("--zoom", required=True, type=float)
parser.add_argument("--center", nargs=2, type=float)
parser.add_argument("--panned-from", type=pathlib.Path)
args = parser.parse_args()
number = r"([-+\d.eE]+)"
pattern = re.compile(r"SS_VIEW zoom=" + number + r" center=\(" + number + r",\s*" + number + r"\)")


def current_view(path):
    lines = path.read_text(errors="replace").splitlines()
    boundary = max((i for i, line in enumerate(lines) if "SS_SCREEN " in line or "SS_MISSION_SELECT " in line), default=-1)
    views = [tuple(map(float, match.groups())) for line in lines[boundary + 1:] if (match := pattern.search(line))]
    if not views or not all(math.isfinite(value) for value in views[-1]):
        raise SystemExit("No finite SS_VIEW for the current screen")
    return views[-1]


zoom, x, y = current_view(args.log)
if not math.isclose(zoom, args.zoom, abs_tol=0.02):
    raise SystemExit(f"Expected zoom {args.zoom}, observed {zoom}")
if args.center and any(abs(actual - expected) > 1 for actual, expected in zip((x, y), args.center)):
    raise SystemExit(f"Expected center {args.center}, observed {(x, y)}")
if args.panned_from:
    old_zoom, old_x, old_y = current_view(args.panned_from)
    if abs(zoom - old_zoom) > 0.02 or x <= old_x + 5 or abs(y - old_y) > 2:
        raise SystemExit(f"Left swipe did not pan toward higher world x at unchanged zoom: {(old_zoom, old_x, old_y)} -> {(zoom, x, y)}")
print(f"Verified SS_VIEW zoom={zoom} center=({x},{y})")
