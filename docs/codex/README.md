# Codex: how to continue (read this first, every time)

Pat will say only "continue". This file is everything you need. Do not read the rest of the repo's governance docs. Do not use any older task you remember. Follow these steps in order.

## Where handoffs live
Branch `codex/handoffs` in pemunson90-cmd/Siren-s-Song, folder `docs/codex/`. Only this branch holds handoffs and completion notes. Claude (root orchestrator) adds new handoff files here. You edit only the file of the handoff you claimed. Nobody else edits it, so there are no merge conflicts.

Your code work happens on a separate lane branch named in the handoff, and returns by pull request into `claude/integration`. Never push code to `codex/handoffs`. Never push to `gauntlet/production` or `main`. Never build an APK.

## Step 1: find the newest untouched handoff
1. `git fetch origin codex/handoffs` and read `docs/codex/` from `origin/codex/handoffs` (use `git show origin/codex/handoffs:docs/codex/<file>` or check the branch out in a separate worktree).
2. Handoff files are named `NNN-short-name.md` with a three digit number. Each has a line `Status: OPEN`, `CLAIMED`, `DONE` or `BLOCKED` near the top.
3. Take the highest-numbered file whose status is exactly `OPEN`. Ignore everything else. If two are OPEN, take the higher number and leave the other alone.

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
- Before you push, run import, the core tests, and every CI scenario: `bash docs/codex/run_ci_scenarios.sh` from the repo root (copy it out of the `codex/handoffs` branch). Every line must read `ok`. It flags any script error too. Do not skip, loosen or delete tests to get green.
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
