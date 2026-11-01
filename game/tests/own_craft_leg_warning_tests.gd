extends SceneTree
# Item 141: a leg within hull clearance of another of your craft warns and names it.
const Sim=preload("res://src/simulation/simulation.gd")
const Pilot=preload("res://src/simulation/hand_pilot/hand_pilot.gd")
var checks=0
var failures=0
func check(ok:bool,label:String):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():call_deferred("run")

func run():
 var s=Sim.new();s.start(39);s.sirens=[];s.paused=true
 var q=s.units[0];var b=s.units[2]
 s.units[1].pos=Vector2(-5000,-5000)
 q.pos=Vector2(300,500);q.vel=Vector2.ZERO;q.band=b.band;q.transition={};q.route=[]
 b.pos=Vector2(400,500);b.vel=Vector2.ZERO;b.transition={};b.route=[]
 s.selected=0
 q.route=[{"pos":Vector2(500,500),"stop":true}]
 var w=Pilot.warnings(s,0).filter(func(x):return x.reason=="Passes DRONE B")
 check(w.size()==1,"leg through parked DRONE B names it")
 check(w.size()==1 and w[0].from==q.pos and w[0].to==Vector2(500,500),"warning spans the offending leg")
 q.route=[{"pos":Vector2(500,540),"stop":true}]
 check(Pilot.warnings(s,0).filter(func(x):return str(x.reason).begins_with("Passes")).is_empty()==(Geometry2D.get_closest_point_to_segment(b.pos,q.pos,Vector2(500,540)).distance_to(b.pos)>=Sim.COLLISION_HULL_CLEARANCE),"warning matches hull clearance geometry")
 b.pos=Vector2(400,540)
 q.route=[{"pos":Vector2(500,500),"stop":true}]
 check(Pilot.warnings(s,0).filter(func(x):return str(x.reason).begins_with("Passes")).is_empty(),"drone 40 m clear returns no own-craft warning")
 b.pos=Vector2(400,500);b.alive=false
 check(Pilot.warnings(s,0).filter(func(x):return str(x.reason).begins_with("Passes")).is_empty(),"lost craft is not warned about")
 b.alive=true
 s.units[1].pos=Vector2(300,500)
 q.route=[{"pos":Vector2(500,500),"stop":true}]
 check(Pilot.warnings(s,0).any(func(x):return x.reason=="Passes DRONE A"),"craft at the leg start is named")
 s.units[1].pos=Vector2(-5000,-5000)
 # Quietus is named from a drone's leg.
 var d=s.units[2];d.band=q.band;d.route=[{"pos":Vector2(300,500),"stop":true}];d.pos=Vector2(380,500)
 check(Pilot.warnings(s,2).any(func(x):return x.reason=="Passes QUIETUS"),"drone leg ending on Quietus names it")
 # Rock keeps its warning.
 d.route=[];d.pos=Vector2(-6000,-6000)
 var rock=s.rock_polygon(s.mission.rocks[0]);var c=Vector2.ZERO
 for p in rock:c+=p
 c/=rock.size()
 q.pos=c+Vector2(-200,0);q.route=[{"pos":c+Vector2(200,0),"stop":true}]
 check(Pilot.warnings(s,0).any(func(x):return x.reason==Pilot.ROCK_REASON),"leg across rock still warns about rock")
 # Placing a warned leg is still allowed.
 q.pos=Vector2(300,500);q.route=[];b.pos=Vector2(400,500);s.selected=0
 check(s.command("route",{"point":Vector2(500,500)}) and not q.route.is_empty(),"warned leg can still be placed")
 check(Pilot.warnings(s,0).any(func(x):return x.reason=="Passes DRONE B"),"placed leg shows the warning")
 print("OWN CRAFT LEG WARNING CHECKS %d FAILURES %d"%[checks,failures]);quit(1 if failures else 0)
