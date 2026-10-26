"""Validate and aggregate external X2 JSON; no production instrumentation.

Usage: python3 game/tests/x2_pressure_report.py REPORT_DIRECTORY
"""
import collections
import json
import pathlib
import statistics
import sys

path = pathlib.Path(sys.argv[1])
rows = json.loads((path / "rows.json").read_text())
assert len({(r["operation"], r["policy"]) for r in rows}) == len(rows)
for row in rows:
    row["rejected_scout_routes"] = sum(c["order"] == "route" and c["unit"] > 0 and not c["accepted"] for c in row["commands"])
    assert 0 < row["seconds"] <= row["budget_seconds"] + .02, row
    assert 0 <= row["hull"] <= 100, row
    assert row["snapshot_valid"], (row["operation"], row["policy"], "invalid snapshot")
    for tool, initial in {"emp": 2, "decoy": 3, "recon": 2, "knock": 2}.items():
        assert row["tools_spent"][tool] == initial - row["tools_remaining"][tool]
        assert row["tools_spent"][tool] == row["accepted"].get(tool, 0)
    if row["policy"] == "quietus_only":
        assert row["drone_losses"] == 0
        assert not any(row["tools_spent"].values())
        assert not any(c["unit"] for c in row["commands"])
    assert row["quietus_beam_seconds"] <= row["quietus_locked_seconds"] + .001
required = {(id_, policy) for id_ in range(14, 30) for policy in
            ("cautious", "aggressive", "drone_heavy", "quietus_only")}
assert required <= {(r["operation"], r["policy"]) for r in rows}, "Missing newer operations"
lines = [f"X2 pressure probes: {len(rows)} rows, report integrity checks passed.",
         "All runs use source-known objective/physical work/extraction routes, operation-data dimensions, 900s budget, endurance, no fittings, default history.",
         "Glass Reach operations14-21 replay the current glass_reach_journeys.gd COURSES, including authored depth crossings, work, material recovery and named exit selection.",
         "cautious: silent Quietus, parked live drones, fresh-contact defensive finite tools.",
         "aggressive: cruise Quietus, sonar every20s, recon at1/90s, knock/EMP/decoy defense.",
         "drone_heavy: silent Quietus, two independent open-profile transit scouts per Quietus leg, drone sonar attempts every25s (shared pulse cooldown) and recon, contact defense.",
         "quietus_only: silent, drones absent at initial launch, no finite tools/sonar. Absent drones excluded from loss counts.",
         "Metrics: lock/beam durations sample live enemy targets each1/60s for logging; policy reacts only to fresh observed contacts.",
         "Defense trigger is a fresh observed lock>=1s; it does not parse industrial windups. Industrial strikes/pressure can reduce hull/load hull while ordinary lock/beam metrics remain zero.",
         "Losses count dead launched drones, including battery exhaustion; causes/identities are not separately classified. Extraction can leave living drones; retrieval is not required by this policy.",
         "One run per policy/operation; default launch history, no fittings, no earned-profile or statistical/player-skill claim. Authored routes do not measure risk of every shortcut.",
         "Controller rejection/stops/timeouts are controller findings, not balance verdicts. Scripted policies are not human play.", "",
         "policy | rows | outcomes | mean hull | min hull | mean time | drone losses | tools spent (emp/decoy/recon/knock) | locked seconds / beam seconds"]
for label, data in [("All operations", rows), ("Newer operations14-29", [r for r in rows if r["operation"] >= 14])]:
    lines.append(label)
    for policy in ("cautious", "aggressive", "drone_heavy", "quietus_only"):
        subset = [r for r in data if r["policy"] == policy]
        outcomes = dict(collections.Counter(r["outcome"] for r in subset))
        tools = "/".join(str(sum(r["tools_spent"][tool] for r in subset)) for tool in ("emp", "decoy", "recon", "knock"))
        lines.append(f"{policy} | {len(subset)} | {outcomes} | {statistics.mean(r['hull'] for r in subset):.2f} | {min(r['hull'] for r in subset):.2f} | {statistics.mean(r['seconds'] for r in subset):.2f} | {sum(r['drone_losses'] for r in subset)} | {tools} | {sum(r['quietus_locked_seconds'] for r in subset):.2f} / {sum(r['quietus_beam_seconds'] for r in subset):.2f}")
lines += ["", "Difficulty curve (each cell: result/outcome; hull; seconds; drone losses; locked seconds; beam seconds):",
          "operation | cautious | aggressive | drone_heavy | quietus_only",
          "--- | --- | --- | --- | ---"]
by_key = {(r["operation"], r["policy"]): r for r in rows}
for id_ in range(14, 30):
    cells = []
    for policy in ("cautious", "aggressive", "drone_heavy", "quietus_only"):
        r = by_key[id_, policy]
        result = "win" if r["outcome"] == "won" else "loss" if r["outcome"] == "lost" else "controller finding"
        cells.append(f"{result}/{r['outcome']}; {r['hull']:.2f}; {r['seconds']:.2f}; {r['drone_losses']}; {r['quietus_locked_seconds']:.2f}; {r['quietus_beam_seconds']:.2f}")
    lines.append(f"{id_} | " + " | ".join(cells))
lines += ["", "Exceptions:"]
for row in rows:
    if row["outcome"] != "won" or row["hull"] < 100 or row["drone_losses"] or row["rejected_scout_routes"]:
        lines.append(f"op{row['operation']} {row['policy']}: {row['outcome']}, hull={row['hull']:.2f}, t={row['seconds']:.2f}, drones lost={row['drone_losses']}, optional scout-route rejects={row['rejected_scout_routes']}, load hull={row['load_hull']}, {row['message']}")
report = "\n".join(lines) + "\n"
(path / "summary.txt").write_text(report)
print(report)
