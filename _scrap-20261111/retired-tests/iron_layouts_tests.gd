extends SceneTree
const L=preload("res://src/campaign/encounters/iron_layouts.gd")
const R=preload("res://src/campaign/encounters/roster.gd")
var checks=0
var failures=0
func check(ok,label):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():call_deferred("run")
func run():
 var box=L.box(1,2,3,4)
 check(box[0]==Rect2(1,2,3,4) and box[1]==[0,1,2],"box defaults to every depth band")
 check(L.box(0,0,1,1,[1])[1]==[1],"box accepts explicit bands")
 for id in range(22,30):
  var e=L.entries(id)
  check(e.size()>=3,"mission %d has authored terrain"%id)
  check(e.all(func(x):return x.size()==2 and x[0] is Rect2 and x[0].size.x>0 and x[0].size.y>0 and not x[1].is_empty() and x[1].all(func(b):return b in [0,1,2])),"mission %d entries are non-empty rects on valid bands"%id)
  check(e==L.entries(id),"mission %d terrain is deterministic"%id)
 # 24 and 25 reuse plain massing on MIDDLE only.
 check(L.entries(24).size()==3 and L.entries(24).all(func(x):return x[1]==[1]),"mission 24 rocks are MIDDLE-only")
 check(L.entries(25).size()==3 and L.entries(25)[0][0]==L.ROCKS[25][0],"mission 25 reads the shared rock table")
 check(L.entries(5).is_empty() and L.entries(-1).is_empty(),"unknown mission ids have no terrain")
 # Bulkheads.
 check(L.structures(23).size()==6 and L.structures(24).size()==2 and L.structures(25).size()==2,"stair, 24 and 25 carry their bulkheads")
 check(L.structures(22).is_empty() and L.structures(26).is_empty() and L.structures(99).is_empty(),"other missions have no bulkheads")
 for r in L.structures(23):check(r.size.x>0 and r.size.y>0,"stair bulkhead has area")
 # Rosters.
 var counts={22:4,23:3,24:4,25:3,26:3,27:4,28:3,29:3}
 for id in counts:
  var m={"sirens":[]}
  L.roster(m,id,{})
  check(m.sirens.size()==counts[id],"mission %d fields %d guards"%[id,counts[id]])
  check(m.sirens.all(func(s):return s.type in ["interceptor","warden","relay","patroller","sentinel"]),"mission %d uses existing unmodified guard roles"%id)
  if id in [22,26]:
   check(m.sirens.filter(func(g):return g.type=="patroller" and g.patrol_points.size()==2 and g.patrol_points[0].distance_to(g.patrol_points[1])>=70.).size()==1,"mission %d has one explicit two-point patrol"%id)
  elif id in [23,24,27,29]:
   check(m.sirens.filter(func(g):return g.type=="sentinel" and g.get("tether",0.)==150. and g.patrol_points.is_empty()).size()==1,"mission %d has one ordinary tethered work-approach post"%id)
  else:check(not m.sirens.any(func(g):return g.type in ["patroller","sentinel"]),"cargo-heavy exception %d retains its industrial guards"%id)
  var numbered=true
  for i in m.sirens.size():numbered=numbered and m.sirens[i].patrol==i
  check(numbered,"mission %d guards are numbered by position"%id)
 var carried=load("res://src/campaign/operation_catalog.gd").make(22,{"facts":{"confluence_route":"concealed"}})
 check(carried.sirens.map(func(g):return g.type)==["interceptor","interceptor","patroller"],"concealed carry removes the original southern warden and preserves the approach patrol")
 var m25={"sirens":[]}
 L.roster(m25,25,{})
 check(m25.sirens.size()==3 and m25.sirens[2].type=="relay","25 preserves all original industrial guards")
 var iso={"sirens":[]}
 L.roster(iso,25,{"facts":{"choir_choice":"isolate"}})
 check(iso.sirens.size()==2 and not iso.sirens.any(func(s):return s.type=="relay"),"isolating removes the relay")
 var dis={"sirens":[]}
 L.roster(dis,25,{"facts":{"choir_plant":"dismantle"}})
 check(dis.sirens.size()==2 and dis.sirens.map(func(s):return s.type)==["interceptor","relay"],"dismantling removes the warden")
 var both={"sirens":[]}
 L.roster(both,25,{"facts":{"choir_choice":"isolate","choir_plant":"dismantle"}})
 check(both.sirens.size()==1 and both.sirens.map(func(s):return s.type)==["interceptor"],"both choices preserve the original interceptor")
 var other={"sirens":[]}
 L.roster(other,22,{"facts":{"choir_choice":"isolate","choir_plant":"dismantle"}})
 check(other.sirens.size()==4,"history choices only reshape mission 25")
 var unknown={"sirens":[]}
 L.roster(unknown,30,{})
 check(unknown.sirens.is_empty(),"unknown missions add no guards")
 var seed={"sirens":[R.guard("buoy",Vector2.ZERO)]}
 L.roster(seed,23,{})
 check(seed.sirens.size()==4 and seed.sirens[1].patrol==1,"roster appends after existing sirens")
 print("IRON LAYOUTS CHECKS %d FAILURES %d"%[checks,failures])
 quit(1 if failures>0 else 0)
