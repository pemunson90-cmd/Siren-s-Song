extends SceneTree
const Sim=preload("res://src/simulation/simulation.gd")
const Habitat=preload("res://src/simulation/shelf_habitat.gd")
const Campaign=preload("res://src/campaign/expedition_campaign.gd")
var checks=0
var failures=0
func check(ok:bool,label:String)->void:
 checks+=1
 if not ok:failures+=1;printerr("FAIL: ",label)
func advance(s,seconds:float)->void:
 s.paused=false
 for n in roundi(seconds*60):s.advance(Sim.STEP)
 s.paused=true
func travel(s,point:Vector2)->bool:
 if not s.command("route",{"point":point}):return false
 for n in 1500:
  advance(s,.1)
  if not s.outcome.is_empty():return s.outcome=="won"
  if s.units[0].pos.distance_to(point)<10 and s.units[0].vel.length()<2:return true
 return false
func run_method(common:bool):
 var s=Sim.new();s.start(8)
 s.units[1].alive=false;s.units[2].alive=false;s.tools={"emp":0,"knock":0,"decoy":0,"recon":0}
 if common:
  # Clear the eastern wall below the guards, then rise at the alarm mouth.
  check(s.command("depth",{"band":2}),"common route descends for the wall crossing")
  advance(s,4.1)
  for point in [Vector2(1700,700),Vector2(1700,1450),Vector2(1520,1640),Habitat.ALARM+Vector2(35,25)]:
   check(travel(s,point),"common approach reaches "+str(point))
  check(s.command("depth",{"band":1}),"common route rises for the local alarm")
  advance(s,4.1)
  check(s.command("shelf_alarm"),"ordinary bare-Q common alarm can be sounded")
  check(s.command("depth",{"band":2}),"common return leaves the heard alarm in deep water")
  advance(s,4.1)
  check(travel(s,Vector2(760,1600)),"common withdrawal starts through the masked inner trench")
 else:
  for point in [Vector2(1500,300),Vector2(640,300),Vector2(610,1050)]:
   check(travel(s,point),"quiet upper approach reaches "+str(point))
  check(s.command("shelf_warn",{"site":"west"}),"ordinary bare-Q quiet west warning")
  advance(s,2.7)
  for point in [Vector2(610,300),Vector2(1700,300),Vector2(1700,1145)]:
   check(travel(s,point),"quiet lower approach reaches "+str(point))
  check(s.command("shelf_warn",{"site":"east"}),"ordinary bare-Q quiet east warning")
  advance(s,2.7)
  check(travel(s,Vector2(1740,1480)),"quiet return clears the inhabited lower mouth")
 check(s.all_records(),"both actual shelter replies aboard before return")
 for point in ([Vector2(700,1600),Vector2(540,2020),s.mission.extraction] if common else [Vector2(1740,2080),Vector2(540,2080),s.mission.extraction]):
  check(travel(s,point),"physical return reaches "+str(point))
 if common:
  check(s.command("depth",{"band":1}),"common route rises at the actual recovery mouth")
  advance(s,4.1)
 check(s.outcome=="won" and s.hull>0,"ordinary guards permit complete no-drone/no-tools "+("common" if common else "quiet")+" journey")
 print("SHELF METHOD ","common" if common else "quiet"," time=",s.elapsed," hull=",s.hull," oxygen=",s.oxygen," receipt=",s.mission.shelf_habitat.receipts," guards=",s.sirens.map(func(g):return {"pos":g.pos,"mode":g.mode}))
 return s
func _initialize()->void:
 var common=run_method(true);var quiet=run_method(false)
 check(common.elapsed<quiet.elapsed-5,"common alarm offers a materially shorter successful work/return route in these authored policies")
 var previous={"version":1,"route":"shelf","routes":["shelf"],"facts":{"shelf":"carrier"},"completed":[6]}
 var p=Campaign.recover(previous,common.mission)
 check(10 in Campaign.available([0,1,2,3,4,5],p) and "drone_sampler" in p.entitlements,"first inhabited-shelf recovery preserves sampler and next plant operation")
 check(p.facts.has("shelf_warning"),"actual first shelter account is carried into later launch context")
 var replay=Campaign.recover(p,quiet.mission)
 check(replay.facts.get("shelf_warning")==p.facts.get("shelf_warning"),"replay cannot silently rewrite the first recovered shelter method")
 print("SHELF HABITAT JOURNEY CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
