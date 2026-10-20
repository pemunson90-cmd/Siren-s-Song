# Siren’s Song — execution screenshot recovery,20October2026

This thin archive preserves230 original PNGs from five normally-quit touch sessions and the prior/final Witness UI captures. The sixth isolated cautious critic is active and excluded from this first commit. Source/session identities, original filenames, image formats, sizes and SHA256 hashes are recorded in the JSON manifests. Final UI captures bind to49d4d35590fb67bd900aba14b7342b4179c600d7; earlier UI captures are explicitly working-tree evidence with unverified exact uncommitted source provenance. Root separately preserves profiles/raw logs/handoff. No source tree, caches, databases or signing keys are stored here; all original local PNGs remain untouched.

Numeric opaque RGB/RGBA frames use lossless libx264rgb CRF0,bgr24. Every original PNG was reconstructed using pinned Godot4.6.3 and its hash verified before publication. Named/initial/UI exceptions remain original PNGs in a lossless tar.gz. The MKVs use a **synthetic25fps storage index**, not gameplay timing. Original timing remains in original filenames and separately retained raw input logs.

## Restore

Retrieve this branch at the exact receipt commit, including all media parts. Run `sha256sum -c SHA256SUMS` in this directory. Concatenate each ordered part series and verify its full archive hash against manifest.json:

```sh
cat media/execution-closed-2184x1968-rgb.mkv.part* > execution-closed-2184x1968-rgb.mkv
cat media/execution-closed-2520x1080-rgb.mkv.part* > execution-closed-2520x1080-rgb.mkv
cat media/execution-named-exceptions.tar.gz.part* > execution-named-exceptions.tar.gz
sha256sum execution-closed-2184x1968-rgb.mkv execution-closed-2520x1080-rgb.mkv execution-named-exceptions.tar.gz
```

Restore the original exceptions under `/workspace` without replacing existing files:

```sh
tar --keep-old-files -xzf execution-named-exceptions.tar.gz -C /workspace
```

For each MKV, make a separate scratch directory, decode with `ffmpeg -v error -i ARCHIVE.mkv -fps_mode passthrough SCRATCH/%06d.png`, then run pinned Godot4.6.3 with the matching JSON:

```sh
godot --headless --path /PATH/TO/GAME --script "$PWD/verify-frame-archive.gd" -- "$PWD/execution-closed-2184x1968-rgb.json" /ABSOLUTE/SCRATCH --restore
```

Repeat for the2520x1080 JSON/MKV using separate scratch. The unchanged verifier restores each original image format, checks exact original PNG bytes, and refuses to overwrite a changed original. It writes the original `/workspace` paths recorded per frame. Finally run `cd /workspace` then `sha256sum -c /PATH/TO/ARCHIVE/ORIGINAL-PNG-SHA256SUMS`. Source/playback timing must never be inferred from the MKV frame rate.
