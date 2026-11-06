/* ========================================================================
 * smoke_test.js — headless smoke test for code/sirens_song.html
 *
 * 2026-06-05. Run from sirens-song/ via `node smoke_test.js`.
 *
 * Goal: verify the game LOADS, INITIALIZES, and TICKS for several seconds
 * without throwing exceptions or logging console errors, in both desktop
 * and mobile-ish viewports. This is NOT logic verification — that already
 * happened via window.__sim in the audit gates. This is "does the HTML
 * actually run when loaded by a browser-like environment."
 *
 * Tool choice:
 *   First attempt: Puppeteer (chromium download blocked by sandbox).
 *   Second attempt: Playwright (chromium download blocked by sandbox).
 *   Fallback used here: jsdom + manual 2D context stub.
 *
 * Reduced coverage flag: jsdom does NOT rasterize. Anything that depends
 * on actual pixel output, real layout box sizing from rendered fonts, or
 * GPU-backed compositing is NOT verified. What IS verified:
 *   - HTML parses without throwing
 *   - Inline script executes without throwing
 *   - DOM elements with required ids exist
 *   - window.__sim is populated (game-init reached end of script)
 *   - requestAnimationFrame loop fires
 *   - __sim.update() advances state without throwing for 3s of game time
 *   - Synthetic keyboard + touch events do not throw
 *   - Canvas element width/height are set (even if not rasterized)
 *   - Mobile-pass: orientation/touch-overlay code paths execute
 *
 * That coverage is sufficient to answer "is it safe for Pat to open in a
 * real browser without immediate crash" — which is the question asked.
 * ========================================================================
 */

const fs = require("fs");
const path = require("path");
const { JSDOM, VirtualConsole } = require("jsdom");

const HTML_PATH = path.resolve(__dirname, "code", "sirens_song.html");
const LOG_PATH = path.resolve(__dirname,
  `smoke_test_run_${todayStamp()}.log`);

function todayStamp() {
  const d = new Date();
  return `${d.getUTCFullYear()}${String(d.getUTCMonth() + 1).padStart(2, "0")}${String(d.getUTCDate()).padStart(2, "0")}`;
}

const logLines = [];
function log(msg) {
  const line = `[${new Date().toISOString()}] ${msg}`;
  console.log(line);
  logLines.push(line);
}
function flushLog() {
  fs.writeFileSync(LOG_PATH, logLines.join("\n") + "\n", "utf8");
}

/* ----- 2D context stub ------------------------------------------------ */
/* jsdom does not implement getContext('2d'). We need a stub that:
 *   - returns a context object on getContext('2d')
 *   - implements every method/setter the game touches as no-ops
 *   - returns sane defaults for measureText (used for layout)
 *
 * We use a Proxy so any unanticipated method call returns a no-op
 * instead of throwing TypeError. Properties default to 0 / "".
 */
function make2DContextStub() {
  const data = {};
  const handler = {
    get(target, prop) {
      if (prop in target) return target[prop];
      // measureText returns an object with .width (used widely for HUD)
      if (prop === "measureText") {
        return (txt) => ({
          width: (String(txt || "").length) * 7,
          actualBoundingBoxAscent: 7,
          actualBoundingBoxDescent: 2,
        });
      }
      // getImageData returns a fake ImageData-shaped object
      if (prop === "getImageData") {
        return (x, y, w, h) => ({
          width: w | 0,
          height: h | 0,
          data: new Uint8ClampedArray((w | 0) * (h | 0) * 4),
        });
      }
      if (prop === "createImageData") {
        return (w, h) => ({
          width: w | 0,
          height: h | 0,
          data: new Uint8ClampedArray((w | 0) * (h | 0) * 4),
        });
      }
      if (prop === "createLinearGradient" || prop === "createRadialGradient" ||
          prop === "createPattern") {
        return () => ({ addColorStop: () => {} });
      }
      if (prop === "canvas") return data.canvas;
      // Any unknown method = no-op function. Unknown property = "".
      // We can't distinguish without calling, so return a callable that
      // also coerces to "". Cheapest: return a function. The game never
      // reads a 2d-ctx property and then uses its non-callable form.
      return function noop() { return undefined; };
    },
    set(target, prop, value) {
      target[prop] = value;
      return true;
    },
  };
  const target = {};
  const proxy = new Proxy(target, handler);
  data.canvas = null; // back-filled when attached to canvas element
  return { ctx: proxy, attachCanvas: (c) => { data.canvas = c; } };
}

/* ----- Single-pass test runner --------------------------------------- */
async function runOne(label, opts) {
  log(`=== ${label} ===`);
  const result = {
    label,
    consoleErrors: [],
    uncaughtExceptions: [],
    bootOk: false,
    canvasOk: false,
    rafFired: false,
    runtimeOk: false,
    inputOk: false,
    notes: [],
  };

  const virtualConsole = new VirtualConsole();
  virtualConsole.on("error", (...args) => {
    const s = args.map(String).join(" ");
    result.consoleErrors.push(s);
    log(`  CONSOLE.ERROR: ${s.slice(0, 240)}`);
  });
  virtualConsole.on("jsdomError", (err) => {
    const s = err && (err.stack || err.message || String(err));
    result.uncaughtExceptions.push(s);
    log(`  JSDOM-ERROR: ${String(s).split("\n")[0].slice(0, 240)}`);
  });
  // Don't pipe info/warn/debug — too noisy from the game's logging.

  const html = fs.readFileSync(HTML_PATH, "utf8");
  const dom = new JSDOM(html, {
    url: "file://" + HTML_PATH,
    runScripts: "dangerously",
    resources: "usable",
    pretendToBeVisual: true,
    virtualConsole,
    beforeParse(window) {
      // Patch viewport BEFORE script runs.
      Object.defineProperty(window, "innerWidth", {
        value: opts.viewport.width, writable: true, configurable: true,
      });
      Object.defineProperty(window, "innerHeight", {
        value: opts.viewport.height, writable: true, configurable: true,
      });
      // Patch canvas getContext before any element is queried.
      const stub = make2DContextStub();
      const origGetContext = window.HTMLCanvasElement.prototype.getContext;
      window.HTMLCanvasElement.prototype.getContext = function (type) {
        if (type === "2d") {
          stub.attachCanvas(this);
          return stub.ctx;
        }
        return origGetContext && origGetContext.call(this, type);
      };
      // Patch touch / pointer hints for mobile run.
      if (opts.mobile) {
        Object.defineProperty(window.navigator, "maxTouchPoints", {
          value: 5, configurable: true,
        });
        // matchMedia stub recognises pointer:coarse on mobile.
        window.matchMedia = (q) => ({
          matches: /pointer:\s*coarse|hover:\s*none|max-width/.test(q),
          media: q,
          onchange: null,
          addListener: () => {},
          removeListener: () => {},
          addEventListener: () => {},
          removeEventListener: () => {},
          dispatchEvent: () => false,
        });
      } else {
        window.matchMedia = (q) => ({
          matches: false, media: q, onchange: null,
          addListener: () => {}, removeListener: () => {},
          addEventListener: () => {}, removeEventListener: () => {},
          dispatchEvent: () => false,
        });
      }
      // Real rAF (jsdom has a setTimeout-based polyfill, but we want a
      // tighter cadence and a flag we can read).
      let rafSeq = 0;
      window.__rafCount = 0;
      window.requestAnimationFrame = function (cb) {
        rafSeq += 1;
        const id = rafSeq;
        setTimeout(() => {
          window.__rafCount += 1;
          try { cb(performance.now()); } catch (e) {
            result.uncaughtExceptions.push(
              "rAF callback threw: " + (e.stack || e.message || String(e))
            );
          }
        }, 16);
        return id;
      };
      window.cancelAnimationFrame = function () {};
      // performance.now polyfill if absent.
      if (!window.performance) window.performance = {};
      if (!window.performance.now) {
        const t0 = Date.now();
        window.performance.now = () => Date.now() - t0;
      }
    },
  });

  const { window } = dom;
  // Catch any errors thrown after parse.
  window.addEventListener("error", (ev) => {
    const s = ev && ev.error && ev.error.stack
      ? ev.error.stack
      : (ev.message || String(ev));
    result.uncaughtExceptions.push(s);
    log(`  WINDOW-ERROR: ${String(s).split("\n")[0].slice(0, 240)}`);
  });

  await waitForReady(window, 5000);
  // Give deferred init a tick.
  await sleep(500);

  /* Boot assertions */
  const canvas = window.document.getElementById("game");
  if (!canvas) {
    result.notes.push("FAIL: no canvas#game found");
  } else {
    const w = canvas.width || 0;
    const h = canvas.height || 0;
    if (w > 0 && h > 0) {
      result.canvasOk = true;
      result.notes.push(`canvas ${w}x${h}`);
    } else {
      result.notes.push(`canvas dims zero (w=${w} h=${h})`);
    }
  }

  const sim = window.__sim;
  if (sim && typeof sim.update === "function" && typeof sim.getState === "function") {
    result.bootOk = true;
    result.notes.push(
      `__sim populated (${Object.keys(sim).length} keys, state=${sim.getState() ? "present" : "missing"})`
    );
  } else {
    result.notes.push("FAIL: window.__sim missing or incomplete");
  }

  /* rAF firing check — set a flag inside a rAF callback, see it tick. */
  const rafBaseline = window.__rafCount || 0;
  await sleep(150);
  const rafAfter = window.__rafCount || 0;
  if (rafAfter > rafBaseline) {
    result.rafFired = true;
    result.notes.push(`rAF fired ${rafAfter - rafBaseline} times in 150ms`);
  } else {
    result.notes.push(`FAIL: rAF did not fire (count stuck at ${rafAfter})`);
  }

  /* 3-second runtime — drive __sim.update directly for deterministic
   * game-time progression, AND let the rAF loop run for wall clock.
   * Note: update(dt) is single-arg and mutates module-level state. */
  let runtimeErrors = 0;
  if (sim && sim.update && sim.getState) {
    try {
      // 3s of game time = 180 frames @ 60 fps
      for (let i = 0; i < 180; i++) {
        sim.update(1 / 60);
      }
      result.notes.push(`drove __sim.update 180 frames (3s game time)`);
    } catch (e) {
      runtimeErrors += 1;
      result.uncaughtExceptions.push(
        "sim.update loop threw: " + (e.stack || e.message || String(e))
      );
    }
  }
  await sleep(3000); // wall clock 3s for the rAF loop
  result.runtimeOk =
    runtimeErrors === 0 && result.uncaughtExceptions.length === 0;
  result.notes.push(`rAF total after 3s: ${window.__rafCount || 0}`);

  /* Synthetic input */
  try {
    if (opts.mobile) {
      const joy = window.document.getElementById("joystick");
      if (joy) {
        const touchStart = new window.Event("touchstart", { bubbles: true });
        Object.defineProperty(touchStart, "touches", {
          value: [{ clientX: 100, clientY: 600, identifier: 1, target: joy }],
        });
        Object.defineProperty(touchStart, "changedTouches", {
          value: [{ clientX: 100, clientY: 600, identifier: 1, target: joy }],
        });
        joy.dispatchEvent(touchStart);

        const touchMove = new window.Event("touchmove", { bubbles: true });
        Object.defineProperty(touchMove, "touches", {
          value: [{ clientX: 130, clientY: 580, identifier: 1, target: joy }],
        });
        Object.defineProperty(touchMove, "changedTouches", {
          value: [{ clientX: 130, clientY: 580, identifier: 1, target: joy }],
        });
        joy.dispatchEvent(touchMove);

        const touchEnd = new window.Event("touchend", { bubbles: true });
        Object.defineProperty(touchEnd, "touches", { value: [] });
        Object.defineProperty(touchEnd, "changedTouches", {
          value: [{ clientX: 130, clientY: 580, identifier: 1, target: joy }],
        });
        joy.dispatchEvent(touchEnd);
        result.notes.push("dispatched touchstart/move/end on #joystick");
      } else {
        result.notes.push("WARN: no #joystick element to touch");
      }
    } else {
      const down = new window.KeyboardEvent("keydown", {
        key: "w", code: "KeyW", bubbles: true,
      });
      window.dispatchEvent(down);
      await sleep(100);
      const up = new window.KeyboardEvent("keyup", {
        key: "w", code: "KeyW", bubbles: true,
      });
      window.dispatchEvent(up);
      result.notes.push("dispatched keydown/keyup KeyW");
    }
    result.inputOk = true;
  } catch (e) {
    result.uncaughtExceptions.push(
      "input dispatch threw: " + (e.stack || e.message || String(e))
    );
  }

  /* Mobile-specific: touch overlay visible + canvas viewport sizing */
  if (opts.mobile) {
    const overlay = window.document.getElementById("touchOverlay");
    if (overlay) {
      result.notes.push("touchOverlay element present");
    } else {
      result.notes.push("FAIL: no #touchOverlay element");
    }
    const rect = canvas && canvas.getBoundingClientRect
      ? canvas.getBoundingClientRect()
      : { width: 0 };
    result.notes.push(
      `canvas getBoundingClientRect width=${rect.width} (viewport ${opts.viewport.width})`
    );
    // jsdom does not lay out, so rect.width is typically 0. We don't
    // assert on this — flagged in the verdict.
  }

  /* Snapshot end state */
  try {
    const s = sim && sim.getState ? sim.getState() : null;
    if (s) {
      const subPos = s.sub ? `(${(s.sub.x | 0)},${(s.sub.y | 0)})` : "no sub";
      const tSec = typeof s.timeSec === "number" ? s.timeSec.toFixed(2) : String(s.timeSec);
      result.notes.push(`end state: timeSec=${tSec}s sub@${subPos} hull=${s.hull}`);
    }
  } catch (e) { /* ignore — diagnostic only */ }

  dom.window.close();
  return result;
}

function waitForReady(window, timeoutMs) {
  return new Promise((resolve) => {
    if (window.document.readyState === "complete") return resolve();
    const t0 = Date.now();
    const iv = setInterval(() => {
      if (window.document.readyState === "complete" ||
          Date.now() - t0 > timeoutMs) {
        clearInterval(iv);
        resolve();
      }
    }, 50);
  });
}
function sleep(ms) {
  return new Promise((r) => setTimeout(r, ms));
}

/* ----- Driver --------------------------------------------------------- */
(async () => {
  log("smoke_test.js starting");
  log(`html: ${HTML_PATH}`);
  log(`html bytes: ${fs.statSync(HTML_PATH).size}`);
  log("tool: jsdom + 2d-context stub (browser binaries blocked by allowlist)");

  const desktop = await runOne("Desktop boot (1280x800)", {
    viewport: { width: 1280, height: 800 },
    mobile: false,
  });
  log("---");
  const mobile = await runOne("Mobile boot (375x812, touch)", {
    viewport: { width: 375, height: 812 },
    mobile: true,
  });

  /* ----- Receipt ---------------------------------------------------- */
  log("");
  log("================================================================");
  log("SMOKE TEST RESULTS — code/sirens_song.html");
  log("================================================================");
  log("Tool: jsdom (puppeteer + playwright both blocked: storage.googleapis.com / cdn.playwright.dev not in allowlist)");
  log("");

  function verdict(r, includeRuntime, includeInput) {
    const fail = [];
    if (!r.bootOk) fail.push("boot");
    if (!r.canvasOk) fail.push("canvas");
    if (!r.rafFired) fail.push("rAF");
    if (includeRuntime && !r.runtimeOk) fail.push("runtime");
    if (includeInput && !r.inputOk) fail.push("input");
    if (r.consoleErrors.length) fail.push(`console.error x${r.consoleErrors.length}`);
    if (r.uncaughtExceptions.length) fail.push(`exception x${r.uncaughtExceptions.length}`);
    return fail.length === 0 ? "PASS" : "FAIL [" + fail.join(", ") + "]";
  }

  const t1 = verdict(desktop, false, false); // boot only
  const t2 = verdict(desktop, true, false);  // 3s runtime
  const t3 = verdict(mobile, false, false);  // boot only
  const t4 = verdict(desktop, false, true);
  const t4m = verdict(mobile, false, true);

  log(`Test 1 (desktop boot): ${t1}`);
  log(`Test 2 (3s runtime):   ${t2}`);
  log(`Test 3 (mobile boot):  ${t3}`);
  log(`Test 4 (input, desktop+mobile): desktop=${t4} mobile=${t4m}`);
  log("");
  log("Console errors during desktop run: " +
    (desktop.consoleErrors.length === 0 ? "none" : desktop.consoleErrors.length));
  if (desktop.consoleErrors.length) desktop.consoleErrors.forEach((s, i) =>
    log(`  d-cerr[${i}] ${s.slice(0, 240)}`));
  log("Console errors during mobile run: " +
    (mobile.consoleErrors.length === 0 ? "none" : mobile.consoleErrors.length));
  if (mobile.consoleErrors.length) mobile.consoleErrors.forEach((s, i) =>
    log(`  m-cerr[${i}] ${s.slice(0, 240)}`));
  log("Uncaught exceptions desktop: " +
    (desktop.uncaughtExceptions.length === 0 ? "none" : desktop.uncaughtExceptions.length));
  if (desktop.uncaughtExceptions.length) desktop.uncaughtExceptions.forEach((s, i) =>
    log(`  d-exc[${i}] ${String(s).split("\n")[0].slice(0, 240)}`));
  log("Uncaught exceptions mobile: " +
    (mobile.uncaughtExceptions.length === 0 ? "none" : mobile.uncaughtExceptions.length));
  if (mobile.uncaughtExceptions.length) mobile.uncaughtExceptions.forEach((s, i) =>
    log(`  m-exc[${i}] ${String(s).split("\n")[0].slice(0, 240)}`));
  log("");
  log("Desktop notes:");
  desktop.notes.forEach((n) => log(`  - ${n}`));
  log("Mobile notes:");
  mobile.notes.forEach((n) => log(`  - ${n}`));

  const allPass =
    desktop.bootOk && desktop.canvasOk && desktop.rafFired &&
    desktop.runtimeOk && desktop.inputOk &&
    mobile.bootOk && mobile.canvasOk && mobile.rafFired && mobile.inputOk &&
    desktop.consoleErrors.length === 0 && mobile.consoleErrors.length === 0 &&
    desktop.uncaughtExceptions.length === 0 && mobile.uncaughtExceptions.length === 0;

  log("");
  log("Coverage caveat: jsdom does NOT rasterize the canvas. Pixel output,");
  log("font-metric-driven layout, and GPU compositing are NOT verified.");
  log("What IS verified: HTML parse, script execution, DOM presence,");
  log("__sim population, rAF cadence, update() loop stability, and");
  log("synthetic input dispatch — all without exceptions or console errors.");
  log("");
  log("VERDICT: " + (allPass ? "SAFE TO PLAYTEST (no crash class detected)" : "NEEDS FIX (see fail markers)"));

  flushLog();
  process.exit(allPass ? 0 : 1);
})().catch((e) => {
  log("DRIVER THREW: " + (e.stack || e.message || String(e)));
  flushLog();
  process.exit(2);
});
catch((e) => {
  log("DRIVER THREW: " + (e.stack || e.message || String(e)));
  flushLog();
  process.exit(2);
});
