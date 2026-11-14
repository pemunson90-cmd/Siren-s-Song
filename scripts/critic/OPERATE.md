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
| `screenshot` | `path` (absolute, forward slashes), `scale` (0.1 to 1, default 1) | Saves the rendered viewport as PNG. Use `scale` 0.5 for routine looks and 1.0 when you need to read small text. |
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

**Coordinates are native pixels** of the full-size viewport (cover 2520x1080, inner 2184x1968). If you saved a screenshot at `scale` 0.5, multiply positions you read from it by 2.

Batch the usual loop to save commands, for example tap, wait, look:

```
{"command":"batch","steps":[
  {"command":"click","x":1260,"y":531},
  {"command":"wait","seconds":1},
  {"command":"screenshot","path":"C:/.../evidence/NAME/012.png","scale":0.5}]}
```

In JSON on a command line, wrap the whole JSON in single quotes. In PowerShell, escape the inner double quotes, or pass it through a file **inside your own folder** `KIT/audit/<session>/` (for example `KIT/audit/<session>/cmd.json`), always by its full path. Never use a relative path or a file outside your folder: other critics may be playing at the same time from the same working folder, and a shared command file sends your taps into their game and theirs into yours.

## Evidence

Save screenshots under `KIT/evidence/<session>/` with numbered names. Keep a short running journal in `KIT/audit/<session>/JOURNAL.md` (what you tried, what happened, findings as you notice them), so a later session can continue from it. Open each screenshot you rely on with your image reader; do not infer a screen you did not look at.

## Limits to report

The window is rendered by a desktop GPU, off a phone. Sound is not captured. The kit proves what the game drew and how it answered touch; it does not prove phone comfort, frame rate on Android or audio quality.
