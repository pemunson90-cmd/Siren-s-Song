# Established development signing identity

`sirens-song-debug.keystore` is the existing non-production Android debug key, preserved in Git under the user's explicit 2026-10-19 authorization. Alias `androiddebugkey`, store/key password `android`. It lives outside the exported `game/` tree. This is not release/store signing material.

Public certificate DER SHA256: `32bcb2287acd01c1f58c26997c7639f3072c74c6b03ab2a24656dc7cd1c7dc3c`, also pinned in `sirens-song-debug.certificate.sha256`.

Recovered from the established production cache (`sirens-song-development-signing-v1`, cache9141003475) by [run39281805341](https://github.com/pemunson90-cmd/Siren-s-Song/actions/runs/39281805341), source024fc3a; artifact12198714472. The 2666-byte key SHA256 is `84b0271c4ffa016d1509743e71f298f535338fda966b7c147b1e21c5a58e17e6`. Its certificate matches accepted installed builds; the later tag-run key and preexisting local key do not.

`configure.sh` verifies this certificate before editor startup and always configures this versioned key. Missing/corrupt/mismatched files fail; restore the tracked files rather than generating a substitute. Official-download caches remain useful, but no signing cache is required. The one-off recovery workflow is removed after persistence. Actual APK signature verification remains part of the next coherent Android batch; no new APK is claimed by this recovery.
