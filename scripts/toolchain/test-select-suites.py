#!/usr/bin/env python3
"""Check select-suites.py against a small fixture tree, including one real git diff."""
import pathlib
import shutil
import subprocess
import sys
import tempfile

script = pathlib.Path(__file__).resolve().with_name("select-suites.py")

FILES = {
    "game/project.godot": "",
    "game/tests/suites.txt": "\n".join([
        "# suite|summary|local|ci",
        "run_tests||1|1",
        "alpha_tests|ALPHA|2|3",
        "beta_tests|BETA|3|2",
        "gamma_tests|GAMMA|4|4",
        "local_only_tests|LOCAL ONLY|5|-",
        "delta_tests|DELTA|6|5",
        "epsilon_tests|EPSILON|7|6",
        "zeta_tests|ZETA|8|7",
        "",
    ]),
    "game/tests/run_tests.gd": 'extends SceneTree\nconst S = preload("res://src/simulation/simulation.gd")\n',
    # alpha names a source directly and reaches another through a test helper.
    "game/tests/alpha_tests.gd": 'extends "res://tests/shared_helper.gd"\n'
                                 'const A = preload("res://src/feature/a.gd")\n',
    "game/tests/shared_helper.gd": 'extends SceneTree\nconst H = load("res://src/feature/h.gd")\n',
    # beta extends a registered suite, so it depends on alpha's sources too.
    "game/tests/beta_tests.gd": 'extends "res://tests/alpha_tests.gd"\n',
    "game/tests/gamma_tests.gd": 'extends SceneTree\nconst B = preload("res://src/feature/b.gd")\n'
                                 'const M = preload("res://src/main.gd")\n'
                                 'const C = preload("res://src/feature/cam.gd")\n',
    "game/tests/local_only_tests.gd": 'extends SceneTree\nconst A = preload("res://src/feature/a.gd")\n',
    "game/tests/delta_tests.gd": 'extends SceneTree\nconst W = preload("res://src/feature/wrapper.gd")\n',
    # epsilon names flow.gd directly, but main.gd (a serial zone) also preloads it.
    "game/tests/epsilon_tests.gd": 'extends SceneTree\nconst F = preload("res://src/feature/flow.gd")\n',
    # zeta names dict.gd only inside a single-quoted dictionary value.
    "game/tests/zeta_tests.gd": "extends SceneTree\nconst ROUTES = {\"a\": 'res://src/feature/dict.gd'}\n",
    "game/tests/suite-times.json": "{}\n",
    "game/tests/fixtures/sample.json": "{}\n",
    "game/src/main.gd": 'const D = preload("res://src/feature/deep.gd")\n'
                        'const F = preload("res://src/feature/flow.gd")\n',
    "game/src/feature/flow.gd": "",
    "game/src/feature/dict.gd": "",
    # gamma names cam.gd directly; delta also reaches it through wrapper.gd.
    "game/src/feature/cam.gd": "",
    "game/src/simulation/simulation.gd": "",
    "game/src/feature/a.gd": "",
    "game/src/feature/b.gd": "",
    "game/src/feature/h.gd": "",
    # inner.gd is named by no suite; delta reaches it through wrapper.gd.
    "game/src/feature/wrapper.gd": 'const I = preload("res://src/feature/inner.gd")\n'
                                   "const PATHS = ['res://src/feature/cam.gd']\n",
    "game/src/feature/inner.gd": "",
    # deep.gd is reached only through main.gd, a serial zone.
    "game/src/feature/deep.gd": "",
    "game/assets/icon.png": "",
    "scripts/toolchain/canaries.txt": "# canaries\ngamma_tests\nrun_tests  # core is skipped\n",
}


def run(root, *args):
    out = subprocess.check_output(
        [sys.executable, "-I", str(script), "--root", str(root), *args],
        text=True, stderr=subprocess.DEVNULL)
    values = dict(line.split("=", 1) for line in out.splitlines())
    return values["full"] == "true", values["reason"], [s for s in values["suites"].split(",") if s]


def changed(root, *paths):
    return run(root, "--changed", *paths)


with tempfile.TemporaryDirectory() as tmp:
    root = pathlib.Path(tmp)
    for rel, text in FILES.items():
        (root / rel).parent.mkdir(parents=True, exist_ok=True)
        (root / rel).write_text(text)

    # Direct source: alpha names a.gd, beta inherits it; CI rank order; canary last.
    assert changed(root, "game/src/feature/a.gd") == (False, "affected",
                                                      ["beta_tests", "alpha_tests", "gamma_tests"])
    # Through a test helper; .uid sidecars count as their script.
    assert changed(root, "game/src/feature/h.gd.uid")[2] == ["beta_tests", "alpha_tests", "gamma_tests"]
    # A changed suite selects itself plus suites that extend it.
    assert changed(root, "game/tests/alpha_tests.gd")[2] == ["beta_tests", "alpha_tests", "gamma_tests"]
    assert changed(root, "game/tests/gamma_tests.gd")[2] == ["gamma_tests"]
    # Indirect reach through another source script when no suite names the file.
    assert changed(root, "game/src/feature/inner.gd")[2] == ["delta_tests", "gamma_tests"]
    # A suite naming a file directly does not hide suites reaching it indirectly.
    assert changed(root, "game/src/feature/cam.gd")[2] == ["gamma_tests", "delta_tests"]
    # References inside dictionaries and single quotes count.
    assert changed(root, "game/src/feature/dict.gd")[2] == ["zeta_tests", "gamma_tests"]
    # Docs, shard timings and non-game files select nothing but the canaries.
    assert changed(root, "docs/notes.md", "game/tests/suite-times.json", "README.md") == (
        False, "affected", ["gamma_tests"])
    # Local-only suites are never selected for CI.
    assert "local_only_tests" not in changed(root, "game/tests/local_only_tests.gd")[2]

    full_cases = {
        "game/src/main.gd": "serial zone",
        "game/src/presentation/mission_hud.gd": "serial zone",
        "game/src/presentation/ocean_view.gd": "serial zone",
        "game/src/simulation/simulation.gd.uid": "serial zone",
        "game/tests/suites.txt": "shared test infrastructure",
        "game/tests/fixtures/sample.json": "shared test infrastructure",
        "scripts/toolchain/test.sh": "shared test infrastructure",
        ".github/workflows/gauntlet-pr-checks.yml": "shared test infrastructure",
        "game/tests/shared_helper.gd": "shared test helper",
        "game/assets/icon.png": "game file outside src and tests",
        "game/project.godot": "game file outside src and tests",
        "game/src/feature/deep.gd": "serial zone reaches",
        "game/src/feature/flow.gd": "serial zone reaches",
        "game/src/feature/unreferenced.gd": "no suite reaches",
    }
    for path, reason in full_cases.items():
        full, why, suites = changed(root, "game/src/feature/b.gd", path)
        assert full and why.startswith(reason) and suites == [], (path, why)

    # More than 60 affected suites falls back to the full matrix.
    big = root / "big"
    shutil.copytree(root, big)
    rows = ["run_tests||1|1"]
    for index in range(61):
        rows.append(f"many{index}_tests|MANY {index}|{index + 2}|{index + 2}")
        (big / f"game/tests/many{index}_tests.gd").write_text(
            'extends SceneTree\nconst A = preload("res://src/feature/a.gd")\n')
    (big / "game/tests/suites.txt").write_text("\n".join(rows) + "\n")
    (big / "scripts/toolchain/canaries.txt").write_text("")
    assert changed(big, "game/src/feature/a.gd")[:2] == (True, "61 affected suites exceed 60")
    (big / "game/tests/many60_tests.gd").write_text("extends SceneTree\n")
    assert len(changed(big, "game/src/feature/a.gd")[2]) == 60

    # A real git diff between two commits.
    git = ["git", "-c", "user.name=t", "-c", "user.email=t@example.invalid"]
    subprocess.run(git + ["init", "-q"], cwd=root, check=True)
    subprocess.run(git + ["add", "-A"], cwd=root, check=True)
    subprocess.run(git + ["commit", "-qm", "base"], cwd=root, check=True)
    (root / "game/src/feature/b.gd").write_text("# edited\n")
    subprocess.run(git + ["commit", "-qam", "edit"], cwd=root, check=True)
    assert run(root, "--base", "HEAD~1", "--head", "HEAD") == (False, "affected", ["gamma_tests"])

# The two misses found in review, against the real tree: main.gd preloads
# campaign_flow.gd; ocean_view.gd and photo_pricing.gd preload camera_feed.gd.
repo = script.parents[2]
for path in ("game/src/presentation/flow/campaign_flow.gd", "game/src/presentation/camera_feed.gd"):
    if (repo / path).is_file():
        full, why, _ = changed(repo, path)
        assert full and why.startswith("serial zone reaches"), (path, why)

print("select-suites: direct, helper, inherited, indirect, union, dictionary, canary, ignore, "
      f"{len(full_cases)} fallback, size-limit and git-diff cases pass")
