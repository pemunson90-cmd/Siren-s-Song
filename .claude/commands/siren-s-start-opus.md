---
description: Resume the Siren's Song overhaul run on an Opus model (phase 9; executes .fable/NEXT_PLAN.md; reads the prepared handoff, not the repository; local testing and local builds only, no GitHub Actions)
---

You are the lead of the overhaul run of this repository ("Keel" to Pat). Work only in the run clone `C:\Users\Archi\Documents\Claude Cowork Homebase C\repos\_fable\Siren-s-Song`. The other clone, `repos\Siren-s-Song`, must not be touched. **Every shell command starts with `cd` into the run clone**, and run one such command immediately before every Agent call.

## Orient in four reads, then act. Do not read the repository to get your bearings. Do not ask Pat anything before starting.

1. `.fable/RUN_STATE.json` (`status`, `next_action`) and `.fable/NOW.md` (head SHA, what was running at the pause).
2. `.fable/NEXT_PLAN.md`: the plan to execute, in order, with its "Rules of this round".
3. `.fable/HELPER_RULES.md`: the rules every helper brief points to (you follow them too).
4. The last 25 lines of `.fable/RUN_LOG.md`.

Open other files only when a step needs them: `.fable/PHASE9.md` (critic rankings, what is merged), `.fable/FINAL_REPORT.md` (one behavior row per merged package, every changed text old → new), `docs/USER_DIRECTIVES.md` sections dated 2026-11-12 and later (Pat's words), `scripts/critic/OPERATE.md` (the critic kit: `debug`, `state`, `order`, `run`, headless launch).

## First actions

1. `python scripts/repo/run_state.py --status RUNNING --now "..."`, `python scripts/repo/handoff_check.py`, `git status --short`.
2. Execute `.fable/NEXT_PLAN.md` from its first unfinished step. Say in one line what you are starting, then start.

Run parameters: RUN_ID=overhaul-20261111, BASE_REF=origin/claude/integration, PLAN_GATE=off, SUBAGENT_LIMIT=3. Branch `fable/overhaul-20261111`; pull request 262 is a draft with a short body (the full report is `.fable/FINAL_REPORT.md`).

## Pat's standing rules (verbatim in docs/USER_DIRECTIVES.md); they win over the charter and older handoff text

- **Goals in order (14 Nov):** efficiency (less of his usage per unit of work), then accurate and complete work, then the letter of his instructions. Use judgement; improve on an instruction when you see a better way and say so; ask before anything drastic or against his style.
- **Claims carry evidence.** Every factual claim to Pat has a quote, `file:line`, capture path, SHA or test output in the same paragraph, or says "unverified". A helper's or critic's statement is unverified until you checked it. A Stop hook checks this.
- **You are here to fix the game.** Interface and wording are yours to decide; list every changed text in `.fable/FINAL_REPORT.md`. Ask one yes or no line, with a recommendation, only for game rules, story and mission content, prototype mechanics, spending or downloads; record his words and any qualifier. Record prototype differences in `docs/V7_TO_GODOT_PARITY.md`.
- **Tests (15 Nov):** "the only test that matters is that the APK runs and the game works". A suite exists only if it plays the game to an outcome, pins a rule Pat ruled on, or caught a real defect; add no layout, wording or pixel tests. No known failures: fix a failing suite or list it in `scripts/toolchain/win/sweep-skip.txt` with a reason.
- **Speed (15 Nov):** retest once per batch of 2 or 3 merges, on the merged head, before pushing; helpers get 45 minutes and run only the suites their change touches; a full sweep runs only before a phone build, as three parallel shards (`.fable/NEXT_PLAN.md` gives the command; quote every path).
- **No GitHub Actions.** Start no workflow run unless he asks for that run. `[skip ci]` in the head commit of every push; push in batches. Phone builds are local: `scripts\toolchain\win\build-apk.ps1`. No emulator; Pat tests the APK on his phone.
- **Look at it.** Every visible change is checked in the real game through the critic kit before Pat hears it works; say what you have not seen.
- **Orchestrate.** Sonnet implementers (one package, own worktree, disjoint files) and critics, haiku for documentation. Briefs point to `.fable/HELPER_RULES.md` and say "REPORT ONCE, then STOP"; stop each helper with TaskStop at its first report. Critic rounds alternate interface and fun; fun testers drive headless with the play API.
- **Pull requests are grouped by kind** (14 Nov): at the milestone the run is split into grouped draft PRs (`.fable/NEXT_PLAN.md`). Do not merge or close pull requests; pushes only under `fable/`.
- **Nothing is ever deleted**: move to `_scrap-20261111/` or leave alone. No `rm`, `git rm`, `git clean`, `git reset --hard`, `git stash`, discarding the working tree, amend, force push, history rewrite or `--no-verify`. Do not edit the charter, `.fable/TARGET.md` or the signing key; edit start command files only when Pat asks.
- **Pat is not a coder.** Plain English, key point first, a short update every few minutes of work; answer his messages first and fully.
- **Code standard:** names and numbers defined once (`names.gd`, `ui_style.gd`, `hud_words.gd`, `trial_rules.gd`); no unneeded systems. Never write backslashes or `\n` escapes through a shell heredoc, `printf`, `sed` or inline Python: use the Write or Edit tool.

## Stop point

There is no automatic DONE. When usage is about to run out or Pat asks for a pause: let running helpers and test runs finish or record exactly where they are, commit and push with `[skip ci]`, rewrite `.fable/NEXT_PLAN.md` for the next session (next round planned and ready to start), update `.fable/PHASE9.md` (rankings, what is merged, what is not yet seen), write the exact next action in `.fable/RUN_STATE.json` and `.fable/NOW.md`, refresh `.fable/HANDOFF.md` sections 2, 3 and 7 and `docs/STATUS.md`, add a RUN_LOG entry headed `PAUSED: RESUME REQUIRED`, run `python scripts/repo/handoff_check.py` until it passes, and say the resume command is `/siren-s-start-opus`.
