# Recovery-route integration review checkpoint

Governing production: e3a541fb24c2a3f136121150b7a0d2960546fda7.
Initial root source: 8b09353712db9163f8fdfb877e3960bbca013dbc.
Frozen provider fix: 09b66ea04730008fd84eae843808c1d66d4475b9 (child of b9d98d6).
Reviewed game commit in isolated tree: 880cea3d1b964be09599067412289588e5b4d60c.
Reviewed game tree: 393e8f4bb77f7a5e7ba7052618ef316e1a14db65, identical to provider09b66ea.

Actual source review is clear after inspecting the frozen narrow pointer fix. The original gesture blocker is fixed; final integration SHA binding and actual PR CI remain pending. No merge or final integrated approval is claimed.

Initial blocker: on both cover/inner, emulated GUI recovery Buttons accepted a short20px horizontal drag still inside their bounds, or a canceled ScreenTouch followed by its emulated mouse release. Both unintentionally ordered NORTH(1000,180). Initial standard62checks missed that protocol. Exact retained independent probe: recovery_choice_pointer_probe.gd; valid RED recovery-pointer-valid-red.log4checks/4failures. Ignore earlier engine_attempt experiments; they had physical/logical coordinate mismatch and are not evidence.

Frozen09b66ea makes recovery buttons ignore GUI mouse input; popup_gesture owns valid same-button taps through recovery_button_at. Source has no model/save changes. Independently rerun original probe on actualGL: recovery-pointer-fixed-gl.log4checks/0failures, exact snapshots unchanged. Updated committed recovery suite: recovery-final-suite.log68checks/0failures, covering ordinary/native-mouse choices, named mouths, propulsion, Queue/undo, no branch commitment before arrival and cancellation. Whole logs have no SCRIPT ERROR or ERROR lines. ActualGL desktop VSync warning and headless suite ObjectDB shutdown warning disclosed. These are source-known control checks, not blind play or device acceptance.

The initial full source review found no other consequential regressions. Route helper uses ordinary route commands, keeps selected craft/profile/drive/Queue/Replace/history/pause, uses public charted mouths and retains physical extraction authority. Known multi-mouth readiness label may lag monotonic acquisition during RUN; not consequential to route/commit.

Root6489d028a8a0cb77708899005703264d53c1cc81 docs/CI extension inspected: new harness appears in actual PR loop with strict whole-log errors and positive zero-failure summary, plus test.sh registry; bash-n passes. CONT/WORK39lines each. That source was still pre-fix when last inspected.

NEXT ACTION: root cherry-pick09b66ea onto PR37, send exact composed head. Compare its game tree with393e8f4bb77f7a5e7ba7052618ef316e1a14db65 and inspect only any further delta. If identical, bind retained review to exact head without rerunning unchanged suites. Root must obtain actual final PR guidance/game-smoke SUCCESS before merging. No APK, broad recertification or second reviewer.

Local isolated tree: /workspace/Siren-s-Song-connected-campaign-review.
Probe/logs reside under its work/ directory and are included on this checkpoint branch. Other ignored evidence is preserved locally; no genuine profiles or worker trees were changed.
