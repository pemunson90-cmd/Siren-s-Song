# Menu screenshot ordering correction

**Local tooling correction, not new Android runtime evidence.** The [actual artifact review](../ARTIFACT_REVIEW.md) found `cover-menu-returned.png` and `inner-menu-returned.png` still showing Settings although fresh diagnostics correctly reported Operations. Other transition/scroll frames similarly preceded their adjacent metrics. Original screenshots remain unchanged.

The old shell order was **screencap → collect fresh log → validate metrics using PNG dimensions → accept**. Matching dimensions never established screenshot content. The retained [RED run](red.log) fails eight assertions among 27 cases, including the requested command-sequence regression:

```text
capture → stale log → wait → capture → fresh matching log → validation → accept
```

Both captures precede the first successful validation; a simulated postcapture settings mutation was never read. ADB/log transport is mocked because this environment has no local emulator; the actual shell helper and real Python checker execute in these tests. Synthetic PNG headers are used only to exercise geometry checks, never as claimed game images.

## Bounded correction and contracts

Changed only `scripts/toolchain/android-menu-smoke.sh`, `android-menu.py` and `test-android-menu.py`; no game/save/main edit or CI run. `menu_snapshot` now:

1. Takes an explicitly named `*-geometry-probe.png`, which provides actual native PNG dimensions only. Removes an old final filename so failed attempts cannot leave an accepted-looking final screenshot.
2. Collects and validates matching fresh requested-screen metrics using the probe dimensions and existing density/safe-area/48dp/preferences gates.
3. Captures `*-candidate.png` **after** that successful validation, then collects fresh logs again and reruns the same checker against this candidate's actual dimensions.
4. Publishes the ordinary final filename only when both validated reports agree on screen, action, scroll offset, preference values, geometry and target/exposure result, with a nondecreasing snapshot count. Changed validated state is retried, keeping rejected candidate files explicitly labeled. Existing ten-attempt/one-second conditional polling bound remains; no arbitrary extra wait was introduced. Malformed evidence, changed preferences or mismatched candidate dimensions are fatal.

Identical diagnostic re-emission can advance the count without forcing failure. The actual downloaded cover returned log has identical layouts at snapshot counts **13 and 14**: replayed through the real checker, all canonical report values agree after removing only `metrics_count`. The [retained replay/ordering report](ordering-and-native-reemission.json) records this observation and the corrected shell event order. Snapshot freshness still uses the original caller's strict `after-count`; incomplete newest records never fall back to older ones.

New optional checker `--wait-for-screen` permits bounded polling of an ordinary in-flight transition. It first validates the other screen's structure, PNG geometry, density, control sizes, safe areas, scroll contract and readonly preferences. Unknown/malformed screen evidence remains fatal; a changed preference remains fatal even when the requested screen is pending. Default CLI wrong-screen behavior remains strict. Existing exit 2 semantics for a valid clipped/offscreen target are preserved for ordinary scrolling.

## Verification

- [Final menu suite](green.log): **30 tests pass**. Includes delayed requested-state arrival, before/capture/after ordering, changed scroll-state retry, identical re-emission acceptance, postcapture preference mutation, bounded timeout without final PNG, valid other-screen retry, malformed other-screen rejection, postcapture PNG geometry mismatch and preserved scrolling result. Initial eight RED failures were observed before implementation; later three boundary cases extend GREEN coverage.
- Related actual commands pass: role parser **10** ([log](related-0.log)), metric records **9** ([log](related-1.log)), navigation **8** ([log](related-2.log)), UI geometry **27** ([log](related-3.log)), and binary primary/backup/restoration/write-failure mock ([log](related-4.log)).
- `bash -n scripts/toolchain/android-menu-smoke.sh` and scoped `git diff --check` pass. Source hashes are retained in `SOURCE_SHA256SUMS`.
- No game test result, live screenshot, native retry or Android installation is attributed to this tooling-only change. The production owner has concurrent acoustic-feedback edits; the parent owns the integrated full-game gate after those edits settle.

## Explicit remaining limitation

**There is no presented-frame acknowledgment.** Stable validated state before and after `adb screencap` improves ordering and detects intervening state changes, but an Android compositor could still present an older frame. PNG dimensions and diagnostic agreement are not semantic pixel identity. The upcoming meaningful native candidate must still have its actual screenshots inspected; no silent automatic visual acceptance follows from these tests.

If actual pixels still lag under the corrected ordering, the smallest next interface is a game-owned diagnostic emitted after `RenderingServer.frame_post_draw`, keyed to the complete metric snapshot/session/serial and requested screen, followed by a coordinated native capture. Even a post-draw signal must be distinguished from Android compositor presentation. No such signal or main-file collision was introduced here; the game owner/parent must coordinate that interface if evidence warrants it.

Requested routing: explicit `gpt-6.1-sol` / high; backend/usage/cost telemetry unavailable. No nested agents, commit or push. This scoped correction leaves the existing b809501 byte/pixel gate and preserved fallback intact.
