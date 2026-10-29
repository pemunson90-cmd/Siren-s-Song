extends SceneTree
# Challenge completions, opening rows: split_solo, foundry_no_charges, well_intact, song_fleet.
# Routes are the existing opening_depth_journeys.gd courses and the expanded_region solo circuit, run on ChallengeRun
# with its own loadout and rule, patient_play rehearsals before each exposure and live Sirens. No par is changed here.
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
func split():
 # The west guard holds MIDDLE and the east guard DEEP, so Quietus works the arms from SHALLOW, then drops to MIDDLE for the uplink.
 var s=R.fresh("split_solo")
 check(not s.units[1].alive and not s.units[2].alive,"split drones stay ashore")
 check(R.dive(s,0,0),"split Quietus rises to shallow cover")
 check(R.course(s,0,[Vector2(700,2050),Vector2(700,1700),Vector2(420,1300),Vector2(420,625)]) and R.record(s,0,0),"split Quietus records the west relay from shallow")
 check(R.course(s,0,[Vector2(900,760),Vector2(1300,800),Vector2(1550,940)]) and R.record(s,0,1),"split Quietus crosses the northern saddle and records the east relay")
 check(R.course(s,0,[Vector2(1160,1000),Vector2(1160,1450)]) and R.dive(s,0,1),"split Quietus drops to MIDDLE above the uplink mouth")
 check(R.go(s,0,Vector2(1110,1660)) and R.record(s,0,2),"split Quietus links the two arms")
 check(R.course(s,0,[Vector2(700,1750),Vector2(650,2060),s.mission.extraction]),"split Quietus returns to extraction")
 finish(s,"split_solo","shallow_saddle")
func foundry():
 var s=R.fresh("foundry_no_charges")
 check(R.dive(s,0,2) and R.go(s,0,Vector2(960,500)),"foundry Quietus crosses beneath the central spine")
 s.command("select",{"unit":1});s.command("drone_drive",{"mode":"quiet"})
 check(R.go(s,1,Vector2(1090,580),18) and R.record(s,1,0),"foundry middle drone records the furnace")
 s.command("select",{"unit":1});s.command("drone_drive",{"mode":"transit"});s.command("route",{"point":Vector2(1080,820)})
 check(R.go(s,0,Vector2(1060,580)) and R.go(s,0,Vector2(1060,820)),"foundry deep transit to the southern spur")
 R.lull(s,0,1,1)
 check(R.dive(s,0,1) and R.go(s,0,Vector2(1110,820)) and R.record(s,0,1),"foundry Quietus ascends and records the cradle")
 check(R.go(s,0,s.mission.extraction),"foundry middle recovery")
 finish(s,"foundry_no_charges","opening_depth")
func well():
 var s=R.fresh("well_intact")
 check(R.dive(s,0,0) and R.go(s,0,Vector2(360,590)) and R.go(s,0,Vector2(800,390)),"well shallow west crossing")
 check(R.dive(s,0,1) and R.record(s,0,0),"well middle receiver records the pattern")
 check(R.dive(s,0,2) and R.go(s,0,Vector2(1150,380)),"well deep east passage")
 R.lull(s,0,1,1,Vector2(1000,650));check(R.dive(s,0,1) and R.record(s,0,1),"well middle aperture image")
 check(R.dive(s,0,2) and R.go(s,0,Vector2(1000,650)) and R.go(s,0,Vector2(560,850)),"well deep withdrawal")
 check(R.go(s,0,Vector2(620,835)),"well southern approach");R.lull(s,0,1,2);check(R.dive(s,0,1) and R.record(s,0,2),"well southern archive")
 check(R.dive(s,0,2) and R.go(s,0,s.mission.extraction) and R.dive(s,0,1),"well archive returns beneath the woken hunter")
 finish(s,"well_intact","opening_depth")
func song():
 var s=R.fresh("song_fleet")
 check(R.dive(s,0,2) and R.go(s,0,Vector2(360,650)) and R.go(s,0,Vector2(950,400)) and R.go(s,0,Vector2(1180,40)),"song deep central crossing")
 R.lull(s,0,1,0);check(R.dive(s,0,1) and R.record(s,0,0),"song crown observation")
 check(R.dive(s,0,0) and R.go(s,0,Vector2(1180,400)) and R.go(s,0,Vector2(1180,760)) and R.go(s,0,Vector2(1250,870)),"song shallow eastern crossing")
 R.lull(s,0,1,1);check(R.dive(s,0,1) and R.record(s,0,1),"song wake observation")
 check(R.go(s,0,Vector2(690,780)) and R.record(s,0,2),"song listens in the middle lee")
 check(R.go(s,0,s.mission.extraction),"song decoded warning returns")
 check(s.units.all(func(u):return u.alive),"song every launched craft is home alive")
 finish(s,"song_fleet","opening_depth")
func _initialize():
 var only=OS.get_cmdline_user_args()
 if only.is_empty() or "split" in only:split()
 if only.is_empty() or "foundry" in only:foundry()
 if only.is_empty() or "well" in only:well()
 if only.is_empty() or "song" in only:song()
 print("CHALLENGES COMPLETIONS OPENING CHECKS ",checks," FAILURES ",failures)
 quit(1 if failures else 0)
