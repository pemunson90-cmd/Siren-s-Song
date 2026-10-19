# Bounded Android UI metric transport

Comparison source: 744ad3e. Native [39227185627](../../../android-39227185627/README.md) passes cover Operations/Settings OS scrolling, invariant settings/sticky BACK and cover navigation, then rejects HUD JSON truncated at 1023 characters. Menu snapshots fit; the full HUD does not. Original native excerpt and exact artifact metadata are preserved by tooling. This is a diagnostic transport boundary, not evidence of malformed in-memory geometry.

Android now emits `SS_UI_METRICS_PART id=<session>:<serial> part=<index> parts=<count> bytes=<full UTF8 length> sha256=<full JSON hash> data=<base64>` records. Each contains at most 450 raw UTF8 bytes; a multibyte character may cross parts, so decoding follows full byte assembly. All fields and controls remain. Desktop one-line output is unchanged. The shared tooling decoder validates completeness, identity, base64, count, byte length, SHA256 and UTF8. An incomplete latest snapshot waits/fails; it cannot silently reuse an older snapshot. Freshness uses the first part's original log position and logical snapshot counts.

## Evidence

- `red.log`: test before encoder implementation fails its missing preload.
- `attempt-1.log`: 63 checks, 2 failures comparing parsed JSON directly to in-memory dictionaries. Exact byte equality passed already.
- `type-probe.log`: Godot integer variant 17 (type 2) parses as float 17.0 (type 3); raw dictionary equality is false. This fixture assumption is corrected explicitly.
- `green.log`: 65 checks, zero failures. Exact canonical byte equality remains strict; separately compare canonical parsed trees and recursively check every key/array/string/boolean/numeric value. Unicode, full HUD, unchanged source and bounded records are exercised.
- Actual HUD is 2166 UTF8 bytes, five parts, maximum record 739 ASCII bytes, all 16 controls. Independent Python decoder recovers exactly the same canonical bytes/hash and passes unchanged geometry with explicitly local 420dpi fixture provenance. Its report is in the native evidence directory. No Android production provenance is fabricated.
- `combined.log`: strict complete-suite run; read its final summaries.

Reproduce focused test:

```sh
scripts/toolchain/headless.sh --script res://tests/metrics_transport_tests.gd -- --fixture-log=/tmp/sirens-encoded-hud.log --fixture-json=/tmp/sirens-encoded-hud.json
```

Native corrected transport remains pending. Downloaded APK-byte/hash and pixel inspection remain blocked by artifact-host access. No new visual critic is needed for this transport-only delta; prior density review and actual captures remain source-specific evidence. Requested production routing is Sol6.1; backend/cost telemetry is unavailable.
