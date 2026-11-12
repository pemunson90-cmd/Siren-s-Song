#!/usr/bin/env python3
"""Critic play kit: build an isolated copy of the game and drive it by touch.

A kit is a folder outside the repository that holds one exported snapshot of
`game/`, the driver, and a control folder per slot. A blind critic plays the
real game through it: every input is a parsed touch, drag or key event, and
every observation is a screenshot of the rendered viewport. The kit never
reads game state and never writes a save itself.

  kit.py new --ref <git ref> --out <kit folder>
      Export `game/` at the ref into a new kit folder and import it once.
  kit.py launch --kit <kit> --slot a --view cover|inner --session <name>
      Start one game instance for that slot. Each session and view has its own
      isolated user data under <kit>/private/<session>/<view>.
  kit.py send --kit <kit> --slot a '<json>'
      Send one command and print the matching result. See README.md.
  kit.py quit --kit <kit> --slot a

Evidence (screenshots, journals, saves) stays in the kit folder, outside the
repository. Windows only: the driver needs a real GPU window.
"""
import argparse
import io
import json
import os
import pathlib
import subprocess
import sys
import tarfile
import time
import uuid

HERE = pathlib.Path(__file__).resolve().parent
REPO = HERE.parent.parent
VIEWS = {"cover": "2520x1080", "inner": "2184x1968"}
GODOT_NAME = "Godot_v4.6.3-stable_win64_console.exe"


def godot_exe():
    override = os.environ.get("GODOT_BIN")
    if override:
        return pathlib.Path(override)
    cache = os.environ.get("TOOLCHAIN_CACHE") or str(pathlib.Path.home() / ".cache" / "sirens-song-toolchain")
    return pathlib.Path(cache) / "win" / GODOT_NAME


def safe_name(value, what):
    if not value or any(ch in value for ch in ("/", chr(92), ":")) or value in (".", ".."):
        raise SystemExit("%s must be a plain name without path separators: %r" % (what, value))
    return value


def cmd_new(args):
    out = pathlib.Path(args.out).resolve()
    if out == REPO or REPO in out.parents:
        raise SystemExit("A kit must live outside the repository: %s" % out)
    if out.exists() and any(out.iterdir()):
        raise SystemExit("Kit folder already exists and is not empty: %s" % out)
    out.mkdir(parents=True, exist_ok=True)
    sha = subprocess.run(["git", "-C", str(REPO), "rev-parse", args.ref], capture_output=True, text=True, check=True).stdout.strip()
    archive = subprocess.run(["git", "-C", str(REPO), "archive", "--format=tar", sha, "game"], capture_output=True, check=True).stdout
    with tarfile.open(fileobj=io.BytesIO(archive)) as tar:
        tar.extractall(out, filter="data")
    (out / "driver.gd").write_bytes((HERE / "driver.gd").read_bytes())
    for name in ("control", "private", "evidence", "audit"):
        (out / name).mkdir(exist_ok=True)
    (out / "kit.json").write_text(json.dumps({"source": sha, "ref": args.ref, "created": time.strftime("%Y-%m-%d %H:%M:%S")}, indent=2), encoding="utf-8")
    log = out / "import.log"
    # The import runs with its own user folders so the editor writes no
    # settings or cache into the real user profile.
    user = out / "private" / "_import"
    (user / "Roaming").mkdir(parents=True, exist_ok=True)
    (user / "Local").mkdir(parents=True, exist_ok=True)
    env = dict(os.environ, APPDATA=str(user / "Roaming"), LOCALAPPDATA=str(user / "Local"))
    with log.open("wb") as handle:
        code = subprocess.run([str(godot_exe()), "--headless", "--path", str(out / "game"), "--editor", "--import", "--quit"], env=env, stdout=handle, stderr=subprocess.STDOUT).returncode
    print("kit %s at %s, import exit %d (log %s)" % (out, sha[:8], code, log))
    return code


def slot_dir(kit, slot):
    path = pathlib.Path(kit).resolve() / "control" / safe_name(slot, "--slot")
    path.mkdir(parents=True, exist_ok=True)
    return path


def cmd_launch(args):
    kit = pathlib.Path(args.kit).resolve()
    control = slot_dir(kit, args.slot)
    pid_file = control / "runtime.pid"
    if pid_file.exists() and _alive(int(pid_file.read_text().strip() or 0)):
        raise SystemExit("Slot %s already has a live runtime (pid %s). Quit it first." % (args.slot, pid_file.read_text().strip()))
    for stale in control.glob("request-*.json"):
        stale.rename(stale.with_name("stale-" + stale.name))
    user = kit / "private" / safe_name(args.session, "--session") / args.view
    (user / "Roaming").mkdir(parents=True, exist_ok=True)
    (user / "Local").mkdir(parents=True, exist_ok=True)
    env = dict(os.environ)
    env["APPDATA"] = str(user / "Roaming")
    env["LOCALAPPDATA"] = str(user / "Local")
    env["PLAYKIT_CONTROL"] = str(control)
    env["PLAYKIT_SIZE"] = VIEWS[args.view]
    log = open(control / ("runtime-%s.log" % time.strftime("%Y%m%dT%H%M%S")), "wb")
    process = subprocess.Popen(
        [str(godot_exe()), "--path", str(kit / "game"), "--rendering-method", "gl_compatibility",
         "--resolution", VIEWS[args.view], "--position", "0,0", "--script", str(kit / "driver.gd")],
        env=env, stdout=log, stderr=subprocess.STDOUT,
        creationflags=getattr(subprocess, "CREATE_NEW_PROCESS_GROUP", 0) | getattr(subprocess, "CREATE_NO_WINDOW", 0),
    )
    pid_file.write_text(str(process.pid))
    time.sleep(args.settle)
    wanted = "(%s)" % VIEWS[args.view].replace("x", ", ")
    reply = {}
    for _ in range(20):
        reply = send(kit, args.slot, {"command": "geometry"}, timeout=60)
        if reply.get("texture_size") == wanted:
            break
        time.sleep(0.5)
    ready = reply.get("texture_size") == wanted
    print(json.dumps({"pid": process.pid, "session": args.session, "view": args.view, "wanted": VIEWS[args.view], "ready": ready, "geometry": reply}))
    return 0 if ready else 1


def _alive(pid):
    if pid <= 0:
        return False
    out = subprocess.run(["tasklist", "/FI", "PID eq %d" % pid, "/NH"], capture_output=True, text=True).stdout
    return str(pid) in out


def send(kit, slot, request, timeout=150):
    control = slot_dir(kit, slot)
    request_id = "%d-%s" % (time.time_ns(), uuid.uuid4().hex[:8])
    temporary = control / ("pending-%s.tmp" % request_id)
    temporary.write_text(json.dumps(request), encoding="utf-8")
    temporary.rename(control / ("request-%s.json" % request_id))
    result = control / ("result-%s.json" % request_id)
    deadline = time.time() + timeout
    while time.time() < deadline:
        if result.exists():
            return json.loads(result.read_text(encoding="utf-8"))
        time.sleep(0.05)
    raise SystemExit("No result for request %s within %ds. Do not send another command; check the runtime." % (request_id, timeout))


def cmd_send(args):
    request = json.loads(args.json)
    reply = send(args.kit, args.slot, request, timeout=args.timeout)
    print(json.dumps(reply))
    return 0 if reply.get("ok") else 1


def cmd_quit(args):
    reply = send(args.kit, args.slot, {"command": "quit"}, timeout=30)
    print(json.dumps(reply))
    return 0


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = parser.add_subparsers(dest="action", required=True)
    new = sub.add_parser("new")
    new.add_argument("--ref", required=True)
    new.add_argument("--out", required=True)
    new.set_defaults(run=cmd_new)
    launch = sub.add_parser("launch")
    launch.add_argument("--kit", required=True)
    launch.add_argument("--slot", default="a")
    launch.add_argument("--view", choices=sorted(VIEWS), default="cover")
    launch.add_argument("--session", required=True)
    launch.add_argument("--settle", type=float, default=4.0)
    launch.set_defaults(run=cmd_launch)
    snd = sub.add_parser("send")
    snd.add_argument("--kit", required=True)
    snd.add_argument("--slot", default="a")
    snd.add_argument("--timeout", type=int, default=150)
    snd.add_argument("json")
    snd.set_defaults(run=cmd_send)
    qt = sub.add_parser("quit")
    qt.add_argument("--kit", required=True)
    qt.add_argument("--slot", default="a")
    qt.set_defaults(run=cmd_quit)
    args = parser.parse_args()
    sys.exit(args.run(args))


if __name__ == "__main__":
    main()
