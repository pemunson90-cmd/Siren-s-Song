# Fresh independent role review evidence

Exact source archives: `/tmp/sirens-fresh-role-review/{8d8635a,ec2aa08,7ff53af}/game`. Built using `git archive <ref> game`, extracted with Python `tarfile`; all `src/**/*.gd` hashes retained in `source-sha256.json` and checked again after probes. Live game files and player saves were never edited.

Run from repository root. To reconstruct an archive:

```sh
mkdir -p /tmp/sirens-fresh-role-review/ec2aa08
git archive ec2aa08 game | tar -x -C /tmp/sirens-fresh-role-review/ec2aa08
mkdir -p /tmp/sirens-fresh-role-review/ec2aa08/game/audit
cp docs/validation/production/siren-roles/fresh-review/ordinary.gd /tmp/sirens-fresh-role-review/ec2aa08/game/audit/
godot --headless --path /tmp/sirens-fresh-role-review/ec2aa08/game --script res://audit/ordinary.gd
```

Repeat for 8d8635a and 7ff53af. `ordinary.gd` uses ordinary route/decoy commands, canonical 60Hz ticks, and an explicitly diagnostic save/restore branch; it does not set actor poses or remove terrain. Its baseline `hunter` output field denotes index 1, which remains an ordinary patroller on 8d. Safe-return timing differs slightly from the builder's protocol because this probe waits for route exhaustion/speed<0.5 before deployment. `WARNING` is a probe event label, not a Godot engine warning.

Other exact commands on isolated snapshots:

```sh
godot --headless --path /tmp/sirens-fresh-role-review/ec2aa08/game --script res://tests/run_tests.gd
godot --headless --path /tmp/sirens-fresh-role-review/ec2aa08/game --script res://audit/intent.gd
godot --headless --path /tmp/sirens-fresh-role-review/ec2aa08/game --script res://audit/stations.gd
godot --headless --path /tmp/sirens-fresh-role-review/ec2aa08/game --script res://audit/pursuit.gd
godot --headless --path /tmp/sirens-fresh-role-review/ec2aa08/game --script res://audit/clearance.gd
```

Copy `intent.gd`, `stations.gd`, `pursuit.gd` unchanged from `../independent-tooling/final-pursuit/` into the archive's `audit/`; `clearance.gd` comes from `../independent-tooling/`. Intent, clearance and core were also run on 8d; station/pursuit checks require challenger role data. All commands exited 0. Raw logs retain complete output, including test totals and canonical diagnostic positions.

MP4 durations were inspected with `ffprobe`; visual samples were extracted using `ffmpeg -ss <seconds> -i <clip> -frames:v 1 <png>`. The three sheets show times 0,3,6,9,12,15 s; `early-samples.png` adds passive0.67/1.67, occluded0.5/1.5 and exposed2/4. These are actual full-viewport frame samples scaled to640×360 on sheets, not a continuous-video viewing claim. Source files are the actual16s/30fps/1280×720 Godot clips in `../clips/`; setup/source limits are preserved there. Four sheets retained; intermediate PNGs discarded to avoid redundant artifacts.

Requested Sol6.1; actual backend/usage telemetry unknown; no nested agents. See the linked review for conclusions and limits.
