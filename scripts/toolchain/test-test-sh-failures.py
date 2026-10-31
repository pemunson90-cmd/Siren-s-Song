#!/usr/bin/env python3
"""Check that test.sh runs every suite and lists all failures (item 136)."""
import os
import pathlib
import shutil
import subprocess
import sys
import tempfile

toolchain = pathlib.Path(__file__).resolve().parent

REGISTRY = "\n".join([
    "# suite|summary|local|ci",
    "good_tests|GOOD|1|1",
    "nosummary_tests|NOSUM|2|2",
    "errline_tests|ERRL|3|3",
    "",
])

# Fake godot: argument after --script names the suite; behaviour keyed on it.
FAKE_GODOT = r"""#!/usr/bin/env bash
for a in "$@"; do case "$a" in res://tests/*.gd) s="${a#res://tests/}"; s="${s%.gd}";; esac; done
case "$s" in
  good_tests) echo "GOOD CHECKS 5 FAILURES 0" ;;
  nosummary_tests) echo "nothing useful here" ;;
  errline_tests) echo "ERROR: something broke"; echo "ERRL CHECKS 5 FAILURES 0" ;;
  *) echo "unknown $s"; exit 3 ;;
esac
"""

bash = shutil.which("bash")
if bash is None or shutil.which("timeout") is None:
    print("SKIP: bash or timeout unavailable")
    sys.exit(0)


def run(root, fail_mode):
    registry = REGISTRY
    if not fail_mode:
        registry = "# suite|summary|local|ci\ngood_tests|GOOD|1|1\n"
    (root / "game/tests/suites.txt").write_text(registry)
    env = dict(os.environ, GODOT_BIN=str(root / "fake-godot"), JAVA_HOME=str(root),
               TOOLCHAIN_CACHE=str(root / "cache"), ARTIFACT_DIR=str(root / "artifacts"))
    return subprocess.run([bash, str(root / "scripts/toolchain/test.sh"), "--profile", "ci"],
                          env=env, capture_output=True, text=True, timeout=120)


with tempfile.TemporaryDirectory() as tmp:
    root = pathlib.Path(tmp)
    (root / "scripts/toolchain").mkdir(parents=True)
    for name in ("test.sh", "common.sh", "headless.sh"):
        shutil.copy(toolchain / name, root / "scripts/toolchain" / name)
    (root / "game/tests").mkdir(parents=True)
    (root / "game/project.godot").write_text("")
    for name in ("good_tests", "nosummary_tests", "errline_tests"):
        (root / f"game/tests/{name}.gd").write_text("extends SceneTree\n")
    fake = root / "fake-godot"
    fake.write_text(FAKE_GODOT)
    fake.chmod(0o755)

    red = run(root, True)
    out = red.stdout + red.stderr
    assert red.returncode != 0, "failing run must exit non-zero\n" + out
    assert "GOOD CHECKS 5 FAILURES 0" in out, "passing suite did not run\n" + out
    assert (root / "artifacts/errline_tests.log").is_file(), "last suite did not run\n" + out
    lines = [l for l in out.splitlines() if l.startswith("FAILED SUITES:")]
    assert len(lines) == 1, out
    assert lines[0] == "FAILED SUITES: nosummary_tests, errline_tests", lines[0]

    green = run(root, False)
    gout = green.stdout + green.stderr
    assert green.returncode == 0, "all-green run must exit zero\n" + gout
    assert "FAILED SUITES" not in gout, gout

    # A profile with no ranked rows selects nothing; that must be a hard error.
    (root / "game/tests/suites.txt").write_text("# suite|summary|local|ci\ngood_tests|GOOD|1|-\n")
    env = dict(os.environ, GODOT_BIN=str(root / "fake-godot"), JAVA_HOME=str(root),
               TOOLCHAIN_CACHE=str(root / "cache"), ARTIFACT_DIR=str(root / "artifacts"))
    empty = subprocess.run([bash, str(root / "scripts/toolchain/test.sh"), "--profile", "ci"],
                           env=env, capture_output=True, text=True, timeout=120)
    assert empty.returncode != 0, "empty selection must fail\n" + empty.stdout + empty.stderr

print("test.sh failure aggregation checks passed")
