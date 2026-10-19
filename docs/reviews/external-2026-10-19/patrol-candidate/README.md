# Independent sustained patrol correction check

19 October 2026. This is an **unpromoted source snapshot**, copied from the lead's frozen local correction atop `1912572`, not a new native-tested baseline. Source identifiers are [SHA256 manifest](source-sha256.json) and [exact patch against 1912572](frozen-source-versus-1912572.patch). Both source hashes were rechecked against the production worktree after the probe; they match. Active game files were never edited by tooling.

## Sustained world probe

The [independent probe](patrol-probe.gd) preserves the baseline experiment's canonical 1/60-second steps, 1e-6 m movement epsilon and 600 s per mission. It additionally counts actual entries within 35 m of each authored waypoint, tracks mode/target duration, and rejects any halted simulation/outcome rather than suppressing it. [Complete raw log](patrol.log), Godot 4.6.3.stable.official.7d41c59c4, process exit 0, `PATROL AUDIT COMPLETE`, zero engine/script errors.

| Mission | Siren | Actual travel, m | Longest unchanged interval, s | Actual waypoint-area entries |
| --- | --- | ---: | ---: | --- |
| 0 | 0 | 14986.729 | 0.000 | [27, 27, 27, 26] |
| 1 | 0 | 14985.537 | 0.000 | [12, 12, 12, 12] |
| 1 | 1 | 14985.460 | 0.000 | [11, 11, 11, 11] |
| 2 | 0 | 14987.365 | 0.000 | [25, 25, 25, 24] |
| 2 | 1 | 14990.730 | 0.000 | [12, 12, 12, 11] |
| 3 | 0 | 14983.670 | 0.000 | [14, 26, 13, 13] |
| 3 | 1 | 14980.228 | 0.000 | [23, 23, 23, 22] |
| 4 | 0 | 14986.584 | 0.000 | [18, 18, 18, 17] |
| 4 | 1 | 14983.996 | 0.000 | [11, 22, 11, 11] |
| 4 | 2 | 14989.791 | 0.000 | [10, 10, 10, 10] |
| 5 | 0 | 14987.600 | 0.000 | [16, 15, 15, 15] |
| 5 | 1 | 14980.500 | 0.000 | [25, 24, 24, 24] |
| 5 | 2 | 14985.175 | 0.000 | [14, 14, 14, 14] |

All 13 Sirens travel 14,980–14,991 m and physically enter all four authored waypoint areas at least 10 times over 600 simulated seconds. No unchanged-position interval, blocked-goal time, empty-route time or detected-target time was recorded. All remain in PATROL. The actual waypoint-area counts are not inferred from `patrol_index`; incidental near-passes can produce extra entries, so these numbers do not prove exactly that many completed circuits. All sampled fresh paths remain reachable. This independently closes the previously reproduced long patrol stall for this unprovoked snapshot, without replacing the full run by a minimum-distance assertion.

## Directed intent probes

[Probe](intent-probe.gd), [raw log](intent.log): **8 checks, 0 failures**. These are explicitly arranged simulation scenarios with test-position setup; they are not the unprovoked patrol experiment or native input evidence.

- Finds legal cover-separated positions 156.205 m apart and verifies no silent visual lock through cover.
- Radius 300 noise behind cover is below the attenuated threshold and does not trigger investigation; radius 600 does, without visual target/lock.
- Visible stationary player receives a 1.0 s lock with 100% hull, preserving the pre-beam telegraph.
- After the player leaves sight, the goal remains the last seen `(700,130)`, not the newly hidden `(140,800)`; SEARCH is subsequently observed.
- A heard point beside a clearance margin produces a real navigable local route endpoint rather than abandoning investigation for patrol.

This is bounded evidence of preserved intent, not exhaustive validation of every chase/search/stun/recovery case. Existing production fairness tests and the lead's full tactics/recovery reassessment remain required. Legacy-save fallback movement, physical target sizing, Android native behavior and revised mission balance are not established by this probe. No enemy speed, hearing, lock, resource or sensor rule was retuned by tooling.

## Reproduce

Copy the two retained probes to `audit/patrol.gd` and `audit/intent.gd` in an isolated copy of the matching game source. Run separately:

```sh
godot --headless --path /tmp/sirens-external-audit-patrol-candidate/game --script res://audit/patrol.gd
godot --headless --path /tmp/sirens-external-audit-patrol-candidate/game --script res://audit/intent.gd
```

Source and baseline comparison are intentionally retained even if a later candidate changes. Requested explicit `gpt-6.1-sol`; actual backend/model usage and cost telemetry unavailable. No nested agents, no game edits and no CI trigger.
