# Critic play kit

Tools for a blind whole-game critic: a fresh reviewer who plays the real game by touch, from screenshots, with no build notes. [AI-DESIGNED] tooling, added by the overhaul run of 2026-11-11. It replaces the unversioned kit copies that earlier critics kept in the tool cache.

| File | Purpose |
| --- | --- |
| `kit.py` | Builds a kit folder from a git ref, launches one game instance per slot, sends commands. |
| `driver.gd` | Runs inside Godot. Loads the game's main scene and turns JSON requests into parsed touch, drag, pinch and key events. It never calls game code and never reads simulation or save state; the `labels` command reads only the text and rectangles of interface labels. |
| `CRITIC_BRIEF.md` | What a critic judges and how to report. Give a critic this file and `OPERATE.md` only. |
| `OPERATE.md` | The command reference a critic needs. |

## Run a critic

```
python scripts/critic/kit.py new --ref <commit> --out %USERPROFILE%\.cache\sirens-song-toolchain\artifacts\critic-<name>
```

Copy `CRITIC_BRIEF.md` and `OPERATE.md` into `<kit>/brief/`. Give each critic its own slot (`a`, `b`, `c`), view (`cover` 2520x1080 or `inner` 2184x1968), session name, an assignment (a region or mode) and a command budget. Slots run side by side; each has its own control folder and its own isolated player data under `<kit>/private/<session>/<view>`.

To start a critic in the middle of the campaign, place an exported profile (`.qprofile`) in `<kit>/private/<session>/<view>/Roaming/Godot/app_userdata/Siren's Song/profiles/` and have the critic import it through Title, Profiles, Import. Record where the export came from. A profile staged with developer tools carries a DEV badge and cannot stand for earned play.

## Rules

- Kits, screenshots, journals and saves stay outside the repository. Commit only the merged, ranked findings.
- A critic gets the two brief files and nothing else: no watch list, no source, no earlier audit.
- The kit needs Windows with a GPU. The desktop can be smaller than the device size; the driver resizes its window after start and captures the full rendered viewport.
- The kit shows what the game drew and how it answered touch. It does not capture sound and does not stand for a phone.

## Protocol

The client writes `<kit>/control/<slot>/request-<id>.json`; the driver answers with `result-<id>.json` and renames the request to `done-...`. One file per request, written under a temporary name and renamed, so a reply is never overwritten or half-read. This replaced the single shared inbox and outbox of the earlier kit, whose parse failures stalled critics in October.
