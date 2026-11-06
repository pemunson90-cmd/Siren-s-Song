const { loadSim } = require('/sessions/inspiring-upbeat-mccarthy/mnt/sirens-song/tmp_audit_step6/harness.js');
const sim = loadSim();
const state = sim.getState();
state.suspicion = 100;
console.log('start: susp=', state.suspicion, 'time=', state.timeSec, 'loseReason=', state.loseReason);
// Check what the step-2 audit method was
// Examine state keys for warning timer
console.log('keys:', Object.keys(state).filter(k => k.match(/warn|kill|timer|sustain|max|instakill/i)).join(', '));

// Drive update
for (let i = 0; i < 50; i++) {
  sim.update(0.1);
  if (i === 0 || i === 30 || i === 49) {
    console.log('after step', i, ': susp=', state.suspicion.toFixed(2), 'time=', state.timeSec.toFixed(2), 'loseReason=', state.loseReason);
  }
}
