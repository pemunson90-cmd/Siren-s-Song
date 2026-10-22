# Codex: how to continue (read this first, every time)

Pat will say only "continue". This file is everything you need. Do the Step 0 orientation below, then read nothing else unless a handoff names it. Do not use any older task you remember. Follow these steps in order.

## Step 0: orient (every new Codex session, once)
1. Read `docs/codex/PLAN_SNAPSHOT.md` on this branch. It is the short version of the whole plan, the settled rules and what Claude has in flight.
2. Then fetch `origin/claude/integration` and read these there, in full, so you know the game, its identity and the current state: `AGENTS.md`, `docs/USER_DIRECTIVES.md`, `docs/CURRENT_GAME_SPEC.md`, `docs/PHOTO_RECON.md`, `docs/SESSION_LEDGER_2026-10-21.md`. Where the ledger and PLAN_SNAPSHOT disagree, PLAN_SNAPSHOT is newer.
3. Open `docs/codex/BOARD.md`. When you have done 1 and 2, go straight to Step 1 and take the first OPEN handoff in order. Do not wait for Pat.

## Where handoffs live
Branch `codex/handoffs` in pemunson90-cmd/Siren-s-Song, folder `docs/codex/`. Only this branch holds handoffs and completion notes. Claude (root orchestrator) adds new handoff files here. You edit only the file of the handoff you claimed. Nobody else edits it, so there are no merge conflicts.

Your code work happens on a separate lane branch named in the handoff, and returns by pull request into `claude/integration`. Never push code to `codex/handoffs`. Never push to `gauntlet/production` or `main`. Never build an APK.

## Step 1: find the newest untouched handoff
1. `git fetch origin codex/handoffs` and read `docs/codex/` from `origin/codex/handoffs` (use `git show origin/codex/handoffs:docs/codex/<file>` or check the branch out in a separate worktree).
2. Handoff files are named `NNN-short-name.md` with a three digit number. Each has a line `Status: OPEN`, `CLAIMED`, `DONE` or `BLOCKED` near the top.
3. Take the LOWEST-numbered file whose status is exactly `OPEN` and whose `Precondition:` is satisfied (changed 22 Oct: handoffs are queued in order so Pat can leave you running). Ignore everything else.
4. Read its `Precondition:` line and obey it. If the precondition says a Claude worker may be active (newest commit on the branch under 90 minutes old), do not claim it; move to the next-highest OPEN handoff. If none are left, go to step 2 below and tell Pat.
5. Read its `Codex may merge:` line. Where it says yes, you may merge that handoff's pull request into `claude/integration` (never production, never main) with a merge commit, but only after GitHub's `guidance` and `game-smoke` are both green on the exact head and the pull request is mergeable.

## Push work in progress (22 Oct, Pat)
Sessions and machines die without warning, and uncommitted work is lost. Commit and push your lane branch at least every 30 minutes and after every meaningful step, even when tests are red (a red WIP commit on your lane branch is fine; never merge red). Use a message starting `WIP:`. In your handoff file's Completion section, note the branch and the last pushed SHA so anyone can resume you. Open the PR as soon as the first coherent version exists (a draft is fine).

## Claude may be absent (22 Oct)
Claude's session can run out of usage. Then you continue alone: Pat's STANDING DELEGATION (top of docs/USER_DIRECTIVES.md on claude/integration) lets you build to the plan and merge your own green PRs. A handoff marked PRIORITY goes first. Ask Pat only at the decision points listed in the delegation. Read docs/SESSION_LEDGER_2026-10-22.md on claude/integration for the current state.

## Batch rule and reporting (22 Oct, Pat)
Handoffs come in batches of three. Work them in numeric order. A file with `Status: HOLD` is not yours; ignore it. After each handoff: set its Status to DONE (or BLOCKED), fill Completion, and update its row in `docs/codex/BOARD.md` (status, PR link, UTC time, one line). Claude watches the board and writes the next batch when two of three are DONE. When no OPEN handoff is left, stop and tell Pat plainly which are DONE, then wait; do not invent work.

## Keep going (22 Oct, Pat)
When you finish a handoff (Step 5 done, PR merged or BLOCKED explained), go straight back to Step 1 and take the next eligible OPEN handoff without waiting for Pat. Stop only when there is none, a handoff is BLOCKED, or you hit a decision that is Pat's (combat, detection, damage, hull, story, photography design). Then follow Step 2 or Step 6 and ask one plain question.

## Step 2: if there is no OPEN handoff
Do nothing else. Do not guess. Do not resume a CLAIMED or older task. Reply to Pat in plain language, no jargon, with exactly:
- "There is no new handoff for me."
- Which handoffs exist and their status (one line each, newest first).
- If any are CLAIMED but not DONE: say which, and ask whether to resume it.
- The question: "What do you need me to do?"

## Step 3: claim it before you start
1. Edit only that handoff file: change `Status: OPEN` to `Status: CLAIMED`, and fill `Claimed at:` with the current UTC time and `Claimed by:` with `codex`.
2. Commit with message `claim NNN` and `git push origin codex/handoffs`.
3. If the push is rejected, fetch, re-read the file. If someone else already claimed it, go back to step 1. Never run a task you failed to claim.

## Step 4: do the task
Follow the handoff exactly. It names the branch to create, the files you may edit, the files you must not touch, and the checks. Rules that always apply:
- Branch from the base the handoff names (normally `origin/claude/integration`, fetched fresh).
- Edit only your owned files. If you need a file outside them, do not touch it; write it in your completion note.
- Mission briefings and story text are short placeholders only, enough to name the tasks. Gameplay, layout and UI come first; never write long story text. Never change combat, detection or damage rules unless the handoff says so. No em dashes in any text you add.
- Before you push, run import, the core tests, and only the scenarios for the area you touched. Do NOT run the full scenario list locally (Pat, 22 Oct): GitHub's game-smoke runs it on the pull request and is the gate. If CI goes red, fix and push again. Never skip, loosen or delete tests to get green. Run the full list locally only if a handoff says so.
- Push your lane branch and open a pull request into `claude/integration`. Wait for GitHub's `guidance` and `game-smoke` checks. Claude merges. You do not merge.
- Setup if needed: `export PATH=$HOME/.cache/sirens-song-toolchain/bin:$PATH; scripts/toolchain/install-godot.sh; scripts/toolchain/headless.sh --editor --import --quit`

## Step 5: write your completion (always, even on failure)
Edit your handoff file again and push to `codex/handoffs`:
- Change `Status:` to `DONE` (or `BLOCKED` if you could not finish) and fill `Finished at:`.
- Fill the `## Completion` section: what changed in plain language, the pull request link, test results, anything you could not verify, any file outside your ownership you needed, and what you recommend next.
- Commit `done NNN` and push. This is what stops the next "continue" from repeating the task.

## Step 6: tell Pat
Two or three plain sentences: what you did, the pull request link, and anything that needs his decision. No jargon.

## Guardrails
- Pat decides game design. Do not change how combat, detection, health, the story or the factory base work unless the handoff explicitly says Pat decided it.
- Only Pat ends the project. Never say the game is done.
- If something is unclear or blocked, set `BLOCKED`, explain in the Completion section, and ask Pat one plain question.
