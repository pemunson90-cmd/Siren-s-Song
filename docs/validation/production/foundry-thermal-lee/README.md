# Foundry thermal lee — bounded implementation evidence

Requested routing: Sol6.1/high; actual backend, tokens and cost unavailable. Baseline79c9b5a90cccf31dd3aceba12256eac8df89771a; exact candidate file hashes in `source-freeze.json` and product delta in `source.patch`. Policy refreshf6afaca56b4b3046d1ec5aa6cddee9e3ffa639a9 was read: changed CONTINUATION/WORKBENCH/parity in full, other governing documents unchanged from the already-read79 policy. The prior investigation remains onf11e6381dd2e3906e4d8bdd34a907da0c25c3063 and its original scratch is preserved.

Inspect `motion/*.mp4` before the interpretation below. Three actual rendered20s/15fps/300-frame1280×720 takes: baseline wait12, challenger wait12, challenger idle. The `*-1fps.jpg` sheets decode the released movies; `.media.json` verifies stream metadata. These are recognizable/nonblind software-GL desktop captures, Dummy audio, fixed programmatic2× chart pan, fixed-step controller. No human touch, listening, native/device latency or performance proof. Static views use desktop1280×720 and repository-established landscape420dpi fixtures2520×1080/2184×1968 at1×/2×/4×, not physical Fold7 captures. Earlier portrait probes stay ignored and are excluded.

## Fixture qualification and policy

`furnace-earned.snapshot` is the unmodified original ordinary-command-earned chapter3 fixture: mission elapsed17.2s, furnace photographed, hull100, all craft alive, one EMP remaining after two already spent from original Disruption stock3. Chapter3 was directly entered by harness; this is not a campaign-earned archive. Drone A already has a withdrawal route; B waits west of the proposed front. No actor, resource, timer, patrol, velocity or accepted order edits.

The original is a LEGACY archive and must stay unmasked. `qualify_thermal.gd` adds ONLY `thermal_revision=1` and the authored `thermal_fronts` metadata to a common copy. Both baseline and challenger load the identical `furnace-qualified.snapshot`; the old baseline ignores those unknown fields. This is an explicitly qualified fresh-mission environmental counterfactual, not a claim that a legacy save gains a new field. Original/common canonical state hashes:8a3749cab5316e7517aa7b0d621cfeefed4ac12ad4a2c6fc715a03ef597b4883 /9b7e5ca1612f4516e372bf85503c0f3fe11920f32e9d51106c6f195ebe3fb6a3. Binary file hashes are in `sha256.json`.

Wait policy is predeclared12s, then ordinary B route1110,830, ordinary camera at settled arrival, ordinary withdrawal1040,880 after record. One remaining EMP may be spent when a legitimately fresh contact has lock>1s and a live observed target; select observed target, use EMP, restore selection. No hidden enemy state chooses a command. `noemp` trace means that remaining EMP is withheld, not absent stock. Idle means zero NEW commands/tool use; A's inherited withdrawal continues and time/O2/battery/enemies continue. No policy/parameter search.

Movie frame0 is mission25.2s (=fixture+8s); last visible frame is45.133s and controller endpoint45.2s (=fixture+28s). Thus they show the latter4s of waiting, the approach, optical exposure and later pressure. Source controller logs expose full actor truth for audit only; UI and policy use ordinary knowledge. Fresh/last-seen contact ages remain honest.

## Actual result and cost

Times below are relative to the17.2s fixture; `null` loss in traces means alive only at that finite endpoint. All cases end hull100 and mission ongoing; no extraction victory is claimed.

| Policy | Baseline | Thermal |
| --- | --- | --- |
| Immediate, last EMP allowed | Record8.9s; EMP7.4s; B lost17.7s; A alive25s | Same record/EMP; B lost21.0s; A alive25s |
| Immediate, EMP withheld | Record8.9s; B lost10.4s | Same record and B loss10.4s |
| Idle, no new commands | A lost12.3s, B16.3s | Both alive25s endpoint; no second record |
| Wait12, last EMP allowed | Record20.9s; EMP9.4s; A lost25.5s, B29.5s | Same record20.9s; EMP18.1s; B lost35.7s, A alive37s endpoint |

The field supplies a useful limited staging choice; it does not make the exposed photo route safe. Waiting costs12s/about0.67oxygen percentage points at unchanged drain and delays record12s. The wait-pair summed fresh-contact seconds fall42.5→30.1 over37s; idle25s falls25.8→9.6. This is sum(contact count×dt), not an any-contact duration or quality score. Beam emission restores legitimate warning even across the front. `challenger-wait12` around movie9.3s shows a current charge line/countdown during optical exposure; baseline later shows A lost while B faces another charge. The candidate's later B loss remains in the full37s trace outside this20s movie.

## Contract and checks

Fresh Foundry only: one charted Rect2(1000,780,320,120),0.55 amplitude factor per true boundary crossing, source/listener separation<120 bypass. A two-boundary path receives0.3025. This retained provisional game-scale coefficient/rectangle produced staging and information costs without changing enemies, speed, stock or drain. It is not calibrated refraction physics or a global v7 clone. Supported bent acoustic paths share one modifier; corner tangencies, subdivisions, same-side and reciprocal paths remain deterministic.

`visible()` is unchanged: chart knowledge, optical camera/LOS and physical launch/steering retain their contract. Only contact acquisition receives thermal attenuation. Active acoustic sonar is weakened too; recon retains its existing global reveal. A real unstunned charge targeting live own craft with physical sight remains observable; targetless/stunned/through-rock locks grant no invented observation. Cached observations and20s memory expiry remain unchanged. Original legacy archives restore exactly without added fields. Malformed/orphan/foreign thermal payloads are rejected. No movement, projectile, route, command/input or targeting instrument edits.

The charted boundary is under stone/fog/craft/beam layers; its short label was moved off the obstructing basalt after initial preview. Thermal status REPLACES the existing acoustic qualification line, preserving8f32 contact clearance, with no added row. Three-contact/optical layout checks pass desktop and both landscape density fixtures. Fit labels are small and subordinate; the fixed-size qualification remains readable. These observations do not establish physical touch/comprehension or native safe-area acceptance.

Targeted Godot4.6.3 checks: thermal model22/0, transmission12/0, thermal UI8/0; existing acoustic path20/0, affected53/0, hearing21/0, footprint6/0, acoustic UI7/0, observed-contact UI/model73/0, physical knockdown59/0. Relevant RED logs retained. One attempted direct launch of a RefCounted scenario module was a harness invocation error, then corrected by `checks/thermal_affected_ui.gd`; only the real73-check run is asserted. Scene-based harnesses retain ObjectDB cleanup warnings at process exit; no script error was observed in the successful checks/captures. These are correctness evidence, not a quality score or a full/native gate.

Reproduction from feature worktree (scratch paths in scripts are explicit):

```sh
TOOLCHAIN_CACHE=/workspace/Siren-s-Song-gauntlet/work/toolchain scripts/toolchain/headless.sh --script res://tests/thermal_lee_tests.gd
TOOLCHAIN_CACHE=/workspace/Siren-s-Song-gauntlet/work/toolchain scripts/toolchain/headless.sh --script res://tests/thermal_transmission_tests.gd
TOOLCHAIN_CACHE=/workspace/Siren-s-Song-gauntlet/work/toolchain scripts/toolchain/headless.sh --script res://tests/thermal_ui_tests.gd
# Product traces: same common binary fixture, candidate vs original79 source tree.
scripts/toolchain/headless.sh --script "$PWD/work/thermal_product_probe.gd" -- --candidate
godot --headless --path work/baseline-game --script "$PWD/work/thermal_product_probe.gd"
# Actual rendering; baseline substitutes --path work/baseline-game; idle adds --idle.
DISPLAY=:320 LIBGL_ALWAYS_SOFTWARE=1 godot --path game --rendering-method gl_compatibility --audio-driver Dummy --resolution 1280x720 --fixed-fps 15 --script "$PWD/work/capture_thermal.gd" -- --output="$PWD/work/thermal-motion/challenger-wait12"
ffmpeg -framerate 15 -i work/thermal-motion/challenger-wait12/frame-%04d.png -c:v libx264 -crf 19 -pix_fmt yuv420p challenger-wait12.mp4
```

Reference: originalv7's cold band reduces enemy detection, whereas this intentional adaptation changes mutual acoustics/passive reception while retaining visible beam sight. Official [Cold Waters manual](https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/541210/manuals/Cold_Waters_Operations_Manual_107.pdf), printed29–31, supports mutual shadow/close-range penetration as design research; downloaded original SHA79a0c558529fdb14c839ca9fb1b22e34044d3ac6023bda16d116df345c52e815 retained ignored. No matched thermal footage/current store verification/play recommendation. Godot Area2D is not used because dictionary/fixed-step actors need no second physics engine.
