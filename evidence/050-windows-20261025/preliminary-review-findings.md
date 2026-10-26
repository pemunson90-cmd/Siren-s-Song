# Preliminary independent audit and root disposition

Reviewer: /root/save043_architect, independent nonauthor, read-only source audit of first WIP c34e7ba6 versus base0fb3873e. This was not final approval and no reviewer tests ran in that preliminary pass.

1. P2: observe-before-threats could lose the actual +6 visual edge if a real paused Disrupt cleared target/stun before the next step. A real Sim.advance acquisition followed by paused EMP reproduced the failure.
2. P2: observe-before-photo completion could leave AITrace attributing a same-step photo stage rise to a previous cause. A real usable photo crossing the threshold reproduced the failure.

Worker /root/photo040_early added unchanged regression expectations. Actual strict RED: integration-edge-red-1.log,66 checks/2 failures. Root moved the single observer to the end of a completed step; the derived sight helper needs no earlier guard stamps. Root also made view cause selection accurate for a pending public action before a subsequent observer. Actual strict GREEN: integration-edge-green.log,66 checks/0 failures, followed by final-hunt_pressure_integration_tests.log,66/0. No sensing, lock, damage or hearing formula changed. Final exact-head review remains a separate requirement.

Separate new-test calibration failure: the paused audio assertion initially required all five voices to report stream_paused, including idle players without streams. External integration-pause-probe-1.log proves two expected dispatches, with only the active stream paused and four idle players stopped. The corrected functional assertion requires all playback stopped or paused, a real paused assigned stream, and the original exact dispatch count. Original integration-expand-7.log59/1 and diagnostic remain preserved; no preexisting shipped assertion changed.
