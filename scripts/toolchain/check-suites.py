#!/usr/bin/env python3
"""Read-only validator for game/tests/suites.txt.

Checks: field format, unique names, positive integer ranks unique per profile
(local and CI), registered files exist, and every entry-point looking test file
(game/tests/*_tests.gd or *_scenarios.gd whose extends chain reaches SceneTree)
is either registered or listed in scripts/toolchain/suites-allowlist.txt.
Also warns about stale allowlist lines. Never modifies anything.

Exit code 0 = no errors (warnings allowed), 1 = errors, 2 = usage/IO problem.
"""
import argparse
import pathlib
import re
import sys

NAME_RE = re.compile(r"[a-z0-9_]+")
SUMMARY_RE = re.compile(r"[A-Z0-9 ]*")
EXTENDS_RE = re.compile(r'^extends\s+(?:"([^"]+)"|([A-Za-z_][A-Za-z0-9_]*))', re.M)


def parse_registry(path, errors):
    rows = []
    for number, line in enumerate(path.read_text(encoding="utf-8").splitlines(), 1):
        if not line.strip() or line.startswith("#"):
            continue
        fields = line.split("|")
        if len(fields) not in (4, 5):
            errors.append(f"suites.txt:{number}: expected 4 or 5 fields, got {len(fields)}: {line}")
            continue
        name, summary, local, ci = fields[:4]
        backend = fields[4] if len(fields) == 5 else "headless"
        if backend not in ("headless", "render"):
            errors.append(f"suites.txt:{number}: {name}: backend must be headless or render, got '{backend}'")
        if not NAME_RE.fullmatch(name):
            errors.append(f"suites.txt:{number}: bad suite name '{name}'")
        if not SUMMARY_RE.fullmatch(summary):
            errors.append(f"suites.txt:{number}: {name}: summary prefix must match [A-Z0-9 ]*, got '{summary}'")
        ranks = []
        for label, value in (("local", local), ("ci", ci)):
            if value == "-":
                ranks.append(None)
            elif re.fullmatch(r"[0-9]+", value) and int(value) > 0:
                ranks.append(int(value))
            else:
                errors.append(f"suites.txt:{number}: {name}: {label} rank must be a positive integer or '-', got '{value}'")
                ranks.append(None)
        rows.append({"line": number, "name": name, "summary": summary,
                     "local": ranks[0], "ci": ranks[1], "backend": backend})
    return rows


def resolve_res(game_dir, ref):
    if ref.startswith("res://"):
        return game_dir / ref[len("res://"):]
    return None


def extends_sceneTree(game_dir, path, seen=None):
    """True when the script's extends chain reaches SceneTree."""
    seen = seen or set()
    for _ in range(12):
        if path in seen or not path.is_file():
            return False
        seen.add(path)
        match = EXTENDS_RE.search(path.read_text(encoding="utf-8", errors="replace"))
        if not match:
            return False
        quoted, bare = match.groups()
        if bare:
            return bare == "SceneTree"
        nxt = resolve_res(game_dir, quoted)
        if nxt is None:
            return False
        path = nxt
    return False


def parse_allowlist(path, warnings):
    entries = {}
    if not path.is_file():
        warnings.append(f"allowlist file missing: {path}")
        return entries
    for number, line in enumerate(path.read_text(encoding="utf-8").splitlines(), 1):
        text = line.split("#", 1)[0].strip()
        if not text:
            continue
        name = text.split("|", 1)[0].strip()
        if not NAME_RE.fullmatch(name):
            warnings.append(f"{path.name}:{number}: unparseable allowlist line: {line}")
            continue
        if name in entries:
            warnings.append(f"{path.name}:{number}: duplicate allowlist entry '{name}'")
        entries[name] = number
    return entries


def main():
    here = pathlib.Path(__file__).resolve().parent
    parser = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    parser.add_argument("--root", type=pathlib.Path, default=here.parent.parent, help="repository root")
    parser.add_argument("--allowlist", type=pathlib.Path, default=here / "suites-allowlist.txt")
    args = parser.parse_args()
    game_dir = args.root / "game"
    tests_dir = game_dir / "tests"
    registry = tests_dir / "suites.txt"
    if not registry.is_file():
        print(f"Missing registry: {registry}", file=sys.stderr)
        return 2

    errors, warnings = [], []
    rows = parse_registry(registry, errors)

    seen_names = {}
    seen_ranks = {"local": {}, "ci": {}}
    for row in rows:
        name = row["name"]
        if name in seen_names:
            errors.append(f"suites.txt:{row['line']}: duplicate suite name '{name}' (first at line {seen_names[name]})")
        else:
            seen_names[name] = row["line"]
        for profile in ("local", "ci"):
            rank = row[profile]
            if rank is None:
                continue
            if rank in seen_ranks[profile]:
                errors.append(f"suites.txt:{row['line']}: {name}: duplicate {profile} rank {rank} "
                              f"(also {seen_ranks[profile][rank]})")
            else:
                seen_ranks[profile][rank] = name
        if row["local"] is None and row["ci"] is None:
            warnings.append(f"suites.txt:{row['line']}: {name} is excluded from both profiles")
        script = tests_dir / (name + ".gd")
        if not script.is_file():
            errors.append(f"suites.txt:{row['line']}: registered suite '{name}' has no file {script.relative_to(args.root).as_posix()}")
        elif not extends_sceneTree(game_dir, script):
            warnings.append(f"suites.txt:{row['line']}: {name} does not resolve to a SceneTree entry point")

    allow = parse_allowlist(args.allowlist, warnings)
    registered = set(seen_names)
    candidates, helpers = [], []
    for script in sorted(list(tests_dir.glob("*_tests.gd")) + list(tests_dir.glob("*_scenarios.gd"))):
        if extends_sceneTree(game_dir, script):
            candidates.append(script.stem)
        elif script.stem not in registered:
            helpers.append(script.stem)
    unregistered = [c for c in candidates if c not in registered and c not in allow]
    for name in unregistered:
        errors.append(f"entry-point suite '{name}' is neither registered in suites.txt nor in {args.allowlist.name}")
    for name, number in allow.items():
        if name in registered:
            warnings.append(f"{args.allowlist.name}:{number}: '{name}' is allowlisted but also registered")
        elif not (tests_dir / (name + ".gd")).is_file():
            warnings.append(f"{args.allowlist.name}:{number}: '{name}' is allowlisted but its file is missing")
        elif name not in candidates:
            warnings.append(f"{args.allowlist.name}:{number}: '{name}' is allowlisted but is not an entry-point suite")

    print(f"Registry: {registry.as_posix()}")
    print(f"Registered suites: {len(rows)}  (local profile {len(seen_ranks['local'])}, ci profile {len(seen_ranks['ci'])})")
    print(f"Entry-point candidates (*_tests.gd / *_scenarios.gd extending SceneTree): {len(candidates)}")
    print(f"Unregistered name matches that do not extend SceneTree (helpers, ignored): {len(helpers)}")
    print(f"Allowlisted: {len(allow)}")
    for message in errors:
        print("ERROR:   " + message)
    for message in warnings:
        print("WARNING: " + message)
    print(f"Result: {'FAIL' if errors else 'OK'} ({len(errors)} errors, {len(warnings)} warnings)")
    return 1 if errors else 0


if __name__ == "__main__":
    sys.exit(main())
