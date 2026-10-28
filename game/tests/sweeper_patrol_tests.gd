extends SceneTree
# Sweeper patrol circuits (src/campaign/sweeper_patrols.gd): authored data is
# fair and clear, a sweeper given points walks them, one without stands.
const Sim=preload("res://src/simulation/simulation.gd")
const Patrols=preload("res://src/campaign/sweeper_patrols.gd")
const Scen=preload("res://tests/sweeper_scenarios.gd")
const EXCLUDED_PHOTO_OPS=[18,19]
var checks=0
var failures=0
func check(ok:bool,label:String)->void:
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func sweepers(s)->Array:return s.sirens.filter(func(e):return e.type=="sweeper")
func loop_length(points:Array)->float:
 var total=0.
 for n in points.size():total+=points[n].distance_to(points[(n+1)%points.size()])
 return total
func _initialize():
 check(Patrols.ENABLED,"circuits are switched on")
 for id in Patrols.OPS:
  var s=Sim.new();s.start(id)
  var found=sweepers(s)
  check(found.size()==Patrols.OPS[id].size(),"op%d has one circuit per sweeper"%id)
  for index in found.size():
   var e=found[index];var points:Array=e.patrol_points;var band:int=int(e.get("band",1))
   var label="op%d sweeper%d"%[id,index]
   check(points==Patrols.circuit(id,index) and points.size()>=2 and points.size()<=4,label+" carries its 2 to 4 point circuit")
   check(loop_length(points)<=900.,label+" loop stays modest")
   var ok=true;var near=true
   for n in points.size():
    var a:Vector2=points[n];var b:Vector2=points[(n+1)%points.size()]
    ok=ok and s.Depth.clear(s,a,a,band,24.) and s.Depth.clear(s,a,b,band,24.)
    near=near and a.distance_to(e.home)<=400.
   check(ok,label+" points and legs are clear water in its band")
   check(near,label+" stays within 400m of its post")
   check(Sim.valid_snapshot(s.snapshot()),label+" snapshot validates")
 for id in EXCLUDED_PHOTO_OPS:
  check(not Patrols.OPS.has(id) and Patrols.circuit(id).is_empty(),"photo-row op%d is left to handoff 040"%id)
  var s=Sim.new();s.start(id)
  # 095 authors Lantern Lock locally; it remains outside the shared circuits.
  var expected=[Vector2(1560,900),Vector2(1760,900),Vector2(1760,450),Vector2(1560,450)] if id==18 else []
  check(sweepers(s).all(func(e):return e.patrol_points==expected),"op%d sweepers retain their authored photo approach patrol"%id)
 check(Patrols.circuit(99).is_empty() and Patrols.circuit(0,5).is_empty(),"unknown op or index yields no circuit")
 # Walking: in each op, the sweeper alone with Quietus parked out of earshot.
 for id in Patrols.OPS:
  var s=Sim.new();s.start(id)
  var e=sweepers(s)[0];var points:Array=e.patrol_points
  s.sirens=[e]
  for i in [1,2]:s.units[i].alive=false
  s.units[0].silent=true;s.units[0].vel=Vector2.ZERO;s.units[0].band=0 if int(e.get("band",1))!=0 else 2
  s.units[0].pos=Vector2(30,30) if e.home.distance_to(Vector2(30,30))>1100. else s.world_size()-Vector2(30,30)
  var best=points.map(func(_p):return 1e9);var leave=0.
  for step in 240:
   Scen.tick(s,1.)
   for n in points.size():best[n]=minf(best[n],e.pos.distance_to(points[n]))
   leave=maxf(leave,e.pos.distance_to(e.home))
  check(best.all(func(d):return d<60.),"op%d sweeper with points walks its whole circuit (closest %s)"%[id,str(best)])
  check(leave<=600.,"op%d sweeper never strays far from its post"%id)
  check(e.mode in ["PATROL","SEARCH"] and s.hull==100. and e.lock==0.,"op%d walking sweeper never locks the parked Quietus"%id)
 # Control: the same sweeper without points stands at home.
 for id in Patrols.OPS:
  var s=Sim.new();s.start(id)
  var e=sweepers(s)[0];e.patrol_points=[];s.sirens=[e]
  for i in [1,2]:s.units[i].alive=false
  s.units[0].silent=true;s.units[0].vel=Vector2.ZERO;s.units[0].pos=Vector2(30,30) if e.home.distance_to(Vector2(30,30))>1100. else s.world_size()-Vector2(30,30)
  Scen.tick(s,120)
  check(e.pos.distance_to(e.home)<1.,"op%d sweeper without points stands at its post"%id)
 print("SWEEPER PATROL CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
