# Ratified A: differentiated Siren movement challenger

Status: local, unpromoted. Accepted Android APK remains f1ea536 / runtime 92625ac, with its inherited patrol defect recorded. Patrol/recovery comparison source is 8d8635a. Original handoff import 8598d5a and verification record 178ea2d are published and byte-verified; their task gate is satisfied. Density WIP 2fc0976 remains parked separately.

## Behavior and original-reference comparison

Actual v7 has authored patrollers, a conditional tethered sentinel and a fast hunter that waits at home unprovoked. Its sentinel can chase a current sighting/lure beyond tether; it returns when outside tether without those stimuli. Its hunter follows sightings/lures/last-known searches, otherwise returns home. It is not an unprovoked roaming enemy. Production retains terrain-safe navigation, inertia, action-noise acoustic occlusion, current-sight lock, four-second warning and disruption rather than copying v7's straight-line movement or constants wholesale.

New dives assign two Cold Foundry sentinels (190 m tether) and one Listening Well hunter at its inner-water station (800,600). Ten other Sirens retain authored patrol loops. A hunter investigates at 64 m/s (production patrol investigation is 48), returns at 38, and searches a bounded local area using only heard/last-seen information. Memory lasts 12 active seconds after the last actual stimulus; pause/disruption freeze response. A sentinel returns when outside tether without a live heard stimulus, or when its bounded attention expires. Return completes before resuming home guard. These bounded deterministic search/return details are production adaptations of v7's timed/random search.

Independent pre-pursuit inspection identified another original-reference departure: production's visual lock cleared all movement. A second retained RED demonstrates that omission. New station roles now pursue a currently visible target beyond 205 m, using a terrain-safe approach 180 m from it and braking near the emitter's standoff. Target loss ends visual pursuit and retains the last known point; it never grants hidden position. The prior patroller lock standoff remains unchanged. This ports meaningful station-role pursuit without restoring target overlap or reducing the warning. Observed silhouettes/labels distinguish GUARD, HUNTER and PATROL; no hidden role/position is drawn.

Legacy active archives lacking types keep their actual saved patrol content, geometry, routes, evidence and campaign progress. New roles apply on a new dive. The accepted finale snapshot still continues to its legacy 44-second remote victory, deliberately retaining that historical content instead of silently replacing the active mission.

## Test-first evidence

- `red.log`: original 13 focused checks, seven expected failures before role implementation.
- `pursuit-red.log`: 29 checks, two expected pursuit failures before bounded pursuit.
- `role-green.log`: 29 role/assignment/conditional tether/return, comparative response, cover/hearing, fresh warning, disruption, save/pause and legacy checks pass.
- `final-full.log`: strict 8 navigation + 19 geometry parser checks, 233 core and 230 runtime checks (subsequent feedback gate: 234 core/230 runtime), zero failures/errors. Actual-pointer campaign progression reaches all six debriefs and ending using ordinary simulation commands.
- `independent-tooling/`: exact pre-pursuit frozen-source 600-second replay. Ten patrollers circulate and enter every authored waypoint at least ten times; three unprovoked station roles stay home. Eight sensing and eighteen station-response checks pass. Failed stronger 24 m planning-margin assertion is retained; actual 12 m body penetration was not observed. Final pursuit replay separately passes 24 pursuit, eight sensing and eighteen station checks; the Well planning-margin observation reproduces identically on 8d8635a (28.05 seconds), so it is inherited, with zero sampled physical-body penetration.

## Matched tactics and retained losses

Source labels matter. `policy-baseline-8d8635a.log` reruns the external audit's generic objective-vantage policy on actual 8d8635a. `policy-pre-pursuit.log` and `tactical-pre-pursuit.log` retain the intermediate role implementation; current candidate files are distinct. Endurance/no-tools silent and cruise plus disruption/reactive-EMP silent and cruise form the fixed naive panel. These expert scripts do not prove global dominance, human difficulty or optimum strategy.

The old Well generic fallback loses at 47.2 seconds after spending all three pulses. A western optical vantage restores a viable physical solo return. The considered plan deduplicates already-acted-on observed lock samples instead of spending multiple pulses on the same stale sample. Matched with/without one eastern diversion and silent/cruise exposed leg are retained; report current final-source figures from `tactical-candidate.log`, not intermediate experiments.

Old Foundry exposed withdrawal wins but loses Drone A. A direct diagonal withdrawal also loses it after a visible unsafe-terrain stop. Explicit west-then-south STOP waypoints behind basalt preserve both drones at the same 34.2-second/100% hull mission return. The unsafe shortcut is retained, not converted to a collision waiver. Finite tools, failed/unprotected finale strategies, the faster coordinated finale's real Drone B loss, Split and Blackwater comparisons and critic loadout probes remain inspectable.

## Clips and limits

`game/tests/capture_siren_roles.gd` records actual production player view using ordinary commands and passive observation, with no sensor override or forced poses. It prepares quiet observation positions and then issues no further commands during each 16-second recording. Hunter response/return stages use an ordinary decoy and preserve contact expiry. External Barotrauma/other shipped-motion comparison remains pending access; see `../../reference-footage/`. No B external quality verdict is claimed.

The earlier `rejected-capture-setups/idle-patrol` recording is retained as a rejected setup: its ordinary RECON uplink itself provoked investigation, so it is not unprovoked-world evidence. Passive replacement recordings distinguish intentional station stillness from the old unreachable-goal defect. Forced MovieMaker exit can retain audio references; this warning is separate from the fixed native PCM endpoint defect.

Fresh separate [regression/experience review](../../../reviews/2026-10-19-siren-roles-regressions.md) confirms no consequential new regression and supports native validation. Actual native candidate validation remains before promotion. Physical Fold7 ergonomics, density correction, human listening and sustained performance remain open. Passing this milestone will not end the user-terminated Gauntlet.

Final-source matched Well controls: western vantage, silent exposed leg, no diversion wins 75.0 s / 57.1% hull; one diversion wins the same 75.0 s / 100%. Cruising only the exposed leg wins 72.2 s / 100% without diversion, while adding that diversion is redundant in this variant. Both drones were already lost in these fallback cases. This is a meaningful time/noise/tool comparison, not proof of global dominance.

Actual clip bundle and precise setup/source limitations: [clips/README.md](clips/README.md). A second capture-discovered RED (`collision-message-red.log`, 30 checks/one failure) proves enemy terrain braking could overwrite the pilot's status with a false autopilot warning. The message-only correction leaves collision/navigation unchanged; `collision-message-green.log` passes 30 checks and `final-full-feedback.log` passes 234 core / 230 runtime with strict parser gates. `native-protocol-local.log` proves the considered silent deployment/withdrawal procedure through canonical main commands/diagnostics, not native input: one decoy, no EMP, max hunter excursion 325.83 m, no visual lock, hull 100%, physical DORMANT return 35.5 s after deployment.

The unchanged movement-hearing rule is distinct from occluded action noise: velocity above 50 within 430 causes local investigation without an acoustic LOS attenuation check, as the original-handoff audit explicitly records. This cycle preserves that production sensing rule; it does not claim a continuous acoustic signature/footprint or uniform occlusion for every signal. Acoustic readability is a later candidate, not a silent role retune.

Additional considered fallback loadout probe (`well-loadout-probe.gd` / `well-loadout.log`): all three current loadouts win the western-vantage / exposed-leg-cruise / one-diversion Well route with both drones already lost, at 72.2 s and 100% hull. Endurance/survey use their two finite pulses; disruption spends three under the same observed-response helper. This establishes a viable option, not equipment equivalence or human-optimal play.

`retained-foundry-policies.log` reruns the original protected/unprotected solo/coordinated scripts: unprotected solo loses, protected solo wins 55.6 s/100%, unprotected coordinated loses both drones without records, and the old protected coordinated withdrawal wins with Drone A lost. The newer explicit queued covered withdrawal retains both drones. These outcomes remain separate from the review and do not force old figures.
