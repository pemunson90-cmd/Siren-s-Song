extends SceneTree
const Sim=preload("res://src/simulation/simulation.gd")
const Store=preload("res://src/persistence/save_store.gd")
func _initialize():
 var s=Sim.new();s.start(0);s.sirens=[];s.mission.rocks=[];s.mission.structures=[Rect2(300,300,400,500),Rect2(760,300,400,500)];s._build_navigation();s.paused=false
 var u=s.units[0];u.pos=Vector2(730,260);u.angle=PI/2;u.vel=Vector2(0,8)
 var initial=s.command("route",{"point":Vector2(730,200)});s.advance(0.2);s.command("queue");s.command("contact_hold")
 var accepted=s.command("emergency",{"point":Vector2(1250,250)})
 var intent_cleared=not s.queue_mode and u.hold=="" and not u.silent
 # An actual archive round trip while the maneuver is incomplete.
 s.paused=true;var snapshot=s.snapshot();s.advance(500);var pause_equal=s.snapshot()==snapshot
 var store=Store.new();store.path="user://nav-turn.archive";var data={"version":1,"unlocked":0,"completed":[],"upgrade":"endurance","settings":{},"active":snapshot};var saved=store.save(data);var loaded=store.load_game();var r=Sim.new();var restored=not loaded.is_empty() and r.restore(loaded.active)
 var equal=true;s.paused=false;r.paused=false
 for n in 500:
  s.advance(0.1);r.advance(0.1)
  equal=equal and s.units==r.units and s.elapsed==r.elapsed and s.oxygen==r.oxygen
  if s.units[0].route.is_empty() and s.units[0].vel.length()<2:break
 print("HUNTER_EMERGENCY initial=",initial," accepted=",accepted," cleared_intent=",intent_cleared," pause_equal=",pause_equal," actual_saved=",saved," restored=",restored," future_kinematics_equal=",equal," reached=",u.pos.distance_to(Vector2(1250,250))<20," time=",s.elapsed," pos=",u.pos," route=",u.route," message=",s.message)
 quit(0 if accepted and intent_cleared and pause_equal and saved and restored and equal and u.pos.distance_to(Vector2(1250,250))<20 else 1)
