#!/usr/bin/env python3
"""Update `.fable/RUN_STATE.json` and append to `.fable/RUN_LOG.md` in one step.

The root session of an autonomous run calls this after every finished task so
the state file never drifts from git:

  python scripts/repo/run_state.py --next "what to do next" \
      [--status RUNNING] [--phase 2-plan] [--checkpoint "text"] \
      [--wp WP-03=merged ...] [--log "text for the run log"] \
      [--now "text for the Doing right now section of NOW.md"]

It always sets `run_head` to the current HEAD, recounts the open decisions,
stamps `updated` from the clock, and starts `next_action` with the pointer to
`.fable/HANDOFF.md` and `.fable/NOW.md`. With `--now` it rewrites the
"Doing right now" section of `.fable/NOW.md` and its `Updated:` line: use that
before starting a step, so a session that dies leaves the step on record.

It writes only those three files. It never commits or pushes.
"""
import argparse
import datetime
import json
import pathlib
import re
import subprocess
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent.parent
FABLE = ROOT / ".fable"
POINTER = "Read .fable/HANDOFF.md and .fable/NOW.md first. Then: "
WP_STATES = ("planned", "building", "review", "revise", "merged", "deferred")


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--next", dest="next_action")
    parser.add_argument("--status")
    parser.add_argument("--phase")
    parser.add_argument("--checkpoint")
    parser.add_argument("--wp", action="append", default=[], metavar="ID=STATE")
    parser.add_argument("--log")
    parser.add_argument("--now")
    args = parser.parse_args()

    clock = datetime.datetime.now()
    state_path = FABLE / "RUN_STATE.json"
    state = json.loads(state_path.read_text(encoding="utf-8"))
    if args.next_action:
        state["next_action"] = POINTER + args.next_action
    if args.status:
        state["status"] = args.status
    if args.phase:
        state["phase"] = args.phase
    if args.checkpoint:
        state["last_checkpoint"] = args.checkpoint
    for item in args.wp:
        key, _, value = item.partition("=")
        if value not in WP_STATES:
            raise SystemExit("work package state must be one of %s: %s" % (", ".join(WP_STATES), item))
        state["work_packages"][key] = value
    head = subprocess.run(["git", "-C", str(ROOT), "rev-parse", "HEAD"], capture_output=True, text=True).stdout.strip()
    state["run_head"] = head
    decisions = (FABLE / "DECISIONS.md").read_text(encoding="utf-8")
    decisions = re.sub(r"<!--.*?-->", "", decisions, flags=re.S)
    state["decisions_open"] = len(re.findall(r"^Status:\s*OPEN\b", decisions, flags=re.M))
    state["updated"] = clock.strftime("%Y-%m-%d %H:%M:%S")
    state_path.write_text(json.dumps(state, indent=2) + "\n", encoding="utf-8", newline="\n")

    if args.log:
        log_path = FABLE / "RUN_LOG.md"
        text = log_path.read_text(encoding="utf-8").rstrip("\n")
        log_path.write_text("%s\n- %s %s\n" % (text, clock.strftime("%Y-%m-%d %H:%M:%S"), args.log), encoding="utf-8", newline="\n")

    if args.now:
        now_path = FABLE / "NOW.md"
        text = now_path.read_text(encoding="utf-8")
        text = re.sub(r"^Updated: .*$", "Updated: " + clock.strftime("%Y-%m-%d %H:%M"), text, count=1, flags=re.M)
        start = text.index("## Doing right now")
        end = text.index("\n## ", start + 5)
        text = text[:start] + "## Doing right now\n\n" + args.now.strip() + "\n" + text[end:]
        now_path.write_text(text, encoding="utf-8", newline="\n")

    print("state: %s, phase %s, head %s, %d open decision(s)" % (state["status"], state["phase"], head[:8], state["decisions_open"]))
    return 0


if __name__ == "__main__":
    sys.exit(main())
