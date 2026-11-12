## Non-negotiable feature continuity (owner directive)

**If Pat did not explicitly authorize removing a working capability, it stays.** Existing working features, gameplay rules, card effects, interfaces, workflows, integrations, content, data, settings, accessibility, and tools survive fixes, refactors, rewrites, ports, engine replacements and architecture changes. Do not silently delete, stub, disable, simplify, postpone or leave them behind because a new implementation is cleaner or the task named only one feature. Lack of an explicit preservation list is **not** permission to drop anything.

**Before coding**, identify the actual most recent owner-accepted/installed usable baseline and the current authoritative development/integration branch; verify commit ancestry and inspect existing successful implementations, including playable prototypes, simulators and branches that the new work replaces. Neither `main` nor the newest-looking version number alone establishes the full feature set. For replacements or substantial refactors, account for each relevant existing capability and preserve behavior or explicitly approved improvements; check meaningful parity/regressions against the old working path. Recheck on the final integration head. If preservation and the requested change conflict, retain the old working functionality and seek Pat's explicit ruling on that **specific** loss; continue independent non-destructive work. Do not substitute extra paperwork or indiscriminate test campaigns for actual continuity checks. Apply updated guidance at the next safe work boundary without disrupting active writers.

# Siren's Song: instructions for every agent

This is the single governing file for agents working in this repository. `CLAUDE.md` only imports it. The table in [docs/GOVERNANCE_MIGRATION.md](docs/GOVERNANCE_MIGRATION.md) shows where every rule of the earlier governing files went.

Pat O'Sullivan owns the repository and is the only authority on game design, canon and narrative. Agents own the engineering.

## 1. Owner directives carried verbatim

The feature continuity directive above is Pat's and stays at the top of this file, unchanged. These further lines are also Pat's own words. Do not paraphrase, shorten or reorder them. New rulings are appended to [docs/USER_DIRECTIVES.md](docs/USER_DIRECTIVES.md), which is the one home for dated rulings.

Milestone loop [PAT, `AGENTS.md` on `main`, commit a2300840, 2026-10-19]:

> Milestone = a complete playable game. Each cycle: a fresh critic plays it with no build notes, the audit ranks its biggest weakness, the next version fixes it, repeat. The user's playtest gates nothing. The loop ends only when the user ends it or usage runs out, in which case write PAUSED, RESUME REQUIRED with the exact next command.

Removal rule [PAT, 2026-11-05, read from Pat's working copy of `AGENTS.md` on 2026-11-12; not yet committed on any shared branch]:

> **Removal rule (Pat, Nov 5 2026):** nothing is deleted. Move files to a scrap folder (`_scrap-YYYYMMDD/` at the repo root or `Documents\_to_delete\`). No `rm`, `git rm`, `git clean`, or delete-permission requests. Back up before overwriting.

Gauntlet priorities [PAT, 2026-10-30, verbatim in docs/USER_DIRECTIVES.md]:

> The storyline is the least important besides how it affects branching paths. The main point of the gauntlet loop right now is gameplay, graphics, ux, ui, bugs, features. The whole point is that we have a complete game. We review it, figure out where it's lacking especially in comparison to other AAA releases, and then we plan out the upgrades, and then we execute.

Minimum tests [PAT, 2026-10-31, verbatim in docs/USER_DIRECTIVES.md]:

> you should always be using the absolute minimum number of required tests and you should always be aiming to get them as quickly done as possible. This doesn't mean take shortcuts, this doesn't mean modify CI to pass on a red, this means taking the most efficient and shortest pass on every single task.

Identity [PAT, ratified 2026-10-22; summary, the verbatim ruling is in docs/USER_DIRECTIVES.md and docs/PHOTO_RECON.md]: Siren's Song is first a military photographic reconnaissance game (Iron Lung influence). Rescue, industrial and fleet work support it.

Story [PAT, 2026-10-21, verbatim in docs/USER_DIRECTIVES.md]: "**Do not author new narrative text.**" Story text stays one or two line placeholders until Pat writes it. Characters, site sequence and ending conditions need Pat's approval before they land.

## 2. The project

Original Android-first 2D tactical submarine stealth and reconnaissance game. One pilot commands USS Quietus and two drones through alien industrial water under superior Siren threats. Godot 4.6.3, GDScript, Compatibility renderer. The game is in `game/`. The six original missions are the tutorial foundation for a longer branching campaign with craft growth, story and multiple endings. The quality target is AAA-caliber Android content and execution. Store administration, marketing and legal publishing work are outside the grant.

Maintain physical movement, unlimited tactical pause, fair information, finite tools and independent craft. Keep the engine and the simulation, campaign, persistence, presentation and audio boundaries described in [docs/architecture/GAUNTLET.md](docs/architecture/GAUNTLET.md).

## 3. Authority order

1. Pat's current explicit decisions: the launch message of a session, then [docs/USER_DIRECTIVES.md](docs/USER_DIRECTIVES.md), newest ruling first.
2. [docs/CURRENT_GAME_SPEC.md](docs/CURRENT_GAME_SPEC.md) with accepted amendments, read with the ratified design bible (`design/SIRENS_SONG_DESIGN_BIBLE_GAUNTLET_V1.md`).
3. Accepted concept selections and visual decisions (`references/package/`).
4. Source-verified playable behavior and runtime evidence.
5. Historical specifications and archives.
6. Proposals.

[docs/SOURCE_AUTHORITY.md](docs/SOURCE_AUTHORITY.md) resolves details. The playable v7 prototype (`reference/original-prototype/sirens_song_prototype_v7.html`) is a working implementation reference: do not drop its demonstrated mechanics without comparison and rationale, and keep its source unchanged. [docs/V7_TO_GODOT_PARITY.md](docs/V7_TO_GODOT_PARITY.md) tracks purposeful differences.

When two documents conflict, the newer one wins unless the older one is a verbatim Pat ruling that the newer one does not explicitly supersede.

## 4. Rules that are Pat's call

Record these as a numbered question with a recommendation, keep the old behavior, and continue independent work. Do not decide them.

- Removing or reducing any working capability, rule, mode, setting, content or tool.
- Narrative, story, dialogue, characters, site sequence and ending conditions. Art direction.
- Protected game rules: Siren senses and sight ranges (silent sight 180 m, cruise sight 290 m), the four second interruptible lock warning, beam, collision, damage and hull rules, sight-only Hunt, photography exposure and grading, and the principle that no player tool permanently disables a Siren. `game/tests/protected_rules_tests.gd` pins the numbers.
- One-press travel shortcuts stay behind the developer state. They exist for testing and are not part of release play.
- Promotion to `main`, anything irreversible, repository settings and releases.

Ask Pat one plain question at a time with a recommendation, and record any qualifier he gives (for example "for now"). Everything else is an engineering decision: make it, make it reversible, and report it.

## 5. Branches

- `claude/integration`: development integration. Feature branches start from it and return to it by pull request.
- `main`: the protected accepted baseline and the only promotion target. Pat authorizes promotion.
- `gauntlet/production`: frozen earlier promotion baseline. Kept, never updated.
- `archive/*`: preserved evidence and history. Not instructions.
- `codex/handoffs`: the earlier coordination branch. Its rulings are copied into docs/USER_DIRECTIVES.md and its status into docs/STATUS.md. Whether it is retired is Pat's decision.

No force push, no history rewrite and no branch deletion on any shared branch. Keep every published branch and recovery ref. [docs/WORKFLOW.md](docs/WORKFLOW.md) has the commit format, review and merge rules and the CI gating.

## 6. Where things are

| Need | File |
| --- | --- |
| Current status, active work, top weaknesses, blockers, next action | [docs/STATUS.md](docs/STATUS.md), the one live status file |
| Pat's rulings, verbatim and dated | [docs/USER_DIRECTIVES.md](docs/USER_DIRECTIVES.md) |
| Open questions for Pat | [docs/QUESTIONS_FOR_PAT.md](docs/QUESTIONS_FOR_PAT.md) |
| Intended game | [docs/CURRENT_GAME_SPEC.md](docs/CURRENT_GAME_SPEC.md) |
| Camera capabilities and gaps | [docs/PHOTO_RECON.md](docs/PHOTO_RECON.md) |
| Branch model, commits, review, CI | [docs/WORKFLOW.md](docs/WORKFLOW.md) |
| Tests and the toolchain | [docs/TESTING.md](docs/TESTING.md) |
| Module seams, switches and reverts | [docs/MODULES.md](docs/MODULES.md) |
| Code conventions | [docs/CONVENTIONS.md](docs/CONVENTIONS.md) |
| Folder map | [docs/REPOSITORY_MAP.md](docs/REPOSITORY_MAP.md) |

## 7. How work is done

- **Look at the whole game.** Rank player-facing weaknesses across tactics, stakes, operations, controls, world, art, sound and technical quality against the specification, the playable v7 and strong shipped games. Pick the change with the largest effect on the player. Work on the game, not on proving that a workflow happened: an hour of simulation, layout and encounter work should outweigh an hour of documentation.
- **Research before building.** Check existing project code and established approaches before writing a custom system.
- **One branch per coherent change**, with explicit file ownership. Keep other workers' edits intact. A worker gets a bounded brief (goal, base commit, owned paths, paths not to touch, documents to read, acceptance commands) and reads that brief and what it names, not the whole repository.
- **Build reversibly.** New systems go in their own files or folders with one narrow, documented seam. Tunable numbers live in data tables. Save fields are optional and validated. Tests live beside the feature and are registered in `game/tests/suites.txt`.
- **One independent reviewer per change**, on the frozen head, before merge. A second reviewer only for a named high risk: save and load, simulation determinism, input routing, the critic driver, or CI workflows. Record the verdict where the merge can cite it. Passing CI shows the tests pass; it is not a review.
- **Test the minimum that proves the change.** Locally: import, core, the suites the diff reaches, the canaries and `check-suites`. The full matrix runs once per head on GitHub. Never loosen, skip or delete a test, and never edit CI to pass on red.
- **Android packages.** Build a debug package when it helps testing, signed only with the tracked development keystore under `scripts/toolchain/signing/`. Never regenerate that key and never commit release or private key material. Pat provides release keys himself.
- **Evidence levels stay distinct:** implementation, scripted verification, automated or critic play, and physical-device observation. Do not claim human enjoyment, audio perception, phone ergonomics or Android performance without that evidence.
- **Keep the tree lean.** Game source, assets, tests, tools and concise instructions stay in the repository. Raw critic reports, screenshots, video and metrics stay outside the active tree in a recoverable place.
- **Critics stand in for players.** A fresh critic gets the running game and nothing else: no build notes, no source, no winning routes. It plays full operations by real touch on the cover and inner views. The kit is in `scripts/critic/`.

## 8. Task closeout and stale guidance

At every task closeout, before reporting:

1. Compare what the documents say with the fetched branches, the pull request state and the evidence. Repair stale status and stale references as part of the change. A passing structural check (`scripts/toolchain/check-gauntlet-guidance.py`, the docs link check) does not prove the documents are right.
2. Update [docs/STATUS.md](docs/STATUS.md) when the integrated base, active work, top weaknesses, blockers or next action changed.
3. State the concrete player or maintainer gain, the observed evidence and the largest remaining weakness.
4. Never ask Pat to update ordinary project documents.

## 9. How runs are bounded

There are two kinds of run.

**Gauntlet runs** follow the milestone loop quoted in section 1. Task completion is not program completion: after each task, root collects the result, reviews and reconciles it, checks for staleness, and starts the next highest-value authorized improvement. The user alone ends the Gauntlet. Pat's playtest never gates development.

**Chartered runs** have their own charter file with a defined stop point (for example `.fable/FABLE_RUN.md`). A chartered run follows its charter and stops where the charter says.

For both: only Pat's stop, a charter's stop point, or actual usage or platform exhaustion interrupts the work. On exhaustion, commit and push everything, record the exact SHA, branches, owners, evidence and first resumption command, and mark the status PAUSED, RESUME REQUIRED. Never claim that work continues after a session ends.

Whether future work runs as a perpetual Gauntlet or as chartered runs is Pat's choice per session.

## 10. Not carried forward

Earlier files named specific models and effort levels for workers and reviewers, a Codex queue on another branch, and dated pause banners. Those were session arrangements, not standing rules. Each one is listed with its disposition in [docs/GOVERNANCE_MIGRATION.md](docs/GOVERNANCE_MIGRATION.md). Model choice is set per session by Pat or by the run's charter.
