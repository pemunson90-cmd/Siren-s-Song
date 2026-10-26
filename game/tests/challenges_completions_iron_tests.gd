extends SceneTree
# Challenge completions, Iron Choir rows: stair_no_charges, lung_solo by both routes.
# Routes are the existing iron_choir_journeys.gd courses replayed on ChallengeRun with its own loadout,
# rule and live Sirens. Measured numbers feed docs/design/CHALLENGE_PARS_PROPOSAL.md; no par is changed here.
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
func stair():
 var s=R.fresh("stair_no_charges")
 var st=s.mission.iron_choir.sites
 check(R.go(s,0,st[0].pos+Vector2(0,35)),"stair reaches lock_a below first bulkhead");check(R.choir(s,"lock_a"),"stair cycles lock_a")
 check(R.course(s,0,[Vector2(650,1785),Vector2(1250,1385)]),"stair climbs to the shallow valve")
 check(R.dive(s,0,0),"stair rises to shallow");check(R.choir(s,"lock_b"),"stair cycles lock_b")
 check(R.course(s,0,[Vector2(1430,1195),Vector2(2400,800)]),"stair passes second bulkhead")
 check(R.dive(s,0,1) and R.dive(s,0,2),"stair drops to deep")
 check(R.go(s,0,Vector2(2400,690)),"stair reaches deep valve");check(R.choir(s,"lock_c"),"stair cycles lock_c")
 check(R.dive(s,0,1),"stair surfaces to middle")
 check(R.course(s,0,[Vector2(1430,1195),Vector2(1430,1500),Vector2(650,1785),Vector2(650,2000),Vector2(300,2350)]),"stair returns down the opened stair")
 finish(s,"stair_no_charges","lock_cycle")
 check(s.tools_used()==0,"stair spends no charge")
func lung(route:String):
 var s=R.fresh("lung_solo")
 check(not s.units[1].alive and not s.units[2].alive,"lung drones stay ashore")
 if route=="dismantle":
  check(R.course(s,0,[Vector2(500,2000),Vector2(850,1500),Vector2(700,1285)]),"lung reaches the western feed room")
  check(R.choir(s,"dismantle") and s.mission.iron_choir.choice=="dismantle","lung dismantle commits")
  check(R.course(s,0,[Vector2(850,1500),Vector2(500,2000),Vector2(300,2350)]),"lung dismantle account recovers")
 else:
  check(R.course(s,0,[Vector2(700,2250)]) and R.choir(s,"lock_c"),"lung far breaker thrown")
  check(R.course(s,0,[Vector2(300,2450),Vector2(2750,2450),Vector2(2750,500),Vector2(2450,500)]),"lung plant approach")
  check(R.choir(s,"reconnect"),"lung reconnects the plant")
  check(R.course(s,0,[Vector2(2750,500),Vector2(2750,2450),Vector2(300,2450),Vector2(300,2350)]),"lung reconnect account recovers")
 finish(s,"lung_solo",route)
func _initialize():
 var only=OS.get_cmdline_user_args()
 if only.is_empty() or "stair" in only:stair()
 if only.is_empty() or "dismantle" in only:lung("dismantle")
 if only.is_empty() or "reconnect" in only:lung("reconnect")
 print("CHALLENGES COMPLETIONS IRON CHECKS ",checks," FAILURES ",failures)
 quit(1 if failures else 0)
