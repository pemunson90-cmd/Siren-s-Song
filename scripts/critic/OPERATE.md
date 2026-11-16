# Operating the critic kit

The kit runs the real game in a window and lets you play it by touch. You see the game only through screenshots. One game instance runs per slot; your dispatcher gives you your kit folder, slot, view and session name.

`KIT` below is the kit folder. `TOOL` is the path to `kit.py` that your dispatcher gave you. Run commands from any shell.

## Start and stop

```
python TOOL launch --kit KIT --slot SLOT --view cover --session NAME
python TOOL quit --kit KIT --slot SLOT
```

`launch` prints `"ready": true` when the game renders at the device size: cover is 2520x1080, inner is 2184x1968. The same session name and view resumes the same isolated player profile; a new name is a new player. If `launch` says a runtime is already live, use it. Quit when you finish.

## Commands

```
python TOOL send --kit KIT --slot SLOT '<json>'
```

It prints the result and exits non-zero on failure. One command at a time. `send` waits up to 150 seconds for the result; for a batch whose waits add up to more, pass `--timeout SECONDS` before the JSON (for example `--timeout 400`). Screenshot paths must be inside the kit folder.

| Command | Fields | Effect |
| --- | --- | --- |
| `screenshot` | `path` (absolute, forward slashes, inside `KIT/evidence/<session>/`, for example `C:/Users/.../KIT-folder/evidence/critic-a/012.png`; no `..`, no relative path), `scale` (0.1 to 1, default 1) | Saves the rendered viewport as PNG. Use `scale` 0.5 for routine looks and 1.0 when you need to read small text. If a capture is refused as "outside the kit folder", compare your path text with the kit folder's full path first. |
| `click` | `x`, `y` | One touch tap. |
| `hold` | `x`, `y`, `seconds` | Touch and hold. |
| `drag` | `x`, `y`, `to_x`, `to_y`, `seconds`, `steps` | One finger drag (pan, scroll, sliders). |
| `pinch` | `x`, `y`, `from_gap`, `to_gap`, `seconds` | Two finger pinch around a point. A growing gap zooms in. |
| `wheel` | `x`, `y`, `notches` (positive scrolls down) | Mouse wheel at a point. Use it to scroll menus: on a PC without a touchscreen a finger `drag` does not scroll a menu, so a menu that will not drag here is not a finding. |
| `back` | | The Android back button. |
| `key` | `key` (for example `Escape`) | A keyboard key. Keyboard is a fallback; touch is the design target. |
| `wait` | `seconds` (up to 120) | Lets the game run. |
| `labels` | | Text and rectangles of visible interface labels, in native pixels. Advisory: it can include labels hidden under another screen. The screenshot is the authority. |
| `geometry` | | Window and viewport sizes. |
| `batch` | `steps`: a list of the commands above | Runs them in order and returns every result. Counts as one command against your budget. |
| `debug` | `line`: one debug console line | Runs the game's debug console on that line, for example `{"command":"debug","line":"jump 6"}` (also `kit.py debug --kit KIT --slot SLOT --line "jump 6"`), and returns its reply. Lines: `jump N`, `time 1..16`, `invulnerable on`, `oxygen lock`, `known`, `win`, `lose`, `unlock`, `granttools`, `help`. |

**Coordinates are native pixels** of the full-size viewport (cover 2520x1080, inner 2184x1968). If you saved a screenshot at `scale` 0.5, multiply positions you read from it by 2.

Batch the usual loop to save commands, for example tap, wait, look:

```
{"command":"batch","steps":[
  {"command":"click","x":1260,"y":531},
  {"command":"wait","seconds":1},
  {"command":"screenshot","path":"C:/.../evidence/NAME/012.png","scale":0.5}]}
```

In JSON on a command line, wrap the whole JSON in single quotes. In PowerShell, escape the inner double quotes, or pass it through a file **inside your own folder** `KIT/audit/<session>/` (for example `KIT/audit/<session>/cmd.json`), always by its full path. Never use a relative path or a file outside your folder: other critics may be playing at the same time from the same working folder, and a shared command file sends your taps into their game and theirs into yours. The same holds for any helper script or temporary file you write: keep it in `KIT/audit/<session>/`, never in `/tmp`, the system temp folder or the working folder (on 14 November one critic's helper in `/tmp` was overwritten by another's and a batch silently did nothing).

`debug` is for root's own checks and for fun-focused rounds that need to reach a state quickly. It marks the profile DEV, as typing the line in the game would. Blind interface critics play without it unless their brief says otherwise; they reach every state by touch.

## Driving by state, order and run (no pixels; headless allowed)

Which way to play depends on what you judge. **Gameplay and fun testers drive with `state`, `order` and `run`**, and may launch with `--headless` (no window, no GPU). **Interface critics keep screenshots and taps**, because they judge what the screen shows; `state` never replaces looking.

```
python TOOL launch --kit KIT --slot SLOT --session NAME --headless
python TOOL state  --kit KIT --slot SLOT
python TOOL order  --kit KIT --slot SLOT '{"order":"start","operation":1}'
python TOOL order  --kit KIT --slot SLOT '{"order":"route","craft":"QUIETUS","points":[[400,760],[800,640]],"mode":"replace"}'
python TOOL run    --kit KIT --slot SLOT --seconds 30 --speed 4
```

`state` is one JSON object of what a player can know now: screen, operation, pause or run, speed, dive time, oxygen (percent and seconds left), hull, each craft (position, depth, route points, hold or task, battery, film, exposure), the contacts received (label as the chart shows it, last-seen position, age), the objectives as the chart shows them (search radius until found, FILED and photo grade after), extraction, tools left, lock warnings with seconds left, the Hunt stage, the strip's lines, `controls` (below) and every open card or prompt with its buttons. Away from a dive (title, hub, briefing, result) it lists the screen's text and buttons. It never names an unreceived Siren. `--truth` (debug builds only) adds the real Siren list under a block marked `TESTING ONLY`; do not play from it.

`order` takes `"order"` and fields: `start` (`operation`: opens a **Campaign** operation's briefing and presses ENTER WATER; the dive starts paused; it is refused while an Expedition or Naval Career is open), `route` (`craft`, `points` as `[[x,y],...]` in chart metres, `mode` `replace` or `append`; a drone still aboard is refused with "deploy it first"), `route_check` (same `craft`, `points`, `mode`; answers per leg whether it crosses charted rock, and plots and moves nothing), `depth` (`band` shallow, middle, deep, up or down; one band at a time, as the game allows), `deploy`, `recall` (`craft`), `operate` (the mission job button: decode, link, sample; beside a Siren in reach the camera slot is PHOTO and `photo` frames the Siren, so use `operate` for the job; with no Siren in reach it does what `photo` does), `photo` (optional `mode` wide or tight, `flash`, `focus`; `insist` presses again after the shutter's first-press warning; the answer's `flash` block says `asked`, `fitted`, `fired`, `charges_left` and, when you asked for a flash that did not fire, `why_not`), `tool` (`tool` emp, decoy with `point` (or, from a lock card, with no point: `answer` `DECOY` arms it, the lock card's prompt in `state` then carries `decoy_point` [x,y], the marked working point that breaks that lock, and `order tool decoy` with no point drops there as a tap on the marker does; a drone whose own rack holds no decoy is refused as "DRONE A carries no decoy", and `tools.by_craft` in `state` lists each craft's own rack), knock with `target` S number such as 1 for S1: it must be a fresh, clear contact within torpedo range, and a refusal lists the `clear_targets`; recon ...), `ping`, `silent`, `loud`, `hold` (`on`), `all_stop`, `select`, `pause`, `run`, `speed` (1, 2 or 4 only; any other speed is refused with "Speed N is not offered", and `run --speed` likewise runs at the speed it already had and says so in `speed_note`. Odd speeds exist only through the `debug` console line `time N`, which marks the profile DEV: do not use it in a playthrough), and `answer` (`button`: press a button of an open card, prompt or screen by its label, for example `GOT IT`, `SEND ANYWAY` (the rock bar), `REPLACE ROUTE` (on the order wheel's ROUTE page), `NEXT DIVE`; `state` lists the labels that are open; part of a label is enough. When two buttons read the same, such as two `Scout drone`, add `index`: 0 is the first of them in the order `state` lists the buttons). **Order wheel buttons.** The wheel has pages that `operate` cannot reach: TOOLS, ROUTE, GUARD, DEPTH AND SONAR, and, near a job site, REACH WORK (Needle Strait's RELEASE VANE, RESTORE SERVICE, SEVER SPUR, OPEN LOCAL GATE, RECOVER MATERIAL, TRANSFER) or CHOIR WORK (the Iron Choir jobs), and CACHE. `state` lists them for the selected craft under `controls`: `[{"page":"glass","name":"REACH WORK","controls":[{"label":"RELEASE VANE","enabled":false,"reason":"Meet local work within 60m ..."}, ...]}, ...]`, the first entry being the wheel's root page `craft`. A greyed-out button carries the game's own reason. `order` `control` does what a player does: opens that craft's wheel, goes to the page that holds the button, taps it (twice where the wheel asks to confirm), and closes the wheel. Fields: `label` (part of the label is enough; line breaks read as spaces; an `index` picks among several matches), optional `craft`. `{"order":"control","label":"RELEASE VANE"}`. A button that exists but is greyed out is refused with its own reason ("RELEASE VANE is greyed out: Meet local work within 60m..."); with no match the answer lists every page and label in `available` (a page appears only while its work is in reach: REACH WORK shows from the work site's neighbourhood, so sail there first). The time and the craft's job are the game's: the job starts and runs with the dive. **Route Map and branches.** On the Campaign screen, `answer` `ROUTE MAP` opens the chart. `state` then has a prompt of kind `route_map` listing BACK, LEGEND, CURRENT and one button per operation named in full, such as `01 SHELF SIGNAL · AVAILABLE`, with its `state` (AVAILABLE, LOCKED, RECOVERED, KNOWN FROM PHOTOS) and `can_open`. `answer` with `01 SHELF SIGNAL` (or part of it) opens that operation's briefing as a tap would (it taps twice when the chart is zoomed out, as a player's second tap does); a node that cannot be opened only changes the chart's detail line. The first operation of a region first shows a region card (prompt kind `arc_card`): `answer` `CONTINUE TO BRIEFING`, then `start` or ENTER WATER as usual. The Route Map is not needed to choose a branch: the ops list on the Campaign screen lists every open operation, and after 06 The Divergence the branch is chosen in the dive itself, by the corridor Quietus exits through (DEEP DESCENT in the north-east, SHELF PASSAGE in the west; the exit selects the next dive, and recovering both carrier fixes keeps both accounts). After the result, the Campaign screen shows the opened operations (and a CONTINUE CURRENT BRANCH button), and `start` opens the one you name.

Each returns `ok`, the game's own `message`, and on refusal `refusal` in the words a player would see. An order plots or starts something; it never moves a craft by itself (no teleport, no instant travel). A route that crosses charted rock is sent as the second tap on the marker would, and the answer carries `warning`.

**Expedition and Naval Career** are reached with `answer`, not `start`: `START GAME`, then `EXPEDITIONS` (`NEW SEEDED EXPEDITION`, `START THIS SEED`, `BEGIN OPERATION`) or `NAVAL CAREER` (`START NAVAL CAREER`, a contract by name such as `SHELF SIGNAL`, `ACCEPT CONTRACT`). Once a mode opens, `state` reads that mode's own screens and dive (it adds `mode_session`: `ExpeditionSession` or `CareerSession`), and `order` and `run` drive its dive; `BACK TO EXPEDITIONS` / `BACK TO GAME MODES` return to the menus.

`state` during a dive also carries `chart`: the rock the chart shows for the selected craft's depth band. An opening chart (`"kind":"opening"`) lists the briefed rock as polygons in chart metres under `rock`; an earned chart (`"kind":"earned"`) lists only the 40 m cells the craft has received as rock under `rock_cells` (`[x,y]` cell numbers; multiply by `cell_m` for metres). Unknown water and uncharted rock are never listed. Use `route_check` to test a leg before plotting it.

`run` (`seconds`, optional `speed`) runs the dive for that many game seconds, starting it if paused, and **stops early** at a pause the game made, a new Siren lock, a new card or prompt, a craft lost, a Siren hunting while sped up, or the dive's end. It returns `stopped` (why), the new `state`, the `events` and the `messages` that happened, and `game_seconds_per_real_second`. The dive is left paused afterwards, so `state` and `order` between runs cost no dive time. Answer a card with `order answer`, then `run` again. `run` is refused (`stopped` is `lock_card_open`) while a lock card is open and unanswered, so the ship cannot be lost by not reading it; answer the card, or send `run` with `"insist":true` (`kit.py send`) to run through the lock on purpose. Keep `--timeout` above the expected real time of a long run.

## Evidence

Save screenshots under `KIT/evidence/<session>/` with numbered names. Keep a short running journal in `KIT/audit/<session>/JOURNAL.md` (what you tried, what happened, findings as you notice them), so a later session can continue from it. Open each screenshot you rely on with your image reader; do not infer a screen you did not look at.

## Limits to report

The window is rendered by a desktop GPU, off a phone. Sound is not captured. The kit proves what the game drew and how it answered touch; it does not prove phone comfort, frame rate on Android or audio quality.
