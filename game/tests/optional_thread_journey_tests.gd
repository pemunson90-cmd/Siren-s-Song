extends "res://tests/calder_trench_journey_tests.gd"
# 127 (Pat 2026-10-30): scripted journeys here fly the dev/test pathfinder route; hand_pilot_journeys covers release play.
# Two source-known, bare Quietus voyages; no staged craft, threats or captures.
const Photo=preload("res://src/simulation/photo_capture.gd")
const Layouts=preload("res://src/campaign/encounters/optional_layouts.gd")
func run():
 for id in [38,39]:
  var s=Sim.new();s.start(id);s.mission["dev"]=true
  var stock=s.tools.duplicate(true)
  check(s.mission.get("launch_equipment",{}).values().all(func(item):return str(item).is_empty() or str(item)=="standard"),"bare loadout "+str(id))
  check(Sim.valid_snapshot(s.snapshot()),"launch snapshot validates "+str(id))
  var finished=deep_thread(s) if id==38 else shelf_thread(s)
  check(finished and s.outcome=="won" and s.mission.recovered,"physical photo recovery "+str(id))
  for index in [0,1]:
   var o=s.mission.objectives[index]
   check(o.captured and Photo.shots_for(s.mission,o.optical).any(func(shot):return shot.get("usable",false) and "mark" in shot.get("features",[])),"usable target-specific required/bonus film "+str(id)+" / "+str(index))
  check(s.tools==stock,"voyage uses no consumable tools or drones "+str(id))
  check(s.sirens.size()==2 and s.units[0].alive and s.hull>0,"authored threats remain live "+str(id))
  check(Sim.valid_snapshot(s.snapshot()),"recovered save validates "+str(id))
  print("OPTIONAL THREAD ROUTE ",id," outcome=",s.outcome," time=",s.elapsed," hull=",s.hull," oxygen=",s.oxygen," pos=",s.units[0].pos," message=",s.message)
 print("OPTIONAL THREAD JOURNEY CHECKS %d FAILURES %d"%[checks,failures]);quit(1 if failures else 0)
func leg(s,p:Vector2)->bool:
 var reached=go(s,p)
 print("THREAD LEG ",s.mission.id," target=",p," reached=",reached," band=",s.units[0].band," time=",s.elapsed," hull=",s.hull," message=",s.message)
 return reached
func deep_thread(s)->bool:
 # Open the audible short crossing; the roof still prevents a MIDDLE crossing.
 if not leg(s,Vector2(800,2110)) or not expose(s,s.mission.objectives[2]):return false
 check(not Layouts.DEEP_GATE in s.mission.structures,"motor physically removes the sluice")
 check(Sim.valid_snapshot(s.snapshot()),"opened sluice snapshot validates")
 if not dive(s,2) or not leg(s,Vector2(800,1700)) or not leg(s,Vector2(800,1100)):return false
 if not leg(s,Vector2(1380,1000)) or not expose(s,s.mission.objectives[0]):return false
 # Quiet western contour remains passable; take the plate in MIDDLE on return.
 if not leg(s,Vector2(350,1100)) or not dive(s,1):return false
 if not leg(s,Vector2(360,950)) or not expose(s,s.mission.objectives[1]):return false
 if not leg(s,Vector2(350,2150)) or not leg(s,Vector2(1650,2480)):return false
 tick(s,1.)
 return s.outcome=="won"
func shelf_thread(s)->bool:
 # Longer outer contour preserves passive sound and passes the optional numbers.
 if not leg(s,Vector2(550,300)) or not leg(s,Vector2(1430,300)):return false
 if not expose(s,s.mission.objectives[1]) or not leg(s,Vector2(550,300)):return false
 if not leg(s,Vector2(530,700)) or not expose(s,s.mission.objectives[0]):return false
 # Short inner return crosses the actual masking front below the hooked terrace.
 if not leg(s,Vector2(650,820)) or not leg(s,Vector2(1850,820)) or not leg(s,Vector2(2250,820)):return false
 if not leg(s,Vector2(2450,700)) or not leg(s,Vector2(2800,1450)) or not leg(s,Vector2(2650,1450)):return false
 tick(s,1.)
 return s.outcome=="won"
