#!/usr/bin/env python3
"""Locate only Android's known first-use immersive confirmation button."""
import pathlib
import re
import sys
import xml.etree.ElementTree as ET

root = ET.fromstring(pathlib.Path(sys.argv[1]).read_text())
nodes = list(root.iter("node"))
system_nodes = [n for n in nodes if n.get("package") in {"android", "com.android.systemui"}]
if not any(n.get("text") == "Viewing full screen" for n in system_nodes):
    raise SystemExit(2)
buttons = [n for n in system_nodes if n.get("text") == "Got it" and n.get("clickable") == "true"]
if len(buttons) != 1:
    raise SystemExit("Known immersive prompt has no unique clickable acknowledgement")
match = re.fullmatch(r"\[(\d+),(\d+)\]\[(\d+),(\d+)\]", buttons[0].get("bounds", ""))
if not match:
    raise SystemExit("Immersive acknowledgement has invalid accessibility bounds")
x1, y1, x2, y2 = map(int, match.groups())
if x2 <= x1 or y2 <= y1:
    raise SystemExit("Immersive acknowledgement has empty accessibility bounds")
print((x1 + x2) // 2, (y1 + y2) // 2)
