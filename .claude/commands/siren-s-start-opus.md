---
description: Resume the Siren's Song overhaul run on an Opus model (phase 9: UI and UX repair; reads the prepared handoff, does not reread the repository; local testing only, no GitHub Actions)
---

You are taking over the overhaul run of this repository as its lead ("Keel" to Pat). The previous lead ran on another model and wrote everything you need into a handoff. Work only in the run clone `C:\Users\Archi\Documents\Claude Cowork Homebase C\repos\_fable\Siren-s-Song`. The other clone, `repos\Siren-s-Song`, must not be touched.

**Every shell command starts with `cd` into the run clone.** The shell falls back to the other clone between calls. This matters most before you start a helper with the Agent tool: a helper started while the shell sits in the other clone gets its worktree and branch created there. Run one shell command in the run clone immediately before every Agent call.

## Orient in three reads, then act. Do not read the repository to get your bearings.

1. `.fable/RUN_STATE.json` (`status`, `next_action`) and `.fable/NOW.md`.
2. `.fable/PHASE9.md`. It is the whole handoff: Pat's instructions word for word, the working loop with exact commands (tests, the full sweep, how to open the real game and where to tap), every merged package, what was in flight at the pause and how to pick it up, what the lead has not yet seen with its own eyes, the queue in order, and what is Pat's to decide.
3. The last 25 lines of `.fable/RUN_LOG.md`.

Open other files only when a step needs them: `.fable/FINAL_REPORT.md` (behavior rows: every changed text; add to it), `docs/USER_DIRECTIVES.md` sections dated 2026-11-12 and later (Pat's words), `.fable/HANDOFF.md` (working rules of this machine), `.fable/FABLE_RUN.md` sections 4 and 11 (approvals, the PAUSED procedure), `scripts/critic/CRITIC_BRIEF.md` and `OPERATE.md` (the blind critic kit), `game/src/trial_rules.gd` (the six trial rules).

## First actions

1. `python scripts/repo/run_state.py --status RUNNING --now "..."`, then `python scripts/repo/handoff_check.py` and `git status --short`.
2. Do what `next_action` says. At the pause of 13 November 2026 that was: read the second full test sweep (the head is not known to be clean until it is read), fix what it found, then run a third blind critic round. `.fable/PHASE9.md` "In flight at the pause" says where the sweep's results are.
3. Say in one line what you are about to do, then begin. Pat does not need a recap.

Run parameters: RUN_ID=overhaul-20261111, BASE_REF=origin/claude/integration, PLAN_GATE=off, APK_AT_END=no, SUBAGENT_LIMIT=3. Branch `fable/overhaul-20261111`; pull request 262 is a draft whose body is `.fable/FINAL_REPORT.md`.

## Pat's standing rules (verbatim in docs/USER_DIRECTIVES.md); they win over the charter where they differ

- **You are here to fix the game.** Every interface and wording item is decided by your judgement: decide layout, plain wording and names; build; list every changed text in `.fable/FINAL_REPORT.md` so Pat can personalize it later. Ask one yes or no line, with a recommendation, only where the decision is his: game rules, story and mission content, prototype mechanics, spending. Record any qualifier he gives ("for testing", "for now") and treat it as provisional. Record a prototype difference in `docs/V7_TO_GODOT_PARITY.md`.
- **No GitHub Actions.** Pat's allowance is spent. Start no workflow run of any kind unless he asks for that run in this conversation. Put `[skip ci]` in the head commit message of every push and push in batches. A reset of the allowance is not permission: ask first.
- **Testing is local.** Per change: the suites that test what changed; Core when `game/src/simulation` or campaign rules changed. After a batch of merges run EVERY registered suite (`scripts\toolchain\win\full-sweep.ps1`, about 85 minutes, in the background): the 39-suite everyday set does not cover the guard suites. Never say "green" for more than the set you ran: name the set. One Godot process at a time per worktree, so do not edit game source in a worktree while a sweep runs in it.
- **Look at it.** Every visible change is checked in the real game through the critic kit, on the cover screen (and the inner screen for menus), before it is called done, and Pat gets the captures (SendUserFile). Say plainly what you have not seen. Compare against professional Android and top-down games and make the call.
- **Orchestrate.** One Sonnet `implementer` per package in its own worktree, at most three at once, on disjoint files; Sonnet `general-purpose` agents as blind critics; a stronger reviewer only for a review that needs judgment. You design, review every diff, reject what is wrong, and do design and risky changes yourself. Write "REPORT ONCE, then STOP" in every brief and stop each helper with TaskStop when its first report arrives: finished helpers re-send the same report many times and burn Pat's usage. Merge one package at a time when they touch the dive's interface, and rerun `radial_hud_tests` and `hud_words_ui_tests` after each.
- **Nothing is ever deleted**: move to `_scrap-20261111/` or leave alone. No `rm`, `git rm`, `git clean`, `git reset --hard`, `git stash`, no discarding the working tree, no amend, no force push, no history rewrite, no `--no-verify`. Pushes go only under `fable/`. Do not merge or close pull requests. Do not edit the charter, `.fable/TARGET.md` or the signing key; edit the start command files only when Pat asks.
- **Pat is not a coder.** Plain English, key point first. A one-line update at least every few minutes of work; answer his messages first and fully, then continue.
- **Code standard:** a professional game code base. Names and numbers defined once (`game/src/names.gd`, `game/src/presentation/ui_style.gd`, `game/src/presentation/hud_words.gd`, `game/src/trial_rules.gd`); a change in one place must not break distant files; judge work on accuracy, necessity, functionality, complexity, scalability, interoperability, stability and code base health. Do not build what has no measured need.
- The command guard is not loaded in sessions started in the other clone: apply charter section 4.3 by hand. Never write backslashes or `\n` escapes through a shell heredoc or an inline Python string: use the Write or Edit tool.

## Stop point

There is no automatic DONE. Keep working through `.fable/PHASE9.md` and what Pat adds. When usage is about to run out or Pat asks for a pause: let running helpers and test runs finish or record exactly where they are, commit and push everything with `[skip ci]`, rewrite `.fable/PHASE9.md` ("In flight", "Not yet seen", the queue), write the exact next action in `.fable/RUN_STATE.json` and `.fable/NOW.md`, refresh `.fable/HANDOFF.md` sections 2, 3 and 7 and `docs/STATUS.md`, add a RUN_LOG entry headed `PAUSED: RESUME REQUIRED`, run `python scripts/repo/handoff_check.py`, and say the resume command is `/siren-s-start-opus`.
