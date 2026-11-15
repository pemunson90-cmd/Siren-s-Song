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

`state` is one JSON object of what a player can know now: screen, operation, pause or run, speed, dive time, oxygen (percent and seconds left), hull, each craft (position, depth, route points, hold or task, battery, film, exposure), the contacts received (label as the chart shows it, last-seen position, age), the objectives as the chart shows them (search radius until found, FILED and photo grade after), extraction, tools left, lock warnings with seconds left, the Hunt stage, the strip's lines and every open card or prompt with its buttons. Away from a dive (title, hub, briefing, result) it lists the screen's text and buttons. It never names an unreceived Siren. `--truth` (debug builds only) adds the real Siren list under a block marked `TESTING ONLY`; do not play from it.

`order` takes `"order"` and fields: `start` (`operation`: opens a **Campaign** operation's briefing and presses ENTER WATER; the dive starts paused; it is refused while an Expedition or Naval Career is open), `route` (`craft`, `points` as `[[x,y],...]` in chart metres, `mode` `replace` or `append`; a drone still aboard is refused with "deploy it first"), `route_check` (same `craft`, `points`, `mode`; answers per leg whether it crosses charted rock, and plots and moves nothing), `depth` (`band` shallow, middle, deep, up or down; one band at a time, as the game allows), `deploy`, `recall` (`craft`), `photo` (optional `mode` wide or tight, `flash`, `focus`; `insist` presses again after the shutter's first-press warning; the answer's `flash` block says `asked`, `fitted`, `fired`, `charges_left` and, when you asked for a flash that did not fire, `why_not`), `tool` (`tool` emp, decoy with `point`, knock with `target` S number such as 1 for S1: it must be a fresh, clear contact within torpedo range, and a refusal lists the `clear_targets`; recon ...), `ping`, `silent`, `loud`, `hold` (`on`), `all_stop`, `select`, `pause`, `run`, `speed` (1, 2, 4; above 4 only in a debug build, through the console, which marks the profile DEV), and `answer` (`button`: press a button of an open card, prompt or screen by its label, for example `GOT IT`, `SEND ANYWAY` (the rock bar), `REPLACE ROUTE` (on the order wheel's ROUTE page), `NEXT DIVE`; `state` lists the labels that are open; part of a label is enough. When two buttons read the same, such as two `Scout drone`, add `index`: 0 is the first of them in the order `state` lists the buttons). Each returns `ok`, the game's own `message`, and on refusal `refusal` in the words a player would see. An order plots or starts something; it never moves a craft by itself (no teleport, no instant travel). A route that crosses charted rock is sent as the second tap on the marker would, and the answer carries `warning`.

**Expedition and Naval Career** are reached with `answer`, not `start`: `START GAME`, then `EXPEDITIONS` (`NEW SEEDED EXPEDITION`, `START THIS SEED`, `BEGIN OPERATION`) or `NAVAL CAREER` (`START NAVAL CAREER`, a contract by name such as `SHELF SIGNAL`, `ACCEPT CONTRACT`). Once a mode opens, `state` reads that mode's own screens and dive (it adds `mode_session`: `ExpeditionSession` or `CareerSession`), and `order` and `run` drive its dive; `BACK TO EXPEDITIONS` / `BACK TO GAME MODES` return to the menus.

`state` during a dive also carries `chart`: the rock the chart shows for the selected craft's depth band. An opening chart (`"kind":"opening"`) lists the briefed rock as polygons in chart metres under `rock`; an earned chart (`"kind":"earned"`) lists only the 40 m cells the craft has received as rock under `rock_cells` (`[x,y]` cell numbers; multiply by `cell_m` for metres). Unknown water and uncharted rock are never listed. Use `route_check` to test a leg before plotting it.

`run` (`seconds`, optional `speed`) runs the dive for that many game seconds, starting it if paused, and **stops early** at a pause the game made, a new Siren lock, a new card or prompt, a craft lost, a Siren hunting while sped up, or the dive's end. It returns `stopped` (why), the new `state`, the `events` and the `messages` that happened, and `game_seconds_per_real_second`. The dive is left paused afterwards, so `state` and `order` between runs cost no dive time. Answer a card with `order answer`, then `run` again. Keep `--timeout` above the expected real time of a long run.

## Evidence

Save screenshots under `KIT/evidence/<session>/` with numbered names. Keep a short running journal in `KIT/audit/<session>/JOURNAL.md` (what you tried, what happened, findings as you notice them), so a later session can continue from it. Open each screenshot you rely on with your image reader; do not infer a screen you did not look at.

## Limits to report

The window is rendered by a desktop GPU, off a phone. Sound is not captured. The kit proves what the game drew and how it answered touch; it does not prove phone comfort, frame rate on Android or audio quality.
