# Validation evidence audit batch V001

Frozen SHA dced64ffc1dddd9e93f13a029cc44b5e7daa93cd; source records 1–18 of 874. Every listed file fetched and examined for format, opening claim, and qualification/error terms. These are **mechanical provenance/content checks**, not replay of the game or independent human evaluation. Failed retrievals remain unreviewed.

| File | Read result | Source claim / shape | Indicators |
|---|---|---|---|
| `docs/validation/android-39194450149/godot-logcat-excerpt.txt` | 15633 chars text | 10-19 03:25:56.290  1304  1344 I Launcher.IconCache: Database bulk icon loading failed, using fallback bulk icon loading for: ComponentInfo{org.sirenssong.game/ | failure/warning terms |
| `docs/validation/android-39197089036/apk-signature.txt` | 1043 chars text | Verifies Verified using v1 scheme (JAR signing): false |  |
| `docs/validation/android-39197089036/godot-logcat-excerpt.txt` | 5205 chars text | 10-19 04:00:09.714   622   730 I ActivityTaskManager: START u0 {flg=0x10000000 xflg=0x5 cmp=org.sirenssong.game/com.godot.game.GodotAppLauncher} with LAUNCH_SIN | failure/warning terms |
| `docs/validation/android-39197795717/workflow-evidence-excerpt.txt` | 7510 chars text | 2026-10-19T04:06:43.1487709Z Cache hit for: godot-4.6.3-official-sha512-v1 2026-10-19T04:06:53.2369663Z Cache restored successfully | failure/warning terms |
| `docs/validation/android-39199537776/apk-signature.txt` | 1043 chars text | Verifies Verified using v1 scheme (JAR signing): false |  |
| `docs/validation/android-39199537776/rotation-logcat-excerpt.txt` | 742 chars text | 10-19 04:31:55.079  4074  4104 I godot   : SS_RESTORE ok mission=0 time=0.65 paused=true completed=[] unlocked=0 10-19 04:32:04.875  4074  4104 I godot   : SS_T |  |
| `docs/validation/android-39200256192/README.md` | 3222 chars markdown | # Native audio boundary crash Run [39200256192](https://github.com/pemunson90-cmd/Siren-s-Song/actions/runs/39200256192), job `117891560814`, source `3caa274d83 | failure/warning terms |
| `docs/validation/android-39200256192/apk-signature.txt` | 1043 chars text | Verifies Verified using v1 scheme (JAR signing): false |  |
| `docs/validation/android-39200256192/fault-instruction.txt` | 404 chars text | /workspace/.sirens-song-toolchain/symbol-investigation/libgodot_android.so:     file format elf64-x86-64 Disassembly of section .text: |  |
| `docs/validation/android-39200256192/fingerprint.txt` | 85 chars text | google/sdk_gphone64_x86_64/emu64xa:16/BE2A.250530.026.F3/13894323:userdebug/dev-keys |  |
| `docs/validation/android-39200256192/native-crash-interval.txt` | 27270 chars text | 10-19 04:42:44.216  5456  5492 F libc    : Fatal signal 11 (SIGSEGV), code 2 (SEGV_ACCERR), fault addr 0x7f78981ff000 in tid 5492 (AudioTrack), pid 5456 (sirens | failure/warning terms |
| `docs/validation/android-39200256192/progress.txt` | 3734 chars text | SS_SMOKE_STAGE 2026-10-19T04:38:50Z smoke script entered after emulator action boot SS_SMOKE_STAGE 2026-10-19T04:39:18Z APK installed |  |
| `docs/validation/android-39201435045/apk-signature.txt` | 1043 chars text | Verifies Verified using v1 scheme (JAR signing): false |  |
| `docs/validation/android-39202066103/README.md` | 3026 chars markdown | # Native completion checkpoint [Successful run 39202066103](https://github.com/pemunson90-cmd/Siren-s-Song/actions/runs/39202066103), job `117896952083`, exact  | failure/warning terms |
| `docs/validation/android-39202066103/apk-signature.txt` | 1043 chars text | Verifies Verified using v1 scheme (JAR signing): false |  |
| `docs/validation/android-39202066103/fingerprint.txt` | 85 chars text | google/sdk_gphone64_x86_64/emu64xa:16/BE2A.250530.026.F3/13894323:userdebug/dev-keys |  |
| `docs/validation/android-39202066103/godot-events.txt` | 78456 chars text |         * ActivityRecord{132431914 u0 org.sirenssong.game/com.godot.game.GodotAppLauncher t8}         mControlTarget=Window{2054c49 u0 org.sirenssong.game/com.g | failure/warning terms |
| `docs/validation/android-39202066103/progress.txt` | 5383 chars text | SS_SMOKE_STAGE 2026-10-19T05:00:20Z smoke script entered after emulator action boot SS_SMOKE_STAGE 2026-10-19T05:00:44Z APK installed |  |

Next validation index 18; full text-audit completion requires all 874 validation records and remaining docs.
