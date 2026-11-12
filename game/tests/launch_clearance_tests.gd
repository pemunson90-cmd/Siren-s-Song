extends SceneTree
# WP-11 bug B1: every operation (0 to 41) with every Quietus hull starts its
# three craft clear of each other, and three seconds with no orders strike no
# own craft and cost no hull. Collision rules and numbers are not touched here.
const Sim=preload("res://src/simulation/simulation.gd")
const Catalog=preload("res://src/equipment/equipment_catalog.gd")
const Hulls=preload("res://src/equipment/hulls.gd")
var checks=0
var failures=0
func check(ok:bool,label:String):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():
 var started=0
 for operation in 42:
  for hull_id in Hulls.HULLS:
   var fit=Catalog.default_loadout();fit["hull"]=hull_id
   var s=Sim.new();s.start(operation,"endurance",{"fitted":fit})
   if s.mission.is_empty():continue
   started+=1
   var tag="op%d %s"%[operation,hull_id]
   var gap=INF
   for a in 3:
    for b in range(a+1,3):gap=minf(gap,s.units[a].pos.distance_to(s.units[b].pos))
   check(gap>=Sim.COLLISION_HULL_CLEARANCE,"%s craft start at least hull clearance apart (closest %.1fm)"%[tag,gap])
   var hull_before=s.hull
   var strikes=[]
   s.paused=false
   for n in roundi(3.0/Sim.STEP):
    s.advance(Sim.STEP)
    if s.message.begins_with("Hull strike") and not s.message in strikes:strikes.append(s.message)
   check(not strikes.any(func(m):return "DRONE" in m),"%s no own-craft strike in the first 3 s %s"%[tag,str(strikes)])
   check(s.hull>=hull_before,"%s no hull loss in the first 3 s (%.1f to %.1f)"%[tag,hull_before,s.hull])
 check(started>=40,"at least 40 operations start (%d hull starts)"%started)
 _critic_strike()
 _recovery_at_launch()
 print("LAUNCH CLEARANCE CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
# Bug B1 as the critic met it (Needle Strait, hull 60 to 47 at 00:02 against
# DRONE A): the start is clear, and a first straight Quietus leg north through
# the parked Drone A strikes it about 2.5 s later for 13 percent. The existing
# own-craft leg warning (item 141) names that drone before the leg runs.
func _critic_strike():
 var s=Sim.new();s.start(15);s.sirens=[]
 s._use_band(s.units[0].band)
 check(s.command("route",{"point":s.units[0].pos+Vector2(0,-400)}),"op15 accepts a first leg north")
 var warned=preload("res://src/simulation/hand_pilot/hand_pilot.gd").warnings(s,0)
 check(str(warned).contains("DRONE A"),"op15 leg through Drone A is warned before it runs %s"%str(warned))
 s.paused=false
 var strike="";var at=-1.0
 for n in roundi(4.0/Sim.STEP):
  var before=s.hull
  s.advance(Sim.STEP)
  if s.hull<before and strike.is_empty():strike=s.message;at=s.elapsed
 print("B1 CAUSE op15 standard leg north: t=",at," ",strike," hull=",s.hull)
 check("DRONE A" in strike and at>2.0 and at<3.0 and roundi(100.0-s.hull)==13,"op15 north leg strike reproduces the critic's 13 percent loss against Drone A")
# Bug B2: in the opening operations the recovery mouth is the launch point and
# the opening layout parks each drone 100 m from it, outside the 65 m recovery
# reach that item 133 uses. Unmoved drones are therefore truthfully OUTSIDE
# RECOVERY; this records that fact, it does not change the rule.
func _recovery_at_launch():
 var Recovery=preload("res://src/simulation/module_recovery.gd")
 var View=preload("res://src/presentation/module_recovery_view.gd")
 var s=Sim.new();s.start(0);s.sirens=[]
 var mouth:Vector2=s.mission.extraction
 check(s.units[0].pos.distance_to(mouth)<1.0,"op0 Quietus launches at its recovery mouth")
 for id in [1,2]:check(s.units[id].pos.distance_to(mouth)>=65.0,"op0 unmoved %s starts %.0fm from the mouth, outside the 65m reach"%[s.units[id].name,s.units[id].pos.distance_to(mouth)])
 var context=Recovery.departure(s,{"pos":mouth})
 check(context.recovered_drones.is_empty(),"op0 departure with unmoved drones recovers neither drone %s"%str(context.recovered_drones))
 Recovery.record(s,context);s.outcome="won"
 var text=View.consequence(s)
 check(text.contains("DRONE A · OUTSIDE RECOVERY") and text.contains("DRONE B · OUTSIDE RECOVERY"),"op0 result label matches the rule for unmoved drones")
 var counted=[]
 for operation in 42:
  var o=Sim.new();o.start(operation)
  if o.mission.is_empty() or o.units[0].pos.distance_to(o.mission.extraction)>=65.0:continue
  if [1,2].any(func(id):return o.units[id].pos.distance_to(o.mission.extraction)>=65.0):counted.append(operation)
 print("B2 operations launching at the mouth with a drone outside reach: ",counted)
