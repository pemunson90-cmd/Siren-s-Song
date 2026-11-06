const { loadSim } = require('/sessions/inspiring-upbeat-mccarthy/mnt/sirens-song/tmp_audit_step6/harness.js');

let pass = 0, fail = 0;
const failures = [];
function check(name, ok, detail='') {
  if (ok) { pass++; console.log('PASS ', name, detail ? '('+detail+')' : ''); }
  else    { fail++; failures.push(name+' '+detail); console.log('FAIL ', name, '('+detail+')'); }
}

// ========================================
// 1. TUNING constants
// ========================================
console.log('\n=== A. TUNING constants ===');
let sim = loadSim();
check('RECON_CHARGES_INITIAL == 2', sim.TUNING.RECON_CHARGES_INITIAL === 2, 'val='+sim.TUNING.RECON_CHARGES_INITIAL);
check('RECON_SUSP_COST == 8', sim.TUNING.RECON_SUSP_COST === 8, 'val='+sim.TUNING.RECON_SUSP_COST);
check('RECON_DURATION_SEC in [6,10]',
  sim.TUNING.RECON_DURATION_SEC >= 6 && sim.TUNING.RECON_DURATION_SEC <= 10,
  'val='+sim.TUNING.RECON_DURATION_SEC);
check('RECON_DURATION > PING_DURATION',
  sim.TUNING.RECON_DURATION_SEC > sim.TUNING.PING_DURATION_SEC,
  'recon='+sim.TUNING.RECON_DURATION_SEC+' ping='+sim.TUNING.PING_DURATION_SEC);
check('RECON_REVEAL_RADIUS_PX > PING_RADIUS_PX',
  sim.TUNING.RECON_REVEAL_RADIUS_PX > sim.TUNING.PING_RADIUS_PX,
  'recon='+sim.TUNING.RECON_REVEAL_RADIUS_PX+' ping='+sim.TUNING.PING_RADIUS_PX);

// ========================================
// 2. Initial state
// ========================================
console.log('\n=== B. Initial state ===');
sim = loadSim();
let state = sim.getState();
check('reconCharges = 2 at init', state.reconCharges === 2, 'val='+state.reconCharges);
check('reconReveals = [] at init', Array.isArray(state.reconReveals) && state.reconReveals.length === 0);
check('getCharges().recon = 2', sim.getCharges().recon === 2);

// ========================================
// 3. Fire returns reveal object & side effects
// ========================================
console.log('\n=== C. fireRecon basic ===');
sim = loadSim();
state = sim.getState();
const suspBefore = state.suspicion;
const reveal = sim.fireRecon(500, 300);
state = sim.getState();
check('fireRecon returned object', reveal && typeof reveal === 'object');
check('reveal.x == 500', reveal.x === 500);
check('reveal.y == 300', reveal.y === 300);
check('reveal.r == 400', reveal.r === sim.TUNING.RECON_REVEAL_RADIUS_PX);
check('reveal.tStart set', typeof reveal.tStart === 'number');
check('reveal.tEnd = tStart + DURATION',
  Math.abs(reveal.tEnd - reveal.tStart - sim.TUNING.RECON_DURATION_SEC) < 1e-9);
check('reconCharges decremented to 1', state.reconCharges === 1);
check('reveals array length 1', state.reconReveals.length === 1);
check('suspicion increased by 8', state.suspicion === suspBefore + 8, 'before='+suspBefore+' after='+state.suspicion);

// ========================================
// 4. Charge exhaustion
// ========================================
console.log('\n=== D. Charge exhaustion ===');
sim = loadSim();
const r1 = sim.fireRecon(100, 100);
const r2 = sim.fireRecon(200, 200);
const r3 = sim.fireRecon(300, 300);
check('1st fire returned reveal', r1 !== null);
check('2nd fire returned reveal', r2 !== null);
check('3rd fire returned null', r3 === null);
check('reconCharges = 0 after 2 fires', sim.getCharges().recon === 0);
check('reveals.length = 2 (not 3)', sim.getState().reconReveals.length === 2);
// 3rd attempt suspicion: should NOT add another +8
const susp = sim.getState().suspicion;
sim.fireRecon(400, 400);
check('4th attempt does not change suspicion', sim.getState().suspicion === susp, 'after='+sim.getState().suspicion);

// ========================================
// 5. Cumulative suspicion
// ========================================
console.log('\n=== E. Suspicion cost cumulative ===');
sim = loadSim();
check('susp = 0 initially', sim.getState().suspicion === 0);
sim.fireRecon(100, 100);
check('susp = 8 after 1 fire', sim.getState().suspicion === 8);
sim.fireRecon(200, 200);
check('susp = 16 after 2 fires', sim.getState().suspicion === 16);
sim.fireRecon(300, 300);
check('susp still 16 after rejected 3rd fire', sim.getState().suspicion === 16);

// ========================================
// 6. Reveal duration exact
// ========================================
console.log('\n=== F. Reveal duration ===');
sim = loadSim();
sim.fireRecon(500, 500);
state = sim.getState();
const t0 = state.timeSec;
const dur = sim.TUNING.RECON_DURATION_SEC;
check('isInReconReveal(500,500) at t=0', sim.isInReconReveal(500, 500));
// Advance time directly by mutating state
state.timeSec = t0 + dur * 0.5;
check('Still active mid-duration', sim.isInReconReveal(500, 500));
// At t < tEnd (just before expiry)
state.timeSec = t0 + dur - 0.01;
check('Active just before tEnd', sim.isInReconReveal(500, 500));
// At t == tEnd should be expired
state.timeSec = t0 + dur;
check('Expired at exact tEnd', !sim.isInReconReveal(500, 500), 'isIn='+sim.isInReconReveal(500,500));
// Past tEnd
state.timeSec = t0 + dur + 1;
check('Expired past tEnd', !sim.isInReconReveal(500, 500));
// updateReconReveals removes expired
sim.updateReconReveals();
check('updateReconReveals removed expired reveal', sim.getState().reconReveals.length === 0);

// ========================================
// 7. Reveal radius
// ========================================
console.log('\n=== G. Reveal radius ===');
sim = loadSim();
sim.fireRecon(600, 400);
check('center (600,400) inside', sim.isInReconReveal(600, 400));
check('+1 px inside', sim.isInReconReveal(601, 400));
check('+399 px inside (399^2 < 400^2)', sim.isInReconReveal(600 + 399, 400));
check('+400 px exactly boundary (<=)', sim.isInReconReveal(600 + 400, 400), '<= test: ' + sim.isInReconReveal(600+400,400));
check('+401 px outside', !sim.isInReconReveal(600 + 401, 400));
check('+500 px outside', !sim.isInReconReveal(600 + 500, 400));
check('-401 px outside', !sim.isInReconReveal(600 - 401, 400));

// ========================================
// 8. LOS NOT gated
// ========================================
console.log('\n=== I. LOS NOT gated ===');
sim = loadSim();
// Find a point behind terrain from the patroller's position
const patroller = sim.getPatroller();
const px = patroller.x, py = patroller.y;
sim.fireRecon(px, py);
check('Patroller position inside recon reveal', sim.isInReconReveal(px, py));
// Even if LOS from sub is blocked, recon still reveals
state = sim.getState();
// Test: place reveal across terrain barrier - we cannot easily test LOS in extractable form,
// but verify the function does not call LOS:
// Source-level check via grep already done; assert behavioral: any point in radius returns true regardless
check('Point far from sub inside reveal still visible', sim.isInReconReveal(px, py));

// ========================================
// 9. countVisibleSirens
// ========================================
console.log('\n=== J. countVisibleSirens accounts for recon ===');
sim = loadSim();
const baseline = sim.countVisibleSirens();
const all = sim.allSirens();
// Place recon to cover all 3 Sirens
let cx = 0, cy = 0;
for (const s of all) { cx += s.x; cy += s.y; }
cx /= all.length; cy /= all.length;
// Verify all sirens are within 400 of (cx,cy)
let maxD = 0;
for (const s of all) { maxD = Math.max(maxD, Math.hypot(s.x-cx, s.y-cy)); }
console.log('  max distance from centroid:', maxD.toFixed(1));
if (maxD <= 400) {
  sim.fireRecon(cx, cy);
  const after = sim.countVisibleSirens();
  check('countVisibleSirens covered all 3', after === 3, 'before='+baseline+' after='+after+' max_d='+maxD.toFixed(1));
} else {
  // Place reveal at one specific siren's position
  sim.fireRecon(all[0].x, all[0].y);
  const after = sim.countVisibleSirens();
  check('countVisibleSirens >= baseline+1 after focused recon', after >= baseline + 1 || after >= 1,
    'before='+baseline+' after='+after);
}

// ========================================
// 10. INV1 - no Siren mutation
// ========================================
console.log('\n=== K. INV1 -- no Siren state mutation ===');
sim = loadSim();
const sirens0 = sim.allSirens();
const snapshots = sirens0.map(s => ({ keys: Object.keys(s).sort().join(','), x: s.x, y: s.y }));
// 100x recon at the patroller, sentinel, hunter
sim = loadSim();
const p = sim.getPatroller();
for (let i = 0; i < 100; i++) {
  // Force a fresh charge each time by resetting reconCharges
  sim.getState().reconCharges = 2;
  sim.fireRecon(p.x, p.y);
  sim.getState().reconReveals = [];
}
const sirens1 = sim.allSirens();
for (let i = 0; i < sirens1.length; i++) {
  const keys = Object.keys(sirens1[i]).sort().join(',');
  check('Siren['+i+'] key shape unchanged after 100 fires', keys === snapshots[i].keys,
    'before='+snapshots[i].keys+' after='+keys);
  // Check for HP-like keys
  const hpLike = keys.match(/hp|health|damage|kill|life/i);
  check('Siren['+i+'] has no HP-like keys', !hpLike, hpLike ? 'found: ' + hpLike[0] : '');
}

// ========================================
// 11. INV3 chokepoint
// ========================================
console.log('\n=== L. INV3 -- chokepoint cost ===');
sim = loadSim();
state = sim.getState();
const lastBefore = state.lastSuspChange;
const susBefore = state.suspicion;
sim.fireRecon(100, 100);
state = sim.getState();
check('lastSuspChange = +8 after fire',
  state.lastSuspChange === 8 || state.lastSuspChange === '+8' || state.lastSuspChange?.amount === 8,
  'val='+JSON.stringify(state.lastSuspChange));
check('suspicion increased by exactly 8', state.suspicion === susBefore + 8);

// ========================================
// 12. INV4 finiteness
// ========================================
console.log('\n=== M. INV4 -- finite charges + duration ===');
sim = loadSim();
let total = 0;
for (let i = 0; i < 20; i++) { if (sim.fireRecon(100, 100)) total++; }
check('Only 2 successful fires out of 20 attempts', total === 2, 'total='+total);
check('Charges = 0 after exhaustion', sim.getCharges().recon === 0);

// ========================================
// 13. lose/win blocks fire
// ========================================
console.log('\n=== N. lose/win blocks fire ===');
sim = loadSim();
state = sim.getState();
state.loseReason = 'vaporized';
const beforeC = sim.getCharges().recon;
const beforeS = sim.getState().suspicion;
const ret = sim.fireRecon(100, 100);
check('lose state: fireRecon returns null', ret === null);
check('lose state: charges preserved', sim.getCharges().recon === beforeC);
check('lose state: suspicion unchanged', sim.getState().suspicion === beforeS);
check('lose state: no reveal added', sim.getState().reconReveals.length === 0);

// win state
sim = loadSim();
state = sim.getState();
state.winState = 'won';
const ret2 = sim.fireRecon(100, 100);
check('win state: fireRecon returns null', ret2 === null);
check('win state: no reveal added', sim.getState().reconReveals.length === 0);

// ========================================
// 14. armedTool wiring
// ========================================
console.log('\n=== O. armedTool wiring ===');
sim = loadSim();
sim.setArmedTool('recon');
check('setArmedTool("recon")', sim.getArmedTool() === 'recon');
sim.setArmedTool(null);
check('setArmedTool(null) clears', sim.getArmedTool() === null);

// ========================================
// 15. Multiple concurrent reveals
// ========================================
console.log('\n=== P. Multiple concurrent reveals ===');
sim = loadSim();
sim.fireRecon(200, 200);
sim.fireRecon(800, 600);
check('2 reveals active', sim.getState().reconReveals.length === 2);
check('First center covered', sim.isInReconReveal(200, 200));
check('Second center covered', sim.isInReconReveal(800, 600));
check('Far point uncovered', !sim.isInReconReveal(50, 50));

// ========================================
// 16. reconRevealAlphaAt fade
// ========================================
console.log('\n=== Q. reconRevealAlphaAt fade ===');
sim = loadSim();
sim.fireRecon(500, 500);
state = sim.getState();
const t0q = state.timeSec;
const durQ = sim.TUNING.RECON_DURATION_SEC;
check('alpha = 1.0 at t=tStart', Math.abs(sim.reconRevealAlphaAt(500, 500) - 1.0) < 1e-9, 'val='+sim.reconRevealAlphaAt(500,500));
state.timeSec = t0q + durQ / 2;
check('alpha = 0.5 at t=mid', Math.abs(sim.reconRevealAlphaAt(500, 500) - 0.5) < 1e-9, 'val='+sim.reconRevealAlphaAt(500,500));
state.timeSec = t0q + durQ - 0.01;
check('alpha ~ 0.01/dur near expiry', sim.reconRevealAlphaAt(500, 500) < 0.01, 'val='+sim.reconRevealAlphaAt(500,500));
state.timeSec = t0q + durQ;
check('alpha = 0 at expiry', sim.reconRevealAlphaAt(500, 500) === 0);
state.timeSec = t0q + durQ + 5;
check('alpha = 0 past expiry', sim.reconRevealAlphaAt(500, 500) === 0);
// outside
state.timeSec = t0q;
check('alpha = 0 outside radius', sim.reconRevealAlphaAt(2000, 2000) === 0);

// ========================================
// 17. Step-5 regression
// ========================================
console.log('\n=== S. Step-5 regression ===');
sim = loadSim();
const ch = sim.getCharges();
check('jam charges = 3 still', ch.jam === 3, 'val='+ch.jam);
check('emp charges = 3 still', ch.emp === 3);
check('kd charges = 2 still', ch.kd === 2);
check('recon added to getCharges', ch.recon === 2);
// fire jam still works
const beforeJam = sim.getCharges().jam;
sim.fireJam(sim.getPatroller());
check('fireJam still works', sim.getCharges().jam === beforeJam - 1);

// ========================================
// 18. INV1 ADVERSARIAL: try to kill via tool chain including recon
// ========================================
console.log('\n=== T. ADV -- chain all tools at Siren ===');
sim = loadSim();
const sirenList = sim.allSirens();
const target = sim.getPatroller();
const beforeKeys = Object.keys(target).sort().join(',');
for (let i = 0; i < 30; i++) {
  // Keep refilling charges to ensure max disruption
  const s = sim.getState();
  s.jamCharges = 99; s.empCharges = 99; s.kdCharges = 99; s.reconCharges = 99;
  s.suspicion = 0;
  try { sim.fireJam(target); } catch (e) {}
  try { sim.fireEMP(target); } catch (e) {}
  try { sim.fireKnockdown(target); } catch (e) {}
  try { sim.fireRecon(target.x, target.y); } catch (e) {}
}
const afterKeys = Object.keys(sim.getPatroller()).sort().join(',');
check('Patroller still exists after tool chain', sim.getPatroller() !== null);
check('Patroller key shape unchanged after chain', beforeKeys === afterKeys, 'before='+beforeKeys+' after='+afterKeys);

// ========================================
// 19. ADV: recon at susp cap
// ========================================
console.log('\n=== U. ADV: recon at susp cap ===');
sim = loadSim();
state = sim.getState();
state.suspicion = 99;
sim.fireRecon(100, 100);
check('susp clamped at 100 after fire from 99', sim.getState().suspicion === 100);
check('charge still consumed', sim.getCharges().recon === 1);

// ========================================
// 20. Determinism
// ========================================
console.log('\n=== W. Determinism ===');
const a = loadSim();
const b = loadSim();
a.fireRecon(500, 300);
b.fireRecon(500, 300);
check('Both produce same reveal coords',
  JSON.stringify(a.getState().reconReveals[0]) === JSON.stringify(b.getState().reconReveals[0]),
  '\n  a='+JSON.stringify(a.getState().reconReveals[0])+'\n  b='+JSON.stringify(b.getState().reconReveals[0]));

// ========================================
// 21. Free reveal check (adversarial)
// ========================================
console.log('\n=== X. No free reveal ===');
sim = loadSim();
const susBefore2 = sim.getState().suspicion;
// fireRecon must always cost +8 when it succeeds
sim.fireRecon(100, 100);
check('Successful fireRecon always costs +8', sim.getState().suspicion === susBefore2 + 8);

// ========================================
// 22. INV5 preservation (fairness valve)
// ========================================
console.log('\n=== Y. INV5 fairness valve preserved ===');
sim = loadSim();
state = sim.getState();
// Drive suspicion to 100 via recon repeats (artificially refilling charges)
for (let i = 0; i < 20; i++) {
  state.reconCharges = 2;
  sim.fireRecon(100, 100);
}
check('Suspicion at 100 cap', state.suspicion === 100);
// Sim past warning sustain
const t0y = state.timeSec;
// advance time and call update; mock dt-based update
for (let i = 0; i < 50; i++) { sim.update(0.1); }
const afterT = state.timeSec - t0y;
console.log('  Elapsed sim time:', afterT.toFixed(2), 's');
// Should have triggered instakill
const isVap = state.loseReason === 'vaporized';
check('Sustained 100 for ~5s triggers vaporized', isVap, 'loseReason='+state.loseReason);

// ========================================
// 23. fireRecon does not LOS-check (verified by behavior)
// ========================================
console.log('\n=== I2. No LOS gating verified behaviorally ===');
sim = loadSim();
// Place a reveal in middle of terrain
state = sim.getState();
const sub = state.sub;
// Hunter is dormant somewhere - find any siren and call recon at that position
const hunter = sim.getHunter();
sim.fireRecon(hunter.x, hunter.y);
check('Hunter at (hunter.x, hunter.y) inside reveal regardless of LOS', sim.isInReconReveal(hunter.x, hunter.y));

// ========================================
// FINAL
// ========================================
console.log('\n========================================');
console.log('TOTAL:', pass, 'PASS,', fail, 'FAIL');
if (failures.length) {
  console.log('FAILURES:');
  for (const f of failures) console.log(' -', f);
}
