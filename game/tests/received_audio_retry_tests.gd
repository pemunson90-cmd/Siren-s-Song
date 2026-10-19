extends SceneTree
const Sim=preload("res://src/simulation/simulation.gd")
class ObservedSound:
 extends "res://src/audio/soundscape.gd"
 var received=[]
 func play(cue:String,relative_position:Vector2=Vector2.ZERO)->void:
  if cue in ["carrier_received","return_received"] and not muted and not system_suspended:received.append(cue)
  super.play(cue,relative_position)
var checks=0
var failures=0
func check(ok:bool,label:String):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():call_deferred("run")
func run():
 var sound=ObservedSound.new();root.add_child(sound)
 var state=Sim.new();var times=[]
 # Identical normal BARE mission starts/routes; no actor/resource/source writes.
 for attempt in 2:
  state=Sim.new();state.start(9);sound.update(state,0.,true)
  check(sound.ambience.stream_paused and sound.engine.stream_paused,"paused new start keeps audio suspended")
  state.command("route",{"point":Vector2(1000,1560)});state.paused=false
  var found=false
  for tick in 1500:
   state.advance(1./60)
   found=state.events.any(func(event):return event.type=="carrier_received" and event.receiver==0)
   sound.update(state,1./60,true)
   if found:times.append(state.elapsed);break
  check(found and sound.received.size()==attempt+1,"ordinary retry%d dispatches its own first received carrier"%(attempt+1))
 check(times.size()==2 and is_equal_approx(times[0],times[1]),"identical first-event timestamps cannot suppress a legitimate retry")
 var heard_before=sound.received_cues.heard.duplicate(true);var count=sound.received.size()
 state.paused=true;sound.update(state,0.,true);sound.update(state,0.,true)
 check(sound.received_cues.heard==heard_before and sound.received.size()==count,"pause at unchanged simulation time does not reset deduplication or replay reception")
 sound.muted=true;state.start(9);sound.update(state,0.,true);state.paused=false;state.advance(1./60);sound.update(state,1./60,true)
 check(sound.received.size()==count and AudioServer.is_bus_mute(AudioServer.get_bus_index(sound.EFFECTS_BUS)),"muted retry stays muted while clock reset remains functional")
 sound.suspend();sound.update(state,0.,true)
 check(sound.system_suspended and sound.engine.stream_paused,"suspension still stops audio after reception clock synchronization")
 sound.queue_free();state=null;await process_frame;await create_timer(.1).timeout
 print("RECEIVED AUDIO RETRY CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
