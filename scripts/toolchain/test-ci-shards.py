#!/usr/bin/env python3
"""Check the actual wrapper's four partitions against the complete CI registry."""
import collections
import json
import pathlib
import shutil
import statistics
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
    assert shard, f"Shard {index + 1} is empty"
    assert shard == [name for name in runtime if name in shard], (
        f"Shard {index + 1} does not run in CI rank order")
times_path = root / "game/tests/suite-times.json"
if times_path.is_file():
    # Duration-balanced: no shard may exceed the lightest by more than its longest suite.
    times = json.loads(times_path.read_text())
    median = statistics.median(times[name] for name in runtime if name in times)
    loads = [sum(times.get(name, median) for name in shard) for shard in shards]
    longest = max(times.get(name, median) for name in runtime)
    assert max(loads) - min(loads) <= longest, loads
    balance = "duration-balanced, estimated seconds " + str([round(load) for load in loads])
else:
    for index, shard in enumerate(shards):
        assert shard == runtime[index::4], f"Shard {index + 1} is not deterministic rank-striding"
    counts = [len(shard) for shard in shards]
    assert max(counts) - min(counts) <= 1, counts
    balance = "rank-striding"
assigned = [name for shard in shards for name in shard]
assert collections.Counter(assigned + ["run_tests"]) == collections.Counter(expected), (
    "Shard union plus single core must equal full CI registry, without duplicates or omissions")
assert len(assigned) == len(set(assigned)), "Duplicate runtime assignment"
assert selection("--suites", ",".join(reversed(runtime[:3]))) == runtime[:3], (
    "--suites must list the named suites in CI rank order")
counts = [len(shard) for shard in shards]
print(f"CI assignment: {len(expected)} registered = 1 core + {counts}; {balance}; "
      "no duplicates/omissions")
