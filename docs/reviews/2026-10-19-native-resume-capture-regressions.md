# Native resume capture · independent regression review

**No consequential defect confirmed in the frozen correction.** Supports integrating this exact patch and validating a subsequent meaningful combined native candidate. It does not establish recovery of a particular Android resume, image semantics or compositor acknowledgment. The current native39266427532 runs older20de source and remains independent evidence. Root continues the Gauntlet; completing this bounded review releases its scope.

Reviewed base: **20de5cd2f7aaabd96790cfbe67840e22c07c66fe**. Patch SHA256: **`bf3628f9aeb5cccaf11a8f26050af9f59bb71781a73d00ab48cb9623794655e0`**. [Independent isolation check](../validation/production/native-resume-regression/isolation-verification.json) reconstructs pinned game/scripts, applies the released patch and confirms all10 before/after file hashes against the [source manifest](../validation/production/native-resume-regression/reviewed-source-manifest.json). Shared6ab8 navigation, governing changes and current-run evidence were excluded and untouched. No normal save/source/asset/tooling/CI/commit/push mutations by reviewer.

## Actual failure and bounded correction

Inspected the actual native black PNG, not just its filename. [Byte/pixel verification](../validation/production/native-resume-regression/black-frame-verification.json) confirms the new fixture is identical to original39261365076 `cover/cover-resume.png`:2520×1080,13,037bytes, SHA256 `cc4fbb9d2709856a47efcdd68a59dad12a0ea018402cec1fde1721088c9c949b`, every RGB channel0. This is an inherited evidence failure, not a new simulation defect.

The only live-game change is a guarded foreground diagnostic hook. It requires a ready node still in the tree and initialized HUD before printing the foreground marker and deferring existing `_report_targets`. It adds no input, selection, pause/resource clock, save/load/reset or simulation command. The existing report still waits for process/layout and actual post-draw only on a real adapter, retaining `layout_only` headless behavior. Capture transport/session/serial/chunk integrity is unchanged.

The provided actual GL RED→GREEN records zero fresh reports before the hook versus two fresh post-draw reports after it, with the paused simulation snapshot unchanged. The early callbacks remain harmless. The corresponding headless record emits two `layout_only` reports with drawn0 and exits. These are bounded desktop lifecycle probes; they do not imitate Android composition or prove restored save content.

## Fail-closed protocol review

Resume now retains the immediate screenshot under an explicitly unverified filename. Its final screenshot requires a fresh foreground marker and a newer complete latest report after that marker, paused mission0/sub selection/no active capture, unchanged pre/post semantic state and existing strict native geometry. Missing, incomplete, old or wrong state waits; malformed latest state remains fatal. Counts and drawn frames can advance but cannot regress. A later foreground event invalidates an earlier report rather than allowing fallback.

The geometry probe remains separate from the candidate. The real Godot PNG decoder checks actual RGB variation before a final filename is published. Uniform black/white candidates remain rejected evidence and retry within the existing10-attempt bound; invalid image/decoder failures exit instead of becoming final. Explicit nonblank output is required as well as successful decoder exit. The decoder runs as a separate headless script, not through game commands or an archive reset. Other capture callers retain their default behavior.

Five additional [independent adversaries](../validation/production/native-resume-regression/adversarial.json) execute the actual checker/helper with mocked ADB/log transport:

- A hidden other-station active capture cannot pass resumed-mission semantics.
- Decoder exit0 without its explicit marker fails; a positive marker cannot override decoder exit7.
- A PNG header that passes geometry but has corrupt chunks fails actual Godot decoding, preserves probe/rejected image and publishes no final.
- A new foreground event between pre/post checks rejects that candidate and retries until a complete later report supplies a stable bracket.

All behave as intended. Expected corrupt-image Godot errors are retained in the result and are decoder rejection evidence, not game runtime defects. The new9-case suite already covers the real black PNG, valid nonuniform/uniform-white images, malformed/missing/latest records and all-black10-attempt failure. Existing20 capture,17 Blackwater, archive integrity/failure and308-runtime evidence is reused; no broad suite or native run was repeated. Archive transport mocks and actual runtime checks retain their original scope.

## Limits and disposition

Nonuniform RGB is deliberately a blank-frame screen, not a scene classifier: a nonblank unrelated or incomplete presentation can still require visual rejection. App post-draw acknowledges the application's report, not Android compositor presentation. The log message correctly qualifies compositor acknowledgment as unavailable. Immediate/probe/rejected originals must remain alongside the final image; actual subsequent native pixels still need inspection. No forced cold restart or user-state repair was added to manufacture a passing frame.

The active older-source native run must be reviewed on its own bytes/pixels; no success or failure from this patch can be assigned retroactively. Support exact integration and later meaningful combined validation, preserving all original black evidence and genuine archive restoration gates. Physical Fold7, thermal/performance, full campaign and subjective audio remain separate.

Requested routing: `gpt-6.1-sol` / high; actual backend/effort/token/cost telemetry unavailable. No nested workers or premium escalation. Source hierarchy, immutable v7 and user-terminated autonomy remain inherited; this tooling correction changes no gameplay to compare with v7.
