extends SceneTree
const Sim=preload("res://src/simulation/simulation.gd")
const Program=preload("res://src/simulation/route_program.gd")
var checks=0
var failures=0
func check(ok:bool,label:String):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func displaced():
 # Compact physics fixture derived from the unmodified earned Well28.5 save.
 # Actual full archive/threat replay stays external; this isolates course following.
 var s=Sim.new();s.start(4);s.sirens=[]
 var u=s.units[0];u.pos=Vector2(1345.6011,627.011);u.angle=-3.28410774866213;u.vel=Vector2(-41.5742,5.96539)
 s.command("route",{"point":Vector2(140,800)})
 # Restore the accepted pre-turn leg; replotted routes already avoid this obstacle.
 u.route=[{"pos":Vector2(140,800),"stop":true,"goal":true,"mode":"inherit"}]
 return s
func _initialize():
 var s=displaced();var u=s.units[0];var goal=s.route_goals();var undo=u.get("route_undo",[]).duplicate(true)
 check(not s.segment_safe(u.pos,u.route[0].pos,12),"earned displaced leg is physically obstructed despite retained accepted endpoint")
 var before=s.snapshot();s.advance(1);check(s.snapshot()==before,"pause does not repair or change a saved course")
 s.paused=false;var pos=u.pos;var vel=u.vel;var angle=u.angle;s.advance(1.0/60)
 check(u.route.size()>1 and s.segment_safe(u.pos,u.route[0].pos,12),"unpause repairs the displaced leg through known clear water before terrain stop")
 check(s.route_goals()==goal and u.get("route_undo",[])==undo,"course repair preserves operator endpoint and undo history")
 check(pos.distance_to(u.pos)<=vel.length()/60+42.0/3600+0.001 and u.vel.distance_to(vel)<=42.0/60+0.0001 and absf(angle_difference(angle,u.angle))<=1.8/60+0.0001,"repair retains physical displacement acceleration and turn limit")
 var copy=Sim.new();var snap=s.snapshot();snap.paused=true;check(copy.restore(snap) and copy.snapshot()==snap,"repaired course restores paused without migration");copy.paused=false
 var safe=true
 for n in 2400:
  s.advance(1.0/60);copy.advance(1.0/60);safe=safe and not s.blocked(u.pos,12)
  if u.route.is_empty() and u.vel.length()<2:break
 check(safe and u.pos.distance_to(Vector2(140,800))<20 and u.vel.length()<2,"same accepted destination completes without collision or another player order")
 check(copy.snapshot()==s.snapshot(),"restore preserves identical repair continuation")
 # A new straight leg may become obstructed while the craft makes a real turn.
 var turn=Sim.new();turn.start(4);turn.sirens=[];var craft=turn.units[0];craft.pos=Vector2(1346.68,667.09);craft.angle=-PI/2;craft.vel=Vector2(0,-60.91)
 check(turn.segment_safe(craft.pos,Vector2(140,800),24) and turn.command("route",{"point":Vector2(140,800)}),"labelled turn fixture starts with an accepted clear straight course")
 turn.paused=false
 for n in 2400:
  turn.advance(1.0/60)
  if craft.route.is_empty() and craft.vel.length()<2:break
 check(craft.pos.distance_to(Vector2(140,800))<20,"limited physical turn can displace and recover its accepted course")
 # Programmed PASS/STOP and propulsion belong to pilot goals, not repair corners.
 var q=displaced();q.command("route_edit",{"index":0,"mode":"cruise","stop":false});q.command("queue");q.command("route",{"point":Vector2(300,800)});q.command("route_edit",{"index":1,"mode":"silent","stop":true})
 var first=q.units[0].route_plan[0].duplicate(true);q.units[0].route=[{"pos":first.pos,"stop":first.stop,"mode":first.mode,"goal":true},q.units[0].route.back().duplicate(true)]
 var accepted=q.route_goals();var history=q.units[0].route_undo.duplicate(true);q.paused=false;q.advance(1.0/60)
 check(q.route_goals()==accepted and q.units[0].route_undo==history and Program.valid_unit(q.units[0]),"repair does not consume PASS goal switch mode or rewrite later STOP/undo")
 # The same player-course seam also repairs a drone while a different craft is selected.
 var drone=displaced();drone.units[1]=drone.units[0].duplicate(true);drone.units[1].name="DRONE A";drone.units[0].route=[];Program.clear(drone.units[0]);drone.selected=2;drone.paused=false;drone.advance(1.0/60)
 check("DRONE A" in drone.message and drone.units[1].route.size()>1 and drone.selected==2,"autonomous drone repair identifies its own craft without changing selection")
 for n in 1800:
  drone.advance(1.0/60)
  if drone.units[1].route.is_empty() and drone.units[1].vel.length()<2:break
 check(drone.units[1].pos.distance_to(Vector2(140,800))<20 and not drone.blocked(drone.units[1].pos,12),"drone fixed-speed route retains physical clearance through the repaired leg")
 # Legacy course corners remain navigation authority; do not collapse to its last goal.
 var legacy=displaced();var old=legacy.units[0];Program.clear(old);old.route[0].erase("goal");old.route[0].stop=false;old.route.append({"pos":Vector2(300,800),"stop":true})
 var retained=old.route.duplicate(true);legacy.paused=false;legacy.advance(1.0/60)
 check(old.route.size()>retained.size() and old.route.slice(old.route.size()-retained.size())==retained and not old.has("route_plan") and not old.has("route_undo"),"legacy repair preserves every original PASS/STOP corner without inventing program or history")
 # Near-wall entry braking is a pathfinder safety stop, not an operator STOP.
 var wall=Sim.new();wall.start(0);wall.sirens=[];wall.mission.rocks=[];wall.mission.structures=[Rect2(300,300,200,200)];wall._build_navigation()
 var own=wall.units[0];own.pos=Vector2(514,350);own.angle=-PI/2;wall.command("route",{"point":Vector2(470,200)});wall.command("route_edit",{"index":0,"stop":false})
 own.route=[{"pos":Vector2(470,200),"stop":false,"goal":true,"mode":"inherit"}];wall.paused=false;wall.advance(1.0/60)
 check(own.route.size()>1 and own.route[0].stop and not own.route.back().stop and wall.route_goals()[0].stop==false,"repair preserves near-wall recovery safety STOP separately from operator PASS")
 print("TURN SAFE NAVIGATION CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
