# Critic harness fix and the evaluation contract

Drafted 2026-10-30. Two halves: make the kit reliable, and make the critic's brief ask the questions that surface a design-level problem in one run.

## Part 1: harness fix (kit v4)

What failed: five stalls (G1-150, G2-797, T1-683, T2-028, C2-987) were the driver rejecting a command whose inbox JSON did not parse and the critic waiting forever. Root's v3 driver (now in the 123 kits) already returns an explicit `predispatch` rejection and publishes results by temp file then rename. Remaining gaps are on the sender side and in the contract.

1. **Sender watchdog.** `send.ps1` becomes `send-and-wait.ps1`: writes the command (temp then rename, as now), then polls `control/result.json` for the matching id for up to 60 s (wait commands: their duration plus 15 s). On timeout it writes one line to `control/faults.jsonl` (`{"id","command","fault":"no_result","heartbeat_age_s"}`) and returns a `HARNESS_FAULT` result to the critic, who may send the next command. The old send-then-poll-by-hand path goes away, so the critic cannot violate the ack rule.
2. **Driver heartbeat.** `driver.gd` writes `control/heartbeat.json` (`{"t", "busy", "frame"}`) every 2 s. The sender reports heartbeat age with every fault, so "driver dead" and "game busy" are told apart without reading `godot.log`.
3. **Inbox parse rejection, retained.** v3's `_reject_request` stays. Add a retry: on a parse failure of a non-empty inbox, re-read once after 50 ms before rejecting, because a half-written file is the likeliest cause of the historical faults (T1-327 saw a half-written result the other way).
4. **Self-test.** `playkit-selftest.ps1`: launches the game, sends 50 commands including a deliberately malformed JSON, a 3 s wait and a screenshot, and asserts one matching result per id, one rejection with a `.wire` dump, heartbeat age under 3 s throughout, and clean quit. Runs before every critic dispatch. A failing self-test blocks the dispatch; it never becomes a game finding.
5. **Classification rule in the brief.** A stall, missing result or `HARNESS_FAULT` is recorded as HARNESS. It becomes a GAME finding only with a `godot.log` excerpt showing a script error or a frozen frame counter. Critics write "game hang" nowhere else.
6. **Kit layout.** One kit folder per build tag under the artifact cache (`critic/<tag>/`), region sessions under it, `faults.jsonl` and `heartbeat.json` in `control/`. Nothing in the repo.

## Part 2: the evaluation contract

**Intent card (in the brief, 10 lines, from RULINGS.md).** What the player does: plans legs while paused, changes depth, works what is in reach, recalls drones, chooses when to be loud. What must be hard: crashing is possible, Sirens punish noise and exposure, bare fleet is a skill feat not the easy path. What must change outcomes: planning, drones, tools, fittings. The critic judges against this card and against the named reference, not against the game's own menus.

**Three questions per operation, fixed form.** For each op the critic fills: `DECIDED:` what choices I made that changed the outcome; `WATCHED:` what happened while I only waited; `LOST:` what I did not understand or could not find. Two more lines: `MIX:` the control-mix number the dev telemetry printed for this op (R5), and `REFERENCE:` the one thing the named reference game does better here. The verdict ranks findings from these, not from free prose. An op where WATCHED dominates DECIDED is the autopilot smell, visible on day one.

**Coverage contract, checked before a verdict counts.** Four regions in parallel, fresh sessions: opening (ops 0 to 5), middle, late through END OF LINE, side modes (expedition, career, challenges, Ironman opening). Required: at least one critic reaches an ending; every side mode is entered; both shapes; one session at 150% text; one Quietus-only and one drone-heavy attempt somewhere. The orchestrator checks the contract from the progress files; a missing item sends one more bounded session, never a verdict that says "unplayed".

**Caps.** 400 commands or 150k context per session, then a fresh session from a 20-line progress file (verdicts so far, evidence paths, remaining coverage). The 091 critic's 413M-token session must not recur.

**Reference comparison, blind and matched.** For each plan piece, one matched task: our capture (screenshots or a 20 s clip from the kit) and public footage of the named reference, labels and HUD brand marks cropped. A fresh Sonnet 5.5 session sees the pair, picks the stronger for the stated dimension, writes three lines. Recognised games are disclosed in the verdict. The ratchet: a change ships only if its piece wins or holds its pair at the next milestone; a loss sends the piece back to the plan, not to the trash.

**Audio and phone feel.** No model here hears or holds the phone. The nightly soundscape audit counts dropped voices, overlapping cues and missing cues per dense event from the event log (`soundscape.gd` allocates five shared voices). Pat gets one yes/no at a milestone playtest about one cue. Frame rate on Android needs an APK, which only Pat can order; the Xvfb `--print-fps` proxy is labelled as such.

**What is committed.** One compact verdict per milestone, under 25 KB, at `docs/design/COLD_REVIEW_<n>.md`: coverage table, ranked findings with evidence paths, the DECIDED/WATCHED summary per region, reference pair results, inherited versus new. Journals, screenshots, control logs and faults stay in the kit folder with a SHA-256 manifest.

## Why this would have caught "it's autopilot"

The 123 critics used "Route to reach work" as a normal action and praised the tactical core, because nothing told them hand piloting was the intent and nothing counted what they did versus watched. With the intent card, the WATCHED line and the MIX number, the opening-region critic would have reported "most of my movement was one tap and a wait, mix 70% one-press" on the first op. The nightly would have shown the same number without any critic.
