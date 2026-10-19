# Siren's Song — Provenance Archive

This zip is the provenance companion to `sirens_song_handoff.zip`. The handoff zip
holds the deliverable build package (current build, specs, dev notes, v6 anchor,
MANIFEST). This zip holds everything else useful from the chat that the handoff
intentionally left out: the full conversation transcript, the two uploaded
screenshots, and every recoverable earlier artifact that was superseded on disk.

Nothing here overlaps the handoff zip's payload. The handoff zip stays exactly as
delivered; this archive is additive.

## 1. What is in this zip

```
PROVENANCE_README.md                      this file
CHAT_TRANSCRIPT.md                        full verbatim conversation, turns 0-127
screenshots/
  16402.jpg                               ORIGIN image (project inspiration)
  16443.jpg                               menu-overlap bug screenshot
recovered_artifacts/
  DEEP_CONTACT_functional_spec_v0.1.md    first real spec file (overwritten on disk)
  DEEP_CONTACT_wrapper_v0.1.md            first Cowork wrapper (overwritten on disk)
  SIRENS_SONG_functional_spec_v0.2.md     the v0.2 spec (overwritten on disk)
  sirens_song_prototype_v1.html           build snapshot v1
  sirens_song_prototype_v2.html           build snapshot v2
  sirens_song_prototype_v4.html           build snapshot v4
  sirens_song_prototype_v5.html           build snapshot v5
  sirens_song_prototype_v6_initial.html   v6 as first built, pre-audit
```

### Inventory with checksums

| File | Bytes | md5 |
|---|---|---|
| CHAT_TRANSCRIPT.md | 192540 | 8bec199282cbdf4cd28b5aa640f2bd80 |
| screenshots/16402.jpg | 5013161 | d2937b98388b6e258274468404b315d1 |
| screenshots/16443.jpg | 826326 | 85fc91c891f82c4996f2d79c8839cbe7 |
| recovered_artifacts/DEEP_CONTACT_functional_spec_v0.1.md | 9473 | e34ae813f619b44b751167feff26c899 |
| recovered_artifacts/DEEP_CONTACT_wrapper_v0.1.md | 3858 | 2398254cf7b8501bf8716a3615ba342b |
| recovered_artifacts/SIRENS_SONG_functional_spec_v0.2.md | 15288 | a46ee3f69384c7f3e26b49c57a04bfba |
| recovered_artifacts/sirens_song_prototype_v1.html | 19346 | 0d345e0c78c6fe94c08a4520b6e2534d |
| recovered_artifacts/sirens_song_prototype_v2.html | 20383 | 259ad1b881f0589c081ce8bd8b7bf29a |
| recovered_artifacts/sirens_song_prototype_v4.html | 23058 | 118b410a4d69e96484ff5be3844c26d6 |
| recovered_artifacts/sirens_song_prototype_v5.html | 28361 | 1eb4225cda32c5b82ec84e600f980b81 |
| recovered_artifacts/sirens_song_prototype_v6_initial.html | 38791 | 31b7a62586b45048523cafac927f8ad5 |

## 2. Source and the honest caveat

The original session transcript file is not mounted in this environment. It was
reconstructed from two live sources, both ground truth, neither a copy of a
pre-existing transcript file:

- **Turns 0 through 113** were pulled with the chat-read tool (`read_conversation`),
  paging the conversation from the top.
- **Turns 114 through 127** (the menu fix, the resize fix, the handoff packaging,
  and this provenance exchange) were taken from the on-disk session log that this
  environment does keep, at
  `/root/.claude/projects/-home-claude/c1f3a55d-a8ec-558e-b6e5-e4cc940b226d.jsonl`.
  That log records those turns verbatim, so the tail is exact.

What this means for trust: every Human turn and all Assistant prose in
`CHAT_TRANSCRIPT.md` are verbatim. No turn was written from memory. Where the
chat-read tool would have truncated a large code block, I did not paste the short
version; I replaced the body with a marker pointing to the byte-faithful file, so
no code is misrepresented as complete when it is not.

## 3. Recovery policy used for the transcript

- Human turns: verbatim, in full.
- Assistant prose: verbatim, in full, including the em dashes and styling of the
  original messages. (This README is fresh prose and follows Pat's house style;
  the transcript preserves the original text as written.)
- Full-file dumps inside an Assistant turn: replaced with a one-line marker that
  names the file and where it ships byte-faithful. This applies to files that ship
  in `sirens_song_handoff.zip` (the v0.3 spec, dev notes, pressure design, the
  recovered Deep Contact origin spec, the MANIFEST) and to the large build HTML,
  whose byte-faithful copies live either in the handoff zip (v6 anchor, v7 current)
  or in this zip's `recovered_artifacts/` (v1, v2, v4, v5, v6_initial).
- Smaller inline artifacts never saved as files (verbatim edit diffs, the smoke-test
  harness, tuning notes) are kept verbatim in the transcript rather than markered.
- Tool calls are shown as compact operation markers, not full tool I/O.

## 4. The recovered artifacts, and how they relate to the shipped files

The build history was mostly in-place iteration on single files, so superseded
versions were overwritten on disk. Several were still recoverable in full from the
conversation, where they had been posted as complete files. Each HTML build here was
extracted by writing the escaped tool output to a file, de-escaping it mechanically
with Python's `html.unescape`, then confirming the result is a complete document whose
embedded script passes `node --check` with zero leftover or double-escaped entities.
All five HTML builds in this zip pass that check.

Spec and wrapper lineage (the shipped spec in the handoff zip is v0.3):

- `DEEP_CONTACT_functional_spec_v0.1.md` is the first real spec file, created at
  turn 23 under the project's original name, Deep Contact. Overwritten on disk during
  the rename to Siren's Song.
- `DEEP_CONTACT_wrapper_v0.1.md` is the first Cowork Project Instructions wrapper,
  appended at turn 25. Superseded by the wrapper now embedded in the shipped v0.3 spec.
- `SIRENS_SONG_functional_spec_v0.2.md` is the v0.2 spec from turn 31 (the rename
  pivot). Superseded on disk by v0.3.

Build lineage (the shipped builds are v6 anchor and v7 current, both in the handoff zip):

- v1 (turn 33), v2 (turn 37), v4 (turn 41), v5 (turn 49), and v6_initial (turn 55)
  were each posted as complete files and are recovered here in full.
- v3 and the Round-4 ping-occlusion step were produced by edits, not full rewrites,
  so they never existed as standalone files. Their exact changes live as verbatim
  diffs inside `CHAT_TRANSCRIPT.md` (v3 at turn 39, the ping-occlusion fix at turn 43).
- `v6_initial` is v6 as first built. The v6 that ships as the handoff anchor
  (`history/sirens_song_prototype.html`) is the later, post-audit evolved v6. They are
  different; both are preserved (initial here, evolved in the handoff).
- v7 (the current build) ships in the handoff zip and is not duplicated here.

One correction to the handoff MANIFEST worth flagging: the MANIFEST lists the headless
smoke-test scripts as ephemeral and unrecoverable. The smoke-test harness is in fact
preserved verbatim in `CHAT_TRANSCRIPT.md` at turn 84, the exact script, not a
description. Later turns reuse that same harness pattern and reference it rather than
reprinting it.

## 5. The two screenshots, corrected

During the handoff I described both uploads as bug evidence, "menu overlap, wide-screen
squish." That was wrong, and I only caught it by actually opening the files for this
archive. The accurate labels:

- **16402.jpg is the origin image, not a bug.** It is a "Leading Report" (@LeadingReport)
  post stating that there may be aliens stationed at five or six underwater bases off the
  U.S. coast, attributed to Rep. Tim Burchett, dated 03 Jun 26, over a Google Earth
  seafloor image of a structure-like feature off a coastline. This is the real-world seed
  the whole project grew from: the underwater alien-base premise behind Deep Contact and
  then Siren's Song. For a provenance archive this is arguably the single most relevant
  artifact, which is exactly why it should not have been left behind.
- **16443.jpg is the menu-overlap bug screenshot**, the one attached inline at turn 114.
  It shows the start screen with the HUD bars and the control buttons overlapping the
  briefing text, the bug fixed in turn 117.
- **There is no wide-screen-squish screenshot.** That problem (turn 118) was reported in
  text only and was never captured as an image. Nothing is missing on that count; the
  earlier "squish screenshot" phrasing was my error.

## 6. What is deliberately not here

- The handoff payload itself (v7, v0.3 spec, dev notes, pressure design, v6 anchor,
  Deep Contact origin spec, MANIFEST). Those live in `sirens_song_handoff.zip`, unchanged.
- v3 and the ping-occlusion intermediate: never standalone files; their diffs are in the
  transcript (see section 4).
- The self-referential tail: from turn 127 onward the session is the construction of this
  very archive. Transcribing that turn by turn would recurse without end, so the transcript
  marks it and this README documents it instead.
