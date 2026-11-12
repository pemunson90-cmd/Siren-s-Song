# Overhaul plan: overhaul-20261111

Status: LIVE PLAN (2026-11-12, Phase 2; P0 and P1 lists fixed; changes are logged at the end)

Base `claude/integration` at `cabd5bd5`, run branch `fable/overhaul-20261111`. Evidence comes from `.fable/SURVEY.md` (defect IDs S-NN), `.fable/COLD_REVIEW_6.md` (G, I and B IDs), `.fable/CI_INVENTORY.md`, `.fable/DOC_INVENTORY.md` and `.fable/PROTECTED_CAPABILITIES.md` (row IDs).

Rules that bind every package: no working capability is removed or reduced; protected game rules (Siren senses, sight, lock, beam, collision, damage, hull, Hunt, photo exposure and grading, never permanently disabling a Siren) do not change; no narrative text is written; existing saves need not carry across a refactor but incompatible saves must be rejected cleanly (Pat, 2026-11-11). Every behavior change is reported.

Local acceptance for every game package: import and core through `scripts/toolchain/win/headless.ps1`, the affected non-render suites, the three canaries (`protected_rules_tests`, `control_mix_tests`, `crash_possible_tests`) and `python scripts/toolchain/check-suites.py`. Render suites run on GitHub at the phase gates.

## P0: all land in this run

| ID | Title | Gain | Evidence | Owned paths | Depends on | Acceptance | Risk | Ledger rows |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| WP-00 | Critic kit, versioned | Maintainer: a reliable blind-critic kit in the repository | S-13; October parse stalls | `scripts/critic/` | none | Reviewer verdict; `kit.py --help`; driver syntax check | High (critic driver): reviewed | MAINT-019 |
| WP-01 | Protected capabilities ledger | Maintainer: a regression ledger for the run | Charter Phase 1 | `.fable/PROTECTED_CAPABILITIES.md`, `scripts/repo/ledger_check.py` | none | `ledger_check.py` PASS | Low | all |
| WP-02 | Governance consolidation | Every agent reads one governing file, one status file and one rulings file; stale pointer documents are in scrap | S-10, S-11; DOC_INVENTORY contradictions 1 to 13 | `AGENTS.md`, `CLAUDE.md`, `README.md`, `docs/STATUS.md`, `docs/WORKFLOW.md`, `docs/GOVERNANCE_MIGRATION.md`, `docs/USER_DIRECTIVES.md` (append only), `docs/TESTING.md`, the "LIVE, fix" documents, `_scrap-20261111/`, `scripts/toolchain/check-gauntlet-guidance.py` and its test, `scripts/toolchain/gauntlet-boundary.py` and its test | none | Guidance checker and its test pass; boundary test passes; docs link check clean; migration table covers every rule of the old governing files | Medium: root does it; reviewed | MAINT rows for the guidance tools |
| WP-03 | Repository hygiene | A clone and a Godot import leave a clean tree on Windows and Linux; the repository has a changelog, a PR template and a link checker | S-09; charter 5.6 | `.gitattributes`, `.gitignore`, `CHANGELOG.md`, `.github/pull_request_template.md`, `scripts/repo/check_doc_links.py`, `scripts/repo/archive_branches.py`, `docs/REPOSITORY_MAP.md`, the 441 `.gd.uid` and 3 `.import` files | WP-02 | After a Windows import `git status` is clean; link check clean; `archive_branches.py --dry-run` changes nothing | Low | MAINT-023 |
| WP-04 | CI necessity gating | The fast `guidance` job also checks links and runs the tool self-tests that no workflow ran; nothing redundant is added | S-12; CI_INVENTORY gaps 3 and 8 | `.github/workflows/gauntlet-pr-checks.yml` | WP-02, WP-03 | The `guidance` job passes on the run branch; full matrix unchanged | High (CI workflow): second look by the reviewer | MAINT rows for CI |
| WP-05 | Harness reliability | A refactor cannot silently change a protected number or make a Siren permanently disabled; the golden names rules that live in this repository | Ledger gaps 7 and 8; S-08 | `game/tests/protected_rules_tests.gd`, `game/tests/fixtures/protected_golden.json`, one new suite `game/tests/never_disabled_tests.gd`, `game/tests/suites.txt` (two rows, applied by root) | WP-02 | The golden fails when any newly pinned number is edited (shown once, then reverted) and passes on the base values; new suite passes | Medium | SIREN-*, TOOL-* |

## P1: land or defer with a recorded reason

| ID | Title | Gain | Evidence | Owned paths | Depends on | Acceptance | Risk | Ledger rows |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| WP-06 | Release hygiene | A release build cannot reach developer travel shortcuts through an imported profile, ships no test scripts and prints no diagnostics | S-02, S-03, S-04; Pat 30 Oct "stripped for release play" | `game/src/debug/dev_state.gd`, `game/export_presets.cfg`, the `print("SS_...")` sites, one new suite | WP-05 | New suite proves the gate by build type; debug behavior unchanged; export filter excludes `tests/` | Medium | DEV-*, MOVE-0xx travel rows, ANDR-* |
| WP-07 | Data-driven operation and region definitions, with guides | Maintainer: adding an operation or a region touches a registry row and its factory, not ID arrays in five files. Four short guides say how to add an operation, a region, a Siren role and a fitting. | SURVEY section 4 (57 literal ID comparisons; `hunt_table.CAPS`, `region_table` ranges, `route_graph_table.POSITIONS`); the specification's "reusable definitions" | `game/src/campaign/operation_catalog.gd` and a new `game/src/campaign/operation_meta.gd`, `game/src/simulation/hunt_pressure/hunt_table.gd`, `game/src/campaign/endurance_budgets.gd`, `game/src/presentation/art/region_table.gd`, `game/src/audio/region_audio_table.gd`, `game/src/presentation/route_map/`, a new parity suite, `docs/guides/`, `docs/MODULES.md` | WP-05 | A parity suite proves every operation 0 to 41 resolves to the same hunt cap, endurance, region key, audio bed and route position as the base tables; core and canaries pass | High (determinism): parity suite plus reviewer | CAMP-000 to CAMP-041, MODE-* |
| WP-08 | Readable detection and loss | Player: sees the shutter-noise radius while framing, sees the lock countdown beside the craft, is told what destroyed a drone and from which bearing, and can choose to pause when a craft is lost | Cold review 6 G1 | New module under `game/src/presentation/threat_read/`, a narrow seam in `game/src/presentation/ocean_view.gd`, `game/src/presentation/accessibility/tactical_aids.gd` (one new aid, off by default), settings row, new suites | WP-05 | New non-render suite for the loss line and the aid; protected golden unchanged; render suite on GitHub | Medium: presentation only, no rule change | SIREN-*, SET-*, PHOTO-* |
| WP-09 | Planning camera and truthful order flow | Player: a tap lands where it was aimed; RESUME always resumes; the order dialog names real controls; a confirm dialog does not burn oxygen | Cold review 6 I1, I3, I4 | `game/src/main.gd` input and camera follow sites, `game/src/input/`, `game/src/presentation/route_program/` and the order-confirm dialog, new suites | WP-08 (shared files, sequential) | New suites: selection while paused leaves the camera still; RESUME with a ring open resumes; dialog text matches controls; simulation time does not advance while a confirm dialog is open | High (input routing): second reviewer | MOVE-*, MENU-* |
| WP-10 | Photograph flow | Player: a shutter control in the camera panel; told before the exposure when a frame cannot be used; one range figure; the debrief and archive show what each photograph paid | Cold review 6 G3, G4, I5 | `game/src/presentation/photo*/` panel files, `game/src/photo_rules/` (read only for values), debrief and archive presentation files, new suites | WP-09 (shared HUD files, sequential) | New suites for the shutter control, the pre-exposure refusal and the pay line; exposure and grading numbers unchanged (golden) | Medium | PHOTO-* |
| WP-11 | Dive HUD and panel defects | Player: threat chips stay in place and inside the screen; life support is always visible in a dive; primary buttons are never below the fold; spacing typos fixed; drones no longer collide at launch or read "outside recovery" when they never left | Cold review 6 I2, I6, I8, G6, B1, B2 | `game/src/presentation/mission_hud.gd` and HUD modules, result screen, launch layout, fittings and supplies text tables | WP-10 (shared HUD files, sequential) | Suites for chip anchoring within the safe area on cover and inner sizes, life-support visibility, and the two bugs reproduced then fixed | Medium | MENU-*, MOVE-*, SET-* |
| WP-12 | Structural proposal for Pat | Pat gets one document with options for the route graph, late-operation variety and the difficulty cliff, to rule on by letter. No narrative text. | Cold review 6 G2, G5; the 1 Nov plan; TARGET section 4 | `docs/proposals/2026-11-ROUTE_AND_VARIETY_OPTIONS.md` | WP-07 | Document exists, tagged AI-designed, with a decision entry | Low | none |

Order: WP-02, WP-03, WP-04 (root, Phase 3). Then WP-05, WP-06 and WP-07 in parallel (disjoint paths). Then WP-08, WP-09, WP-10, WP-11 one after another, because they share the HUD and input files. WP-12 by root alongside.

## P2: backlog, not started in this run

| Item | Detail for a later run | Evidence |
| --- | --- | --- |
| Whole-campaign blind critic coverage | Stage earned profiles per region (Glass Reach, Iron Choir, Calder Trench, final pair) and run one critic per region to END OF LINE and each ending family; also one full Expedition, a Career stretch, Challenges and Ironman | Cold review 6 coverage |
| Late-operation variety and the branching route graph | Build what Pat selects from WP-12 | G5; 1 Nov plan |
| Photo pay table | Retune so quality outweighs distance and tools, once Pat rules | G3; cold review 4 F15 |
| Drone pace and early purchases | A time step while no Siren is aware; an affordable first purchase | G2; decision for Pat |
| Buying and fitting screens | Stats and conflicts before purchase, confirmation, balance near buttons | I7; cold review 5 rank 10 |
| ARRIVALS shows received content | Open the received record, not instructions | Cold review 5 rank 9 |
| Opening view of a dive | Fit that shows the first objective, or a pinch hint | I9 |
| Route map defects | Node 13 fill, minimum zoom, optional nodes off screen | B4 |
| Bearing readout, depth-band hiding, early Sorley archive line | Verify each against intent first | B3, B5, B6 |
| Progress loss with an unreadable save | Reproduce with a test, then fix | S-01 (Pat: minor priority) |
| Code consolidation | Duplicate tool stock and order lists, dead null guards, settings stored twice | S-05, S-06, S-07 |
| Decompose `main.gd` and `simulation.gd` | Move the tick out of the accessibility module; split input routing, save and lifecycle | SURVEY sections 1 and 2 |
| Shared test assertion helper | 301 files define their own `check` | SURVEY section 5 |
| Role literals | Siren role names appear in 30 non-test files; a role registry would cut the cost of a new role | SURVEY section 4 |
| Narrower affected-suite selection | Safe narrowing of the serial-zone fallback | CI_INVENTORY gap 2 |
| Nightly on `main` | Starts at the next promotion (Pat) | CI_INVENTORY gap 1 |
| Journeys for operations 37 and 40; non-render split of tactical-aid and developer-taint logic; suite times for 24 suites | Ledger "Gaps noticed" | Ledger |
| Look and sound comparison | Read-only comparison against the reference games; art direction is Pat's | 1 Nov plan package 6 |

## Change log

- 2026-11-12: plan written. Compared with the 11 Nov sketch: the progress-loss defect S-01 moved to P2 (Pat's ruling of 2026-11-11); P1 was reseeded from cold review 6, which ranks readable detection and the planning camera above photo payoff for a new player; ARRIVALS, fitting screens and code consolidation moved to P2 to keep P1 finishable.
