extends SceneTree
const Sim=preload("res://src/simulation/simulation.gd")
var checks=0
var failures=0
func check(ok,label):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():
 var path="res://src/presentation/landmarks/landmark_data.gd"
 var Data=load(path) if ResourceLoader.exists(path) else null
 check(Data!=null and Data.can_instantiate(),"authored landmark data exists")
 if Data==null or not Data.can_instantiate():finish();return
 for op in range(6,30):
  var rows=Data.rows(op)
  check(rows.size()>=3 and rows.size()<=5,"operation%d has three to five authored landmarks"%op)
  var ids={}
  var sim=Sim.new();sim.start(op)
  for row in rows:
   check(not ids.has(row.id),"operation%d landmark ids distinct"%op);ids[row.id]=true
   check(row.glow>=0. and row.glow<=1.,"glow is bounded")
   check(row.band in [0,1,2],"landmark has explicit depth")
   if row.source!="rock":continue
   var shapes=sim.Depth.rock_shapes(sim,row.band)
   check(row.rock>=0 and row.rock<shapes.size(),"authored rock exists at assigned depth")
   if row.rock>=shapes.size():continue
   check(row.polygon==shapes[row.rock],"whole physical form matches authored reference")
  var first=Data.rows(op);first[0].id="changed"
  check(Data.rows(op)[0].id!="changed","callers cannot mutate shared table")
 check(Data.rows(5).is_empty() and Data.rows(30).is_empty(),"tutorial and ending unchanged")
 check(Data.rows(6,false).is_empty(),"explicit off switch")
 finish()
func finish():
 print("LANDMARKS CHECKS %d FAILURES %d"%[checks,failures]);quit(1 if failures else 0)
