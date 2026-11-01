extends SceneTree
const Sim=preload("res://src/simulation/simulation.gd")
const Routes=preload("res://tests/campaign_scenarios.gd")
var checks=0
var failures=0
func check(ok:bool,label:String):
 checks+=1
 if not ok:failures+=1;print("FAIL ",label)
func fresh_wall(side:int,velocity:float=0.0,unit_id:int=0):
 var s=Sim.new();s.start(0);s.sirens=[];s.mission.rocks=[];s.mission.structures=[Rect2(300,300,200,200)];s._build_navigation()
 var u=s.units[unit_id];u.pos=Vector2(530 if side==1 else 270,350);u.angle=PI if side==1 else 0.0;u.vel=Vector2(-side*velocity,0);u.silent=unit_id==0
 s.selected=unit_id;s.paused=false
 return s
func drive(s,steps:int=300):
 for n in steps:
  s.advance(0.1)
  if s.units[s.selected].route.is_empty() and s.units[s.selected].vel.length()<2:break
func _initialize():
 var s=Sim.new();s.start(2,"disruption");s.units[1].alive=false;s.units[2].alive=false
 var setup=true
 for id in [0,1]:
  setup=setup and Routes.move(s,s.mission.objectives[id].pos+Vector2(0,140));setup=setup and s.command("camera")
  for n in 45:
   s.advance(0.1)
   for contact in s.contacts.values():
    if s.elapsed-contact.time<.3 and contact.lock>1.0 and s.tools.emp>0:s.command("emp");break
 check(setup and s.all_records(),"ordinary forward-order solo records acquired")
 for arg in OS.get_cmdline_user_args():
  if arg.begins_with("--save-fixture="):
   var f=FileAccess.open(arg.trim_prefix("--save-fixture="),FileAccess.WRITE);f.store_var(s.snapshot());f.close()
 print("ORDINARY_DEPARTURE_INITIAL time=",s.elapsed," pos=",s.units[0].pos," angle=",s.units[0].angle," tools=",s.tools)
 var returned=Routes.move(s,s.mission.extraction)
 check(returned and s.outcome=="won","same ordinary forward-order solo route returns home")
 print("ORDINARY_DEPARTURE_FINAL won=",s.outcome=="won"," time=",s.elapsed," pos=",s.units[0].pos," hull=",s.hull," tools=",s.tools," message=",s.message)
 for side in [-1,1]:
  for unit_id in [0,1]:
   for velocity in [0.0,8.0]:
    var w=fresh_wall(side,velocity,unit_id);var u=w.units[unit_id];var target=Vector2(u.pos.x,180)
    check(w.command("route",{"point":target}),"wall fixture accepts safe route")
    if velocity>0:
     var before=u.pos;var heading=u.angle;w.advance(1.0/60)
     check(u.vel.length()>0 and u.vel.length()<velocity and u.pos!=before and absf(angle_difference(heading,u.angle))<=1.8/60+0.00001,"risky turn brakes gradually while retaining physical turn rate")
    drive(w)
    check(u.pos.distance_to(target)<20 and u.vel.length()<2,"safe near-wall turn completes side%d unit%d residual%.1f"%[side,unit_id,velocity])
    check(not w.blocked(u.pos,12),"hull never ends inside wall")
    print("WALL_FINAL side=",side," unit=",unit_id," residual=",velocity," time=",w.elapsed," pos=",u.pos," message=",w.message)
 # A full reversal on either side of a wall must retain its clear planned route.
 for side in [-1,1]:
  for unit_id in [0,1]:
   var w=Sim.new();w.start(0);w.sirens=[];w.mission.rocks=[];w.mission.structures=[Rect2(300,400 if side==1 else 200,200,100)];w._build_navigation()
   var u=w.units[unit_id];u.pos=Vector2(450,370 if side==1 else 330);u.angle=side*0.01;w.selected=unit_id;w.paused=false
   var target=Vector2(220,u.pos.y);check(w.command("route",{"point":target}),"reversal route is terrain-safe")
   drive(w);check(u.pos.distance_to(target)<20,"near-wall reversal completes turn%d unit%d"%[side,unit_id])
   print("REVERSAL_FINAL side=",side," unit=",unit_id," time=",w.elapsed," pos=",u.pos," message=",w.message)
 # Open-water steering must remain exactly comparable to accepted source.
 var open_trace=[]
 for unit_id in [0,1]:
  for silent in [true,false]:
   var w=Sim.new();w.start(0);w.sirens=[];w.mission.rocks=[];w.mission.structures=[];w._build_navigation();w.selected=unit_id;w.paused=false
   var u=w.units[unit_id];u.pos=Vector2(800,480);u.angle=2.0;u.silent=silent;w.command("route",{"point":Vector2(1050,400)})
   for n in 80:w.advance(0.1);open_trace.append([u.pos.x,u.pos.y,u.vel.x,u.vel.y,u.angle,u.route.size()])
 print("OPEN_WATER_TRACE_SHA256 ",JSON.stringify(open_trace).sha256_text())
 # Momentum too large for braking room must still stop rather than tunnel or retain an unsafe route.
 # 127 (Pat 2026-10-30): the safety stop is the dev/test route path; release play crashes.
 var crash=fresh_wall(1,78.0);crash.command("route",{"point":Vector2(530,180)});drive(crash)
 check(crash.hull<100.0 and "Hull strike" in crash.message and not crash.blocked(crash.units[0].pos,12),"release play: unavoidable inertial contact is a costly hull strike outside rock")
 var unsafe=fresh_wall(1,78.0);unsafe.mission["dev"]=true;unsafe.command("route",{"point":Vector2(530,180)});drive(unsafe)
 print("UNAVOIDABLE_STOP time=",unsafe.elapsed," pos=",unsafe.units[0].pos," vel=",unsafe.units[0].vel," message=",unsafe.message)
 check(unsafe.units[0].route.is_empty() and "unsafe terrain" in unsafe.message and unsafe.units[0].name in unsafe.message and not unsafe.blocked(unsafe.units[0].pos,12),"unavoidable inertial collision retains physical safety stop")
 var paused=fresh_wall(1);paused.command("route",{"point":Vector2(530,180)});paused.paused=true;var snap=paused.snapshot();paused.advance(10)
 check(paused.snapshot()==snap,"pause preserves route inertia resources and time")
 var restored=Sim.new();check(restored.restore(snap),"existing snapshot restores maneuver state")
 paused.paused=false;restored.paused=false;paused.advance(0.2);restored.advance(0.2)
 check(paused.snapshot()==restored.snapshot(),"restore produces identical future maneuver")
 # Replacement is accepted while turning; queued endpoint/pass intent survives the controller.
 var e=fresh_wall(1);e.command("route",{"point":Vector2(530,180)});e.advance(0.2);e.command("queue");e.command("emergency",{"point":Vector2(700,350)});drive(e)
 check(e.units[0].pos.distance_to(Vector2(700,350))<20,"emergency replacement overrides near-wall turn")
 var q=fresh_wall(1);q.command("route",{"point":Vector2(530,180)});q.command("queue");q.command("route",{"point":Vector2(700,180)})
 var routes=q.units[0].route.duplicate(true);check(routes.size()==2 and not routes[0].stop and routes[1].stop,"explicit queued pass and stop intent retained");drive(q,600)
 check(q.units[0].pos.distance_to(Vector2(700,180))<20,"queued near-wall departure reaches final stop")
 # Same kinematic input through the enemy-call boundary is saved for exact baseline comparison.
 var trace=[];var enemy=fresh_wall(1);var actor=enemy.units[0].duplicate(true);actor.route=[{"pos":Vector2(530,180),"stop":true}]
 for n in 180:enemy._move(actor,1.0/60,96.0,false,false);trace.append([actor.pos.x,actor.pos.y,actor.vel.x,actor.vel.y,actor.angle,actor.route.size()])
 print("ENEMY_TRACE_SHA256 ",JSON.stringify(trace).sha256_text())
 print("NAVIGATION CHECKS ",checks," FAILURES ",failures)
 quit(1 if failures else 0)
