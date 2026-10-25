# Siren's Song — Project Ledger

**Version:** 0.1 | **Established:** 2026-10-24 (America/New_York)  
**Scope:** Siren's Song design, source authority, Gauntlet orchestration, implementation, testing, assets, and release preparation.  
**Synchronization:** Local handoff file created. GitHub root and ChatGPT Library mirrors **pending**; neither has been modified by this ledger creation.

## Operating contract

This ledger is the **navigation, provenance, current-state and chronological change-history authority**. It routes readers to the governing design bible, Pat's explicit directives, selected art, repository source and test evidence. Those primary sources retain authority in their domains. It does not replace them.

Update the ledger **in the same work unit** when a Markdown/specification/artifact is created, changed, moved, archived or superseded; a game build or asset changes; a test or device review completes; a PR is opened/merged; orchestration ownership or branch rules change; or a discussion produces a durable decision. If persistence is unavailable, publish a dated ledger delta with **sync pending** rather than claiming a persistent update.

Each event must record the date (and time only if supported), workstream, type, authority and origin, decision/change, affected paths and versions/PRs/commits, status, supporting evidence, supersession links, and next step. Maintain status distinctions: **proposed / approved / implemented / tested / rejected / superseded / disputed**. An approved direction is not an implemented feature; a green test is not a physical Android playthrough.

The chronological event history is **append-only**. Preserve mistaken or obsolete claims, then record corrections or supersessions with cross-references. Update the current-state register in place while retaining earlier snapshots through event IDs. When backfilling history, distinguish the event's original date, the source's evidence date, and the date the ledger recorded it. Never infer an event time from an upload or Git commit date without evidence.

For any **status update**, read this ledger first, then verify the relevant linked source and live repository state. State the window covered and label findings source-verified, repository-reported, user-reported or unresolved. Link new artifacts, PRs and commits back to event IDs when practical.

**Canonical target:** repository root `PROJECT_LEDGER.md` at `pemunson90-cmd/Siren-s-Song`. **Mirror target:** ChatGPT Library `/Siren's Song/PROJECT_LEDGER.md` (verify/create exact path). Confirm each synchronization independently. Existing `Siren's Song.md` is an experiential project journal, complementary to this operational ledger.

## Current-state register — evidence through 2026-10-23; recorded 2026-10-24

| Workstream | Current state | Source / locator | Verification and next action |
|---|---|---|---|
| Creative authority | Design Bible v1.0 dated Oct 18; explicit later Pat directions override conflicting prior material | `SIRENS_SONG_DESIGN_BIBLE_GAUNTLET_V1.md`; dated directives | Uploaded copy inspected; verify any later repository amendment |
| Core identity | 2D top-down submarine stealth and tactical drone command aboard USS Quietus; superior Sirens, costly information and photographic reconstruction/reconnaissance | Design Bible §§2–7; Oct 21 photo-first directive | Vision approved/reaffirmed; campaign-wide execution not fully verified |
| Story | Human drilling/oil and military sites endangered by their own activities and superior alien Sirens; false human fleet/Siren evacuation premise rejected | Oct 21 project journal, Pat's directives | Rewrite/integration/approval remains to be checked |
| Visual design | Factory-channel C01/C02 highly promising; Quietus exterior provisional; sleek manta/stingray and pointed serpentine Siren shapes requested | `SIRENS_SONG_VISUAL_EXPLORATION_PLAN_V3_HANDOFF.md`; selection ledger | No final art lock established |
| Gauntlet orchestration | Claude root on `claude/integration`; Codex bounded work on `codex/handoffs`; Pat controls promotion to production/main; Windows desktop handoff dated Oct 23 | `docs/RESUME.md`, `docs/DESKTOP_HANDOFF.md`, `docs/codex/BOARD.md` | Last journal snapshot, not verified against live branches today |
| Game implementation | Reported 30 operations, 12 challenges, PHOTO1/PHOTO2, photo discoveries, equipment and progression; partial photography identity drift remains an area of work | Oct 22–23 source/audit journal | Revalidate live HEAD and playable coverage |
| Automated validation | Oct 22 pinned Godot 4.6.3 suite 817/0; Oct 23 earlier integration snapshot 818/0 and 33 targeted suites | Dated repo audit and cold review | Snapshot-specific; no end-to-end Android signoff implied |
| User experience | Touch navigation, menu reach, Back behavior, save slots/replay, photography feedback and finale are active review concerns | Oct 23 cold review | Source/automated reviews distinct from device acceptance |
| Repo audit | External read-only audit and stale-guidance/archive inventory performed; cleanup and full reconciliation incomplete in reported checkpoints | Oct 19/22 journal; audit reports | Check current status independently |
| Ledger | v0.1 local first draft | This file, E-20261024-001 | GitHub and Library sync pending |

## Source routing and recovery order

1. This ledger; then current `claude/integration/docs/RESUME.md` for live orchestration context.
2. `docs/DESKTOP_HANDOFF.md` and `codex/handoffs/docs/codex/BOARD.md` for assigned lane and local-PC transition; inspect actual branches, PRs and checks before reporting their current status.
3. Current direct Pat directives and `SIRENS_SONG_DESIGN_BIBLE_GAUNTLET_V1.md` for creative authority. Check subsequent amendments and decisions.
4. `SIRENS_SONG_VISUAL_EXPLORATION_PLAN_V3_HANDOFF.md`, selection ledger and curated visuals for art provenance.
5. Game source, tests, replay/device evidence, commits and PRs for implementation claims.
6. ChatGPT Library `Siren's Song.md` for the dated development journal; recovery archive and historical audit files for earlier provenance.

## Chronological events

### 2026-10-24

#### E-20261024-001 — Operational project ledger initialized
- **Workstream:** Cross-project governance
- **Type:** Workflow decision / artifact
- **Event / recorded date:** 2026-10-24
- **Origin:** Pat's request to adapt the PNB 2026 Nova Mobiles project-ledger workflow; retrieved Library `PROJECT_LEDGER.md` v0.8 operating contract.
- **Change:** Established this navigation and history ledger, current-state register, source routing, open work register and retrospective dated event index.
- **Artifact:** `SIRENS_SONG_PROJECT_LEDGER.md` local handoff; target repo root `PROJECT_LEDGER.md`.
- **Status:** Implemented as local file; persistent GitHub/Library sync **pending**.
- **Next:** Publish and wire into repo entrypoints, then reconcile live branch/current PR evidence.

### 2026-10-23 (retrospective entries, recorded 2026-10-24)

#### E-20261023-001 — Cloud-to-desktop Gauntlet handoff
- **Workstream:** Orchestration / repository
- **Type:** Handoff / operational change
- **Origin:** Dated Siren's Song Library journal based on Oct 23 repo reads
- **Change:** Pat moved development to Windows PC. Claude handles integration; Codex handles bounded lanes; production/main remain gated for Pat. Portable archive reportedly retained 551 evidence files.
- **Affected:** `docs/RESUME.md`, `docs/DESKTOP_HANDOFF.md`, `docs/codex/BOARD.md`; `archive/cloud-desktop-20261023`.
- **Status:** Reported and journal-source supported; today's live branch state unverified.
- **Next:** Verify active PRs/owner assignments and current HEADs.

#### E-20261023-002 — Cold-review experience gaps and approved directions
- **Workstream:** Gameplay / UX / QA
- **Type:** Review and design decisions
- **Origin:** Oct 23 journal / Pat approvals
- **Change:** Back handling, save slot/replay fork, menu reach and three early earned modules approved for work. Photo acquisition, operation-30 ending, navigation and narrative presentation remain review concerns. Siren senses/lock timing require Pat's explicit decision before changes.
- **Status:** Approval/review; do not infer merged fixes or device testing.
- **Next:** Check ticket/PR implementation evidence; perform real-device acceptance.

### 2026-10-22 (retrospective)

#### E-20261022-001 — Photographic recon integration audit
- **Workstream:** Photography / source audit
- **Type:** Snapshot verification / bug report
- **Origin:** Dated read-only repository audit summarized in Library project journal
- **Change:** Recorded 30 operations, 12 challenges and PHOTO1/PHOTO2 systems. Identified reproducible study-ID, hidden-object preview, route disclosure, handler precedence and camera flash problems. Nine operations had authored photographic subjects in the inspected scope.
- **Affected:** `claude/integration` snapshot `07eb890`, `docs/RESUME.md`, Codex board.
- **Status:** Source-audited at historical snapshot; correction state requires fresh inspection.
- **Next:** Verify bug fixes and photo-first campaign coverage.

### 2026-10-21 (retrospective)

#### E-20261021-001 — Reconnaissance primacy and narrative correction
- **Workstream:** Creative authority / campaign
- **Type:** Ratified designer directive / rejection
- **Origin:** Pat's project conversation, journal checkpoint
- **Change:** Photography/evidence acquisition is the primary game purpose, with rescue secondary. Rejected invented fleeing human fleet and Siren evacuation; human personnel at drilling/oil and military installations are endangered by Siren reaction to perceived threats.
- **Status:** Approved creative ruling; complete implementation not established.
- **Supersedes:** Conflicting AI-introduced human-fleet/evacuation plot.
- **Next:** Audit missions, objectives and endings against this authority.

#### E-20261021-002 — Orchestrator transition and lethal Siren beam
- **Workstream:** Gauntlet / enemy systems
- **Type:** Handoff / implementation report
- **Origin:** Oct 21 dated journal checkpoint
- **Change:** Claude took root coordination with bounded Codex assignments. PR #64 reportedly merged one-hit Siren beam and collision effects; historical handoff reports 30 authored operations and eight enemy roles.
- **Status:** Historical reported merge; production promotion and device acceptance unverified.
- **Next:** Inspect integration and current enemy tests.

### 2026-10-20 (retrospective)

#### E-20261020-001 — Gauntlet progress and quality gates
- **Workstream:** Campaign / orchestration
- **Type:** Development checkpoint / workflow correction
- **Origin:** Oct 20 Library journal
- **Change:** PRs #39–#50 reportedly merged, approximately 30 operations reached. Pat directed substantial integrated improvements with independent critique and periodic larger regression checks, replacing excess micro-certification friction. Claude handoff reported PR #51 checkpoint `ca4735e`.
- **Status:** Historical reported milestones; specific branch promotion remains separate.
- **Next:** Audit substantive game experience against implemented breadth.

### 2026-10-19 (retrospective)

#### E-20261019-001 — V7 recovery, Gauntlet continuity and read-only audit
- **Workstream:** Prototype / agent workflow / audit
- **Type:** Recovery and governance
- **Origin:** Oct 19 Library journal
- **Change:** Recovered original V7 handoff; Android reports and deterministic tests tracked. Pat directed continuous branch-based production/reviewer integration and bounded independent read-only audit. Historical obsolete-evidence inventory found 2,491 objects, with deletion deferred.
- **Status:** Recovery and inventory reported; final acceptance and cleanup unresolved.
- **Next:** Preserve audit provenance and avoid interrupting live production workers.

### 2026-10-18 (retrospective)

#### E-20261018-001 — Design Bible, visual selections and autonomy brief
- **Workstream:** Creative design / art / orchestration
- **Type:** Source synthesis / designer feedback
- **Origin:** Uploaded Design Bible v1.0 and Oct 18 journal
- **Change:** Consolidated prior prototype/spec provenance for Android top-down tactical submarine stealth and drone command. C01/C02 selected as promising visual candidates, Quietus exterior provisional; Sirens directed toward sleek angular manta/stingray and serpentine forms.
- **Affected:** Design Bible v1.0, visual exploration plan v3, concept-selection ledger.
- **Status:** Bible authored; visual candidates provisional.
- **Next:** Check current reference package and asset adoption in working game.

## Open reconciliation queue

| ID | Priority | Task | Status |
|---|---|---|---|
| Q-001 | High | Publish this ledger as repository-root `PROJECT_LEDGER.md` and Library mirror; verify both writes | Pending |
| Q-002 | High | Add ledger-first instruction to `AGENTS.md` and `docs/RESUME.md` without disrupting existing Gauntlet procedures | Pending |
| Q-003 | High | Read live Claude/Codex branch heads, board, PRs and CI; replace historical snapshots with current sourced states | Pending |
| Q-004 | High | Verify photo-first design is expressed across mission objectives, risk, evidence and outcomes | Pending |
| Q-005 | High | Reconcile Oct 22 camera/study defects with merged implementations and regression coverage | Pending |
| Q-006 | High | Track native Android phone playthrough, audio/readability and save/replay acceptance separately | Pending |
| Q-007 | Medium | Backfill early prototype and pre-Oct 18 history from original provenance and actual Git history | Pending |
| Q-008 | Medium | Link selected concept art assets and versions; mark candidates versus accepted assets precisely | Pending |
| Q-009 | Medium | Reconcile historic external audit and archive/cleanup state without affecting development work | Pending |

## Entry template

```md
#### E-YYYYMMDD-NNN — Concise title
- **Workstream:**
- **Type:** Decision / proposal / source change / build / test / merge / rejection / supersession / correction
- **Event date / evidence date / recorded date:**
- **Origin / authority:** Pat / canonical spec / repository source / tested build / archive / assistant proposal
- **Change:**
- **Affected artifacts, versions, commits, PRs:**
- **Status:** Proposed / approved / implemented / tested / rejected / superseded / disputed
- **Supersedes / superseded by:**
- **Evidence / validation:**
- **Next:**
```