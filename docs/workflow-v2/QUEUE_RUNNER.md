# Queue and runner design (runner2.py)

Drafted 2026-10-30. A spec for the replacement of `auto.py` and `runner.py` in `C:/Users/Archi/.cache/sirens-song-toolchain/artifacts/queue-s6/`. The phase machine, the notes handoff and the `INTENT: PASS` gate are kept. What changes: items come from `queue.json` instead of `ITEMS`/`CHAINS` in source; lanes become area locks; either provider can run a phase; phase C is a script, not a model session; the BOARD banner, LEDGER lines and runner-state surgery go away; red CI and stalls are handled by the runner, not by the orchestrator.

## Files

| File | Purpose |
|---|---|
| `runner2.py` | the loop (`tick` every 120 s) plus commands `status`, `dry-run`, `launch NNN`, `pause`, `resume`, `tracker` |
| `docs/state/queue.json` (on `codex/handoffs`) | the queue; the runner is its only writer |
| `docs/state/areas.json` | ownership areas: name to file globs; serial zones listed |
| `docs/state/items/NNN-slug.md` | item text the builder reads |
| `prompts/phase_a.txt`, `phase_b.txt`, `review.txt` | the only prompt templates; placeholders `{item}`, `{class}`, `{checks}`, `{notes}` |
| `<queue folder>/status.txt` | the old BOARD banner, local only, never committed |
| `<queue folder>/NNN.notes.md` | unchanged handoff between phases, ends with a `PHASE X DONE|CONTINUE|BLOCKED` line |

## queue.json

```json
{
  "max_builders": 2,
  "items": [
    {
      "id": 127, "slug": "release-controls", "title": "Release controls, pilot by hand",
      "class": "sim", "areas": ["sim.orders", "hud.orders", "debug.dev_state"],
      "serial": ["mission_hud.gd"], "depends": [126],
      "provider_pref": ["codex", "claude:opus"],
      "status": "queued", "phase": null, "branch": "item/127-release-controls",
      "worktree": null, "pr": null, "head": null, "attempts": {"A": 0, "B": 0, "C": 0},
      "started": null, "updated": null, "blocker": null
    }
  ]
}
```

Statuses: `queued`, `active`, `waiting_intent`, `merging`, `done`, `blocked`. The item file and `queue.json` are the whole record; there is no BOARD row.

## Launch rule (replaces CHAINS)

An item launches when all of these hold: status `queued`; every `depends` item is `done`; none of its `areas` or `serial` zones is held by an `active`, `waiting_intent` or `merging` item; fewer than `max_builders` sessions are alive; a provider in `provider_pref` answers the health probe. Items are considered in file order, so order in the file is priority.

## Providers

```python
PROVIDERS = {
  "codex":        lambda prompt, wt, effort: codex_exec(prompt, wt, model="gpt-6.1-sol", effort=effort),
  "claude:sonnet": lambda prompt, wt, effort: claude_p(prompt, wt, model="claude-sonnet-5-5"),
  "claude:opus":   lambda prompt, wt, effort: claude_p(prompt, wt, model="claude-opus-5-5"),
}
def healthy(name):   # one-line probe, cached 10 minutes; a usage-limit or capacity message counts as down
    ...
def codex_exec(prompt, wt, model, effort):   # exactly auto.py's Start-Process form: hidden window, stdin from the prompt file, stdout and stderr to files, pid file, no captured pipes
    ...
def claude_p(prompt, wt, model):
    # claude -p --model <model> --permission-mode acceptEdits --output-format json --max-turns 200
    #   --add-dir <artifact dir> < prompt file  > NNN.out.log 2> NNN.err.log   (same Start-Process wrapper, pid file)
    # Verify flag names against `claude --help` for the installed CLI (2.1.310 on 30 Oct) before first use.
    ...
```

Effort: phase A medium, phase B low (Pat 29 Oct), review high. Claude builders are told their model class in the prompt so Sonnet does not attempt sim items.

## Phases

- **A build** (model session): read the item file and only the files it names; implement; run import, core, `select-suites.py` output and the canary set; commit and push the branch as a draft PR (draft runs no game CI); append notes; end `PHASE A DONE <sha>`. Context rule unchanged: past 150k tokens, write notes and `PHASE A CONTINUE`.
- **B verify and PR** (model session, low effort): produce the class-capped evidence only (PROCESS.md section 5), fold it into the PR body under the cap, mark the PR ready for review, request the reviewer session; end `PHASE B DONE PR <n> head <sha>`.
- **Review** (model session, other provider, high): fixed checklist in `prompts/review.txt`; posts one PR comment of at most 10 lines ending `REVIEW: APPROVE <tree>` or `REVIEW: CHANGES <reasons>`. `CHANGES` relaunches A once with the comment as `{notes}`.
- **Intent** (orchestrator, Claude): reads the capped body and the review; posts `INTENT: PASS` or `INTENT: HOLD <reason>`. `HOLD` relaunches A once. Status `waiting_intent` until posted. This is the one human-shaped step left and it is the step that has caught the real problems.
- **C merge** (script, no model): with a global merge lock, in queue order: `git merge origin/claude/integration` into the branch (abort and relaunch A with the conflict files if it conflicts), push, wait for the full matrix on the exact head (or enable auto-merge when GitHub merge queue is on), merge with a merge commit via `gh pr merge --merge`, record `done`, write STATE.md. A red full run writes the failing assertion lines into the notes and relaunches A once; a second red marks `blocked` with those lines and releases the lock.

Attempts are capped: A at most 3 launches per item in total (initial, one repair, one more continue), after which `blocked`. The queue never waits on a blocked item; the orchestrator decides what to do with it.

## Watchdog

Each tick: for every alive session, if its notes file and worktree index have not changed for 45 minutes, kill the process tree (the runner owns its children, so no classifier denial), relaunch the same phase once from pushed WIP, then `blocked`. A session ending without a `PHASE` line is treated as a stall. A session ending with a capacity or usage message marks the provider unhealthy for 30 minutes and relaunches on the other provider.

## State writing

- `queue.json` is written on every transition and pushed to `codex/handoffs` at most once per 10 minutes (one commit, message `state: <item> <old> -> <new>`), rebased onto the fetched tip the same way `save_push` does today.
- `STATE.md` Base, In flight and Blockers sections are regenerated from `queue.json`, GitHub and the latest nightly artifact in the same commit. The orchestrator's Next and Notes lines are preserved verbatim.
- `status.txt` locally holds the running, done and blocked summary that the BOARD banner used to carry. No LEDGER lines: the merged PR and the item file are the record.
- `runner2.py tracker` regenerates the phone tracker dataset from `queue.json` (same Artifact upload calls HANDOFF describes), so the tracker is never hand-edited.

## Diff against today, in short

| Today (`auto.py` + `runner.py`) | v2 (`runner2.py`) |
|---|---|
| `ITEMS` and `CHAINS` edited in source | `queue.json` on the state branch |
| two lanes fenced by hand | area locks and serial zones checked before launch |
| Codex only | provider table with health probe; Claude builders |
| phase C is a 60-minute Codex session | phase C is a script with a merge lock |
| red CI in C needs 7 orchestrator steps | runner relaunches A once with the failing lines, then blocks |
| BOARD banner commit every refresh (74 commits in 3 days) | local `status.txt`; at most one state commit per 10 minutes |
| `checks` string in `runner.py:64` | `select-suites.py` output plus canaries; the full matrix only on the merge candidate |
| prompt text in three places (runner, FRESH_SESSION_PROMPT, auto.py PHASES) | three template files, one each |
| independent review of every commit before push | one review per PR on the frozen head, plus intent |

## Safety

The runner never pushes to `claude/integration` except through `gh pr merge` on a green exact head, never to `main` or `gauntlet/production`, never force-pushes, never deletes a branch, never builds an APK. It refuses to launch an item whose `Files` contain paths outside its `areas`. It refuses to merge a PR whose body exceeds the class cap, with a one-line reason the builder can act on.

## Commands

```
python -I runner2.py status      # queue, alive sessions, provider health; no writes
python -I runner2.py dry-run     # what the next tick would launch and why not otherwise
python -I runner2.py pause       # finish alive sessions, launch nothing, write PAUSED to STATE.md
python -I runner2.py resume
python -I runner2.py tracker     # regenerate the phone tracker from queue.json
python -I runner2.py             # the loop
```
