extends SceneTree
const Catalog=preload("res://src/campaign/operation_catalog.gd")
const Sim=preload("res://src/simulation/simulation.gd")
var checks=0
var failures=0
func check(ok,label):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():
 for id in range(22,30):
  var d=Catalog.definition(id)
  check(not d.is_empty(),"authored Iron Choir identity "+str(id))
  if d.is_empty():continue
  var m=Catalog.make(id)
  check(Catalog.valid_definition(d) and m.has("iron_choir"),"real physical industrial factory "+str(id))
  check(m.objectives.is_empty() and not m.iron_choir.sites.is_empty(),"industrial work replaces receiver errand "+str(id))
  var s=Sim.new();s.start(id)
  check(Sim.valid_snapshot(s.snapshot()),"initial industrial current save "+str(id))
  for e in s.sirens:check(s.Depth.clear(s,e.pos,e.pos,e.band,12),"enemy starts in physical water "+str(id))
 var shapes={}
 for id in range(22,30):shapes[Catalog.make(id).iron_choir.sites.map(func(site):return site.id)]=id
 check(shapes.size()==8,"every Iron Choir operation has its own work-site structure")
 check(Catalog.make(22).iron_choir.stamp==-1. and not Catalog.make(26).iron_choir.sealed,"timed work starts unarmed")
 check(Catalog.prerequisites_met(22,[19]) and not Catalog.prerequisites_met(22,[18]),"ordinary recovered Reach finale opens industry")
 check(Catalog.prerequisites_met(26,[22]) and Catalog.prerequisites_met(27,[23]) and Catalog.prerequisites_met(28,[23]) and Catalog.prerequisites_met(29,[24]),"optional jobs unlock at useful intermediate points")
 print("IRON CHOIR CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
