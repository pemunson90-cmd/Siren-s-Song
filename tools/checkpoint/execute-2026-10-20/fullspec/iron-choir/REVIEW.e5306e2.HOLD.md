# Independent accumulated Iron Choir review — HOLD

Reviewer: /root/release_integration_review, sole independent integration reviewer. Requested routing Sol6.1 Medium; backend/effort telemetry unavailable. Date21 October2026.

**HOLD accumulated head `e5306e246a9205b871c4ff1490eedc8ea8a77e02` against production base `16b1a5052a270f2c6c69b500ed664ec0c3a2a30d`. One confirmed P2 occupied-band acquisition blocker.** Same-builder/same-branch repair and exact-head re-review required. Root owns subsequent mandatory CI/normal PR/protected integration. No formal GitHub approval, CI pass or merge claimed.

## Scope and authority

Read candidate AGENTS/USER_DIRECTIVES first, living specification/current Iron scope, architecture/source authority/V7 parity and external TASK/REPORT; root supplied fresh unchanged production16b boundary and candidate handoffs. Review covers all34 accumulated files, not final documentation-only commit: four core22–25/four optional26–29, physical industrial loads/voyages/locks/tows, new interceptor/warden, fitting/material research, people/plant/first-choice consequences, ordinary onward/replay, current saves and spatial presentation. Glass PR49 acceptance remains closed. Current user preference is substantial new content after this required accumulated integration boundary; no broad old-game refinement or new governance.

Source /workspace/Siren-s-Song-play-frozen, branch gauntlet/release/iron-choir. No tracked source edits, subagents, APK, PR, profile/save migration or original player/signer changes. Independent probes/logs/captures external under iron-choir/independent. Staged poses/access below are explicit technical isolation, not blind play or genuine earned campaign chronology.

## Blocking finding

**P2 — both new roles ignore a legitimately visible craft entering their occupied water band.** `game/src/simulation/industrial_threats.gd::evidence` returns `{pos:u.pos,band:u.band}` after Depth.sight succeeds. During a transition, u.band remains the source band even though Depth.occupied contains both source and destination. `advance` then rejects `received.band != e.band`. A target entering the enemy's band gets the full incoming4s (or sleeve2.5s) without acquisition, despite physical sight and the explicit both-band vulnerability requirement. Existing burst/patch damage checks correctly understand occupied bands; the new acquisition gate does not.

Independent matched authored-terrain reproduction (ordinary depth command, production fixed ticks; other peers removed only to isolate acquisition):

- Operation22 authored MIDDLE interceptor; Q(1550,2200). Settled MIDDLE: Depth.sight=true, windup after0.5s. SHALLOW→MIDDLE depth command accepted; occupied[0,1], Depth.sight=true, but new role remains idle after0.5s.
- Operation23 authored DEEP warden; Q(2400,1200). Settled DEEP: sight=true, windup after0.5s. MIDDLE→DEEP command accepted; occupied[1,2], sight=true, but role remains idle after0.5s.

All four states save-valid. Probe independent/occupied_acquisition.gd/.log: **4checks/2failures, exit1**. It changes only incoming transition versus settled occupancy in each matched pose, not enemy target/phase. Player consequence: the advertised exposed stationary layer change instead delays the new threat's acquisition, changing pressure-sleeve and depth counterplay. This is a current authored consequence, not hypothetical polish.

Repair acquisition to retain the legitimately shared/observed water volume rather than rejecting an occupied destination band. Do not query hidden current target depth after sight is lost or retarget committed aim. Focused regression should cover both incoming transition directions/source+destination occupancy, bare and shortened sleeve transition, legitimate interruption/terrain, partial state restore and preserved frozen-target behavior. Retain current no-overlap rejection and finite snare/EMP/patch clocks. No broader AI redesign required.

## Independent accumulated evidence

Physical freight/receipt/campaign — **35/0**, own independent/voyage_campaign.gd/.log. All8 fresh empty-objective industrial missions fail all_records and cannot auto-extract before actual jobs. In22, local deliberate WEST starts real route; an actual in-flight current snapshot restores. Both original/restored hulls travel over1000m through authored water and reach the same actual dock alive/hull100. With Q back at south/no live peers, hidden arrival gives no receipt/victory and public last fix stays frozen. Bringing Q into local observation earns the real receipt; ordinary settled recovery advances valid campaign22 without changing its earlier ending. Three real23 equalizer jobs each survive selection to a DEEP peer/partial restore and remove actual shutters; only then recovery advances23. Actual26 Q descent/deep winch/ascent/material recovery consumes pressure spindle with returned22 proof, earns one sleeve, cannot farm replay and roundtrips a real checksummed campaign+recovered active envelope. Local access was explicitly staged; freight movement/arrival, timed jobs, depth/custody/extraction/research were not injected.

Worker-local tow/material — **16/0**, own independent/tow_custody.gd/.log. A DEEP drone material winch saves/finishes with a MIDDLE peer selected; actual carrier loss leaves a valid DEEP wreck; wrong-depth Q rejects, same-band Q recovers. A bare B cannot use A's remote yoke; fitted A attaches real ballast, depth change is rejected while towing, ordinary route creates travelled trail. Unselected partial tow saves/restores; pause freezes load/trail; original and restored physical tow move identically in authored water with bounded separation. Actual carrier loss leaves a free unteleported load and valid snapshot. No selected-craft geometry or remote-fitting blocker established.

Enemy lifecycle/fairness — independently reran industrial_threats23/0. Legitimate distant received windup earns a bearing without fabricated contact; aim remains frozen after actual target relocation; committed state saves/pauses; relocation evades burst; warden fields are finite/bounded/saveable and expire; real torpedo and overlapping EMP independently expire for both roles without permanent pin/patch; actual new-role attacks can destroy the NPC hull while Q remains intact. Source review confirms physical burst movement, received stale network evidence, clear-water patch damage and acquired-only pressure presentation. Those passes do not cover the incoming-band defect above. No second confirmed blocker established.

Materials/rewards/consequences — independently reran research13/0: actual material/evidence ledger recipes, consume-once, sleeve physical duration/reserve/emission/slot and occupied transition state, no remote drone sleeve, fitted-only yoke/speed/noise/narrow clearance. Own physical material return above confirms the ledger is reached from real recovery. Inspected all8 factories, prerequisite chain, optional aid/first-fact/replay persistence, modified industrial-only empty-objective validation and gated physical complete_mission. New catalog52/0 and jobs20/0 pass independently. Earlier ending resolver/history rules are unchanged; I did not reopen Glass or rerun its full family journeys. Builder92/0 all8 live-threat bare/no-tools journeys (including aid-free25), first-choice opposite replay, people/plant topology and later actual reward use remain separately attributed REPORT evidence, not my blind/enjoyment assessment.

Representative actual window/input — independently reran UI24/0 on owned Xvfb632/Compatibility software window at2520×1080 and2184×1968,420DPI fixture/no explicit136px inset. ScreenTouch plus emulated mouse traverse actual viewport input: campaign archive23 briefing, craft local equalizer/full touch targets/progress, observed ballast body/tow attach, acquired interceptor windup and visible finite warden field. Six independent PNGs retained; visually inspected cover warden pressure and inner lock progress. Distinct new silhouettes, physical machinery and0% work cue are visible. Functional input/capture evidence is not native ergonomics or novice discoverability; existing rings/readouts still crowd local water.

A source-only content-extension seam remains: new ordinary beam victim selection can choose Choir loads, while contact_target's recipient endpoint still resolves only old Recipient.status. Current Iron authored threats are interceptor/warden/relay, so no present authored beam-warning failure established. Retain this as a narrowly identified future ordinary-beam/load integration risk; it is not a second blocker or request for an old-role audit.

## Exact independent checks

Godot4.6.3, bash login=false, cwd /workspace/Siren-s-Song-play-frozen. For each named suite:

```
XDG_DATA_HOME=/workspace/work/iron-independent-<suite>-xdg timeout --kill-after=10s 120s godot --headless --path game --script res://tests/<suite>.gd
```

iron_choir_tests52/0; industrial_jobs_tests20/0; industrial_threats_tests23/0; iron_research_tests13/0. Own absolute probes use the same command flags with XDG iron-independent-occupied-xdg, iron-independent-voyage-xdg and iron-independent-tow-xdg; script paths are /workspace/work/gauntlet-fullspec-20261020/iron-choir/independent/{occupied_acquisition,voyage_campaign,tow_custody}.gd. Voyage timeout180s; others120s. Results4/2(exit1),35/0(exit0),16/0(exit0). Matching raw logs retained; no script/engine errors.

Rendered command, LD_LIBRARY_PATH=/workspace/tools/display-runtime/usr/lib/x86_64-linux-gnu plus prior value:

```
/workspace/tools/display-runtime/usr/bin/Xvfb :632 -screen 0 3000x2200x24 -nolisten tcp
DISPLAY=:632 LIBGL_ALWAYS_SOFTWARE=1 XDG_DATA_HOME=/workspace/work/iron-independent-render-xdg timeout --kill-after=10s 120s godot --path game --display-driver x11 --rendering-method gl_compatibility --audio-driver Dummy --script res://tests/iron_choir_ui_tests.gd -- --capture-dir=/workspace/work/gauntlet-fullspec-20261020/iron-choir/independent/captures
```

Display readiness checked; owning shell EXIT trap killed/reaped server. rendered-ui.log24/0/exit0, no script/engine errors; software VSync warning is not device evidence. No native/headphone claim. Core758/runtime649/all8 journeys remain builder-attributed, not independently repeated. No full old66-suite regression, profiling or every-route rendered replay; root owns mandatory final-head CI after repair/review.

## Risks and release

Retain all existing inventory risks. Full-hull outside bare policies prove technical viability, not balanced industry pressure, drama, meaningful alternate routing, novice discovery or enjoyment. Crew/plant consequences are real local geometry/current/threat facts, while inhabited identity and narrative payoff remain qualitative expansion. Crowded spatial UI/selection/FIT friction, dense sonar labels, Well balance, inherited ObjectDB/density findings, native lifecycle/device performance, headphone sound, Fold ergonomics and human enjoyment remain open. Further28core/12optional content, fleet/chassis/economy/manufacturing/research depth, production frontend/accessibility/replay/challenges/expeditions/career/audio remain unfinished.

Verified head e5306e246a9205b871c4ff1490eedc8ea8a77e02; tracked source clean, git diff --check passes, generated221UIDs preserved. All reviewer-owned Godot processes exited; Xvfb632 killed/reaped. **Read-only source RELEASED to root for same-builder/same-branch occupied-band acquisition repair.** No second confirmed blocker; consolidated bounded review complete.
