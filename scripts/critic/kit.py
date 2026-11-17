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
  kit.py launch ... --headless          (WP-123) no window; drive by state / order / run
  kit.py state --kit <kit> --slot a [--truth]
  kit.py order --kit <kit> --slot a '{"order":"route","craft":"QUIETUS","points":[[x,y]]}'
  kit.py run --kit <kit> --slot a --seconds 30 [--speed 4]

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
    # WP-123: --headless runs the game with no window (Godot's own --headless). state, order, run and debug work;
    # screenshot, taps and labels answer a clear refusal. Playing by state/order/run needs no GPU window.
    if args.headless:
        command = [str(godot_exe()), "--headless", "--path", str(kit / "game"), "--script", str(kit / "driver.gd")]
    else:
        command = [str(godot_exe()), "--path", str(kit / "game"), "--rendering-method", "gl_compatibility",
                   "--resolution", VIEWS[args.view], "--position", "0,0", "--script", str(kit / "driver.gd")]
    process = subprocess.Popen(
        command,
        env=env, stdout=log, stderr=subprocess.STDOUT,
        creationflags=getattr(subprocess, "CREATE_NEW_PROCESS_GROUP", 0) | getattr(subprocess, "CREATE_NO_WINDOW", 0),
    )
    pid_file.write_text(str(process.pid))
    time.sleep(args.settle)
    wanted = "(%s)" % VIEWS[args.view].replace("x", ", ")
    reply = {}
    for _ in range(20):
        reply = send(kit, args.slot, {"command": "geometry"}, timeout=60)
        if args.headless and reply.get("headless"):
            break
        if reply.get("texture_size") == wanted:
            break
        time.sleep(0.5)
    ready = bool(reply.get("headless")) if args.headless else reply.get("texture_size") == wanted
    print(json.dumps({"pid": process.pid, "session": args.session, "view": args.view, "headless": bool(args.headless), "wanted": VIEWS[args.view], "ready": ready, "geometry": reply}))
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


def cmd_debug(args):
    # WP-120: one debug console line, for example `debug --line "jump 6"`. Same as send '{"command":"debug","line":...}'.
    reply = send(args.kit, args.slot, {"command": "debug", "line": args.line}, timeout=args.timeout)
    print(json.dumps(reply))
    return 0 if reply.get("ok") else 1


def cmd_state(args):
    # WP-123: everything a player can know now, as one JSON object. --truth adds hidden Siren truth (debug builds, testing only).
    request = {"command": "state"}
    if args.truth:
        request["truth"] = True
    reply = send(args.kit, args.slot, request, timeout=args.timeout)
    print(json.dumps(reply))
    return 0 if reply.get("ok") else 1


def cmd_order(args):
    # WP-123: one player order by name, e.g. order ... '{"order":"route","craft":"QUIETUS","points":[[600,500]]}'.
    request = json.loads(args.json)
    request["command"] = "order"
    reply = send(args.kit, args.slot, request, timeout=args.timeout)
    print(json.dumps(reply))
    return 0 if reply.get("ok") else 1


def cmd_run(args):
    # WP-123: run the dive for N game seconds (at speed S); stops at a lock, card, loss or the dive's end.
    request = {"command": "run", "seconds": args.seconds}
    if args.speed is not None:
        request["speed"] = args.speed
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
    # --slot has no default: a critic that left it off once drove another critic's game (13 Nov).
    launch.add_argument("--slot", required=True)
    launch.add_argument("--view", choices=sorted(VIEWS), default="cover")
    launch.add_argument("--session", required=True)
    launch.add_argument("--settle", type=float, default=4.0)
    launch.add_argument("--headless", action="store_true", help="no window: state, order, run and debug only (WP-123)")
    launch.set_defaults(run=cmd_launch)
    snd = sub.add_parser("send")
    snd.add_argument("--kit", required=True)
    snd.add_argument("--slot", required=True)
    snd.add_argument("--timeout", type=int, default=150)
    snd.add_argument("json")
    snd.set_defaults(run=cmd_send)
    dbg = sub.add_parser("debug")
    dbg.add_argument("--kit", required=True)
    dbg.add_argument("--slot", required=True)
    dbg.add_argument("--timeout", type=int, default=150)
    dbg.add_argument("--line", required=True)
    dbg.set_defaults(run=cmd_debug)
    st = sub.add_parser("state")
    st.add_argument("--kit", required=True)
    st.add_argument("--slot", required=True)
    st.add_argument("--timeout", type=int, default=150)
    st.add_argument("--truth", action="store_true")
    st.set_defaults(run=cmd_state)
    od = sub.add_parser("order")
    od.add_argument("--kit", required=True)
    od.add_argument("--slot", required=True)
    od.add_argument("--timeout", type=int, default=150)
    od.add_argument("json")
    od.set_defaults(run=cmd_order)
    rn = sub.add_parser("run")
    rn.add_argument("--kit", required=True)
    rn.add_argument("--slot", required=True)
    rn.add_argument("--timeout", type=int, default=600)
    rn.add_argument("--seconds", type=float, required=True)
    rn.add_argument("--speed", type=float, default=None)
    rn.set_defaults(run=cmd_run)
    qt = sub.add_parser("quit")
    qt.add_argument("--kit", required=True)
    qt.add_argument("--slot", required=True)
    qt.set_defaults(run=cmd_quit)
    args = parser.parse_args()
    sys.exit(args.run(args))


if __name__ == "__main__":
    main()
