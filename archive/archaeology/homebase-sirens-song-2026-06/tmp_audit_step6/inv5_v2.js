const { loadSim } = require('/sessions/inspiring-upbeat-mccarthy/mnt/sirens-song/tmp_audit_step6/harness.js');

// Test 1: 100 sustained for 4.1s -> vaporized
let sim = loadSim();
let state = sim.getState();
for (let i = 0; i < 42; i++) {
  state.suspicion = 100;  // force-hold at cap each frame
  sim.update(0.1);
}
console.log('Test1 (100 sustained 4.2s): loseReason=', state.loseReason);
console.log('Test1 instakillTimer=', state.instakillTimer);

// Test 2: 100 sustained for 3.9s -> NOT vaporized
sim = loadSim();
state = sim.getState();
for (let i = 0; i < 39; i++) {
  state.suspicion = 100;
  sim.update(0.1);
}
console.log('Test2 (100 sustained 3.9s): loseReason=', state.loseReason);

// Test 3: with recon mixed in, valve still kills
sim = loadSim();
state = sim.getState();
state.reconCharges = 99;
for (let i = 0; i < 60; i++) {
  if (i % 5 === 0) sim.fireRecon(100, 100);
  state.suspicion = 100;
  sim.update(0.1);
}
console.log('Test3 (recon spam + force 100 6s): loseReason=', state.loseReason);
