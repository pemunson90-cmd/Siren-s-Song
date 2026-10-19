# Barotrauma sustained-sonar discovery · 19 October 2026

**No suitable continuous-motion reference was verified in this bounded search.** The sonar-navigation/uncertainty comparison remains pending. Two video leads were discovered, but their playable bytes and attribution could not be verified through the available normal access paths. A third accessible source supplies static annotated screenshots, not sustained gameplay. No dimension winner, player-decision claim or human audio judgment follows.

Requested worker routing: gpt-6.1-sol/high, inherited fresh-context scout; actual backend/token/cost telemetry unknown. No delegation, product/assets/tooling/governing/player-save edits, commits or pushes. This is a released research input; root continues active production/native work.

## Three candidate sources

| Candidate | What was verified | Disposition |
| --- | --- | --- |
| [Captain's Guide · Barotrauma](https://www.youtube.com/watch?v=vJKKwwmqifw) | Exa search identifies this exact title/URL. Exa page fetch returns only YouTube footer. Ordinary `urllib` watch and oEmbed requests through inherited proxy/CA each fail with `Tunnel connection failed:403 Forbidden`. | **Best next lead**, because a captain guide is plausibly relevant. Uploader, actual publication date, runtime, game version, mod status, chapters and continuous sonar timestamps remain unknown. It is not certified official, unmodded or suitable merely from its title. |
| [Barotrauma · Real Sonar Moment](https://www.youtube.com/watch?v=EWctHKBWqIY) | Exact title/URL appears in search. Ordinary oEmbed request fails at the same proxy CONNECT403 boundary. | Lower-priority lead. Could be a short/meme or modified footage; no duration, author, version, actual scene or suitability claim. No timestamp invented. |
| [Handbook for Not-so-total-noobs](https://steamcommunity.com/sharedfiles/filedetails/?id=2084142160), Steam creator **Ake-tits** | Ordinary Steam page fetch succeeds HTTP200/399,994bytes. Source shows posted12May2020, updated5March2022, and mixed historic version notes including0.10/0.15; these do not identify a single capture patch. “How to achieve quick dock” discusses footage and embeds attributed navigation images. Three directly linked public originals were fetched HTTP200 and inspected. | All three are **single-frame JPEGs**, confirmed by ffprobe; two visually inspected images show annotated docking alignment/sonar screens. Useful historic static context, **unsuitable for sustained sonar navigation/dread**. Mod status and precise capture version unknown. No attempt to animate stills or represent them as motion. |

Search also sought official Undertow/FakeFish/Daedalic sustained gameplay. The bounded results yielded wiki prose, the above guide, a single-player playlist without a verified specific scene, and a general friends livestream; none justified labeling a new developer clip verified. Search-index dates on YouTube leads were not adopted as actual upload dates.

## Access and retained evidence

All new scratch is under `work/reference-footage/barotrauma-discovery/`:

- `youtube-access.json`: exact stable watch/oEmbed request URLs and observed CONNECT403 errors.
- `handbook-steam.html`, `handbook-retrieval.json`: successful source page and fetch record.
- `handbook-media.json`, `media-probes.json`, `docking-{0,1,2}.media`: public source URLs, byte counts, SHA256 and actual one-frame JPEG probes. First image SHA256 `062c4707975699c3d8aab5152ecfb0c6a519328d50095ff30495ae60f29eb8f2`; remaining hashes are in the records.

Only normal configured proxy/CA access was used. No alternate proxy, client impersonation, cookie/login substitution, signed-URL persistence or access-control bypass. The successful Steam page/image fetches show this is **source-specific access failure**, not an environment-wide network outage. The already failed official press page was not retried. Missing Python `requests` was a local tooling availability issue; the ordinary standard-library `urllib` request supplied the actual HTTP result.

The previously retrieved official `FeatureTrailer1.0_EN` remains preserved and explicitly unsuitable: its approximately36.5–38.5s console shot cuts back to crew/combat. Full197.056s720p file SHA256 `448c69f8fa3e39b201560ab97c4ab8811bb11f9e9a87ddecc2e00e7b95924958`; [earlier decoded inspection and limits](../../reviews/2026-10-19-campaign-quality-scout.md). It was not fetched or rejudged again here.

## Exact next action when ordinary playback is available

Open the [Captain's Guide lead](https://www.youtube.com/watch?v=vJKKwwmqifw) using supported normal playback, establish the uploader/date and whether mod/version information is supplied, then find an **uncut10–20s sonar-console navigation passage** showing evolving returns and an actual steering/information decision. Record its true source timestamps before retrieving only that excerpt. If it is an edited overview without such a passage, reject it and inspect the second lead; do not infer suitability from the title.

Pair the verified excerpt with the retained [Blackwater approach](../production/campaign-quality-scout/blackwater-approach-16s.mp4) and [no-input exposure/world clip](../production/campaign-quality-scout/blackwater-noinput-16s.mp4), qualified to accepted52bedd6, or an exact-source current equivalent. Judge only sonar as the world view/uncertainty; do not turn crew combat or promotional cuts into a comparison of dread. Recognizable UI/prior identity knowledge prevents a blind claim. Neither candidate is a current-play recommendation; store availability was not separately verified. No further blocked-source retries are needed for this assignment.
