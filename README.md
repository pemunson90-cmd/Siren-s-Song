# Cloud evidence snapshot for the Windows desktop handover

Created23October2026 Eastern while PR96's hosted check was still running.
The final published source and stop state belong to docs/RESUME.md on
claude/integration and docs/codex/023-arch2-main-and-hud.md on codex/handoffs.
This archive is historical evidence, not an instruction to resume implementation.

cloud-evidence-20261023.zip preserves551 selected evidence files: local Godot
logs, route-map screenshots, M1 pressure pairs/comparison tools, ARCH2 body-parity
proofs and an incremental bundle of11 local recovery refs. SHA256SUMS identifies
the ZIP; manifest.json records every contained path, length and SHA256. All
published game/preparation source remains on its existing Git branches.

The archive intentionally includes RED probes plus later passing candidates.
Read the exact candidate log names in the handoff Completion notes. Root's
campaign-flow evidence is ss-arch2-{before,campaign-after}; photo preparation is
ss-arch2-photo-{before,after}. The first photo import failed type inference;
import2 and the final candidate checks passed. M1's final comparison is
ss-m1-new-pressure, not its earlier baseline. No test count or scripted controller
establishes physical-phone behavior, blind-player success or enjoyment.

Retrieve through Git without checking out this evidence branch:

```sh
git fetch origin refs/heads/archive/cloud-desktop-20261023:refs/remotes/origin/archive/cloud-desktop-20261023
git show origin/archive/cloud-desktop-20261023:cloud-evidence-20261023.zip > ../cloud-evidence-20261023.zip
git show origin/archive/cloud-desktop-20261023:SHA256SUMS
sha256sum ../cloud-evidence-20261023.zip
unzip ../cloud-evidence-20261023.zip -d ../cloud-evidence-20261023
```

Use a full repository clone/fetch, then optionally verify and restore local
recovery refs from the extracted incremental bundle:

```sh
git bundle verify ../cloud-evidence-20261023/recovery-refs.bundle
git fetch ../cloud-evidence-20261023/recovery-refs.bundle 'refs/codex/recovery/*:refs/codex/recovery/*'
```

Those recovery refs preserve metadata-equivalent local commits from an earlier
network interruption. They do not replace the live published refs, authorize a
force push or require restarting completed work. If a local ref already differs,
inspect and preserve it rather than forcing this fetch.

Credentials, environment-variable dumps, personal Godot profiles/saves, toolchain
caches and APKs are excluded. Existing personal saves need a separate private
copy if present; never replace Windows or phone progress with test fixtures.
The canonical debug signing key stays at its existing Git-tracked path and must
not be regenerated. No branches were deleted or promoted to frozen baselines.
