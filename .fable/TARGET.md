# Target: Siren's Song

Facts in this file were observed on 2026-11-11 from GitHub. Phase 0 re-verifies every SHA and status line before the run relies on it. Where this file and the live repository disagree, record the difference in RUN_LOG.md and follow the newer evidence by date.

Source tags: **[REPO]** read from the repository at the ref named. **[PAT]** Pat's own words or rulings. **[PAT-MEMORY]** stated by Pat in earlier conversations with Claude and recorded in Claude's memory (not in the repository; treat as Pat's direction, quote it as such, do not paste it into canon files as a verbatim ruling).

## 1. Identity

Original Android-first 2D tactical submarine stealth and reconnaissance game. One pilot commands USS Quietus and two drones through alien industrial water under superior Siren threats. Godot 4.6.3, GDScript, Compatibility renderer. Game source in `game/`. [REPO: README.md, AGENTS.md]

Design premise [PAT-MEMORY]: the Sirens are superior aliens who kill anything they judge a threat. The player's job is to look like something they need not care about while researching them. Player tools may protect (the knockdown torpedo is a bola, EMP, decoys) but never permanently disable a Siren, because that would bring a military response.

Pat's direction for the game [PAT-MEMORY]: build out the v7 prototype as a full game with the design ideas he has approved; finish a whole rough playable game first, then evaluate and improve it, instead of polishing every edge of unfinished pieces. Earlier agents lost time on APK churn and over-engineered save files instead of making the game. Long-term aim is app-store quality. Pat tests after a run stops and then gives concrete feedback; a run never waits on his playtest.

## 2. Run location and backups

- Dedicated run clone (the session's working directory): `~/Documents/Claude Cowork Homebase C/repos/_fable/Siren-s-Song`
- Pat's existing clone, which the run never touches: `~/Documents/Claude Cowork Homebase C/repos/Siren-s-Song`
- Backups made by the bootstrap: `~/Documents/Claude Cowork Homebase C/repos/_backups/Siren-s-Song-pre-overhaul-20261111.git` (mirror) and `.bundle` (verified bundle of every ref).
- Rollback for Pat: every shared branch is untouched by design. The run's own work lives only under `fable/`. The tag `fable/pre-overhaul-20261111` marks the base.

## 3. Branches and live state

| Ref | Role [REPO] |
| --- | --- |
| `main` | Protected accepted baseline. Pat authorizes promotion. |
| `claude/integration` | Development integration line. **BASE_REF for this run.** Feature PRs target it. |
| `gauntlet/production` | Frozen promotion baseline. |
| `codex/handoffs` | Coordination branch: `docs/state/STATE.md`, `queue.json`, `RULINGS.md`, `DECISIONS.md`, `items/`, and design audits under `docs/design/` (COLD_REVIEW_1 to 4, plan drafts). Read with `git show origin/codex/handoffs:<path>`. Read-only for this run. |
| `claude/workflow-v2` | Workflow v2 material, including `docs/workflow-v2/QUESTIONS_FOR_PAT.md` (Q3 intent card and spec line 73, Q4 daily digest, Q5 model cap: waiting on Pat). |
| `archive/*` | Preserved evidence snapshots, for example `archive/gauntlet-evidence-2026-10-19` and `archive/workflow-v1-2026-10-31`. |

Remote branch count on 2026-11-11: 373 (190 `claude/*`, 114 `gauntlet/*`, 28 `archive/*`, 20 `item/*`, 4 `codex/*`, 4 `audit/*`, 4 `maintenance/*`, 3 `docs/*`, and singles). [REPO: git ls-remote]

Last recorded state, `codex/handoffs:docs/state/STATE.md`, updated 2026-11-01 21:46 by the queue runner [REPO]:

- Integration `6182568d`, main `a2300840`, production `26e09906`. The `claude/integration` tip on 2026-11-11 is a later docs commit (2026-11-01 22:23, "docs: retain working capabilities unless owner explicitly cuts them"). Phase 0 records the exact tip.
- Items 126 to 148 and package 2 (stable board) merged; one item parked (134, route flow, package 4).
- A debug APK of `6182568d` was built for Pat (workflow run 41379272814).
- Codex provider was down (401 Unauthorized). No other writer was active. Confirm in Phase 0.
- Nightly dispatch fails until `nightly-integration.yml` exists on `main`.
- Planned next: **Critic 6**, a blind whole-game critic on `claude/integration` that must reach END OF LINE and each ending family, Glass Reach ops 5 to 9, Iron Choir, one full Expedition, a Career stretch and Ironman. Its watch list is in STATE.md and must not be given to the critic.
- Planned after Critic 6, in this order: photo payoff (value currently favors distance and tools over photo quality); late-operation variety and the branching route graph (forks mostly change approaches inside operations, not which operations you get; Star Fox scope in the spec); fitting allocation; a read-only look-and-sound comparison (building waits on Pat's art calls; audio never assessed).

## 4. Authority

Order [REPO: AGENTS.md, docs/SOURCE_AUTHORITY.md]: current explicit user decisions, then `docs/CURRENT_GAME_SPEC.md` with accepted amendments read with the ratified design bible, then accepted concept selections and visual decisions, then source-verified playable behavior and runtime evidence, then historical specifications, then proposals. The playable v7 prototype (`reference/original-prototype/sirens_song_prototype_v7.html`) is a working implementation reference: do not drop its demonstrated mechanics without comparison and rationale.

Rulings live in two places today: `docs/USER_DIRECTIVES.md` on `claude/integration` and `docs/state/RULINGS.md` on `codex/handoffs`. Read both in full. Consolidating them into one home on the run branch is part of Phase 3 (copy verbatim, keep dates and attribution, never rephrase). `codex/handoffs` itself stays untouched; whether to retire it is a decision for Pat.

Rulings the run must apply, quoted from `RULINGS.md` [PAT]:

- 2026-10-30, gauntlet priorities: "The storyline is the least important besides how it affects branching paths. The main point of the gauntlet loop right now is gameplay, graphics, ux, ui, bugs, features. The whole point is that we have a complete game. We review it, figure out where it's lacking especially in comparison to other AAA releases, and then we plan out the upgrades, and then we execute."
- 2026-10-30, reference-judged plan: approved judging each piece blind against named reference games (proposed: Cold Waters, FTL, Into the Breach, Highfleet, Barotrauma, Mini Motorways), and "At every major milestone you should stop and evaluate our progress, find areas where we can tighten up our workflow or improve, find our weakest areas, and essentially run a mini gauntlet loop against our own workflow".
- 2026-10-30, controls: one-press travel shortcuts "are fine for testing but they will absolutely have to be stripped for release play".
- 2026-10-30, movement: "You should still be able to crash. But there should be moderate autopilot for edges and stuff so you're not just getting stuck grinding on things if you fuck up."
- 2026-10-31, minimum tests: "you should always be using the absolute minimum number of required tests and you should always be aiming to get them as quickly done as possible. This doesn't mean take shortcuts, this doesn't mean modify CI to pass on a red". The applied rule (D36) is in RULINGS.md; follow it.

Story ruling, quoted from `docs/USER_DIRECTIVES.md` on `claude/integration` [REPO]: "the Siren-evacuation / human-fleet-threat arc is rejected as unratified AI fabrication and will be stripped. ... **Do not author new narrative text.** Claude orchestrates the rewrite; the user approves characters, site sequence and ending conditions before they land." This run writes no narrative text. It may prepare a structural proposal for Pat (site sequence options, which operations change, which systems carry the rescue survivors) as a document under `docs/proposals/`, tagged AI-designed, for Pat's ruling.

Protected game rules: any rule USER_DIRECTIVES or RULINGS marks "Protected, your call", plus Siren senses, sight ranges, lock, beam, collision, damage and hull rules, and the never-permanently-disable principle. Changes to these are Pat decisions (charter 4.2).

Feature continuity: the owner directive at the top of `AGENTS.md` and `CLAUDE.md` is Pat's. Carry it verbatim into the new AGENTS.md.

## 5. Gates and toolchain

[REPO: docs/TESTING.md, docs/DESKTOP_HANDOFF.md, docs/CODEX_ENVIRONMENT.md]

- On Windows, the Linux toolchain scripts run under WSL2 Ubuntu. Read DESKTOP_HANDOFF.md for the working setup before Phase 0 step 2.
- `game/tests/suites.txt` is the single suite registry. `scripts/toolchain/test.sh --list --profile ci` lists them. `scripts/toolchain/select-suites.py` picks the suites a diff reaches.
- Local gate per work package: import, core, the affected suites, the canaries and `check-suites`. Never the full scenario list locally.
- Baseline gate (Phase 0): import and core locally.
- Full gate: the four-shard matrix on GitHub. `gauntlet-pr-checks.yml` runs it on `workflow_dispatch` (`gh workflow run gauntlet-pr-checks.yml --ref fable/overhaul-20261111`) and on ready PRs that touch shared code. Draft PRs run guidance only.
- Core must end `CHECKS N FAILURES 0` with N above zero; other suites end with their registered prefix and the same strict line. Resource-in-use lines, script errors and leaks fail.
- CI has a `guidance` job that runs `scripts/toolchain/check-gauntlet-guidance.py` against the governing documents. Governance consolidation must update that checker and its test (`test-check-gauntlet-guidance.py`) in the same change, so it audits the new structure. Do not weaken what it protects.
- APK: use the existing integration APK route (item 147, see `.github/workflows/android-validation.yml`). Sign only with the tracked development keystore `scripts/toolchain/signing/sirens-song-debug.keystore` (alias `androiddebugkey`, wired by `scripts/toolchain/configure.sh`). One build, at Phase 5. [PAT, 2026-11-11] Any private or release key stays out of the repository and is gitignored; Pat provides it when and as needed. Do not look for one, create one, or ask for one in this run.
- Git hooks: the bootstrap installed the run's own pre-commit, pre-push and reference-transaction hooks in this clone. Do not run `scripts/toolchain/install-gauntlet-hooks.py` here (it refuses unmanaged hooks by design). Call `scripts/toolchain/gauntlet-boundary.py` directly where the governing documents require a boundary check.
- Critic tooling: the critic driver and sender had a JSON parse failure in October that stalled critics (fixed as package 0 or later, verify). The critic briefs are `docs/CRITIC_BRIEF.md` and the cold review history on `codex/handoffs`.

Engine detail: use fresh output directories for each check instead of cleaning old ones (the guard blocks deletion). Godot import caches (`.godot/`) are gitignored.

## 6. Phase inputs specific to this repository

### Phase 1 (Survey)

- Read in full: README.md, AGENTS.md, CLAUDE.md, every file in `docs/` and `design/`, `references/package/START_HERE.md` and the concept selection ledger, and from `codex/handoffs`: `docs/state/STATE.md`, `RULINGS.md`, `DECISIONS.md`, `queue.json`, every `docs/state/items/*.md`, and the latest cold review and plan drafts under `docs/design/` and `docs/codex/`.
- Run **Critic 6** as defined in STATE.md, through the existing critic kit, as one fresh blind reviewer subagent per region in parallel where staged profiles allow (within the subagent limit), with no source access and no watch list. Each critic writes its verdict outside the active tree as the repository's rules require; you commit only the merged ranked findings, as `.fable/COLD_REVIEW_6.md`, ranked by gameplay, graphics, UX and UI, bugs and missing features against the reference games in section 4. If the critic kit cannot run, fix it as the first P0 package and then run the critic.
- The protected capabilities ledger must cover at least: every campaign operation and both branch routes, Expedition, Career, Challenges, Ironman, presets and the advanced economy, every fitting and tool, every Siren role and its counterplay, sonar and identification rules, thermal bands, photos and dossier, save, restore and import or export, settings and accessibility (pause aids, mirrored HUD, text scale, contrast, reduced motion), title, profiles and menus, Android lifecycle and back handling, and the dev-only travel shortcuts (kept, gated).

### Phase 2 (Plan)

Seed P1 from Critic 6 and from the planned order in section 3. Pat's priorities (section 4) rank gameplay, graphics, UX and UI, bugs and features above story. Expansion-readiness packages that fit this game: data-driven operation, encounter, equipment and consequence definitions (already the spec's stated direction), the branching route graph, and short guides for adding an operation, a Siren role, a fitting and a region.

### Phase 3 (Foundation): known gaps

- Layered pointer documents: README, CONTINUATION, WORKBENCH and RESUME on `claude/integration` point at each other and at STATE.md on another branch. The README still carries a "cloud stop, wait for Pat to resume" banner that CONTINUATION says is lifted.
- Governance text is spread across AGENTS.md, CLAUDE.md, RESUME.md, GAUNTLET_ORCHESTRATION.md, architecture/GAUNTLET.md, AGENT_BRIEF.md, CODEX_ENVIRONMENT.md, USER_DIRECTIVES.md, `docs/directives/` and banners at the top of the spec and source authority files.
- The governing files describe a perpetual Gauntlet ("The user alone can terminate the program"). This run is bounded by its charter. In the new AGENTS.md, keep the Gauntlet loop policy as the policy for Gauntlet runs and add that a run with its own charter follows that charter's stop point. Whether future work runs as a perpetual Gauntlet or as bounded runs is a decision for Pat; record it.
- Model routing lines name `gpt-6.1-sol` and Astra routing. Classify them in the migration table; this run uses Claude only.
- 57 Markdown files on `claude/integration`, many dated pause or checkpoint notes (for example `docs/PAUSE_CHECKPOINT_2026-10-21.md`, `docs/directives/`).
- No `CHANGELOG.md`, no PR template, no `.gitattributes`.

## 7. Out of scope for this run

- Narrative text of any kind (section 4).
- New art direction or final art. Placeholder art that already exists stays. Pat makes art calls.
- Store submission, release signing, monetization, marketing.
- Physical-device acceptance claims. Pat plays the APK after the run.
- Writing to `codex/handoffs`, `claude/workflow-v2`, `main`, `gauntlet/production` or `claude/integration`.
- Answering the open workflow-v2 questions (Q3 to Q5) on Pat's behalf. List them in DECISIONS.md if the run depends on them.

## 8. High-risk areas (second reviewer allowed)

Save, restore, import and export; simulation determinism and seeded Expedition generation; touch input routing and gesture ownership; the critic driver; CI workflow changes.
