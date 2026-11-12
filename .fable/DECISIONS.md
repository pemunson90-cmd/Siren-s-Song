# Decisions for Pat: overhaul-20261111

Each item keeps the current behavior in place until Pat rules. Answer by number and letter, for example "D-03 B, D-07 A". Items can be answered in any order and at any time; the run never waits on them.

<!-- Format (FABLE_RUN.md section 9.3):
## D-NN <short title>
Status: OPEN
Raised: <date>, phase <n>, WP-NN
What: <one or two sentences, plain>
Options: (A) ... (B) ... (C) ...
Recommendation: <letter> because <one sentence>
Current state kept: <what stays in place until Pat rules>
-->

## D-01 Run continues without the command-text guard
Status: OPEN
Raised: 2026-11-11, phase 0
What: This session started in the other clone, so the run clone's PreToolUse guard, post-command restore check and stop gate never loaded. The git-level hooks work and were tested. Pat said "Just fix it snd go"; a guarded session could not be started from Remote Control, so the run continues here with the guard rules applied by hand.
Options: (A) Keep going in this session. (B) Pat opens the run clone in the desktop app and runs `/siren-s-start-fable`; the run resumes there from RUN_STATE.json with all hooks loaded.
Recommendation: B when Pat is next at the desktop, because it restores the enforced layer at no cost to progress; A until then.
Current state kept: the run continues in this session; nothing outside `fable/` can be pushed and no ref can be removed (git-level hooks).
