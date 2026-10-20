extends SceneTree
const Sim=preload("res://src/simulation/simulation.gd")
const Sound=preload("res://src/audio/soundscape.gd")
class ObservedSound:
 extends "res://src/audio/soundscape.gd"
 var switches=[]
 func play(cue:String,relative_position:Vector2=Vector2.ZERO)->void:
  if cue=="plant_switch" and cues.has(cue) and not muted and not system_suspended:switches.append(relative_position)
  super.play(cue,relative_position)
var checks=0
var failures=0
func check(ok:bool,label:String):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():call_deferred("run")
func run():
 var sound=ObservedSound.new();root.add_child(sound)
 check(sound.cues.has("plant_switch"),"accepted plant controls have a registered local console cue")
 var samples=Sound.samples("plant_switch");var energy=0.;var peak=0.
 for sample in samples:energy+=sample*sample;peak=maxf(peak,absf(sample))
 check(samples.size()<Sound.RATE*.5 and peak<.5 and energy>.01 and samples!=Sound.samples("record"),"plant switch is a short generated mechanical confirmation with clipping headroom")
 var sim=Sim.new();sim.start(10);sim.sirens=[];sim.units[0].pos=Vector2(480,1055);sim.units[0].vel=Vector2.ZERO
 check(sim.command("chain_power",{"mode":"connect"}),"actual paused local connection is accepted")
 sound.update(sim,0.,true)
 check(sound.switches==[Vector2.ZERO] and sim.events.is_empty(),"accepted plant event dispatches once as centered console feedback, not remote machinery location")
 check(sound.voices.filter(func(v):return v.stream==sound.cues.get("plant_switch")).all(func(v):return v.stream_paused),"tactical pause freezes any newly dispatched plant cue")
 sound.update(sim,0.,true);check(sound.switches.size()==1,"paused refresh cannot replay a consumed plant event")
 check(not sim.command("chain_send"),"remote unconfigured SEND remains rejected")
 sound.update(sim,0.,true);check(sound.switches.size()==1,"rejected control has no accepted-switch sound")
 for mode in ["disconnect","backup"]:
  sim.command("chain_power",{"mode":mode});sound.update(sim,0.,true)
 sim.units[0].pos=Vector2(1520,1055);sim.command("chain_route",{"output":"service"});sound.update(sim,0.,true);sim.command("chain_send");sound.update(sim,0.,true)
 check(sound.switches.size()==5 and sound.switches.all(func(pos):return pos==Vector2.ZERO),"disconnect, backup, selection and SEND each acknowledge only their own accepted console operation")
 check(sim.acoustic_feedback().pulses.any(func(p):return p.label=="SERVICE WARNING" and p.pos==Vector2(1520,1000)) and sim.acoustic_feedback().pulses.any(func(p):return p.label=="BACKUP GENERATOR START" and p.pos==Vector2(480,1000)),"audible world footprints retain actual public plant hardware origins independently of console feedback")
 sim.paused=false;sound.update(sim,0.,true)
 check(sound.voices.all(func(v):return not v.stream_paused),"normal running resumes paused console voices")
 sound.muted=true;sim.events.append({"type":"plant_control","action":"disconnect","unit":0,"pos":sim.units[0].pos});sound.update(sim,0.,true)
 check(sound.switches.size()==5 and sim.events.is_empty(),"muted plant feedback stays muted and never queues a late acceptance sound")
 sound.suspend();sound.update(sim,0.,true);check(sound.engine.stream_paused and sound.voices.filter(func(v):return v.playing).all(func(v):return v.stream_paused),"application suspension still freezes all plant and ordinary voices")
 sound.queue_free();sim=null;await process_frame
 print("WARNING CHAIN AUDIO CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
