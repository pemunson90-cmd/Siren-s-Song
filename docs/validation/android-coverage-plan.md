# Bounded installed-Android coverage beyond Shelf Signal

19 October 2026. Tooling proposal after promoted `f1ea536` / runtime `92625ac`, [native pass 39205478335](android-39205478335/README.md). No additional Android runtime claim follows from this plan. The production lead owns game hooks and the current [finale cycle](../design/FINALE_CYCLE.md); tooling owns native input/evidence scripts. Requested tooling model is explicit `gpt-6.1-sol`; actual backend/cost telemetry is unavailable.

## Keep the current gate

Retain both cover/inner zoom/pan/FIT, zero accidental order/pause assertions, ordinary Shelf Signal camera/win, sustained real audio, strict fatal/engine/script/parse scan, and cold completed-campaign restoration. Reuse one APK, signing identity, emulator boot and bounded adb helpers. Do not multiply six nearly identical long jobs. Do not rerun the unchanged promoted baseline only to collect more counts.

## Next valuable increment

Add **one finale ordinary-input path** when its canonical command protocol is green and independently inspected. It exercises distinct optical evidence, shipborne acquisition, Quietus return, ending presentation and durable archive data that Shelf Signal cannot cover. Keep the final error gate after this increment. Start with unfolded landscape for the long path; cover layout/gesture behavior already has independent coverage. A selected cover ending frame can follow live resize, without replaying the whole mission twice.

Needed read-only contracts, coordinated with the lead before implementation:

- Fresh `SS_TARGET` actions for mission selection, each clear objective approach, shipborne receiving approach and extraction; use current world→viewport mapping and reject stale/offscreen targets. FIT before authored world-target taps. Approach geometry must be validated for the selected craft and navigation/LOS rules, not blindly use one offset for every station.
- `SS_CAMERA_READY unit=N objective=N` must reflect the same canonical eligibility as CAMERA, including prerequisites and required craft. Current `main.gd::_observation_diagnostics()` checks range/LOS/alive/exposure only; generalizing it unchanged would overstate later-mission readiness. Never use the marker to bypass prerequisites.
- Observe accepted ordinary orders, objective/evidence identifiers, final outcome, ending screen and archive restore. Require new marker counts after each relevant action. Numeric mission IDs and evidence identifiers belong in the log; match selected required records instead of accepting any camera result.
- Reuse bounded waits with live process/fatal checks. Retain last valid screenshot, raw logs and progress on failure. A missing capability or ambiguous target fails with diagnostics; no blind gameplay retries or state repair.

Suggested observed sequence: select final mission → begin paused → send craft to valid optical approaches → acquire both records with ordinary CAMERA → move Quietus to eligible receiver → acquire shipborne record → route back → win/ending → inspect concrete recovered evidence → background/kill/restart → verify completed campaign and retained evidence. The lead's final ordinary-command plan supplies safe waypoints, tool decisions and finite wait bounds; this document does not invent a winning strategy before that work is proven.

## Honest entry state

The current native archive legitimately unlocks only Split Channel. The cheapest next progression extension is its **NEXT DIVE** entry and actual mission-one prerequisite/shipborne checks; this can prove genuine transition from Shelf Signal without another boot. Full legitimate progression through all six missions is a separate, longer gate.

For focused finale iteration, consider an **isolated, explicitly labeled debug archive fixture**, generated through canonical SaveStore/snapshot serialization and loaded through the normal app loader. It may supply prior completed missions, but must not supply already-captured finale records, teleported midmission craft, invulnerability or forced outcomes. Install it only in the ephemeral CI debug app data, preserve fixture/hash/start-state evidence, and run all finale actions through ordinary input. Confirm `run-as`/actual Godot data path first; no production cheat menu or hidden player-build command is needed. Production lead agreement is required for the precise fixture schema/hook contract. A fixture-assisted finale pass establishes that path, **not** native campaign progression or the player's ability to reach it. If clean fixture injection is not available, keep the finale gate pending rather than silently forcing scene state.

## Proportionate performance evidence

The successful retry already retains guest memory and process/boot continuity snapshots. Extend only when meaningful, in the same run and same known state:

1. Record APK hash, source, Android fingerprint/API/ABI, emulator/GPU version/mode, exact viewport, active mission/zoom and whether paused. Emulator backend is software ANGLE; it is not Fold7 hardware.
2. Bound `adb shell dumpsys meminfo org.sirenssong.game` at mission entry, after active play, and after return; retain raw output. Compare like states and identify sample count. A single high/low PSS does not establish leakage.
3. Probe `adb shell dumpsys gfxinfo org.sirenssong.game framestats` once. Godot's native rendering surface may not populate Android View frame statistics; an empty/inapplicable result is **unsupported**, never a zero-jank claim. Do not substitute screenshot/adb latency for frame pacing.
4. If native frame pacing is actually needed, coordinate a small sampled Godot monitor window (not per-frame log spam) with the lead: engine frame interval/process/physics distributions over a declared active state, including warmup/sample count. Keep output bounded and preserve raw samples/summary. Report engine/guest timing separately from simulation time; polling/screenshots and software rendering perturb it. Do not set an arbitrary phone-FPS acceptance threshold on this emulator.
5. Physical-device performance remains a separate repeatable test with actual Fold7 model/OS, display/fold state, thermal conditions, battery/audio and observed interaction latency. No phone-speed claim follows from this CI.

No new hosted service, profiler infrastructure, backend change, blind sleep or benchmark matrix is justified at this stage. Implement one distinct mission path first; retain current baseline if it exposes a regression.
