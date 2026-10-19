extends SceneTree
const Simulation=preload("res://src/simulation/simulation.gd")
const SaveStore=preload("res://src/persistence/save_store.gd")
func _initialize():
 var store=SaveStore.new(); store.path="/tmp/sirens-accepted-baseline.save"
 var data=store.load_game(); var s=Simulation.new(); s.restore(data.active)
 for target in s.mission.objectives:
  var id=1 if s.units[1].alive else 2
  s.command("select",{"unit":id})
  var vantage=target.pos+Vector2(0,210)
  if s.blocked(vantage,25): vantage=target.pos+Vector2(-210,0)
  if not s.command("route",{"point":vantage}): break
  s.paused=false
  for n in 1800:
   step(s)
   if not s.units[id].alive or not s.outcome.is_empty(): break
   if s.units[id].route.is_empty() and s.units[id].vel.length()<2: break
  if not s.units[id].alive or not s.command("camera"): break
  for n in 45: step(s)
  if not target.captured: break
 print("LEGACY_COMPARE outcome=",s.outcome," time=",snappedf(s.elapsed,0.1)," hull=",s.hull," records=",s.mission.objectives.map(func(o):return o.captured)," drones=",s.units[1].alive,",",s.units[2].alive," emp=",s.tools.emp)
 var f=FileAccess.open("/tmp/sirens-legacy-won.var",FileAccess.WRITE); f.store_var(s.snapshot()); f.close()
 quit()
func step(s):
 s.advance(0.1)
 for c in s.contacts.values():
  if s.elapsed-c.time<0.3 and c.lock>1.0 and s.tools.emp>0:
   s.command("emp"); break
