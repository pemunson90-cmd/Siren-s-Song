#!/usr/bin/env python3
"""Fill the Phase 5 status column of .fable/PROTECTED_CAPABILITIES.md.

Usage:
  python scripts/repo/ledger_status.py --log CI_LOG --run RUN_ID --sha SHA [--write]

CI_LOG is the text of `gh run view RUN_ID --log` for a full-matrix run. The
script reads every `<PREFIX> CHECKS N FAILURES M` line in it, maps each prefix
to its suite through game/tests/suites.txt (suites registered for the local
profile only are not required), and gives each ledger row:

  PASS      every suite the row names ran in that CI run with FAILURES 0
  an entry from .fable/LEDGER_OVERRIDES.json (keyed by row ID) when one exists;
            overrides carry rows that are checked another way, rows that
            changed under a cited ruling, and rows that wait on Pat
  UNRESOLVED  anything else (a named suite failed or did not run, or the row
            names no suite and has no override)

Without --write it only prints the counts and the unresolved rows. With
--write it adds or replaces the last column, "Phase 5 status", in every ledger
table. It changes no other file and removes nothing. Exit code 1 while any row
is UNRESOLVED.
"""
import argparse
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
LEDGER = ROOT / ".fable" / "PROTECTED_CAPABILITIES.md"
OVERRIDES = ROOT / ".fable" / "LEDGER_OVERRIDES.json"
SUITES = ROOT / "game" / "tests" / "suites.txt"
ROW = re.compile(r"^\|\s*([A-Z0-9]+-[A-Z0-9-]+)\s*\|")
TICK = re.compile(r"`([^`]+)`")
RESULT = re.compile(r"(?:^|\s)((?:[A-Z0-9][A-Z0-9 /&'.+-]*? )?)CHECKS (\d+) FAILURES (\d+)\s*$")
COLUMN = "Phase 5 status"


def registry():
    by_prefix, names, local_only = {}, set(), set()
    for line in SUITES.read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if not line or line.startswith("#"):
            continue
        fields = line.split("|")
        names.add(fields[0])
        if len(fields) > 3 and fields[3].strip() == "-":
            local_only.add(fields[0])
        else:
            by_prefix.setdefault(fields[1].strip(), []).append(fields[0])
    return by_prefix, names, local_only


def ci_results(log_path, by_prefix):
    results = {}
    for line in Path(log_path).read_text(encoding="utf-8", errors="replace").splitlines():
        match = RESULT.search(line)
        if not match:
            continue
        prefix = match.group(1).strip()
        if prefix not in by_prefix:
            continue
        checks, failures = int(match.group(2)), int(match.group(3))
        ok = checks > 0 and failures == 0
        # Suites that share a prefix (partitions of one suite) share one result.
        for suite in by_prefix[prefix]:
            results[suite] = results.get(suite, True) and ok
    return results


def row_suites(cell, names):
    found = []
    for token in TICK.findall(cell):
        token = token.strip()
        if token == "core":
            found.append("run_tests")
        elif token in names:
            found.append(token)
    return found


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--log", required=True)
    parser.add_argument("--run", required=True)
    parser.add_argument("--sha", required=True)
    parser.add_argument("--write", action="store_true")
    args = parser.parse_args()

    by_prefix, names, local_only = registry()
    results = ci_results(args.log, by_prefix)
    overrides = json.loads(OVERRIDES.read_text(encoding="utf-8")) if OVERRIDES.exists() else {}
    method = f"PASS (CI run {args.run} on {args.sha[:8]}, scripted verification)"

    out, counts, unresolved = [], {}, []
    for line in LEDGER.read_text(encoding="utf-8").splitlines():
        stripped = line.strip()
        if stripped.startswith("| ID |") or re.match(r"^\|\s*-{3}", stripped) or ROW.match(line):
            cells = [c.strip() for c in stripped.strip("|").split("|")]
            if len(cells) >= 6:
                cells = cells[:5]
            if stripped.startswith("| ID |"):
                cells.append(COLUMN)
            elif not ROW.match(line):
                cells.append("---")
            else:
                row_id = cells[0]
                suites = row_suites(cells[3], names)
                in_ci = [s for s in suites if s not in local_only]
                suites = in_ci or suites
                if row_id in overrides:
                    status = overrides[row_id]
                elif suites and all(results.get(s) is True for s in suites):
                    status = method
                else:
                    missing = [s for s in suites if results.get(s) is not True]
                    status = "UNRESOLVED" + (": " + ", ".join(missing) if missing else ": no suite named")
                    unresolved.append(f"{row_id}: {status}")
                key = status.split(" ")[0].rstrip(":")
                counts[key] = counts.get(key, 0) + 1
            line = "| " + " | ".join(cells) + " |"
        out.append(line)

    for item in unresolved:
        print(item)
    print("LEDGER STATUS:", ", ".join(f"{k} {v}" for k, v in sorted(counts.items())),
          f"({len(results)} suites read from the CI log)")
    if args.write:
        LEDGER.write_text("\n".join(out) + "\n", encoding="utf-8", newline="\n")
        print("ledger written")
    return 1 if unresolved else 0


if __name__ == "__main__":
    sys.exit(main())
