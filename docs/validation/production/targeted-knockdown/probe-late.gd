extends SceneTree
const Sim=preload("res://src/simulation/simulation.gd")
func setup():
 var s=Sim.new();s.start(4,"disruption");s.command("silent");s.command("route",{"point":Vector2(820,520)});s.paused=false
 for n in 69:s.advance(0.1)
 return s
func _initialize():
 for policy in ["knock1.8","knock2.0","knock2.2","knock2.4","knock2.6"]:
  var s=setup();var shot=false;var commands=[];var hit=false;var lost=false
  for frame in 240:
   var time=frame/15.0
   if frame==15 and policy!="idle":s.command("emergency",{"point":Vector2(420,580)});commands.append({"t":time,"order":"emergency"})
   if frame==15 and policy=="emp":s.command("emp");commands.append({"t":time,"order":"emp"})
   if policy.begins_with("knock") and not shot and time>=float(policy.trim_prefix("knock")):
    var observed=s.knockdown_targets();var accepted=false
    if not observed.is_empty():accepted=s.command("knock",{"target":observed[0].key})
    commands.append({"t":time,"order":"knock","accepted":accepted,"eligible":observed,"angle":s.units[0].angle});shot=true
   if s.sirens.any(func(e):return e.get("pin_time",0)>0):hit=true
   if s.message=="Torpedo struck terrain · shot spent":lost=true
   s.advance(1.0/15.0)
  print(JSON.stringify({"policy":policy,"commands":commands,"hull":s.hull,"outcome":s.outcome,"elapsed":s.elapsed,"pin_seen":hit,"terrain_impact":lost,"tools":s.tools,"endpos":s.units[0].pos}))
 quit()
