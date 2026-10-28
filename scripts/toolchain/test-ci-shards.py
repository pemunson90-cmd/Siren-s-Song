#!/usr/bin/env python3
"""Check the actual wrapper's four partitions against the complete CI registry."""
import collections
import pathlib
import shutil
import subprocess

root = pathlib.Path(__file__).resolve().parents[2]


def selection(*args):
    return subprocess.check_output(
        [shutil.which("bash"), "scripts/toolchain/test.sh", "--profile", "ci", "--list", *args],
        cwd=root, text=True,
    ).splitlines()


registered = [line.split("|") for line in (root / "game/tests/suites.txt").read_text().splitlines()
              if line.strip() and not line.startswith("#")]
expected = [row[0] for row in sorted(
    (row for row in registered if row[3] != "-"), key=lambda row: int(row[3]))]
assert selection() == expected, "Full CI selection differs from ranked registry"
assert expected.count("run_tests") == 1, "Core must be registered exactly once"
runtime = [name for name in expected if name != "run_tests"]
assert selection("--skip-core") == runtime
shards = [selection("--skip-core", "--shard", str(i)) for i in range(1, 5)]
for index, shard in enumerate(shards):
    assert shard == runtime[index::4], f"Shard {index + 1} is not deterministic rank-striding"
counts = [len(shard) for shard in shards]
assert min(counts) > 0 and max(counts) - min(counts) <= 1, counts
assigned = [name for shard in shards for name in shard]
assert collections.Counter(assigned + ["run_tests"]) == collections.Counter(expected), (
    "Shard union plus single core must equal full CI registry, without duplicates or omissions")
assert len(assigned) == len(set(assigned)), "Duplicate runtime assignment"
print(f"CI assignment: {len(expected)} registered = 1 core + {counts}; no duplicates/omissions")
