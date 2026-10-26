extends SceneTree
var failures=0
var checks=0
func check(ok:bool,label:String):
 checks+=1
 if not ok:failures+=1;print("FAIL ",label)
func _initialize():
 var plan=preload("res://tests/split_channel_command_plan.gd")
 var s=plan.play()
 check(s.outcome=="won" and s.all_records(),"opposite relay arms and Quietus uplink recover an ordinary archive")
 check(s.tools.emp>=0 and s.tools.recon==2,"coordinated recovery uses finite observed defense without required survey")
 print("COORDINATED t=",s.elapsed," hull=",s.hull," tools=",s.tools," units=",s.units.map(func(u):return {"alive":u.alive,"pos":u.pos}))
 var solo=preload("res://src/simulation/simulation.gd").new();solo.start(1,"disruption");solo.units[1].alive=false;solo.units[2].alive=false
 var routes=preload("res://tests/campaign_scenarios.gd");var complete=true
 for id in 3:
  var objective=solo.mission.objectives[id]
  if not routes.move(solo,objective.pos+Vector2(0,180 if id<2 else 0)):complete=false;break
  if not solo.command("camera"):complete=false;break
  for n in 65:
   solo.advance(0.1)
   for contact in solo.contacts.values():
    if solo.elapsed-contact.time<.3 and contact.lock>1.0 and solo.tools.emp>0:solo.command("emp");break
 if complete:routes.move(solo,solo.mission.extraction)
 check(solo.outcome=="won","Quietus can recover both relay arms and link after drones are lost")
 check(solo.elapsed>s.elapsed+30,"opposite-arm coordination avoids the solo physical circuit")
 print("SOLO t=",solo.elapsed," hull=",solo.hull," tools=",solo.tools)
 print("EXPANDED JOURNEYS CHECKS ",checks," FAILURES ",failures)
 quit(1 if failures else 0)
