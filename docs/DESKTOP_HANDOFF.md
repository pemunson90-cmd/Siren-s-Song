# Cloud to Windows desktop handover

Pat's latest order, 23 October 2026 Eastern: finish PR96 only, save the remaining
steps, update stale documentation, leave notes for Pat/future Codex/Claude Code,
then stop. PR96 has landed; this document closes the requested cloud handover.
No further game implementation is authorized in this cloud session.

## Notes for Pat

The game and prepared work are saved on GitHub. A fresh desktop session does not
need the cloud conversation or its absolute folders. Current source/stop state:
[RESUME](RESUME.md). The unfinished assignment stays claimed so nobody repeats it.

The desktop is Windows. The existing automation uses Linux tools, so use WSL2
Ubuntu for development. You can separately open `game/project.godot` with native
Windows Godot 4.6.3 and run the project for optional desktop play. No Android
package, phone test or production/main promotion is part of this move.

Give a future assistant this starting instruction:

> Read docs/USER_DIRECTIVES.md, docs/RESUME.md and docs/DESKTOP_HANDOFF.md from
> freshly fetched claude/integration. Check the live PRs and codex/handoffs board.
> Explain the saved state and prepare Windows/WSL. Do not start implementation
> until I say continue. Preserve all branches, existing saves and the signing key.

When you want Codex to continue, explicitly ask it to resume claimed handoff 023
from its Completion notes. You do not need to choose another task or re-approve
ordinary implementation decisions.

## Source and last cloud actions

| Item | Published recovery location |
|---|---|
| Campaign-flow extraction | PR96, branch `claude/lane-arch2-campaign-flow`, head `3afb12f966efc2646c9b148ddf7de5aafe68c5c5` |
| Verified PR96 merge | `dcf81b542bc5a4d27774deb271c9c98a0235e8e7`; exact reviewed tree and both expected parents verified |
| Prepared photo-review extraction | `claude/lane-arch2-photo-review`, head `52ba7d502b3e449180a4883eb570a2c80a9b94f5`, no PR and not merged |
| Claim/progress/next commands | `codex/handoffs:docs/codex/023-arch2-main-and-hud.md` plus BOARD.md |
| This documentation work | `claude/desktop-handoff-20261023`, docs-only followup after PR96 |
| Portable evidence | `archive/cloud-desktop-20261023`, commit `5407a241c9993b2c2e03fdfd83d03e334bc23368` |

PR96 moves nineteen campaign/menu functions to
`game/src/presentation/flow/campaign_flow.gd`; Main keeps its existing entry
signatures, state and host-bound callbacks as one-line forwarders. Main shrinks
1,106 to 950 lines. Independent review approved exact 3afb12f with no findings and
reconstructed the complete old Main byte for byte. Before/after core 818,
runtime 665 including campaign UI, campaign dispatch 13, archive recap 8 and actual
Canvas route-map 70 all pass with zero failures and clean exits. Additional
Canvas early-reward 40 and menu 24 also pass. The reviewer independently ran40/0.
Exact hosted run 40043994511 passed both required checks before the verified merge.

The saved photo step moves nine photo/archive helpers,950 to 864 Main lines.
Its original entry points/callbacks stay. One explicit String annotation retains
an original inferred type. Mechanical body/full-Main restoration, clean import,
core 818/runtime 665/dispatch 13/recap 8/capture UI 9/archive-parent 2/Canvas cold-review 218
all pass. No tests, rules, numbers, story, saves or Simulation behavior changed.
This is preparation only: no independent final review, PR or own hosted gate yet.
Its RESUME snapshot predates this final handover and must be reconciled before PR.

No metrics extraction or shared feature-contract implementation was started.
No 025 or later handoff was claimed. The prior019/020/024/035/036/037 and021 are
DONE;023 remains partial. Completed history is in the board and merged PRs.

## Notes for the next Codex session

Read the current protocol and Completion on `origin/codex/handoffs`; do not
re-claim023, restart its completed campaign step or mark it DONE after one PR.
After Pat says continue:

1. Fetch live refs and PR state. Confirm PR96 and the docs handover landed.
2. Resume the existing photo-review branch52ba7d5. Merge freshly fetched
   claude/integration into it, preserve current guidance/stop history, and update
   its stale prepared RESUME at the normal feature boundary. Do not overwrite
   an existing desktop checkout or discard local edits.
3. Verify body/type parity, import, core and the named affected suites. Obtain
   attributable independent review and open its own PR to claude/integration.
   Require guidance/game-smoke green on its exact current head before merge.
4. Then extract ui_metrics as a separate PR. Inspection note only: asynchronous
   frame/capture methods have Node-owned lifetimes. Preserve that behavior;
   synchronous geometry/serialization helpers provide a smaller extraction.
   No implementation of that choice exists in the saved source.
5. Then implement ARCH_AUDIT_1 step6, one existing presentation feature per PR:
   shared applies(sim), build_panel(hud), draw(view), preserving draw/call order.
   The registry/API is not implemented yet. Read the design on codex/handoffs.
6. Only after all 023 steps land, mark023 DONE and update BOARD in one commit,
   then take eligible025 and the numeric queue. Skip unmet preconditions.

Every merge contains latest integration, has attributable independent review,
passes both hosted checks on the exact head and uses a merge commit. Never
promote main/gauntlet/production, delete branches or build APKs. Keep 48 dp touch
and Android Back. Combat, beam, collision, damage, hull and Siren sight/hearing
remain unchanged without Pat. V7 Sirens have no sonar. No new narrative, art032
or SIREN TELL decisions. Story remains short placeholders; no em dashes.

## Notes for Claude Code

Read latest USER_DIRECTIVES and RESUME first, then this file and the live board.
The cloud stop is deliberate, not usage exhaustion or project completion.
Do not restart a historical lane from LANES or duplicate Codex's claimed 023.
When Pat resumes, coordinate one implementation worker and one independent
integration reviewer; keep other criticism sequential and bounded. Use existing
review/CI boundaries and handoff files, with no new governance framework.
A desktop session starts fresh; cloud agent processes do not transfer.

## Windows/WSL bootstrap for an assistant

The shell block below is Ubuntu Bash, not PowerShell. Keep the checkout inside
WSL's Linux filesystem, such as `~/src/Siren-s-Song`, and run Codex/Claude Code
there or execute repository Bash commands through WSL from the Windows client.
If the desktop client cannot use a WSL workspace, use its WSL CLI instead of
assuming Git Bash can run the Linux Godot binary. Existing Windows checkouts and
saves must be inspected/preserved before creating another checkout.

WSL prerequisites: Git, Python3, Bash/GNU utilities, curl, unzip, JDK 17 and the
Godot runtime libraries. Rendered tests need xvfb, xauth and Mesa/software GL.
The existing installer targets x86_64; check `uname -m` before assuming it works
on Windows ARM. No Android SDK/emulator setup is required for ordinary checks.
Authenticate GitHub locally; do not copy cloud tokens or credential files.

For a new full clone, after local GitHub authentication:

```sh
mkdir -p "$HOME/src"
cd "$HOME/src"
git clone --branch claude/integration https://github.com/pemunson90-cmd/Siren-s-Song.git
cd Siren-s-Song
git fetch origin claude/integration codex/handoffs claude/lane-arch2-photo-review
git status --short
export PATH="$HOME/.cache/sirens-song-toolchain/bin:$PATH"
scripts/toolchain/install-godot.sh
scripts/toolchain/headless.sh --editor --import --quit
scripts/toolchain/headless.sh --script res://tests/run_tests.gd
```

For an existing checkout, fetch and inspect its status instead of cloning over
it, resetting, cleaning or deleting branches. Recreate separate worktrees from
published refs as needed. If not already present, after Pat asks to resume:

```sh
git worktree add --track -b codex/handoffs ../ss-handoffs origin/codex/handoffs
git switch --track origin/claude/lane-arch2-photo-review
python3 scripts/toolchain/gauntlet-boundary.py --boundary resume
```

If those local branches/worktrees already exist, reuse them; do not recreate or
force them. Pat reinstalls hooks between tasks using
`python3 scripts/toolchain/install-gauntlet-hooks.py`; hooks are local, not
transferred by Git. Run the existing boundary helper manually at boundaries
until the desktop hook setup is established. Use core plus affected suites,
never the full local scenario list. See CODEX_ENVIRONMENT.md and TESTING.md.

## Evidence, saves and signing

The archive branch's README gives Git retrieval commands. Its ZIP is 2,648,261 bytes,
with SHA256 `de357d0afa4431c4ef16efe066688c9d6019476a8962aec356de0bb72fc7604e`.
The manifest verifies 551 files: route-map screenshots, local test logs and
parity scripts, M1 pressure pairs/comparisons and 11 local recovery refs. It
includes historical RED probes alongside later passing candidates; use the
handoff's exact final log names. Source code is already on its published refs.

Cloud `/workspace`, `/tmp`, caches, hooks and running agents do not transfer
through Git. The archive replaces that dependency for selected evidence.
Credentials, personal saves, toolchains and APKs are excluded. If personal cloud
progress exists, copy it privately before discarding the cloud environment.
Do not overwrite desktop/phone progress with test fixtures. Godot user data is
normally `%APPDATA%/Godot/app_userdata/Siren's Song` on native Windows and
`~/.local/share/godot/app_userdata/Siren's Song` in Linux/WSL; respect any explicit
XDG or Godot user-data override. Back up existing data before selecting a copy.

The canonical debug signing key is Git-tracked at
`scripts/toolchain/signing/sirens-song-debug.keystore`; never regenerate it.
Physical Fold7 ergonomics, headphone quality, full cold current-campaign play and
enjoyment remain unverified by these scripted results. No phone-test request is
part of this handover. When PR96 and the documentation are published, stop.
