# Original-prototype mechanics evidence — 19 October 2026

Read-only implementation audit. Requested routing: `gpt-6.1-sol`; actual backend/cost telemetry unavailable. All seven archive originals inspected; full v6/v7 diff retained. Original files unchanged.

Exact production `game/` and `design/` snapshots were extracted with `git archive` at **8d8635a**, **f1ea536**, **d09311c** into `/tmp/sirens-mechanics-audit/<sha>/`; no live or density WIP source was used. `source-hashes.json` records full commit IDs, production GDScript hashes and every original hash. Patches isolate the two current-source differences and v6→v7.

## Probes and scope

- `prototype-probe.cjs`, `prototype-v6-probe.cjs`: Node VM executes the original inline script unchanged, with DOM/canvas/audio context absent/stubbed and frame scheduling disabled. Deterministic micro-scenarios call real `update()` with a single synthetic zero-vision, zero-chase hunter, no rocks/currents/logs, submarine at (300,1500), hunter at (500,1500), speed chosen to match the original arrival throttle, and one 1/60s tick. This isolates acoustic investigation/suspicion from LOS detection. Thermal uses actual `effDetect()`. Heartbeat hook counts actual `AU.beat()` calls over two seconds; it does not render/listen to audio. Hunt cooldown probes have no nearby threat; four-photo probe starts at 90 then cools for 60 s (result 42, toward floor 32).
- `current-probe.gd`: real Godot 4.6.3 simulation and soundscape, isolated mission 0 with rocks removed and drones disabled; `_threats()` is called directly to isolate sensing from movement. Noise hearing test is 350 production world units away with explicit velocity; the stationary detection test is 200 units away. It also calls real ping, beam/stun and `Soundscape.update()` with a fresh synthetic observed lock. Audio `voice_playing=true` proves the cue is scheduled in headless playback; it does not establish audible quality or Android performance. Engine gain is read from actual production function.
- `prototype-v7.json`, `prototype-v6.json`, `current-*.log`: raw outputs. All three production revisions return the same measured mechanics in this fixture. f1ea536/d09311c exit 0 with an ObjectDB shutdown-leak warning; 8d8635a exits 0 without warning. No script errors. This is bounded audit evidence, not a full strict runtime/Android gate or attribution of that shutdown warning to gameplay.

**Units and inference:** prototype and production world scales/layouts differ. 200 prototype units and 350 production units are separate setups, not normalized difficulty comparisons. The probes establish code paths and discontinuities, not relative fairness, whole-run difficulty, fun, or source fidelity. No full browser/Android/human listening test was performed for this audit.

## Archival contradictions and implementation caveats

functional v0.3/dev notes still say drones or knockdown are unbuilt although both saved builds contain them. The pressure proposal's header says “not built,” but v7 implements Hunt core/graze; its **stage patrol-speed/sweep/lockdown movement ladder was deferred**, not lost production behavior ([manifest:105–122](../../../reference/original-prototype/MANIFEST.md#L105)). v7 idle Hunt can cool rather than inevitably climb. Spec §7 says detection inputs are LOS-gated, while original ping/engine hearing is not; original Sirens/drones also move straight through terrain. These are reasons to adapt code, not copy every detail. Dev-note numbers lag v7 (arrival 110→220, oxygen ≈220→300 s); manifest's 9 rocks versus code's 10 is another archival mismatch. Deep Contact is an earlier classification-game pitch, not implemented Siren's Song mechanics.

## Reproduce

From the repository root, run either original against its corresponding Node fixture:

```sh
node docs/validation/original-prototype-mechanics/prototype-probe.cjs reference/original-prototype/sirens_song_prototype_v7.html
node docs/validation/original-prototype-mechanics/prototype-v6-probe.cjs reference/original-prototype/history/sirens_song_prototype.html
```

For production, extract the desired exact commit's `game/` into an empty temporary directory with `git archive`, then use Godot 4.6.3:

```sh
godot --headless --path /tmp/sirens-mechanics-audit/8d8635a/game --script "$PWD/docs/validation/original-prototype-mechanics/current-probe.gd" -- 8d8635a
```

The hash manifest lets a reviewer verify the extracted sources. The script adds no production file and does not touch player saves. Test setup uses `start()` directly rather than the running application/persistence.
