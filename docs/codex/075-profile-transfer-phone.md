# Handoff 075: Profile export and import that works on a real phone (system file dialog or share path)

Status: CLAIMED
Claimed at: 2026-10-28 09:43:24 UTC
Claimed by: codex-root (transferred from claude 28 Oct 2026 10:20 ET)
Finished at:

Precondition: none beyond ORCHESTRATION. Scout note: Verify the DisplayServer dialog API on Android in 4.6.3 in the first 20 minutes. If unavailable, ship the Downloads fallback only. No APK or phone test is allowed, so the code path must be capability-probed and fully faked in tests. Read ORCHESTRATION_2026-10-26.md first.
Codex may merge: yes, into claude/integration only, on green guidance + game-smoke for the exact head, merge commit.

Source: Claude gap scout 27 Oct (four scanners, two adversarial verifiers per gap, completeness critic). AI-DESIGNED scope; owner may adjust.

## Task (plain language)
Make export and import usable on Android without a computer. First confirm on the 4.6.3 toolchain whether DisplayServer.file_dialog_show (native save and open dialogs) works on Android. If it does, EXPORT opens the system save dialog (suggested name from the slot, never the profile name), and IMPORT opens the system open dialog filtered to .qprofile. If it does not, fall back to a copy of the package into the Downloads folder via OS.get_system_dir plus a plain notice of where it went.
Keep the current user://profiles list as the desktop and fallback path. Reuse the existing bounded envelope, checksum and validators; no format change. Cancel in the dialog must be a no-op with a plain notice. Android Back keeps dismissing the picker layers first.
Report the truthful limit when neither route is available instead of showing a path the player cannot reach.

Spec basis: Complete title/menu, Continue/mode selection, profiles, ... and truthful recovery/error flows (Approved full-release expansion). Integrated checkpoint: Three independent profiles support copy/clear/export/import.
Evidence it is missing: persistence/profiles/README.md: 'The fallback file location is the app's user directory, under profiles. Export displays the absolute path; Import provides a touch list of .qprofile files in that folder.' profile_picker.gd line 33 shows 'EXPORTED TO <path>' and line 54 tells the player 'Place a .qprofile export in: <globalized user path>'. On Android that folder is app-private storage, so a phone player cannot copy the file out, move it to another device, or place a file in to import. git grep for file_dialog, get_system_dir and share finds nothing in game/src. The README itself notes that Android filesystem sharing is not claimed.

## Base and branch
Base: origin/claude/integration (fetch fresh). Create branch: claude/lane-profile-transfer

## Files you may edit
persistence/profiles/profile_picker.gd, profile_store.gd (a destination and source callback only), new persistence/profiles/profile_transfer.gd, README.md in the same folder; tests beside the feature.

## Files you must not touch
Cloud sync, accounts, new save formats, any change to SAVE2 sidecar semantics. Lock, beam, collision, damage, hull rules, Siren senses, photography design. Files owned by any other CLAIMED handoff.

## Checks
Fake dialog callbacks for save, open, cancel and error. Import through the callback rejects a corrupt or oversized file with the existing messages. The existing profile tests and the 150 percent text touch tests still pass. Never more than ORCHESTRATION section 5 requires. Suite ranks: Codex local 300-349 / CI 400-449 next free.

## Return
PR into claude/integration; merge on green; close per ORCHESTRATION section 7.

## Completion
(five lines max)

## Claude claim (28 Oct)
Claude builds this on `claude/c19-profile-transfer`. Codex: skip it.

## Ownership transfer (28 Oct 2026 10:20 ET, Claude)
Pat's 28 Oct efficiency baseline: Claude runs no subagents; Codex executes. Codex root owns PR176 from here (independent review, commit, CI, merge, closeout). The Claude worktree for this lane is idle; use your own worktree. Claude's lane report findings are in the PR body and the lane notes on this file.
