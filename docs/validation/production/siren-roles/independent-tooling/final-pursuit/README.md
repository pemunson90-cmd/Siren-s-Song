# Final station-role pursuit replay

Independent follow-up to the [pre-pursuit replay](../README.md). The frozen **uncommitted** source is identified by `source-sha256.json`: simulation `472b86bd…`, missions unchanged `d98b85e5…`. It was copied to `/tmp/sirens-final-pursuit/game` before testing and rehashed afterward. No game edits, publication, native validation or baseline promotion is implied. Requested routing: explicit Sol 6.1; actual backend/usage telemetry unavailable; no nested agents.

## Observed results

`pursuit.gd`: **24 checks, zero failures**. Each of the actual Well hunter and two Foundry sentinels is tested separately on its unchanged authored terrain. The fixture removes other Sirens/drones and places a cruise-visible pilot at a reachable, clear 260-unit offset. During 3.5 seconds it varies that position sinusoidally by up to 8 units; this is explicit diagnostic stimulus, not evidence of ordinary player navigation. All movement/locking is production simulation at canonical steps.

| Role | Actual pursuit travel | Minimum pilot separation | Return / DORMANT time |
| --- | ---: | ---: | ---: |
| Well hunter | 77.56 | 181.23 | 24.45 s |
| Foundry sentinel 0 | 82.41 | 177.64 | 12.88 s |
| Foundry sentinel 1 | 74.49 | 185.07 | 13.02 s |

Distances are world units; times are simulated seconds from fixture start. Return is physically within the 15-unit dormant tolerance, not teleportation. Each role:

- Pursues the moving visible target without sampling a blocked position at the actual 12-unit body radius.
- Retains 100 hull during 3.5 seconds of fresh visual lock and brakes near the chosen emitter standoff.
- Loses current target when the pilot is moved to the distant hidden start, retains the actual last-seen point and does not follow the hidden position.
- Physically returns home after the bounded investigation/search.
- Stops immediately under the canonical EMP command, clears lock, and receives a fresh approximately 3-second warning after the full disruption expires, with no damage during that warning.

The unchanged independent common-sensing probe passes **8 / 0**, and actual-terrain noise/search/conditional-sentinel-return probe passes **18 / 0** on this exact final source. This checks both current sight and the separate heard-evidence path. Logs contain no Godot/script errors. It does not measure unrestricted chase of an arbitrarily fast player, all possible terrain approaches, ordinary-input mission victory, subjective fairness or Android performance.

## Reference reconciliation and circulation scope

`pursuit-source.diff` records the complete change from the prior audited simulation: the station-role visual branch now computes production terrain paths toward a 180-unit offset while farther than 205 units; it brakes inside that distance. Its path refresh interval is 0.3 seconds. Visual lock/damage still requires current LOS every tick, and disruption blocks both movement and locking. Hunter response speed remains 64; alerted sentinel response remains 48. This is a documented adaptation of v7's straight-line pursuit, avoiding overlap while retaining the production lock warning. Patroller visual standoff remains deliberately unchanged.

The no-current-sight patrol and station logic and mission data are byte-identical to the previous frozen audit. Therefore the full 600-second circulation replay is retained there rather than repeated for this localized visual-only change. The new directed tests exercise the changed branch and its transitions back into last-known/return logic.

## Planning-margin baseline comparison

`baseline-8d-clearance.log` reruns only actual mission 4 for 600 seconds against exact commit `8d8635aa2a1d7dc64c3d0f9f933972c1504aec1e`; both source files were compared byte-for-byte with `git show` before execution. Their SHA-256 values are retained separately. It uses the parent `clearance.gd` unchanged.

Well patroller 0 reproduces **exactly the same 28.05 seconds inside the 24-unit planning margin**, same first position `(707.3588, 262.5551)`, and same 14,985.4577 total travel. All three baseline Sirens have zero samples penetrating the actual 12-unit movement collision radius. This qualifies the failed stronger margin assertion as **inherited from the earlier navigation source**, not a newly introduced role/pursuit regression. It does not establish that 24-unit clearance is maintained, or that the planning margin has no experiential consequence.

## Reproduce

Copy the exact matching game source to isolation, place the retained `.gd` files in its `audit/`, then run each with `godot --headless --path /path/to/game --script res://audit/<name>.gd`. Require exit status zero, exact `PURSUIT CHECKS 24 FAILURES 0`, `INTENT CHECKS 8 FAILURES 0`, `STATION CHECKS 18 FAILURES 0`, and no Godot/script errors. Godot: official 4.6.3 stable `7d41c59c4`. The source-only diff and all raw evidence are hashed in `SHA256SUMS`. External shipped-game motion comparison remains pending accessible footage, with no invented verdict.
