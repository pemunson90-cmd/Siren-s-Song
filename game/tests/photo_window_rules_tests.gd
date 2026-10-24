extends SceneTree
const Table=preload("res://src/photo_rules/rule_table.gd")
const WinCheck=preload("res://src/photo_rules/window_check.gd")
const Post=preload("res://src/photo_rules/post_clock.gd")
const Rules=preload("res://src/photo_rules/photo_rules.gd")
var checks=0
var failures=0
func check(ok,label):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():call_deferred("run")
func unit(pos:=Vector2.ZERO,route:=[],silent:=false):return {"alive":true,"pos":pos,"route":route,"silent":silent}
func run():
 # Craft speeds.
 check(WinCheck.craft_speed({"silent":true},0)==42.0 and WinCheck.craft_speed({},0)==78.0 and WinCheck.craft_speed({"silent":true},1)==96.0,"speed: silent 42, cruise 78, any drone 96")
 # Arrival: straight-line less the standoff, never negative; routes sum their legs.
 check(is_equal_approx(WinCheck.arrival(unit(Vector2.ZERO),0,Vector2(178,0)),1.0),"direct arrival is (distance - 100) / 78")
 check(WinCheck.arrival(unit(Vector2.ZERO),0,Vector2(50,0))==0.0,"inside the standoff arrives immediately")
 var legs=[{"pos":Vector2(78,0)},{"pos":Vector2(78,156)}]
 check(is_equal_approx(WinCheck.arrival(unit(Vector2.ZERO,legs),0,Vector2(9999,9999)),3.0),"a route sums its legs and ignores the subject position")
 # evaluate: period 30, open 7, phase 0.
 var go=WinCheck.evaluate(0.0,30.0,7.0,0.0,2.0)
 check(go.state=="go" and go.text=="OPEN 7s · you arrive in 2s · GO","open now and still open on arrival is GO")
 var margin=WinCheck.evaluate(0.0,30.0,7.0,0.0,5.0)
 check(margin.state=="go","exactly GO_MARGIN of window left is still GO")
 var late_edge=WinCheck.evaluate(0.0,30.0,7.0,0.0,5.5)
 check(late_edge.state=="late" and is_equal_approx(late_edge.wait,24.5),"less than the margin left on arrival is LATE")
 var wait=WinCheck.evaluate(10.0,30.0,7.0,0.0,5.0)
 check(wait.state=="wait" and wait.text=="OPENS IN 20s · you arrive in 5s · WAIT 15s","closed now, arriving before the next opening is WAIT")
 check(is_equal_approx(wait.wait,15.0),"wait is the time from arrival to the next opening")
 var long=WinCheck.evaluate(8.0,60.0,5.0,0.0,1.0)
 check(long.state=="late" and long.text.contains("TOO LATE"),"a wait over WAIT_LIMIT reads TOO LATE")
 check(WinCheck.evaluate(8.0,60.0,5.0,0.0,1.0).wait>Table.WAIT_LIMIT,"the late wait exceeds the limit")
 var phased=WinCheck.evaluate(0.0,30.0,7.0,25.0,0.0)
 check(phased.state=="wait" and is_equal_approx(phased.wait,5.0) and WinCheck.evaluate(5.0,30.0,7.0,0.0,0.0).text==WinCheck.evaluate(0.0,30.0,7.0,5.0,0.0).text,"phase and clock are interchangeable offsets")
 check(WinCheck.evaluate(30.0,30.0,7.0,0.0,0.0).text==WinCheck.evaluate(0.0,30.0,7.0,0.0,0.0).text,"the clock wraps by one whole period")
 check(WinCheck.evaluate(-1.0,30.0,7.0,0.0,0.0).state==WinCheck.evaluate(29.0,30.0,7.0,0.0,0.0).state,"a negative clock wraps like fposmod")
 # entries filters findings and reads the selected craft.
 var findings=[{"id":"c1","kind":"cycle","period":30.0,"open":7.0,"pos":[400,0]},{"id":"bad","kind":"cycle","period":0.0,"pos":[0,0]},{"id":"x","kind":"loop","pos":[0,0]},{"id":"nopos","kind":"cycle","period":10.0}]
 var sim={"selected":0,"elapsed":0.0,"units":[unit()],"mission":{"photo":{"findings":findings}}}
 var ents=WinCheck.entries(sim)
 check(ents.size()==1 and ents[0].id=="c1" and ents[0].pos==Vector2(400,0),"only well-formed cycle findings produce a window")
 sim.units[0].alive=false
 check(WinCheck.entries(sim).is_empty(),"a lost craft has no window plan")
 sim.units[0].alive=true
 check(WinCheck.camera_line(sim,Vector2(410,10)).begins_with("OPEN") and WinCheck.camera_line(sim,Vector2(500,0))=="","camera line matches only a subject within 24 m of the cycle")
 # Rules.camera_hint leaves the context alone unless a window matches.
 var ctx={"ready":false,"text":"X"}
 check(Rules.camera_hint(sim,ctx).text=="X","hint ignores an unready frame")
 check(Rules.camera_hint(sim,{"ready":true,"target":-1,"text":"X"}).text=="X","hint ignores no target")
 sim.mission.objectives=[{"pos":Vector2(400,0)},{"pos":Vector2(0,900)}]
 check(Rules.camera_hint(sim,{"ready":true,"target":5,"text":"X"}).text=="X","hint ignores an out-of-range target")
 check(Rules.camera_hint(sim,{"ready":true,"target":1,"text":"X"}).text=="X","hint ignores a subject with no cycle")
 var hinted=Rules.camera_hint(sim,{"ready":true,"target":0,"text":"X"})
 check(hinted.text.begins_with("X · OPEN"),"hint appends the window line after a separator")
 # Post return clock.
 var post_f={"id":"post_1","kind":"post","pos":[100,0],"r":50.0}
 var psim={"elapsed":10.0,"sirens":[{},{}],"contacts":{1:{"source":"optical","time":8.0,"pos":Vector2(350,0),"mode":"SEARCH"}},"mission":{"photo":{"findings":[post_f]}}}
 var pe=Post.entries(psim)
 check(pe.size()==1 and is_equal_approx(pe[0].back,250.0/48.0) and pe[0].state=="live","alerted sentinel outside its tether returns at 48 m/s")
 psim.contacts[1].mode="PATROL"
 check(is_equal_approx(Post.entries(psim)[0].back,10.0),"a calm sentinel walks back at 25 m/s")
 psim.contacts[1].mode="RETURN"
 check(is_equal_approx(Post.entries(psim)[0].back,(250.0-25.0*2.0)/25.0),"a returning sentinel has already covered part of the way")
 psim.contacts[1].time=-20.0
 check(Post.entries(psim).is_empty(),"a contact older than STALE_AFTER is dropped")
 psim.contacts[1].time=8.0;psim.contacts[1].pos=Vector2(140,0)
 check(Post.entries(psim).is_empty(),"a sentinel inside its tether needs no clock")
 psim.contacts[1].pos=Vector2(350,0);psim.contacts[1].source="sonar"
 check(Post.entries(psim).is_empty(),"only optical contacts count")
 psim.contacts[1].source="optical";psim.elapsed=20.0
 check(Post.entries(psim)[0].state=="aging" and Post.text(Post.entries(psim)[0]).ends_with("AGING"),"older than AGING_AFTER is marked aging")
 psim.mission.photo.findings=[{"id":"post_9","kind":"post","pos":[0,0],"r":1.0},{"id":"gate_1","kind":"post","pos":[0,0],"r":1.0}]
 check(Post.entries(psim).is_empty(),"out-of-range or non-post ids are skipped")
 print("PHOTO WINDOW RULES CHECKS %d FAILURES %d"%[checks,failures])
 quit(1 if failures>0 else 0)
