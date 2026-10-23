# Siren's Song cold review 2 (full pass)

Method: fresh save, Godot 4.6.3 under xvfb with llvmpipe, driven only by synthetic InputEventScreenTouch / ScreenDrag / pinch (two finger) plus Escape key and the Android go-back notification. Windows 1280x576 and 960x432. Screenshots in this folder (for example op1 photo result `fr1.png`, op2 death `u2.png`, lock banner `b3g.png`). I read source only to learn how to inject input and that the main scene is `main.tscn`. I did not read design docs or tests.

One setup note: Godot only turns touch into mouse clicks for Controls when `emulate_touch_from_mouse` / touchscreen is on. In a plain headless run with no touchscreen, ScrollContainer would not scroll from touch drags. I used a project copy with that setting on; on a real phone this is native touch, so not a bug.

## Verdict in one paragraph

The game has a strong identity: unlimited tactical pause, readable chart, a believable "sound is your enemy" rule, a clear lock countdown, and photography that is about viewpoint and range rather than a button. A new player can start op 1 without help. The weak points are not the core loop. They are (1) the briefing for ops 4 to 6 is a wall of jargon, (2) Back/Escape is dead on every title-overlay screen (Settings, Challenges, Challenge detail), (3) deaths tell you what killed you but not what you could have done, (4) a "Save rejected" message appeared in play on a clean save, and (5) a few layout and readability issues at phone size. Compared with Iron Lung, you have far more systems and far less dread; compared with a publishable stealth game, the biggest gap is feedback on why you were found and the amount of text a player must absorb.

## (A) Concrete bugs and readability fixes for a code worker (ranked)

### A1. Android Back / Escape does nothing on Settings, Challenges list and Challenge detail
- Saw: from the title, Settings, Challenges, and a challenge briefing. Sent `key escape` and the go-back notification on each. Screen did not change (frames `set2.png`, `set3.png`, `ch2.png`, `ch3.png`, `ch5.png`, `ch6.png`). Only the on-screen BACK button works, and on the Challenges list at 960x432 it is below the fold (y=636 on a 432 tall window) with no scroll hint, so a phone player must scroll to find the exit.
- Also: the main `_android_back` still runs under the overlay (it calls the campaign menu behind it), so state changes silently behind the overlay while nothing visible happens.
- Why it matters: Android players press Back reflexively. Dead Back on three screens reads as a hang, and play stores flag it.
- Remedy: the title overlay (frontend) should own Back: Settings and Challenges return to the title, Challenge detail returns to the list, title Back shows an exit confirm or minimises. Put BACK at the top of the Challenges list (or as a sticky footer) and add a scroll indicator.

### A2. "Save rejected: unsupported or invalid archive." appeared during normal play on a clean save
- Saw: op 1, about 38 to 50 s into the dive, seconds after taking the second photograph and while placing orders. The top status line read "Save rejected: unsupported or invalid archive." (log: no `SS_SAVE ok` between, the next save succeeded). It replaced the normal status text for one action. Task owner note: I also saw it again on op 6 after I used a debug helper that set progress directly, so that second sighting may be my doing; the op 1 sighting was before any helper.
- Why it matters: for a save system this is the scariest possible string. A player cannot know the next save worked.
- Remedy: find the state that fails `valid(data)` mid-exposure (probably a photo or capture record half written between frames), validate or defer saves while an exposure is in flight, and never show the rejection text to the player unless a retry also fails. Log the failing key.

### A3. Briefings for ops 4, 5 and 6 are walls of jargon
- Saw (`b4a.png`, `b5a.png`, `b6a.png`): a 6 to 8 line paragraph that says things like "The furnace sentinel holds MIDDLE; the recovery sentinel and the plant's deep motor work DEEP", "An unverified archive is valid", "A deep pass is no engine reference", then a repeated generic ORDERS paragraph, then the Field Manual. Ops 1 to 3 are one short GOAL and one DANGER line, which works well.
- Why it matters: this is the point where the player is expected to absorb new rules (layers, cycles, receivers). It reads as rule text, not as a mission, and most players will skip it and then die to a rule they were told.
- Remedy: keep GOAL and DANGER to two lines for every op, move rule text into collapsible "what's new in this op" with one bold new concept, and drop the repeated ORDERS block after op 2. Replace internal words (sentinel, aperture, verified archive) with what the player sees.

### A4. Fittings sit under a scroll with no cue, and the list shifts when RESUME appears
- Saw: the loadout/fittings block is below the briefing and field manual. On a fresh save every mount reads "empty" (`fit1.png`), so the screen looks like dead text. The only hull choices cycle one tap at a time (STANDARD, LOW NOISE, FAST TRANSIT) through one button that also changes its own label and moves position as the description grows (`fit4.png`, tapping the same place twice moved to a different state).
- Also: when a dive is resumable a RESUME DIVE row appears on the ops list and pushes every mission row down about 50 px. My own taps landed on the wrong mission twice.
- Remedy: put fittings in a tab or a separate screen with a visible "FITTINGS" entry; use a selector with all three hulls visible at once; keep mission rows fixed and show RESUME as a banner above or below them.

### A5. Tutorial hint cards come back every launch
- Saw: relaunching to op 2 (`a10.png`) and op 6 (`sm1.png`) re-showed the "Tap QUIETUS or a drone..." card. The player who has finished op 1 sees "Tap a craft..." again.
- Remedy: persist seen hints in the settings file or save.

### A6. Lock banner can go stale after a Disrupt
- Saw (op 3, `b3h.png`): after Disrupt, the banner still said "S1 PATROL → DRONE A · BEAM 3.8s" while the Siren was stunned, and the lock arc over S1 was still partly drawn. It cleared after the stun ended and then relocked and killed Drone A when I ran 30 s without checking.
- Why: the player cannot tell whether Disrupt worked.
- Remedy: show "S1 DISRUPTED 12 s" (counting down) in place of the lock text; draw a stun ring on the Siren.

### A7. Small text in the viewfinder and status lines at phone size
- Saw: at 1280x576 the viewfinder lines ("SHUTTER heard to 520m", "STOPPED CLOCK sharp inside 130m", "SHARP 79% LIG...") are about 9 px tall and truncated by an ellipsis ("LIG..."), exactly where the player needs the answer (`w6.png`, `b5d.png`). At 960x432 the same text is about 7 px.
- Remedy: cap the viewfinder to three lines, enlarge, and show the two numbers a player cares about (sharpness, light) as two bars instead of a clipped string.

### A8. Title screen exposes ERASE PROGRESS directly under CONTINUE
- Saw (`t960.png`): the second button on the title is "ERASE PROGRESS · NEW CAMPAIGN". A confirm exists, but a first-time tap on the wrong row of five is a few pixels off.
- Remedy: move Erase into Settings (or at least to the bottom, danger-coloured).

### A9. Touch target sizes
- Measured (window pixels, 1280x576): menu buttons 38 px, ring buttons 59x38, unit chips 38x38. At 960x432 menu buttons are 34 px. The game scales them from a 1600x720 virtual canvas, so physical dp depends on the device's reported density; on desktop DPI (96) the numbers equal the game's own 48 virtual px. I could not verify real Android dp. The "UNDO" button (122x44) and zoom buttons were fine. The unit chips are the smallest and the most used.

## (B) Design-level weaknesses needing a decision (ranked)

### B1. Deaths explain "what" but not "what to do differently"
- Saw: op 2 death (`u2.png`): "SIGNAL LOST. VAPORIZED · Siren beam struck Quietus." No time of first detection, no "you were heard at X because Y". The in-play banner "S2 SWEEPER → QUIETUS · BEAM 0.9s" is excellent, but it is the only teaching.
- Why it matters: the game's core question is "why was I found?". Iron Lung gets away with unexplained death because the loop is a few seconds; this game has 2 to 3 minute dives and a retry button only.
- Decision: add a one-line cause on the death screen ("heard: your engine at 3 m/s in open water, 41 s in; it walked to that spot") and a replay-free "last 10 seconds" chart still frame with the Siren's path and your noise ring.

### B2. Photography is central in ops 1 and 2 but quality feedback arrives late
- Saw: shot 1 in op 1 gives "Record secured" at once; the quality number (frame 2 of 2, 62%, grade B, "resolved: beacon lamp 92%, drill string 64%") only appears in the debrief (`fr1.png`). Viewfinder does say things like "STOPPED CLOCK hidden from here · go round the subject", "TOO DARK · add light or close in", "FLASH not fitted / WAIT needs the low-light back / CLOSE to 130m ok" and the sharp % changes with position (op 2: 21%, 30%, 74%, 79% at different spots). That part is good and discoverable.
- What I did not confirm: a deliberately weak frame. I never shot a bad frame on purpose, so I cannot say whether a weak frame fails, partly pays, or is simply accepted. The debrief wording ("average 61% of each record's best frame") suggests partial payment.
- Decision: show a quality chip right after the exposure ("62% · C") and a reshoot prompt when below a threshold, so the retry loop is visible in the moment, not after extraction. Make clear that closer or from the lit side pays more.

### B3. Much of the tension depends on one four-second lock window
- Saw: lock warning in ops 1 to 3 gives about 3 to 4 s of sim time to respond (first warning 3.9 s remaining in op 3). Because pause is unlimited, the human can respond; the sim does not punish slowness. But the first appearance of a Siren is often the lock itself (op 3: a patrol beside the request relay was invisible until it locked, `b3f.png`).
- Decision: either guarantee one sighting or sound cue before the first lock on each op (a "something is near" tone, a faint contact), or accept that first contact is a free death and make the retry very cheap. Right now retry is OK but you have to go through the briefing again.

### B4. Variety and pacing across ops 1 to 6
- Ops 1 and 2: photograph and link, good ramp. Op 3 changes the verb to SAMPLE/TRANSFER with a "Q ABOARD 0/2 · FIELD NOTES 0/2" line that is hard to parse. Op 4 adds layers and cycles, op 5 adds listening comparison, op 6 adds six-second listen with a packet. Each op teaches a new system but from a text paragraph, not from play.
- Decision: introduce one new verb per op through a safe first beat in the water (a prop that demonstrates it) instead of through briefing text.

### B5. The campaign beyond op 6
- Saw: the Challenges list lists ops up to 30 (e.g. "LUNG / QUIETUS ONLY / LOCKED · recover operation 30") and after recovering op 6 the ops list shows "The Divergence · AVAILABLE". I did not play beyond op 6, so I cannot judge the middle game. I noticed that, on the ops list, the first six rows are labelled "RECOVERED" with no sense of story or route; there is no map or branching view on the screens I saw.
- Decision: a simple route screen showing the branch and what each op unlocks would turn the list into a campaign.

### B6. Fittings and research have no visible reward loop at the start
- Saw (`ir1.png`): the Intel screen lists four camera research goals ("OPEN FLASH UNIT · needs COLD FOUNDRY / VENT LINING at 35% (best 0%)"). That is a real carrot, but with all fittings empty, a new player has nothing to spend or fit through ops 1 to 3.
- Decision: grant one visible module after op 1 or 2 so the fittings screen has a first decision.

## What works and must be protected

- Unlimited pause and the radial command ring: tap a craft, get PHOTO / DEPTH-SONAR / SILENT / PLAN ROUTE / ROUTE / TOOLS / ALL STOP / STATUS / BACK, readable and tappable (`m3.png`, `o2m.png`).
- The lock warning: the banner across the top plus the arc over the Siren and a seconds countdown is a model of fair readable tension (`b3g.png`).
- The first-dive hints that say what is possible ("Closer is clearer", "PAUSE is always at top left") appear as small cards at the right moment.
- Viewpoint-dependent photo hints in the viewfinder ("hidden from here · go round the subject", "too dark · add light or close in").
- Clean save: quit and relaunch resumed op 1 and op 2 exactly ("Mission restored · paused for review"), no recovery warning on a clean install.
- Mission Escape/back goes to the ops list and pauses, and it saves.
- Route program screen (`w8.png`) is legible and the Back from it returns to the chart.
- The Foundry and Well art (large structures, drawn from above) gives real scale (`b4b.png`, `b5b.png`).
- Debrief "Field photograph records" frame-by-frame, with compare frames and aspect/ distance/ light/ clarity lines.

## Limits (what I did not do)

- I did not hear audio. Dummy audio driver; no audio events were logged beyond none visible in the log. I cannot say anything about sound design.
- I did not finish ops 3, 4, 5 or 6. I reached the start of each (briefing, chart, first orders), played op 3 far enough to find the first patrol and test Disrupt, got op 5's "Return archive" photo, and saw op 4 and op 6 only at the start. Ops 3 to 6 were reached with a debug-like helper that sets progress (my own driver, not a game feature), because playing five missions to completion under software rendering was impractical here. The "Save rejected" on op 6 may be a side effect of that helper.
- I did not play ops 7 and later, so I cannot judge difficulty spikes, softlocks or the end of the campaign. I saw the ops list change to "The Divergence · AVAILABLE" only.
- I did not fire a torpedo, decoy or survey ping; I tested Disrupt only. I did not test the hunter or the sweeper's decoy handling, and I did not test film running out.
- I did not deliberately take a weak photograph, so "does a weak frame fail or partly pay" is only partly answered (the debrief shows a 62% frame still counted and graded B).
- I did not test text size 115 to 150%, high contrast, or reduced motion.
- Performance: software rendering. I saw no logic stalls (the `_process` loop and the Godot log showed only ALSA, vsync and audio-device warnings, no script errors). Frame times are not representative.
- Touch target sizes depend on real Android density, which I cannot simulate. Numbers above are window pixels.
