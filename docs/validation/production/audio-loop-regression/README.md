# Native PCM loop boundary crash — 19 October 2026

Confirmed native defect, not an emulator rotation error. Actions run39200256192, source3caa274 / game322d23c, passed cover and unfolded native entry/orders/pause/Home/kill/restart/archive entry. During fresh Shelf Signal drone travel, resume04:42:36.380 preceded AudioTrack SIGSEGV04:42:44.216. Mission completion was not reached. Prior native baseline539f58b did not include this longer uninterrupted playback interval; its earlier pass is not evidence that this path was safe.

Tooling retained the actual Android crash trace and matched official x86_64 library. Build ID: `20156519a646217072efd93ff30876fa51603c60`. At PC `0x30338db`, disassembly is `movswl 0x0(%r13,%rsi,2),%esi`, a signed16-bit PCM read. Tombstone registers: r13=`0x7f78981a8de0`, rsi=`0x2b110`=176400. Effective address=`0x7f78981ff000`, exactly the reported protected-page fault.176400=22050Hz×8s, the ambience frame count. The last valid index is176399. The nearest exported name WebPPictureRescale from the stripped library is not a symbolication of the crashing function.

The authored stream factory set both looping WAV endpoints to `values.size()`. Official matching Godot4.6.3 code explains the read:

- [AudioStreamPlaybackWAV::_mix_internal](https://github.com/godotengine/godot/blob/4.6.3-stable/scene/resources/audio_stream_wav.cpp#L245) sets the looping end limit from loop_end.
- Its mix-count computation uses `(limit - offset) / increment + 1`, permitting the endpoint itself in the current chunk.
- The same file's WAV importer clamps sample-index loop endpoints to `frames - 1`.
- `set_data` stores the exact supplied PCM vector; the application must provide valid loop indices.

Fix: use the last valid sample index, `values.size()-1`, for ambience and engine. Both were out of range; only ambience's particular allocation was shown hitting a protected page. No padding workaround, mute, audio-backend change, engine replacement, shortened sample or relaxed native gate was introduced. The shutdown audio-thread flush warning is a separate observation; this crash alone does not establish its cause.

Regression evidence:

- `red.log`: both newly added looping-PCM safety assertions fail; `CHECKS88 FAILURES2`. Existing campaign checks still run.
- `green.log`: full production harness `CHECKS88 FAILURES0`, `RUNTIME CHECKS176 FAILURES0`; no script/engine errors. Assertions check that loop indices address existing PCM frames, rather than only comparing a hardcoded assigned value.
- Long actual mixer audition driver: `game/tests/capture_audio_loops.gd`. Reproduce with `CAPTURE_FRAMES=540 CAPTURE_RESOLUTION=1280x720 CAPTURE_DIR=/absolute/path scripts/toolchain/capture.sh --script res://tests/capture_audio_loops.gd`. It runs18seconds, crossing two ambience periods and repeated pitch-adjusted engine loop boundaries, logs real playback positions and records actual mixed output. Completed actual18second capture; `mixer.log` reports ambience position wrapping at8.02s and16.02s plus repeated engine wraps. `mixer-analysis.json` records actual PCM measurement, and `loop-audition.mp4` retains the rendered/mixed output. There are no script/engine errors; known forced-exit ObjectDB audio flush warning remains. This is desktop evidence, not an Android substitute.
- Corrected native retry remains required: full lifecycle/completion gate with actual audio enabled, elapsed active playback and strict fatal/script/error checks. Passing local assertions or a desktop recording does not certify Android behavior.

Raw crash trace: `/workspace/.sirens-song-toolchain/artifacts/github-run-39200256192/evidence/android-smoke/logcat.txt`. Matched library: `/workspace/.sirens-song-toolchain/symbol-investigation/libgodot_android.so`. Tooling's durable native evidence is under `docs/validation/android-39200256192/`.
