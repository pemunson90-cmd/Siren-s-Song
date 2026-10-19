extends SceneTree
func _initialize():
 var Simulation=load("res://src/simulation/simulation.gd")
 for policy in ["cruise","silent","idle","covered-decoy"]:
  var s=Simulation.new();s.start(4)
  if policy!="idle":
   if policy!="silent":s.command("silent")
   s.command("route",{"point":Vector2(800,780)})
   s.command("select",{"unit":1});s.command("route",{"point":Vector2(760,200)})
   s.command("select",{"unit":2});s.command("route",{"point":Vector2(1370,450)})
   s.command("select",{"unit":0})
  if policy=="covered-decoy":s.command("decoy",{"point":Vector2(420,240)})
  s.paused=false
  var trace=[]
  for n in 30*60:
   s.advance(1.0/60)
   if n%300==299:trace.append({"time":s.elapsed,"hull":s.hull,"alive":s.units.map(func(u):return u.alive),"sub":s.units[0].pos,"threats":s.sirens.map(func(e):return {"pos":e.pos,"goal":e.goal,"mode":e.mode,"lock":e.lock})})
  print(JSON.stringify({"policy":policy,"source":"BASE_OR_CANDIDATE_PATH_PROVIDED_BY_INVOCATION","fixture":"ordinary mission4 start and commands; no forced outcome or enemy edits","trace":trace,"oxygen":s.oxygen,"tools":s.tools,"outcome":s.outcome}))
 quit()
