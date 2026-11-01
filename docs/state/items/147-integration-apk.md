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
2. A new job `debug-apk` in the same workflow runs on workflow_dispatch from any branch: checkout, Godot/Android setup and caches as native-smoke does, headless import with the same SCRIPT ERROR grep, then `scripts/toolchain/build.sh android` (with the check from 1), and uploads the .apk and .apk.sha256. It does not run the Android emulator smokes. native-smoke stays exactly as it is (still production push or dispatch on production only); do not edit or skip its tests. Dispatch debug-apk once on this item's branch: record the run id, signer SHA-256 line and APK sha256.
(1 Nov: the first dispatch failed in scripts/toolchain/test-android-blackwater.py, a stale Android-only test last run 19 Oct; that repair is item 148, not this one.)

## Do not
Generate, replace or move any keystore; touch scripts/toolchain/signing/; add release signing or secrets; change game code or tests.

## Evidence (class cap)
The dispatch run id, the signer SHA-256 line, the APK sha256.

## Builder notes
Branch item/147-integration-apk from origin/claude/integration. Preferred provider: claude:sonnet. RED BEFORE: on integration, build.sh has no comparison (grep shows only the print). No Godot test suite is needed; the hand-in is the run id and the two-way signature check.
Checks before push: the minimum (RULINGS.md speed rule).
