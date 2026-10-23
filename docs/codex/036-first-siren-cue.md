# Handoff 036: FIRST-SIREN CUE (Pat approved 23 Oct, decision D1)

Status: CLAIMED
Claimed at: 2026-10-23 19:21:32 UTC
Claimed by: codex
Finished at:

Codex may merge: yes, into claude/integration only, after GitHub guidance and game-smoke are both green on the exact head and the PR is mergeable. Merge with a merge commit, then mark DONE and update docs/codex/BOARD.md.
Testing: import, core tests (CHECKS N FAILURES 0), and only the tests for what you touched. No full scenario list locally. Never skip, loosen or delete a test.
Standing rules: PLAN_SNAPSHOT.md and the top of docs/USER_DIRECTIVES.md on claude/integration (see the 23 Oct entry D1 to D5). Touch-first (48 dp, Android Back), modular: one self-contained module, one narrow seam, numbers and the on/off switch in a data table, optional validated save fields, a revert note in the module header. Push WIP every 30 minutes. No em dashes.
Precondition: 035 DONE or at least its PR open (both touch warning UI; avoid overlap).

## Task (plain language)
Full cold review: in op 3 an unseen patrol locked onto a craft from beside the relay and the player had about 4 s to react; the lock banner was the first sign of danger. Add a cue BEFORE the first lock in ops 1 to 3 only: when a Siren first notices any of the player's craft (the same internal moment the existing code uses to start investigating or to start the lock), show a short warning mark with the bearing toward it and play a soft distinct warning sound, once per Siren per dive. Use existing signals only.
Hard limits: do NOT change Siren sight or hearing ranges, detection rules, lock duration (4 s), the beam, collision or damage. The cue is presentation of an existing event; it must not make the Siren notice sooner or later. The 035 and FIX1 warning pause behavior stays as is. Ops 4 and later: switch off in the table, behavior identical to today.
Module: game/src/presentation/first_siren_cue/ (name your choice) with data table (ops enabled, cue duration, audio id) and an enabled flag. Tests: cue fires once per Siren in ops 1 to 3, does not fire in op 4+, does not alter the simulation state hash across a scripted dive (cue on vs off give identical sim state), real-touch visible at both Fold7 shapes, audio event logged.

## Base and branch
Base: origin/claude/integration. Branch: claude/first-siren-cue

## Completion

Claimed while final019 PR92 runs its own gate. All remaining019 PRs are now open in order;036 preparation is isolated from photo orders. Merge92 before036, then reconcile actual newest integration into036 and obtain exact-head review/CI.035 is DONE, so this handoff's precondition is met. Approved D1 supplies the design; no new rule, story or pillar decision is needed.

WIP pushed branch claude/first-siren-cue at0c3be16a2272e4f48d8393eb5a6370a4ddf7a28a. Draft PR93 https://github.com/pemunson90-cmd/Siren-s-Song/pull/93, base actual integration70b1f18. Photo PR92 remains first to merge; reconcile that actual merge before036 final review/CI/merge. New observer signal publishes the existing heard/detected branch before lock increment; no rules, contacts, sonar, save fields or simulation event rows change. Presentation tracker/table/overlay/audio live in first_siren_cue; one main registration. Settings Table.enabled, OPERATIONS1/2/3,DURATION2.5,AUDIO alert -18dB/.65pitch/.18s and layout table. Approved D1 is the design; implementation checklist lives docs/superpowers/plans/2026-10-23-first-siren-cue.md. Inline execution and existing handoff ledger avoid extra governance tooling.

Functional32/0, actual Canvas/injected-touch Fold7 cover/inner34/0. Checks cover hearing/visual pre-lock timing, per-Siren dedup/reset/expiry/filter/off, paired simulation snapshot hashes, audio event, visible/text bounds, real touch pause/AndroidBack, active lifecycle freeze and mute. Screenshots inspected at /workspace/ss-cue-evidence/cue-2520.png andcue-2184.png. Import clean; existing pause15/0,lock27/0,lockUI14/0,FIX2feedback12/0,photoaudio47/0. Core running; independent review pending. Initial functional test callback retained its Sim; explicit disconnect removed the cycle and clean exit was verified. Lifecycle trace showed Godot playing=false when paused, so tests assert playback before suspension then paused, and trigger a fresh cue before touch pause; no tests removed/loosened. Story/combat/senses unchanged. No APK/device/headphone/fullcampaign claim.

Review/fix checkpoint: initial0c3be16 was NOT approved. Independent /root/review_integration found Important same-dive reload repeats, environmental FACTORY RESPONSE consuming craft notice, direct Soundscape suspension missing HUD voice; Minor unlabeled reference craft. All three Important findings reproduced RED before fixes. Current branch claude/first-siren-cue last pushed23dc1972f177b93ce6641d34b5d8f23c997278fa, PR93 still DRAFT. Optional validated first_siren_seen lives in archive only, no Sim fields; existing winner provenance identifies own propulsion/craft emissions without changing hearing selection/math; sound now belongs under Soundscape; mark explicitly says FROM Q/A/B. Ruling: ambiguous reference was consequential fair-information feedback, fixed within D1; cost is one short reference label.

Fixed-source import/core818/0, functional37/0, actualCanvas50/0, pause15/lock27/lockUI14/FIX2feedback12/photoaudio47/FIX2save12/optionalrecovery20 all0. Logs clean of errors/leaks. Environmental fixture now checks its real hearing attention timer plus unchanged seen-empty assertion because at the noise itself AI legitimately changes INVESTIGATE to SEARCH; no AI behavior altered. New screenshots inspected. Final preparation re-review requested on23dc197. Exact final CI and actual-photo merge reconciliation still required; merge92 first.036 remains CLAIMED.

Independent re-review /root/review_integration APPROVE preparation23dc197 againstactual70b1f18 with no outstanding Critical/Important/Minor. Prior findings resolved; inspected immutable source/tests/archive validation/lifecycle/diff, no runtime rerun. No new rules introduced by acquisition sidecar. Relayed verdict in PR93 body/comment. Physical/headphone/enjoyment/fullcampaign/hostedCI unjudged. Still reconcile actual92 merge then final review/CI before93 merge.
