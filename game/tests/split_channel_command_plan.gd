extends RefCounted
# Ordinary production commands only. Opposite-arm drone routes run while
# Quietus takes the covered uplink approach; defensive reactions use fresh locks.
static func play(sim=null,survey:bool=false):
 var s=sim
 if s==null:s=preload("res://src/simulation/simulation.gd").new();s.start(1,"disruption");s.mission["dev"]=true # 127: dev/test route path.
 var returning=false;var surveyed=false;var drone_returned={1:false,2:false}
 for id in [1,2,0]:
  s.command("select",{"unit":id})
  s.command("route",{"point":[s.mission.objectives[2].pos,s.mission.objectives[0].pos+Vector2(0,180),s.mission.objectives[1].pos+Vector2(0,180)][id]})
 s.paused=false
 for n in 1800:
  s.advance(0.1)
  for contact in s.contacts.values():
   if s.elapsed-contact.time>0.3 or contact.lock<1.0 or s.tools.emp<=0:continue
   var nearest=-1;var distance=340.0
   for id in 3:
    if s.units[id].alive and s.units[id].pos.distance_to(contact.pos)<distance:nearest=id;distance=s.units[id].pos.distance_to(contact.pos)
   if nearest>=0:s.command("select",{"unit":nearest});s.command("emp");break
  if survey and not surveyed and s.units[0].pos.distance_to(s.mission.objectives[2].pos)<100:
   s.command("select",{"unit":0});s.command("recon");surveyed=true
  if s.capture_unit<0 and not s.all_records():
   for objective_id in 3:
    var unit_id=[1,2,0][objective_id];var objective=s.mission.objectives[objective_id]
    if not objective.captured and s.units[unit_id].alive and s.units[unit_id].pos.distance_to(objective.pos)<230:
     s.command("select",{"unit":unit_id});s.command("camera")
  for drone in [1,2]:
   if s.mission.objectives[drone-1].captured and not drone_returned[drone] and s.units[drone].alive:
    s.command("select",{"unit":drone});s.command("route",{"point":s.mission.extraction});drone_returned[drone]=true
  if s.all_records() and not returning:
   s.command("select",{"unit":0});s.command("route",{"point":s.mission.extraction});returning=true
  if not s.outcome.is_empty():break
 return s
