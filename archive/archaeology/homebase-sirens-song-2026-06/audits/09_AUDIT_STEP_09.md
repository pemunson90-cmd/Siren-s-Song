# Audit -- Step 09 v0.3_pullin_patch

**Auditor session:** sharp-magical-dirac (Cowork Dispatch child, Claude Opus 4.7-1M, 1M context)
**Audited step handoff:** `handoffs/09_HANDOFF_FROM_STEP9.md`
**Audited code state:** `code/sirens_song.html` 135,266 bytes / 3,086 lines (Step 9 delta vs Step 8: 0 bytes / -110 lines — see CRITICAL FINDING below)
**Pre-Step-9 backup:** `code/sirens_song.html.bak.pre-step9-20260605` (135,266 bytes; md5 `9e6d673b4bcc3e8a82a100f414ef0557` — verified byte-identical to Step-8-closed state; backup parses clean under `node --check`)
**Authority chain:** `SIRENS_SONG_SPEC.md` > `agent.md` > `briefs/AUDITOR_BRIEF.md` (incl. Step 9 appended section) > `briefs/09_v03_pullin_patch.md` > `handoffs/09_HANDOFF_FROM_STEP9.md` > current code

---

## TL;DR

**VERDICT: RED — ROLL BACK TO `code/sirens_song.html.bak.pre-step9-20260605`.**

The post-Step-9 file is **hard-truncated mid-comment** inside `drawWorldNear` at line 3086. The closing of `drawWorldNear`, the factory-rendering block, drone rendering, HUD, input handlers, animation loop, and the entire `window.__sim` surface are **gone**. The file has **no `</script>`, no `</body>`, no `</html>`**. Node syntax check fails. The game cannot load in any browser. The handoff's claim of "~151 KB / 3,659 lines" is false; the file is 135,266 bytes / 3,086 lines (110 lines SHORTER than the baseline, which happens to byte-coincidence-match the backup size at exactly 135,266).

Pulls 1, 2 (helper only), 3, and 4 (helpers + key bind + mobile button) all have new code present in the file's first ~3086 lines, so the build agent did the editing work. The damage appears to be a final-write truncation event — possibly a Write tool call that delivered an unclosed payload. The four pulls cannot be exercised because the script never finishes loading.

No regression sims could be run. The script fails to parse.

---

## CRITICAL FINDING — file is truncated

### Symptom

- `tail -c 10 code/sirens_song.html` returns `factory ed` (no newline, no closing tags).
- `grep -c "</html>" code/sirens_song.html` = **0**.
- `grep -c "</script>" code/sirens_song.html` = **0**.
- `grep -c "</body>" code/sirens_song.html` = **0**.
- `node --check` on the extracted script body: **SyntaxError: Unexpected end of input** at the end of file, at line 2911 of the extracted JS (corresponds to HTML line 3086):
  ```
  // in the LOS check (a ray that ends on the factory ed
                                                        ^
  ```

### Comparison to baseline

| Metric | Backup (pre-Step-9) | Post-Step-9 | Delta |
|---|---|---|---|
| Bytes | 135,266 | 135,266 | 0 |
| Lines | 3,196 | 3,086 | **−110** |
| `</html>` count | 1 | 0 | −1 |
| `</script>` count | 1 | 0 | −1 |
| `</body>` count | 1 | 0 | −1 |
| `node --check` on extracted JS | EXIT 0 (clean) | EXIT 1 (SyntaxError) | regressed |

The handoff claims `~151 KB / 3,659 lines (delta: ~+16 KB / +463 lines)`. Reality: 135,266 B / 3,086 L. The handoff also claims "Backup byte-equal to Step-8 closed state (md5 `9e6d673b4bcc3e8a82a100f414ef0557` confirmed)" — this is true for the **backup**, not the post-Step-9 file. The post-Step-9 file happens to also weigh exactly 135,266 bytes by coincidence (additions cancelled the truncation by-bytes; the truncation lopped off roughly the same byte volume the four pulls added).

### What was lost

Lines from approximately HTML line 3086 onward in the backup (the equivalent of backup lines ~2642–3196, about 554 lines of baseline content). This includes, at minimum:

- The completion of `drawWorldNear` (factory-body LOS occlusion, factory rect render).
- Drone rendering (`drawDrones`, `drawSubCamCone`).
- HUD render (`drawHUD`).
- Top-level UI overlay rendering and warning banners.
- `applyInertia` (only partial — its definition appears before the cut, but Pull 4 also added a silent-running early-return inside it; without verifying the function fully closed, cannot confirm).
- Touch-handler wiring (`wireTouchHandlers`, `joystickVectorToKeys`, the click registration block).
- Resize / orientation handlers.
- The `window.__sim` definition block (line 3030 of backup).
- The `state = newState(); requestAnimationFrame(frame);` boot sequence.

### What was preserved

The first ~3086 lines of HTML output. The new code from the four Step 9 pulls IS present in this region:

| Pull | Symbol | HTML line | Status |
|---|---|---|---|
| Pull 1 | `function hasActiveDetector()` | 1613 | present |
| Pull 1 | Kill-gate `_killGateActive = hasActiveDetector()` | 2240 | present |
| Pull 2 | `function shadowPolyForRect()` | 2744 | present |
| Pull 2 | Shadow-fill loop in `drawWorldNear` | 3076 (truncated mid-comment 10 lines later) | partial — loop body present, factory render after is cut |
| Pull 3 | `const AU = {` | 587 | present |
| Pull 4 | `NOISE_GAIN`, `NOISE_HEAR_MAX`, `SILENT_BIND_KEY` in TUNING | 560–563 | present |
| Pull 4 | `function noiseRForSub()` | 1643 | present |
| Pull 4 | `function toggleSilentRunning()` | 855 | present |
| Pull 4 | `Digit5` keybind branch | 887 | present |
| Pull 4 | `#btnSilent` mobile button DOM | 167 | present |
| Pull 4 | `btnSilent` entry in `TOUCH_ACTIONS` | 989 | present |
| Noise-investigate loop in `update()` | `_noiseR = noiseRForSub(state.sub)` | 2316 | present |

So the build agent's edit logic is mostly intact for the four pulls; the final-write delivery is what corrupted the file.

---

## Invariant checks

All checks below are **N/A — UNVERIFIABLE** because the script does not parse. Reporting the closest thing to evidence rather than fabricating PASS marks.

| Invariant | Status | Evidence |
|---|---|---|
| 1. No enemy HP / no player kill-path | **UNVERIFIABLE** | Source for `hasActiveDetector()` (line 1613) is read-only on Sirens — no HP keys added in the surviving portion. But the full Siren / drone / factory render loop is truncated; cannot confirm no kill-path introduced downstream. Pre-Step-9 baseline was PASS; nothing in the surviving Step-9 additions introduces HP. **Likely held had the file been complete.** |
| 2. Suspicion is the spine | **UNVERIFIABLE** | Threshold constants (34/75/100) untouched in TUNING (verified lines 530–565). `applySuspicion` chokepoint inherited. Beat-on-rising-edge wiring at line ~2240 is present. Cannot run sims to confirm. |
| 3. Perceiving costs | **UNVERIFIABLE** | Ping/EMP/KD/Jam/Recon cost constants present in TUNING. No new free reveal added in surviving region. Pull 4's noise mechanic does not raise suspicion directly — it stamps `invX/invY/invT`. Surviving source matches brief. |
| 4. Tools buy time and cost heat | **UNVERIFIABLE** | All charge counts + costs unchanged in surviving TUNING block. |
| 5. Fairness valve | **UNVERIFIABLE** | Kill-gate code present at line 2240; `_killGateActive` branch reads correct. Cannot drive a sim because `__sim` block is missing and script doesn't parse. |
| 6. Function before form | **PASS (in surviving region)** | No `<audio>`, `<video>`, `<img>`, `@font-face`, `@keyframes`, `animation:`, `transition:` introduced. AU module is procedural Web Audio (per v0.3 carve-out). SILENT HUD indicator is monospace text per brief. Shadow fill is `rgba(8, 14, 22, ...)` per brief — legibility geometry, not chrome. |

---

## Step scope check

| Check | Status | Evidence |
|---|---|---|
| Stayed within Step 9 scope (four ratified pulls) | **PASS (intent)** | Code present implements exactly the four pulls from brief 09 §1. No HUNT meter, no graze damage, no 4th Siren, no thermal/currents, no narrative logs. |
| File deliverable complete | **FAIL** | File is truncated; deliverable is broken. |

---

## Code hygiene checks

| Check | Status | Evidence |
|---|---|---|
| Syntax valid | **FAIL** | `node --check` on extracted JS: **SyntaxError: Unexpected end of input** at line 2911 of script (HTML line 3086). |
| File has closing tags (`</script>`, `</body>`, `</html>`) | **FAIL** | Counts: 0 / 0 / 0. Last 10 bytes of file: `factory ed` (no newline). |
| Single file at `code/sirens_song.html` | **PASS** | One file; backups in place. |
| Backup md5 verifies | **PASS** | `code/sirens_song.html.bak.pre-step9-20260605` md5 = `9e6d673b4bcc3e8a82a100f414ef0557` matches handoff claim and matches Step-8 closed state. |
| Spec patch present | **PARTIAL** | Brief asked for "Spec append-only" — handoff claims `SIRENS_SONG_SPEC.md (Step 9 patch section appended at bottom)`. Reality: `SIRENS_SONG_SPEC.md` tail is unchanged from v0.2 decision log; the patch is in the sidecar `SIRENS_SONG_SPEC_STEP9_PATCH.md` (5,061 bytes). The Auditor Brief §"Spec file note" anticipated this fallback, so this is a deferred Pat-merge item, not a fail. Handoff text is misleading; sidecar exists. |
| No fabricated tuning numbers | **PASS (in surviving region)** | Four new constants documented in handoff with rationale: `NOISE_GAIN=4.5` (FLAG playtest), `NOISE_HEAR_MAX=360` (matches v7), `NOISE_INVESTIGATE_WINDOW_SEC=2.5` (DEFAULT), `SILENT_BIND_KEY="Digit5"` (DEFAULT next unused). |
| Invariant comments present where critical | **PASS (in surviving region)** | INV5 cited at `hasActiveDetector` site (line ~1593) and at kill-gate (line ~2230); INV1/INV4 cited where pull 4 stamps Siren invX/invY/invT fields. |

---

## Handoff completeness checks

| Check | Status | Evidence |
|---|---|---|
| All required fields per `agent.md` §5.2 | **PASS** | What I built / State of the file / Spec sections implemented / Tuning values used / Sim tests run / Open potholes / Design improvement notes / Invariant adherence / Receipt all present. |
| Tuning values documented | **PASS** | Step 7 table preserved-by-reference; four new Step 9 constants listed with rationale + spec citation. |
| Sim tests logged | **PASS (handoff section); FAIL (auditor cannot re-run)** | Handoff lists 18 sanity-sim PASS results. None of the listed sims can be re-run because the script doesn't parse — the build agent's reported PASSes are unverifiable from the delivered artifact. |
| Receipt present | **PASS** | "Step 09: COMPLETE -- READY FOR AUDIT." |
| File size / line count claim matches reality | **FAIL** | Handoff: "~151 KB / 3,659 lines". Reality: 135,266 B / 3,086 lines. |
| Post-edit `node --check` verified by build agent | **FAIL (handoff says "Audit step should re-run `node --check` to confirm" — implying not run)** | Handoff explicitly defers `node --check` to the auditor. Auditor ran it: SyntaxError. Build agent did not catch the truncation before declaring complete. |

---

## Sim tests I ran

| Test | Expected | Result |
|---|---|---|
| `node --check` on extracted script from post-Step-9 file | EXIT 0 | **FAIL** — SyntaxError: Unexpected end of input |
| `node --check` on extracted script from `.bak.pre-step9-20260605` | EXIT 0 | **PASS** (baseline parses clean — rollback target is good) |
| File has `</html>` | 1 occurrence | **FAIL** — 0 occurrences |
| File has `</script>` | 1 occurrence | **FAIL** — 0 occurrences |
| File has `</body>` | 1 occurrence | **FAIL** — 0 occurrences |
| Last 10 bytes of file end in `</html>\n` or similar | yes | **FAIL** — ends with `factory ed` (no newline) |
| Pull 1: `hasActiveDetector` function defined | yes | PASS (line 1613) |
| Pull 1: Kill-gate references `hasActiveDetector()` | yes | PASS (line 2240) |
| Pull 2: `shadowPolyForRect` function defined | yes | PASS (line 2744) |
| Pull 2: Shadow-fill called in `drawWorldNear` | yes | PASS (line 3076 — but truncated mid-loop completion / before factory body render) |
| Pull 3: `const AU = {` defined | yes | PASS (line 587) |
| Pull 4: New TUNING constants present | yes | PASS (lines 560–563) |
| Pull 4: `noiseRForSub` defined | yes | PASS (line 1643) |
| Pull 4: `toggleSilentRunning` defined | yes | PASS (line 855) |
| Pull 4: `Digit5` keybind in keydown listener | yes | PASS (line 887) |
| Pull 4: `#btnSilent` button in DOM | yes | PASS (line 167) |
| Pull 4: `btnSilent` in TOUCH_ACTIONS map | yes | PASS (line 989) |
| `__sim` block present | yes | **FAIL** — `window.__sim = {` not found anywhere; only commentary refs. The entire `__sim` surface is in the truncated tail. |
| Regression — Step 8's 53-sim battery re-run | 53 PASS / 0 FAIL | **N/A** — cannot run; script doesn't parse and no `__sim` surface |
| Regression — Steps 1-7 (sub physics, sonar, hunter AI, suspicion thresholds, drone timings, recon timings) | parity with backup | **N/A** — cannot run |
| Step 9 gate sims (Pull 1: kill-gate truth table; Pull 2: polygon corner geometry; Pull 3: AU mock-context safety + seam wiring; Pull 4: noise math at 0/40/80, silent toggle, mobile button) | per Auditor Brief Step-9 section | **N/A** — cannot run |
| Desktop byte-equivalence check (Step 8 hard constraint inherited) | Pre-Step-9 keydown branches unchanged; only `Digit5` added | **PARTIAL PASS** — source inspection shows `Digit5` branch appended after existing branches (line 887); existing branches present in surviving region. Cannot programmatically diff because file doesn't parse. |

---

## Adversarial sims

| Attack | Result |
|---|---|
| Load `code/sirens_song.html` in a browser | Would fail — `<script>` unterminated. Browser will error or render only the head/body up to the script open tag; subsequent inline script never finishes parsing; no game runs. |
| Try the four ratified mechanics in playtest | **N/A** — game does not boot. |
| Try to find a regression hidden in the surviving 3086 lines | Surviving region matches the pulls described in the brief. Inline LOS/raycast/suspicion math is byte-equivalent to baseline in the surviving region (verified by spot-comparing `applySuspicion`, `suspicionState`, `tryActivePing`, `fireEMP`, `fireKnockdown`, `tryActivePing` against backup at same line ranges). The damage is purely a truncation event, not a logic regression. |

---

## Pull-by-pull mapping (intent vs delivered)

For completeness — what the build agent **intended** vs **what survives in the file**:

### Pull 1 — EMP / kill-rule fix
- Intent: `hasActiveDetector()` predicate + gate in `update()`.
- Delivered: predicate present (line 1613). Gate present (line 2240, `_killGateActive` branch).
- Cannot exercise — `update()` body completes past the gate, but the renderer below the gate breaks the script.
- **Verdict: source intent looks correct; cannot test.**

### Pull 2 — Shadow-cone LOS rendering
- Intent: `shadowPolyForRect()` helper + fill pass in `drawWorldNear`.
- Delivered: helper present (line 2744). Fill loop present in `drawWorldNear` (line 3076).
- The shadow loop body (lines 3076–3084) appears complete. The truncation is INSIDE the comment that begins the factory-body render block that follows the shadow loop — i.e., the shadow loop closes cleanly, but the factory block (whose comment opens "Factory body: LOS-gated. Test against the nearest point on the / factory rect from the reveal center. Skip the factory rect itself / in the LOS check (a ray that ends on the factory ed[GE OF THE FACTORY IS NOT A HIT])") never finishes. The function `drawWorldNear` has no closing `}`.
- **Verdict: shadow loop landed; downstream render path collapsed.**

### Pull 3 — Procedural Web Audio (AU)
- Intent: `AU` const + gesture-init + seam wiring at 8 sites.
- Delivered: `AU` const present (line 587). `_au_first_gesture()` referenced from `btnSilent` action (line 989). Seam wires at `tryActivePing` / `fireEMP` / `fireKnockdown` / `tryDronePhoto` / `trySubCamPhoto` are in the surviving region; the win-extract `AU.surface()` and lose-vaporized `AU.boom()` seams MAY be in the truncated tail (the lose handler typically sits in the late `update()` body — depending on file layout, this could be either preserved or lost).
- Cannot exercise — no Audio init runs in a non-parsing script.
- **Verdict: module + early seams landed; some seams may be in the truncated tail.**

### Pull 4 — Speed-as-noise + silent running
- Intent: TUNING constants + `noiseRForSub()` + `toggleSilentRunning()` + noise loop in `update()` + Digit5 keybind + mobile `#btnSilent` + `applyInertia` silent-running early-return + HUD "SILENT" indicator.
- Delivered: constants present. Helpers present. Noise loop in `update()` present (line 2316). Digit5 in keydown listener present. `#btnSilent` DOM element present. `TOUCH_ACTIONS.btnSilent` present.
- `applyInertia` silent-running early-return: cannot confirm — `applyInertia` is defined before the cut; need to verify the early-return was inserted. (Spot-checked: line 2580 has `applyInertia` comment header for `__sim.applyInertia` reference; the function body should be just above. The early-return per the handoff is at the top of `applyInertia`. Not exhaustively diffed against backup due to file corruption blocking the audit pipeline.)
- HUD "SILENT" indicator render: in the truncated tail (HUD render is near the bottom of the file).
- **Verdict: most of Pull 4 landed; HUD indicator likely lost in truncation.**

---

## Verdict

**RED — REGRESSION DETECTED, ROLL BACK.**

The Step 9 patch should be **rolled back to `code/sirens_song.html.bak.pre-step9-20260605`** (md5 `9e6d673b4bcc3e8a82a100f414ef0557`, verified clean parse). The current `code/sirens_song.html` is unusable: it is truncated mid-comment in `drawWorldNear`, has no closing `</script>` / `</body>` / `</html>` tags, and fails `node --check` with "SyntaxError: Unexpected end of input."

This is **not a logic regression**. The build agent's source intent for all four pulls is visible in the surviving 3086 lines, and that intent aligns with brief 09 §1. The damage appears to be a final-write delivery event: the file was written with the additions in place but the tail of the source (factory render through `__sim` and boot) was not included in the write payload. By byte-coincidence the truncated payload weighs exactly 135,266 bytes — the same as the backup — which obscures the truncation from a `ls -la` glance. The handoff's stated "~151 KB / 3,659 lines" is fictional; the file is 135,266 B / 3,086 lines.

### Recommended remediation

1. **Roll back code:** copy `code/sirens_song.html.bak.pre-step9-20260605` over `code/sirens_song.html`. This restores Step 8 GREENLIGHT state.
2. **Re-fire Step 9 build** with a fresh agent. Required additions to the brief:
   - The agent MUST run `node --check` on the extracted script body BEFORE declaring complete.
   - The agent MUST verify `tail -c 50 code/sirens_song.html` ends with `</html>\n` (or `</html>`) BEFORE declaring complete.
   - The agent MUST verify the file's line count and byte count both **exceed** the backup's by a margin consistent with the claimed additions (handoff said +463 lines / +16 KB — neither was true).
3. **Investigate the write mechanism.** This kind of silent truncation suggests either an Edit-tool failure mode (partial replace), a Write-tool chunking failure, or a context-window limit hit mid-write. The next agent should consider whether to use multiple targeted `Edit` calls (replacing only the regions that need to change) rather than a single full-file `Write` for a file of this size.
4. **No fix-pass on the truncated file.** The truncated artifact cannot be repaired in-place by patching the tail back on, because the auditor cannot know whether the source-of-truth for the truncated region included Step 9 additions that needed to land there (e.g., `AU.boom()` / `AU.surface()` wires near lose / win handlers; HUD "SILENT" indicator; silent-state branch in `applyInertia`; `__sim` superset additions). The rollback + re-fire is cleaner than an attempted patch-restore.
5. **Spec patch sidecar:** `SIRENS_SONG_SPEC_STEP9_PATCH.md` exists at root (5,061 bytes). The Auditor Brief §"Spec file note" anticipated this; the patch can be merged by Pat (or by a future build agent with the spec lock cleared) into `SIRENS_SONG_SPEC.md`. The handoff's claim that the spec was patched in-place is incorrect; the sidecar is the actual delivery.

### Why this is RED, not FIX REQUIRED

A FIX REQUIRED verdict implies a targeted correction within the step's scope by the same or next agent. Here:
- The deliverable is broken at the file-integrity level — no surgical fix is appropriate when the file's closing tags are missing.
- The build agent already declared complete without a `node --check` sanity. Trusting a re-attempt by the same agent without procedural changes risks the same failure mode.
- Step 9 is a **post-leash ratification pull-in** (not part of the spec's 7-step build), so the orchestrator decision is whether to re-fire from `.bak.pre-step9-20260605` or hold and surface to Pat. RED expresses that: the patch in its delivered form is not usable; the chain should reset and decide.

### If FIX REQUIRED — N/A (escalated to RED)
### If PAT INTERVENTION — N/A (no spec ambiguity or invariant tension; this is purely a delivery failure)

---

## Notes for the orchestrator

- **Rollback path:** `cp code/sirens_song.html.bak.pre-step9-20260605 code/sirens_song.html`. Verify `md5sum code/sirens_song.html` returns `9e6d673b4bcc3e8a82a100f414ef0557` post-copy.
- **Step 8 closed state remains the canonical playable build** until Step 9 re-fires successfully or Pat rules differently.
- The build agent's task list (`task #6` through `#10`) shows all four pulls + deliverables marked "completed" — those completion marks were premature; the file integrity check was skipped.
- The sidecar `SIRENS_SONG_SPEC_STEP9_PATCH.md` does NOT need to be rolled back — it's standalone documentation that survives even if the code regresses.
- `briefs/09_v03_pullin_patch.md` and `handoffs/09_HANDOFF_FROM_STEP9.md` are correctly authored and should remain on disk for the re-fire to reference.

---

## Receipt

- Audit complete: YES
- Verdict: **RED — ROLL BACK**
- Orchestrator action: **ROLL BACK `code/sirens_song.html` TO `.bak.pre-step9-20260605`. RE-FIRE STEP 9 WITH HARDENED COMPLETION GATE (mandatory `node --check` and `tail`-tag verification before declaring complete).**
- Blocking flag for Pat: a Step 9 build agent declared complete on a truncated file. Next attempt needs a hard completion gate.

---

*AI-DESIGNED. Auditor: sharp-magical-dirac (Cowork Dispatch child, Claude Opus 4.7-1M, 1M context). Authority: `SIRENS_SONG_SPEC.md` > `agent.md` > `briefs/AUDITOR_BRIEF.md` > `briefs/09_v03_pullin_patch.md` > `handoffs/09_HANDOFF_FROM_STEP9.md` > current code. Audit verifies, does not modify code. This audit recommends rollback and re-fire; the orchestrator routes.*
