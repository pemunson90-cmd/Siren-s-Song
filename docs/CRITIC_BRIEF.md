# Reusable critic brief · ratified reference method

Inherit [AGENT_BRIEF.md](AGENT_BRIEF.md), source hierarchy and explicit model routing. Keep builder/critic separation, read actual artifacts before builder interpretation, and preserve the strongest verified baseline. Read the relevant [original v7 implementation](../reference/original-prototype/sirens_song_prototype_v7.html) and compare retained/changed/missing behavior; do not treat its historical wrapper as current governance. The user ratified [Addendum A](reviews/2026-10-19-external-audit-addendum-A.md) and [Addendum B](reviews/2026-10-19-external-audit-addendum-B.md) on 19 October 2026; B's original Proposal label is superseded by that explicit direction, not silently edited.

## Starting external bar

| Reference | Judge this dimension |
| --- | --- |
| Door Kickers | Route planning, waypoints, conditional orders and touch planning UI. |
| Barotrauma | Sonar as the primary world view, creature behavior and submarine dread. |
| Mark of the Ninja | Making noise and detection visible, learnable and understandable. |

Use **one dimension per comparison**, rather than resemblance or an overall shipped-game score. After these gaps close, expand to Frozen Synapse (plan legibility, intent lines, enemy uncertainty, HUD economy), Silent Hunter (submarine atmosphere and navigation-chart plotting; the owner's remembered title remains **unconfirmed**) and Into the Breach (enemy-intent telegraphing on a small screen). Do not misstate historical mobile releases as current availability.

## Required evidence and report

1. Inspect actual **10–20 second Siren's Song clips** of the selected dimension and at least one **no-player-input world clip**. Watch enemy activity, not only a successful player route. Record source SHA, scenario, input, viewport and device/backend; retain failed or weak states too.
2. Pair with **reference footage of the same dimension**, identified by URL/source, title/version if known and timestamps. Verify current store status before recommending anyone play a reference; footage can serve comparison when a port is unavailable. No current store or footage inspection is implied by this brief.
3. Blind the clips **only where feasible**: remove titles/branding without removing the information being judged. State the blinding limits, recognizable differences and any prior identity knowledge. Give the dimension verdict and reasons before unblinding when genuinely possible; never label an identifiable or already-known pair blind.
4. State which clip better achieves that dimension and point to observed moments. Separate observed behavior, interpretation and unavailable evidence. Missing footage or unsuitable clips mean **comparison pending**, not an invented loss/win or completed external review.
5. Record every result, including outright losses, source clips and actionable gaps in [BASELINE_AND_EXPERIMENTS.md](BASELINE_AND_EXPERIMENTS.md). Losing to a shipped game is expected and useful. Do not equate more tests, solver speed, content count or difficulty with experience quality.
6. Use references for clarity, behavior and feel, **not imitation** of identity, art, assets or mechanics. Preserve Siren's Song's original premise and current approved creative grant. A regression hunter still compares accepted baseline/challenger separately and may find no consequential new regression.

Report compactly: **dimension → actual clips/reference timestamps → blinding status → observed strengths/losses → baseline/challenger difference → next bounded improvement and remaining evidence**. Keep human/physical Fold7 evidence separate from emulator/desktop and synthetic-input evidence. No code, asset or save changes unless explicitly assigned. Requested model routing is observable; actual backend/usage/cost telemetry may be unavailable and must not be invented.
