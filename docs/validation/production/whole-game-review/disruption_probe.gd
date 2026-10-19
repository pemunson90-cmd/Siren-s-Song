extends SceneTree
const Simulation=preload("res://src/simulation/simulation.gd")
func _initialize():
 call_deferred("run")
func step(s,dt):
 s.advance(dt)
 for c in s.contacts.values():
  if s.elapsed-c.time<0.3 and c.lock>1.0 and s.tools.emp>0:
   s.command("emp"); break
func run():
 for id in [0,2,4,5]:
  var s=Simulation.new(); s.start(id,"disruption")
  var success=true
  var sub_origin=s.units[0].pos
  for target in s.mission.objectives:
   var unit=1 if s.units[1].alive else 2
   if not s.units[unit].alive: success=false; break
   s.command("select",{"unit":unit})
   var vantage=target.pos+Vector2(0,210)
   if s.blocked(vantage,25): vantage=target.pos+Vector2(-210,0)
   if not s.command("route",{"point":vantage}): success=false; break
   s.paused=false
   for n in 1800:
    step(s,0.1)
    if not s.units[unit].alive or not s.outcome.is_empty(): break
    if s.units[unit].route.is_empty() and s.units[unit].vel.length()<2: break
   if not s.units[unit].alive or not s.command("camera"): success=false; break
   for n in 45: step(s,0.1)
   if not target.captured: success=false; break
  print("DRONE_ONLY mission=",id," complete_records=",s.all_records()," outcome=",s.outcome," elapsed=",snappedf(s.elapsed,0.1)," hull=",s.hull," oxygen=",snappedf(s.oxygen,0.1)," quietus_displacement=",s.units[0].pos.distance_to(sub_origin)," drones=",s.units[1].alive,",",s.units[2].alive," emp_left=",s.tools.emp," result=",success," msg=",s.message)
 var m=Simulation.new(); m.start(0)
 print("DEFAULT_LOADOUT oxygen=",m.oxygen," emp=",m.tools.emp," recon=",m.tools.recon)
 var first=m.command("camera")
 print("CAMERA_AT_LAUNCH accepted=",first," message=",m.message)
 quit()
