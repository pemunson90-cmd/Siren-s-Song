extends SceneTree
const Sim=preload("res://src/simulation/simulation.gd")
var checks=0
var failures=0
func check(ok,label):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func tick(s,t):
 s.paused=false
 for n in roundi(t*60):s.advance(1./60)
 s.paused=true
func travel(s,p):
 if not s.command("route",{"point":p}):return false
 s.paused=false
 for n in 9000:
  s.advance(1./60)
  if not s.outcome.is_empty():s.paused=true;return s.outcome=="won"
  if s.units[0].pos.distance_to(p)<15 and s.units[0].vel.length()<2:s.paused=true;return true
 s.paused=true;return false
func policy(active):
 var s=Sim.new();s.start(0)
 # Baseline fleet; keep unused drones at their launch locations.
 if not active:
  check(s.command("depth",{"band":2}),"quiet policy deliberately dives");tick(s,4.1)
 else:
  s.command("select",{"unit":1});check(s.command("depth",{"band":2}),"independent scout dives under the shelf");tick(s,4.1);check(s.command("route",{"point":Vector2(1000,500)}),"active policy coordinates a real independent scout");s.command("select",{"unit":0})
 for point in ([Vector2(360,650),Vector2(560,480),Vector2(760,620),Vector2(1190,490)] if not active else [Vector2(760,620),Vector2(940,570),Vector2(1190,490)]):
  check(travel(s,point),"actual %s passage to%s"%["quiet" if not active else "active",str(point)])
  if active and s.tools.emp>0 and point.x==940:
   check(s.command("emp"),"active policy spends finite disruption while crossing the sweeper's listening ground")
   check(s.units[1].alive,"coordinated drone survives its actual approach")
   s.command("select",{"unit":1});check(s.command("sonar_mode",{"sector":"all","power":"high"}) and s.command("ping"),"scout buys a costly independent active return");tick(s,3)
   check(s.contacts.values().any(func(c):return c.get("source") in ["active","optical"]),"coordination earns actual positional information")
   s.command("select",{"unit":0})
 if not active:check(s.command("depth",{"band":1}),"quiet approach ascends for real evidence work");tick(s,4.1)
 check(s.command("camera"),"physical policy reaches camera work · "+s.message);tick(s,4.2)
 check(s.all_records(),"policy really retains spire evidence")
 if not active:check(s.command("emp"),"quiet policy spends one disruption to cover its heard evidence work")
 if not active:check(s.command("depth",{"band":2}),"quiet withdrawal returns beneath shelf");tick(s,4.1)
 if active and s.tools.emp>0:s.command("emp")
 for point in [Vector2(760,650),Vector2(360,750),Vector2(140,800)]:check(travel(s,point),"physical withdrawal%s"%str(point))
 if not active:check(s.command("depth",{"band":1}),"quiet extraction returns to recovery band");tick(s,4.1)
 tick(s,.2)
 check(s.outcome=="won","complete baseline policy %s"%str(active))
 print("POLICY active=",active," outcome=",s.outcome," time=",s.elapsed," hull=",s.hull," oxygen=",s.oxygen," tools=",s.tools," heard=",s.sirens.filter(func(e):return e.get("type")=="sweeper")[0].get("listen",{}).get("pos",Vector2.ZERO))
 return s
func _initialize():
 var quiet=policy(false);var active=policy(true)
 var controls=[]
 for band in [1,2]:
  var s=Sim.new();s.start(0);s.units[0].pos=Vector2(850,500);s.units[0].band=band;s.units[0].silent=false;s._use_band(band)
  for i in [1,2]:s.units[i].alive=false
  tick(s,3);controls.append(s)
  print("MATCHED STAGED band=",band," time=",s.elapsed," hull=",s.hull," outcome=",s.outcome," sweeper=",s.sirens[1].mode," lock=",s.sirens[1].lock," heard=",s.sirens[1].get("listen",{}))
 check(controls[0].sirens[1].lock>1.0 and controls[1].sirens[1].lock==0.0,"matched same-position policy: the sweeper sees MIDDLE Quietus but not the same craft beneath the shelf")
 check(controls[0].sirens[1].mode in ["LOCKING","BEAM"] and controls[1].sirens[1].mode not in ["LOCKING","BEAM"] and controls[1].hull==100,"depth cover changes the sweeper's lock and damage, not a decorative instrument")
 check(quiet.tools.emp>active.tools.emp,"matched policies create different finite exposure/disruption cost")
 print("DEPTH POLICY CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
