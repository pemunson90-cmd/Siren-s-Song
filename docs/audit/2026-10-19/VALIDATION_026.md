# Validation evidence audit 026

Frozen source `dced64ffc1dddd9e93f13a029cc44b5e7daa93cd`. Canonical lexical indices 450–467 / 874. File bytes fetched to classify evidence and caveats, no game replay asserted.

| File | SHA | Content | Caveats |
|---|---|---|---|
| `docs/validation/android-touch-targets/quantized-viewport/actual-inner-transform.txt` | `f2f2eb5875cf6d8bc38a581043f74d99de5fd93f` | 288 chars text DENSITY_SETTLED_CAPTURE size=(2184, 1968) result=0 DENSITY_TRANSFORMS screen=[X: (1.70625, 0.0), Y: (0.0, 1.706852), O: (0.0, 0.0)] final=[X |  |
| `docs/validation/android-touch-targets/quantized-viewport/engine-source.json` | `dc3ca8497aac034c6e607ff67b4a90544b1d47b4` | 451 chars JSON keys window,viewport |  |
| `docs/validation/android-touch-targets/quantized-viewport/settled-local-audit.json` | `c3fcd146acf63761d2522c5684629a9ba3ae070f` | 63794 chars JSON keys native_measurement,provenance,reports | failure terms |
| `docs/validation/android-touch-targets/quantized-viewport/source-checkpoint.json` | `772c6a8fed07526d312266a93e5bb74003e2b83f` | 491 chars JSON keys isolated_suites_commit,project_sha256,project_model,geometry_summary,menu_summary,settled_capture_artifacts_commit,settled_capture_blobs_verified | failure terms |
| `docs/validation/android-touch-targets/quantized-viewport/viewport-source-excerpt.txt` | `a18067b38688f61ef397c2d27173932ee9c4258d` | 415 chars text 1202: Rect2 Viewport::get_visible_rect() const { 1203: 	ERR_READ_THREAD_GUARD_V(Rect2()); |  |
| `docs/validation/android-touch-targets/quantized-viewport/window-source-excerpt.txt` | `8b7ec48885f556bbab2ba98ba45e366c1e533859` | 4458 chars text 1232: void Window::_update_viewport_size() { 1233: 	//update the viewport part |  |
| `docs/validation/android-touch-targets/scroll-contract/README.md` | `84849079e1ca37741e5102a0b3400d45829541d0` | 1462 chars text # Scroll correction: local contract verification The seven actual same-frame PNG/JSON pairs in `production/density/scroll-boundary/captures/ | failure terms |
| `docs/validation/android-touch-targets/scroll-contract/settings-reachability.json` | `6f98a418843feb18963b414bfbbbd048cb719cee` | 2637 chars JSON keys native_measurement,reports |  |
| `docs/validation/android-touch-targets/scroll-contract/settled-audit.json` | `b7a3d0cd3e98b94f2a20ec553f1cbbe06e96a6b5` | 40486 chars JSON keys native_measurement,provenance,reports | failure terms |
| `docs/validation/environment-audit.md` | `adf284e3b87a6276b5c0ff88ff10c809e4ce5c7d` | 38515 chars text # Environment audit — 2026-10-19 UTC Requested delegate model: **gpt-6.1-sol**, explicitly routed with `fork_turns=none`. Actual backend mod | failure terms,qualification |
| `docs/validation/native-siren-roles/README.md` | `24a8fe7d14c8457c31896a80fe79daf93289aabe` | 5496 chars text # Prepared native A-role increment **Executed in [run 39216492480](../android-39216492480/README.md): numerical native gate passes; direct c | failure terms,qualification |
| `docs/validation/native-siren-roles/local-protocol-parser.json` | `f830c36b72c1b901760a49850c3152f1f4164ffd` | 331 chars JSON keys mission,hunter,entry,observations,max_observed_home_distance,return_simulated_time,final_home_error,modes | failure terms |
| `docs/validation/original-prototype-mechanics/README.md` | `8df784f7be5a97e31e7bda4e409388c6a41ea5d8` | 4597 chars text # Original-prototype mechanics evidence — 19 October 2026 Read-only implementation audit. Requested routing: `gpt-6.1-sol`; actual backend/c | failure terms |
| `docs/validation/original-prototype-mechanics/prototype-v6.json` | `b94d8e13c3d6a411fe6c1f50d046064627a8b321` | 1056 chars JSON keys source,result |  |
| `docs/validation/original-prototype-mechanics/prototype-v7.json` | `6a61711988b32568644d5a3271599f30b1148e21` | 1192 chars JSON keys source,result |  |
| `docs/validation/original-prototype-mechanics/source-hashes.json` | `1fd8552c29d1ab5bd76346bc567aaf12b2b0618d` | 4565 chars JSON keys 8d8635a,f1ea536,d09311c,originals |  |
| `docs/validation/production/2026-10-19-playable-batch.md` | `aaf579db4baebd418945b935673b089ae8031335` | 1304 chars text # Integrated playable batch Game source735e444; docs-only point b4e4d79. One combined gate exited0 on19October2026, Godot4.6.3 Compatibility | failure terms |
| `docs/validation/production/README.md` | `5b1512385d4a10952c5fa11f52709f04f53617a3` | 5377 chars text # Baseline evidence — 19 October 2026 This is an initial campaign baseline, not completion of the persistent Gauntlet. Actual game framebuff | failure terms,qualification |

Next zero-based index 468.
