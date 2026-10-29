# Handoff 097: MAKE THE FLEET MATTER IN THE EARLY WAYPOINT OPS (2, 6, 7, 8, 9, 13, 39)

Status: PREPARED (codex-root; retained)
Claimed at: 28 Oct 2026 (root retained)
Claimed by: codex-root; no Claude handoff/restart
Finished at:

Precondition: not owned by another CLAIMED handoff. Leave op 37 alone (092 owns the Sorley content). Read HANDOFF.md and ORCHESTRATION_2026-10-26.md first. Current review rule (Pat, 28 Oct): independent Sol6.1-high review of the frozen patch before commit and before merge.
Codex may merge: yes, into claude/integration only, after independent approval and green required checks on the exact head, merge commit.

Source: 093 report (docs/design/FLEET_MATTERS_2026-10-28.md, Codex fresh session, 28 Oct) and Pat's 28 Oct finishability ruling. AI-DESIGNED scope; Pat ratifies.

## Task (plain language)
093 measured 2, 6, 7, 8, 9 and 13 (arcs 1 to 3) and optional 39 as WAYPOINT. The early game already has the best examples of the fleet mattering (EARNED: 1 Split Channel, 3 Cold Foundry, 10 Warning Chain, 11 Confluence), so copy what those do. Teaching still matters here: keep ops 0 to 5 gentle and readable (067 owns briefing wording).

Per op (093's cause in brackets):
- **2 Blackwater** [solo reverse-order custody beats the drone handoff]: make the handoff the safer, better-paying path (patterns 1, 2).
- **6 Divergence** [bare gets one route fact safely; scout gets two]: make the second fact matter later and the solo investigation more exposed (1, 3).
- **7 Deep Rendezvous** and **8 Shelf Return** [quiet solo berth / common-alarm route]: placement and parallel work (2, 4).
- **9 Wake Crossing** [playback fleet saves time and adds a record but adds exposure]: give the fleet route the better result without making it the more dangerous one (1, 5).
- **13 Open Warning** [manual gate route safe bare]: a drone task that pays off (1, 2).
- **39 Shelf Thread** (optional): the cache and bonus need the fleet (1, 3).
Also complete the **UNMEASURED** early pairs where cheap: 4, 5 and 12 (093 replayed the same solo route for both) and 0 and 40 (both policies lost; find a working pair or report why).

Ops 1, 3, 10 and 11 are the EARNED reference ops; do not change them except to fix a measurement controller.

## Files you may edit
The mission builder and layout files for these ops (opening_depth_operations.gd, onward_missions.gd, resolution_missions.gd, optional_operations.gd for 39 only), their journey suites and controllers, briefing lines, reward hooks, shared registration lines. Also game/src/campaign/onboarding2/briefing_rows.gd and onboarding_text.gd for the changed ops only (067/PR195 added GOAL/DANGER/NEW THIS DIVE rows; keep them true to the new jobs and name the equipped option in one line).

## Pat's rule (28 Oct, verbatim in USER_DIRECTIVES via PR194)
A bare launch (no finite tools) finishing an op is a skill feat for a skilled player: possible, demanding, with worse results. Planning, drones, tools and progression must change the outcome. The game must not feel like a walking simulator in a submarine.

## Hard limits
No change to Siren senses, lock timing (4 s interruptible), beam lethality, collision, damage or hull rules, photography design, art direction or ending conditions. Existing Siren roles keep their behavior; you may change **where Sirens are placed and their authored patrol points**, objectives, work sites, endurance values, optional tiers and rewards. A required route is never gated behind a finite tool or a losable drone. No save-format change unless a new fact is unavoidable (one key, old saves default absent). Story text: 1 to 2 line placeholders, no em dashes.

## Method
Use `docs/design/FLEET_MATTERS_FIX_PATTERNS.md` (patterns 1 to 8) and `docs/design/FLEET_MATTERS_2026-10-28.md` (the 093 measurements, harness at C:/Users/Archi/.cache/sirens-song-toolchain/artifacts/093). Reuse the 093 harness for the before and after numbers.

## Success measure (per op)
Rerun the 093 bare and equipped pair on the changed source:
- **Bare** (STANDARD) still finishes, and **meets the Sirens**: in at least three quarters of the batch's ops the bare route shows a Hunt peak of 20 or more or at least one received lock episode, from placement and authored patrol points of existing roles at the work (pattern 4). Endurance-only pressure (oxygen under 25 percent with Hunt 0) counts for at most a quarter of the ops and must not be the main lever. A route the Sirens never notice is still a walk (Claude S5 correction 28 Oct 14:27 ET after PR198).
- **Measure bare in SILENT running throughout**, as a skilled player would. Contact obtained by choosing avoidable cruise or exposure-only travel does not count (094b was blocked by independent review for exactly this). Keep a silent-running counterexample test.
- **Equipped** must not take clearly more hull than bare unless the PR states the tradeoff is deliberate; otherwise the fleet reads as the riskier choice.
- **Equipped** (drones used plus plausible tools and fittings for that point in the campaign) is clearly better on a major axis: people or cargo, photo records or grade, recovered material, side objective, reward, or a safer exposure profile.
- The equipped journey must complete the full recovery and departure flow (093 noted INC endings; fix the controller, do not skip the flow).
Report the before and after table rows in the PR body and the Completion lines.

## Checks
Import + core; the region's existing journey suites (update source-known routes where placement changed; never relax a check); the 093 pair rerun for each op. Suite ranks: next free in your block.

## Return
PR into claude/integration; independent review, merge on green; close per ORCHESTRATION section 7; one LEDGER line.

## Current prepared status
PUBLISHED PR212 head8b938470; UPDATED own gate pending (old40bf four-journey failures retained as evidence). Root48688 completed four TEST fixture-only repairs, independently reviewed62 and published: opening55/0, recipient72/0, nativeUI142/0, shelf27/0; no assertion weakening or source edits. Independent HIGH review62 APPROVE; root verified exact hashes, committed82478d5f and recorded accepted070 ancestry in content-identical8b938470. Historical6/7 pressure remains provisional with op6 limits, not DONE. Candidate already includes070 fede; original evidence and failed candidates preserved. Root retains097, then090/091; no Claude handoff/restart or new Pat decision needed. Pat two-lane ownership holds; Claude094/095/101 DONE remain untouched.

## Completion
(five lines max: per-op before/after class and the main pattern used)
