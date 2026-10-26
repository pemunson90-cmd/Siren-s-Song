# Siren's Song — Android / Galaxy Z Fold7 playtest

## Deferred reference, not a current testing request

Pat prohibits APK builds and defers phone testing until feature complete and bug
free. Do not build, install, dispatch Android workflows or ask Pat to test during
the cloud-to-desktop transition. Current state is [RESUME](RESUME.md); Windows
recovery is [DESKTOP_HANDOFF](DESKTOP_HANDOFF.md). The procedure below applies
only after a later explicit Pat instruction. No current accepted APK run is
identified by CONTINUATION.

## Select a later authorized build

After Pat authorizes that stage, record the accepted source SHA and exact Android workflow run in RESUME or its linked handover. Select that run from the [production Android workflow](https://github.com/pemunson90-cmd/Siren-s-Song/actions/workflows/android-validation.yml?query=branch%3Agauntlet%2Fproduction), verify its branch, source and checks, and use its named artifact. The newest run alone is insufficient. Package extraction/install instructions belong to that later authorized handover.

For an update without losing saves, require the same development signing certificate SHA256: `32bcb2287acd01c1f58c26997c7639f3072c74c6b03ab2a24656dc7cd1c7dc3c`. Compare the artifact's `apk-signature.txt`. If the update fails, record the Android error before uninstalling; uninstall can delete local campaign state. The stable debug signing identity is documented in `scripts/toolchain/signing/README.md`.

## Hands-on acceptance

- **Cover landscape:** open a mission paused; verify readable information and controls around the cutout, touch/drag chart, pinch and +/- zoom, FIT, and tap-to-plot without accidental orders.
- **Tactical planning:** select Quietus and both drones, queue and edit waypoints, configure speed/stop behavior where available, inspect selected craft and route intent, use PLAN ROUTE and RETURN/EXTRACT, and confirm that pausing never spends time/resources.
- **Stealth tools:** try active sonar, decoy, disruption and the single-target knockdown when equipped. Confirm feedback, cost, range/target selection, exposure and recoverable mistakes are understandable without hunting through menus.
- **Fold/unfold and resume:** change between cover/inner while paused, rotate back to landscape, background the app, cold reopen and resume the active mission. Check craft routes, records and resources.
- **Actual experience:** assess thumb comfort, latency, legibility, audio/dread, mission information payoff, and whether the deliberate challenge comes from controlling a submarine rather than from interface friction.

Report the exact build/run SHA, phone configuration, actions taken and what appeared wrong; screenshots help with specific layout failures. The main Gauntlet remains responsible for deciding and building the next meaningful gameplay improvement.
