extends SceneTree
# Challenge completions, middle rows: rendezvous_middle, wake_one_charge, glass_passive, reach_quiet, glass_fast.
# Glass courses are the glass_reach_journeys.gd waypoints, the Wake course is wake_crossing_journey_tests.gd quiet-outer-solo,
# the Rendezvous course is the quiet berth path of rendezvous_transport_tests.gd. All run on ChallengeRun with live Sirens.
const R=preload("res://tests/challenge_routes.gd")
var checks=0
var failures=0
func check(ok,label):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func finish(s,id:String,route:String):
 check(s.outcome=="won","%s %s outcome is won (%s)"%[id,route,s.message])
 check(not s.result().loss,"%s %s result is not a loss"%[id,route])
 check(s.rule_failure=="","%s %s rule was not violated (%s)"%[id,route,s.rule_failure])
 R.report(id,route,s)
const COURSES={
 14:[["go",Vector2(1000,1300)],["depth",2],["go",Vector2(1000,720)],["depth",1],["go",Vector2(950,560)],["camera"],["depth",2],["go",Vector2(1000,1300)],["depth",1],["go",Vector2(2000,1800)],["exit"]],
 16:[["go",Vector2(1400,2250)],["depth",2],["go",Vector2(1400,1560)],["depth",1],["camera"],["depth",2],["go",Vector2(1400,2250)],["depth",1],["go",Vector2(700,2000)],["exit"]],
 19:[["go",Vector2(1600,1700)],["go",Vector2(1600,1200)],["go",Vector2(1600,700)],["camera"],["depth",0],["go",Vector2(725,1200)],["go",Vector2(725,1600)],["go",Vector2(1600,1700)],["exit"],["depth",1]]}
func glass(id:String,op:int):
 var s=R.fresh(id)
 for step in COURSES[op]:
  match step[0]:
   "go":check(R.go(s,0,step[1]),"%s reaches %s"%[id,step[1]])
   "depth":check(R.dive(s,0,step[1]),"%s crosses to band %d"%[id,step[1]])
   "camera":check(R.record(s,0,0),"%s receives the account"%id)
   "exit":check(R.go(s,0,s.mission.corridors[0].pos),"%s reaches the recovery mouth"%id)
  if not s.outcome.is_empty():break
 finish(s,id,"glass_course")
func wake():
 var s=R.fresh("wake_one_charge")
 check(R.course(s,0,[Vector2(700,1540),Vector2(580,1320),Vector2(60,1320),Vector2(60,620),Vector2(300,620)]),"wake Quietus reaches the western onward packet")
 s.command("select",{"unit":0});check(s.command("camera"),"wake Quietus receives the onward packet")
 R.tick(s,25.)
 check(s.all_records(),"wake real passive decode earns the packet before the crossing")
 check(R.course(s,0,[Vector2(60,620),Vector2(60,160),s.mission.extraction]),"wake Quietus crosses the outer water and returns")
 finish(s,"wake_one_charge","quiet_outer")
func rendezvous():
 var s=R.fresh("rendezvous_middle")
 check(R.go(s,0,Vector2(380,760)),"rendezvous Quietus reaches the quiet western berth")
 R.tick(s,.8)
 check(R.record(s,0,0) and s.all_records(),"rendezvous Quietus keeps the berth packet")
 check(R.go(s,0,s.mission.extraction),"rendezvous Quietus recovers by the north trench")
 finish(s,"rendezvous_middle","quiet_berth")
func _initialize():
 var only=OS.get_cmdline_user_args()
 if only.is_empty() or "rendezvous" in only:rendezvous()
 if only.is_empty() or "wake" in only:wake()
 if only.is_empty() or "glass14" in only:glass("glass_passive",14)
 if only.is_empty() or "reach" in only:glass("reach_quiet",16)
 if only.is_empty() or "fast" in only:glass("glass_fast",19)
 print("CHALLENGES COMPLETIONS REACH CHECKS ",checks," FAILURES ",failures)
 quit(1 if failures else 0)
