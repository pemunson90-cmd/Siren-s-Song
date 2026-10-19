extends SceneTree
const Sim=preload("res://src/simulation/simulation.gd")
const Listener=preload("res://passive_listener.gd")
func _initialize():
 for policy in ["moving-scout","visual-post","listening-post","scout-survey"]:
  var s=Sim.new();s.start(4);var listener=Listener.new();listener.configure(s)
  s.command("silent");s.command("route",{"point":Vector2(800,780)})
  s.command("select",{"unit":1});s.command("route",{"point":Vector2(300,600) if policy in ["visual-post","listening-post"] else Vector2(760,200)})
  s.command("select",{"unit":2});s.command("route",{"point":Vector2(1370,450)});s.command("select",{"unit":0});s.paused=false
  var first_bearing=-1.0;var first_hunter=-1.0;var first_contact=-1.0;var samples=[];var first_arrival_state={}
  for tick in 30*60:
   if tick==360 and policy=="scout-survey":s.command("recon")
   if tick==600 and policy in ["moving-scout","scout-survey"]:
    s.command("select",{"unit":1});s.command("camera");s.command("select",{"unit":0})
   s.advance(Sim.STEP)
   if s.has_live_contact() and first_contact<0:first_contact=s.elapsed
   if s.contacts.has(1) and s.elapsed-s.contacts[1].time<0.3 and first_hunter<0:first_hunter=s.elapsed
   if tick%30==0:
    var reading=listener.sample(s,1)
    if policy=="listening-post" and first_bearing<0 and not reading.bearings.is_empty():first_bearing=s.elapsed;first_arrival_state={"sub":s.units[0].pos,"drone":s.units[1].pos,"public_reading":reading}
    if policy=="listening-post":samples.append(reading)
   if not s.outcome.is_empty():break
  print(JSON.stringify({"policy":policy,"fixture":"ordinary mission4 start/routes; one stationary post vs moving scout; no enemy/resource/knowledge edits; listener is scratch observer only","sensitivity_hypothesis":2.0,"first_bearing":first_bearing,"first_live_hunter":first_hunter,"first_live_any_contact":first_contact,"first_arrival_state":first_arrival_state,"samples":samples,"end":{"time":s.elapsed,"hull":s.hull,"outcome":s.outcome,"tools":s.tools,"records":s.mission.objectives.map(func(o):return o.captured),"alive":s.units.map(func(u):return u.alive),"positions":s.units.map(func(u):return u.pos)}}))
 quit()
