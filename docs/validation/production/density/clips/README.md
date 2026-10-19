# Actual planning GUI replay

`cover-planning.mp4`: 16.000 seconds, 240 frames, 15 fps, 1260×540. Each frame is actual rendered 2520×1080 viewport output downsampled by half, without MovieMaker crop. Fixture density 420 dpi is explicitly simulated. No audio track, Android OS input or finger-comfort claim. Current source main.gd SHA256: cbfc3c59a0bffd68ab4f6b2d9303a11bb5ec8f31c7b55bf675fcceb0d82687df. Captured by `game/tests/capture_density_interaction.gd`; event log and contact sheet retained.

Starts canonical paused Shelf Signal. Ordinary engine GUI pointer events select Drone A, route to 600,800, enable queue, add 900,800, open secondary, attempt CAMERA out of range, append 900,700, emergency-route selected Drone A to extraction, return primary, select/route Drone B, resume/pause, zoom/FIT. Persistent header shows ADD TO ROUTE during secondary actions and REPLACE ROUTE after emergency. No position/capture/outcome edits. Only one simulated second elapses during sixteen seconds of tactical planning. This is deterministic GUI replay, not a human playtest or OS-touch proof.

`cover-planning-6ce6cc0.mp4` retains the initial pre-feedback clip, whose sequence selected Drone B before opening secondary and therefore did not expose hidden queue mode. Its log/source remains separate. Individual source frame sequences were in /tmp/sirens-density-interaction and /tmp/sirens-density-feedback; videos are durable motion artifacts.

Prior no-input passive-patrol.mp4 under siren-roles/clips is ec2aa08 UI source, only prior-world context; do not label it new-density footage. Door Kickers shipped-motion comparison remains pending actual footage access.
