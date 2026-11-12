# Workflow

How changes move through this repository. The rules for agents are in [AGENTS.md](../AGENTS.md); this file holds the mechanics. Rulings quoted here are in [USER_DIRECTIVES.md](USER_DIRECTIVES.md).

## Branch model

| Branch | Role | Who updates it |
| --- | --- | --- |
| `claude/integration` | Development integration. Feature pull requests target it. | The integrator, by reviewed pull request |
| `main` | Protected accepted baseline and the only promotion target (Pat, 2026-10-31) | Pat, by a promotion pull request from `claude/integration` at a coherent milestone |
| `gauntlet/production` | Frozen earlier promotion baseline. Kept, never updated. | Nobody |
| `archive/*` | Preserved evidence and history | Nobody after creation |
| `codex/handoffs` | Earlier coordination branch (queue, rulings and state until 2026-11-01) | Nobody in current work; retirement is Pat's decision |
| feature branches | One coherent change each, started from the latest `claude/integration` | Their owner |

No force push, history rewrite or deletion on a shared branch. A feature branch whose base moved merges the new base in and rechecks; it is not rebased after it has been pushed for review. Keep every published branch. Old branches are archived by tag, only when Pat approves; `scripts/repo/branch_ledger.py` classifies them.

Nothing is deleted from the tree. A retired file is moved with `git mv` into a dated scrap folder (`_scrap-YYYYMMDD/`) with a row in that folder's `SCRAP_MANIFEST.md`.

## Commits

`type(scope): imperative summary`, under 72 characters. Types: feat, fix, refactor, perf, test, docs, build, ci, chore, revert. The body says what changed and why, wrapped at 72. Each commit on a shared or run branch builds and passes the focused checks for what it touches. Undo with `git revert`.

## Review and merge

1. The author runs the local checks listed below and writes down the result.
2. One independent reviewer reads the frozen head against the base: behavior, conflicts with other work, protected rules, save shape and the focused tests. The verdict (APPROVE or REVISE, the reviewed head, findings and their disposition) is recorded in the pull request, or in the merge commit message when the merge is local. A review relayed by the integrator is labelled as relayed.
3. A second reviewer is added only for a named high risk: save and load, simulation determinism, input routing, the critic driver, or CI workflows.
4. Merge only a reviewed head whose required checks passed on that exact head. Merge with a merge commit. Never merge known-broken game or save behavior.
5. After the merge, fetch the new integration tip and update [STATUS.md](STATUS.md) if the base, active work or next action changed.

## Tests and CI: run what is necessary, once

Pat's rulings of 2026-10-31 and 2026-11-12 set the rule: the literal bare minimum of testing for every process, as fast as possible, with no editing CI to pass on red. Large test runs are for a release or near-release package only.

- **Locally, per change:** an import and the suites that test what you changed (`python scripts/toolchain/select-suites.py --minimum --changed <paths>` names them). Core only when simulation or campaign rules changed. `scripts/toolchain/check-suites.py` when the registry changed. Never the full scenario list, and no neighbouring suites to be safe.
- **On GitHub:** `gauntlet-pr-checks.yml`. Draft pull requests run the `guidance` job only (governing documents, documentation links, tool self-tests). Ready pull requests run core plus the minimum selection and the canaries (a few minutes); they never run the four-shard matrix. A manual dispatch (`gh workflow run gauntlet-pr-checks.yml --ref <branch>`) runs the full matrix (about 46 minutes, 150 runner-minutes): use it only before a release or near-release package. Marking a pull request ready, and each push to a ready pull request, starts a check run.
- **Once per head.** Do not rerun a suite that is already green on the same head. Read existing results first. An infrastructure failure (runner, quota, network) is retried once, then recorded.
- **Never** loosen, skip or delete a test, or lengthen a timeout, to get a pass.

[TESTING.md](TESTING.md) has the suite registry rules, the strict summary line and the toolchain setup.

## Android packages

A debug package may be built when it helps testing (Pat, 2026-11-01): `gh workflow run android-validation.yml --ref <branch>`. It is signed only with the tracked development keystore `scripts/toolchain/signing/sirens-song-debug.keystore`. Never regenerate that key; never commit a release or private key. Do not build a package for every change. [PLAYTEST_ANDROID.md](PLAYTEST_ANDROID.md) has the phone procedure.

## Tools

| Tool | Use |
| --- | --- |
| `scripts/toolchain/check-gauntlet-guidance.py --root .` | Structural check of the governing documents; runs in the `guidance` job |
| `scripts/repo/check_doc_links.py` | Checks every relative link in tracked Markdown; runs in the `guidance` job |
| `scripts/toolchain/gauntlet-boundary.py --boundary complete` | Fetches the governing files from `claude/integration` at a task boundary and runs the structural check on them. A fresh receipt means the files were fetched, not that anyone read them. |
| `scripts/toolchain/install-gauntlet-hooks.py` | Optional local git hooks that call the boundary helper. It refuses to replace hooks it does not manage. Installed hooks keep the helper version they were installed with; run the installer again to adopt a changed helper. |
| `scripts/repo/branch_ledger.py` | Read-only ledger of every remote branch and its class |
| `scripts/critic/` | The blind critic play kit |

## Status, questions and closeout

[STATUS.md](STATUS.md) is the only status file. It is short: current integrated base, active work, top weaknesses, blockers, next action. Update it in the change that alters any of those. Questions for Pat go to [QUESTIONS_FOR_PAT.md](QUESTIONS_FOR_PAT.md) (or a run's own decisions file), one plain question each with a recommendation; work that does not depend on the answer continues. On usage exhaustion write PAUSED, RESUME REQUIRED in STATUS.md with the exact next command.
