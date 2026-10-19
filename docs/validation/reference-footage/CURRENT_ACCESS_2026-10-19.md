# Current official reference access ·19 October 2026

The earlier CONNECT403 failures in `SOURCES.json` remain valid historical observations. Later normal inherited-proxy access retrieved official Steam movie metadata/HLS and decoded the Mark of the Ninja: Remastered footage; TLS verification was unchanged. No alternate proxy or access bypass was used. Current retrieval provenance is retained locally in `work/reference-footage/provenance.json`, not silently assigned to the earlier failed attempts. Barotrauma and Door Kickers do not receive an access/comparison verdict from this result.

- Official Steam metadata: <https://store.steampowered.com/api/appdetails?appids=860950&filters=movies>, movie **256730179**, title **Mark of the Ninja: Remastered Trailer**.
- Exact HLS source: <https://video.akamai.steamstatic.com/store_trailers/860950/186745/1e7eeceedbb4b6a382dbc31c6cc079109f5f1a50/1750590484/hls_264_master.m3u8?t=1537890640>.
- Local capped100s source: `work/reference-footage/mark-of-the-ninja-trailer.mp4`; SHA256 `e661cf1dc46f7c86cf78ce0aabfd9423bd27f0559cce7fb561edc0bbaff991ab`. Retrieval recorded at2026-10-19T11:10:29Z. Remastered promotional footage, visible cuts/branding; exact gameplay patch/platform unverified. The separate YouTube teaser candidate is not asserted to be the same edit.
- Primary critical comparison: **30–40s**,10seconds; supplementary **44–60s**,16seconds. Actual chronological frame decoding and cadence are in the [independent report](../../reviews/2026-10-19-acoustic-feedback-critique.md). No blinding, human listening or measured new-player learning is claimed.

Reconstruct the primary excerpt from the hash-matched local source (silent1280×720, visual comparison only):

```sh
ffmpeg -ss 30 -i work/reference-footage/mark-of-the-ninja-trailer.mp4 -t 10 -an -vf scale=1280:720 -c:v libx264 -crf 24 work/acoustic-critic/mark-of-the-ninja-30-40.mp4
```

Four selected frames with timestamps and Klei credit are retained in [critic evidence](../production/acoustic-feedback/critic/reference-moments.jpg). Full trailer is not duplicated into the repository. This compares clarity, not assets, identity or mechanic imitation. No recommendation to play/download a current store version is made; current regional/mobile availability was not verified.
