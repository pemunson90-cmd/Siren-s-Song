extends SceneTree
const Sim=preload("res://src/simulation/simulation.gd")
var checks=0
var failures=0
func check(ok:bool,label:String):
 checks+=1
 if not ok:failures+=1;print("FAIL ",label)
func _initialize():
 for id in [9,10]:
  var sim=Sim.new();sim.start(id)
  check(sim.mission.id==id,"onward registry dispatches distinct authored chapter")
  if sim.mission.id!=id:continue
  check(Sim.valid_snapshot(sim.snapshot()),"fresh onward world supports actual save")
  check(not sim.all_records(),"hidden required source never counts as an empty completed mission")
  check(sim.path(sim.units[0].pos,sim.mission.extraction).size()>0,"authored launch and recovery connected by ordinary navigation")
  var restored=Sim.new();check(restored.restore(sim.snapshot()),"frozen fitting and launch context restore")
  if id==9:
   sim.paused=false
   for i in 60:sim.advance(1.0/60)
   for reading in sim.signal_readings():check(reading.label=="UNRESOLVED CARRIER" and not reading.has("id") and not reading.has("pos"),"new received cue cannot leak source label or source position")
   sim.units[0].pos=sim.mission.signal_sources[1].pos;sim._observe()
   for i in 60:sim.advance(1.0/60)
   check(not sim.all_records(),"optional repeater discovery cannot complete live packet")
 print("ONWARD MISSIONS ",checks," FAILURES ",failures)
 quit(1 if failures else 0)
