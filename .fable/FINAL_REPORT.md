# Final report: overhaul run `overhaul-20261111`

Status: FINAL (2026-11-12)

Branch `fable/overhaul-20261111`, final game code at `247e0582` (later commits on the branch change only run documents), base `claude/integration` at `cabd5bd5` (tag `fable/pre-overhaul-20261111`). Pull request: https://github.com/pemunson90-cmd/Siren-s-Song/pull/262 (complete, left as a draft on purpose, unmerged; see D-15; Pat merges).

## In plain English (for Pat)

**What you will notice when you play**

- *Getting caught makes sense.* When you line up a photograph, the map draws a ring showing how far the shutter noise carries. When a Siren locks onto a craft, a countdown appears next to that craft. When you lose a drone, the message says what destroyed it and from which direction, or "UNSEEN SIREN" if you never saw it. A new optional setting (off by default) pauses the dive when a craft is lost.
- *Planning while paused works.* Tapping a craft while paused no longer swings the camera away. RESUME always resumes in one press, and the button is large enough that taps are not missed. The "replace this route?" box names its real buttons, shows what the craft is doing now, and the clock stops while it is open.
- *Photographs explain themselves.* There is a SHUTTER button in the camera panel. If you are zoomed wide on something that needs a close-up, you get a warning before film is spent; press again to shoot anyway. After a dive, and in the archive, each photograph shows what it earned.
- *Oxygen is always visible.* While the dive is running the pause button shows oxygen and roughly how long is left, and turns amber at 25 percent. From the second operation on, the briefing says how long the oxygen lasts.
- *Buttons and labels stay put.* Warning labels no longer jump or run off the screen. After a lost dive, RETRY is at the top. The Expedition start screen keeps BEGIN at the bottom of the screen. A greyed-out LOAD button says why. Typos such as "by45%" are fixed.

**Not changed:** no game rule, number, Siren behavior, story text or price. The developer travel shortcuts still work in your test build; they are blocked only in a release build, as you ruled on 30 October.

**Behind the scenes:** one rulebook for agents, one status page and one list of your rulings (your words copied exactly). Ten outdated notes moved to a scrap folder; nothing was deleted. Safety tests lock in your protected numbers and the rule that no tool permanently disables a Siren. Adding an operation, region, Siren type or fitting is simpler and has a short how-to. A plan to tidy 326 old branches is written and waits for your yes.

**What I could not check:** nothing was seen on a real phone. Everything was checked by automated tests and by three AI play-testers, who covered the opening and middle of the campaign only. Two player complaints turned out to be the game working as designed and are left for you: drones start just outside recovery range (D-11) and there is no obvious way back to the title from the Operations screen (D-12).

## 1. Outcome

The repository now has one governing file, one status file, one rulings file, a changelog, a tested harness around Pat's protected rules, and CI that also runs the tool tests nothing ran before. On top of that base the run landed six player-facing packages that answer the blind critics' top findings: readable detection and drone loss, a planning camera that stays put, truthful order dialogs, a clearer photograph flow, always-visible life support and reachable primary buttons. No game rule, number, story text or saved field changed, with one exception listed in section 4 (a drone-loss event carries one extra key that is not saved).

## 2. For the player

- **You can see why you were caught.** While framing a photograph the chart draws how far the shutter is heard. Every craft under a Siren lock shows a countdown beside it. A lost drone says what destroyed it and from which bearing, or "UNSEEN SIREN" when you held no contact. A new setting (off by default) pauses the dive when a craft is lost.
- **Planning while paused works.** Selecting a craft while paused no longer moves the view. RESUME closes an open ring or pending marker and resumes in one press, and its button now fits its label (taps on it were being missed). The route confirm dialog names its real buttons, shows the craft's live orders and holds dive time while open.
- **Photographs explain themselves.** The camera panel has a SHUTTER control. A WIDE frame of a subject that needs fine detail warns before film is spent; a second press within four seconds exposes anyway. The ring shows one reach figure. The debrief and the archive show what each photograph added.
- **Life support is on screen whenever the dive is running** (oxygen and an estimated time left, on the pause control), and from operation 1 on the briefing states the operation's life-support time.
- **Chips and buttons stay where you can use them.** Threat and notice chips stay inside the screen; the Hunt chip stops jumping; loss debriefs put RETRY and OPERATIONS ARCHIVE under the heading; the Expedition pre-dive page pins BEGIN and RETURN; a grey LOAD button says why.
- **Release builds** refuse the developer travel shortcuts on every profile (Pat, 30 October: "they will absolutely have to be stripped for release play"). The debug package Pat tests is unchanged in this respect.

## 3. For the engineering

- **Governance:** `AGENTS.md` is the single governing file (feature-continuity directive carried verbatim); `CLAUDE.md` imports it; `docs/STATUS.md` is the one status file; `docs/WORKFLOW.md` holds the branch model, commit format, review and merge rules and CI gating; `docs/GOVERNANCE_MIGRATION.md` accounts for every rule of the old governing files. Pat's rulings from `codex/handoffs` and from this run are appended verbatim to `docs/USER_DIRECTIVES.md`.
- **Documents:** every documentation file is classified in `.fable/DOC_INVENTORY.md`. Ten pointer and handoff documents moved to `_scrap-20261111/` with a manifest. Stale banners and superseded instructions were corrected in place.
- **Hygiene:** `.gitattributes` (LF text, byte-exact provenance and fixtures), tracked Godot `.uid` files so an import leaves a clean tree, a PR template, `CHANGELOG.md`, a documentation link checker.
- **CI:** the fast `guidance` job also checks documentation links and runs eleven tool self-tests that no workflow ran; `game-core` runs two helper tests that need Godot. The matrix is unchanged and nothing redundant was added.
- **Harness:** the protected-rules golden pins 23 more of Pat's numbers; a new suite states that no player tool permanently disables a Siren, for all eight roles; a release build gate suite; an operation metadata parity suite. Fourteen suites were added in total (ranks 1404 to 1418).
- **Expansion seams:** per-operation metadata lives in one table (`game/src/campaign/operation_meta.gd`) with a parity suite; `docs/guides/` explains how to add an operation, a region, a Siren role and a fitting. Each new player-facing module sits behind one switch and is listed in `docs/MODULES.md`.
- **Tools:** `scripts/critic/` (the blind critic kit, versioned and reviewed) and `scripts/repo/` (branch ledger, archive planner, link check, capabilities ledger check and status, run-state helpers).
- **Critic 6:** three blind critics played the opening campaign, the side modes and the mid campaign; findings are ranked in `.fable/COLD_REVIEW_6.md`. Coverage is partial: no critic reached the endings, Iron Choir, Career, Challenges or Ironman. That is the first item of the P2 backlog.

## 4. Behavior changes

Complete table, built from `git diff fable/pre-overhaul-20261111..fable/overhaul-20261111` file by file and checked against the work-package reports. "Switch" names the constant that restores the old behavior where one exists.

| # | Change | Where | Package | Switch |
| --- | --- | --- | --- | --- |
| 1 | Release builds refuse the six developer-only travel shortcuts on every profile, including an imported developer-marked profile. Debug builds unchanged. | `presentation/release_controls.gd` | WP-06 | none (ruling of 30 October) |
| 2 | Exported packages no longer contain test scripts. | `game/export_presets.cfg` | WP-06 | the `exclude_filter` line |
| 3 | The `SS_` diagnostic lines and the Android UI metric records print only in debug builds. | `main.gd`, `flow/campaign_flow.gd`, `flow/ui_metrics.gd` | WP-06 | see D-13 |
| 4 | Drone beam-loss event carries an extra key `siren` (the Siren's index). Not saved, not read by the simulation. | `simulation/simulation.gd` | WP-08 | none |
| 5 | While a photograph is framed the chart draws a ring "SHUTTER HEARD <n>m" using the camera panel's own figure; fresh contacts inside it are marked "IN SHUTTER REACH". The existing OWN SHUTTER ring is still drawn at the same radius. | `presentation/threat_read/` | WP-08 | `threat_read_table.gd: enabled` |
| 6 | Every craft under a Siren lock shows a chip "S<n> LOCK · <t>s" beside it. | same | WP-08 | same |
| 7 | A lost drone leaves a wreck mark and bearing ray for 10 seconds, and the loss message begins with cause and bearing ("DRONE A LOST · SIREN BEAM FROM 090° · S1 GUARD", "· UNSEEN SIREN", "· BATTERY EXHAUSTED"). A Siren the player never detected in this dive is not named. | same | WP-08 | same |
| 8 | New setting "TACTICAL AID: PAUSE ON CRAFT LOSS" (`auto_pause_loss`), off by default, saved with the other settings. | `persistence/settings_store.gd`, `frontend/frontend.gd`, `accessibility/tactical_aids.gd` | WP-08 | same |
| 9 | Selecting a craft while paused does not move the view; on resume the view follows the selected craft again unless the player panned, zoomed or used FIT. Selecting while running is unchanged. | `main.gd` | WP-09 | none |
| 10 | RESUME (button or SPACE) closes an open command ring or cancels a pending route marker and resumes in one press. | `main.gd` | WP-09 | none |
| 11 | The pause control grows to fit its wrapped label. | `presentation/mission_hud.gd` | WP-09 | none |
| 12 | Route confirm dialog: text built from the craft's live orders and its real button names; dive time is held while it is open; ADD TO ROUTE is hidden (was shown disabled) when the craft has no route; the UNDO chip says what it restores. | `presentation/order_guard.gd`, `main.gd` | WP-09 | none |
| 13 | The route wedge reads "TAPS: QUEUE" or "TAPS: REPLACE"; the field manual and briefing text name it the same way (instruction text, not story). | `main.gd`, `campaign/onboarding_text.gd`, `flow/campaign_flow.gd` | WP-09 | none |
| 14 | SHUTTER control in the camera panel header (same action as the ring's PHOTO). | `presentation/photo_shutter/`, `camera_feed.gd` | WP-10 | `shutter_table.gd: enabled` |
| 15 | A WIDE frame of a still subject that needs fine detail gives a warning before any film is spent, on both SHUTTER and ring PHOTO; pressing again within four seconds exposes anyway (the old WIDE-then-TIGHT path still works). | same | WP-10 | same |
| 16 | The ring caption shows one camera reach figure ("READY · 60m · REACH 240m") and no distance to an unresolved lead's hidden position ("SEARCH AREA"). | `photo_shutter/range_caption.gd`, `mission_hud.gd` | WP-10 | same |
| 17 | Debriefs show a PHOTO PAY block and the archive a "PAID ·" line per photograph (stored intel, camera research, later chart marks). No pay rule or number changed. | `presentation/photo_pay/`, `flow/campaign_flow.gd`, `expedition_operations.gd`, `archive/archive_view.gd` | WP-10 | `pay_table.gd: enabled` |
| 18 | While a dive runs, the pause control reads "Ⅱ PAUSE" over "O₂ 87% ~3:10" (was "Ⅱ" over "PAUSE"), amber at 25 percent or below; the time is oxygen divided by the base drain rate. The control keeps its size. On a narrow control the line shortens to the time or the percentage. The paused control is unchanged. | `presentation/life_support_chip.gd`, `mission_hud.gd` | WP-11 | `life_support_chip.gd: ENABLED` |
| 19 | From operation 1 on (operation 0 keeps its short opening briefing), the briefing stock line gains "LIFE SUPPORT m:ss at the base rate". | `presentation/truthful_commands.gd` | WP-11 | none |
| 20 | The Hunt chip keeps its seat while the layout is unchanged; once moved aside by a lock card or notice it stays there until the layout changes. | `presentation/hunt_meter.gd` | WP-11 | `meter_table.gd: STICKY` |
| 21 | NOTICE and NEW SIREN TYPE chips grow to their text, wrap, stay inside the content edge and move below a lock card; the Expedition banner sits under the header. | `first_siren_cue/first_siren_cue.gd`, `runs/expedition_session.gd` | WP-11 | none |
| 22 | The ring's centre title wraps to two lines, then ends with an ellipsis. | `radial_layout/center_layout.gd` | WP-11 | `center_layout.gd: FIT_TEXT` |
| 23 | Loss and withdrawal debriefs show REVIEW FIELD RECORDS, RETRY and OPERATIONS ARCHIVE under the heading, ahead of the cause and damage lines. | `presentation/debrief_actions.gd` | WP-11 | `debrief_actions.gd: ENABLED` |
| 24 | Expedition pre-dive page: BEGIN OPERATION and RETURN TO MODES are pinned at the bottom of the screen; a refused BEGIN states its reason at the top of the page. | `runs/expedition_session.gd` | WP-11 | none |
| 25 | A grey LOAD button names its reason ("/ NONE ASHORE", "/ CARGO FULL", "/ RACK FULL", "/ SAVE PENDING"), on the Expedition and campaign rack pages. | `presentation/tool_racks_view.gd` | WP-11 | none |
| 26 | Thirteen fitting descriptions gained missing spaces ("by45%" to "by 45%"); one gained a word ("capped22m/s" to "capped at 22m/s"). No number changed. | `equipment/equipment_catalog.gd` | WP-11 | none |
| 27 | Region, route-map position, endurance and opening-arc gating are read from one table. No operation behaves differently (parity suite against values recorded from the base). | `campaign/operation_meta.gd` and five readers | WP-07 | none |

Not behavior changes, listed for completeness: 441 `.gd.uid` files and line-ending normalization (whitespace only, `git diff -w` is empty for those files); the AI trace and sweeper patrol files changed in line endings only.

## 5. Protected capabilities

390 rows in `.fable/PROTECTED_CAPABILITIES.md`: 388 PASS, 1 CHANGED, 1 PAT. 361 rows pass through suites named on the row, all green in full-matrix run 43242777379; the others name their method in the last column.

CHANGED rows:

- **DEV-005** (developer travel shortcuts): kept in debug builds; release builds now refuse them on every profile. Ruling: Pat, 2026-10-30, "they will absolutely have to be stripped for release play" (`docs/USER_DIRECTIVES.md`).

PAT rows:

- **DEV-009** (UI metric records for native layout checks): still printed in debug builds, silent in release builds. Decision D-13.

Rows resolved without a CI suite name the method in the ledger's last column (a CI job, a tool run in this session, direct use during the run, or "unchanged since the base and never automated").

## 6. Evidence

Evidence levels: *implementation* (code read), *scripted verification* (a test suite or tool ran), *automated play* (blind critics driving the real game through the kit), *device observation* (none in this run).

| Gate | Result | Level |
| --- | --- | --- |
| Phase 0 baseline, local | Import OK, core `CHECKS 850 FAILURES 0` on the base | scripted |
| Phase 3 full matrix | Run 43188734403 on `075f627e`: guidance, core, four runtime shards, smoke all green | scripted |
| Phase 4 full matrix | Run 43229665195 on `95cbc1cb`: guidance and core green; seven suites red, all caused by WP-11 (the first life support display took layout space; a briefing line was too long; one typed variable). Fixed in commit `b6a32a16` "fix(hud): show life support on the pause control" | scripted |
| Full matrix on the final code | Run 43242777379 on `247e0582`: guidance, core, four runtime shards and smoke all green | scripted |
| Per package, local | Import, core, the package suites and the three canaries after every merge (figures in `.fable/RUN_LOG.md`) | scripted |
| Reviews | One independent reviewer per package, two for WP-09 (input routing); every finding applied or recorded | implementation |
| Critic 6 | Three blind critics, partial coverage (`.fable/COLD_REVIEW_6.md`) | automated play |
| Debug package | Workflow run 43251208547 on `247e0582`: `sirens-song-debug.apk`, 76,842,695 bytes, SHA-256 `78a8fa947ccee90714174001cb71ed8972fe6316ba8bc312807fb119eb93bdd3`, versionCode 1, signed with the tracked development key (signer certificate SHA-256 `32bcb228...c7dc3c`, signature schemes v2 and v3 verified by the workflow). The emulator smoke job does not run on a manual dispatch, so the package was built and its signature checked, not launched | scripted (build and signature only); no emulator or phone observation |

Not verified by anyone in this run: how the changes look and feel on Pat's phone, audio, performance on Android hardware, and enjoyment.

## 7. Documentation retired

Ten documents moved to `_scrap-20261111/`; each has a row in [`_scrap-20261111/SCRAP_MANIFEST.md`](../_scrap-20261111/SCRAP_MANIFEST.md). Nothing was deleted. Four documents of uncertain staleness stay in place (D-02).

## 8. Branches

Ledger (`.fable/BRANCH_LEDGER.md`): 374 remote branches on 2026-11-11: 5 SHARED, 19 ACTIVE, 24 UNMERGED-UNIQUE, 61 UNMERGED-STALE, 265 MERGED. The archive plan (`.fable/BRANCH_ARCHIVE_PLAN.md`) covers 326 branches: 265 already merged and 61 old unmerged ones. No ref was removed. Commands awaiting Pat's approval (D-14):

```
git fetch --all
gh pr list --state all --limit 1000 --json number,state,headRefName,baseRefName > prs.json
python scripts/repo/branch_ledger.py --prs prs.json > .fable/BRANCH_LEDGER.md
python scripts/repo/archive_branches.py --execute --approved-by-pat
python scripts/repo/archive_branches.py --remove-branches --approved-by-pat
```

The first three lines refresh the ledger (branches change class as they age), the fourth only adds tags `archive/branch/<name>`, the fifth removes a branch only where its tag already exists at the same commit.

## 9. Decisions for Pat

Answer by number and letter. Full text in `.fable/DECISIONS.md`. Recommendation in bold.

| # | Question | Options |
| --- | --- | --- |
| D-01 | Run continued without the command-text guard (git-level hooks worked) | A accept; **B** start future runs with the run clone open as the project |
| D-02 | Four documents of uncertain staleness | **A** scrap the readiness gate and ending copy table, keep the roadmap and the report; B keep all; C scrap all |
| D-03 | Stale lines in the story draft | A you fix them later; **B** dated correction notes quoting your rulings; C remove sweeper patrols |
| D-04 | `codex/handoffs` branch | **A** freeze it as history; B keep it live |
| D-05 | Perpetual Gauntlet or bounded runs | A bounded; B perpetual; **C** both available |
| D-06 | Workflow questions Q3 to Q5 | **A** yes to Q3 only; B yes to all; C leave open |
| D-07 | Guard files travel with the PR | **A** keep; B scrap them before merge; C keep but loosen the push rule |
| D-08 | Photo pay: quality over distance | **A** retune after this run, numbers shown first; B leave; C retune now |
| D-09 | Drone pace and an early purchase | **A** time step and starter tool; B time step; C starter tool; D neither |
| D-10 | Route graph and late variety | Part 1 A, B, C or **D**; part 2 P, Q or **R** |
| D-11 | Drone start positions | **A** start inside recovery reach and astern; B count unmoved drones as recovered; C leave |
| D-12 | TITLE control on the Operations panel | **A** add; B leave |
| D-13 | Diagnostics silent in release builds | **A** keep silent; B print again |
| D-14 | Run the branch archive plan | **A** tags only; B tags then remove the archived branch refs; C not now |
| D-15 | Pull request left as a draft to save a full check run | **A** leave it, you mark it ready or merge; B mark it ready now |

## 10. Deferred and backlog

No P0 or P1 package was deferred: WP-00 to WP-12 all merged. Two critic findings inside WP-11 (launch strike, OUTSIDE RECOVERY) proved to be rules working as built and became D-11 instead of code changes; the Operations panel BACK became D-12.

The P2 backlog is in `.fable/OVERHAUL_PLAN.md` ("P2: backlog"). Its first items: whole-campaign blind critic coverage, the route graph and late variety (after D-10), the photo pay table (after D-08), drone pace (after D-09), buying and fitting screens, and decomposing `main.gd` and `simulation.gd`.

## 11. Testing on the phone, and rolling back

- **Test:** open https://github.com/pemunson90-cmd/Siren-s-Song/actions/runs/43251208547 on the phone (signed in to GitHub), scroll to Artifacts, download `sirens-song-debug-apk`, unzip it and install `sirens-song-debug.apk`. It is signed with the same development key as the 1 November package, so it installs over that one. Saves from an older build may be rejected (your ruling of 2026-11-11 makes that acceptable); start a new campaign if so.
- **Things worth trying first:** frame a photograph near a Siren and watch the shutter ring; lose a drone and read the message; pause, select each craft and plan; open the camera on a subject that needs TIGHT while in WIDE; let oxygen run under 25 percent; lose a dive and look at the debrief; open an Expedition pre-dive page.
- **Roll back:** nothing outside `fable/` was touched, so not merging PR 262 is a full rollback. The base is tagged `fable/pre-overhaul-20261111`. Backups made before the run: `repos/_backups/Siren-s-Song-pre-overhaul-20261111.git` (mirror) and the `.bundle` beside it.
