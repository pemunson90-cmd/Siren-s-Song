# Independent role-aware replay

This is an independent deterministic audit of the frozen, **uncommitted challenger** identified by [source hashes](source-sha256.json), not native Android validation or baseline promotion. These are **pre-pursuit** results: the independent v7 comparison below prompted the lead to add a focused visible-pursuit RED test before a further station-role change. That later source requires a separate directed replay. Production source was copied to `/tmp/sirens-siren-roles-independent/game` before execution; neither probe nor auditor edited game source. Requested model: explicit `gpt-6.1-sol`; backend, token and cost attestation unavailable. No nested agents.

## Method and results

`world.gd` advances each of the six actual missions for 36,000 canonical `Simulation.STEP` ticks (600 simulated seconds), with untouched endurance loadout/default units and no commands. Travel sums actual per-tick displacement; movement epsilon is 0.000001 world units, rather than the erroneous 0.5-per-frame test. Counts record entries within 35 world units of each authored waypoint (including incidental entries), not just waypoint-index increments. Completion rejects prematurely halted simulation. The retained log samples state every 60 seconds and reports every role separately. `check_world.py` verifies the resulting role-specific assertions.

All 10 patrollers travel approximately 14,980–14,991 world units, visit every authored waypoint at least 10 times and have no stationary interval. The two Foundry sentinels and Listening Well hunter remain exactly at home, DORMANT for all 600 seconds. This is intentional station behavior, not a failed patrol. No player target is detected in this idle replay. The initial stronger `blocked(position,24)==false` assertion failed for Well patroller 0: it spends 28.05 seconds within the 24-unit planning margin. The actual `_move` collision radius is 12, so this is separately checked below rather than mislabeled terrain penetration. Detailed per-role measurements are in `world.log` / `measurements.json`.

`intent.gd` retains the independent 8-check cover/hearing/lock/last-known/SEARCH/reachable-edge probe: 8 checks, zero failures. It checks the common sensing path through a patroller; it does not independently reprove every role's save/EMP behavior.

`stations.gd` adds 18 checks on **actual authored terrain**, selecting a reachable 300-world-unit stimulus point rather than clearing obstacles. Other Sirens and drones are removed only in this directed fixture to isolate each station role. It injects a named diagnostic noise (not a player-input or resource-balance test); the pilot stays at its original distant position. Each scenario runs 80 simulated seconds at canonical steps. Logs retain every mode transition and physical travel, rather than accepting goal changes as movement.

- Well hunter: INVESTIGATE → SEARCH (6.57 seconds) → RETURN → DORMANT at 18.98 seconds; 877.18 world units total physical travel.
- Foundry sentinel 0: live lure permits 303.18 world units from home; returns after the lure expires at 8 seconds; DORMANT at 15.97 seconds.
- Foundry sentinel 1: live lure permits 299.07 world units from home; DORMANT at 15.82 seconds.
- All directed station runs retain 100 hull, no invented visual target and no position blocked at 24-unit clearance. Final home errors are 5.60–5.65 world units, inside the production 15-unit dormant tolerance. There is no teleport-to-home assertion.

The focused `clearance.gd` replay repeats actual mission 4 for 600 seconds and samples both radii: all three Sirens have **zero samples blocked at the actual 12-unit body radius**. Well patroller 0 repeats the 28.05-second planning-margin observation; its first such position is (707.3588, 262.5551). This qualifies terrain safety rather than erasing the failed stronger assertion.

## Source comparison and limits

[Original v7](../../../../../reference/original-prototype/sirens_song_prototype_v7.html) branches separately for authored patrollers, tethered sentinels and a fast hunter. Sentinel return is conditional on no live sight/lure; hunter returns home when investigation expires. The candidate preserves those distinctions using production terrain paths and bounded deterministic search around last-known evidence. [Ratified A](../../../../reviews/2026-10-19-external-audit-addendum-A.md) makes production sensing authoritative; the existing cover, attenuated sound, fresh four-second lock warning and stun branches remain shared.

One explicit departure remains: v7 physically chases a visible pilot; production's inherited visual-lock branch clears its movement route and fires after the warning. That was present before this role change and is not a newly introduced regression. It is reported to the lead as a reference departure, not silently counted as a demonstrated chase. The 24-unit margin result is not a liveness failure: circulation and all-waypoint entry continue. These probes do not evaluate difficulty, atmosphere, silhouette legibility, full tactics, native performance or fairness subjectively. External reference motion comparison remains pending accessible footage.

## Reproduce

Copy the exact matching `game/` source to an isolated directory, copy these four `.gd` files into its `audit/`, then run:

```sh
godot --headless --path /path/to/isolated/game --script res://audit/world.gd > world.log 2>&1
godot --headless --path /path/to/isolated/game --script res://audit/intent.gd > intent.log 2>&1
godot --headless --path /path/to/isolated/game --script res://audit/stations.gd > stations.log 2>&1
godot --headless --path /path/to/isolated/game --script res://audit/clearance.gd > clearance.log 2>&1
python3 check_world.py
```

Require completion markers, zero failures, exit status zero and no Godot/script errors. Godot used: official 4.6.3 stable, build `7d41c59c4`. Exact retained-file hashes are in `SHA256SUMS`.
