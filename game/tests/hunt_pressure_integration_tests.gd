extends SceneTree
const Sim=preload("res://src/simulation/simulation.gd")
const Hunt=preload("res://src/simulation/hunt_pressure/hunt_pressure.gd")
const Table=preload("res://src/simulation/hunt_pressure/hunt_table.gd")
const Store=preload("res://src/persistence/save_store.gd")
const AITrace=preload("res://src/diagnostics/ai_trace.gd")
const TraceTable=preload("res://src/diagnostics/ai_trace_table.gd")
const Soundscape=preload("res://src/audio/soundscape.gd")
const Pricing=preload("res://src/simulation/photo_pricing/photo_pricing.gd")
const Photo=preload("res://src/simulation/photo_capture.gd")
class CueSound:
 extends "res://src/audio/soundscape.gd"
 var played=[]
 func play(cue:String,relative_position:Vector2=Vector2.ZERO)->void:
  played.append(cue)
  super.play(cue,relative_position)
var checks=0
var failures=0
func check(ok:bool,label:String)->void:
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func fixture(on:bool,distance:float=350.):
 Table.enabled=on
 var s=Sim.new();s.start(22,"endurance")
 s.mission.rocks=[];s.mission.structures=[];s._build_navigation();s._configure_terrain();s._configure_depth_charts()
 for u in s.units:u.alive=false
 s.units[0].alive=true;s.units[0].pos=Vector2(300,500)
 var e=s.sirens[0].duplicate(true);e.pos=s.units[0].pos+Vector2(distance,0);e.home=e.pos;e.goal=e.pos;e.type="sentinel";e.route=[];e.patrol_points=[];e.stun=0.;e.lock=0.;e.target=-1;e.band=s.units[0].band;e.transition={}
 s.sirens=[e];s.mission.reconnaissance={"hunt":95.,"floor":0.,"delay":0.,"secured":[]}
 return s
func _initialize()->void:
 Table.enabled=true
 var s=Sim.new();s.start(22)
 check(Hunt.active(s.mission),"fresh operation opts in")
 s._noise(s.units[0].pos,100.,"DECOY")
 check(s.Recon.state(s.mission).hunt==0.,"actual decoy noise path adds no Hunt")
 s._noise(s.units[0].pos,100.,"RECON UPLINK")
 check(s.Recon.state(s.mission).hunt==0.,"actual survey noise path adds no Hunt")
 s._noise(s.units[0].pos,100.,"ACTIVE SONAR")
 check(s.Recon.state(s.mission).hunt==5.,"actual sonar noise path adds five")
 var saved=s.snapshot();var restored=Sim.new()
 check(Sim.valid_snapshot(saved) and restored.restore(saved),"new mission state validates/restores")
 if saved.mission.has("hunt_pressure"):
  var bad=saved.duplicate(true);bad.mission.hunt_pressure.seen=1
  check(not Sim.valid_snapshot(bad),"optional validator rejects corrupt boolean")
 else:check(false,"optional validator has a real field to validate")
 var legacy=saved.duplicate(true);legacy.mission.erase("hunt_pressure")
 var old=Sim.new();check(old.restore(legacy) and not Hunt.active(old.mission),"absent optional field remains inactive after restore")
 var old_hunt=old.Recon.state(old.mission).hunt;old._noise(old.units[0].pos,100.,"DECOY")
 check(old.Recon.state(old.mission).hunt==old_hunt+4.,"legacy action amount stays four")
 var a=fixture(true);var b=fixture(false)
 a.units[0].vel=Vector2(78,0);b.units[0].vel=Vector2(78,0)
 Table.enabled=true;a._threats(Sim.STEP)
 Table.enabled=false;b._threats(Sim.STEP)
 check(a.sirens==b.sirens and a.hull==b.hull,"high Hunt leaves actual hearing and movement identical beyond sight")
 a=fixture(true,250.);b=fixture(false,250.)
 Table.enabled=true;a._threats(Sim.STEP)
 Table.enabled=false;b._threats(Sim.STEP)
 check(a.sirens[0].lock>0 and b.sirens[0].lock==0,"eligible sight extends while legacy sight does not")
 a=fixture(true,100.);b=fixture(false,100.)
 for n in 80:
  Table.enabled=true;a._threats(Sim.STEP)
  Table.enabled=false;b._threats(Sim.STEP)
 check(a.sirens==b.sirens and a.hull==b.hull and a.outcome==b.outcome,"same acquired target retains identical lock/beam/damage and movement")
 Table.enabled=true
 var save_source=Sim.new();save_source.start(0);save_source.Recon.action(save_source.mission,45.)
 Hunt.observe(save_source,Sim.STEP);var save_snapshot=save_source.snapshot()
 var disk=Store.new();disk.path="user://hunt-roundtrip.save"
 var envelope={"version":1,"unlocked":0,"completed":[],"upgrade":"endurance","settings":{},"active":save_snapshot}
 check(disk.save(envelope),"existing on-disk save path accepts Hunt")
 var disk_copy=Sim.new();var stored=disk.load_game()
 check(stored.has("active") and disk_copy.restore(stored.active) and disk_copy.mission==save_snapshot.mission,"existing save codec preserves owned metadata")
 action_paths()
 photo_paths()
 timer_and_replay()
 malformed_snapshots()
 await cue_audio_trace()
 sight_edge_before_emp()
 photo_completion_trace_cause()
 Table.enabled=true
 print("HUNT INTEGRATION CHECKS ",checks," FAILURES ",failures)
 quit(1 if failures else 0)
func action_paths()->void:
 Table.enabled=true
 var s=Sim.new();s.start(22,"endurance")
 var base:float=s.Recon.state(s.mission).hunt
 check(s.command("ping") and is_equal_approx(s.Recon.state(s.mission).hunt,base+5.),"real active sonar command adds five")
 base=s.Recon.state(s.mission).hunt
 check(s.command("emp") and is_equal_approx(s.Recon.state(s.mission).hunt,base+4.),"real EMP command adds four")
 base=s.Recon.state(s.mission).hunt
 check(s.command("decoy",{"point":s.units[0].pos}) and is_equal_approx(s.Recon.state(s.mission).hunt,base),"real decoy spends a charge without Hunt rise")
 base=s.Recon.state(s.mission).hunt
 check(s.command("recon") and is_equal_approx(s.Recon.state(s.mission).hunt,base),"real survey spends a charge without Hunt rise")
 var knock=fixture(true,120.)
 knock.units[0].angle=0.;knock._observe()
 base=knock.Recon.state(knock.mission).hunt
 check(knock.command("knock",{"target":0}) and is_equal_approx(knock.Recon.state(knock.mission).hunt,base+4.),"real acquired knockdown launch adds four")
 var legacy=Sim.new();legacy.start(22,"endurance");legacy.mission.erase("hunt_pressure")
 var disabled=Sim.new();Table.enabled=false;disabled.start(22,"endurance");Table.enabled=true
 for pair in [[legacy,"legacy"],[disabled,"flag off"]]:
  var x=pair[0];var label:String=pair[1]
  var initial:float=x.Recon.state(x.mission).hunt
  check(x.command("decoy",{"point":x.units[0].pos}) and x.command("recon") and is_equal_approx(x.Recon.state(x.mission).hunt,initial+8.),"%s real quiet tools retain legacy Hunt amounts"%label)
  check(not Hunt.active(x.mission),"%s action remains opt-out"%label)
func photo_paths()->void:
 Table.enabled=true
 var spire=Vector2(1300,300);var facing=2.74
 var usable=Sim.new();usable.start(0,"endurance");usable.sirens=[]
 usable.units[0].pos=spire+Vector2.from_angle(facing)*110.;usable.units[0].angle=facing+PI;usable.units[0].vel=Vector2.ZERO
 check(usable.command("camera"),"real opening photograph begins through player command")
 usable.paused=false
 for n in 360:usable.advance(Sim.STEP)
 var good=usable.Recon.state(usable.mission)
 check(usable.mission.objectives[0].captured and good.floor==8. and good.hunt>=8.,"real secured photo adds eight and establishes earned floor")
 for n in 1800:usable.advance(Sim.STEP)
 good=usable.Recon.state(usable.mission)
 check(is_equal_approx(good.hunt,8.) and good.floor==8.,"actual operation clock cools to secured-photo floor and stops there")
 var unusable=Sim.new();unusable.start(0,"endurance");unusable.sirens=[]
 unusable.units[0].pos=spire+Vector2.from_angle(facing+PI)*230.;unusable.units[0].angle=facing;unusable.units[0].vel=Vector2.ZERO
 unusable.command("frame",{"mode":"tight","focus":"drill"})
 check(unusable.command("camera"),"real wrong-aspect photograph begins through player command")
 unusable.paused=false
 for n in 360:unusable.advance(Sim.STEP)
 var bad=unusable.Recon.state(unusable.mission)
 check(not unusable.mission.objectives[0].captured and Photo.peek(unusable).shots.size()==1 and not Photo.peek(unusable).shots[0].usable and bad.floor==0. and bad.hunt>=3.,"real unusable photo adds three without secured-record floor")
 var viewed=null;var ring={}
 for op in [3,4,5,8,10,12,14,15,18,19]:
  var candidate=Sim.new();candidate.start(op,"endurance")
  if candidate.sirens.is_empty() or Hunt.view(candidate).cap<=1.:continue
  for target in candidate.mission.objectives:
   if not Photo.applies(target):continue
   candidate.units[0].pos=target.pos+Vector2(100,0);candidate.units[0].angle=PI;candidate.units[0].vel=Vector2.ZERO
   candidate.sirens[0].type="sentinel"
   candidate.contacts[0]={"pos":candidate.sirens[0].pos,"band":candidate.units[0].band,"time":candidate.elapsed}
   candidate.Recon.action(candidate.mission,95.,"ACTIVE SONAR")
   ring=Pricing.chart_rings(candidate)
   if not ring.is_empty() and not ring.sirens.is_empty():viewed=candidate;break
  if viewed!=null:break
 check(not ring.is_empty() and not ring.sirens.is_empty(),"photo chart quotes a currently held public Siren contact")
 if not ring.is_empty() and not ring.sirens.is_empty():
  var observed_r:float=ring.sirens[0].r
  var expected_factor:float=Hunt.view(viewed).scale
  Table.enabled=false
  var old_ring=Pricing.chart_rings(viewed)
  Table.enabled=true
  check(not old_ring.is_empty() and is_equal_approx(observed_r/old_ring.sirens[0].r,expected_factor),"photo chart radius matches capped sight factor for observed contact")
func timer_and_replay()->void:
 Table.enabled=true
 var s=Sim.new();s.start(22,"endurance")
 s.Recon.action(s.mission,45.,"ACTIVE SONAR")
 Hunt.observe(s,Sim.STEP)
 s.events.clear() # Presentation has consumed pre-save cues; event queue is not saved.
 var shot=s.snapshot();var copy=Sim.new()
 check(Sim.valid_snapshot(shot) and copy.restore(shot),"pending stage and cue clock snapshot restores")
 var before=s.mission.hunt_pressure.duplicate(true)
 check(copy.mission.hunt_pressure==before,"restore retains pending, cause, stage and cue clock")
 s.paused=false;copy.paused=false
 for n in 12:s.advance(.25);copy.advance(.25)
 check(s.mission.hunt_pressure==copy.mission.hunt_pressure and s.mission.reconnaissance==copy.mission.reconnaissance,"saved forward clock and owned state replay deterministically")
 check(s.events.filter(func(e):return e.type=="hunt_stage")==copy.events.filter(func(e):return e.type=="hunt_stage"),"saved forward stage-cue events replay deterministically")
 var p=s.Recon.state(s.mission)
 check(is_equal_approx(p.delay,3.) and is_equal_approx(p.hunt,45.6),"three real seconds preserve delayed pressure and time nudge")
 for n in 24:s.advance(.25)
 p=s.Recon.state(s.mission)
 check(is_equal_approx(p.delay,0.) and p.hunt>43. and p.hunt<44.,"six-second delay expires before cooling")
 for n in 8:s.advance(.25)
 p=s.Recon.state(s.mission)
 check(p.hunt<46. and p.hunt>=p.floor,"post-delay clock cools without crossing floor")
func malformed_snapshots()->void:
 Table.enabled=true
 var s=Sim.new();s.start(22,"endurance")
 s.Recon.action(s.mission,0.,"ACTIVE SONAR")
 var valid=s.snapshot()
 for pair in [["revision",2],["stage",5],["seen",1],["cause",123],["cause","HIDDEN"],["pending",1],["stage_cause","HIDDEN"],["cue_at",NAN],["cue_at",INF]]:
  var bad=valid.duplicate(true);bad.mission.hunt_pressure[pair[0]]=pair[1]
  check(not Sim.valid_snapshot(bad),"snapshot validator rejects owned %s=%s"%[pair[0],str(pair[1])])
 for pair in [["hunt",NAN],["hunt",INF],["floor",NAN],["delay",INF]]:
  var bad=valid.duplicate(true);bad.mission.reconnaissance[pair[0]]=pair[1]
  check(not Sim.valid_snapshot(bad),"snapshot validator rejects nonfinite pressure "+pair[0])
func cue_audio_trace()->void:
 Table.enabled=true;TraceTable.enabled=true
 var s=Sim.new();s.start(22,"endurance")
 var recorder=AITrace.attach(s,false,{"event_cap":1})
 var before=s.snapshot()
 AITrace.sample(recorder,s)
 check(s.snapshot()==before,"attached trace sample does not mutate simulation")
 s.Recon.action(s.mission,25.,"ACTIVE SONAR");Hunt.observe(s,Sim.STEP);AITrace.sample(recorder,s)
 check(recorder.get("hunt_events",[]).size()==1 and recorder.hunt_events[0].cause=="active sonar","attached trace records first own-cause Hunt rise")
 s.Recon.action(s.mission,50.,"DISRUPTION");Hunt.observe(s,Sim.STEP);AITrace.sample(recorder,s)
 check(recorder.hunt_events.size()==1 and recorder.dropped>=1 and recorder.hunt_events[0].cause=="Disrupt","attached trace ring bounds later owned cause")
 AITrace.detach(recorder,s);TraceTable.enabled=false
 var sound=CueSound.new();get_root().add_child(sound)
 await process_frame
 sound.update(s,Sim.STEP,true)
 check(is_equal_approx(sound.ambience.volume_db,-12.9),"HUNTING stage ambience uses public stage offset")
 check(s.events.is_empty() and "hunt_stage" in sound.played and sound.cues.has("hunt_stage"),"public stage-up event dispatches generated Soundscape cue")
 var plays:int=sound.played.count("hunt_stage")
 s.Recon.action(s.mission,20.,"ACTIVE SONAR");Hunt.observe(s,Sim.STEP)
 check(s.events.filter(func(e):return e.type=="hunt_stage").is_empty(),"stage rise inside three seconds does not enqueue second cue")
 # Controlled public-clock fixture: cool to the SEARCHING boundary, then rise.
 s.elapsed=3.1;s.mission.reconnaissance.hunt=69.;Hunt.observe(s,Sim.STEP)
 s.Recon.action(s.mission,1.,"ACTIVE SONAR");Hunt.observe(s,Sim.STEP)
 check(s.events.filter(func(e):return e.type=="hunt_stage").size()==1,"later stage rise queues one public cue")
 s.paused=true;sound.update(s,Sim.STEP,true)
 check(sound.played.count("hunt_stage")==plays+1 and sound.voices.all(func(v):return not v.playing or v.stream_paused) and sound.voices.any(func(v):return v.stream==sound.cues.hunt_stage and v.stream_paused),"paused Soundscape dispatches earned cue but freezes active playback")
 for voice in sound.voices:voice.stop()
 sound.muted=true;sound.play("hunt_stage")
 check(sound.voices.all(func(v):return not v.playing),"muted stage cue starts no voice")
 sound.muted=false;sound.suspend();s.events.append({"type":"hunt_stage","stage":4,"cause":"ACTIVE SONAR"});plays=sound.played.count("hunt_stage");sound.update(s,Sim.STEP,true)
 check(sound.system_suspended and s.events.is_empty() and sound.played.count("hunt_stage")==plays and sound.voices.all(func(v):return not v.playing),"suspension discards stage cue and blocks playback")
 sound.queue_free()
func sight_edge_before_emp()->void:
 Table.enabled=true
 var s=fixture(true,100.)
 s.mission.reconnaissance={"hunt":0.,"floor":0.,"delay":0.,"secured":[]}
 s.paused=false
 var acquired=false
 for n in 120:
  s.advance(Sim.STEP)
  if s.sirens[0].target==0 and s.sirens[0].lock>0.:
   acquired=true;break
 check(acquired,"actual Sim.advance creates first visual acquisition")
 if not acquired:return
 var before:float=s.Recon.state(s.mission).hunt
 s.paused=true
 check(s.command("emp"),"immediate paused EMP is accepted after first visual acquisition")
 var after:float=s.Recon.state(s.mission).hunt
 check(before>=6. and after>=before+4.-0.001,"first real sight edge survives immediate paused EMP clearing target")
func photo_completion_trace_cause()->void:
 Table.enabled=true;TraceTable.enabled=true
 var s=Sim.new();s.start(0,"endurance");s.sirens=[]
 var spire=Vector2(1300,300);var facing=2.74
 s.units[0].pos=spire+Vector2.from_angle(facing)*110.;s.units[0].angle=facing+PI;s.units[0].vel=Vector2.ZERO
 s.Recon.action(s.mission,18.5,"ACTIVE SONAR")
 check(s.command("camera"),"real usable opening exposure starts before trace threshold")
 s.paused=false
 for n in 220:s.advance(Sim.STEP)
 check(not s.mission.objectives[0].captured and Hunt.view(s).index==0,"trace attaches before real photo completes and before stage rise")
 var rec=AITrace.attach(s,false,{"event_cap":8})
 for n in 100:AITrace.step(rec,s,Sim.STEP)
 check(s.mission.objectives[0].captured and rec.get("hunt_events",[]).size()==1,"real photo completion crosses the public Hunt stage boundary")
 if rec.get("hunt_events",[]).size()==1:check(rec.hunt_events[0].cause=="secured record","attached trace attributes same-step stage rise to secured record")
 AITrace.detach(rec,s);TraceTable.enabled=false
