extends SceneTree
const V=preload("res://tests/glass_fleet_voyage.gd")
const G=preload("res://tests/glass_reach_journeys.gd")
const H=preload("res://tests/glass_fleet_photo_support.gd")
var checks=0
var failures=0
var rows=[]
func check(ok,label):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
const KEYS={14:"buoy_blind",15:"vane_crack",16:"exhaust_stack",17:"silt_scour",18:"keel_mark",19:"boat_keel",20:"prism_facets",21:"locker_latch"}
func equipped_course(s,id,g)->bool:
 if id!=19:return g.course(s,id)
 # Directly supplied decoder probe, legal after the measured21 wafer/17 ledger.
 # Approach the real north-side workstation; no remote gate activation.
 if not g.go(s,Vector2(1600,1700)) or not g.dive(s,0):return false
 for p in [Vector2(725,1600),Vector2(725,1200),Vector2(1100,1100)]:
  if not g.go(s,p):return false
 if not g.dive(s,1) or not g.go(s,Vector2(1600,700)):return false
 if not s.command("camera"):return false
 g.tick(s,6.2)
 if not s.mission.objectives[0].captured:return false
 if not g.go(s,Vector2(1600,1200)) or not s.command("glass_action",{"action":"gate"}):return false
 g.tick(s,2.2)
 check(s.mission.glass_reach.gate_open,"actual supplied decoder opens19 local gate quietly")
 return g.go(s,Vector2(1600,1700)) and g.go(s,Vector2(1100,1700)) and g.go(s,Vector2(1100,2600)) and g.go(s,s.mission.corridors[0].pos)
func photographer(s,id,g)->bool:
 var h=H.new(id,KEYS[id],1);h.s=s
 var ok=true
 match id:
  14:
   ok=h.depth(2)
   for p in [Vector2(650,1650),Vector2(850,1450),Vector2(1150,1450),Vector2(1350,1250),Vector2(1570,1060)]:
    if ok:ok=h.go(p)
   if ok:ok=h.depth(1)
  15:ok=h.depth(2) and h.go(Vector2(940,2380)) and h.depth(1)
  16:
   ok=h.depth(2) and h.go(Vector2(2650,2450)) and h.go(Vector2(2380,1500)) and h.go(Vector2(2100,1050)) and h.depth(1)
  17:ok=h.depth(0) and h.go(Vector2(2700,1450)) and h.go(Vector2(1900,1380)) and h.go(Vector2(1850,1230)) and h.depth(1)
  18:
   for p in [Vector2(2650,1900),Vector2(2650,1150),Vector2(2300,1300),Vector2(1702,1278)]:
    if ok:ok=h.go(p)
   if ok:ok=h.depth(0)
  19:ok=h.depth(2) and h.go(Vector2(2100,2080)) and h.depth(1)
  20:ok=h.depth(2) and h.go(Vector2(1350,900)) and h.go(Vector2(1190,1250)) and h.go(Vector2(1310,1630)) and h.depth(1)
  21:
   ok=h.depth(2) and h.go(Vector2(350,1500)) and h.go(Vector2(950,850)) and h.go(Vector2(950,1040)) and h.depth(1)
   if ok:ok=h.record_current()
   if ok:ok=h.go(Vector2(1110,1170)) and h.go(Vector2(1260,1200)) and h.go(Vector2(1260,1155)) and h.depth(0)
 if ok:ok=h.focus() and h.record_optional()
 var index=h.target()
 check(ok and index>=0 and s.mission.objectives[index].captured and V.Photo.shots_for(s.mission,KEYS[id]).any(func(shot):return shot.get("usable",false)),"actual optional usable optical subject captured "+str(id))
 if not ok:return false
 # Return on the same real surveyed approach, then diverge into distinct berths.
 match id:
  14:
   ok=h.depth(2)
   for p in [Vector2(1350,1250),Vector2(1150,1450),Vector2(850,1450),Vector2(650,1650)]:
    if ok:ok=h.go(p)
  15:ok=h.depth(2) and h.go(Vector2(1100,2600)) and h.go(Vector2(1100,3350))
  16:ok=h.depth(2) and h.go(Vector2(2380,1500)) and h.go(Vector2(2650,2450))
  17:
   ok=h.depth(0) and h.go(Vector2(1900,1380)) and h.go(Vector2(2700,1450)) and h.depth(1)
   for p in [Vector2(600,1350),Vector2(400,850),Vector2(2470,850),Vector2(2470,400),Vector2(2250,380),Vector2(2250,140)]:
    if ok:ok=h.go(p)
  18:
   ok=h.depth(1)
   for p in [Vector2(1550,1278),Vector2(2300,1278),Vector2(2650,1150),Vector2(2650,1900),Vector2(2400,2350)]:
    if ok:ok=h.go(p)
  19:ok=h.depth(2) and h.go(Vector2(1880,2200))
  20:ok=h.depth(2) and h.go(Vector2(1190,1250)) and h.go(Vector2(1350,900))
  21:ok=h.depth(1) and h.go(Vector2(1110,1170)) and h.depth(2) and h.go(Vector2(950,850)) and h.go(Vector2(350,1500))
 var home=s.units[0].pos
 if ok:ok=h.depth(1) and h.go(home+Vector2(40,-30))
 h.uid=2
 if ok and id==17:
  ok=h.depth(0) and h.go(Vector2(2700,1450)) and h.depth(1)
  for p in [Vector2(600,1350),Vector2(400,850),Vector2(2470,850),Vector2(2470,400),Vector2(2250,380),Vector2(2250,140)]:
   if ok:ok=h.go(p)
 if ok:ok=h.go(home+Vector2(-100,-80)) and h.go(home+Vector2(-40,-30))
 s.command("select",{"unit":0});g.tick(s,1.0)
 check(h.failures==0,"all photographer commands succeed "+str(id))
 return ok
func _initialize():call_deferred("run")
func run():
 var g=G.new();var qualified=0
 var ids=[14,15,16,17,18,20,21,19]
 var args=OS.get_cmdline_user_args()
 if args.size()>0:ids=[int(args[0])]
 for id in ids:
  var bare=V.new();bare.start(id,"endurance",{"context":V.Consequences.context(g.progress())})
  check(g.course(bare,id),"actual bare course "+str(id))
  check(bare.outcome=="won" and bare.hull>0 and bare.silent_throughout and bare.tools==bare.initial_tools,"SILENT every step, no finite tool, complete bare departure "+str(id))
  if bare.hunt_peak>=20 or bare.warnings>0:qualified+=1
  check(V.valid_snapshot(bare.snapshot()),"bare empty-rack save remains valid "+str(id))
  rows.append({"policy":"bare","result":bare.measured()})
  var s=V.new();s.equipped=true
  s.start(id,"endurance",{"context":V.Consequences.context(g.progress()),"fitted":{"quietus":"quietus_decoder" if id==19 else "quietus_baffles","drone_a":"drone_deep_cells","drone_b":"drone_survey_array"}})
  for uid in [1,2]:
   s.command("select",{"unit":uid});s.command("drone_drive",{"mode":"quiet"})
  s.command("select",{"unit":0})
  check(equipped_course(s,id,g),"equipped required physical course "+str(id))
  if id==19 and float(s.mission.field_tools.get("repairable_collision_loss",0.0))>0 and s.hull<100:
   var before=s.hull
   check(s.command("hull_patch") and s.hull>before,"one actual carried hull patch repairs credited collision loss19")
  print("GLASS EQUIPPED CORE ",id," hull=",s.hull," time=",s.elapsed)
  check(photographer(s,id,g),"full equipped photograph and physical return "+str(id))
  var recovery=s.mission.module_recovery.result
  check(s.outcome=="won" and s.units.all(func(u):return u.alive) and recovery.lost.is_empty() and recovery.recovered.size()==s.mission.module_recovery.modules.size(),"both drones alive, every fitted module recovered, explicit departure "+str(id))
  check(s.hull+0.1>=bare.hull,"equipped hull at least matched bare hull "+str(id))
  if id in [17,20,21]:check(s.mission.glass_reach.artifact.state=="recovered","actual research material physically returned "+str(id))
  check(V.valid_snapshot(s.snapshot()),"full equipped rack/recovery save remains valid "+str(id))
  rows.append({"policy":"equipped","result":s.measured()})
  print("GLASS PAIR ",id," ",JSON.stringify(rows.slice(rows.size()-2)))
 if ids.size()==8:check(qualified>=6,"silent counterexample: at least six of eight actual bare routes receive locks or Hunt20")
 check(g.failures==0,"required course assertions")
 var path=OS.get_environment("ARTIFACT_DIR")
 if not path.is_empty():
  var f=FileAccess.open(path+"/glass-pairs"+("-"+str(ids[0]) if ids.size()==1 else "")+".json",FileAccess.WRITE)
  f.store_string(JSON.stringify(rows));f.close()
 g.free()
 print("GLASS FLEET PAIRS CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
