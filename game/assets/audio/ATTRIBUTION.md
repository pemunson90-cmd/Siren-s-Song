# Recorded soundscape attribution

These are edited recordings, not synthesized waveforms. Licensed for commercial use.
Downloaded 21 October 2026. No endorsement by the source authors is implied.

## Machinery recordings: Creative Commons Attribution 3.0 Unported

**Michael Brigida and students, Berklee College of Music / OLPC sound archive.**
A collection of sounds selected, organized and prepared for OLPC by Dr. Richard
Boulanger (Dr. B.). From 1999–2007, these samples were recorded in The Berklee
Studios and on location in and around Boston under Associate Professor Michael
Brigida by over 250 Music Synthesis majors in his Advanced Sampling Class.
Diane Douglas and Colman O'Reilly edited and trimmed the original recordings.
Submitted to OpenGameArt by bart.

Source: https://opengameart.org/content/13-ambient-machine-sounds
Archive: https://opengameart.org/sites/default/files/ambient%20machinery%202.zip
License: https://creativecommons.org/licenses/by/3.0/ (full text: CC-BY-3.0.txt)

Used source files: fan_noise.wav, motor_1.wav, motor_2.wav,
subwayTrain_B-line.wav, wind_up_long_1.wav.
Derived game files: ambience.wav, engine.wav, tension.wav, factory.wav,
salvage.wav, berth_release.wav. These adaptations retain CC-BY-3.0 attribution.

## Metal foley recordings: Creative Commons Zero 1.0

**blacklodgegames**, “27 Metal Audio Samples (SFX)”. The author recorded pieces
of metal being bent, wobbled and struck. CC0 public domain dedication.

Source: https://opengameart.org/content/27-metal-audio-samples-sfx
Archive: https://opengameart.org/sites/default/files/27-Metal-Audio-Samples-blacklodgegames.com_.zip
License: https://creativecommons.org/publicdomain/zero/1.0/ (full text: CC0-1.0.txt)
All remaining game WAV files derive from this pack.

## Adaptations and playback

Editing by the Siren's Song audio implementation lane. `manifest.json` maps every
output to its original filename, crop, playback speed, filtering, rhythm and SHA256.
All recordings were downmixed to mono, resampled to 22050 Hz, DC centered,
peak normalized to 0.55 or less, and written as 16-bit PCM. No oscillators or noise
sources were added. Pitch changes, filtering, reverse and rhythmic arrangements
create game cues from physical recordings; they are designed cues, not claims of
actual submarine/sonar/heartbeat recordings. The ambience represents an interior
machinery texture, not an underwater hydrophone recording.

Three loops use a 400ms equal-gain tail/head overlap and a 5ms endpoint guard.
Godot imports preserve PCM without normalization or trimming, with inclusive loop
endpoints inside the frame data. Each cue is preloaded once and shared by players.
Total WAV bytes: 2,513,586 (about 2.40 MiB), plus tiny import/license metadata.
Decoded PCM: 2,512,530 bytes; three continuous players plus at most five effect
voices. No streaming decompression or runtime PCM synthesis. A quiet bed and
feedback-only tension use the music setting; propulsion and cues use effects.
The master limiter guards peaks; the bed is -17dB and tension peaks at gain .24.

Only fresh public `recon_feedback().threat` drives tension. Its attack is 0.7s and
release 4s, with continuous exponential gain interpolation. It reads no hunt stage,
hidden actor, hidden lock or unreached source. Tactical pause/menu/suspension
freeze all players, and pause freezes the tension envelope. A new mission clock
resets the envelope. Received event provenance/cooldowns remain unchanged.

Retain this attribution and the license texts when redistributing game assets.
`attribution.tres` embeds the attribution and full licenses as an exported resource,
preloaded by soundscape.gd and available as `Soundscape.ATTRIBUTION` or the node
metadata `audio_attribution`. A frontend credits screen can surface its metadata
without rewriting the audio implementation. Distribution should surface these
credits; frontend/export configuration is outside this audio lane.
The original source-page snapshots are also in the external lane archive.
License text mirrors: https://github.com/idleberg/Creative-Commons-Markdown
(3.0/by.markdown and 4.0/zero.markdown), because the canonical legalcode.txt
endpoints returned HTTP403 during this session. Canonical license URLs above govern.
