extends SceneTree
# Source-known Shelf replay through ordinary commands, live actors and real work clocks.
# This proves one representative completion, not difficulty or Android play quality.
const Run=preload("res://src/campaign/challenges/challenge_run.gd")
const Travel=preload("res://tests/campaign_scenarios.gd")
var checks=0
var failures=0
func check(ok,label):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():
 var s=Run.new()
 check(s.setup("shelf_passive"),"the representative challenge starts with its authored loadout")
 check(not s.command("ping") and not s.command("recon"),"passive-only restriction remains active on the real journey")
 var objective=s.mission.objectives[0]
 var reached=Travel.move(s,objective.pos+Vector2(0,210))
 check(reached,"the fixed fleet physically reaches the Shelf optical approach")
 if reached:
  check(s.command("camera"),"the challenge starts ordinary optical work")
  for n in int((objective.get("duration",4.0)+0.5)*10):s.advance(.1)
  check(objective.captured,"the actual camera work clock recovers the record")
  check(Travel.move(s,s.mission.extraction),"Quietus physically returns to extraction")
 check(s.outcome=="won" and not s.result().loss,"the live passive challenge completes successfully")
 check(s.units.all(func(unit):return unit.alive),"the fixed fleet survives the representative replay")
 check(s.tools.recon==2,"the replay spends no forbidden active survey charge")
 print("CHALLENGE SHELF outcome=",s.outcome," time=",s.elapsed," hull=",s.hull," tools=",s.used)
 print("CHALLENGES JOURNEY CHECKS ",checks," FAILURES ",failures)
 quit(1 if failures else 0)
