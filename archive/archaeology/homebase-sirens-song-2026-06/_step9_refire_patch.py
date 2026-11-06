#!/usr/bin/env python3
"""
Step 9 RE-FIRE patch script.

Applies the 4 pulls into code/sirens_song.html in a single atomic batch by
reading the file once, performing in-memory string replacements, and writing
the result back. Bypasses the Edit-tool/FUSE-cache issue that truncated the
first attempt.
"""

import hashlib
import os
import sys

SRC = "code/sirens_song.html"
BASELINE_MD5 = "9e6d673b4bcc3e8a82a100f414ef0557"

def main():
    with open(SRC, "rb") as f:
        raw = f.read()
    actual_md5 = hashlib.md5(raw).hexdigest()
    print(f"  source: {SRC}")
    print(f"  bytes: {len(raw)}")
    print(f"  md5: {actual_md5}")
    text = raw.decode("utf-8")

    edits = []

    # EDIT 1: TUNING constants for Pull 4
    edit1_old = "  RECON_REVEAL_RADIUS_PX: 460,           // step 7 tuned\n};\n"
    edit1_new = (
        "  RECON_REVEAL_RADIUS_PX: 460,           // step 7 tuned\n"
        "\n"
        "  // ===================================================================\n"
        "  // step 9 v0.3 pull-in 2026-06-05 (Pull 4 -- speed-as-noise + silent\n"
        "  // running). Spec v0.3 section 6: throttle generates a noise signature\n"
        "  // that feeds Siren detection; a silent toggle zeroes both speed and\n"
        "  // noise. Brief 09 section 1 Pull 4 picks NOISE_GAIN=4.5 so the sub at\n"
        "  // terminal speed (SUB_SPEED_PX_PER_SEC=80) gives a ~360 px noise\n"
        "  // radius matching v7's noiseHearMax. SILENT_BIND_KEY is the new desktop\n"
        "  // binding (Digit5); a new mobile button #btnSilent is additive to the\n"
        "  // Step 8 tray. INV4 -- noise is silent cost of throttle.\n"
        "  // -------------------------------------------------------------------\n"
        "  NOISE_GAIN: 4.5,\n"
        "  NOISE_HEAR_MAX: 360,\n"
        "  SILENT_BIND_KEY: \"Digit5\",\n"
        "};\n"
    )
    edits.append(("TUNING Pull 4 constants", edit1_old, edit1_new))

    # EDIT 2: AU module after TUNING
    edit2_old = (
        "  NOISE_GAIN: 4.5,\n"
        "  NOISE_HEAR_MAX: 360,\n"
        "  SILENT_BIND_KEY: \"Digit5\",\n"
        "};\n"
        "\n"
        "/* ----- Terrain (unchanged from step 1; step 2 verified patroller route\n"
    )
    edit2_new = (
        "  NOISE_GAIN: 4.5,\n"
        "  NOISE_HEAR_MAX: 360,\n"
        "  SILENT_BIND_KEY: \"Digit5\",\n"
        "};\n"
        "\n"
        "/* =====================================================================\n"
        " * Step 9 v0.3 pull-in 2026-06-05 (Pull 3 -- procedural Web Audio).\n"
        " * Ported from sirens_song_prototype_v7.html lines 126-151. Spec v0.3\n"
        " * section 6: Audio and noise are core systems, not polish. Wired at the\n"
        " * seven event seams in brief 09 section 1 Pull 3:\n"
        " *   ping / emp / knock / cap / boom / surface / startAmb (+ beat).\n"
        " * Gesture-initialized on first keydown; fail-safe try/catch (no AU == no\n"
        " * crash; game runs normally). INV6: audio is a core pillar per v0.3.\n"
        " * ------------------------------------------------------------------- */\n"
        "const AU = {\n"
        "  ctx: null, master: null, amb: null, muted: false,\n"
        "  init() {\n"
        "    if (this.ctx) return;\n"
        "    try {\n"
        "      this.ctx = new (window.AudioContext || window.webkitAudioContext)();\n"
        "      this.master = this.ctx.createGain();\n"
        "      this.master.gain.value = 0.32;\n"
        "      this.master.connect(this.ctx.destination);\n"
        "    } catch (e) { this.ctx = null; }\n"
        "  },\n"
        "  resume() {\n"
        "    try { if (this.ctx && this.ctx.state === \"suspended\") this.ctx.resume(); }\n"
        "    catch (e) { /* noop */ }\n"
        "  },\n"
        "  tone(f, dur, type, vol, slide) {\n"
        "    if (!this.ctx || this.muted) return;\n"
        "    try {\n"
        "      const t = this.ctx.currentTime;\n"
        "      const o = this.ctx.createOscillator();\n"
        "      const g = this.ctx.createGain();\n"
        "      o.type = type || \"sine\";\n"
        "      o.frequency.setValueAtTime(f, t);\n"
        "      if (slide) o.frequency.exponentialRampToValueAtTime(slide, t + dur);\n"
        "      g.gain.setValueAtTime(0.0001, t);\n"
        "      g.gain.linearRampToValueAtTime(vol || 0.25, t + 0.012);\n"
        "      g.gain.exponentialRampToValueAtTime(0.0001, t + dur);\n"
        "      o.connect(g); g.connect(this.master);\n"
        "      o.start(t); o.stop(t + dur + 0.03);\n"
        "    } catch (e) { /* noop */ }\n"
        "  },\n"
        "  noise(dur, vol) {\n"
        "    if (!this.ctx || this.muted) return;\n"
        "    try {\n"
        "      const t = this.ctx.currentTime;\n"
        "      const b = this.ctx.createBuffer(1, this.ctx.sampleRate * dur, this.ctx.sampleRate);\n"
        "      const d = b.getChannelData(0);\n"
        "      for (let i = 0; i < d.length; i++) d[i] = Math.random() * 2 - 1;\n"
        "      const s = this.ctx.createBufferSource();\n"
        "      s.buffer = b;\n"
        "      const g = this.ctx.createGain();\n"
        "      g.gain.setValueAtTime(vol || 0.2, t);\n"
        "      g.gain.exponentialRampToValueAtTime(0.0001, t + dur);\n"
        "      const f = this.ctx.createBiquadFilter();\n"
        "      f.type = \"lowpass\"; f.frequency.value = 1400;\n"
        "      s.connect(f); f.connect(g); g.connect(this.master);\n"
        "      s.start(t); s.stop(t + dur);\n"
        "    } catch (e) { /* noop */ }\n"
        "  },\n"
        "  ping()    { this.tone(880, 0.5, \"sine\", 0.22, 300); },\n"
        "  emp()     { this.noise(0.35, 0.28); this.tone(130, 0.3, \"square\", 0.18, 55); },\n"
        "  knock()   { this.tone(90, 0.55, \"sine\", 0.3, 38); },\n"
        "  decoy()   { this.tone(560, 0.25, \"triangle\", 0.16, 720); },\n"
        "  drone()   { this.tone(700, 0.18, \"square\", 0.12, 900); },\n"
        "  cap()     { this.tone(1500, 0.07, \"square\", 0.18); this.tone(2200, 0.05, \"square\", 0.12); },\n"
        "  boom()    { this.noise(0.8, 0.5); this.tone(60, 0.9, \"sine\", 0.4, 28); },\n"
        "  surface() { this.tone(380, 0.7, \"sine\", 0.22, 820); },\n"
        "  beat(host){ this.tone(host ? 230 : 150, 0.12, \"sine\", 0.16); },\n"
        "  startAmb() {\n"
        "    if (!this.ctx || this.amb) return;\n"
        "    try {\n"
        "      const o = this.ctx.createOscillator();\n"
        "      const g = this.ctx.createGain();\n"
        "      o.type = \"sine\"; o.frequency.value = 44;\n"
        "      g.gain.value = 0.10;\n"
        "      o.connect(g); g.connect(this.master);\n"
        "      o.start();\n"
        "      this.amb = { o, g };\n"
        "    } catch (e) { /* noop */ }\n"
        "  },\n"
        "  stopAmb() {\n"
        "    if (this.amb) { try { this.amb.o.stop(); } catch (e) { /* noop */ } this.amb = null; }\n"
        "  }\n"
        "};\n"
        "\n"
        "/* ----- Terrain (unchanged from step 1; step 2 verified patroller route\n"
    )
    edits.append(("AU module (Pull 3)", edit2_old, edit2_new))

    # EDIT 3: silentRunning field in newState
    edit3_old = (
        "    reconCharges: TUNING.RECON_CHARGES_INITIAL,\n"
        "    reconReveals: [],\n"
        "  };\n"
        "}\n"
    )
    edit3_new = (
        "    reconCharges: TUNING.RECON_CHARGES_INITIAL,\n"
        "    reconReveals: [],\n"
        "\n"
        "    // step 9 v0.3 pull-in 2026-06-05 (Pull 4 -- silent running).\n"
        "    // When true: applyInertia zeroes velocity each tick; noiseRForSub\n"
        "    // returns 0; oxygen drain continues. Toggle bound to\n"
        "    // TUNING.SILENT_BIND_KEY (Digit5) and to #btnSilent. INV4.\n"
        "    silentRunning: false,\n"
        "  };\n"
        "}\n"
    )
    edits.append(("silentRunning in newState", edit3_old, edit3_new))

    # EDIT 4: AU gesture-init in keydown
    edit4_old = (
        "/* ----- Input --------------------------------------------------------- */\n"
        "const keys = new Set();\n"
        "window.addEventListener(\"keydown\", (e) => {\n"
        "  keys.add(e.code);\n"
        "  if (e.code === \"Space\") tryActivePing();\n"
    )
    edit4_new = (
        "/* ----- Input --------------------------------------------------------- */\n"
        "const keys = new Set();\n"
        "window.addEventListener(\"keydown\", (e) => {\n"
        "  // Step 9 v0.3 pull-in (Pull 3 -- AU gesture-init).\n"
        "  AU.init();\n"
        "  AU.resume();\n"
        "  if (!AU.amb) AU.startAmb();\n"
        "  keys.add(e.code);\n"
        "  if (e.code === \"Space\") tryActivePing();\n"
    )
    edits.append(("keydown AU gesture-init", edit4_old, edit4_new))

    # EDIT 5: Digit5 silent toggle in keydown
    edit5_old = (
        "  if (e.code === \"Digit4\") {\n"
        "    state.armedTool = (state.armedTool === \"recon\") ? null : \"recon\";\n"
        "  }\n"
        "  if (e.code === \"Escape\") state.armedTool = null;\n"
    )
    edit5_new = (
        "  if (e.code === \"Digit4\") {\n"
        "    state.armedTool = (state.armedTool === \"recon\") ? null : \"recon\";\n"
        "  }\n"
        "  // Step 9 v0.3 pull-in (Pull 4 -- silent running toggle). Additive.\n"
        "  if (e.code === TUNING.SILENT_BIND_KEY) toggleSilentRunning();\n"
        "  if (e.code === \"Escape\") state.armedTool = null;\n"
    )
    edits.append(("Digit5 silent toggle", edit5_old, edit5_new))

    # EDIT 6: hasActiveDetector + noiseRForSub + toggleSilentRunning helpers
    # placed just before update() function.
    edit6_old = "/* ----- Update loop ------------------------------------------------- */\nfunction update(dt) {\n"
    edit6_new = (
        "/* =====================================================================\n"
        " * Step 9 v0.3 pull-in 2026-06-05 (Pull 1 -- EMP / kill-rule fix).\n"
        " * hasActiveDetector returns true iff at least one Siren is un-stunned,\n"
        " * within its per-type detection radius of the sub, AND has line-of-\n"
        " * sight to the sub. Per-type radii per brief 09 section 1 Pull 1:\n"
        " *   Patroller: PATROL_RADIUS_PX + 180 (=194 px)\n"
        " *   Sentinel:  SENTINEL_DETECT_RADIUS_PX (=220 px)\n"
        " *   Hunter:    HUNTER_PROXIMITY_RANGE_PX (=200 px)\n"
        " * INV5 fairness valve: vaporize at sustained SUSP_MAX requires an\n"
        " * active LOS detector; if all detectors stunned, the kill timer\n"
        " * PAUSES (no advance, no reset) until re-acquisition.\n"
        " * ------------------------------------------------------------------- */\n"
        "function hasActiveDetector() {\n"
        "  const sx = state.sub.x, sy = state.sub.y;\n"
        "  const candidates = [\n"
        "    { siren: state.patroller, radius: TUNING.PATROL_RADIUS_PX + 180 },\n"
        "    { siren: state.sentinel,  radius: TUNING.SENTINEL_DETECT_RADIUS_PX },\n"
        "    { siren: state.hunter,    radius: TUNING.HUNTER_PROXIMITY_RANGE_PX },\n"
        "  ];\n"
        "  for (const c of candidates) {\n"
        "    const s = c.siren;\n"
        "    if (!s) continue;\n"
        "    if (isSirenStunned(s)) continue;                  // (a) INV5\n"
        "    const dx = s.x - sx, dy = s.y - sy;\n"
        "    if (dx * dx + dy * dy > c.radius * c.radius) continue;  // (b)\n"
        "    if (!isLineOfSightClear(s.x, s.y, sx, sy)) continue;    // (c)\n"
        "    return true;\n"
        "  }\n"
        "  return false;\n"
        "}\n"
        "\n"
        "/* =====================================================================\n"
        " * Step 9 v0.3 pull-in 2026-06-05 (Pull 4 -- noise + silent helpers).\n"
        " * noiseRForSub: omnidirectional noise radius. Silent => 0. Otherwise\n"
        " *   clamp(speed * NOISE_GAIN, 0, NOISE_HEAR_MAX).\n"
        " * toggleSilentRunning: flips state.silentRunning, refreshes touch UI.\n"
        " * INV4: noise is the silent cost of throttle (no flat suspicion bump).\n"
        " * ------------------------------------------------------------------- */\n"
        "function noiseRForSub(sub) {\n"
        "  if (state && state.silentRunning) return 0;\n"
        "  if (!sub) return 0;\n"
        "  const speed = Math.hypot(sub.vx || 0, sub.vy || 0);\n"
        "  const r = speed * TUNING.NOISE_GAIN;\n"
        "  return r > TUNING.NOISE_HEAR_MAX ? TUNING.NOISE_HEAR_MAX : (r < 0 ? 0 : r);\n"
        "}\n"
        "\n"
        "function toggleSilentRunning() {\n"
        "  if (!state) return false;\n"
        "  state.silentRunning = !state.silentRunning;\n"
        "  if (typeof refreshTouchArmedUI === \"function\") refreshTouchArmedUI();\n"
        "  return state.silentRunning;\n"
        "}\n"
        "\n"
        "/* ----- Update loop ------------------------------------------------- */\n"
        "function update(dt) {\n"
    )
    edits.append(("hasActiveDetector + Pull 4 helpers", edit6_old, edit6_new))

    # EDIT 7: vaporize gate on hasActiveDetector + AU.boom seam
    edit7_old = (
        "  /* ----- step 2 fairness valve (BEFORE decay -- see step 2 comment) ----- */\n"
        "  if (state.suspicion >= TUNING.SUSP_MAX) {\n"
        "    state.instakillTimer += dt;\n"
        "    if (state.instakillTimer >= TUNING.INSTAKILL_SUSTAIN_SEC) {\n"
        "      state.loseReason = \"vaporized\";\n"
        "    }\n"
        "  } else {\n"
        "    state.instakillTimer = 0;\n"
        "  }\n"
    )
    edit7_new = (
        "  /* ----- step 2 fairness valve (BEFORE decay) -- Step 9 Pull 1 gate ---\n"
        "   * INV5: vaporize at sustained SUSP_MAX requires hasActiveDetector().\n"
        "   * No detector -> timer PAUSES (no advance, no reset). Below SUSP_MAX\n"
        "   * timer resets (Step 2 behavior unchanged).\n"
        "   * ---------------------------------------------------------------- */\n"
        "  if (state.suspicion >= TUNING.SUSP_MAX) {\n"
        "    if (hasActiveDetector()) {\n"
        "      state.instakillTimer += dt;\n"
        "      if (state.instakillTimer >= TUNING.INSTAKILL_SUSTAIN_SEC) {\n"
        "        state.loseReason = \"vaporized\";\n"
        "        if (typeof AU !== \"undefined\") AU.boom();  // Pull 3 audio seam\n"
        "      }\n"
        "    }\n"
        "    // else: paused -- timer holds.\n"
        "  } else {\n"
        "    state.instakillTimer = 0;\n"
        "  }\n"
    )
    edits.append(("vaporize gate + AU.boom", edit7_old, edit7_new))

    # EDIT 8: applyInertia silent gate
    edit8_old = (
        "function applyInertia(dt, thrust, turn) {\n"
        "  const s = state.sub;\n"
        "\n"
        "  // --- linear ---\n"
    )
    edit8_new = (
        "function applyInertia(dt, thrust, turn) {\n"
        "  const s = state.sub;\n"
        "\n"
        "  // Step 9 v0.3 pull-in (Pull 4 -- silent running). Sub freezes.\n"
        "  if (state.silentRunning) {\n"
        "    s.vx = 0; s.vy = 0; s.angularVel = 0;\n"
        "    return;\n"
        "  }\n"
        "\n"
        "  // --- linear ---\n"
    )
    edits.append(("applyInertia silent gate", edit8_old, edit8_new))

    # EDIT 9: tryActivePing AU seam
    edit9_old = (
        "function tryActivePing() {\n"
        "  if (state.loseReason || state.winState) return;\n"
        "  state.ping.tStart = state.timeSec;\n"
        "  state.ping.originX = state.sub.x;\n"
        "  state.ping.originY = state.sub.y;\n"
        "  applySuspicion(TUNING.SUSP_PING_COST, \"active_ping\");\n"
        "  state.lastPing.x = state.sub.x;\n"
        "  state.lastPing.y = state.sub.y;\n"
        "  state.lastPing.valid = true;\n"
        "}\n"
    )
    edit9_new = (
        "function tryActivePing() {\n"
        "  if (state.loseReason || state.winState) return;\n"
        "  state.ping.tStart = state.timeSec;\n"
        "  state.ping.originX = state.sub.x;\n"
        "  state.ping.originY = state.sub.y;\n"
        "  applySuspicion(TUNING.SUSP_PING_COST, \"active_ping\");\n"
        "  state.lastPing.x = state.sub.x;\n"
        "  state.lastPing.y = state.sub.y;\n"
        "  state.lastPing.valid = true;\n"
        "  if (typeof AU !== \"undefined\") AU.ping();  // Pull 3 audio seam\n"
        "}\n"
    )
    edits.append(("AU.ping seam", edit9_old, edit9_new))

    # EDIT 10: fireEMP AU seam
    edit10_old = (
        "  applySuspicion(TUNING.EMP_SUSP_COST, \"emp_fire\");\n"
        "  return target;\n"
        "}\n"
        "\n"
        "function fireKnockdown(targetX, targetY) {\n"
    )
    edit10_new = (
        "  applySuspicion(TUNING.EMP_SUSP_COST, \"emp_fire\");\n"
        "  if (typeof AU !== \"undefined\") AU.emp();  // Pull 3 audio seam\n"
        "  return target;\n"
        "}\n"
        "\n"
        "function fireKnockdown(targetX, targetY) {\n"
    )
    edits.append(("AU.emp seam", edit10_old, edit10_new))

    # EDIT 11: fireKnockdown AU seam
    edit11_old = (
        "  applySuspicion(TUNING.KNOCKDOWN_SUSP_COST, \"knockdown_fire\");\n"
        "  return target;\n"
        "}\n"
    )
    edit11_new = (
        "  applySuspicion(TUNING.KNOCKDOWN_SUSP_COST, \"knockdown_fire\");\n"
        "  if (typeof AU !== \"undefined\") AU.knock();  // Pull 3 audio seam\n"
        "  return target;\n"
        "}\n"
    )
    edits.append(("AU.knock seam", edit11_old, edit11_new))

    # EDIT 12: tryDronePhoto AU.cap seam
    edit12_old = (
        "  if (captured) {\n"
        "    applySuspicion(TUNING.DRONE_PHOTO_COST, \"drone_photo\");\n"
        "    return captured;\n"
        "  }\n"
        "  return null;\n"
        "}\n"
        "\n"
        "function trySubCamPhoto() {\n"
    )
    edit12_new = (
        "  if (captured) {\n"
        "    applySuspicion(TUNING.DRONE_PHOTO_COST, \"drone_photo\");\n"
        "    if (typeof AU !== \"undefined\") AU.cap();  // Pull 3 audio seam\n"
        "    return captured;\n"
        "  }\n"
        "  return null;\n"
        "}\n"
        "\n"
        "function trySubCamPhoto() {\n"
    )
    edits.append(("AU.cap drone", edit12_old, edit12_new))

    # EDIT 13: trySubCamPhoto AU.cap seam
    edit13_old = (
        "    if (dist <= range) {\n"
        "      o.captured = true;\n"
        "      // Spec section 6: sub-cam carries no flat photo cost. The\n"
        "      // proximity terms already running each tick are the cost.\n"
        "      return o;\n"
        "    }\n"
        "  }\n"
        "  return null;\n"
        "}\n"
    )
    edit13_new = (
        "    if (dist <= range) {\n"
        "      o.captured = true;\n"
        "      // Spec section 6: sub-cam carries no flat photo cost. The\n"
        "      // proximity terms already running each tick are the cost.\n"
        "      if (typeof AU !== \"undefined\") AU.cap();  // Pull 3 audio seam\n"
        "      return o;\n"
        "    }\n"
        "  }\n"
        "  return null;\n"
        "}\n"
    )
    edits.append(("AU.cap sub-cam", edit13_old, edit13_new))

    # EDIT 14: win AU.surface seam
    edit14_old = (
        "  const allRequired = state.objectives.every(o => o.captured);\n"
        "  if (allRequired) {\n"
        "    const dxe = state.sub.x - EXTRACTION.x;\n"
        "    const dye = state.sub.y - EXTRACTION.y;\n"
        "    if (dxe * dxe + dye * dye <= EXTRACTION.r * EXTRACTION.r) {\n"
        "      state.winState = true;\n"
        "    }\n"
        "  }\n"
    )
    edit14_new = (
        "  const allRequired = state.objectives.every(o => o.captured);\n"
        "  if (allRequired) {\n"
        "    const dxe = state.sub.x - EXTRACTION.x;\n"
        "    const dye = state.sub.y - EXTRACTION.y;\n"
        "    if (dxe * dxe + dye * dye <= EXTRACTION.r * EXTRACTION.r) {\n"
        "      const wasWin = state.winState;\n"
        "      state.winState = true;\n"
        "      if (!wasWin && typeof AU !== \"undefined\") AU.surface();  // Pull 3 seam\n"
        "    }\n"
        "  }\n"
    )
    edits.append(("AU.surface seam", edit14_old, edit14_new))

    # EDIT 15: shadowPolyForRect helper before drawWorldNear
    edit15_old = (
        "/* drawWorldNear -- draws terrain + factory + objectives within a clip\n"
        " * radius around (cx, cy). This is the unified \"things in this reveal\n"
        " * window\" pass; passive sonar, ping, and drone-cam all funnel through it.\n"
    )
    edit15_new = (
        "/* =====================================================================\n"
        " * Step 9 v0.3 pull-in 2026-06-05 (Pull 2 -- shadow-cone LOS rendering).\n"
        " * shadowPolyForRect(L, rect, far) returns a 4-pt shadow polygon for an\n"
        " * axis-aligned rect cast from origin L. Two silhouette corners are the\n"
        " * angular extremes (min/max polar angle from L); rays extend through\n"
        " * them to distance far. Returns null if L is inside the rect.\n"
        " * Render-only change; isLineOfSightClear / suspicion math unchanged.\n"
        " * INV1-INV4 untouched. INV6 legibility per spec v0.3 section 3.\n"
        " * ------------------------------------------------------------------- */\n"
        "function shadowPolyForRect(L, rect, far) {\n"
        "  if (L.x >= rect.x && L.x <= rect.x + rect.w &&\n"
        "      L.y >= rect.y && L.y <= rect.y + rect.h) return null;\n"
        "  const corners = [\n"
        "    { x: rect.x,          y: rect.y          },\n"
        "    { x: rect.x + rect.w, y: rect.y          },\n"
        "    { x: rect.x + rect.w, y: rect.y + rect.h },\n"
        "    { x: rect.x,          y: rect.y + rect.h },\n"
        "  ];\n"
        "  const cx = rect.x + rect.w / 2, cy = rect.y + rect.h / 2;\n"
        "  const refA = Math.atan2(cy - L.y, cx - L.x);\n"
        "  let minD = Infinity, maxD = -Infinity;\n"
        "  let cMin = corners[0], cMax = corners[0];\n"
        "  for (const c of corners) {\n"
        "    const a = Math.atan2(c.y - L.y, c.x - L.x);\n"
        "    let d = a - refA;\n"
        "    while (d >  Math.PI) d -= 2 * Math.PI;\n"
        "    while (d < -Math.PI) d += 2 * Math.PI;\n"
        "    if (d < minD) { minD = d; cMin = c; }\n"
        "    if (d > maxD) { maxD = d; cMax = c; }\n"
        "  }\n"
        "  const dx1 = cMin.x - L.x, dy1 = cMin.y - L.y;\n"
        "  const dx2 = cMax.x - L.x, dy2 = cMax.y - L.y;\n"
        "  const l1 = Math.hypot(dx1, dy1) || 1;\n"
        "  const l2 = Math.hypot(dx2, dy2) || 1;\n"
        "  const ex1 = L.x + (dx1 / l1) * far, ey1 = L.y + (dy1 / l1) * far;\n"
        "  const ex2 = L.x + (dx2 / l2) * far, ey2 = L.y + (dy2 / l2) * far;\n"
        "  return [ cMin, cMax, { x: ex2, y: ey2 }, { x: ex1, y: ey1 } ];\n"
        "}\n"
        "\n"
        "/* drawWorldNear -- draws terrain + factory + objectives within a clip\n"
        " * radius around (cx, cy). This is the unified \"things in this reveal\n"
        " * window\" pass; passive sonar, ping, and drone-cam all funnel through it.\n"
    )
    edits.append(("shadowPolyForRect helper", edit15_old, edit15_new))

    # EDIT 16: drawWorldNear shadow render
    edit16_old = (
        "  // Terrain rectangles -- always rendered (they ARE the occluders;\n"
        "  // the near face of a wall is visible to anyone next to it).\n"
        "  ctx.fillStyle = \"rgba(120, 130, 150, \" + alpha + \")\";\n"
        "  for (const t of TERRAIN) ctx.fillRect(t.x, t.y, t.w, t.h);\n"
        "\n"
        "  // Factory body: LOS-gated. Test against the nearest point on the\n"
    )
    edit16_new = (
        "  // Terrain rectangles -- always rendered (they ARE the occluders;\n"
        "  // the near face of a wall is visible to anyone next to it).\n"
        "  ctx.fillStyle = \"rgba(120, 130, 150, \" + alpha + \")\";\n"
        "  for (const t of TERRAIN) ctx.fillRect(t.x, t.y, t.w, t.h);\n"
        "\n"
        "  // Step 9 v0.3 pull-in (Pull 2 -- shadow-cone LOS render). Dark\n"
        "  // wedges behind every terrain rect inside the reveal disc. Clipped\n"
        "  // to the disc by the surrounding ctx.clip() call above. Performance\n"
        "  // cap: only consider rects whose nearest point is within radius + diag.\n"
        "  const L_s9 = { x: cx, y: cy };\n"
        "  const farDist_s9 = radius * 3 + 200;\n"
        "  ctx.fillStyle = \"rgba(6, 10, 18, \" + (alpha * 0.85) + \")\";\n"
        "  for (const t of TERRAIN) {\n"
        "    const diag = Math.hypot(t.w, t.h);\n"
        "    const dRect = distancePointToRect(cx, cy, t);\n"
        "    if (dRect > radius + diag) continue;\n"
        "    const poly = shadowPolyForRect(L_s9, t, farDist_s9);\n"
        "    if (!poly) continue;\n"
        "    ctx.beginPath();\n"
        "    ctx.moveTo(poly[0].x, poly[0].y);\n"
        "    for (let i = 1; i < poly.length; i++) ctx.lineTo(poly[i].x, poly[i].y);\n"
        "    ctx.closePath();\n"
        "    ctx.fill();\n"
        "  }\n"
        "\n"
        "  // Factory body: LOS-gated. Test against the nearest point on the\n"
    )
    edits.append(("drawWorldNear shadow render", edit16_old, edit16_new))

    # EDIT 17: HUD SILENT indicator
    edit17_old = (
        "    (s.armedTool ? (\"ARMED: \" + s.armedTool.toUpperCase() + \" -- click target\") : \"armed: none\") + \"   \" +\n"
        "    (isJamActive() ? (\"JAM ACTIVE (\" + (s.jamActiveUntil - s.timeSec).toFixed(1) + \"s)\") : \"jam: idle\");\n"
        "}\n"
    )
    edit17_new = (
        "    (s.armedTool ? (\"ARMED: \" + s.armedTool.toUpperCase() + \" -- click target\") : \"armed: none\") + \"   \" +\n"
        "    (isJamActive() ? (\"JAM ACTIVE (\" + (s.jamActiveUntil - s.timeSec).toFixed(1) + \"s)\") : \"jam: idle\") + \"   \" +\n"
        "    // Step 9 Pull 4 HUD: silent state + current noise radius.\n"
        "    (s.silentRunning ? \"SILENT\" : \"silent: off\") + \"   \" +\n"
        "    \"noiseR: \" + noiseRForSub(s.sub).toFixed(0);\n"
        "}\n"
    )
    edits.append(("HUD SILENT indicator", edit17_old, edit17_new))

    # EDIT 18: HTML btnSilent (additive, before btnRestart)
    edit18_old = (
        "        <button class=\"tbtn\" id=\"btnHelp\" type=\"button\">?</button>\n"
        "        <button class=\"tbtn\" id=\"btnRestart\" type=\"button\">RESTART</button>\n"
    )
    edit18_new = (
        "        <button class=\"tbtn\" id=\"btnHelp\" type=\"button\">?</button>\n"
        "        <!-- Step 9 Pull 4 -- additive silent running button. -->\n"
        "        <button class=\"tbtn\" id=\"btnSilent\" type=\"button\">SILENT</button>\n"
        "        <button class=\"tbtn\" id=\"btnRestart\" type=\"button\">RESTART</button>\n"
    )
    edits.append(("HTML btnSilent", edit18_old, edit18_new))

    # EDIT 19: TOUCH_ACTIONS btnSilent handler
    edit19_old = (
        "  btnHelp:    () => { touchInput.helpVisible = !touchInput.helpVisible; refreshHelpOverlay(); },\n"
        "  btnRestart: () => { if (state.loseReason || state.winState) { state = newState(); refreshTouchArmedUI(); } },\n"
        "};\n"
    )
    edit19_new = (
        "  btnHelp:    () => { touchInput.helpVisible = !touchInput.helpVisible; refreshHelpOverlay(); },\n"
        "  // Step 9 Pull 4 -- silent running toggle from mobile tray.\n"
        "  btnSilent:  () => { toggleSilentRunning(); },\n"
        "  btnRestart: () => { if (state.loseReason || state.winState) { state = newState(); refreshTouchArmedUI(); } },\n"
        "};\n"
    )
    edits.append(("TOUCH_ACTIONS btnSilent", edit19_old, edit19_new))

    # EDIT 20: refreshTouchArmedUI silent toggle
    edit20_old = (
        "  if (armed && armMap[armed]) {\n"
        "    const el = document.getElementById(armMap[armed]);\n"
        "    if (el) el.classList.add(\"armed\");\n"
        "  }\n"
        "  // Gameover class toggles RESTART button visibility.\n"
    )
    edit20_new = (
        "  if (armed && armMap[armed]) {\n"
        "    const el = document.getElementById(armMap[armed]);\n"
        "    if (el) el.classList.add(\"armed\");\n"
        "  }\n"
        "  // Step 9 Pull 4 -- reflect silent state on #btnSilent.\n"
        "  const silentBtn = document.getElementById(\"btnSilent\");\n"
        "  if (silentBtn) {\n"
        "    if (state && state.silentRunning) silentBtn.classList.add(\"armed\");\n"
        "    else silentBtn.classList.remove(\"armed\");\n"
        "  }\n"
        "  // Gameover class toggles RESTART button visibility.\n"
    )
    edits.append(("refreshTouchArmedUI btnSilent", edit20_old, edit20_new))

    # EDIT 21: __sim harness Step 9 additions
    edit21_old = (
        "  // Read-back of the live `keys` Set (for joystick-key sim\n"
        "  // assertions). Returned as Array so tests can deep-compare.\n"
        "  getKeysSet: () => Array.from(keys),\n"
        "};\n"
    )
    edit21_new = (
        "  // Read-back of the live `keys` Set (for joystick-key sim\n"
        "  // assertions). Returned as Array so tests can deep-compare.\n"
        "  getKeysSet: () => Array.from(keys),\n"
        "  // ------------------------------------------------------------------\n"
        "  // Step 9 v0.3 pull-in 2026-06-05 additions. All additive.\n"
        "  // ------------------------------------------------------------------\n"
        "  hasActiveDetector,         // Pull 1\n"
        "  shadowPolyForRect,         // Pull 2\n"
        "  AU,                        // Pull 3\n"
        "  noiseRForSub,              // Pull 4\n"
        "  toggleSilentRunning,       // Pull 4\n"
        "  toggleSilent: () => toggleSilentRunning(),  // alias per brief 09\n"
        "  getSilentRunning: () => state.silentRunning,\n"
        "};\n"
    )
    edits.append(("__sim Step 9 additions", edit21_old, edit21_new))

    # Apply edits in order, asserting uniqueness for each.
    for (label, old, new) in edits:
        count = text.count(old)
        if count == 0:
            print(f"  FAIL [{label}]: old_string NOT FOUND")
            sys.exit(1)
        if count > 1:
            print(f"  FAIL [{label}]: old_string occurs {count} times (need exactly 1)")
            sys.exit(1)
        text = text.replace(old, new, 1)
        print(f"  OK   [{label}]")

    # Atomic write.
    tmp = SRC + ".tmp"
    with open(tmp, "w", encoding="utf-8", newline="\n") as f:
        f.write(text)
    os.replace(tmp, SRC)

    with open(SRC, "rb") as f:
        final = f.read()
    print()
    print(f"  RESULT bytes: {len(final)} (delta {len(final) - len(raw):+d})")
    print(f"  RESULT md5: {hashlib.md5(final).hexdigest()}")
    print(f"  RESULT lines: {final.count(chr(10).encode())}")
    print(f"  RESULT tail: {final[-50:]!r}")

if __name__ == "__main__":
    main()
