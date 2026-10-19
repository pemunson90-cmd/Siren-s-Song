# Addendum A to the external adversarial audit: patrol regression and fix instructions

## Provenance

| Field | Value |
| --- | --- |
| Date | 2026-10-19 |
| Auditor | Claude Opus 5.5 (Anthropic), external to the Gauntlet |
| Parent document | `docs/reviews/2026-10-19-external-adversarial-audit.md` (finding F1, intervention 1) |
| Trigger | Owner noted that the chat-built v7 prototype had moving, patrolling enemies. Verified against the archived source before inclusion. |
| Audited source | `game/src` identical at `92625ac` and `f1ea536` |
| Prototype inspected | `archive/prototypes/sirens_song_prototype_v7.html`, Siren definitions and behavior branches |
| Mode | Read-only. No repository writes by the auditor. |

This addendum stands alone. The same finding and instructions appear as Addendum A in the full audit, so the Gauntlet only needs this file to act on it.

## Context from the parent audit (F1, summarized)

Running each mission for 600 simulated seconds with no player input, 8 of 13 production Sirens never move. The production patrol goal is a procedural formula, `home + (sin(elapsed/19 + patrol)*190, 70 + cos(elapsed/27)*65)`, which regularly lands inside rock or out of bounds. `path()` then returns an empty route, and a new goal is only picked once the Siren gets within 35 px of the old one, which never happens. Every balance number recorded so far was measured against these frozen Sirens.

## Observation: v7 already had working, differentiated enemy movement

`archive/prototypes/sirens_song_prototype_v7.html` defines three Siren types with separate behavior branches:

| v7 type | Definition (approx. line) | Unprovoked behavior |
| --- | --- | --- |
| `patroller` | 187, 190 | Authored four-point waypoint loop (`wp` array), advanced by `s.wi=(s.wi+1)%s.wp.length` as each point is reached (around line 376) |
| `sentinel` | 193 | Tethered guard: returns home when beyond `tether:190` with no sighting or lure (around line 362) |
| `hunter` | 194 | Fast (`chase:64`). Chases sightings and lures, investigates last-known positions with a wider random search, returns home otherwise (around line 368) |

All three share last-known-position memory (`invX`, `invY`, `invT`) and decoy luring. Each type has its own silhouette in the renderer (around lines 426 to 427).

## Comparison

Production `simulation.gd` has a single Siren type whose unprovoked movement comes entirely from the procedural goal formula, with no authored routes. `GAUNTLET.md` names v7 as the "reusable behavioral reference for noise, suspicion, ping investigation, last-known positions." The production rewrite kept those named behaviors but dropped v7's movement model and its type differentiation.

## Inference

- F1 is a regression from the Gauntlet's own designated reference rather than an unexplored gap. Neither the critics nor the deterministic suite compared production enemy behavior against v7.
- The Listening Well's promised "mobile hunter" already existed as v7's `hunter` type.
- A sentinel type would turn Cold Foundry's stationary guards into an intended, legible design. Right now they are stationary only because of the bug.

## Instructions for the fix

These replace the minimal goal-picker patch as the preferred route.

1. **Red before green.** Write the liveness tests first and confirm they fail on the current code:
   - Each unprovoked patroller covers a minimum distance in a fixed time and visits every authored waypoint.
   - Each sentinel stays within its tether when unprovoked.
   - Every authored waypoint passes production `blocked()` at Siren clearance.

   A fix that is written before its test means the test is grading its own fix.
2. **Port v7's patroller waypoint loops** into mission data as authored per-mission routes. v7's `moveToward` moves in straight lines, so production should keep using `path()` between waypoints for terrain avoidance.
3. **Port `sentinel` (tethered guard) and `hunter` (fast responder) as distinct types.** They should use production's existing fair-sensing rules: line of sight, acoustic occlusion, stun, and the lock telegraph. Keep production's no-omniscience guarantees. v7 is the reference for movement, and production stays the reference for sensing.
4. **Assign types per mission as a design decision.** The Listening Well gets the hunter. Cold Foundry's guards become sentinels on purpose.
5. **Retire the old numbers; do not retune back to them.** Once Sirens move, some of the six fallback wins will likely start losing. That is real difficulty appearing, not a regression. Do not reduce detection or slow Sirens to recover the old 100% hull results. Record the pre-fix numbers as historical in `docs/BASELINE_AND_EXPERIMENTS.md` and treat the post-fix results as the new baseline.
6. **Rerun everything** against the new behavior: the naive-policy panel (parent audit, intervention 3), all retained strategies, and the critic probes.

## Evidence quality note

This addendum is based on reading v7's source. v7 was not run, and its patrol paths were not measured in a browser.
