---
description: Start (or resume) the Siren's Song Fable overhaul run under .fable/FABLE_RUN.md (now in phase 9: UI and UX repair after the audit; local testing only)
---
You are resuming the overhaul run of this repository. Work only in the run clone `repos\_fable\Siren-s-Song` (every shell command starts with `cd` into it; the shell falls back to the other clone, `repos\Siren-s-Song`, which must not be touched).

Read in full, in this order: .fable/RUN_STATE.json, .fable/NOW.md, .fable/PHASE9.md, .fable/HANDOFF.md, .fable/UX_AUDIT.md, the last 30 lines of .fable/RUN_LOG.md, and the sections of docs/USER_DIRECTIVES.md dated 2026-11-12 (Pat's rulings, verbatim). Read .fable/FABLE_RUN.md section 4 (what needs approval, what is forbidden) and section 11 (the PAUSED procedure); the rest of the charter and .fable/TARGET.md only when a step needs them. They govern this session.

Run parameters:
RUN_ID=overhaul-20261111
BASE_REF=origin/claude/integration
PLAN_GATE=off
APK_AT_END=no (a package needs GitHub Actions; build one only when Pat asks, and tell him the cost first)
SUBAGENT_LIMIT=3

Where the run stands: phases 0 to 8 are finished and pushed on `fable/overhaul-20261111`; pull request 262 is a draft with the report as its body. Phase 8 delivered the code base audit, the fixes Pat approved, an independent review, and a test trim (238 suites kept, 39 in the everyday set, 152 retired to scrap). The UI and UX audit is delivered in .fable/UX_AUDIT.md: ten plain defects (Part A) and nineteen yes or no items (Part B) that Pat has not answered. The current work is phase 9, defined in .fable/PHASE9.md. Continue from `next_action` in .fable/RUN_STATE.json: set status RUNNING, ask Pat for his Part B answers in one short message, and start Part A while he answers. Do not restart earlier phases and do not rebuild the audit.

Pat's standing rules (all verbatim in docs/USER_DIRECTIVES.md), which win over the charter where they differ:
- GitHub Actions: Pat's allowance is spent (12 November 2026). Start no workflow run of any kind: no `gh workflow run`, no re-run, no package build, unless Pat asks for that run in this conversation. Put `[skip ci]` in the head commit message of every push, and push in batches, not after every small commit. A reset of the allowance is not permission: ask first.
- Testing is local and minimal. Per change: an import and the suites that test what changed (`python scripts/toolchain/select-suites.py --minimum --changed <paths>` names them); core (`scripts\toolchain\win\headless.ps1 -Action Core`, about 100 seconds) only when simulation or campaign rules changed; the everyday set (`scripts\toolchain\win\test-suite.ps1 -All -Profile local`, 39 suites, about 20 minutes) before a merge of size. Test runs are isolated from the real save folder automatically. One Godot process at a time in a worktree.
- Delegation: orchestrate. The cheapest agent that can do each task well (Explore or Sonnet for searches and measurements; the implementer agent on Sonnet for small code packages in its own worktree; a stronger reviewer only for a review that needs judgment). Never more than three writing agents at once, on disjoint files. Root reviews every diff before merging and uses its own intelligence for design, synthesis and risky changes. Every brief says: branch from the run head (worktrees are created at `main`), no deletions, no amend, private temp folder, report once when nothing is still running.
- Nothing is ever deleted: move to `_scrap-20261111/` or leave alone. No `rm`, `git rm`, `git clean`, `git reset --hard`, no discarding the working tree, no force push, no history rewrite, no `--no-verify`.
- Pat is not a coder. Every report to him is plain English, key point first, with a recommendation he can answer yes or no. Where he has delegated a decision ("you can figure it out"), decide, do it and report; ask only where the decision is his: game design, story and mission text, wording the player reads, spending.
- Do not go silent. A one-line update at least every few minutes of work; answer Pat's messages first and fully, then continue.
- Game design, story and prototype parity are Pat's. A demonstrated prototype mechanic is never dropped or changed without his ruling; record every difference in docs/V7_TO_GODOT_PARITY.md. Every change the player can see goes in .fable/FINAL_REPORT.md as a behavior row.
- Standard for the code (Pat, 12 November): a professional game code base. Names and numbers defined once (`game/src/names.gd`), a change in one place must not break distant files, and work is judged on accuracy, necessity, functionality, complexity, scalability, interoperability, stability and overall code base health. Do not build what has no measured need.
- The command guard is not loaded in sessions started in the other clone (decision D-01): apply charter section 4.3 by hand. Pushes go only under `fable/`. Do not merge or close pull requests. Do not edit the charter, .fable/TARGET.md or the signing key; edit this command file only when Pat asks.
- Do not write backslash-heavy text through a shell heredoc or an inline Python string: use the Write or Edit tool, or a script file written with them.

Stop point: there is no automatic DONE. Keep working through .fable/PHASE9.md and what Pat adds. When usage is about to run out or Pat asks for a pause, follow the PAUSED procedure of charter section 11 exactly: commit and push everything (with `[skip ci]`), write the exact next action in .fable/RUN_STATE.json and .fable/NOW.md, add a RUN_LOG entry headed `PAUSED: RESUME REQUIRED`, and say the resume command is `/siren-s-start-fable`.

Before you start, say in one line what you are about to do. Then begin.
