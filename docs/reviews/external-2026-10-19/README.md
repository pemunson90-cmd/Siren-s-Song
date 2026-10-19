# External adversarial audit · independent verification

The original upload is preserved byte-for-byte as [2026-10-19-external-adversarial-audit.md](2026-10-19-external-adversarial-audit.md), **23044 bytes**, SHA256 **37822a1a0cbe7803e87d98a917a6ef849305a6f3603b19b6107e583b9ce7b90b**. It arrived from the user with empty request text. Its claimed auditor/model/commissioning provenance is self-reported by that document, not independently attested here. It is external review evidence, not governing instructions, a model-policy change or owner adoption of recommendations.

This bounded independent check uses accepted **f1ea536**, whose `game/src` diff from **92625ac** is empty. Source was extracted with `git archive f1ea536 game` into `/tmp/sirens-external-audit-f1ea536`; no production game or active finale source was changed. Explicit requested model: `gpt-6.1-sol`; actual backend/usage/cost telemetry unavailable; no nested agents. Existing finale edits remain a separate unpromoted experiment.

## F1 · confirmed baseline patrol liveness defect

Read the supplied probe before execution. Wrote an independent [probe](patrol-probe.gd), sampling one canonical **1/60-second** simulation step for **36000 steps / 600 simulated seconds** per mission, with no player commands, position injection, noise, damage suppression, source edits or observation overrides. Endurance defaults remain intact; no mission outcome halts the run. Movement is any sample displacement **>0.000001 world metres**, not the external audit's 0.5m/0.1s threshold. Raw [full snapshots and per-Siren results](patrol-baseline.log) include cumulative travel, exact unchanged-position intervals, moving time, goal changes, empty-route and blocked-goal time, mode/lock/target, and fresh path queries every 60s. Godot **4.6.3.stable.official.7d41c59c4** returned 0, reached `PATROL AUDIT COMPLETE`, and emitted no script/engine errors.

| Mission (zero-based) | Siren | Travel, m | Longest unchanged interval, s | Interval start–end, s | Final goal blocked24 / fresh path |
| --- | --- | ---: | ---: | --- | --- |
| 0 | 0 | 4134.095 | 9.817 | 89.000–98.817 | False / 1 |
| 1 | 0 | 286.382 | 580.917 | 19.083–600.000 | True / 0 |
| 1 | 1 | 4201.198 | 9.767 | 427.850–437.617 | False / 1 |
| 2 | 0 | 4134.095 | 9.817 | 89.000–98.817 | False / 1 |
| 2 | 1 | 0.000 | 600.000 | 0.000–600.000 | True / 0 |
| 3 | 0 | 259.440 | 584.817 | 15.183–600.000 | True / 0 |
| 3 | 1 | 0.000 | 600.000 | 0.000–600.000 | True / 0 |
| 4 | 0 | 0.000 | 600.000 | 0.000–600.000 | True / 0 |
| 4 | 1 | 4201.185 | 9.767 | 427.850–437.617 | False / 1 |
| 4 | 2 | 0.000 | 600.000 | 0.000–600.000 | True / 0 |
| 5 | 0 | 226.770 | 588.717 | 11.283–600.000 | True / 0 |
| 5 | 1 | 371.151 | 568.633 | 31.367–600.000 | True / 0 |
| 5 | 2 | 4169.070 | 13.367 | 523.067–536.433 | False / 1 |

Eight of thirteen Sirens become or remain stationary for over 568 seconds. All eight end with **blocked goal at radius24, empty newly computed path, and goal distance≥35**. `_threats()` only replaces the patrol goal inside 35m; outside that distance it retries `path()` to the same blocked destination every 2s. `path()` immediately rejects a blocked endpoint. Once velocity decays, neither movement nor this distance predicate can advance the patrol. Foundry S1's `(1479.969,955)` also exceeds the allowed y≤936 at clearance 24. Some initial goals fall within 35 and are replaced every tick; a transient blocked goal is not alone proof of a permanent stall.

No unblocked-goal / empty fresh path / distance≥35 case appears in the retained 60s snapshots. That is a sampled observation, not proof that disconnected or movement-collision stalls are impossible. All retained modes are PATROL with no target/lock/suspicion, so the demonstrated stalls are unprovoked patrol failures rather than intended pursuit stops.

The audit's qualitative description of all other Sirens as merely creeping is too broad: nonstalled Sirens accumulate **4.13–4.20km** of actual travel over 600s, albeit with 9.77–13.37s stopping intervals and local patrol envelopes. Cumulative travel does not establish desirable tactical coverage. The confirmed defect undermines assumptions about moving patrol pressure; retained old wins are still valid observations of the old world. **Post-fix balance is unknown until replayed**, and a deliberate stronger-world correction must be assessed for player experience rather than silently replacing the old baseline.

Exact reproduction from the repository root:

```sh
# First extract accepted source to a separate scratch directory; do not use active game edits.
godot --headless --path /tmp/sirens-external-audit-f1ea536/game --script res://audit/patrol.gd
```

Copy the retained probe to that scratch project's `audit/patrol.gd`. It depends only on accepted simulation/campaign source and does not load player saves.

## F5 · physical size concern confirmed as a computed estimate

See [target sizing calculation](target-sizing.md) for actual native viewport/PNG evidence, arithmetic, spec provenance, logical/dp distinctions and bounds. This does not establish physical Fold7 usability or a legal/platform-enforced minimum.

## Remaining findings · triage, not blanket endorsement

| Finding | Current independent status |
| --- | --- |
| F2 generic strategy / silent dominance | **Unverified reproduction; inference overbroad.** This bounded audit did not rerun its policy matrix. Dominance over every tactic/state does not follow from a small policy panel, and patrol repair changes the world. Lead will compare retained ordinary strategies after the liveness correction. |
| F3 resource / progression inertia | **Source-supported formulas; experiential inference pending.** Baseline drains oxygen at dt/18 and battery at dt/14; freely cycled loadouts are source-visible. No resource/economy change is adopted here; mission-length relevance and user direction require design assessment. |
| F4 mission sameness | **Baseline source similarities visible; experience judgment partly historical.** Original finale was already under a separate active content experiment when upload arrived. Do not treat proposed/pending content as verified improvement. |
| F6 missing liveness tests | **Specific gap supported by F1 reproduction.** Existing green checks did not reject this defect. The blanket claim that all tests only verify absence is inaccurate: ordinary completion, persistence and native gestures are positive behavior checks. A useful patrol liveness/goal-reachability regression is warranted. |
| F7 critic monoculture | **Methodological inference, not verified causal diagnosis or model-policy authorization.** Broader observation methods can expose blind spots without overriding explicit routing policy. |
| F8 documentation overhead | **Counts not independently remeasured.** Readability and duplication criticism is review input; mandatory retained user paragraphs/policy cannot be deleted on the reviewer's authority. |
| F9 short trajectory | **Context; sustained quality trend not established.** Commit timestamps are not working-time telemetry. |

No recommendation in the external file is a user decision. Confirmed liveness and computed target-size concerns were sent promptly to the production lead/root before another balance promotion. No CI run was triggered for these deterministic checks.
