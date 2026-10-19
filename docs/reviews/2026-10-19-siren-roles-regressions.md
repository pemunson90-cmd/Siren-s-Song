# Role restoration: independent regression and experience review

19 October 2026. Requested model: Sol 6.1; actual backend/cost telemetry unknown. No nested agents. Exact comparison: corrected patrol baseline **8d8635a → ec2aa08**. The accepted native APK f1ea536/runtime92625ac is earlier and contains inherited patrol stalls; density WIP 2fc0976 is excluded. This bounded review does not end the Gauntlet.

**Verdict: no consequential new regression confirmed.** The challenger restores purposeful station roles with physical response, search and return while preserving the tested sensing/lock/disruption rules. It changes the tactical problem, especially in the Well. Local evidence supports advancing this source to native validation; native, human and external-footage evidence remain separate gates.

## Actual evidence inspected

Inspected timestamped frames from all three actual 16-second, 30 fps, 1280×720 desktop Godot clips **before reading their setup explanation**. Samples every three seconds plus early-contact samples are retained in [fresh-review](../validation/production/siren-roles/fresh-review/). This was sampled sequence inspection, not a claim to have watched every frame or assessed the audio.

- [Passive patrol](../validation/production/siren-roles/clips/passive-patrol.mp4): the live contact changes position between 0.67 and 1.67 s; by 6 s it is a stationary LAST SEEN echo whose age increases. This proves a brief visible patrol passage, not visible circulation throughout the clip. Ordinary silent setup movement and simulation pre-roll precede the no-input interval.
- [Occluded lure](../validation/production/siren-roles/clips/occluded-lure-response.mp4): HUNTER changes DORMANT→INVESTIGATE and visibly moves south at 0–1.5 s; at 3 s it is already memory. A different live PATROL appears around 9–12 s. These are distinct observations. No visible hunter return is established.
- [Exposed lure loss](../validation/production/siren-roles/clips/exposed-lure-loss.mp4): fresh warning reads 3.4 s at 2 s and 1.4 s at 4 s; firing damages hull by 6 s, with loss by 12 s. No evasive input follows setup. This makes the consequence of remaining exposed readable; it does not establish that escape is impossible.

Checked rejected-setup provenance/logs, original v6/v7 role branches, local actual-v7 sampled sequence/runtime provenance, and the selected factory/split-channel concepts plus ray/serpentine references. Current role labels help identification; changing proportions on a common ray texture is a modest visual distinction, not the full silhouette ambition of the concepts. Neither concept art nor hidden diagnostic positions prove observed motion.

## Reproduced findings

All fresh probes used `git archive` snapshots, never the live working tree. [Source hashes](../validation/production/siren-roles/fresh-review/source-sha256.json) identify every archived source file; rehashing after execution found no source changes. Godot 4.6.3 stable, official `7d41c59c4`.

| Check | Exact result | Classification |
| --- | --- | --- |
| Common cover/hearing/last-known/lock probe | 8/0 on both 8d and ec2 | No measured sensing regression |
| Actual-terrain station stimulus/pursuit replays | ec2: 18/0 station, 24/0 pursuit; physical return, fresh warning after EMP, no tested 12-unit body penetrations | Supports intended roles; fixtures are diagnostic |
| Ordinary Well diversion | Silent route to (640,850), settle, decoy at (800,850), route home (140,800): ec2 INVESTIGATE→SEARCH→RETURN→DORMANT in **35.73 s** after decoy; 100 hull, no visual target ticks, one decoy, no EMP; maximum home excursion 326.83 | Real physical return through ordinary simulation commands; not visible-return footage |
| Save during that search | Restore remains paused, then deterministic resumed Siren state; same check also succeeds on 8d | No reproduced save/recovery regression |
| 600-second actual Well clearance | Patroller 0 spends **28.05 s** inside the 24-unit planning margin on both snapshots, identical first position/travel; zero actual 12-unit body penetrations for all three actors on both | Stronger planning-margin weakness is inherited, not a new body collision |
| Exact snapshot core suites | 8d 204/0; ec2 233/0 | Supporting executable coverage, not experience scores |

**Confirmed misleading feedback, inherited and separately fixed:** silently route to (600,600), settle, decoy at (800,850), wait. Both snapshots emit “Autopilot stopped…” at simulation **14.95 s**, while Quietus has no route and zero speed. The shared enemy movement routine can write player-facing collision feedback. The footage therefore gives the player an incorrect explanation, but this is not introduced by roles. The ec2→**7ff53af** production delta suppresses only enemy collision reporting and adds read-only native diagnostics/target metadata. Repeating the same independent protocol on exact 7ff removes the warning and preserves every recorded safe-return transition, position and timing. No remaining integration blocker was reproduced.

## Deliberate tradeoffs

The Well hunter now waits at home without stimuli, matching actual v7, rather than patrolling. Foundry sentinels intentionally guard stations; their tether permits a live lure to draw them out. These stationary states differ from unreachable-goal stalls. The two unchanged Well patrols retain identical 600-second movement against corrected 8d.

Station roles now pursue visible distant targets using terrain paths and brake at emitter standoff. Production retains its four-second current-sight lock and terrain sensing rather than copying v7 straight-line overlap. Patroller visual standoff remains a departure from v7, inherited from 8d.

Retained policy logs show old Well disruption approaches losing; a considered diversion/optical approach remains viable. Lower hull or failure of former scripts is not independently a defect. Do not slow or deafen the hunter to restore old scores. Legacy saves intentionally retain their existing mission/type content; new roles arrive on new dives.

## Biggest remaining gap and limits

**Make the diversion's acoustic risk learnable in the player view.** In the occluded sequence a decoy draws the hunter away, then another patrol arrives while the hunter becomes an aging echo. The live-role labels and beam countdown explain immediate danger better than they explain which exposure invited it or how long the lure remains active. A bounded next improvement is persistent decoy remaining-life/acoustic feedback and clearer explanations of known noise sources, validated with the same safe and losing choices. Preserve sensor uncertainty; do not disclose unseen actors or their hidden return state. A visible, legitimately observed search/return encounter would improve experiential evidence substantially.

The inspected clips are recognizable, labeled Siren's Song and were never blind. **Barotrauma enemy/sonar comparison remains pending**: [official source/access record](../validation/reference-footage/SOURCES.json) contains metadata but no inspected shipped motion. Door Kickers planning and Mark of the Ninja detection/noise comparisons also have no verdict here. Local actual v7 supplements movement reference; it does not replace those benchmarks. No current-store play recommendation, physical Fold7 comfort, native role performance, human discovery rate, full-campaign human completion or audio-quality conclusion is established by this review.
