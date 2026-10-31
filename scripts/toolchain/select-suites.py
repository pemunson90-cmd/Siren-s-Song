#!/usr/bin/env python3
"""Choose the runtime suites a pull request push must run, or ask for the full matrix.

Usage: select-suites.py --base SHA [--head REF] [--root DIR] [--changed PATH ...]

The dependency map comes from every quoted res:// string literal (double or
single quotes, anywhere: preload, load, extends, dictionaries, constants) in
game scripts and text resources (.gd, .tscn, .tres), followed transitively.
A suite depends on everything it reaches without passing through a serial zone.
A changed game/src file selects every suite that reaches it, directly or through
other scripts. When in doubt it asks for the full matrix: a file that any
serial zone (main.gd, mission_hud.gd, ocean_view.gd, simulation.gd) reaches
transitively, a file no suite reaches, a non-suite test helper, shared test
infrastructure, game files outside src and tests, or more than 60 suites.
The merge candidate and the nightly always run the full matrix, which backs up
this static map.

Prints key=value lines for $GITHUB_OUTPUT on stdout:
  full=true|false
  reason=<why the full matrix was chosen, or "affected">
  suites=<comma-separated CI-registered suites in CI rank order, canaries last>
and a human-readable explanation on stderr. Core (run_tests) is never listed
because the game-core job already runs it.
"""
import argparse
import pathlib
import re
import subprocess
import sys

SERIAL_ZONES = {
    "game/src/main.gd",
    "game/src/presentation/mission_hud.gd",
    "game/src/presentation/ocean_view.gd",
    "game/src/simulation/simulation.gd",
}
FULL_PREFIXES = (".github/workflows/", "scripts/toolchain/", "game/tests/fixtures/")
FULL_FILES = {"game/tests/suites.txt"}
# Shard balance data only; it never changes what a suite checks.
IGNORED_FILES = {"game/tests/suite-times.json"}
MAX_SUITES = 60
REF_RE = re.compile(r'"(res://[^"\n]+)"|\'(res://[^\'\n]+)\'')
FOLLOWED = (".gd", ".tscn", ".tres")


def registry(root):
    rows = {}
    for line in (root / "game/tests/suites.txt").read_text(encoding="utf-8").splitlines():
        if not line.strip() or line.startswith("#"):
            continue
        fields = line.split("|")
        rows[fields[0]] = None if fields[3] == "-" else int(fields[3])
    return rows


def canaries(root):
    path = root / "scripts/toolchain/canaries.txt"
    if not path.is_file():
        return []
    names = []
    for line in path.read_text(encoding="utf-8").splitlines():
        line = line.split("#", 1)[0].strip()
        if line and line not in names:
            names.append(line)
    return names


def refs(root, rel, cache={}):
    if rel not in cache:
        try:
            text = (root / rel).read_text(encoding="utf-8")
        except (FileNotFoundError, IsADirectoryError, UnicodeDecodeError):
            text = ""
        cache[rel] = {"game/" + (a or b)[len("res://"):] for a, b in REF_RE.findall(text)}
    return cache[rel]


def closure(root, start, stop=frozenset()):
    """Everything start reaches, without following files listed in stop."""
    seen, stack = {start}, [start]
    while stack:
        for ref in refs(root, stack.pop()):
            if ref not in seen:
                seen.add(ref)
                if ref.endswith(FOLLOWED) and ref not in stop:
                    stack.append(ref)
    return seen


def changed_files(root, base, head):
    out = subprocess.check_output(
        ["git", "diff", "--name-only", "--no-renames", base, head], cwd=root, text=True)
    return [line for line in out.splitlines() if line]


def select(root, changed):
    """Return (full, reason, suites) for the given changed repository paths."""
    rows = registry(root)
    # Only CI-registered runtime suites can be selected; core already ran.
    ci = [name for name, rank in rows.items() if rank is not None and name != "run_tests"]
    deps = {name: closure(root, f"game/tests/{name}.gd", SERIAL_ZONES) for name in ci}
    serial = set().union(*(closure(root, zone) for zone in sorted(SERIAL_ZONES)))
    chosen, notes = set(), []
    for path in sorted(set(changed)):
        rel = path[:-4] if path.endswith(".uid") else path
        if (rel in IGNORED_FILES or rel.endswith(".md")
                or not rel.startswith(("game/", ".github/", "scripts/toolchain/"))):
            continue
        if rel in SERIAL_ZONES:
            return True, f"serial zone {rel}", []
        if rel in FULL_FILES or rel.startswith(FULL_PREFIXES):
            return True, f"shared test infrastructure {rel}", []
        if rel.startswith("game/tests/"):
            name = rel[len("game/tests/"):]
            if not ("/" not in name and name.endswith(".gd") and name[:-3] in rows):
                return True, f"shared test helper {rel}", []
        elif not rel.startswith("game/src/"):
            return True, f"game file outside src and tests {rel}", []
        if rel in serial:
            return True, f"serial zone reaches {rel}", []
        hit = {s for s, d in deps.items() if rel in d}
        if not hit and rel.startswith("game/src/"):
            return True, f"no suite reaches {rel}", []
        notes.append(f"{rel}: {len(hit)} suites")
        chosen |= hit
    if len(chosen) > MAX_SUITES:
        return True, f"{len(chosen)} affected suites exceed {MAX_SUITES}", []
    ordered = sorted(chosen, key=lambda name: rows[name])
    for name in canaries(root):
        if name not in rows:
            raise SystemExit(f"Unknown canary suite: {name}")
        if name in ci and name not in ordered:
            ordered.append(name)
    for note in notes:
        print(note, file=sys.stderr)
    return False, "affected", ordered


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--base")
    parser.add_argument("--head", default="HEAD")
    parser.add_argument("--root", default=str(pathlib.Path(__file__).resolve().parents[2]))
    parser.add_argument("--changed", nargs="*", help="changed paths instead of a git diff")
    args = parser.parse_args()
    root = pathlib.Path(args.root)
    if args.changed is not None:
        changed = args.changed
    elif args.base:
        changed = changed_files(root, args.base, args.head)
    else:
        parser.error("--base or --changed is required")
    full, reason, suites = select(root, changed)
    print(f"{len(changed)} changed files; full matrix: {full} ({reason}); "
          f"{len(suites)} suites selected", file=sys.stderr)
    print(f"full={'true' if full else 'false'}")
    print(f"reason={reason}")
    print(f"suites={','.join(suites)}")


if __name__ == "__main__":
    main()
