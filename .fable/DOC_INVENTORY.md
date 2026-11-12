# Documentation inventory

Every tracked documentation file on the base (`cabd5bd5`, 57 Markdown files outside the run's own folders), with its last commit date, role and class. Each file was read in full: the governing files, the specification and the rulings by the root session, the rest by a read-only explorer whose report the root reviewed. Classes follow charter section 6.2:

- **LIVE:** stays. "LIVE, fix" means stale statements are corrected in place in Phase 3.
- **CARRY:** every live statement moves into a living document, then the file goes to `_scrap-20261111/`.
- **HISTORICAL:** a dated checkpoint or handoff with nothing live left; goes to scrap.
- **UNSURE:** staleness is uncertain; stays in place and is listed in DECISIONS.md (D-02).

## Governing and entry documents

| Path | Last commit | Role | Class | Notes |
| --- | --- | --- | --- | --- |
| `AGENTS.md` | 2026-11-01 | Governing agent file: feature-continuity directive, Gauntlet loop, merge and review rules | LIVE, rewrite | Old text goes to scrap after the migration table is complete. The feature-continuity directive is carried verbatim. |
| `CLAUDE.md` | 2026-11-01 | Copy of the feature-continuity directive only | LIVE, rewrite | Becomes `@AGENTS.md`. |
| `README.md` | 2026-10-24 | Project entry | LIVE, rewrite | Carries the 23 Oct "cloud stop" banner that later documents lift. |
| `docs/START_HERE.md` | 2026-10-24 | Second entry page | CARRY | Into `README.md` and `AGENTS.md`. Same stale banner. |
| `docs/RESUME.md` | 2026-11-01 | Operational entry; points at `docs/state/` on `codex/handoffs` | CARRY | Into `docs/STATUS.md` and `docs/WORKFLOW.md`. Holds the 1 Nov APK ruling summary. |
| `docs/CONTINUATION.md` | 2026-11-01 | Pointer file | CARRY | Into `docs/STATUS.md`. |
| `docs/WORKBENCH.md` | 2026-11-01 | Pointer file | CARRY | Into `docs/STATUS.md`. |
| `docs/AGENT_BRIEF.md` | 2026-10-24 | Worker and reviewer brief rules | CARRY | Into `AGENTS.md` and `docs/WORKFLOW.md`. Stale banner; model routing lines. |
| `docs/GAUNTLET_ORCHESTRATION.md` | 2026-10-24 | Boundary helper, hook installer, Android validation routes, closeout check | CARRY | Tool usage into `docs/WORKFLOW.md`. Stale banner; APK prohibition superseded on 1 Nov. |
| `docs/architecture/GAUNTLET.md` | 2026-10-24 | Technical architecture: system boundaries, platform, verification approach | LIVE, fix | Stale banner and two "no APK" sentences. `gauntlet-boundary.py` reads it. |
| `docs/SOURCE_AUTHORITY.md` | 2026-10-25 | Authority order and provenance rules | LIVE, fix | Two stale banners; points at RESUME. |
| `docs/USER_DIRECTIVES.md` | 2026-10-30 | Pat's rulings to 30 Oct, verbatim and dated, with agent notes on their effect | LIVE | Becomes the one home for rulings: the 29 Oct to 1 Nov rulings from `codex/handoffs:docs/state/RULINGS.md` are appended verbatim. One link to the pause checkpoint is repointed. |
| `docs/directives/2026-10-20-order-correction.md` | 2026-10-20 | Pat's verbatim order of 20 Oct | LIVE | Verbatim owner record that USER_DIRECTIVES links. Stays as provenance. |
| `docs/directives/2026-10-20-audit-reaffirmation.md` | 2026-10-20 | Pat's verbatim audit order and loop rule | LIVE | Same. |
| `docs/QUESTIONS_FOR_PAT.md` | 2026-10-29 | Owner question list with ruled markers | LIVE, fix | Items 8 and 23 show as open; RULINGS records "Later" and "Yes, keep 29". Markers added with the verbatim answers. |
| `docs/REPOSITORY_MAP.md` | 2026-10-27 | Paths, branch roles, a 22 Oct branch snapshot | LIVE, fix | Queue pointer and branch snapshot are stale; the branch ledger replaces the snapshot. |
| `docs/DESKTOP_HANDOFF.md` | 2026-10-24 | 23 Oct cloud to Windows handover | HISTORICAL | The handoff 023 steps are done. Carried first: Godot user-data paths and the evidence archive pointer into `docs/TESTING.md`; the key rule is already in `scripts/toolchain/signing/README.md`. Sixteen inbound links, all from files this run rewrites or scraps. |
| `docs/PAUSE_CHECKPOINT_2026-10-21.md` | 2026-10-20 | Codex stop checkpoint of 21 Oct | HISTORICAL | One inbound link (USER_DIRECTIVES line 215), repointed to the scrap path. The story ruling it quotes is in USER_DIRECTIVES. |
| `docs/CODEX_ENVIRONMENT.md` | 2026-10-24 | Toolchain setup, signing note | CARRY | Into `docs/TESTING.md` (environment section). Says WSL is required; the native Windows toolchain exists. Says APKs are prohibited; superseded. |
| `docs/CRITIC_BRIEF.md` | 2026-10-24 | Brief for independent critics | CARRY | Into `scripts/critic/CRITIC_BRIEF.md`. Stale banner. |

## Specification, design and rulings

| Path | Last commit | Role | Class | Notes |
| --- | --- | --- | --- | --- |
| `docs/CURRENT_GAME_SPEC.md` | 2026-10-25 | Living game specification | LIVE | Kept as it is. Its three banner lines are stale pointers and are replaced by one pointer line; nothing else changes. Line 73 "safe pathfinding" conflicts with Pat's 30 Oct movement ruling: that is open question Q3 on `claude/workflow-v2` and stays for Pat. |
| `design/SIRENS_SONG_DESIGN_BIBLE_GAUNTLET_V1.md` | 2026-10-19 | Design bible | LIVE | Kept as it is. |
| `docs/V7_TO_GODOT_PARITY.md` | 2026-10-28 | v7 to Godot mechanics ledger | LIVE | Kept as it is apart from banner lines. Line 59 calls challenge pars proposals; they were ratified on 27 Oct (see CHALLENGE_PARS_PROPOSAL). Recorded in the migration table, not edited. |
| `docs/PHOTO_RECON.md` | 2026-10-29 | Photographic pillar and capability record | LIVE | Says operation IDs are 0..31; the catalog is 0..41. Noted in STATUS, not edited (its history sections are labelled). |
| `docs/STORY_BIBLE_DRAFT.md` | 2026-10-29 | Provisionally approved story direction | LIVE | Narrative: not edited by this run. Three internal contradictions are listed in D-03. |
| `docs/MODULES.md` | 2026-10-29 | Module, switch and revert index | LIVE, fix | Baseline predates items 126 to 148. Rows for the missing modules are added by the expansion-guide package. |
| `docs/A11Y_CUES.md` | 2026-10-28 | Sound and colour cue inventory | LIVE | Line 108 "integration pending" is stale (081 merged); corrected. |
| `docs/CONVENTIONS.md` | 2026-10-24 | Builder code conventions | LIVE | |
| `docs/TESTING.md` | 2026-10-31 | Suite registry, CI selection, local limits | LIVE, fix | Gains the environment section; the WSL-only and no-APK lines are corrected. |
| `docs/DEBUG_CONSOLE.md` | 2026-10-28 | Developer console | LIVE, fix | Add that item 127 gates one-press travel behind the same developer state. |
| `docs/PLAYTEST_ANDROID.md` | 2026-10-24 | Phone playtest procedure | LIVE, fix | Header prohibits APK builds; superseded by the 1 Nov ruling. Add the any-branch debug APK route (item 147). |
| `docs/FUTURE_OPTIONS.md` | 2026-10-24 | Preserved sweeper hard-mode option | LIVE | |
| `docs/decisions/README.md` | 2026-10-24 | Decision record index | LIVE, fix | One stale APK sentence. |
| `docs/decisions/0001-godot-android-production.md` | 2026-10-19 | Engine decision record | LIVE | |
| `docs/design/HUNT_RESTORE.md` | 2026-10-27 | Sight-only Hunt decision and Pat's 27 Oct tuning ruling | LIVE | |
| `docs/design/CHALLENGE_PARS_PROPOSAL.md` | 2026-10-27 | Challenge par measurements; ratified by Pat 27 Oct | LIVE | Design record with a ruling; stays. |
| `docs/design/AUTHORED_ENDING_125.md` | 2026-10-30 | Before and after copy table for the authored ending | UNSURE | Narrative placeholder record; no inbound links. D-02. |
| `docs/design/STEALTH_AI_ROADMAP.md` | 2026-10-23 | AI-designed Siren AI roadmap, partly built | UNSURE | Proposal with several points later ruled. Feeds the backlog. D-02. |
| `docs/design/HUMAN_TEST_READINESS.md` | 2026-10-24 | Unratified proposal for a gate before phone testing | UNSURE | No inbound links; one dead link; partly superseded by the 1 Nov ruling. D-02. |
| `reports/2026-11-01-sirens-song-full-project-overview.md` | 2026-11-01 | Progress overview, 27 Oct to 1 Nov | UNSURE | Describes itself as a historical checkpoint; item 146 forbade editing `reports/`. No inbound links. D-02. |

## Reference and provenance

| Path | Last commit | Role | Class | Notes |
| --- | --- | --- | --- | --- |
| `reference/original-prototype/MANIFEST.md`, `SIRENS_SONG_dev_notes.md`, `SIRENS_SONG_functional_spec.md`, `SIRENS_SONG_pressure_design.md`, `history/DEEP_CONTACT_original_spec.md` | 2026-10-19 | Original prototype handoff, with Pat's playtest quotes | LIVE | Immutable provenance. Also here, not Markdown: the playable v7 HTML, the v6 HTML and the original zip. |
| `references/package/START_HERE.md` | 2026-10-22 | Visual package entry with Pat's visual decisions | LIVE | Required by the guidance checker. |
| `references/package/SIRENS_SONG_CONCEPT_SELECTION_LEDGER.md` | 2026-10-22 | Concept selection ledger | LIVE | Required by the guidance checker. |
| `references/package/sources/02-...DESIGN_BIBLE...md` | 2026-10-19 | Package copy of the design bible (byte-identical) | LIVE | Hash-listed in `MANIFEST.json`. |
| `references/package/sources/03-...VISUAL_EXPLORATION_PLAN...md` | 2026-10-19 | Package copy of the visual plan without the historical banner | LIVE | Hash-listed in `MANIFEST.json`. |
| `references/visual/SIRENS_SONG_VISUAL_EXPLORATION_PLAN_V3_HANDOFF.md` | 2026-10-19 | Visual plan with its historical banner | LIVE | Required by the guidance checker. |
| `references/visual/README.md` | 2026-10-20 | One-line pointer to a PDF that is only on `archive/reference-package-20261022` | LIVE, fix | Dead relative link; repointed to the archive branch. |

## Beside the code

| Path | Last commit | Role | Class | Notes |
| --- | --- | --- | --- | --- |
| `game/src/persistence/profiles/README.md` | 2026-10-28 | Profiles module | LIVE | |
| `game/src/diagnostics/AI_TRACE.md` | 2026-10-24 | AI trace observer | LIVE, fix | Says no other file refers to it; Hunt now does. |
| `game/assets/ATTRIBUTION.md` | 2026-10-22 | Art provenance | LIVE | Cites a generator script path that is not in the tree; recorded, left as provenance. |
| `game/assets/audio/ATTRIBUTION.md` | 2026-10-26 | Audio licences | LIVE | Two sentences about Hunt disagree with each other; recorded in the survey. |
| `scripts/toolchain/signing/README.md` | 2026-10-19 | Development key provenance | LIVE | Protected path. |
| `scripts/toolchain/win/README.md` | 2026-10-24 | Native Windows toolchain | LIVE | |

## On `codex/handoffs` (read-only for this run; nothing moves)

| Path | Last commit | Role | State |
| --- | --- | --- | --- |
| `docs/state/STATE.md`, `queue.json` | 2026-11-01 | Live queue and status of workflow v2 | Read. Content is carried into `docs/STATUS.md` on the run branch. |
| `docs/state/RULINGS.md` | 2026-11-01 | Pat's rulings 29 Oct to 1 Nov, and the draft intent card (unratified) | Copied verbatim into `docs/USER_DIRECTIVES.md` in Phase 3. |
| `docs/state/DECISIONS.md` | 2026-11-01 | Agent decisions D1 to D37 that Pat can revert | Read. The ones that are rules are classified in the migration table. |
| `docs/state/items/*.md` (23) | 2026-10-31 to 2026-11-01 | One card per queue item 126 to 148 and package 2 | 22 done, item 134 parked. |
| `docs/design/COLD_REVIEW_1..5`, `ARCH_AUDIT_1`, `DESIGN_*`, `FLEET_MATTERS_*` (12) | 2026-10-22 to 2026-10-30 | Critic reviews, design proposals, the fleet pressure diagnostic | COLD_REVIEW_5, COLD_REVIEW_4 and FLEET_MATTERS seed the plan. The rest is history. |
| `docs/codex/*` (146) | to 2026-10-31 | Workflow v1: board, ledger, handoffs, `PAT_RULINGS_2026-10-29.md` | Frozen; also on `archive/workflow-v1-2026-10-31`. |

Whether `codex/handoffs` is retired once its live content is on the integration line is D-04.

## Contradictions found, and how each is resolved

Newer evidence wins unless the older text is a verbatim Pat ruling the newer one does not supersede (charter 6.1). Each row is repeated in `docs/GOVERNANCE_MIGRATION.md` in Phase 3.

1. **APK builds.** Nine documents forbid them. Pat, 1 Nov: "If it would be easier to test on, you can build the apk. Just ve smart about the debug signing. We dont need release signing yet." The ruling wins; item 147 added the any-branch debug APK job.
2. **Promotion target.** USER_DIRECTIVES 26 Oct sends milestone PRs to `gauntlet/production`. Pat, 31 Oct, answered yes to making `main` the only promotion target with `gauntlet/production` frozen. The 31 Oct ruling wins.
3. **Per-feature review.** USER_DIRECTIVES 26 Oct drops it; 28 Oct restores an independent reviewer and says it supersedes the earlier entry. 28 Oct wins.
4. **Who builds.** USER_DIRECTIVES 28 Oct (later) says Claude launches no subagents. Pat, 31 Oct: bounded Claude builders are allowed. The 31 Oct ruling wins for Gauntlet work; this run follows its charter.
5. **Local test scope.** Decision D10 ("full suite before every push") was reverted by D20 and by Pat's 31 Oct minimum-tests ruling. The ruling wins.
6. **Windows toolchain.** Three documents say WSL2 is required. `scripts/toolchain/win/` runs natively and is what this run used. The scripts win.
7. **Queue authority.** REPOSITORY_MAP and HUMAN_TEST_READINESS point at `docs/codex/BOARD.md`; `docs/state/` replaced it on 31 Oct.
8. **Operation count.** PHOTO_RECON, the parity ledger, the pause checkpoint and the story draft give 30 or 32 operations; the catalog has IDs 0 to 41 and Pat ruled "Yes, keep 29" core operations.
9. **Sorley reward and diver ascent in the story draft.** The draft's summary lines disagree with its own later sections and with Pat's 29 Oct rulings. Narrative file: not edited, listed in D-03.
10. **Hunt and audio.** `game/assets/audio/ATTRIBUTION.md` says the ambience reads no Hunt stage and, later, that it adds a Hunt offset. The code decides; checked in the survey.
11. **Challenge pars.** The parity ledger calls them proposals; Pat ratified route pars on 27 Oct.
12. **Critic brief.** `docs/CRITIC_BRIEF.md` lacks what decision D11 requires. The new brief in `scripts/critic/` asks the decided-versus-watched question and carries the lens, labelled unratified.
13. **Sweeper patrols.** The v1 board calls authored sweeper patrol points "against the PR70 invariant" while MODULES lists `campaign/sweeper_patrols.gd`. Left as built; listed in D-03 for Pat.

## Dead links

- `references/visual/README.md` to a PDF that exists only on `archive/reference-package-20261022`.
- `game/assets/ATTRIBUTION.md` names `docs/validation/production/blackwater-direct/render_receiver_plates.py`, which is not in the tree.
- `docs/design/HUMAN_TEST_READINESS.md` to `docs/repository/RC_ACCEPTANCE_...` (the folder does not exist).
- Links in `COLD_REVIEW_4`, `COLD_REVIEW_5` and `FLEET_MATTERS` on `codex/handoffs` point at machine-local `C:/Users/...` paths.
