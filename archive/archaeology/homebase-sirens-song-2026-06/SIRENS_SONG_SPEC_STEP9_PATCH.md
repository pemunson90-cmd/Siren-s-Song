# SIREN'S SONG SPEC — Step 9 patch (v0.3 pull-ins applied)

**Append target:** `SIRENS_SONG_SPEC.md` (could not patch in-place — file lock returned EPERM during this build session; this sidecar holds the patch text Pat or the next agent should append at the bottom of the canonical spec).

---

## Step 9 patch — v0.3 pull-ins applied (2026-06-05)

**Status:** AI-DESIGNED implementation patch. Pat ratified the four pulls in claude.ai-space 2026-06-03 per v0.3 decision log; Cowork chain executed the implementation post-Step-8.
**Scope:** four targeted pulls from v0.3 spec at `Inbox_from_Claude.ai/Siren's Song claude web/SIRENS_SONG_functional_spec.md`. Remaining v0.3 deltas (HUNT meter, graze, narrative fragments, currents/thermal, 4th Siren, photo scoring, factory escalation, search memory, distinct silhouettes) are NOT implemented in this patch — HOLD pending Pat playtest of v7 and current Cowork build side-by-side. See `research/CLAUDE_AI_INBOX_ANALYSIS_20260605.md` §10 + §11.

### Patched mechanics

1. **EMP / kill-rule fix (v0.3 §6).** Vaporize at sustained `suspicion == 100` now requires at least one un-stunned Siren with proximity + LOS detection on the sub. With all detectors stunned (EMP / KD) or LOS-broken (cover), the instakill timer pauses at its current value (does not advance, does not reset). When an un-stunned detector re-acquires LOS, the timer resumes from where it paused. INSTAKILL_SUSTAIN_SEC = 4.0 unchanged.
2. **Shadow-cone LOS rendering (v0.3 §3).** Visible dark wedges rendered behind every terrain rect inside the passive sonar disc, active ping disc, and drone-cam disc. Render-only; the geometric LOS gate (`isLineOfSightClear`) is unchanged. Recon reveal is NOT shadow-cast (flyover; recon disc is not LOS-gated per Step 6 design).
3. **Procedural Web Audio module (v0.3 §10).** AU module ported verbatim from v7 prototype. Cues wired at: active ping, EMP, knockdown, drone photo, sub-cam photo, vaporize, extraction, rising-edge into HOSTILE (heartbeat), first-input ambient drone start. Gesture-initialized; fail-safe try/catch — game continues normally if Web Audio is unavailable.
4. **Speed-as-noise + silent running (v0.3 §2 + §6).** Throttle generates a noise emission radius `noiseR = sub.speed × NOISE_GAIN`, capped at `NOISE_HEAR_MAX = 360 px`. Any Siren within `noiseR` (no LOS required — noise is omnidirectional) gets a soft investigate hint at the sub's current position (window 2.5 s). Noise does NOT directly increment suspicion; it feeds detection through the existing proximity chokepoint once the Siren closes. Silent running (keybind `Digit5` desktop, `#btnSilent` mobile button) cuts engines: sub.speed forced to 0, sub freezes in place, noiseR forced to 0. Oxygen drain continues.

### Invariant impact

- **INV5 (fairness valve):** strengthened. EMP and cover are now genuine survival tools at sustained max. The kill needs an active witness.
- **INV3 (perceiving costs):** broadened. Moving is now a perception cost too (Knot B of v0.3 §1). Silent running is the "pay nothing extra, see nothing extra" beat — but it freezes the sub, and oxygen still ticks.
- **INV6 (function before form):** preserved with a v0.3 carve-out. Audio is core pillar per v0.3 wrapper §6; shadow rendering is legibility geometry per v0.3 §3, not chrome.
- INV1, INV2, INV4: unchanged in shape. Thresholds 34/75/100, 4.0 s sustain, all charges, all costs, 210 s oxygen, -5/s decay, Step 7 tuning preserved verbatim.

### Tuning constants added (Step 9 only)

- `NOISE_GAIN = 4.5` — multiplier from sub speed to noise emission radius (terminal 80 px/s -> 360 px). FLAG-style playtest dial.
- `NOISE_HEAR_MAX = 360` — hard cap; matches v7 `noiseHearMax`.
- `NOISE_INVESTIGATE_WINDOW_SEC = 2.5` — Siren attention window from a noise hint.
- `SILENT_BIND_KEY = "Digit5"` — desktop binding (additive; no collision).

### Build state

- Pre-Step-9: `code/sirens_song.html` 135,266 bytes / 3,196 lines (Step 8 closed).
- Post-Step-9: ~151 KB / 3,659 lines. Backup at `code/sirens_song.html.bak.pre-step9-20260605` (md5 `9e6d673b4bcc3e8a82a100f414ef0557`).
- `__sim` surface: 73 -> 80 entries (strict superset). New entries: `hasActiveDetector`, `shadowPolyForRect`, `AU`, `noiseRForSub`, `toggleSilentRunning`, `getSilentRunning`, `setSilentRunning`, `getNoiseR`.

### Decision log entry

**Step 9 patch — 2026-06-05.** Pat ratified four v0.3 pulls in claude.ai-space 2026-06-03 (per v0.3 decision log: kill-rule fix + noise/silent + audio + shadow cones). Cowork chain implemented in `code/sirens_song.html` per `briefs/09_v03_pullin_patch.md`. Pat ratifies the patch via accept/reject of the Step 9 audit deliverable. Remaining v0.3 mechanics held pending v7 playtest and the next ratification queue.

---

**FLAG for next-agent / Pat:** the canonical `SIRENS_SONG_SPEC.md` could not be edited in-session due to a Windows file lock (EPERM on every Edit + Write attempt). The patch text above should be appended verbatim at the bottom of `SIRENS_SONG_SPEC.md` once the lock clears.
