BUILD: "Deep Contact" — a single-file browser game.

CORE LOOP (one sentence):
Ping the dark ocean, classify each ambiguous sonar return as
geology / survey-artifact / the Unit, and commit to a read you
can never confirm — until the consequence tells you.

WIN / LOSE:
- Win: reach the extraction point on the far side of the map.
- Lose: the Unit reaches you, OR you run out of ping power while
  not yet at extraction.
- Critical: the game NEVER confirms a classification was correct.
  The only feedback is what happens next. No score popups, no
  "correct!" — consequence is the only signal.

HARD TECHNICAL BOUNDARY (do not exceed):
- ONE self-contained .html file. Inline CSS + JS. HTML5 canvas.
- No external assets, no images, no libraries, no build step.
- All visuals procedural (shapes/gradients). Sound optional via
  Web Audio API only (a ping tone), and must be skippable.
- Mouse-driven. Runs by double-clicking the file. Desktop browser.

PLAY LENGTH: 5–10 minutes, single screen, one session.

MECHANICS:
- Screen is near-black. A PING reveals returns within a radius,
  which fade over ~2 seconds back to black. Limited ping budget
  (start ~25), shown as remaining power.
- Three return types, distinguished by SUBTLE tells:
    * Geology  — large, static, irregular blob. Harmless.
    * Artifact — straight parallel lines / striped texture
                 (survey sonar tracks). Noise. Harmless.
    * Unit     — geometric, and it MOVES between pings. Hunts.
- Click a return, choose a classification. Correctly marking the
  Unit lets you plot a path that avoids it. Marking it as harmless
  lets it close distance on you each ping.
- You move toward extraction a step at a time; each move and each
  ping is a decision under the fog.

BUILD ORDER (important):
1. Playable v1 first: ping, the three return types with tells,
   classify, the Unit advancing on misread, win/lose. Make the
   LOOP fun before anything else.
2. Stop. Let me playtest and tune the tells.
3. Only then: polish (sound, fade timing, intro text).

DO NOT: add menus, multiple levels, procedural map generation,
settings screens, or a tutorial. If it isn't the core loop, leave
it out of v1.
