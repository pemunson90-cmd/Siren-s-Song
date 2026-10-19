# Original prototype handoff import · 19 October 2026

**Published status:** import `8598d5a` and all requested remote bytes/paths are verified; see [published result](PUBLISHED_RESULT.md) and [per-path evidence](PUBLISHED_VERIFICATION.json). Preparation details below remain as provenance.

User-supplied archive: `SIRENS_SONG_ORIGINAL_PROTOTYPE_HANDOFF.zip`, **53,264 bytes**, SHA-256 **d68bbe1495fa42361eaf3ff02e08e60ae1a63251b54a01b7b9d4812e6b27f10d**. Original ZIP is preserved at [reference/SIRENS_SONG_ORIGINAL_PROTOTYPE_HANDOFF.zip](../../../reference/SIRENS_SONG_ORIGINAL_PROTOTYPE_HANDOFF.zip). All seven regular files are preserved at their exact internal paths under [reference/original-prototype/](../../../reference/original-prototype/). No original content, filename, line ending or metadata text was rewritten.

[INVENTORY.json](INVENTORY.json) records every original's byte count, MD5 and SHA-256, manifest match and existing-copy comparison. The ZIP contains six manifest-listed payloads, `MANIFEST.md` itself and the nonempty `history/` directory. Uncompressed regular-file total is **142,965 bytes**.

## Verification

- ZIP CRC check passes for every entry. All names were inspected before extraction; there are no absolute/traversal/backslash paths, duplicate names, encrypted entries, symlinks or other nonregular file payloads. Eight entries comprise seven regular files and one directory; largest payload is 47,365 bytes.
- Each of the six rows in the original manifest's inventory table matches its declared MD5 and byte count. The manifest itself is an additional original file, not a missing listed payload; its SHA-256 is independently recorded.
- Every extracted file was byte-compared to the ZIP member. Originals remain byte-for-byte unchanged in the new location. Git's staged blobs were also compared against the ZIP, independently of the working-tree files.
- All seven are exact duplicates of the corresponding existing `archive/prototypes/` paths. The uploaded ZIP is an exact duplicate of `references/package/sources/01-sirens_song_handoff.zip`, including the same SHA-256. Nothing was silently deduplicated, replaced or renamed: the requested new reference path and uploaded ZIP are preserved explicitly.
- There are **no missing archive entries, manifest checksum failures or differing existing prototype copies**. Historical gaps described inside the originals are distinct from transport integrity and are retained as written.

Preparation used isolated worktree `/workspace/Siren-s-Song-original-import`, branch `import/original-prototype-handoff`, exact fetched base **d09311c3c7201249d4b7230462ff42e9623aa67e**. Scratch extraction is `/tmp/sirens-original-prototype-handoff-inspect`. Active production worktree, uncommitted density changes, player saves and later local commits were left intact. No game/tooling/workflow changes or CI runs are part of this import. Commit and remote path verification are separate final publication checks, not established by staged-byte verification alone.

## Original-file inspection

Every original was inspected as source material, with no embedded commands executed:

| Original | Inspection and interpretation |
| --- | --- |
| `sirens_song_prototype_v7.html` | Full HTML/CSS/JavaScript inspected: interface, procedural audio, configuration, vessel/drone movement, terrain/sonar, tools, suspicion/Hunt/graze, distinct Siren branches, rendering and start/end loop. Preserved as the user-ratified working gameplay implementation reference. Static reading alone is not browser/device validation. |
| `history/sirens_song_prototype.html` | Full v6 content covered by comparison to the inspected v7 common content and complete unified-diff inspection. Retains pre-Hunt/baseAlert behavior, no graze/hull layer, earlier movement/oxygen/drone behavior and earlier menu chrome/resize ordering. It remains a historical rollback reference. |
| `SIRENS_SONG_functional_spec.md` | All 334 lines inspected, including 15 design sections, embedded Cowork wrapper and v0.1–v0.3 decision log. Its single-level/build-sequence/approval instructions remain historical evidence; they are not silently reactivated. |
| `SIRENS_SONG_dev_notes.md` | All 107 lines inspected, including provenance tags, four playtest rounds, tuning table and open questions. Pre-Hunt/v6-era tuning and “drones unbuilt” text do not describe every v7 mechanic. |
| `SIRENS_SONG_pressure_design.md` | All 135 lines inspected. Explicitly labeled a proposal, with escalation/graze rationale, proposed numbers and open design decisions; recommendations are not owner decisions merely because the file was uploaded. Compare implemented v7 behavior separately. |
| `history/DEEP_CONTACT_original_spec.md` | All 49 lines inspected. Early sonar-classification/extraction pitch, technical limits and build-order directions are historical origin evidence, not a replacement production brief. |
| `MANIFEST.md` | All 123 lines inspected. File inventory, missing-item claims, version lineage, implementation/spec gaps, historical governance, open questions and contradictions are preserved without correction inside the original. |

## Reconciliation without changing originals

The user now ratifies v7 as a working gameplay implementation reference. This makes its actual behavior an explicit comparison source for production, while current approved production decisions remain distinct from historical code and prose. Do not infer that every v7 number, architecture choice, unresolved proposal or embedded approval rule is newly ratified. The user separately ratified external Addenda A/B; [current directions and safe checkpoints](RATIFICATION.md) distinguish that later decision from original file status. The separate mechanics audit compares original behavior with published production and the later committed patrol/recovery correction; it must label those source states separately.

The original manifest says earlier versions and smoke tests were unrecoverable. Existing [source-import reconciliation](../README.md) records later recovery of v1/v2/v4/v5/v6-initial artifacts and transcript diffs/harness evidence. Those later records do not alter the bytes of this older manifest. The original manifest's screenshot descriptions likewise retain their historical wording; later provenance distinguishes the origin image from menu-overlap evidence. No omitted files were invented for this ZIP.

This handoff ZIP is **not** the separate original transcript/provenance ZIP previously marked absent. Its arrival does not justify pretending that different missing archive was supplied. It is also not a new functional spec version: the included spec remains v0.3, with documented implementation/spec differences.

## Publication and continuation

Prepare one reference/import/audit-only commit from the approved remote base after the comparison audit is inspected. Before publication, compare immutable candidate against that base and require an empty committed game/tooling/workflow diff, verify every committed original blob and ZIP SHA-256, and confirm the remote branch still equals the expected base. Push only the inspected exact SHA in a separate dependent call, without force. Then verify the exact GitHub commit and each original path/hash before production resumes. Merge the reference commit into local production only after the lead has checkpointed its paused UI work; preserve all local gameplay/tooling commits.

At preparation time no commit, push or remote verification is claimed. Requested import worker model: explicit `gpt-6.1-sol`; actual backend/usage/cost telemetry unavailable. No nested agents.
