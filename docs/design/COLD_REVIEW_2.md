# COLD REVIEW 2 (PARTIAL DRAFT, play stopped in operation 1)

Scripted touch events under Xvfb with software rendering. No audio, no real phone. Reached only op 1 (Shelf Signal), four dives. Everything below about ops 2 to 18, fittings, the ending, Challenges, Android Back and sound is NOT tested.

## Verdict
The camera idea has real bones: a viewfinder that lists why a frame is weak (FLASH not fitted, CLOSE to 155m ok, SHUTTER heard to 520m) and a shutter that wakes Sirens is a genuine trade. But the first twenty minutes are lethal and opaque: two of four dives ended in VAPORIZED, the scout drone died at the same spot both times, and the opening route hurts you before any Siren appears. The photographs themselves are the weakest link: two frames taken 11m apart look identical, so the picture teaches nothing.

## Ranked fixes (photography)
1. Photos are a fixed drawing, not a viewpoint (big). Archive frames 1 and 2 of the Signal Spire (168m, quality 33% and 179m, quality 29%) show the same tower and lamp; only the numbers changed. Remedy: let distance, heading and band visibly change what is drawn, and show features the player did not already know about.
2. Target is confirmed, not discovered (big). The goal reads "SIGNAL SPIRE" and the ring and 'BRG' bearing are given. One 33% frame produced "Record secured". Remedy: make a low frame fail or only partly pay.
3. Film is barely a budget in op 1 (medium). Quietus had 8 frames and used 1; drone had 4. Film is spent when the exposure starts (7/8 at 0%), so a Siren-interrupted frame is still lost, which is fair, but nothing made me ration.
4. Viewfinder text covers the picture (medium). On a 1280x576 window the thumbnail is about 330px wide and four red lines sit on top of it.
5. Sirens are photographable ("S1 PATROLLER: SENSOR ARRAY: TOO SOFT") which is promising, but the one time I tried, the drone was beamed within a second. Not enough tested to judge payoff.
6. Archive "Intel and Research" button sat below the fold; my drag did not scroll it. Not confirmed on a real phone.

## Ranked fixes (everything else)
1. Opening self-collision (big). Both dives: first order, a straight route east, rams Drone B: "Hull strike 42m/s, hull -13%" then "37m/s, -11%". The text never says what was hit. Remedy: spawn drones off the opening lane, or route around friendly craft.
2. Warning gives no thinking time (big). S2 LOCK card showed 2.6s then 1.1s, game running. The "first Siren warning pause" never fired in my fresh-save dive: a hint card "A sweeper Siren heard noise..." appeared with GOT IT while sim time kept advancing (paused=false on every poll) and Drone A was beamed about 13s in. The pause seems keyed to Quietus being locked, not a drone. Question for owner: should the tutorial pause also trigger for drones?
3. Scouting drone is unreadable bait (big). Sweeper went INVESTIGATE at 4s sim time, LOCKING at 9s, BEAM at 13s, drone dead at (894,570) in both runs. Nothing taught why.
4. Goal not visible at start (big). The first view is zoomed on Quietus; the objective ring appears only after FLEET > VIEW > FIT. Radial said "NOT READY 1263m" but not which way.
5. Controls buried (medium). ALL STOP is Quietus > ROUTE > ALL STOP, two taps deep, costs 1.0% O2, and is not on the main wheel. VIEW is under FLEET. Tool names (DECOY, DISRUPT, SURVEY, EMIT, SECTOR, POWER, HISTORY) have no explanation in the wheel. Radial centre text overlaps the BACK label.
6. Accidental orders (medium). Tapping near, not on, a craft plots a route. Confirm panel buttons wrap badly ("REPLA CE ROUTE", "CANCE L"). Pause button says "RUN" then "RESUME" for the same state.
7. Briefing/manual jargon (medium): "lee plating", "passive bearings", "layers". Wall of text.
8. Stale HUD from the previous dive (old viewfinder, "BEAM 0.1s" warning) shows behind the briefing and archive (polish).
9. Fresh install on a machine with other Godot saves showed "Primary archive was unreadable. Recovered previous backup." to a new player; likely test pollution, unconfirmed.

## What works, protect it
- Lock card: "S2 LOCK 1.1s. Break sight with cover. DISRUPT or torpedo impact interrupts." Clear, and DISRUPT genuinely saved me once (OP PRESSURE DORMANT, 12s window).
- Viewfinder reasons list and the 4s hold with live SHARP/LIGHT/CLARITY numbers.
- Shutter noise drawing the sweeper (bearing and seconds shown: "HEARD SWEEPER INVESTIGATING 272 deg 0.2s"). The camera has a price.
- ERASE PROGRESS confirmation; clean minimal chart look; PLAN ROUTE editor.

## Five differences (limited evidence)
1. Individual locks: in my play, readable and fair at 2.6s, harsh at 1.1s; better than a vague meter. 2. Hunt: not observed. 3. Two vulnerable drones: drones die fast and teach little; ALL STOP works but is hard to find; untested vs SILENT. 4. Real photography: better in concept, worse in the picture itself. 5. Branching campaign: not reached.

## Limits
Only op 1 played, four dives, harness polled at 30 to 60 frame steps at 1x to 3x so reaction times are not human. Not tested: questions 5, 6, 8 (sound), Challenges, Android Back, depth bands for photos, flash, ops 2 to 18, performance. Log had no errors seen but I did not scan it fully.
