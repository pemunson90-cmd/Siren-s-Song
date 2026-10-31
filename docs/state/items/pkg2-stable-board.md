# Item PKG2: Stable board and clear threat (PR 239, root)

Goal (player): The board does not move under your finger; overlapping targets get a chooser; threat text is never covered; every craft action reachable at 150%.
Why now: Critic 123 C02/C07/C08/C09/C15/C20/C52.
Class: ui
Areas: hud.layout
Files: as in PR 239
Serial zones touched: mission_hud.gd, ocean_view.gd
Depends on: none
Protected rules touched: none

## Acceptance test (fails before, passes after)
PR 239 CI green; native layout tests.

## Do not
Touch wording or route targets (126).

## Evidence (class cap, PROCESS.md section 5 on claude/workflow-v2)
PR 239 body.

## Builder notes
Branch root/stable-board-pkg2 from origin/claude/integration. Preferred provider: codex.
Checks before push: import, core, the affected suites for the changed files, the canary set once it exists.

## Root verification — 2026-10-31 05:17 Eastern
Current head d1dcadb92faccdcc10417e2623df2cfd019b5f14 composes actual126 and CI v2 base1642acd9. Independent HIGH99 approved exact composition; MEDIUM100 approved its documentation-only pointer correction. Own run41186670556: guidance/core/affected-selection passed; four runtime shards and final smoke still required. No merge clearance yet. Root is available despite the earlier predicted usage gap. Preserve serial-runner merge authority and all other item owners.

## Root verification â€” 2026-10-31 07:37 Eastern
PR239 head527e4478eaf2fd1cd400c7e23da64974c12e4c95: all eight own hosted checks SUCCESS in run41193503459 (guidance/core/affected/four runtime/final smoke). Actual base1642acd9 remains live. HIGH99 approved actual126/CIv2 composition; MEDIUM100 approved docs-only correction; HIGH102 approved exact native test partition treea5b0777350751934692b4dcfbf35a453670c9fa9/parentd1dc, reverified before commit. All eight cases/assertions/34captures retained; four local native entries1610/0; hosted timeout resolved without relaxed checks. PR review provenance: https://github.com/pemunson90-cmd/Siren-s-Song/pull/239#issuecomment-6542313732
Ready for serial-runner final current-head/base verification and merge; root does not merge under D15. Keep claim active until landed source confirmed. If integration moves, reconcile and apply exact-head review/CI gates. All other owners preserved. This is technical acceptance, not phone/audio/blind-reference acceptance.