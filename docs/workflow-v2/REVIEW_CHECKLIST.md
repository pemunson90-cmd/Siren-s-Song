# Reviewer checklist (prompts/review.txt) and intent check

One reviewer per PR, on the frozen head, from the other provider when both are up. The verdict is one PR comment of at most 10 lines ending `REVIEW: APPROVE <tree>` or `REVIEW: CHANGES <reasons>`. The reviewer does not re-run voyages or re-measure; it reads the diff, the capped evidence and runs the acceptance test once.

## Checklist (every line answered yes or the verdict is CHANGES)

1. The diff touches only the item's `Files` and `Areas`. No serial zone outside the item.
2. The acceptance test named in the item exists, fails on the base, passes on the head (the reviewer runs it once).
3. No test skipped, loosened, deleted or timed out longer. An updated expectation cites a `RULING:` line.
4. Protected constants unchanged (`protected_rules_tests.gd` green) unless the item class is `protected` and the ruling line is in the PR body verbatim.
5. Release controls intact: `release_controls_tests.gd` green; no new `_order("route"...)` outside `TRAVEL_SHORTCUTS`.
6. Evidence matches the class cap in size and kind; nothing missing, nothing extra.
7. Strings: no em dashes; story text 1 to 2 lines; player-facing text truthful about what the action does.
8. Save fields optional and validated; old saves load (persistence tests green) when any save key changed.
9. Nothing is claimed that was not run: a line that says "identical physics" is backed by the voyage hash line.
10. The PR body is under the cap and says what the player gets in its first line.

## Intent check (orchestrator, 5 lines)

Reads the first line of the body, the acceptance test result, the evidence and the reviewer verdict. Asks one question: does this give the player what the item promised without breaking a ruling? Posts `INTENT: PASS` or `INTENT: HOLD <one reason the builder can act on>`. A HOLD names the missing evidence or the ruling it fails; it never asks for more tables than the class cap.
