# Historical lane ledger (21 October 2026)

This table preserves old assignments and is not a live claim list. Current ownership is on docs/codex/BOARD.md at codex/handoffs; current execution is in [RESUME](RESUME.md). Pat requested the cloud stop and Windows handover in [DESKTOP_HANDOFF](DESKTOP_HANDOFF.md). Claude orchestrates; Codex may merge only under its handoff/delegation. Only Pat promotes to frozen production/main. No APKs. The historical lane text below does not restart workers or override these rules.

## Original coordination snapshot

Root: Claude. Integration branch `claude/integration` (from production `ca4735e`). Lanes branch from it as
`claude/lane-<id>-<slug>` and return by PR into it. Only root merges. Promotion to `gauntlet/production` needs Pat.
Rules: bounded briefs, green CI before merge, no automatic APKs, authored text has no em dashes and shows rather than explains.
Story: survivors are humans from drilling/oil-rig sites and military installations struck by threat-reactive Sirens. Pat approves
characters, site sequence and endings before any rewrite lands.

| Lane | Owner | Branch | Status | Owns (may edit) |
|---|---|---|---|---|
| S1 narrative inventory | Claude agent | claude/lane-s1-inventory | open | new `docs/STORY_INVENTORY.md` only |
| S2 story bible draft | Claude agent | claude/lane-s2-bible | open, Pat approval gate | new `docs/STORY_BIBLE_DRAFT.md` only |
| S3 rewrite + number spacing | Claude agent | claude/lane-s3-rewrite | blocked on S2 approval | `campaign/endings.gd`, text constants in `campaign/*_operations.gd`, `*_missions.gd`, briefing and record strings |
| P progression foundation | Claude agent | claude/lane-p-progression | open | `equipment/*`, `campaign/glass_research.gd`, `campaign/fleet_inventory.gd`, fitting and briefing UI, save schema for these fields |
| C content, de-template | Claude agent | claude/lane-c-content | open (geometry and objectives only; text waits for S3) | `campaign/glass_reach_operations.gd`, `campaign/iron_choir_operations.gd`, `simulation/glass_reach_work.gd`, `simulation/industrial_jobs.gd`, new encounter modules |
| T pressure and tuning | Codex | claude/lane-t-pressure | running (X2, X4 landed) | threat sections of `simulation/simulation.gd`, `simulation/industrial_threats.gd`, `simulation/sweeper_senses.gd` |
| X1 review | Codex | per PR | on request | read only |
| X2 pressure probes | Codex | claude/lane-x2-probes | merged | new test files only |
| X3 audio | Codex | claude/lane-x3-audio | merged | `audio/*`, new audio assets |
| X4 endpoint seam | Codex | claude/lane-x4-seam | merged | files that show the ordinary-beam / industrial-load bug |

Overlap notes: C places rosters, T edits threat logic. P and C both touch briefing data, so P owns schema and C owns operation tables.
Later (delivery order): challenges, roguelite (rename code "expedition" first), naval career, frontend, settings and accessibility, art.

## Update 21 Oct (Pat away; Claude runs all lanes, Codex lanes done by Claude agents)
Running: C1 glass, P1 fittings, S3 rewrite, X4 seam, X2 probes, X3 audio, A1 art, F1 frontend. Next: C2 Iron Choir, S3b glass/iron text, T pressure, P2 economy.
Open questions for Pat: docs/QUESTIONS_FOR_PAT.md

Codex work queue: branch codex/handoffs, folder docs/codex/ (README is the protocol). Lane T merged (PR 58).
