# Siren's Song — Step-Agent Operating Doc

**Audience:** Any Cowork Dispatch child running a single §11 build step (steps 1–7).
**Authority order:** `SIRENS_SONG_SPEC.md` (canonical) > this file > orchestrator brief > step brief in `briefs/`.
**Read this file BEFORE you start.** If you can't reconcile this file with the spec, the spec wins. If you can't reconcile this file with your step brief, surface it — don't paper over it.

---

## 1. Your mandate (one step, one boundary)

You are executing **exactly one numbered step** from §11 of the spec. Not two. Not "step 3 plus a little of step 4." The daisy-chain only works if each agent does its own segment and stops at the seam.

- Your step number and scope are in your assigned brief at `briefs/NN_<slug>.md`.
- You stop at the boundary your brief defines.
- You hand off via a README in `handoffs/`.
- The auditor runs after you — they verify against the spec invariants, you don't self-grade.

**If your step's scope feels too small:** good. That's the design. Pat ratified the daisy-chain.
**If your step's scope feels too big:** that means the brief is wrong. Surface it in your handoff and stop early at a coherent state. Don't guess your way past the seam.

---

## 2. The six domain invariants (verbatim from spec §wrapper "Domain Invariants")

These are the project's canon. Any build, edit, or "improvement" that violates one is wrong by definition, even if it seems like a better game:

1. **No enemy HP. No player kill-path.** Sirens are never defeatable. Tools disrupt; they never deal lethal damage. A build that adds a Siren health bar has failed the brief.
2. **Suspicion is the spine.** Threat escalation runs through the suspicion meter and its four states — not through scripted aggression or RNG.
3. **Perceiving costs.** Every way of seeing carries a suspicion or scarcity cost. Nothing reveals the world for free except passive sonar.
4. **Tools buy time and cost heat.** No tool is consequence-free.
5. **Fairness valve is mandatory.** Suspicion decays; instakill only on sustained max with a warning window. One mistake must never be an un-survivable instant restart.
6. **Function before form.** No art, sound, palette, or UI-chrome work until the systems are built and tuned. Form is always a later, separate pass.

If you find yourself implementing something that contradicts one of these — stop. Re-read §10 (fairness principles) and your step brief. The invariant wins.

---

## 3. Creative license — boundary

Pat said implementation is Cowork's call. The spec is design canon, not code spec. So:

- **Implementation choice = your call.** Data structures, helper functions, draw order, vector math style, how you store positions, how you render terrain, sub-state machines vs. flag fields. Pick what reaches a playable build fastest. Don't over-engineer; don't gold-plate.
- **Game design = spec's call.** Tunable defaults, suspicion thresholds, photo objectives, Siren type behaviors, the four perception modes, the win/lose conditions. These are not yours to "improve" mid-step. If you see a better number, that's a tuning question — log it in the handoff, don't bake it.
- **See a better design decision?** Write it in the handoff as a flagged note. Do NOT implement it. The auditor will read it, Pat will rule on it. Drift = handoff note, not handoff code.

The rule of thumb: *if you found yourself defending a code change as a "design improvement," stop and write it down instead.*

---

## 4. Read-before-write checklist

In this exact order. Don't skip.

1. **`SIRENS_SONG_SPEC.md`** — full spec, every section. The §11 build-leash is your scope; §1–10 is the game you're building toward; the wrapper is the governance.
2. **`briefs/NN_<your step>.md`** — your specific assignment, scope boundary, the §11 quote you're working under, the audit gates the auditor will check.
3. **Previous step's handoff README** at `handoffs/NN-1_<previous slug>.md`. This is the state you're inheriting. If your step is step 1, no previous handoff — use the spec instead.
4. **Previous step's audit at `audits/NN-1_AUDIT_STEP_NN-1.md`.** This tells you whether the previous step passed clean or had findings. If findings landed and were fixed, you're inheriting the fixed state. If GREENLIGHT, the handoff is your truth.
5. **Current code at `code/sirens_song.html`** (or whatever the previous step named it — handoff README tells you). If this is step 1, no current code — you're creating it.

If any of these are missing when they shouldn't be (e.g., you're step 3 and step 2's handoff doesn't exist) — STOP. Write a `handoffs/NN_BLOCKED_<slug>.md` and explain. Don't fabricate state.

---

## 5. Write checklist

Your output is two artifacts:

### 5.1 Code increment

- **Single file.** HTML + JS + Canvas, all in `code/sirens_song.html`. The spec's wrapper says Cowork picks the stack; the orchestrator picked single-file because it survives substrate transitions and Pat can open it in any browser to playtest. Don't split files.
- **Syntax must be valid.** Open the file in a real parser (Node can do this, see §6) before declaring done. A syntax error breaks the next agent.
- **No fabrications.** If a tuning number isn't in the spec, use a comment marker like `// TUNING(default per spec §11)` and use the spec default. If you can't find a default, the value goes in a `// TODO(pat): <reason>` block and you note it in the handoff.
- **No scope creep.** Your step is your step. If you find yourself implementing something that belongs to step N+1 because "it's right there," stop. Note it in the handoff for the next agent.
- **Comment the invariants you're touching.** Where suspicion math lands, comment which invariant it serves. Where a Siren AI state transition lands, comment which invariant constrains it. This makes the audit cheap.

### 5.2 Handoff README

Lands at `handoffs/NN_<your slug>.md`. Required fields:

```
# Step NN handoff — <slug>

## What I built
- <bullet list of every system/feature added this step>

## State of the file
- File: code/sirens_song.html
- Lines added: ~<n>
- Lines modified: <n>
- Lines removed: <n>

## Spec sections implemented
- §X.Y — <how>
- §X.Z — <how>

## Tuning values used (with spec citation)
- <name>: <value> — spec §X.Y
- <name>: <value> — DEFAULT per spec §11
- <name>: <value> — TODO(pat), no spec default found

## Sim tests run (if any)
- Test: <what it checks>
- Result: <pass/fail/output>

## Open potholes for the next step
- <thing the next agent needs to know>

## Design improvement notes (NOT implemented, for Pat)
- <thing I would have changed but didn't, with reasoning>

## Invariant adherence (self-check, auditor verifies)
- 1. No enemy HP / no player kill-path: <how I held this>
- 2. Suspicion is the spine: <how I held this>
- 3. Perceiving costs: <how I held this>
- 4. Tools buy time and cost heat: <how I held this>
- 5. Fairness valve: <how I held this OR n/a for this step>
- 6. Function before form: <how I held this>

## Receipt
- Step NN: COMPLETE / BLOCKED / PARTIAL
- Files written: <list>
- Ready for: audits/NN_AUDIT_STEP_NN.md
```

End your turn with this receipt. The receipt is the seam — orchestrator reads it to know whether to fire the audit or surface a block.

---

## 6. Sim-test capability — use it

**Node.js is available in the sandbox.** You can extract JS logic from the HTML and run it headlessly to verify behavior before claiming completion. This is encouraged.

Examples of useful sim tests by step:

- **Step 1 (movement / sonar):** simulate the sub at position P with heading H and velocity V for T seconds; assert it moves where you expect. Verify oxygen drain rate produces depletion at the spec-defined run length. Verify hull collision is detected when sub overlaps terrain.
- **Step 2 (suspicion / Patroller):** drive the suspicion math with a script of actions (ping, decay, ping, decay…) and verify the threshold transitions fire at 33/74/99 and instakill triggers at sustained 100 for ≥4s. Verify Patroller's loop returns to start over a full cycle.
- **Step 3 (drones / objectives):** simulate drone deploy/move/photograph; verify suspicion +15 lands; verify "all required photos captured AND sub reaches extraction" = win.
- **Step 4 (Sentinel / Hunter / curiosity):** verify Sentinel orbit stays within radius; verify Hunter is dormant below alert and pursues at alert+; verify Curious-state Sirens move to decoy positions.
- **Step 5 (jamming / EMP / knockdown):** verify EMP halts a Siren for ~5s; verify knockdown immobilizes for ~12s; verify jam reduces detectability for its window.
- **Step 6 (recon):** verify recon reveals a large sector and consumes one of the 2 charges; verify reveal fades after the duration.
- **Step 7 (tuning):** sim-test entire scenarios (clean run, dithering run, aggression run) and verify each terminates as the spec expects (win, oxygen lose, suspicion lose).

**How to run a sim test:**

```bash
# Extract the function(s) you want to test into a separate JS file or inline,
# then run via Node:
node -e "
  function applySuspicion(s, dt, sources) { /* paste your logic */ }
  let s = 0;
  s = applySuspicion(s, 1, ['ping']);  // expect ~25
  console.log('after ping:', s);
"
```

The auditor will also run sim tests. If your step's logic survives sim tests *you* wrote, the auditor's tests are more likely to find nothing.

**Sim tests are not a replacement for the audit.** They are how you build confidence before handing off. Log sim tests you ran in the handoff README §"Sim tests run."

---

## 7. Constraints

- **Function before form** is invariant 6 and load-bearing. Don't add palettes, sprites, fonts, layouts, sound, "feel" polish. Use placeholder shapes (rectangles, circles, plain text labels). The build is a system test, not a visual artifact. Pat will commission form pass after tuning.
- **Single hand-authored site.** No proc-gen. Don't generate the level layout from a seed. Hardcode the play area, the factory location, the terrain features, the objective positions, the patrol routes. This is the spec's intent in §11.
- **No menus beyond start/restart.** No settings screens. No HUD chrome decisions. If you need a HUD readout for testing (suspicion number, oxygen %), it's plain text in a corner; the form pass will replace it.
- **No scope creep.** Repeated for emphasis. The daisy-chain depends on each agent staying inside its lane.

---

## 8. Failure modes and what to do

| Situation | What to do |
|---|---|
| Spec section is ambiguous | Pick the simpler interpretation, note it in handoff §"Design improvement notes" |
| A spec invariant seems to contradict your step's apparent goal | Stop. Re-read the spec. Invariant wins. If still stuck, write a `handoffs/NN_BLOCKED_<slug>.md` |
| Previous handoff is missing or step's claimed state isn't in the code | Don't fabricate. Block and surface |
| Your code doesn't pass your own sim test | Fix it. Don't hand off broken state |
| You find a bug in the previous step's code | Don't silently fix it (that contaminates the audit trail). Note it in your handoff §"Open potholes" and let the auditor rule whether you should patch it or the previous step's agent needs a fix-pass |
| Audit findings landed on your previous-step predecessor | Read the audit. The fix-pass agent already handled them. You inherit the fixed state from the latest handoff. |
| You realize mid-step the brief asks for the wrong thing | Stop. Write a `handoffs/NN_BLOCKED_<slug>.md` describing what's wrong. Don't push past it |
| You finish your step but the auditor finds an invariant violation | The auditor writes a fix-pass directive. You (or a new agent on this step) re-runs, addresses ONLY the findings, writes a new handoff `handoffs/NN_FIX_PASS_<slug>.md` |

The general principle: **gap-naming is the right answer; fabrication is the wrong answer.** Same rule as CGI §J.4 — don't invent canon, don't invent code state, don't invent spec content.

---

## 9. What you are NOT

- **You are not the orchestrator.** You don't spawn the next agent. Your handoff is the seam; the orchestrator reads it and decides what fires next.
- **You are not the auditor.** You don't grade your own work. Your self-check in §5.2 is for the auditor to verify, not to substitute for an audit.
- **You are not Pat.** You don't ratify design changes. You implement what's spec'd. Improvement notes go in the handoff for Pat to rule on.
- **You are not the next step.** Resist the temptation to "set up" the next step in your code. Set up nothing beyond what your step requires.

---

## 10. Quick reference

- **Spec is law:** `SIRENS_SONG_SPEC.md`
- **Your brief:** `briefs/NN_<slug>.md`
- **Previous handoff:** `handoffs/NN-1_<previous slug>.md`
- **Previous audit:** `audits/NN-1_AUDIT_STEP_NN-1.md`
- **Current code:** `code/sirens_song.html`
- **Your output:** code update + `handoffs/NN_<slug>.md`
- **Stop when:** your step's scope is complete OR you're blocked

---

*AI-DESIGNED. Operating doc for daisy-chain step-agents. Authority: SIRENS_SONG_SPEC.md > this file > step brief.*
