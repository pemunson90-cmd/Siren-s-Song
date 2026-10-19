# Independent acoustic experience evidence

See [the verdict](../../../../reviews/2026-10-19-acoustic-feedback-critique.md). Selected moments supplement actual decoded chronological inspection; these sheets are not substituted for the videos.

- `paired-moments.jpg`: baseline left/challenger right at3.5,10.5,19.4 clip seconds, accurately sought and decoded by FFmpeg.
- `idle-expiry-moments.jpg`: no-input clip at13.8,14.8,15.8,17.2s.
- `reference-moments.jpg`: four critical-comparison frames from Klei's **Mark of the Ninja: Remastered**, official Steam movie256730179, source30.5,32.5,33.5,36s. Credit: Klei Entertainment; footage remains its owners' property. Used only to compare visible event/attention feedback. No assets/mechanics copied into Siren's Song.
- `inspection-manifest.json`: source clip SHA256/probe facts and decoder version. Product hashes remain in the parent `source-sha256.txt`.

Inspection cadence: Siren's Song paired20s and idle18s at1fps in full; pause8–13s and idle expiry13–17.5s additionally2fps. Earlier passive patrol16s at1fps,0.5–2.5s additionally3fps. Reference full capped100s context at0.2fps;44–60s and27–43s at2fps; primary30–40s selected from that continuous sequence;30–34s additionally4fps. All were chronological decoded frame sequences, without subjective audio judgment. Selected-sheet timestamps are exact seek requests; regular fps sheets used FFmpeg's representative frame per sampling interval, so review prose gives approximate event times rather than frame-exact latency.

Intermediate extraction and full chronological sheets remain ignored under `work/acoustic-critic/`. Reconstruct selected frames using `ffmpeg -ss <seconds> -i <source> -frames:v 1 frame.png`; source credit/URL/hash/retrieval boundary and10s excerpt command are [retained separately](../../../reference-footage/CURRENT_ACCESS_2026-10-19.md). Full official trailer is not duplicated into Git.
