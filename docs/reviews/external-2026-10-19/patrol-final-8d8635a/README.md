# Final-source recovery replay · 8d8635a

Exact committed patrol/clearance-recovery source **8d8635a**, copied with `git archive` into an isolated scratch project. [Source hashes](source-sha256.json) match the lead's frozen identifiers. Native/UI/balance promotion remains pending; no player saves or active source were changed.

Replayed the identical [canonical 1/60-second world probe](../patrol-candidate/patrol-probe.gd) for 600 simulated seconds per mission and [eight directed intent probes](../patrol-candidate/intent-probe.gd). Both processes exit 0; raw [world log](patrol.log) reaches `PATROL AUDIT COMPLETE` with all 13 results and no engine/script errors; [intent log](intent.log) reports 8 checks, 0 failures.

All 13 sustain actual travel of 14,980–14,991 m; every authored waypoint area is entered at least 10 times. All remain PATROL with no detected target, blocked-goal time, empty-route time or unchanged-position interval at movement epsilon 1e-6. [Numeric delta against the earlier frozen patrol correction](delta-versus-prior.json) shows identical waypoint-entry counts and stationary durations for all Sirens. Twelve cumulative travel values are identical; Listening Well Siren 0 travels 1.126 m less over 600 seconds (about 0.008%), with a slightly different trajectory after shared clearance recovery. No stall or missed waypoint accompanies that difference. This establishes that shared navigation recovery did not regress the measured sustained unprovoked circulation. It does not replace adverse-heading/stranded-origin tests or establish difficulty, native input or physical touch quality.

Cover/hearing/last-known/search/telegraph/local-heard-point checks remain green. Their arranged test positions are separate from the unprovoked experiment. The original accepted stalled-patrol log and the prior correction snapshot remain retained beside this final-source replay.

Commands (copy retained probes to the scratch project's `audit/` first):

```sh
godot --headless --path /tmp/sirens-patrol-final-8d8635a/game --script res://audit/patrol.gd
godot --headless --path /tmp/sirens-patrol-final-8d8635a/game --script res://audit/intent.gd
```

Requested explicit `gpt-6.1-sol`; actual backend/usage/cost telemetry unavailable. No nested agents, no CI trigger, no push.
