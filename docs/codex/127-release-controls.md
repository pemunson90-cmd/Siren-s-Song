# Handoff 127: RELEASE CONTROLS (pilot by hand; travel shortcuts are test-only)

Status: QUEUED (claude-lane, Pat 30 Oct)

Precondition: 126 merged (same chain). Root package 2 (ROOT-PKG2) owns HUD layout, hit-testing and chart camera; this item owns which controls exist on each wheel page and the new orders. Merge latest claude/integration before the PR. Check `git worktree list`.
Codex may merge: yes, into claude/integration only, after independent Sol6.1-high approval, Claude's `CLAUDE INTENT: PASS` comment and green required checks on the exact head, merge commit.
Source: Pat, 2026-10-30 chat. "I honestly just don't like the controls. It basically means you can complete almost every mission while half of your maneuvering is just clicking a button and watching autopilot. That defeats the whole purpose of the entire waypoint mode and the pause planning selection stuff. There should be controls for depth, interacting with nearby interactable objects, movement controls and recover drones." Then, on stripping one-press travel shortcuts: "They are fine for testing but they will absolutely have to be stripped for release play".

## Task
1. **Test-only travel shortcuts.** Every one-press "go there" order (ROUTE TO REACH WORK / LOCAL WORK, ROUTE HERE, glass/choir route, recovery-chooser and WITHDRAW/HOME autopilot, object-tap auto-route) is available only when the existing dev/test state is on (`src/debug/dev_state.gd`; reuse it, do not invent a second flag). Release play (dev off, the default and every shipped build) never shows them. Tests and measurement harnesses may turn dev on explicitly.
2. **Move by plan, with risk and a light assist.** In release play the player moves craft by placing waypoints (existing waypoint mode, queue, hold, program), not by one-press destinations. A tapped destination installs a straight leg (or the player's own legs); the game does not solve a path around terrain for the player. Pat (2026-10-30): "You should still be able to crash. But there should be moderate autopilot for edges and stuff so you're not just getting stuck grinding on things if you fuck up. It still got to be a game like there still has to be some challenge and risk to it." So:
   - A leg that crosses measured rock is allowed but drawn as a warning (red segment, short reason); the player can still plot into danger. Unknown terrain stays unknown.
   - Collisions keep their existing damage and hull rules exactly (protected). Crashing must remain possible and costly.
   - Edge assist: when a craft touches or is about to graze a wall, it deflects and slides along the edge toward its leg end at reduced speed, the way a character slides along a wall in an action game, and stops (holds, with a reason) if sliding makes no progress, instead of grinding into the same wall. It never plans around an obstacle or finds a gap for you. The first impact still costs hull per the existing rules; the assist prevents repeated grinding damage, not the crash.
   - Show the numbers: per op, collisions, hull lost and stuck-holds for the hand-piloting harness, and one deliberate crash case per shape proving damage still happens.
3. **Job page = what is in reach here.** The per-operation work page lists the jobs the selected craft can do from where it is now (with 126's grey reasons for the ones it cannot), plus a depth up/down pair. No travel buttons on it in release play.
4. **Recall drone.** A new order on a drone's wheel: RECALL returns that drone to Quietus by its own planned legs (straight legs back along its own route history or toward Quietus; refused with a reason if blocked), and a recalled drone inside Quietus's recovery reach counts as recovered when the dive ends. Quietus also gets RECALL ALL. Noise and speed follow the drone's current mode; no free safety.
5. **Brief and help text** say how to move (plan legs while paused), change depth, work and recall, in 1-2 lines each, no em dashes.

## Protected (do not change)
Beam lethality, 4 s interruptible lock warning, collision/hull/damage, Siren and role senses (silent 180 m, cruise 290 m), PR70 sweeper, photography exposure and grading, ending conditions, art direction, job ranges and durations.

## Bar (release play, dev off)
- **Finishability by hand:** for op 2 and Needle Strait, Furnace Drift, Silt Archive, Prism Grave, Hammerwake and Final Survey 1, a deterministic harness that only uses release-play controls (waypoint legs it places itself from measured chart knowledge, depth changes, in-reach jobs, recall) finishes each on STANDARD and ACCESSIBLE with Quietus SILENT throughout and bare fittings. Table: time, Hunt peak, locks, hull, oxygen, legs placed, drones recovered, versus the same op with test shortcuts (dev on).
- Fleet must matter (Pat 28 Oct): bare must still meet the Sirens in about 3/4 of these ops and finish; equipped clearly better.
- Proof shortcuts are gone: list of every travel shortcut and its visibility with dev off/on; a grep or test that fails if a new one-press travel order appears outside dev.
- Native screenshots, inner and cover at 100% and 150%: craft wheel, job page in reach, drone wheel with RECALL, a refused leg with its reason.
- If any op cannot be finished by hand, stop and report: that is a design finding for Pat, not something to paper over.

## Files you may edit
Order/command availability per wheel page, route installation for release play, new recall order, dev-state gating, brief/help text, their tests, docs, shared registration lines. Not layout, hit-testing or chart camera (root package 2). Not Siren behaviour.

## Checks
Import + Core, orders/navigation, route, radial, presentation/HUD, expedition instruments, campaign and finishability suites; full local checks before the PR.

## Return
PR into claude/integration with the tables above; independent review; wait for CLAUDE INTENT: PASS; merge on green; close the BOARD row and add one LEDGER line.
