#!/usr/bin/env python3
"""Merge per-suite wall times written by test.sh into suite-times.json form.

Usage: suite-times.py --out PATH TSV [TSV ...]

Each TSV line is `suite<TAB>seconds` (test.sh appends one per suite it runs to
$ARTIFACT_DIR/suite-times.tsv). A suite seen more than once keeps its longest
time. The output maps suite name to seconds, sorted by name, which is the shape
test.sh --shard reads from game/tests/suite-times.json.
"""
import argparse
import json
import pathlib


def merge(paths):
    times = {}
    for path in paths:
        for line in pathlib.Path(path).read_text(encoding="utf-8").splitlines():
            if not line.strip():
                continue
            name, seconds = line.split("\t")
            times[name] = max(times.get(name, 0.0), float(seconds))
    return dict(sorted(times.items()))


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--out", required=True)
    parser.add_argument("tsv", nargs="+")
    args = parser.parse_args()
    times = merge(args.tsv)
    pathlib.Path(args.out).write_text(json.dumps(times, indent=1) + "\n", encoding="utf-8")
    print(f"{len(times)} suites, {round(sum(times.values()))} s total -> {args.out}")


if __name__ == "__main__":
    main()
