extends RefCounted
# Scripted journeys play patiently: before surfacing for a photograph they rehearse the exact manoeuvre
# (rise, optionally move to the vantage, expose the frame, sink again, then leave by the next planned leg) on a copy of the simulation and wait while that rehearsal would
# get Quietus caught. Only the real simulation's own rules decide; nothing here changes a Siren.
const Sim=preload("res://src/simulation/simulation.gd")
static func _run(s,seconds:float)->void:
 s.paused=false
 for n in roundi(seconds*60):s.advance(1./60)
 s.paused=true
static func rehearsal_survives(s,id:int,up:int,target:int,then:Vector2=Vector2.INF,at:Vector2=Vector2.INF)->bool:
 var copy=Sim.new()
 if not copy.restore(s.snapshot()):return true
 var home=copy.units[id].band
 copy.command("select",{"unit":id})
 if not copy.command("depth",{"band":up}):return true
 _run(copy,4.1)
 if at.is_finite() and copy.command("route",{"point":at}):_run(copy,copy.units[id].pos.distance_to(at)/35.+1.)
 if copy.command("camera"):_run(copy,copy.mission.objectives[target].get("duration",4.)+.3)
 if copy.units[id].alive and copy.outcome.is_empty() and copy.command("depth",{"band":home}):_run(copy,4.1)
 if then.is_finite() and copy.units[id].alive and copy.command("route",{"point":then}):_run(copy,26.)
 if copy.sirens.any(func(e):return e.mode in ["LOCKING","BEAM"]):return false
 return copy.units[id].alive and copy.outcome.is_empty() and copy.hull>=s.hull-.001
