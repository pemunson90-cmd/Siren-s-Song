const fs = require('fs');

const html = fs.readFileSync('/sessions/inspiring-upbeat-mccarthy/mnt/sirens-song/code/sirens_song.html', 'utf8');
const m = html.match(/<script>([\s\S]*?)<\/script>/);
if (!m) { console.error('NO SCRIPT'); process.exit(1); }
const src = m[1];

function makeStubs() {
  const ctx = new Proxy({}, {
    get: (t, k) => {
      if (k in t) return t[k];
      if (k === 'canvas') return { width: 1200, height: 800 };
      return function(){};
    },
    set: (t, k, v) => { t[k] = v; return true; }
  });
  const canvas = {
    width: 1200, height: 800,
    getContext: () => ctx,
    addEventListener: () => {},
    getBoundingClientRect: () => ({ left:0, top:0, width:1200, height:800 }),
  };
  const document = {
    getElementById: (id) => id === 'game' ? canvas : null,
    addEventListener: () => {},
    body: { appendChild: () => {} },
  };
  const window = {
    addEventListener: () => {},
    requestAnimationFrame: () => 0,
    innerWidth: 1200, innerHeight: 800,
  };
  const performance = { now: () => 0 };
  const requestAnimationFrame = () => 0;
  return { document, window, performance, requestAnimationFrame };
}

function loadSim() {
  const stubs = makeStubs();
  const fn = new Function('document', 'window', 'performance', 'requestAnimationFrame',
    src + '\nreturn window.__sim;');
  return fn(stubs.document, stubs.window, stubs.performance, stubs.requestAnimationFrame);
}

module.exports = { loadSim };
