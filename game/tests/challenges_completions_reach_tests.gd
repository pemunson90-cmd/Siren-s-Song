extends SceneTree
# Challenge completions, middle rows: rendezvous_middle, wake_one_charge, glass_passive, reach_quiet, glass_fast.
# Glass courses are the glass_reach_journeys.gd waypoints, the Wake course is wake_crossing_journey_tests.gd quiet-outer-solo,
# the Rendezvous course is the quiet berth path of rendezvous_transport_tests.gd. All run on ChallengeRun with live Sirens.
const R=preload("res://tests/challenge_routes.gd")
const Glass=preload("res://tests/glass_reach_journeys.gd")
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
 14:Glass.COURSES[14],
 # Physically scout the western return, as in the earned-chart campaign journey.
 # The direct recovery leg assumed the whole detour was already measured.
 16:Glass.COURSES[16],
 19:[["go",Vector2(1600,1700)],["go",Vector2(1600,1200)],["go",Vector2(1600,700)],["camera"],["depth",0],["go",Vector2(725,1200)],["go",Vector2(725,1600)],["go",Vector2(1600,1700)],["exit"],["depth",1]]}
func glass(id:String,op:int):
 var s=R.fresh(id)
 if op==16:check(s.mission.earned_terrain and not s.terrain_chart.is_clear(s.mission.corridors[0].pos),"reach recovery starts unmeasured")
 for step in COURSES[op]:
  match step[0]:
   "go":check(R.go(s,0,step[1],22.,op in [14,16]),"%s reaches %s"%[id,step[1]])
   "depth":check(R.dive(s,0,step[1]),"%s crosses to band %d"%[id,step[1]])
   "wait":R.tick(s,float(step[1]))
   "camera":check(R.record(s,0,0),"%s receives the account"%id)
   "exit":check(R.go(s,0,s.mission.corridors[0].pos,22.,op in [14,16]),"%s reaches the recovery mouth"%id)
  if not s.outcome.is_empty():break
 finish(s,id,"glass_course")
 if op==16:check(s.tools_used()==0,"reach passive return spends no finite charges")
func wake():
 var s=R.fresh("wake_one_charge")
 check(R.course(s,0,[Vector2(700,1540),Vector2(580,1320),Vector2(60,1320),Vector2(60,620),Vector2(300,620)]),"wake Quietus reaches the western onward packet")
 s.command("select",{"unit":0});check(s.command("camera"),"wake Quietus receives the onward packet")
 # The local packet is a four-second decode. Waiting another 21 seconds
 # after it is aboard spends the authored 105-second crossing reserve.
 R.tick(s,4.3)
 check(s.all_records(),"wake real passive decode earns the packet before the crossing")
 check(s.mission.objectives.any(func(o):return o.get("site_id","")=="wake_packet" and o.captured),"wake required local packet is actually received")
 check(R.course(s,0,[Vector2(60,620),Vector2(60,160),s.mission.extraction]),"wake Quietus crosses the outer water and returns")
 finish(s,"wake_one_charge","quiet_outer")
func rendezvous():
 var s=R.fresh("rendezvous_middle")
 # A real independent receiver works the required saddle while Quietus
 # approaches the tender. Neither source knowledge nor completion is injected.
 s.command("select",{"unit":1})
 check(s.command("drone_drive",{"mode":"quiet"}),"rendezvous helper uses quiet thrust")
 check(s.command("route",{"point":Vector2(650,1120)}),"rendezvous helper approaches the saddle service")
 check(R.go(s,0,Vector2(380,760)),"rendezvous Quietus reaches the quiet western berth")
 R.tick(s,.8)
 var packet=s.mission.objectives.filter(func(o):return o.get("site_id","")=="rendezvous")
 check(packet.size()==1 and s.rendezvous_context().vessel.live,"rendezvous actual local carrier observation exposes its packet")
 check(R.go(s,1,Vector2(650,1120)) and R.record(s,1,0),"rendezvous helper receives the required saddle service account")
 s.command("select",{"unit":1})
 check(s.command("route",{"point":Vector2(520,980)}),"rendezvous helper starts its physical return")
 s.command("queue")
 for point in [Vector2(440,760),Vector2(440,300),s.mission.extraction]:
  check(s.command("route",{"point":point}),"rendezvous helper queues its clear return water")
 s.command("queue")
 check(packet.size()==1 and R.record(s,0,s.mission.objectives.find(packet[0])) and s.all_records(),"rendezvous Quietus keeps the berth packet")
 check(packet.size()==1 and packet[0].captured,"rendezvous Quietus actually decodes the observed tender packet")
 # Give the quietly returning receiver a three-second lead before Quietus
 # commits the final leg; recovery ends simulation for every craft.
 R.tick(s,3.)
 check(R.go(s,0,s.mission.extraction),"rendezvous Quietus recovers by the north trench")
 check(s.units[1].alive and s.units[1].pos.distance_to(s.mission.extraction)<180,"rendezvous service helper returns alive to recovery water")
 print("RENDEZVOUS HELPER pos=",s.units[1].pos," route=",s.units[1].route," alive=",s.units[1].alive," battery=",s.units[1].battery)
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
