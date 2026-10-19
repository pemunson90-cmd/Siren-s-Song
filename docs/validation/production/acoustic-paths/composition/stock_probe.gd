extends SceneTree
const Simulation=preload("res://src/simulation/simulation.gd")
func _initialize():
 for upgrade in ["disruption","endurance"]:
  for planned in [false,true]:
   var s=coordinated(planned,-1,false,upgrade)
   print(JSON.stringify({"upgrade":upgrade,"planned":planned,"time":s.elapsed,"hull":s.hull,"outcome":s.outcome,"tools":s.tools,"alive":s.units.map(func(u):return u.alive),"records":s.mission.objectives.map(func(o):return o.captured),"trace":s.get_meta("trace"),"commands":s.get_meta("commands")}))
 quit()
func coordinated(safe_return: bool,stop_at_return_seconds: float=-1.0,legacy:bool=false,upgrade:String="disruption"):
 var s=Simulation.new(); s.start(1,upgrade)
 if legacy:s.mission.erase("acoustic_revision")
 var trace=[];var commands=[];s.set_meta("commands",commands)
 s.set_meta("trace",trace)
 for id in [1,2,0]:
  s.command("select",{"unit":id})
  s.command("route",{"point":[Vector2(840,780),Vector2(420,490),Vector2(1220,490)][id]})
 s.paused=false
 var returning=false
 var return_started=0.0
 var drone_returned={1:false,2:false}
 for n in 1600:
  s.advance(0.1)
  if n%10==0:trace.append({"time":s.elapsed,"hull":s.hull,"units":s.units.map(func(u):return {"pos":u.pos,"vel":u.vel,"alive":u.alive}),"sirens":s.sirens.map(func(e):return {"pos":e.pos,"goal":e.goal,"mode":e.mode,"lock":e.lock,"suspicion":e.suspicion}),"noises":s.noises.duplicate(true),"contacts":s.contacts.duplicate(true)})
  for contact in s.contacts.values():
   if s.elapsed-contact.time>0.3 or contact.lock<1 or s.tools.emp<=0: continue
   var nearest=0; var distance=INF
   for id in 3:
    if s.units[id].alive and s.units[id].pos.distance_to(contact.pos)<distance: nearest=id; distance=s.units[id].pos.distance_to(contact.pos)
   s.command("select",{"unit":nearest}); s.command("emp"); commands.append({"order":"emp","time":s.elapsed,"unit":nearest,"origin":s.units[nearest].pos,"observed_contact":contact.pos}); break
  for drone in [1,2]:
   if s.mission.objectives[drone-1].captured and not drone_returned[drone] and s.units[drone].alive:
    s.command("select",{"unit":drone}); s.command("route",{"point":s.mission.extraction}); drone_returned[drone]=true
  if s.capture_unit<0 and not s.all_records():
   for objective_id in 3:
    var unit_id=[1,2,0][objective_id]; var o=s.mission.objectives[objective_id]
    if not o.captured and s.units[unit_id].alive and s.units[unit_id].pos.distance_to(o.pos)<230:
     s.command("select",{"unit":unit_id}); s.command("camera"); break
  if s.all_records() and not returning:
   s.command("select",{"unit":0})
   if safe_return:
    s.command("decoy");commands.append({"order":"decoy","time":s.elapsed,"origin":s.units[0].pos}); s.command("route",{"point":s.mission.extraction})
   else: s.command("route",{"point":s.mission.extraction})
   returning=true; return_started=s.elapsed
  if returning and stop_at_return_seconds>=0 and s.elapsed-return_started>=stop_at_return_seconds: return s
  if not s.outcome.is_empty(): break
 return s
