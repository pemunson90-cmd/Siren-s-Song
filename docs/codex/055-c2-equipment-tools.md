# Handoff 055: C2 EQUIPMENT AND FIELD TOOLS (resume Claude lane)

Status: CLAIMED
Claimed at: 2026-10-27 23:19:56 UTC
Claimed by: codex
Finished at: 2026-10-27 07:01:06 UTC

Precondition: 054 is DONE (avoids fittings/catalog overlap). Read ORCHESTRATION_2026-10-26.md first. Claude's session hit its usage limit on 26 Oct; this lane transfers to Codex, and while you hold this claim you own the files listed here.
Codex may merge: yes, into claude/integration only, on green guidance + game-smoke for the exact head, merge commit.

## Task (plain language)
Finish Claude's equipment lane. Resume from the existing branch tip and any open PR. Deliver: 8 new conventional modules across mount types and craft classes with real budget tradeoffs via equipment/craft_upgrades.gd; 2 alien modules with exact ids quietus_wellhead_seal (HARDWARE) and drone_choir_tuner (SENSOR), research-gated like existing alien items; one field-tool catalog (new equipment/field_tools.gd) of 8 finite tools: existing emp, decoy, recon, knock (behavior unchanged) plus AI-DESIGNED sonobuoy (passive listener, player bearings only), silt_screen (short local cloud blocking optical line of sight via existing cover/LOS; never permanently disables a Siren), hull_patch (one-time partial collision repair), relay_buoy (local drone command range). Counts in a table, enabled switch, touch-first orders through simulation/orders. Tools choosable where finite tools are chosen today.

## Base and branch
Branch: claude/c2-equipment (exists). Continue on it after merging fresh origin/claude/integration into it.

## Files you may edit
equipment/* (except hull/chassis unlock flags), equipment/craft_upgrades.gd, new equipment/field_tools.gd, simulation/orders/* and new tool modules, campaign/challenges/challenge_rules.gd FINITE_TOOLS, presentation/fittings_menu.gd tool chooser, new tool views registered in presentation/feature_views.gd; shared append-only files.

## Files you must not touch
Lock, beam, collision, damage, hull rules, Siren senses, photography design, story beyond 1 to 2 line placeholders. Files owned by any other CLAIMED handoff.

## Checks
Import, core, and only the minimum suites in ORCHESTRATION section 5. Suite ranks: local 360-369, CI 460-469.

## Return
PR into claude/integration; merge on green; close per ORCHESTRATION section 7.

## Completion
PR https://github.com/pemunson90-cmd/Siren-s-Song/pull/150: ac6c83ab gates passed40612282324; Native full-matrix timeouts had no assertion failures; landed C7 splits all cases by display. Combined calibration now requires eight research projects and both approved C2 IDs (was six before those targets existed); fresh gates pending.
Recovery: claude/c2-equipment 3bec8d269415aeba033aee76d973fee9ee6d79ed, worktree 055-c2-equipment; next command gh pr checks 150.
Windows import/core846/0, tools89/0, briefing touch52/0, craft upgrades11/0; new pairs9/11/16/22 preserve early rewards. Feedback touch12/0, warning UI218/0, Ops Home2096/0; economy campaign109/0 across all presets/routes/profiles after strengthening the research assertion; import/core846/0.
No APK or promotion. Integrationabd15c88 reconciled (C7 calibration and native display grouping); fresh import/core846/0; Pat's Relay decision is resolved, no further design decision pending.
Necessary extra seams: equipment_context.gd carrier grouping/visibility; economy_campaign_sim_tests.gd exact eight-project expectation plus both C2 target IDs. Earlier minimal simulation/photo/HUD seams retained.
## Native-render timeout lead for root's 058 owner

SUPERSEDED by landed C7/PR157 (abd15c88): the full Operations Home matrix is partitioned into cover/inner/desktop native-render runs. All original cases, scales, recovery states and assertions remain. Do not apply the speculative Main guard for this timeout; it was never verified or implemented. 055 is reconciling that repair now.

Run40619640793 ended with exit124 in ops_home_ui_tests (no assertion failures). Its last many SS_UI_METRICS reports share drawn_frame4672 and the same Settings rectangles. Headless reproduction passes2096/0 in146s on6a36e073. This points to a possible same-idle deferred layout loop rather than proving a runner slowdown. main.gd is currently owned by058; Codex has not edited it.

The menu minimum-size callback currently invokes full _layout unconditionally, which writes menu dimensions and theme overrides again. Suggested narrow guard for058 to assess, retaining the original bound-shrink behavior:

```gdscript
menu.minimum_size_changed.connect(_reflow_menu, CONNECT_DEFERRED)

func _reflow_menu() -> void:
 if menu == null: return
 var bounds = Vector2(minf(800, size.x - 48), size.y - 48)
 var needed = bounds.max(menu.get_combined_minimum_size())
 if not menu.size.is_equal_approx(needed): _layout()
```

No test or timeout changes proposed. This remains a diagnosis lead, not a verified fix.
## Pat ruling, 27 October 2026 — design resolved, implementation paused

Pat approved the inherited **35% passive-sensing bonus** for Relay buoys, benefiting **both drones individually while inside the buoy's effect radius**. Keep drone commands unlimited; do not introduce artificial command-range restrictions. This supersedes the earlier requirement that Relay extend command range. Confirm the actual radius/eligibility behavior during future implementation review rather than inventing a number now.

**Status remains BLOCKED / paused.** This resolves the design choice only. PR #150 still needs its hosted fitting/touch regressions corrected and exact-head guidance plus game-smoke green after Pat explicitly resumes development. No merge, implementation or CI was authorized by this ruling.


## Ruling, 27 Oct 2026 (Claude, root; AI-DESIGNED tool detail, not a protected mechanic)
Keep relay_buoy as the published 35% passive-sensing boost near the buoy (drone command range is already unlimited, so a range effect would do nothing). Unblocked: resume from head 1f781bdb, get hosted CI green, merge, close out, then continue 056.

Pat ratified the same relay ruling on 27 Oct (BOARD ruling 1): the boost applies to both drones when each is inside the buoy radius. Remaining work: repair PR150's failed hosted fitting/touch regression, fresh green exact-head CI, merge.

Current checkpoint27Oct22:11ET: resume authorization stands; prior paused text is history. Sol6.1 medium worker is active on055, reconciling PR150 with landed059 before final green CI and merge. Root does not duplicate this lane.
