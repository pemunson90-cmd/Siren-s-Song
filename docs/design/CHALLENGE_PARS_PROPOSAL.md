# Challenge pars proposal (handoff 047)

AI-DESIGNED. Every number in the "proposed par" column and the schema below is a
proposal for Pat to accept, change or reject. No par, no scoring code and no rule was
changed by this work. The measured numbers are real: they come from the scripted
completions in `game/tests/challenges_completions_*_tests.gd` (ChallengeRun, live
Sirens, ordinary commands) and from `challenges_journey_tests.gd` for the Shelf row.

## Why

`challenge_records.gd` `pars(row, result)` scores time against one `row.par.time`.
`lung_solo` has two physical routes with very different lengths, so one time par is
fair to one route only:

| lung_solo route | time | hull | tools | vs par time 110 s |
|---|---|---|---|---|
| dismantle (west feed room) | 79.3 s | 100 | 0 | meets (3 of 3 pars) |
| reconnect (far breaker, plant, return) | 273.6 s | 100 | 0 | cannot meet (2 of 3 pars) |

The reconnect route cannot reach par 110 s by any shortening of the course: the
plant approach alone is a 2750 m loop at cruise speed. The dismantle/reconnect choice
is the operation's own decision, so the gap is a scoring question, not a play-skill one.

## Measured results, all rows

One scripted route per row (the first in that row's "route" cell); times are
`ChallengeRun.elapsed` at the won outcome, one run each (the simulation is fixed-tick
and the scripted routes are deterministic on this build, but they are single samples,
not a difficulty distribution).

| row | route | time s | hull | tools | par time | par hull | par tools | pars met |
|---|---|---|---|---|---|---|---|---|
| shelf_passive | camera approach (existing journey) | 64.0 | 100 | 2 (EMP, allowed by the rule) | 90 | 100 | 0 | 2 (tools par missed) |
| split_solo | shallow saddle, MIDDLE uplink | 164.2 | 100 | 0 | 210 | 95 | 0 | 3 |
| foundry_no_charges | opening depth course | 83.6 | 100 | 0 | 120 | 100 | 0 | 3 |
| well_intact | opening depth course | 127.6 | 100 | 0 | 160 | 100 | 0 | 3 |
| song_fleet | opening depth course | 118.3 | 100 | 0 | 180 | 90 | 1 | 3 |
| rendezvous_middle | quiet berth, no release | 71.9 | 100 | 0 | 180 | 95 | 0 | 3 |
| wake_one_charge | quiet outer water | 123.9 | 100 | 0 | 180 | 90 | 1 | 3 |
| glass_passive | glass course | 139.5 | 100 | 0 | 210 | 90 | 0 | 3 |
| reach_quiet | glass course | 149.6 | 100 | 0 | 240 | 85 | 0 | 3 |
| glass_fast | glass course | 182.8 | 74.4 | 0 | 240 | 85 | 0 | 2 (hull par missed) |
| stair_no_charges | lock cycle | 187.9 | 100 | 0 | 240 | 90 | 0 | 3 |
| lung_solo | dismantle | 79.3 | 100 | 0 | 110 | 100 | 0 | 3 |
| lung_solo | reconnect | 273.6 | 100 | 0 | 110 | 100 | 0 | 2 |

Note 1: the Shelf journey is the existing test; its `Travel.move` helper fires EMP
on a lock, so it spends 2 EMP charges and misses the tools par. It was read from that
test's own printed line, not re-run through the new `report` helper.

Findings:

1. Eleven of twelve rows are completed by a source-known scripted route; a scripted route with route knowledge finishes 22 to 60 percent inside the time par on them.
   Pars were authored as targets, so this is expected, not a defect.
2. `glass_fast` met its rule (time limit 360 s, 182.8 s used) but its scripted route
   took 25.6 hull damage and missed par hull 85. That is a scripted-route finding, not
   proof the par is unfair: a more careful route was not searched for.
3. `lung_solo` is the only row where the rule-legal routes differ enough to matter.
4. No second route was scripted for any other row. `split_solo` has a middle-band
   alternative (the older expanded-region solo circuit) that was lost to a Siren beam
   in 49 s on this build, so it is not a viable second route; the shallow-cover route
   above is the first one that completes.

## Proposed par values (Pat decision)

Only `lung_solo` needs a change; every other row keeps its current par.

| row | route | current par time | proposed par time | basis | Pat decision |
|---|---|---|---|---|---|
| lung_solo | dismantle | 110 | 110 (unchanged) | measured 79.3 s | accept / change |
| lung_solo | reconnect | 110 | 300 (proposed) | measured 273.6 s, about 10 percent margin | accept / change |

Hull 100 and tools 0 would stay the same on both routes (both measured 100 hull, 0 tools).

## Route-aware par schema sketch (Pat decision)

Keep today's shape valid. Add an optional `routes` list beside `par`:

```
{"id":"lung_solo", ..., "par":{"time":110.,"hull":100.,"tools":0},
 "route_pars":{"key":"iron_choir.choice",
               "reconnect":{"time":300.,"hull":100.,"tools":0}}}
```

Rules of the sketch:

1. `par` stays the default and the only par for every row without `route_pars`.
2. The route is read from existing mission state at the moment of recovery, never from
   player input and never from a new save field. For `lung_solo` that is
   `mission.iron_choir.choice` (`"dismantle"` or `"reconnect"`). `ChallengeRun.result()`
   would copy that one string into the result as an optional validated field
   `route` (max 32 characters), so `ChallengeRecords.pars(row, result)` stays a pure
   function of its two arguments.
3. `pars()` would use `route_pars[result.route]` when both exist, else `par`.
4. A result without `route` (an old save) scores against `par`, exactly as today.
5. Saved bests: the stored best is compared with `better()`, which calls `pars()` for
   each result. If the best was a dismantle result and the new one a reconnect result,
   each is scored against its own par, then ties fall through to time. This means a
   fast dismantle best would always beat a reconnect result; Pat should say whether
   best is kept per route (a `best_by_route` map) or overall.

Alternative considered: a single `par.time` as an object keyed by route
(`"time":{"default":110,"reconnect":300}`). It changes the type of an existing field
that `valid()` and tests read as a number, so the extra-field form above is safer.

## What was not done

1. No scoring code change. The optional default-off flag in `challenge_records.gd`
   was skipped: the schema in rule 5 (best per route versus overall) is a design
   decision for Pat, and adding a flag before that decision would fix one answer into
   code.
2. No par number was edited in `challenge_catalog.gd`.


## Ratification, 27 October 2026 (Pat)

Pat **approved** route-dependent time pars for `lung_solo`: **110 seconds for dismantle** and **300 seconds for reconnect**; hull 100 and tools 0 remain unchanged. Route identification must come from the actual recorded mission choice. Pat also approved storing **personal bests per route** alongside an **overall challenge completion** record. This settles the previously open scoring-model decision in this proposal. Other challenge pars remain unchanged pending evidence.

**Implementation status:** implemented in handoff 059: catalog `route_pars`, optional result `route` and per-row `routes` bests, route lines in the challenges detail screen, `challenges_route_pars_tests`. Choices other than dismantle/reconnect (bypass, isolate) use the base par.
