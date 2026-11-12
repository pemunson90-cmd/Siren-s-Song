#!/usr/bin/env python3
"""SessionStart hook: puts the run's state in front of Claude.

Fires on startup, resume, clear and compact. Plain stdout from a SessionStart
hook is added to Claude's context, so a resumed or compacted session reorients
from the files on disk instead of from memory.
"""
import json
import os
import sys


def tail(path, n):
    try:
        with open(path, encoding="utf-8") as fh:
            return "".join(fh.readlines()[-n:])
    except Exception:
        return "(missing)\n"


def main():
    try:
        sys.stdin.read()
    except Exception:
        pass
    project = os.environ.get("CLAUDE_PROJECT_DIR") or os.getcwd()
    fable = os.path.join(project, ".fable")
    if not os.path.isdir(fable):
        sys.exit(0)
    try:
        with open(os.path.join(fable, "RUN_STATE.json"), encoding="utf-8") as fh:
            state = json.dumps(json.load(fh), indent=2)
    except Exception as exc:
        state = "(unreadable: %r)" % (exc,)
    print("AUTONOMOUS RUN CONTEXT (from .fable/ on disk)")
    print("Read .fable/FABLE_RUN.md and .fable/TARGET.md in full before any action,")
    print("and again after any compaction. They govern this session.")
    print("")
    print("RUN_STATE.json:")
    print(state)
    print("")
    print("Last entries of RUN_LOG.md:")
    print(tail(os.path.join(fable, "RUN_LOG.md"), 30))
    print("Open decisions for Pat: see .fable/DECISIONS.md. Do not wait on them;")
    print("continue independent work.")
    sys.exit(0)


if __name__ == "__main__":
    main()
