#!/usr/bin/env python3
"""Stop hook: keeps a RUNNING run from ending its turn early.

The run's state lives in .fable/RUN_STATE.json. While status is RUNNING, this
hook blocks the stop (exit 2) and tells Claude the next action, so the run
continues instead of ending on a summary or an offer to continue.

Statuses that allow a stop: NOT_STARTED, PAUSED, STUCK, DONE.

Escape valve: if Claude tries to stop three times in a row and neither
RUN_STATE.json nor RUN_LOG.md changed in between, the stop is allowed and a
warning is written to the log. That prevents an endless loop when something
outside the run is actually wrong.
"""
import json
import os
import sys
import time

MAX_IDLE_BLOCKS = 3


def main():
    try:
        sys.stdin.read()
    except Exception:
        pass
    project = os.environ.get("CLAUDE_PROJECT_DIR") or os.getcwd()
    fable = os.path.join(project, ".fable")
    state_path = os.path.join(fable, "RUN_STATE.json")
    log_path = os.path.join(fable, "RUN_LOG.md")
    counter_path = os.path.join(fable, ".stop_blocks")
    if not os.path.exists(state_path):
        sys.exit(0)
    try:
        with open(state_path, encoding="utf-8") as fh:
            state = json.load(fh)
    except Exception as exc:
        sys.stderr.write(
            "RUN_STATE.json is unreadable (%r). Repair it from the last good commit "
            "(git show HEAD:.fable/RUN_STATE.json) and continue.\n" % (exc,)
        )
        sys.exit(2)
    status = str(state.get("status", "")).upper()
    if status != "RUNNING":
        if os.path.exists(counter_path):
            try:
                os.replace(counter_path, counter_path + ".last")
            except Exception:
                pass
        sys.exit(0)

    sig = "%s|%s" % (
        os.path.getmtime(state_path),
        os.path.getsize(log_path) if os.path.exists(log_path) else 0,
    )
    count = 0
    try:
        with open(counter_path, encoding="utf-8") as fh:
            prev = json.load(fh)
        if prev.get("sig") == sig:
            count = int(prev.get("count", 0))
    except Exception:
        pass
    count += 1
    with open(counter_path, "w", encoding="utf-8") as fh:
        json.dump({"sig": sig, "count": count}, fh)

    if count > MAX_IDLE_BLOCKS:
        with open(log_path, "a", encoding="utf-8") as fh:
            fh.write(
                "\n- %s STOP GATE: allowed a stop after %d idle attempts with status "
                "RUNNING. The next session must check why progress stalled.\n"
                % (time.strftime("%Y-%m-%d %H:%M:%S"), count - 1)
            )
        sys.exit(0)

    sys.stderr.write(
        "The run is not finished. RUN_STATE.json says status RUNNING, phase %s, next "
        "action: %s. Continue with that action now. If an item needs Pat, record it "
        "in .fable/DECISIONS.md and move to independent work. Set status PAUSED only "
        "when Pat asked for a pause or usage is exhausted; STUCK only when no "
        "independent work remains; DONE only after every Definition of Done item in "
        ".fable/FABLE_RUN.md is verified on the final head. Update RUN_STATE.json "
        "before you stop.\n"
        % (state.get("phase", "?"), state.get("next_action", "see RUN_LOG.md"))
    )
    sys.exit(2)


if __name__ == "__main__":
    main()
