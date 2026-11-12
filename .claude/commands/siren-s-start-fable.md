---
description: Start (or resume) the Siren's Song Fable overhaul run under .fable/FABLE_RUN.md (now in phase 8: code base audit and Pat's follow-up work)
---
You are resuming the overhaul run of this repository. Work only in the run clone `repos\_fable\Siren-s-Song` (every shell command starts with `cd` into it; the shell can fall back to the other clone, which must not be touched).

Read in full, in this order: .fable/FABLE_RUN.md, .fable/TARGET.md, .fable/RUN_STATE.json, the last 40 lines of .fable/RUN_LOG.md, .fable/PHASE8.md, .fable/NOW.md, .fable/HANDOFF.md, and the last 150 lines of docs/USER_DIRECTIVES.md (Pat's rulings of 2026-11-12). They govern this session.

Run parameters:
RUN_ID=overhaul-20261111
BASE_REF=origin/claude/integration
PLAN_GATE=off
APK_AT_END=only when Pat asks for a build or a gameplay change needs him to play it
SUBAGENT_LIMIT=3

Where the run stands: phases 0 to 7 are finished and pushed on `fable/overhaul-20261111`; pull request 262 is a draft with the report as its body; Pat has a debug package to playtest. The current work is phase 8, defined in .fable/PHASE8.md: rename the DISRUPTION loadout to EMP, audit the code base for tangle and inefficiency, report in plain English, then build what Pat approves. Continue from `next_action` in .fable/RUN_STATE.json. Do not restart earlier phases.

Pat's standing rules (all verbatim in docs/USER_DIRECTIVES.md), which win over the charter where they differ:
- Testing: the literal bare minimum for every change. Locally only the suites that test what changed (`python scripts/toolchain/select-suites.py --minimum --changed <paths>` names them), core only when simulation or campaign rules changed. Never start the full matrix; it is for a release or near-release package.
- GitHub Actions: do not spend them unless necessary. Count runs before starting one. Pull request 262 stays a draft until Pat says his rulings are done.
- Delegation: orchestrate. Use small, bounded batches of the cheapest agent that can do each task well (Explore or a Haiku or Sonnet general-purpose agent for searches, measurements and mechanical edits; the implementer agent on Sonnet for small code packages). Use your own intelligence only where it is needed: design, synthesis, risky simulation changes, review of risky code. Never more than three writing agents at once.
- Nothing is ever deleted: move to scrap or leave alone.
- Pat is not a coder. Every report to him is plain English, key point first, with a recommendation he can answer yes or no.
- Do not go silent. Send a one-line update at least every few minutes of work, and answer Pat's messages first, fully, before continuing.
- Game design, story and prototype parity are Pat's. A demonstrated prototype mechanic is never dropped or changed without his ruling; record every difference in docs/V7_TO_GODOT_PARITY.md.
- The guard is not loaded in sessions started in the other clone (decision D-01): apply charter section 4.3 by hand. Pushes go only under `fable/`.

Stop point: there is no automatic DONE in phase 8. Keep working through .fable/PHASE8.md and what Pat adds. When usage is about to run out or Pat asks for a pause, follow the PAUSED procedure of charter section 11 exactly: commit and push everything, write the exact next action in .fable/RUN_STATE.json and .fable/NOW.md, add a RUN_LOG entry headed `PAUSED: RESUME REQUIRED`, and say the resume command is `/siren-s-start-fable`.

Before you start, say in one line what you are about to do. Then begin.
