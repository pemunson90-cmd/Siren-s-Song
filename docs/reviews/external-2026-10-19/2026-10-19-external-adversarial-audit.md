# Siren's Song Gauntlet: independent adversarial audit

## Provenance

| Field | Value |
| --- | --- |
| Date | 2026-10-19 |
| Auditor | Claude Opus 5.5 (Anthropic), external to the Gauntlet. Not Sol 6.1, not Codex. |
| Commissioned by | Pat O'Sullivan (repository owner), via the "Independent Adversarial Audit" brief |
| Repository | `pemunson90-cmd/Siren-s-Song`, branch `gauntlet/production` |
| Audited source | `92625ac` (touch challenger head). Re-fetched before writing: branch had moved to `f1ea536`. Those five commits touch docs, tests and the touch-regression report only; `game/src` is byte-identical, so every code finding holds at `f1ea536`. |
| Engine used for reproduction | Official Godot `4.6.3.stable.official.7d41c59c4`, Linux x86_64, headless |
| Repository writes by auditor | None. All probes ran in a separate scratch copy. |
| Mode | Read-only. No pushes, PRs, CI triggers or interference with the running Gauntlet. |

Everything below is the auditor's analysis. No sentence in this document is the owner's words or a decision by the owner. Observations, inferences and recommendations are labeled where the distinction matters.

### What was inspected

- Governance: `AGENTS.md`, `docs/architecture/GAUNTLET.md`, `docs/WORKBENCH.md`, `docs/CONTINUATION.md`, `docs/BASELINE_AND_EXPERIMENTS.md`, `docs/PHONE_DASHBOARD.md`, `docs/MODEL_USAGE.md`, `docs/AGENT_BRIEF.md`, `docs/START_HERE.md`.
- Reviews: `docs/reviews/2026-10-19-baseline-critique.md` (headline and grep), `2026-10-19-integrated-experience-critique.md` (full), `2026-10-19-cold-foundry-critique.md` (full), and after re-fetch `2026-10-19-touch-regressions.md` (headline).
- Source: `game/src/simulation/simulation.gd` (full), `game/src/campaign/missions.gd` (full), `game/src/presentation/layout_metrics.gd`, targeted reads of `game/src/main.gd`.
- Tests: `game/tests/run_tests.gd`, `campaign_scenarios.gd`, `core_scenarios.gd` (full); suite execution of `run_tests.gd` and `runtime_tests.gd`.
- Images viewed: `docs/validation/android-39202066103/inner-camera-exposure.png`, `docs/validation/production/touch/cover-fit.png`, `docs/validation/production/foundry/response.png`.
- CI config: `.github/workflows` (native-smoke job).
- External: Samsung Galaxy Z Fold7 display specifications (sources at end).

### What was not inspected

- GitHub Actions runs and artifacts. The Actions API required credentialed access this session did not have. Runs `39202066103` and `39204224960` were not inspected directly; only their repo-retained copies under `docs/validation/android-*` were available.
- The APK was not installed. No emulator or physical Fold7 play.
- Audio was not listened to. The three MP4s (`response-live.mp4`, `navigation.mp4`, `loop-audition.mp4`) were not viewed.
- Roughly 27 of about 30 retained captures were not viewed.
- No human playtest data exists to inspect.

---

## 1. Executive verdict

The engineering half of the Gauntlet is healthy and unusually honest. The tests reproduce, native Android evidence is real for one mission, and failed experiments are kept rather than buried.

The game half is less advanced than the documentation implies, because of a blind spot the process cannot see: **most Sirens never move.** Every balance number, solver win and difficulty judgment to date was measured against sentries frozen at their spawn points. None of the three critics caught it, because every probe (including this auditor's, until the enemy was watched directly) measured the player's route and never the enemy unprovoked.

Overall: credible as a reliable implementation of a tactical framework. Weakly credible as evidence of a game with tension. Fixable cheaply, and the fix will invalidate most existing balance readings.

## 2. Verified achievements

Reproduced or confirmed directly by the auditor.

- **Suites pass independently.** `CHECKS 88 FAILURES 0` and `RUNTIME CHECKS 225 FAILURES 0` at `92625ac` on a clean import with official Godot 4.6.3.
- **Architecture matches its claims.** The simulation is display-free, runs on a fixed 60 Hz step and clamps per-call dt to 0.25 s. Pause freezes every clock. Restore validates structure before activation. Commands never advance time.
- **Cold Foundry is genuinely authored.** The factory `structures` rect is used by both `blocked()` and `line_clear()`, so movement and sight agree with the drawing (confirmed in code). It has two distinct optical records, a prerequisite with an in-fiction reason, and a carrier response that emits a real noise event rather than a scripted spawn.
- **Split Channel has a real coordination puzzle.** Two separated relays plus a Quietus-only uplink gated on both.
- **The native PCM crash was diagnosed causally.** Off-by-one at the loop endpoint (index 176400 vs final frame 176399), with a red-to-green test. Genuine debugging.
- **Evidence discipline is good.** Desktop captures are labeled not-Samsung. Rejected experiments are retained (the redundant Foundry decoy, the worse lower-channel detour). The docs repeatedly refuse to equate passing checks with quality.
- **The critics are competent.** The integrated critique independently found inert oxygen, inert upgrades, generic missions and unimplemented brief promises. Most content gaps below were already on record.

## 3. Adversarial findings, ranked

### F1. Siren patrols stall permanently

Severity: **high**. Confidence: **high** (reproduced).

**Observation.** Each mission run for 600 simulated seconds with no player input, tracking each Siren's longest continuous stationary interval:

| Mission | Sirens | Stationary for essentially the whole run |
| --- | --- | --- |
| 1 Shelf Signal | 1 | 0 |
| 2 Split Channel | 2 | 1 (581 s) |
| 3 Blackwater Relay | 2 | 1 (600 s) |
| 4 Cold Foundry | 2 | 2 (585 s, 600 s) |
| 5 The Listening Well | 3 | 2 (600 s, 600 s) |
| 6 Siren's Song | 3 | 2 (589 s, 569 s) |

8 of 13 Sirens are frozen. The others creep slowly near home.

**Mechanism** (`simulation.gd`, `_threats`):

1. The patrol goal is `home + (sin(elapsed/19 + patrol)*190, 70 + cos(elapsed/27)*65)`.
2. This regularly lands inside rock or out of bounds. Examples: Listening Well S0 gets goal (620,265) against a rock top at y=280; Foundry S1 gets (1480,955), which is outside bounds.
3. `path()` returns `[]` when the goal is blocked at 24 px clearance.
4. A new goal is picked only when the Siren comes within 35 px of the old one, which never happens.
5. The Siren sits until a noise or sighting overwrites its goal.

Diagnostic trace excerpt (auditor probe, see appendix):

```
m5 t=40.0 s0 pos=(620.0, 130.0) goal=(620.0, 265.0) route=0 mode=PATROL goal_blocked24=true dist=135.0
m5 t=40.0 s2 pos=(1160.0, 130.0) goal=(1333.0, 265.0) route=0 mode=PATROL goal_blocked24=true dist=219.0
m4 t=40.0 s1 pos=(1320.0, 820.0) goal=(1480.0, 955.0) route=0 mode=PATROL goal_blocked24=true dist=209.0
```

**Impact (inference).** The Listening Well's "mobile hunter patrols the inner water" is two statues and one slow drifter. Cold Foundry's guards are fixed turrets. All six fallback wins, the Split Channel 87.1% vs 100% decoy comparison, and the Foundry 34.2 s staged route were measured against this behavior. They remain valid only for the current bug state.

### F2. One generic policy solves the campaign; silent running is strictly dominant

Severity: **high**. Confidence: **high**.

**Observation.** The fallback test (`campaign_scenarios.gd`) uses one heuristic for all six missions: park 210 px south of each objective (or 210 px west if blocked), camera, auto-EMP on any observed lock over 1 s, extract. Auditor variants, endurance loadout, no drones:

| Mission | No EMP, silent | No EMP, cruise |
| --- | --- | --- |
| 1 | won 64.0 s, hull 100% | lost 28.0 s |
| 2 | won 78.0 s, hull 33.7% | lost 29.3 s |
| 3 | lost 49.4 s | lost 16.1 s |
| 4 | lost 50.5 s | lost 20.6 s |
| 5 | lost 31.5 s | lost 18.7 s |
| 6 | won 82.1 s, hull 100% | lost 19.1 s |

With finite reactive EMP (the repo's own fallback test), all six win; five of six at 100% hull.

**Inference.** The tactical space currently collapses to two rules: always run silent, and spend EMP when locked. With static sentries, route choice reduces to approaching from the side the sentry cannot see. Losses in missions 3 and 5, which critics read as "real threat," come from parking spots near statues.

### F3. Oxygen, battery and progression are inert

Severity: **medium-high**. Confidence: **high**.

- **Oxygen** drains `dt/18`: 100% lasts 1800 s (30 minutes). Missions are solved in 34 to 82 s, using 3 to 5%. The endurance upgrade's +20 buys six irrelevant minutes.
- **Drone battery** drains `dt/14`: about 1400 s. Also irrelevant at mission length.
- **Loadout** is a free `CYCLE LOADOUT` button available from mission one (`main.gd:230`). `GAUNTLET.md` specifies that "progression rewards evidence with equipment choices." Nothing is earned.

The integrated critic flagged oxygen and loadouts. No cycle acted on them.

**Design question for the owner (not resolved here).** "Slow oxygen pressure" is a confirmed requirement, and "avoid frantic play" is a stated preference. Slow pressure at a 2 to 5 minute mission scale could satisfy both.

### F4. Four of six missions are one template

Severity: **medium**. Confidence: **high**.

Missions 1, 3, 5 and 6 share: three rectangles each, the same spawn and the same extraction at (140,800), Siren homes on the same row `(620 + n*270, 130)`, and generic SIGNAL SPIRE / RELAY MOUTH / ARCHIVE NODE objectives with a 4 s exposure. Every rock in the game is the same 12-point polygon scaled (`rock_polygon`), visible in the Shelf Signal capture.

Briefs promise mechanics that do not exist: Blackwater's relay chain, the Listening Well's mobile hunter and sustained observation, the finale's transmission/outbound vector.

Trajectory: two of six missions authored after five cycles.

### F5. Touch targets are below Android's physical minimum

Severity: **medium**. Confidence: **medium** (computed from specs, not measured on device).

All buttons are 48 logical px (`main.gd:87`), with `canvas_items`/`expand` stretch from a 1280×720 base (`project.godot`). Fold7 panels per Samsung: cover 6.5" at 2520×1080, inner 8.0" at 2184×1968.

| Screen | Stretch scale | 48 logical px becomes | Density (computed) | Physical height |
| --- | --- | --- | --- | --- |
| Cover | 1.5× (1080/720) | 72 px | ≈422 ppi | **≈4.3 mm** |
| Inner | ≈1.71× (2184/1280) | ≈82 px | ≈368 ppi | **≈5.7 mm** |

Android's 48 dp minimum is about 7.6 mm. Cover controls are roughly 57% of the guideline; inner controls roughly 75%. The touch work treats logical 48 px as if it were 48 dp. The Foundry critic warned against exactly that, but the arithmetic was not done. This is a deterministic check needing no device.

### F6. The tests verify absence, not presence

Severity: **medium**. Confidence: **high**.

The suite is strong on negative invariants: no leak through cover, pause changes nothing, stunned Sirens cannot lock, malformed saves rejected. It has zero liveness assertions: nothing checks that Sirens patrol, that resources deplete meaningfully, or that a loadout changes any outcome. That gap is why F1 and F3 survived 88 plus 225 green checks.

Check counts also grow partly through per-waypoint loops (`for p in route: t.check(...)` in `core_scenarios.gd`). The workbench discloses this, so it is not deceptive, but count is a poor progress signal.

### F7. Critic monoculture

Severity: **low-medium**. Confidence: **medium**.

Every critic and the builder are Sol 6.1 (requested routing per `MODEL_USAGE.md`). Every critic evaluated threat through scripted player-route probes. Fresh context removes builder contamination but not shared method. Each critic's top recommendation became the next cycle (Foundry, then touch). That is good responsiveness, and it also means the program converges wherever the critics' lens converges.

### F8. Documentation overhead

Severity: **low**. Confidence: **high**.

- Gauntlet-authored markdown under `docs/` (excluding `source-import/`) plus `AGENTS.md` is about 250 KB, against 79 KB of game source.
- The Persistent Gauntlet mandate is duplicated verbatim in `AGENTS.md`, `GAUNTLET.md` and `CONTINUATION.md`.
- `MODEL_USAGE.md` devotes most of its text to restating that telemetry is unavailable.
- Prose is compressed past readability ("88core/225runtime", "Actions39202066103"), which hurts the phone dashboard the owner is meant to read.

### F9. Trajectory is short

Severity: **context**. Confidence: **high**.

Commit timestamps place all production game source between 03:03 and 05:21 UTC on 2026-10-19. Commits may be batched pushes, so actual working time is unknown. Either way, "five cycles" is one burst, and early-vs-recent comparison cannot yet establish a sustained improvement trend.

## 4. Evidence gaps

- **CI runs.** Actions API not accessible; native claims for runs `39202066103` and `39204224960` rest on repo-retained copies.
- **Physical device.** No APK install, emulator play or Fold7 play.
- **Audio.** Not listened to; MP4s not viewed.
- **Human comprehension.** No one outside the build loop has played it.
- **Post-fix balance.** Every existing balance number becomes unknown once F1 is fixed.

## 5. Workflow assessment

**Working:** builder/critic separation with images-first review; red-to-green discipline; baseline/challenger ratchet; retained counterexamples; sole-pusher coordination around `cancel-in-progress` CI; honest telemetry labeling; restraint on premium-model use.

**Wasting effort:** documentation restatement (F8). Native fixture plumbing took a large share of commits; it was necessary once and is now done.

**Stagnation risk:** the loop optimizes what its probes measure, and its probes measure player routes against a world nobody watches. Cycles keep landing on UI, audio plumbing and reliability because those produce clean evidence, while enemy behavior, the resource economy and mission identity stay untouched.

## 6. Game-design assessment

Primarily a more reliable implementation. The two genuine design gains, Split Channel's dependency structure and Cold Foundry's authored revelation, are good. Everything else improves the instrument panel around a world whose threats do not act.

Creative ambition is not rising with technical reliability. The touch cycle was user-directed and correct; the next one should not be more interface.

The creative grant is adequate, with no harmful constraints found. The binding limits are inherited prototype structure: one patrol formula, one rock shape, one objective template. None of these are rules; they are simply still the code.

## 7. Recommended interventions

Ordered by benefit over cost and disruption.

1. **Fix patrol stalls and recalibrate.** Cost: tiny. Disruption: high, intentionally. Re-pick the goal when `path()` returns empty and reject blocked goals at generation. Then rerun every retained strategy and critic probe, and treat the result as a new baseline rather than a regression. Better: give each mission authored patrol routes so "mobile hunter" becomes a design object.
2. **Add liveness assertions.** Cost: small. Each unprovoked Siren covers at least X m in T s; every patrol goal is reachable; each loadout changes at least one scripted outcome; resources reach a defined fraction by mission end. This closes the hole F1 and F3 fell through.
3. **Add a fixed naive-policy panel per cycle.** Cost: seconds of CPU, no model calls. Policies: silent plus auto-EMP, cruise, no-tools, rush. Flag any mission a generic bot wins at 100% hull as undifferentiated, and any binary choice one bot always wins as dominant. This is the one added measurement recommended, because it already exposed F2.
4. **Physical touch-size gate.** Cost: trivial. Assert logical size × stretch scale ÷ density of at least 7.5 mm for cover and inner profiles. Fold it into the touch challenger before promotion.
5. **Resource and progression decision (owner's call).** Make oxygen bite at mission scale or remove it from HUD and loadouts. Tie loadouts to recovered evidence as `GAUNTLET.md` already specifies.
6. **Mission identity pass for 3, 5 and 6 on the Foundry template.** Start with the Listening Well hunter, which F1's fix feeds directly. Replace the single rock polygon with authored geometry.
7. **Rotate critic lens rather than adding critics.** `AGENTS.md` already names Claude Code for independent reviews, so occasionally routing the critic slot there adds a different model family at zero new process. Give one critic per cycle a "watch the world" brief: enemy behavior over time without the player.
8. **Owner's 20 minutes on the Fold7** once F1 is fixed. One session answers comprehension, comfort and tension questions no probe can. This is the invitation step the mandate already defines, not supervision.
9. **Doc compaction.** State the mandate once and point to it. Write the dashboard in readable sentences.

## 8. Next audit triggers

- F1 fixed and all retained strategies rerun; compare old and new numbers.
- Any loadout or economy change.
- The first of missions 3, 5 or 6 rebuilt.
- The first physical Fold7 session (owner notes or recording).
- Touch challenger promotion to baseline.
- Two consecutive cycles with no simulation or campaign source diff (stagnation signal).

---

## Appendix A: reproduction

Commands run from a scratch copy of the repository at `92625ac`:

```sh
G=Godot_v4.6.3-stable_linux.x86_64
cd game
$G --headless --path . --editor --import --quit
$G --headless --path . --script res://tests/run_tests.gd      # CHECKS 88 FAILURES 0
$G --headless --path . --script res://tests/runtime_tests.gd  # RUNTIME CHECKS 225 FAILURES 0
$G --headless --path . --script res://audit/probe.gd
$G --headless --path . --script res://audit/freeze.gd
```

Note on `probe.gd`: `Simulation.advance()` clamps each call to 0.25 s. The first idle-oxygen loop (`advance(1.0)` × 4000) therefore covered only 1000 s and printed a meaningless line; the second loop, bounded by `elapsed`, gives the correct 1800 s oxygen exhaustion. The freeze and policy probes use `advance(0.1)` and are unaffected.

### `game/audit/probe.gd`

Cleaned from the executed version: the faulty first idle loop, an unused variable and a message-collection diagnostic were removed. Policy, oxygen and stall logic are identical to what ran.

```gdscript
extends SceneTree
const Simulation = preload("res://src/simulation/simulation.gd")
var emp_policy := true
func move(s, point: Vector2) -> bool:
	if not s.command("route",{"point":point}): return false
	s.paused=false
	for n in 2600:
		s.advance(0.1)
		if emp_policy:
			for c in s.contacts.values():
				if c.lock>1.0 and s.tools.emp>0: s.command("emp"); break
		if not s.outcome.is_empty(): return s.outcome=="won"
		if s.units[0].pos.distance_to(point)<20 and s.units[0].vel.length()<2: return true
	return false
func run_policy(id:int, upgrade:String, use_emp:bool, drones:bool, cruise:bool) -> String:
	emp_policy=use_emp
	var s=Simulation.new(); s.start(id,upgrade)
	if not drones: s.units[1].alive=false; s.units[2].alive=false
	if cruise: s.units[0].silent=false
	var ok=true
	for target in s.mission.objectives:
		var v=target.pos+Vector2(0,210)
		if s.blocked(v,25): v=target.pos+Vector2(-210,0)
		if not move(s,v): ok=false; break
		if not s.command("camera"): ok=false; break
		for n in int((target.get("duration",4.0)+0.5)*10): s.advance(0.1)
		if not target.captured: ok=false; break
	if ok: ok=move(s,s.mission.extraction)
	return "m%d %s emp=%s cruise=%s -> %s t=%.1f hull=%.1f o2=%.1f tools=%s" % [id+1,upgrade,use_emp,cruise,s.outcome if s.outcome!="" else "stalled",s.elapsed,s.hull,s.oxygen,s.tools]
func _initialize():
	for id in 6:
		print(run_policy(id,"endurance",false,false,false))
		print(run_policy(id,"endurance",false,false,true))
	var s=Simulation.new(); s.start(0,"survey"); s.paused=false
	while s.outcome=="" and s.elapsed<4000: s.advance(1.0)
	print("IDLE base oxygen-death seconds=",s.elapsed," drone battery=",s.units[1].battery," alive=",s.units[1].alive)
	for id in 6:
		var q=Simulation.new(); q.start(id,"endurance"); q.paused=false
		var last=[]; var stuck=[]; var maxstuck=[]
		for si in q.sirens.size(): last.append(q.sirens[si].pos); stuck.append(0.0); maxstuck.append(0.0)
		for n in 6000:
			q.advance(0.1)
			for si in q.sirens.size():
				if q.sirens[si].pos.distance_to(last[si])<0.5: stuck[si]+=0.1
				else: stuck[si]=0.0
				maxstuck[si]=maxf(maxstuck[si],stuck[si]); last[si]=q.sirens[si].pos
		print("m",id+1," sirens=",q.sirens.size()," longest stationary run (s)=",maxstuck)
	quit()
```

### `game/audit/freeze.gd`

```gdscript
extends SceneTree
const Simulation = preload("res://src/simulation/simulation.gd")
func _initialize():
	for id in [1,3,4]:
		var q=Simulation.new(); q.start(id,"endurance"); q.paused=false
		for n in 400:
			q.advance(0.1)
			if n%100==99:
				for si in q.sirens.size():
					var s=q.sirens[si]
					print("m",id+1," t=",snappedf(q.elapsed,0.1)," s",si," pos=",s.pos.round()," goal=",s.goal.round()," route=",s.route.size()," mode=",s.mode," goal_blocked24=",q.blocked(s.goal,24)," dist=",snappedf(s.pos.distance_to(s.goal),1))
	quit()
```

### Probe output

The `tools=` column is omitted and the oxygen and stall values are rounded to one decimal. Results are otherwise as printed.

```
m1 endurance emp=false cruise=false -> won t=64.0 hull=100.0 o2=116.4
m1 endurance emp=false cruise=true -> lost t=28.0 hull=0.0 o2=118.4
m2 endurance emp=false cruise=false -> won t=78.0 hull=33.7 o2=115.7
m2 endurance emp=false cruise=true -> lost t=29.3 hull=0.0 o2=118.4
m3 endurance emp=false cruise=false -> lost t=49.4 hull=0.0 o2=117.3
m3 endurance emp=false cruise=true -> lost t=16.1 hull=0.0 o2=119.1
m4 endurance emp=false cruise=false -> lost t=50.5 hull=0.0 o2=117.2
m4 endurance emp=false cruise=true -> lost t=20.6 hull=0.0 o2=118.9
m5 endurance emp=false cruise=false -> lost t=31.5 hull=0.0 o2=118.2
m5 endurance emp=false cruise=true -> lost t=18.7 hull=0.0 o2=119.0
m6 endurance emp=false cruise=false -> won t=82.1 hull=100.0 o2=115.4
m6 endurance emp=false cruise=true -> lost t=19.1 hull=0.0 o2=118.9
IDLE base oxygen-death seconds=1800.0 drone battery=0.0 alive=false
m1 sirens=1 longest stationary run (s)=[9.9]
m2 sirens=2 longest stationary run (s)=[581.0, 9.9]
m3 sirens=2 longest stationary run (s)=[9.9, 600.0]
m4 sirens=2 longest stationary run (s)=[584.9, 600.0]
m5 sirens=3 longest stationary run (s)=[600.0, 9.9, 600.0]
m6 sirens=3 longest stationary run (s)=[588.8, 568.7, 13.5]
```

## Sources

- [Samsung: display size and resolution of Galaxy Z Flip7 and Z Fold7](https://www.samsung.com/sa_en/support/mobile-devices/what-is-the-display-size-resolution-of-galaxy-flip-7-galaxy-fold-7/)
- [Google Fi: Galaxy Z Fold7 specs](https://fi.google.com/about/phones/samsung-galaxy-z-fold7-specs)
- Pixel densities are computed from Samsung's stated diagonal and resolution; Samsung does not state ppi on the cited page.
