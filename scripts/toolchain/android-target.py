#!/usr/bin/env python3
"""Map a production SS_TARGET logical point to an actual adb screenshot."""
import pathlib
import re
import struct
import sys

log_path, image_path, action = sys.argv[1:]
lines = pathlib.Path(log_path).read_text(errors="replace").splitlines()
last_screen = max((i for i, line in enumerate(lines) if any(marker in line for marker in ("SS_SCREEN ", "SS_MISSION_SELECT ", "SS_VIEW "))), default=-1)
pattern = re.compile(r"SS_TARGET (\S+) center=(-?\d+),(-?\d+) viewport=(\d+),(\d+)")
targets = [match for line in lines[last_screen + 1:] if (match := pattern.search(line)) and match[1] == action]
if not targets:
    print(f"Waiting for current target {action}", file=sys.stderr)
    raise SystemExit(2)
data = pathlib.Path(image_path).read_bytes()
if data[:8] != b"\x89PNG\r\n\x1a\n":
    raise SystemExit("Invalid adb screenshot")
width, height = struct.unpack(">II", data[16:24])
_, x, y, logical_width, logical_height = targets[-1].groups()
if abs((int(logical_width) / int(logical_height)) / (width / height) - 1) > 0.02:
    # A resize can update Android's screenshot before Godot has reported its new layout.
    print(f"Waiting for matching layout: target viewport {logical_width}x{logical_height}, screenshot {width}x{height}", file=sys.stderr)
    raise SystemExit(2)
x, y = round(int(x) * width / int(logical_width)), round(int(y) * height / int(logical_height))
if not (0 <= x < width and 0 <= y < height):
    raise SystemExit(f"Target {action} lies outside screenshot: {x},{y} in {width}x{height}")
print(x, y)
