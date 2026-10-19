# Resume capture · independent regression evidence

[Verdict](../../../reviews/2026-10-19-native-resume-capture-regressions.md): no consequential defect confirmed in exact patchbf3628f9 on20de5cd. Supports bounded integration and meaningful subsequent native validation, not compositor/image-semantic/physical acceptance. Current39266427532 evidence is untouched and predates this patch.

- `isolation-verification.json`, `reviewed-source-manifest.json`: independent exact20de game/scripts reconstruction, successful patch application and all10 before/after hashes. Shared6ab8 navigation is excluded.
- `black-frame-verification.json`: byte-identical actual39261365076 original/fixture,2520×1080/allRGB0, source hash and provenance. Original PNG is preserved in the released patch and prior native artifacts, not duplicated here.
- `adversarial.py`, `adversarial.json`: five additional real checker/helper gap probes. ADB/logs are mocked. Decoder exit/marker contradictions, actual corrupt PNG decode and a foreground boundary appearing only after the candidate cannot publish a stale final. Geometry probe and rejected candidate remain. Expected corrupt-image decoder errors are retained.
- `reference-sha256.json`: exact released patch, GL RED/GREEN, headless, decoder/protocol and existing unaffected suites reused. No broad/runtime/native/CI rerun.
- `verification.log`, `SHA256SUMS`: final source/evidence and report-link checks.

Reproduce after reconstructing the pinned patched copy under `work/native-resume-regression/candidate/`:

```sh
python3 docs/validation/production/native-resume-regression/adversarial.py
```

The script finds the repository root from AGENTS.md, runs actual isolated checker/helper files, uses pinned Godot for corrupt-image decoding, and keeps temporary userdata/files inside the reviewer's work directory. Its final positive shell case uses a fake successful pixel checker to isolate foreground bracketing; that synthetic header is explicitly not accepted-image evidence. The producer's separate9-case suite supplies real positive/black/uniform decoder coverage.

Reviewer owns only this directory, its report and `work/native-resume-regression/`. No shared source/governing/assets/save/tooling/CI/commit/push mutations or nested agents. Requested Sol6.1/high; actual backend/effort/cost unknown. Root owns integration/publication and continues the persistent Gauntlet after scope release.
