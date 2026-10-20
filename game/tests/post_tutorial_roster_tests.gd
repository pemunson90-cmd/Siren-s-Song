extends SceneTree
const Sim=preload("res://src/simulation/simulation.gd")
const Missions=preload("res://src/campaign/missions.gd")
var checks=0
var failures=0
func check(ok:bool,label:String)->void:
 checks+=1
 if not ok:failures+=1;printerr("FAIL: ",label)
func context(thread:String)->Dictionary:
 return {"thread":thread,"completed":[6,7,9] if thread=="deep" else [6,8,10],"facts":{},"references":{}}
func fixture(id:int,thread:String="deep"):
 var s=Sim.new();s.start(id,"disruption",{"context":context(thread)})
 return s
func reachable_receiver(s,point:Vector2)->bool:
 for offset in [Vector2(0,180),Vector2(180,0),Vector2(-180,0),Vector2(0,-180)]:
  var at=point+offset
  if not s.blocked(at,24) and s.line_clear(at,point) and not s.path(s.mission.start,at).is_empty():return true
 return false
func _initialize()->void:
 var roles={}
 for id in range(6,14):
  var s=fixture(id)
  for enemy in s.sirens:
   roles[enemy.type]=true
   check(not s.blocked(enemy.home,24) and not s.blocked(enemy.pos,24),"job%d enemy deploys in physical water"%id)
   if enemy.type=="sentinel":check(enemy.get("tether",0)>0,"station defender has a finite home tether")
  for source in s.mission.get("signal_sources",[]):check(reachable_receiver(s,source.pos),"job%d source retains reachable clear acquisition water"%id)
  for site in s.mission.objectives:check(reachable_receiver(s,site.pos),"job%d operation retains reachable clear working water"%id)
  for exit in s.mission.corridors:check(not s.path(s.mission.start,exit.pos).is_empty(),"job%d physical exit remains reachable"%id)
 check(roles.has_all(["patroller","sentinel","hunter"]),"all three threat roles occur beyond the tutorial")
 check(fixture(7).sirens.any(func(s):return s.type=="sentinel"),"Deep berth is defended by a station-bound sentinel")
 check(fixture(8).sirens.any(func(s):return s.type=="hunter"),"Shelf approach includes a mobile hunter")
 check(fixture(10).sirens.any(func(s):return s.type=="sentinel"),"parallel warning fieldwork includes a stationary defender")
 var deep=fixture(11,"deep");var shelf=fixture(11,"shelf")
 check(deep.sirens.any(func(s):return s.type=="sentinel") and deep.sirens.any(func(s):return s.type=="hunter") and deep.sirens.any(func(s):return s.type=="patroller"),"deep entry retains all three physical Confluence threat jobs")
 check(shelf.sirens.any(func(s):return s.type=="hunter") and shelf.sirens.any(func(s):return s.type=="sentinel") and shelf.sirens.any(func(s):return s.type=="patroller"),"shelf entry retains all three physical Confluence threat jobs")
 check(deep.mission.start!=shelf.mission.start and deep.mission.rocks==shelf.mission.rocks,"thread changes physical entry within one shared Confluence")
 check(fixture(12).sirens.any(func(s):return s.type=="sentinel"),"sluice operation has a local station defender")
 check(fixture(13).sirens.any(func(s):return s.type=="hunter") and fixture(13).sirens.any(func(s):return s.type=="sentinel"),"open warning combines mobile response and guarded receiver")
 # A closed sluice still permits a quiet physical route; opening only removes
 # its own structure, so no thread outcome depends on a compulsory actuator.
 var concealed=fixture(12)
 check(reachable_receiver(concealed,concealed.mission.signal_sources[0].pos) and not concealed.path(concealed.mission.start,concealed.mission.extraction).is_empty(),"concealed job remains traversable with the sluice closed")
 print("POST TUTORIAL ROSTER CHECKS ",checks," FAILURES ",failures)
 quit(1 if failures else 0)
