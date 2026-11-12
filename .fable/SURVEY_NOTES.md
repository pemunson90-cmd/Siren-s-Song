# Survey working notes (root, Phase 1)

Status: LIVE NOTES (working notes for the root session; superseded by SURVEY.md and HANDOFF.md where they overlap)

Working notes that survive context compaction. The finished survey is `.fable/SURVEY.md`. These notes are facts read from the named files on 2026-11-11.

## Session facts

- Local checks: `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\toolchain\win\headless.ps1 -Action Import|Core|Script -Isolate`, with `$env:ARTIFACT_DIR` set to a fresh folder under `%USERPROFILE%\.cache\sirens-song-toolchain\artifacts\`. Core takes about 180 s. Rendered suites cannot run locally (no Xvfb on Windows); they run on GitHub.
- Godot import on Windows dirties the tree: 43 tracked `.import` files change by line ending only, 441 `.gd.uid` files and 3 `.import` files are untracked (359 `.uid` files are tracked). No `.gitattributes`. `core.autocrlf=true` in this clone. Fix belongs in the hygiene package.
- Commits must use the noreply email (set in local config). Redirect git stderr when listing status (CRLF warnings flood output).
- Handoffs branch copies for reading: `%USERPROFILE%\.cache\sirens-song-toolchain\fable-notes\handoffs-*.md`.
- Subagents: custom `implementer` and `reviewer` types are not registered in this session. Use `general-purpose` with the text of `.claude/agents/implementer.md` or `reviewer.md` in the brief.
- Two explorers launched 20:55: code architecture map; documentation inventory (Part A working tree docs, Part B handoffs items and design).

## Governing documents read in full by root

AGENTS.md (61 lines), CLAUDE.md (6), README.md, docs/START_HERE, CONTINUATION, WORKBENCH, RESUME, AGENT_BRIEF, SOURCE_AUTHORITY, GAUNTLET_ORCHESTRATION, architecture/GAUNTLET, USER_DIRECTIVES (285), CURRENT_GAME_SPEC (152), DESKTOP_HANDOFF, TESTING, CODEX_ENVIRONMENT, win/README; handoffs STATE and RULINGS.

Findings:

- CLAUDE.md on the base holds only the feature-continuity directive (duplicated at the top of AGENTS.md). Pat's other clone has a different AGENTS.md on `main` (the "Milestone = a complete playable game" line plus the removal rule of 5 Nov). The run branch follows `claude/integration`.
- Stale banners: README, START_HERE, AGENT_BRIEF, GAUNTLET_ORCHESTRATION, architecture/GAUNTLET carry the 23 Oct "cloud stop" banner. SOURCE_AUTHORITY and CURRENT_GAME_SPEC carry a "Current authority 25 October" banner plus the historical banner. AGENTS.md "Current execution contract" still says Codex continues its queue and names Sol6.1 routing.
- Contradictions on APK: AGENTS.md step 5, CODEX_ENVIRONMENT, architecture/GAUNTLET, GAUNTLET_ORCHESTRATION, spec "Development governance", USER_DIRECTIVES D5 say APK builds are prohibited. RESUME (1 Nov) and RULINGS 2026-11-01 ~16:30 say APK builds are allowed when they help testing, development key only. Newer verbatim ruling wins.
- Contradiction on promotion target: RULINGS 2026-10-31 15:06 makes `main` the only promotion target and freezes `gauntlet/production`. USER_DIRECTIVES 26 Oct says milestone PRs go to `gauntlet/production`. Newer ruling wins.
- Contradiction on review: USER_DIRECTIVES 26 Oct drops per-feature review; 28 Oct restores an independent reviewer before commits and merges ("supersedes earlier entries dropping per-feature review"). 28 Oct stands.
- Contradiction on who builds: USER_DIRECTIVES 28 Oct (later) says Claude launches no subagents; RULINGS 2026-10-31 allows Claude builders (one bounded session per item, two alive at most, no fan-outs). This run's charter sets its own limits.
- Perpetual Gauntlet lines ("The user alone ends the Gauntlet") in AGENTS, README, START_HERE, spec, USER_DIRECTIVES. TARGET.md section 6: keep as Gauntlet policy, add that a chartered run follows its charter stop; record the perpetual versus bounded question for Pat.
- Model routing lines (`gpt-6.1-sol`, Sol6.1 Medium, never Astra) in AGENTS, AGENT_BRIEF, spec, USER_DIRECTIVES, GAUNTLET_ORCHESTRATION. Classify in the migration table.
- Rulings live in two places: USER_DIRECTIVES (through 30 Oct) and handoffs RULINGS (29 Oct to 1 Nov, plus the draft intent card, UNRATIFIED pending Q3). Consolidate verbatim in Phase 3 into one file on the run branch.
- STATE (1 Nov): integration 6182568d, items 126 to 148 and package 2 merged, item 134 route flow parked; Critic 6 planned (reach END OF LINE and each ending family, Glass Reach 5 to 9, Iron Choir, one full Expedition, a Career stretch, Ironman); then photo payoff, late-operation variety and branching route graph, fitting allocation, look and sound comparison. Nightly dispatch fails until `nightly-integration.yml` is on `main`: main is now f5b66a19, check whether the file is there.
- Protected rules named in the rulings: silent sight 180 m, cruise sight 290 m, 4 s interruptible lock warning, beam, collision, damage, hull, sight-only Hunt, never permanently disable a Siren, Disrupt 12 s and 2 charges, film counts (Quietus 8, drone 4), 520 m shutter noise, EMP 340 units and 12 s, decoy 3 charges and 15 s and 160 m placement, torpedo as a physical projectile.
- Spec scope: 28 core (29 kept by ruling) plus 12 optional operations, six arcs and regions, three hulls, four drone chassis, 18 plus 6 modules, eight tools, eight Siren roles, three depth bands, eight artifacts, 12 challenges, Expedition (3 to 6 operations, seeded), Career, presets ACCESSIBLE, STANDARD, SURVIVAL plus Ironman, three profiles with copy, clear, export, import, three manual snapshots and four fork states per profile.

## Hazards learned

- Never `cd` outside the run clone in the Bash tool: the shell then resets to Pat's other clone (`repos\Siren-s-Song`), which the run must never touch. Use absolute paths or a subshell, and start risky commands with `cd` into the run clone.
- The toolchain cache `%USERPROFILE%\.cache\sirens-song-toolchain` is shared with Pat's earlier agents and holds their evidence. Read it; write only into new folders named `fable-*` or `critic6-fable-*`.

## Critic kit (external, not in the repository)

- Kit v3 transport: `artifacts\critic6-cabd-20261105\prep6-cabd\` (`driver.gd` 8297 bytes, `drive.ps1`, `launch.ps1`, `send.ps1`, `rootprep\geometry\size-owned-window.ps1`), briefs in `brief\`. Commands: geometry, screenshot, click, drag, wait, labels, key, quit. No pinch, hold or multitouch.
- Desktop is 1280x720, so a launched window clamps to 1284x701 until `size-owned-window.ps1` resizes the GUI child (GEOMETRY_HANDOFF.txt has the exact steps). Cover is 2520x1080, inner 2184x1968.
- An earlier Critic 6 on this base (cabd5bd5) ran 5 to 8 Nov under another agent: 98 segments, reached only Shelf Signal recovered and Split Channel incomplete in fresh play, plus staged probes (Glass Fence, Needle Strait, Confluence, Shelf, one Expedition). Its ledgers: `prep6-cabd\audit\main\COVERAGE.tsv` and `FINDINGS.tsv` (findings U01 extraction drone-consequence warning, U02 required versus optional contact confusion, D01 pause state at detection tutorial). Top-level reports in `critic6-cabd-20261105\*.md`. The coverage contract in STATE.md was not met. Throughput of screenshot-driven play is the limit.
- Tool tests not run by CI: `test-gauntlet-boundary.py`, `test-test-sh-failures.py`, `test-configure-signing.py`, ten `test-android-*.py`, two `.sh`, two `.gd`.

## Documentation inventory done

`.fable/DOC_INVENTORY.md` written. Explorer report kept at `fable-notes\explorer-doc-inventory.md` (878 lines: per-file stale lines, rules, rulings, inbound links; cold review tables). Decisions D-02 to D-06 added.

Design choices for Phase 3: rulings home stays `docs/USER_DIRECTIVES.md` (append handoffs RULINGS.md verbatim); new `docs/STATUS.md`, `docs/WORKFLOW.md`, `docs/GOVERNANCE_MIGRATION.md`; scrap START_HERE, RESUME, CONTINUATION, WORKBENCH, AGENT_BRIEF, GAUNTLET_ORCHESTRATION, CODEX_ENVIRONMENT, CRITIC_BRIEF, DESKTOP_HANDOFF, PAUSE_CHECKPOINT and the old AGENTS.md text. `check-gauntlet-guidance.py` FILES and `gauntlet-boundary.py` FILES (line 7) and its dispatch prefix (line 121, names Sol6.1) must change in the same commit; `test-gauntlet-boundary.py` and `install-gauntlet-hooks.py` reference them.

Plan seeds from the cold reviews (handoffs): COLD_REVIEW_5 rank 9 (ARRIVALS opens instructions, not received content) has no later item: open. Rank 11 (machinery and site roles rely on text, weak compositions): open, art is Pat's. PLAN_DRAFT_1 package 6 (look and sound, read-only comparison) and package 7 (late-operation variety) open. FLEET_MATTERS (28 Oct): 29 of 41 operations classed WAYPOINT, 4 EARNED; tools with no demonstrated decisive use: Decoy, RECON, Torpedo, Sonobuoy, Silt screen, Hull patch, Relay buoy, flash; no fitting individually proven decisive; later fixes 094 to 097 and 139 raised pressure on some operations. COLD_REVIEW_4 F9 (newest record needs 44 NEXT presses), F15 (challenge pars ignore photo quality) not retested. STATE order after Critic 6: photo payoff; late-operation variety and branching route graph; fitting allocation; look and sound comparison.

## Root's intended plan (sketch, 2026-11-11 21:20; the binding version will be `.fable/OVERHAUL_PLAN.md`)

P0, all land in this run:
- WP-00 Critic kit versioned under `scripts/critic/` (done, commit aa77916c; needs a reviewer pass before the Phase 3 gate).
- WP-01 Protected capabilities ledger (`.fable/PROTECTED_CAPABILITIES.md`, drafter running).
- WP-02 Governance consolidation: new `AGENTS.md`, `CLAUDE.md` (`@AGENTS.md`), `README.md`, `docs/STATUS.md`, `docs/WORKFLOW.md`, `docs/GOVERNANCE_MIGRATION.md`; append handoffs RULINGS verbatim to `docs/USER_DIRECTIVES.md`; fix stale lines in the LIVE, fix documents; scrap moves with `_scrap-20261111/SCRAP_MANIFEST.md`; update `check-gauntlet-guidance.py`, its test, `gauntlet-boundary.py` FILES and dispatch prefix, `test-gauntlet-boundary.py`. Root does this itself (shared files).
- WP-03 Repository hygiene: `.gitattributes`, track the 441 `.gd.uid` and 3 `.import` files, `.gitignore` additions, `CHANGELOG.md`, PR template, refresh `docs/REPOSITORY_MAP.md`, a docs link checker in `scripts/repo/` wired into the `guidance` job.
- WP-04 CI necessity: run the Python tool self-tests in CI; keep the matrix as it is unless a safe narrowing is proven.
- WP-05 Progress-loss defect S-01: reproduce with a test, then fix (`main.gd`, `save_store.gd`, `frontend.gd`). High risk: second reviewer.

P1 candidates (rank after the critics report): release hygiene S-02, S-03, S-04; data-driven operation tables (hunt caps, endurance, region and route position keyed by registry rows instead of ID arrays) plus guides for adding an operation, a Siren role, a fitting and a region, and MODULES.md rows for items 126 to 148; photo payoff; ARRIVALS shows received content; duplicated constants S-06 and dead guards S-05; critic findings.

P2 backlog: look and sound comparison, shared test assertion helper, god-object decomposition, settings stored twice, select-suites narrowing, nightly on main.

## Pat ruling 2026-11-11 21:16:48: saves are minor priority

Verbatim: "Save files are minor priority because the game isnt even finished yet so saves absolutely will not be able to be carried forward if there is a major refactor or a change in the flow of the game." Plan changes: WP-05 (S-01) leaves P0 and goes to the P2 backlog. Refactors may break compatibility with existing saves as long as incompatible saves are rejected cleanly and save, restore, profiles, export and import keep working on new saves. Record this ruling in `docs/USER_DIRECTIVES.md` in Phase 3 (append, verbatim, dated 2026-11-11).

## Line endings (for WP-03)

`git ls-files --eol`: 1,334 files are LF in the index and CRLF in the working copy (this clone has `core.autocrlf=true`), 10 files are CRLF in the index (`game/src/campaign/sweeper_patrols.gd` and nine test files), 2 are mixed (`game/src/diagnostics/ai_trace.gd`, `ai_trace_table.gd`). Plan: `.gitattributes` with `* text=auto eol=lf`, binaries marked, and `reference/**`, `references/**` and `game/tests/fixtures/**` set `-text` so provenance bytes and fixtures never convert; one normalization commit for the 12 files.
