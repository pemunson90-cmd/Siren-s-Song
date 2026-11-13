# UI and UX audit: findings and yes/no list

Status: FINDINGS DELIVERED, 2026-11-12. No repair has been made. Pat answers the yes/no items; plain defects in part A are fixed without asking.

## How it was done

Three fresh critics played the real game by touch, from screenshots only, through the critic kit (`scripts/critic/`), at run branch commit 1dadecd7. None saw source, documents or an earlier audit.

| Critic | Screen | Assignment | Reached |
|---|---|---|---|
| A | cover 2520x1080 | Brand-new player | Title to the end of operation 1 (photo taken, lost to life support). 75 commands. |
| B | inner 2184x1968 | Every menu and side mode | Profiles, settings, credits, mode list, Career, Expedition and Campaign hub; a dive started in three modes. 46 commands. |
| C | cover | Every dive control, one at a time | Operation 1: wheels, tools, route editor, zoom, pause, camera, debrief. 72 commands. |

Not reached by anyone: operation 2 onward, drone B, recalling a drone, Fittings and Route Map in depth, a won dive's debrief, any Challenge (all twelve are locked on a new profile). Sound and phone feel cannot be judged by the kit. Screenshots are in the kit folder `%USERPROFILE%\.cache\sirens-song-toolchain\artifacts\fable-critic7-20261112\evidence\`.

## What is good (all three said so)

- The chart, rock art, craft and Siren look finished. The photo viewfinder with its Sharp and Light bars is the best screen in the game.
- Refusals give real reasons ("the camera reaches 240m", "Rock or unsafe clearance"). The route preview warns "CROSSES CHARTED ROCK". The undo button works.
- The Campaign briefing (a goal line, a danger line, short actions) is the clearest screen outside the dive.
- Settings work and visibly do something (high contrast, text size).

## The headline finding, and why it is marked "not confirmed"

Critics A and C both reported that tapping a wheel entry or a dialog button also dropped a route marker on the chart, and both ranked it first. Root replayed it in the same kit with exact coordinates (open the Quietus wheel, tap TOOLS, tap BACK, with and without a route set): every tap did one thing and nothing reached the chart. Both critics read positions from half-size screenshots and critic C noted its screenshots lagged a step, so the likeliest cause is taps that landed beside the control, on open water. That leaves a real, smaller issue (item B1): a tap that misses the wheel sets a route instead of closing the wheel.

## Part A: plain defects (fixed without asking, tested locally)

| # | Defect | Seen by |
|---|---|---|
| A1 | Wheel centre text is cut off: "UNKNOWN SIGN...", "NOT READY · SEARC...". The wheel is clipped by the left screen edge when the craft is near it. | A, C |
| A2 | Tools wheel shows the raw name "FIELD_TOOLS" and breaks "SONOBUOY" in the middle of the word. | C |
| A3 | The Expedition lost screen shows a dive hint ("Drones aboard. Tap a craft..."), "Hull 100% / Life support 100%" on a lost run, the seed line twice, and eight rows of "0 spent / 0 gained". | B |
| A4 | The Supplies page says "No dive yet" and "Hull 100%" while a dive is under way. | C |
| A5 | The route dialog says "has a route (1 stop)" for a route that is already finished. | C |
| A6 | Status line keeps old text ("Marker cancelled · orders unchanged") and stacks three or four lines. | A |
| A7 | In the Research / Archive screen the active tab is the greyed one; in Settings the active tab is the bright one. One style. | B |
| A8 | "TITLE" appears twice on the Campaign hub. | B |
| A9 | Zoomed in, chart labels (EXTRACTION, UNKNOWN SIGNAL SOURCE) grow huge and run through the craft. | C |
| A10 | The failure screen said "DRONE A · ABOARD" for a drone the critic believed was left in the water. To be checked before it is called a defect. | A |

## Part B: decisions for Pat (yes or no)

Ranked by how much each costs a player. "Rec" is Claude's recommendation.

| # | Question | Why | Rec |
|---|---|---|---|
| B1 | While a wheel or dialog is open, should a tap that misses it only close it, and never set a route? | Both dive critics lost most of their time to stray markers and replaced routes. Other touch games treat an open menu as owning the screen. | Yes |
| B2 | Add a LAUNCH DRONE entry to the Quietus wheel, and a RECALL entry to a launched drone's wheel? | Launching exists only as "tap water" with a drone selected, taught by one hint line. Neither dive critic found a recall at all. | Yes |
| B3 | Show the photographs taken (frame, grade) on the end-of-dive screen, lost dives included? | Both dive critics secured a photo, lost the dive, and the debrief said "The archive is silent". Photography is the point of the game. Whether a lost dive keeps its photo is your rule; this asks only whether the screen should show what was taken. | Yes |
| B4 | Confirm before any action that throws away a dive or a run? | Expedition "END DIVE · LOSE RUN" has no confirm (Career has one). In the Campaign hub, "NEXT OPERATION" during a dive silently discarded it. Android Back leaves a dive without asking. | Yes |
| B5 | Move the route dialog to a screen edge so it never covers the craft being ordered? | It opens on top of the craft at the bottom of the screen. | Yes |
| B6 | Should tapping a Siren select it and show what is known about it, not set a route onto it? | No way to read a threat by touching it. | Yes |
| B7 | One back pattern everywhere: a BACK button in the same place on every screen, and Android Back goes up one level? | Five different back labels were counted; Android Back from Naval Career skipped a level. | Yes |
| B8 | Rewrite the Career and Expedition briefings in the Campaign's goal and danger format? | They are walls of rules text. The words would be yours; Claude would lay out the format and you supply or approve the lines. | Yes |
| B9 | Replace jargon on the route and wheel screens with plain words? Examples seen: "INHERIT · STOP", "ADDED POINTS: PASS THROUGH", "ALL STOP 1.0% O2 · 6s restart", "RIDER · ACCEPTED", "CONFIRM REPLACEMENT" (for clearing a profile). | First-time players could not tell what these do. A wording table would come to you first. | Yes |
| B10 | Rename the FLEET button, or make it a real fleet list (all three craft, state, tap to select)? | It opens the wheel of the craft already selected. | Yes: real list |
| B11 | "STATUS" on the wheel opens the route program. Rename it, or make it a status page? | Mislabelled. | Rename |
| B12 | Depth change: show the change at once on the craft readout (for example "MIDDLE to DEEP, 4 s")? | A depth tap gave no visible feedback. | Yes |
| B13 | Results and fittings screens are lists of raw numbers ("LOCKER 0.85 / 1.00", eight zero rows). Show only what changed, in words? | Reads as a spreadsheet. | Yes |
| B14 | Put a one-line reason on every locked item (operations 2 to 6, Challenges, Career hulls), and make "selected" look different from "locked"? | Locked rows give no reason; a chosen hull and a locked one look the same. | Yes |
| B15 | Credits: move the engineering notes (file names, hashes, function names) off the credits page? | Reads as developer notes. | Yes |
| B16 | Use the full width of the cover screen for menus, and the lower half of the unfolded screen? | Menus are a narrow centre column with large empty areas. This is the larger restructure you marked "later" as A9 in the code audit. | Yes, as its own step after the items above |
| B17 | One name for each place: the first mission is "listening spire", "signal spire" and "Corran Bank" on different screens. Also "Disrupt" in the Sorley rescue brief where you ruled "It should just say EMP". | Story text is yours. | You choose the names |
| B18 | "IRONMAN · OFF to ON (ONE WAY)" sits beside the preset buttons with no confirm. Add one? | A one-way mis-tap. | Yes |
| B19 | Finger-drag scrolling did not move Credits, the Campaign hub panel or the briefing panel in the kit. The earlier cold review found this is a kit limit (the PC window does not report a touchscreen). Can you confirm on your phone that those three scroll by drag? | Cannot be tested here. | Please check |

## Not defects

- The DEVELOPER button in Settings is shown only in debug builds; a release build hides it.
- "Dive time is held until you choose": critic A read the pause label as a running clock; critic C confirmed time is held while the dialog is open.

## What this audit cannot tell you

Whether the game is fun, how it sounds, and how it feels in the hand. Three critics, one operation each in the dive: late-game screens were not seen.

## After Pat's answer (2026-11-12): what the code map changed

Pat approved every Part B item by Claude's judgement ("Youre here to fix the game. I can personalize it later"). Before building, a read-only survey mapped each item to its code. Five items turned out to describe behavior the game already has; the critics missed it or mis-tapped. They need no work:

| # | What the code already does |
|---|---|
| B1 | A tap outside an open wheel closes the wheel and is swallowed; it cannot reach the chart (`mission_hud.gd` blocker and `blocks()`). The stray markers the critics saw were second taps on open water. |
| B10 | FLEET already opens a wheel of all three craft with their state (READY, ROUTE, ABOARD, LOST) plus ARRIVALS, VIEW, OPERATIONS and AUDIO LOG. |
| B11 | STATUS opens a status sheet. The route program is PLAN ROUTE. |
| B12 | A depth change shows "MIDDLE to DEEP 3.2s" on the craft badge and in the wheel centre, and the depth buttons are disabled while it runs. |
| B18 | Ironman is already a two-step arm: the first tap changes the button to "CONFIRM IRONMAN · CANNOT BE UNDONE". |

Narrowed by the map:

- **B2:** RECALL exists, but two levels down (wheel, ROUTE, RECALL). LAUNCH has no button at all. Work: a LAUNCH entry for an aboard drone and RECALL on the drone's first wheel page. A recalled drone waits beside Quietus; it cannot go back aboard. Whether it should is a game rule for Pat (question for his playtest).
- **B3:** a lost dive drops its photographs, while the hub says "Field records remain reviewable after loss or abandonment", and opening the gallery after a loss keeps them anyway. Work: the lost screen lists the photographs taken with their grades. Which of the two rules is meant is a question for Pat.
- **B4:** the Campaign already asks "ABANDON THE CURRENT DIVE?" before launching over a dive, and Android Back only pauses. Missing confirms: Expedition "END DIVE · LOSE RUN" and Challenge "END ATTEMPT".

Build order: (1) B2 and B5 on the dive screen; (2) B3 and B4 on the end screens; (3) B6 tapping a contact; (4) B7, B14, B15 and the B9 wording pass in the menus; (5) B8 and B13 briefing and results layout; (6) B16 full-width layout; B17 names with the wording pass. B19 waits for Pat's phone.
