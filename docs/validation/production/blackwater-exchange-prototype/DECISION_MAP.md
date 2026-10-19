# Blackwater baseline decisions and smallest experiment

Baseline52bedd664b2d50d428e4d92a379b89b115c4d79f,117tracked game files independently verified in provenance.json. Two separate git-archive snapshots live under ignored work/blackwater-exchange-prototype/{baseline,experiment}/game. Shared frozen observed-contact/native source is untouched. This is a prototype question, not a gameplay promotion or a program stopping point.

## Existing decision map

| Stage | What is known/earned | Real available decisions and costs |
| --- | --- | --- |
| Briefing/chart | Two fixed sites(760,200)/(1360,480), three rocks, dark water, return buoy. Both uncollected sites are plotted. | First versus reverse order; drone separation/Quietus fallback; choose approaches and loadout. |
| Approach | Blackwater passive range is0.65×: Quietus156m, drones214.5m, terrain occludes. CAMERA accepts clear240m geometry even when passive contact information is thin. | Move closer/observe, active SONAR950m noise and3.5s cooldown, SURVEY8s visibility/finite charge; movement may be audible. All hearing/AI rules remain production rules. |
| Exposure | Four-second physical optical acquisition, CAMERA noise event520m/2s; generic spire image. | Hold through danger, spend finite disruption, switch attention/station, or break off. Acquisitions persist across station changes; current-source scout retains real drone loss. |
| First result | One record flag; generic “Record secured. Continue the survey.” | Does not currently change a second-site decision except collection progress. Two sites remain interchangeable acquisition actions; next location was already charted. |
| Second/return | Both flags then return Quietus; final prose mentions ancient ocean temperatures. | Recover with surviving craft/resources. No earned first-record calibration, exchange-state knowledge or retained site-specific optical evidence affects the next plan. |

Actual scout approach/no-input16s clips were inspected via full decoded1fps sequences and source-qualified raw commands. Approach: Drone A to760,410, SONAR6s, CAMERA11.33s, two finite observed-lock disruptions; first record by16s, both drones alive. No-input take: camera immediately before clip, record around4s, renewed observed beam around10s and Drone A loss around14s; Quietus100%/Drone B/one disruption remain. Coarse order probes retain first→second and reverse-order drone losses but do not establish an optimal order or whole-mission defeat.

Actual v7 doCapture rewards proximity/drone photography with different photo quality, adding exposure/Hunt; active ping/throttle are acoustic costs. It has no multi-mission progression to restore. This experiment preserves the risk/information relationship rather than reinstating a numeric photo grade or copying quadratic movement/radius tuning.

## Hypothesis A: readable request/reply cadence

Only the experimental Blackwater variant changes its information action. **Baseline remains the original two4s noisy optical photographs.** The experimental sites are distinct REQUEST and REPLY records: a2s settled local hydrophone sample during an authored exchange window, or a2s sample from existing240m clear standoff after accepted SONAR solicits a3s local replay. This is a new authored relay response, not an assertion existing enemy AI heard a decoy. Other missions/optical mechanics remain untouched. No art assets precede the decision test.

Quiet local eligibility uses each craft's actual Blackwater passive distance and terrain-clear line, not a new global radius/sensor buff. The cycle hypothesis is10active seconds,4s request window and4s reply window offset5s. At a settled eligible vantage the worst quiet completion bound is10active seconds; that waiting cost must be measured and may justify rejection. Sampling is2s continuous: a gap/lost geometry resets incomplete reception; progress survives tactical pause and serialized restore with its actual clocks. Any live craft can sample; no mandatory shipborne uplink and no prerequisite order.

The first request sample calibrates the reply's repeating rhythm; the first reply instead calibrates the request. A remote plan may display only a clearly labelled **prediction from that earned packet**, never current off-sensor transmission/enemy state. Locally observed carrier/open-gap feedback requires the selected craft's own range/LOS or its accepted local solicitation. First-record information should let the pilot time the next approach rather than blindly arrive and wait, or accept audible standoff reacquisition. If no useful route/exposure choice follows, the hypothesis fails even if all tests pass.

SONAR preserves its actual cooldown/noise command semantics. A rejected/cooling-down ping cannot refresh a replay. A valid local replay needs target range≤240m and clear terrain; no replay/sampling is published through cover. Sampling from a drifting fast craft must settle first. No global sensing/AI, resources, damage, navigation or enemy-content retuning is permitted.

## Explicit comparator and disposition criteria

Hypothesis B removes mandatory cadence:2s quiet close sampling versus2s audible standoff replay. Compare it explicitly if A creates waiting without a better approach/exposure decision. Keep distinct request/reply records/calibration; do not call faster acquisition alone an experience gain.

Headless rule tests first: close quiet/no added pulse; standoff requires accepted local sonar; no through-cover disclosure; predicted next-site rhythm only after earned data; reverse order; uninterrupted reception; paused/serialized clocks; real ping cooldown; drone loss and solo fallback; legacy optical save remains legacy. Then ordinary-command policies across baseline/A/B: quiet, active, impatient, solo (both drones lost in a separately labelled fallback fixture), retained loss/weak takes. Measure wait, task completion, resources, observed threat and hull/drone outcomes; do not hide losses or nerf enemies. Reject the window if it adds dead time, active is a trivial dominant answer, or fallbacks break.

If promising, retain actual10–20s running prototype/counterexample/idle-world clips, source/command manifests and a playable Godot entry. All work remains isolated until root explicitly integrates. Requested model gpt-6.1-sol/high; actual backend/cost unknown. No nested agents, commits/pushes, shared source, toolchain or governing edits.
