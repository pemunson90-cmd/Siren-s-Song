extends RefCounted
# One abandoned departure loop, not a remote-commandable global distraction.
# Sirens hear the ordinary finite emission through the same water as any tool.
const REPEATER=Vector2(1520,620)
const SOUND_RANGE=1100.0
const DURATION=15.0
const LOCAL_RANGE=65.0
const ACCOUNT="DRILLER'S LOG: The beacon is still calling from the empty rig. Nobody out there is waiting on it. One charge remains in the repeater. Let the watchers come to an empty mouth while you cross, if that buys you water. Once it falls silent, I cannot call them back."
static func applies(m:Dictionary)->bool:return m.get("id")==9 and m.has("wake_crossing")
static func initial()->Dictionary:return {"played_at":-1.0,"played_by":-1}
static func context(sim)->Dictionary:
 if not applies(sim.mission):return {}
 var state=sim.mission.wake_crossing
 var known=sim.mission.signal_sources.any(func(s):return s.id=="wake_repeater" and s.located)
 var result={"known":known,"ready":false,"used":state.played_at>=0,"active":state.played_at>=0 and sim.elapsed<state.played_at+DURATION,"remaining":maxf(0.0,state.played_at+DURATION-sim.elapsed) if state.played_at>=0 else 0.0,"reason":"Locate the old repeater locally or with finite Survey"}
 if not known:return result
 result.merge({"pos":REPEATER,"account":ACCOUNT,"range":LOCAL_RANGE,"noise_radius":SOUND_RANGE,"duration":DURATION})
 var body=sim.units[sim.selected]
 if result.used:result.reason="Last playback spent · no recharge or remote repeat"
 elif not sim.outcome.is_empty() or not body.alive:result.reason="Craft unavailable"
 elif body.pos.distance_to(REPEATER)>LOCAL_RANGE:result.reason="Bring any craft within65m of the repeater"
 elif not sim.line_clear(body.pos,REPEATER):result.reason="Rock blocks the local repeater connection"
 elif body.vel.length()>=2:result.reason="Settle below2m/s before starting the one-use playback"
 elif not sim.captures[sim.selected].is_empty() or not sim.module_recovery_status().jobs[sim.selected].is_empty():result.reason="Finish this craft's current work first"
 else:result.ready=true;result.reason="PLAY OLD LOOP ONCE ·1100m open-water sound /15s · may draw ordinary listeners; sight still wins"
 return result
static func play(sim)->bool:
 var c=context(sim)
 if c.is_empty() or not c.ready:
  if not c.is_empty():sim.message=c.reason
  return false
 sim.mission.wake_crossing.played_at=sim.elapsed;sim.mission.wake_crossing.played_by=sim.selected
 sim._noise(REPEATER,SOUND_RANGE,"RIG BEACON LOOP",DURATION)
 sim.events.append({"type":"wake_playback","pos":REPEATER})
 sim.events.append({"type":"plant_switch","pos":REPEATER})
 sim.message="Rig beacon loop plays from the empty platform · one15s transmission · listen for actual watch movement"
 return true
static func valid(data:Dictionary)->bool:
 var m=data.mission
 if m.get("id")!=9:return not m.has("wake_crossing")
 var state=m.get("wake_crossing",{})
 if not state is Dictionary or state.size()!=2 or not state.has_all(["played_at","played_by"]):return false
 if not (state.played_at is int or state.played_at is float) or not is_finite(float(state.played_at)) or state.played_at< -1 or state.played_at>data.get("elapsed",0):return false
 if not state.played_by is int or state.played_by not in [-1,0,1,2]:return false
 return (state.played_at==-1 and state.played_by==-1) or (state.played_at>=0 and state.played_by>=0 and m.signal_sources.any(func(s):return s.id=="wake_repeater" and s.located))
