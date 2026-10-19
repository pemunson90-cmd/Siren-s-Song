# Own acoustic emissions, finite decoys, uncertain reception

Bounded challenger to production game at aa022cc (same game as inspected native b809501). Parent docs-only publication11151d3 does not change that baseline. Existing dedicated production checkout is reused; no reset/new worktree, no nested agents. Requested implementation routing is gpt-6.1-sol/high; actual backend/token/cost telemetry is unavailable.

## Player gain and boundaries

A launch message disappears as soon as the pilot selects another station or plots a route. The persistent chart instrument retains each live decoy's remaining transmission life, independently of that log, and reports the pilot's own actual movement/tool emissions. The decoy chart symbol now loses its life arc and has a screen-sized remaining-seconds label. The global summary remains visible if the glyph moves off-chart or overlaps another decoy.

These are known emissions, not reports of reception. The instrument says **Enemy reception unknown** and never reads Siren modes, goals, suspicion or hidden positions. Below-threshold movement does not imply concealment: visual detection, remembered evidence and other emitters remain consequential. Silent mode can leave residual above-threshold motion, and drones can make movement noise.

`Simulation.acoustic_feedback()` returns fresh value dictionaries for audible alive craft, a whitelist of player action pulses and sensor-visible factory responses. Presentation cannot mutate the simulation through it. No AI, physics, sensing, resource, duration, command or save-schema changes. The inherited factory-response world marker is now gated by actual source visibility rather than drawing every enemy noise behind fog. Active SURVEY intentionally makes the whole chart sensor-visible under the existing production rule; the correction does not override it.

## Actual v7 comparison

Inspected reference/original-prototype/MANIFEST.md and actual v7 code: decoyLife7s, tap-to-place decoy, blue pulsing point (no countdown), decoyPull320. Movement uses sub silent?0:(speed/maxSpeed)^2, noiseHearMax360 and a corresponding live filled/dashed footprint only while engines are live. Direct sight supersedes lure. Those are working implementation references, not silently adopted balance numbers.

Production retains its15s finite1100-radius DECOY event, default selected-craft placement160m to its right, and action-noise attenuation to36% radius through cover. Other player action events last2s; their perception/exposure timers differ (SONAR visual3.5s, SURVEY visibility8s, camera exposure per objective). The instrument reports the emission event, not that different task timer. Production movement hearing is a strict speed>50 and distance<430 for every alive craft, independent of silent flag and terrain; it has no v7 quadratic signature. This presentation change reports that inherited rule without making it continuous or retuning it. A continuous radius/retune would require a separate design and baseline comparison.

## Options and tradeoffs

Chosen: small read-only snapshot plus persistent chart instrument, decoy life arcs/countdowns. Existing chart rectangle/control geometry is unchanged. Normally3 rows; an active tool pulse adds a fourth. Fonts scale with the existing density-aware target height. Instrument sits below zoom controls and the old chart gesture hint. Fresh threat rows follow it; optical feed remains in its existing lower corner. This intentionally adds chart overlay occupancy, which actual threat/camera/small-screen captures must review.

Rejected/deferred: repeated toast messages (still overwritten); replacing route/camera context (would hide another important state); new HUD/control row (would further shrink the chart); giant all-purpose sound circles (would imply v7 continuous/occluded acoustics that production does not have); enemy reaction confirmations (would violate sensor uncertainty). Do not infer success from a disappearing pulse.

## Clock and save behavior

Remaining seconds round upward while the positive event exists; expired events disappear. All times come directly from existing noise records, so multiple decoys remain distinct. Tactical pause, Operations, suspension and outcomes consume no simulation time; reopening/resuming does not restart a transmission. Restore uses existing records and starts paused. No new persisted identifiers, durations, clocks or historical source-of-noise fields are introduced. Unknown labels are omitted, avoiding accidental promotion of future enemy events into player telemetry.

## Plan and evidence

1. Retain missing-feedback assertion RED for overwritten messages, pause/restore/multiple/expired decoys, actual craft motion, read-only/hidden-reaction independence and source visibility; retain UI RED for persistent copy/uncertainty.
2. Add the minimum snapshot, formatter and chart drawing; retain GREEN and the strict project gate.
3. Replay the same actual GUI command trace against baseline and challenger, capture cover x136 and inner at420dpi, include ordinary threat/camera contexts and a standalone18s no-input decoy-expiry clip. Preserve failed setup traces and inherited uncertain states.
4. Release exact files/evidence to parent for independent criticism and source/native promotion. Desktop software rendering is not Android runtime, physical Fold7, campaign or human audio approval.

Skills using-superpowers, brainstorming, TDD and worktree guidance were read at dispatch; user autonomy supersedes repeated routine approval/subagent defaults. Skills catalog subsequently became unavailable, so later verification principles are followed from supplied instructions without claiming a fresh skill read. Existing parent baseline strict gate was234/230/1057/7/15/65. No premium escalation.
