extends SceneTree
# Route pars: par chosen by the route taken, per-route bests beside the overall best, optional validated save field.
const Catalog=preload("res://src/campaign/challenges/challenge_catalog.gd")
const Records=preload("res://src/campaign/challenges/challenge_records.gd")
const Run=preload("res://src/campaign/challenges/challenge_run.gd")
var checks=0
var failures=0
func check(ok,label):
	checks+=1
	if not ok:failures+=1;printerr("FAIL ",label)
func won(time:float,route:String="")->Dictionary:
	var out={"time":time,"hull":100.,"tools_used":{},"loss":false,"lost_craft":0,"loud_time":0.}
	if not route.is_empty():out.route=route
	return out
func _initialize():
	var row=Catalog.get_challenge("lung_solo")
	check(Records.par_for(row,won(1.,"dismantle")).time==110. and Records.par_for(row,won(1.,"reconnect")).time==300.,"lung_solo par follows the route taken")
	check(Records.par_for(row,won(1.)).time==110. and Records.par_for(row,won(1.,"bypass")).time==110.,"no or unknown route uses the base par")
	check(Records.pars(row,won(273.6,"reconnect"))==3 and Records.pars(row,won(273.6))==2,"a 273.6 s reconnect meets all pars only by route")
	var other=Catalog.get_challenge("shelf_passive")
	check(Records.par_for(other,won(1.,"reconnect")).time==90.,"rows without route pars ignore a route")
	var records=Records.add({},"lung_solo",won(79.3,"dismantle"))
	records=Records.add(records,"lung_solo",won(273.6,"reconnect"))
	check(records.lung_solo.best.route=="dismantle","overall best keeps the faster dismantle")
	check(records.lung_solo.routes.reconnect.time==273.6,"a fast dismantle never erases the reconnect best")
	records=Records.add(records,"lung_solo",won(250.,"reconnect"))
	records=Records.add(records,"lung_solo",won(290.,"reconnect"))
	check(records.lung_solo.routes.reconnect.time==250. and records.lung_solo.routes.dismantle.time==79.3,"each route keeps its own best")
	check(records.lung_solo.attempts==4 and Records.valid(records),"attempts count and the shape validates")
	records=Records.add(records,"lung_solo",{"time":50.,"hull":10.,"tools_used":{},"loss":true,"route":"dismantle"})
	check(records.lung_solo.routes.dismantle.time==79.3,"a loss never replaces a route best")
	check(Records.route_lines(row,records.lung_solo).size()==2 and Records.route_lines(other,{}).is_empty(),"route lines list only route-par rows")
	var saved=str_to_var(var_to_str(records))
	check(Records.valid(saved) and saved.lung_solo.routes.reconnect.time==250.,"records round trip through text")
	var old={"lung_solo":{"attempts":1,"last":won(90.),"best":won(90.)}}
	check(Records.valid(old),"an old save without routes or route stays valid")
	var bad=records.duplicate(true);bad.lung_solo.routes.reconnect.loss=true
	check(not Records.valid(bad),"a lost result is rejected as a route best")
	bad=records.duplicate(true);bad.lung_solo.routes[""]=won(1.)
	check(not Records.valid(bad),"an empty route name is rejected")
	bad=records.duplicate(true);bad.lung_solo.routes="x"
	check(not Records.valid(bad),"routes of the wrong type are rejected")
	bad=records.duplicate(true);bad.lung_solo.best.route=5
	check(not Records.valid(bad),"a non-string route is rejected")
	bad=records.duplicate(true);bad.lung_solo.best.route="x".repeat(33)
	check(not Records.valid(bad),"an over-long route is rejected")
	bad=records.duplicate(true)
	for n in 9:bad.lung_solo.routes["r%d"%n]=won(1.)
	check(not Records.valid(bad),"too many routes are rejected")
	var s=Run.new();check(s.setup("lung_solo"),"lung_solo starts")
	check(s.route()=="" and not s.result().has("route"),"no committed choice gives no route")
	s.mission.iron_choir.choice="reconnect"
	check(s.route()=="reconnect" and s.result().route=="reconnect","the recorded mission choice becomes the result route")
	var plain=Run.new();plain.setup("shelf_passive")
	check(plain.route()=="" and not plain.result().has("route"),"other rows record no route")
	print("CHALLENGES ROUTE PARS CHECKS ",checks," FAILURES ",failures)
	quit(1 if failures else 0)
