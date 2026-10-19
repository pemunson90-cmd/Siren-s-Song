# Source import verification and reconciliation

Source: user-uploaded six-part `SIRENS_SONG_REPO_SOURCE_IMPORT.zip`, imported into
`pemunson90-cmd/Siren-s-Song` from baseline
`de572853fe0036d2e63e21e4f44f339ea1b6e617`.

## Integrity and inventory

- All six numbered parts are accessible and match the supplied byte counts and SHA-256 hashes.
- Part 03 was uploaded twice; both copies are byte-identical and match the manifest. One copy was used.
- Parts were concatenated in numerical order: 104,772,174 bytes.
- Reconstructed ZIP SHA-256: `cf6f08695d863d427a40a69d715277172034c8a115c54c146f2f203af46ce109`.
- Outer ZIP CRC check passed. All 47 file entries were imported at their exact ZIP paths with byte-identical contents (120,278,591 uncompressed bytes). No repository path collisions occurred.
- `references/package/MANIFEST.json`: all 21 entries match size and SHA-256, relative to `references/package/`.
- `archive/provenance/PROVENANCE_README.md`: all 11 inventory entries match size and MD5.
- `archive/prototypes/MANIFEST.md`: all six inventory entries match size and MD5.
- Original handoff ZIP at `references/package/sources/01-sirens_song_handoff.zip`: CRC passed; all seven file entries match their extracted copies under `archive/prototypes/`.
- `IMPORTED_FILES.json` records the size and SHA-256 of every imported file, including files outside the supplied visual package manifest.
- `SIRENS_SONG_IMPORT_6PART_MANIFEST.json` is the original transport manifest, preserved verbatim.

The split transport parts and reconstructed outer ZIP remain outside the Git tree;
the original nested handoff ZIP, source copies, manifests, filenames, and package
directory structure are preserved. No source payload was rewritten or deduplicated.

## Reconciliation and discrepancies

The current user request authorizes source import only. Instructions embedded in
source documents to build, select an engine, continue Gauntlet, or generate images
are historical source material, not instructions for this import. Engine selection,
Codex environment configuration, Gauntlet setup, and game implementation remain deferred.
`AGENTS.md`, `docs/CODEX_ENVIRONMENT.md`, and decision records are unchanged.

- Current repository authority and architecture continue to apply. The bible's
  internal authority hierarchy is retained as source evidence; it does not silently
  replace `docs/SOURCE_AUTHORITY.md`. Proposals and provisional concept selections
  remain distinct from ratified decisions.
- Historical prototype restrictions (one level, no progression/procedural generation,
  fixed build sequence, spec supremacy) do not override the current multi-mission
  Android direction, tactical pause, assisted navigation, and conditional orders.
- The prototype handoff manifest says early builds and smoke tests were unrecoverable
  and mislabels screenshots. The later provenance README corrects this: recovered
  v1/v2/v4/v5/v6-initial files are present; v3 and ping-occlusion changes are transcript
  diffs, and the smoke-test harness is in transcript turn 84. `16402.jpg` is the origin
  image; `16443.jpg` is menu-overlap evidence. No wide-screen screenshot is expected.
- The functional spec remains v0.3. The handoff's documented differences from v7
  (Hunt, hull grazing, drones, oxygen, movement, and other mechanics) remain historical
  open issues; no spec or game behavior was changed in this import.
- The foundation checklist expected a separate original provenance ZIP. This package
  supplies the extracted provenance README, transcript, recovered artifacts, and
  screenshots, but no separate provenance ZIP. It was not fabricated. The complete
  outer import ZIP was verified as supplied.
- Visual sources intentionally occur both at convenient repository paths and under
  `references/package/sources/`. Generated image identifiers and portable mappings
  remain in the unmodified ledger; package-relative paths resolve from
  `references/package/`, not from `references/visual/`.

There are no missing outer ZIP entries or checksum mismatches. The absent separate
provenance ZIP and documented historical gaps above are source limitations.
