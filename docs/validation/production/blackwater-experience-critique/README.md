# Independent Blackwater experience evidence

[Review](../../../reviews/2026-10-19-blackwater-direct-experience.md). Read actual artifacts before builder/code interpretation; [initial notes](artifact-first-observations.md) preserve the provisional record. No blinding, audio, newcomer or physical-device acceptance claim.

- [Inspection hashes/method](inspection-manifest.json).
- [Audible acquisition0–4s at4fps](active-acquisition-0-4s.jpg), ordered left-to-right/top-to-bottom. Source is actual `../blackwater-motion-review/challenger-active-reply.mp4`; quarter-second sample cadence.
- [Idle lock/loss8–14s at2fps](idle-lock-loss-8-14s.jpg), same ordering; add8s to the relative half-second cadence. Source is actual `challenger-idle-final.mp4`.
- [Official Mark of the Ninja30–40s at2fps](reference-noise-30-40.jpg), same ordering; add30s. Credit Klei Entertainment; reference footage remains its owners' property. Used only for noise/attention clarity. No imitation, asset reuse or store/play recommendation.

Reproduce sheets with `ffmpeg -ss START -i INPUT -t DURATION -vf 'fps=RATE,scale=480:-1,tile=COLSxROWS' -frames:v 1 OUTPUT`. ExactSTART/DURATION/RATE/grid: acquisition0/4/4/4x4; idle8/6/2/4x3; reference30/10/2/4x5. Full chronological game1fps sheets and six fullsize frames per take remain in `../blackwater-motion-review/`; receiving/gallery originals remain in `../blackwater-direct/`.
