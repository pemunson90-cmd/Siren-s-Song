extends SceneTree
const Sim=preload("res://src/simulation/simulation.gd")
var checks=0
var failures=0
func check(ok:bool,label:String)->void:
 checks+=1
 if not ok:failures+=1;printerr("FAIL: ",label)
func advance(s,seconds:float)->void:
 s.paused=false
 for n in roundi(seconds*60):s.advance(Sim.STEP)
func _initialize()->void:
 var s=Sim.new();s.start(8)
 check(s.mission.has("shelf_habitat"),"Shelf Return contains occupied galleries with physical warning/response state")
 check(s.command("shelf_alarm")==false,"remote alarm cannot be operated from the launch basin")
 check(not s.all_records(),"the old fixed receiver flag cannot replace warning actual occupied galleries")
 if not s.mission.has("shelf_habitat"):
  print("SHELF HABITAT CHECKS ",checks," FAILURES ",failures);quit(1);return
 var Habitat=load("res://src/simulation/shelf_habitat.gd")
 s.sirens=[];s.units[0].pos=Habitat.ALARM+Vector2(0,40);advance(s,.2);s.paused=true
 check(s.command("shelf_alarm"),"local settled Quietus can sound the common alarm")
 check(s.mission.shelf_habitat.warned_at.size()==2 and not s.all_records(),"actual outward arrivals warn both galleries, but acknowledgement is still separate")
 var paused=s.snapshot();s.advance(8)
 check(s.snapshot()==paused,"pause cannot advance residents or earn a reply")
 advance(s,2.7)
 check(s.all_records() and s.mission.shelf_habitat.receipts.size()==2,"actual local returns secure both shelter acknowledgements")
 check(not s.command("shelf_alarm"),"finite common alarm cannot be farmed as an unlimited lure")
 check(Sim.valid_snapshot(s.snapshot()),"ordinary current habitat state is a valid active save")
 var restored=Sim.new();check(restored.restore(s.snapshot()) and restored.mission.shelf_habitat==s.mission.shelf_habitat,"resident response and received proofs restore without replaying work")
 var quiet=Sim.new();quiet.start(8);quiet.sirens=[]
 for id in [1,2]:quiet.units[id].alive=false
 quiet.tools={"emp":0,"knock":0,"decoy":0,"recon":0}
 for site in Habitat.GALLERIES:
  quiet.units[0].pos=site.pos+Vector2(0,55);quiet.units[0].vel=Vector2.ZERO;advance(quiet,.2);quiet.paused=true
  check(quiet.command("shelf_warn",{"site":site.id}),"bare Quietus locally warns "+site.id)
  advance(quiet,2.7)
 check(quiet.all_records() and not quiet.mission.shelf_habitat.alarm_used,"two close quiet visits complete without drone, fittings or finite tools")
 var far=Sim.new();far.start(8);far.sirens=[];far.units[0].pos=Habitat.ALARM+Vector2(0,40);advance(far,.2)
 far.units[0].pos=Vector2(2200,2200)
 advance(far,3)
 check(far.mission.shelf_habitat.seen.is_empty(),"remote passage of time cannot reveal gallery activity")
 var old=quiet.snapshot();old.mission.erase("shelf_habitat")
 check(not Sim.valid_snapshot(old),"old incompatible active Shelf operation rejects cleanly rather than inventing inhabitant work")
 var guard=Sim.new();guard.start(8);guard.units[0].pos=Habitat.ALARM+Vector2(0,40);advance(guard,.2)
 check(guard.sirens[0].target==-1 and guard.command("shelf_alarm"),"common call starts without an invented visual lock")
 advance(guard,1)
 check(guard.sirens[0].mode=="INVESTIGATE" and guard.sirens[0].goal.distance_to(Habitat.ALARM)<90,"common alarm actually draws the authored hunter toward its heard source")
 var front=Sim.new();front.start(8);front.sirens=[];front.units[1].pos=Vector2(540,1600)
 var target=Vector2(840,1600)
 check(front.line_clear(front.units[1].pos,target) and front.visible(target),"optical truth stays clear across the exhaust front")
 check(1 not in front.passive_receivers(target) and front.acoustic_paths.arrivals(front.units[1].pos,target,700).is_empty(),"exhaust physically attenuates passive contact and emitted sound across it")
 front.mission.thermal_fronts=[];front.acoustic_paths.thermal_fronts=[]
 check(1 in front.passive_receivers(target) and not front.acoustic_paths.arrivals(front.units[1].pos,target,700).is_empty(),"matched clear water restores the same actual contact and sound arrival")
 var bent=Sim.new();bent.start(8);bent.sirens=[];bent.units[0].pos=Vector2(900,1150)
 bent.mission.shelf_habitat.warned_at.west=0.0;bent.mission.shelf_habitat.methods.west="local"
 var arrivals=bent.acoustic_paths.arrivals(bent.units[0].pos,Habitat.GALLERIES[0].pos,850)
 check(not arrivals.is_empty() and not arrivals[0].direct,"shelter reply fixture follows a real bent water path")
 advance(bent,3)
 var events=bent.events.filter(func(event):return event.type=="return_received")
 check(not events.is_empty() and events[0].direction.distance_to(bent.units[0].pos.direction_to(arrivals[0].goal))<.01,"received reply cue uses its actual arrival bearing rather than a hidden through-rock source vector")
 var stale=Sim.new();stale.start(8);stale.sirens=[];stale.units[0].pos=Vector2(560,1055);advance(stale,.2)
 stale.units[0].pos=stale.mission.start;advance(stale,.3)
 var before_private=stale.shelf_context()
 stale.mission.shelf_habitat.warned_at.west=stale.elapsed;stale.mission.shelf_habitat.methods.west="common"
 check(stale.shelf_context()==before_private,"unobserved remote delivery cannot advance old gallery graphics or expose private resident state through action readiness")
 print("SHELF HABITAT CHECKS ",checks," FAILURES ",failures)
 quit(1 if failures else 0)
