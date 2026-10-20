LIVE GODOT PLAY DRIVER

Driver: /workspace/Siren-s-Song-gauntlet-archives/live-input-harness/play.py
Choose a unique session name. It preserves its own save, screenshots and input log.

Start an actual Main session (fresh profile):
python3 /workspace/Siren-s-Song-gauntlet-archives/live-input-harness/play.py --session cautious-cover start --shape cover --source /workspace/Siren-s-Song-berth-instruments

Use --shape inner for2184x1968; cover is2520x1080 with recorded Android inset.
Optionally append --profile /absolute/path/quietus.save to COPY a genuine profile.
Read the returned PNG and choose physical pixels from that original-size image.
If your image viewer scales the PNG, convert coordinates back to its stated size.

Commands, with the same --session NAME prefix:
 screenshot                         capture current frame
 tap X Y                            press/release one screen position
 drag X1 Y1 X2 Y2 --seconds .5       drag one finger
 pinch X1 Y1 X2 Y2 EX1 EY1 EX2 EY2  two-finger gesture
 touch down X Y --pointer 0          raw finger press
 move X Y --pointer 0                raw finger drag sample
 touch up X Y --pointer 0            raw finger release
 key Escape                         raw keyboard press/release
 wait 3                             allow3 seconds of live wall time
 status                             current own-state metrics and screenshot
 resize inner                       live display resize; or cover
 quit                               final screenshot/metrics and process exit

The game continues in real time between commands. Use its visible PAUSE control
when you want unlimited thinking time. The driver never pauses or advances Sim.
Every response includes an actual PNG path. Session files include requests.jsonl,
input-events.jsonl, responses.jsonl, end-metrics.json, source.json and godot.log.
Input events go through Window.push_input; game callbacks/commands are not called.

These are420dpi Godot desktop display fixtures. Audio uses Dummy; no audio verdict.
Source/save provenance is recorded automatically. Strategy and route decisions
belong to the player. No named-action API, winning route or gameplay edits exist.
