# Handoff 126: TRUTHFUL COMMANDS (PLAN_DRAFT_1 package 1)

Status: QUEUED (claude-lane, Pat 30 Oct)

Precondition: none of the files below claimed by another BOARD row; root's package 2 (stable board, threat stack, 150%) owns layout, hit-testing and chart camera; this item owns wording, action availability reasons and route target selection only. Check `git worktree list`; merge latest claude/integration before opening the PR.
Codex may merge: yes, into claude/integration only, after independent Sol6.1-high approval, Claude's `CLAUDE INTENT: PASS` comment and green required checks on the exact head, merge commit.
Source: `docs/codex/PLAN_DRAFT_1.md` package 1; evidence `artifacts/evidence-base/ADDENDUM_LATE_VERDICTS.md` (C44, C14/C18/C23, C03, C53). Ruling (Pat, 2026-10-30 chat, after Claude asked to unfreeze packages 0-2 with recommendation yes): "Good keep working".

## Task
1. **Real exit names.** `mission_hud.gd:111` hard-codes `WITHDRAW\nAT SOUTH`. Name the actual recovery mouth(s) from `sim.extraction_corridors()` / mission corridors (e.g. NORTH REACH RECOVERY, EAST COLLAR). Same for any other fixed direction text in withdraw/recovery buttons.
2. **Legal work approach points.** ROUTE HERE (`mission_hud.gd:244`), glass_route (`:214`) and choir_route (`:208`) route to the object's own centre, which fails with "Rock or unsafe clearance" (`route_orders.gd:22`) when the object sits on rock (critic G2 Silt spindle, S3 Furnace). Route instead to the nearest legal open-water point within the job's work range on the craft's current or required band, using only geometry the player has measured. If none is known, say so and name what is needed (survey, band, approach side) rather than offering a command that cannot succeed.
3. **Job-specific verbs.** Valve/machinery work must not read CAMERA/PHOTO; a hydrophone decode must not read CAMERA READY; machinery must not read STARTED when it has not (`work_task.gd:83-95`). ARRIVALS must not be overwritten by generic status (`mission_hud.gd:495/505`).
4. **A reason on every grey action.** Every disabled local action (work, lock, voyage, recover material, photo, tools, depth change) names the first unmet requirement it knows: range (with distance), band, settling, heading/camera bearing, prerequisite step, zero stock on this craft. Unknown objects stay unknown.
5. **Per-craft tool counts.** The brief and each craft's tool menu show that craft's own stock (zero included); fleet or run totals are secondary. A drone never shows Quietus's torpedo count as its own (`main.gd:387-388`).

## Protected (do not change)
Which actions exist and what they do, work ranges and durations, beam, 4 s lock, collision/hull/damage, Siren and role senses, PR70 sweeper, photography exposure and grading, ending conditions, art direction. No new geometry revealed.

## Bar
- Full SILENT bare voyages of op 2 plus Needle Strait, Furnace Drift, Silt Archive, Prism Grave, Hammerwake and Final Survey 1 (STANDARD and ACCESSIBLE): identical physics before/after (time, Hunt, locks, hull, oxygen) except where a route now succeeds that previously failed; show those cases.
- Table: every withdraw/recovery button per op, old text versus new; every work site in those ops, old route target versus new target and whether it is legal water.
- Table: each disabled-action case, old text versus new reason.
- Native screenshots at 100% and 150% of a grey action with its reason, a work route on a rock-sited object, and a drone tool menu.
- Evidence cap: tables plus screenshots, no prose essays.

## Files you may edit
Mission HUD wording and action availability, work task text, route target selection for work/route-here orders, brief tool listing, their tests, docs, shared registration lines. Not layout, hit-testing or chart camera (root package 2).

## Checks
Import + Core, orders/navigation, presentation/HUD, expedition instruments, campaign suites; full local checks before the PR.

## Return
PR into claude/integration with the tables above; independent review; wait for CLAUDE INTENT: PASS; merge on green; close the BOARD row and add one LEDGER line.
