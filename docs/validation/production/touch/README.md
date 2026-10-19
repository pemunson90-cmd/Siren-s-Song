# Touch navigation challenger

Baseline93b8631 remains the promoted native checkpoint. This challenger adds anchored1–4×zoom, clamped drag pan,−/+/FIT controls, route-on-short-release and explicit gesture cancellation. It changes presentation/input only; simulation, mission and audio source trees match93b8631 byte-for-byte.

Actual desktop captures: cover2520×1080 and unfolded2184×1968, `*-fit.png`, `*-zoom.png`, `inner-advanced.png`. The same ordinary-command Cold Foundry state is replayed at23.9s/100% hull, mid-cradle exposure, before optional chart zoom/pan. Baseline comparable view is `../foundry/cradle.png`; previous unfolded response crowding is `../foundry/inner-response.png`. These are not OS-touch/Samsung captures. `capture_touch.gd -- --view=zoom|fit|advanced` reproduces them through the standard capture tool.

`navigation.mp4` is seven seconds of actual production rendering with **synthetic Godot** mouse/touch events: + twice, drag chart, FIT, open and close MORE ORDERS. Recorded SS_VIEW values:1.4,1.96, center1028.263/646.8071, then FIT1/800/480. Zero new SS_ORDER events occur. Mission stays tactically paused; the video is not a winning run or evidence of OS multi-touch. Driver: `game/tests/capture_touch_movie.gd`; raw210frames/WAV under `build/captures/touch-navigation-movie/`. Capture teardown still has the known audio-flush warning, separate from fixed native PCM overrun.

## Supported gains and tradeoffs

- At useful local zoom, craft and physical geometry can be inspected; FIT recovers full-map planning. Camera movement never expands sensor range or advances paused simulation.
- Fresh permitted threat source/target/countdown rows occupy a reserved screen area instead of covering the cradle. World source IDs and beam lines preserve the spatial connection. Nonselected craft use Q/A/B labels; selected station retains its name. Recovered markers quiet their redundant text.
- Camera/sonar/silent/route intent/hold/disruption/emergency/operations remain primary. Survey, decoy, conditions and STOP/PASS are behind MORE ORDERS. They require an extra disclosure tap; unlimited pause and emergency access remain available. Human discovery/comfort is not established by these captures.
- Short tap commits on release. Drag/pinch/OS cancellation, third finger, release outside map, HUD crossing, suspend and layout changes cannot become accidental routes. Touch-emulated mouse duplication cannot append a second queued waypoint. A cutout-inset root uses one global coordinate space across press/release.
- A zoomed viewport can crop distant geometry/labels; overview recovery is explicit. Further edge-label handling and physical-phone comfort remain review opportunities, not certified quality.

## Verification and retained counterexamples

`candidate-green.log`: updated production test.sh passes8 native-parser guards plus88core/campaign and225runtime checks, zero failures/script errors. All six ordinary fallback and actual-pointer campaign progression still pass. Current tests include real viewport input events, not mocked command implementations.

RED evidence is retained: missing camera capability (`camera-red.log`), unsafe local/global cutout mapping (`inset-red.log`), missing secondary-order disclosure (`disclosure-red.log`), OS-canceled route commit and HUD-finger chart pinch (`cancel-red.log`). These were corrected before candidate promotion; keeping them records what went wrong, not a claim of unresolved failures. Earlier green stage logs remain historical.

Independent regression hunt against93b8631 and actual candidate output is complete: no consequential newly broken behavior reproduced. Full8/88/225check run and52candidate/18shared-baseline extra assertions passed; production independently reran the retained52assertion probe with the same result. See `../../../reviews/2026-10-19-touch-regressions.md` and durable `hunter/` scripts/logs, including rejected raw-touch GUI false-positive. Native OS+/−/swipe/FIT, no-order/no-pause checks, ordinary completion/lifecycle and active audio gate are prepared but not yet run for this challenger. OS pinch and physical Fold7 fingers/folding/performance remain separately open. Do not promote from test count or a new capture alone.
