#!/usr/bin/env python3
"""Read-only structural check of .fable/PROTECTED_CAPABILITIES.md.

For every table row with an ID it checks that the ID is unique, that each
repository path named in backticks exists, and that each suite named in the
"How to verify" column is registered in game/tests/suites.txt. It changes
nothing. Exit code 1 when a row fails.
"""
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
LEDGER = ROOT / ".fable" / "PROTECTED_CAPABILITIES.md"
SUITES = ROOT / "game" / "tests" / "suites.txt"
ROW = re.compile(r"^\|\s*([A-Z0-9]+-[A-Z0-9-]+)\s*\|")
TICK = re.compile(r"`([^`]+)`")
PATH_ROOTS = ("game/", "scripts/", "docs/", ".github/", ".claude/", ".fable/", "reference/", "references/", "design/")


def suite_names():
    names = set()
    for line in SUITES.read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if not line or line.startswith("#"):
            continue
        for field in re.split(r"[\s|,]+", line):
            if re.fullmatch(r"[a-z0-9_]+", field):
                names.add(field)
    return names


def main():
    suites = suite_names()
    seen, problems, rows = {}, [], 0
    for number, line in enumerate(LEDGER.read_text(encoding="utf-8").splitlines(), 1):
        match = ROW.match(line)
        if not match:
            continue
        rows += 1
        row_id = match.group(1)
        if row_id in seen:
            problems.append(f"{number}: duplicate ID {row_id} (first at line {seen[row_id]})")
        seen[row_id] = number
        cells = [c.strip() for c in line.strip().strip("|").split("|")]
        for token in TICK.findall(line):
            token = token.strip()
            if token.startswith(PATH_ROOTS) and " " not in token and "*" not in token and "<" not in token:
                if not (ROOT / token.rstrip("/")).exists():
                    problems.append(f"{number}: {row_id}: path not found: {token}")
        if len(cells) >= 4:
            for token in TICK.findall(cells[3]):
                token = token.strip()
                if re.fullmatch(r"[a-z0-9_]+", token) and token != "core" and token not in suites:
                    if not any((ROOT / base / token).exists() for base in ("", "scripts/toolchain", "game/tests")):
                        problems.append(f"{number}: {row_id}: suite not registered: {token}")
    for problem in problems:
        print(problem)
    print(f"LEDGER CHECK {'FAIL' if problems else 'PASS'}: {rows} rows, {len(seen)} IDs, {len(problems)} problem(s)")
    return 1 if problems else 0


if __name__ == "__main__":
    sys.exit(main())
