# Native touch: passing subset, interrupted final restoration

[Run 39204224960](https://github.com/pemunson90-cmd/Siren-s-Song/actions/runs/39204224960), job `117903438115`, source `92625acdf55a6e45c55903a7943aef994ba334a7`. Overall **failed**; baseline remains `93b8631`. Hosted checks pass eight parser guards, 88 core and 225 runtime checks. Public signing identity remains unchanged; [signature](apk-signature.txt), [APK hash](sirens-song-debug.apk.sha256), [fingerprint](fingerprint.txt).

## Actual passing native evidence

Both cover 2520×1080 and inner 2184×1968 profiles pass +/− at numerical zoom 1.4/1/1.96, real single-pointer touchscreen swipe, FIT recovery to zoom 1/world center (800,480), and **zero new orders or pause changes during navigation**. Cover center moves to (874.7768,480); inner to (900.2903,480). [Raw engine lines](godot-events.txt) and [fixture stages](progress.txt) retain the assertions.

Inspected original [cover pan](cover-panned.png), [unfolded pan](inner-panned.png), camera exposure artifact and [successful debrief](inner-mission-completed.png). Zoomed terrain and primary controls render; controls reflow beneath the unfolded chart. Zoom crops distant world content, including the Signal Spire label at the edge; this is retained as a presentation limitation, not hidden by rectangle checks. OS pinch remains unverified.

Both profiles also pass normal orders/pause, background/resume, explicit process death/new-process archive restoration. A fresh ordinary Shelf Signal sequence travels through sustained active audio, captures the optical record, wins extraction and saves `completed=[0] unlocked=1`. This is not a claim that the final completed-campaign restore or global final error gate passed.

## Exact interrupted stage

After the successful debrief, Home/kill precedes the final restart. At 05:29:52 the host emulator reports a preempted graphics context and adb reports `error: closed`. At 05:30:00 the final downloaded log shows a fresh Zygote startup; at 05:30:01 `wm` reports `Can't find service: window`, exit 20. The [unaltered workflow excerpt](restart-workflow-excerpt.txt) and [raw post-interruption logcat](post-interruption-logcat.txt) preserve this evidence.

Android runtime/services restarted or were unavailable. The captured evidence does not establish whether the initiating cause was app, system, graphics, memory pressure or another guest/host issue; graphics-context preemption alone is not causation. No app-fatal trace appears in the retained deduplicated engine events. The reboot/reset log buffer means that is not complete pre-interruption system-crash evidence. The final completed-campaign restore and strict final gate were **not reached**.

The next controlled retry retains a full pre-restart log checkpoint plus kernel boot ID, system_server PID, service states, boot properties and memory before/after the final restart; on failure it additionally collects app exit history and system_server crash/watchdog records. Probes remain bounded/diagnostic, with no automatic service recovery, backend change or relaxed game gate. Production runtime source remains exactly this candidate. One controlled retry is intended to resolve the interrupted service boundary, not erase this failure.
