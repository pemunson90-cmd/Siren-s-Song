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
 var counts={22:3,23:2,24:3,26:2,27:3,28:3,29:2}
 for id in counts:
  var m={"sirens":[]}
  L.roster(m,id,{})
  check(m.sirens.size()==counts[id],"mission %d fields %d guards"%[id,counts[id]])
  check(m.sirens.all(func(s):return s.type in ["interceptor","warden","relay"]),"mission %d uses Iron Choir roles"%id)
  var numbered=true
  for i in m.sirens.size():numbered=numbered and m.sirens[i].patrol==i
  check(numbered,"mission %d guards are numbered by position"%id)
 var m25={"sirens":[]}
 L.roster(m25,25,{})
 check(m25.sirens.size()==3 and m25.sirens.back().type=="relay","25 default roster ends with the relay")
 var iso={"sirens":[]}
 L.roster(iso,25,{"facts":{"choir_choice":"isolate"}})
 check(iso.sirens.size()==2 and not iso.sirens.any(func(s):return s.type=="relay"),"isolating removes the relay")
 var dis={"sirens":[]}
 L.roster(dis,25,{"facts":{"choir_plant":"dismantle"}})
 check(dis.sirens.size()==2 and dis.sirens.map(func(s):return s.type)==["interceptor","relay"],"dismantling removes the warden")
 var both={"sirens":[]}
 L.roster(both,25,{"facts":{"choir_choice":"isolate","choir_plant":"dismantle"}})
 check(both.sirens.size()==1 and both.sirens[0].type=="interceptor","both choices leave the lone interceptor")
 var other={"sirens":[]}
 L.roster(other,22,{"facts":{"choir_choice":"isolate","choir_plant":"dismantle"}})
 check(other.sirens.size()==3,"history choices only reshape mission 25")
 var unknown={"sirens":[]}
 L.roster(unknown,30,{})
 check(unknown.sirens.is_empty(),"unknown missions add no guards")
 var seed={"sirens":[R.guard("buoy",Vector2.ZERO)]}
 L.roster(seed,23,{})
 check(seed.sirens.size()==3 and seed.sirens[1].patrol==1,"roster appends after existing sirens")
 print("IRON LAYOUTS CHECKS %d FAILURES %d"%[checks,failures])
 quit(1 if failures>0 else 0)
