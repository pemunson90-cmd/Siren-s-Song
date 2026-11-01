# Item 147: A debug APK from any branch, signed with our key

Goal (player): Pat can install the current integration build on his phone to test touch, 150% text and sound, and every APK is proven to carry the established development signature (so it updates over earlier installs).
Why now: Pat 1 Nov ruling [android]: APK builds allowed when they help testing; be smart about the debug signing; no release signing. Today .github/workflows/android-validation.yml runs only on frozen gauntlet/production, and scripts/toolchain/build.sh prints the APK signer but never compares it with the pinned certificate.
Class: ui
Areas: tooling
Files: .github/workflows/android-validation.yml, scripts/toolchain/build.sh
Serial zones touched: none
Depends on: none
Protected rules touched: none

## Acceptance test (fails before, passes after)
1. build.sh android fails unless the APK's signer certificate SHA-256 (apksigner --print-certs) equals the value in scripts/toolchain/signing/sirens-song-debug.certificate.sha256. Prove both ways locally with apksigner if available, or with a short shell check on a saved apksigner output: the pinned value passes, a changed value fails.
2. native-smoke runs on workflow_dispatch from any branch (push trigger on gauntlet/production unchanged). Dispatch it once on this item's branch: the run uploads the .apk and .apk.sha256 and the signature check passes. Record the run id. The emulator smoke step may stay as it is; if it fails for emulator reasons only, say so with the log line, do not loosen it.

## Do not
Generate, replace or move any keystore; touch scripts/toolchain/signing/; add release signing or secrets; change game code or tests.

## Evidence (class cap)
The dispatch run id, the signer SHA-256 line, the APK sha256.

## Builder notes
Branch item/147-integration-apk from origin/claude/integration. Preferred provider: claude:sonnet. RED BEFORE: on integration, build.sh has no comparison (grep shows only the print). No Godot test suite is needed; the hand-in is the run id and the two-way signature check.
Checks before push: the minimum (RULINGS.md speed rule).
