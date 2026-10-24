# 027 implementation plan

Claim: codex/handoffs 9aa1409. Base: aaff40e. Branch: claude/ending-m3b.

1. Add catalog registrations and two separate encounter layouts for 30 and 31.
   Require recovery of 25, then 30. Use ordinary optical objectives, existing
   enemy types and depth bands. Core photos require no fitting or grade gate;
   optional closer frames spend the same finite film. Existing tables stay intact.
2. Add a photo ending selector derived from existing campaign facts, recovered
   photo intel and archive frames. Keep the original four ending conditions.
   Select the best usable shot per subject, annotate only with recorded finding
   names, and reuse PhotoView.Plate. Show the old ending until both missions finish.
3. Add a small wall presenter with campaign/back/archive controls and the two
   narrow campaign hooks. A data switch disables the derived wall behavior.
   Retain catalog identities when switched off so existing saves remain valid.
   No new save fields or story text. Keep old ending presentation reachable.
4. Start with failing contract tests. Verify both bare missions with ordinary
   movement/photo/recovery commands, saved snapshots, all four ending branches,
   missing film, best-shot ordering, optional failed frames, off switch and old
   saves. Check real wall rendering and touch layouts in cover and inner shapes.
5. Run import, core and affected suites only. Preserve generated import/uid noise
   outside commits. Independent review, then exact-head GitHub guidance and
   game-smoke. Reconcile current integration before merging with a merge commit.
   Mark done027 and update the shared board together after publication.

Do not change simulation rules, old operation tables, story or art direction.
Commit/push useful WIP within 30 minutes. Next handoffs remain numeric order.
