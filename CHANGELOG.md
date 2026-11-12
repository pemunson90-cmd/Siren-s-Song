# Changelog

One entry per run or milestone, newest first. Day-to-day history is in git. Current status is in [docs/STATUS.md](docs/STATUS.md).

## Unreleased: overhaul run `overhaul-20261111` (branch `fable/overhaul-20261111`)

Base: `claude/integration` at `cabd5bd5`. The complete account, including every behavior change, is `.fable/FINAL_REPORT.md` when the run closes.

### Governance and documents

- `AGENTS.md` is the single governing file. `CLAUDE.md` imports it. `docs/STATUS.md` is the one status file. `docs/WORKFLOW.md` holds the branch model, commit format, review and merge rules and CI gating.
- Pat's rulings from `codex/handoffs` (29 October to 1 November) and from this run are copied verbatim into `docs/USER_DIRECTIVES.md`.
- Ten pointer and handoff documents moved to `_scrap-20261111/` with a manifest. `docs/GOVERNANCE_MIGRATION.md` accounts for every rule of the old governing files.
- Stale statements corrected in place: the lifted stop banners, the superseded APK prohibition, the WSL-only instructions, dead links.

### Repository hygiene

- `.gitattributes` stores text with LF on every platform and keeps provenance files and fixtures byte for byte. Twelve scripts with CRLF or mixed endings were normalized (whitespace only).
- The 441 Godot `.gd.uid` files and three title `.import` files that an import generated are now tracked, so an import leaves a clean tree and script identifiers are the same on every machine.
- Added a pull request template, a documentation link check and a branch archive planner (`scripts/repo/archive_branches.py`, dry run by default; it changes nothing without the owner's flag).

### CI

- The fast `guidance` job also checks documentation links and runs the tool self-tests that no workflow ran before; two helper tests that need Godot run in `game-core`. Nothing redundant was added and the matrix is unchanged.

### Tests

- The protected-rules golden pins 23 more protected numbers (Disrupt, torpedo, decoy, the Hunt table, radio reports, survivor ascent, passive reach, silt screen). A new suite states as one rule that no player tool permanently disables a Siren, for all eight roles. New suites also cover the release build gate and operation metadata parity.

### Tools

- `scripts/critic/`: the blind critic play kit, versioned and reviewed.
- `scripts/repo/`: branch ledger, documentation link check, capabilities ledger check, run-state helpers.
- The guidance checker audits the new document structure; the boundary helper reads the new file list and still reads the old one from commits that predate the consolidation.

### Game

- Release builds refuse the six developer-only travel shortcuts on every profile, including an imported developer-marked one. Debug builds are unchanged. The developer mark and its exclusion from records are unchanged.
- Exported packages no longer contain the test scripts.
- The internal `SS_` diagnostic lines print only in debug builds.
- Per-operation metadata (region, route-map position, endurance, opening-arc gating) lives in one table, `game/src/campaign/operation_meta.gd`. No operation behaves differently; a parity suite proves it against values recorded from the base. `docs/guides/` explains how to add an operation, a region, a Siren role and a fitting.
- While a photograph is framed, the chart draws the shutter-noise reach with its distance, using the same figure the camera panel prints. Every craft under a Siren lock shows a countdown chip beside it. A lost drone reports its cause and bearing ("UNSEEN SIREN" when the player held no contact). A new setting, off by default, pauses the dive when a craft is lost.
- Selecting a craft while the dive is paused no longer moves the camera; on resume the view follows the selected craft again unless the player panned or zoomed. RESUME closes an open command ring or a pending route marker and resumes in one press. The route confirm dialog names its real buttons, shows the craft's live orders, and holds dive time while it is open. The pause control grows to fit its label, which fixes taps on RESUME being ignored.
- The camera panel has a SHUTTER control. A WIDE frame of a subject that needs fine detail gives a warning before any film is spent; pressing again within four seconds exposes anyway. The ring caption shows one camera reach figure and no longer shows the distance to an unresolved lead's hidden position. The debrief and the archive show what each photograph added (intel, camera research, later chart marks). No photo rule or number changed.
- Quietus life support is on screen whenever a dive is running: the pause control's second line shows oxygen and an estimated time left at the base drain rate, amber at 25 percent or below. The control keeps its size and nothing else moves. From operation 1 on, the briefing states the operation's life-support time (operation 0 keeps its short opening briefing).
- Threat, notice and new-Siren-type chips stay inside the screen and grow to fit their text; the Hunt chip keeps its seat while the layout is unchanged; the Expedition banner sits under the header; the ring's centre title wraps to two lines.
- Loss and withdrawal debriefs show REVIEW FIELD RECORDS, RETRY and OPERATIONS ARCHIVE directly under the heading. The Expedition pre-dive page pins BEGIN OPERATION and RETURN TO MODES at the bottom of the screen. A grey LOAD button names its reason.
- Thirteen fitting descriptions gained the missing spaces between words and numbers. No number changed.
- **Drones launch from Quietus (restored from the v7 prototype, Pat's ruling of 2026-11-12).** Every dive starts with both drones aboard: they are not on the chart and nothing can see, hear or strike them. Choose a drone under FLEET and tap water: it enters the water beside Quietus and swims the route. Other orders to an aboard drone are refused with the reason. A drone never launched comes home with Quietus and is never counted lost. No launch noise, two drones and no spares, recovery of a launched drone unchanged (Pat's rulings for this first version). Dives saved before this keep their drones in the water.
- The Operations panel has a TITLE control at its top.

### After the first closeout (2026-11-12)

- Pull requests run the bare minimum on GitHub: core, at most twelve suites that directly test the change, and the three canaries. The full matrix (46 minutes, about 150 runner-minutes) runs only by manual dispatch, for a release or near-release package.
- `docs/V7_TO_GODOT_PARITY.md` records an audit of the prototype against the game: eleven differences that had no recorded rationale. One (drone launch) is restored; ten wait on Pat.
- Pat's answers to decisions D-01 to D-15 are applied: two documents moved to scrap, correction notes in the story draft, `codex/handoffs` frozen, the specification's movement clause updated, archive tags for old branches.
- **Recon is discovery again (Pat's rulings of 2026-11-12 on the prototype audit).** On a player dive after the three tutorial operations: the chart starts as a small window around the launch point and is earned by the craft's sensors; a survey sweep shows water and objectives for 30 seconds and they lapse unless a craft maps them; each objective is a search area until a craft's passive sensing or sonar finds it; Disrupt is refused, charge kept, when no Siren is in range; a craft within 340 m of a factory (operations 3 and 11) raises Hunt, and the Hunt meter names the cause. A developer console command, `known`, shows charts and objectives from the start. Dives saved earlier keep the rules they started with.
- Quietus's sonar pulse costs no life support (drones still pay battery). The tool formerly labelled DISRUPT is named EMP everywhere the player reads it; it is an area pulse and needs no target.
- The DISRUPTION loadout is named EMP wherever the player reads it (Pat, 2026-11-12): the loadout cycle button, the supply comparison, the FILL button on the tool racks, the next-dive line, Challenges, Expedition and seed entry. The loadout id `disruption` in code and saves is unchanged. One helper, `FieldTools.loadout_label`, supplies the name. Three test files that still expected DISRUPT, three craft in the water or EMP as an internal id were brought up to the rules Pat ruled on.
- Drones are scouts again: a calm Siren ignores a drone in its sight (the prototype's rule); once that Siren is investigating, searching or locking, or Hunt reaches SEARCHING, drones are targets. Drone movement noise reaches 60 percent as far.
- The chart draws an estimated sight range around a detected, identified Siren once its type has been photographed (the SENSOR ARRAY feature of a Siren photograph, kept in the campaign's photo intel).

