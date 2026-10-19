extends SceneTree
const Route=preload("res://src/simulation/route_program.gd")
var checks=0
var failures=0
func check(ok,label):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func path(a,b):return [{"pos":a.lerp(b,0.5),"stop":false},{"pos":b,"stop":true}]
func _initialize():
 var work={"pos":Vector2(650,1120),"stop":true,"mode":"silent","task_site":"chain_west"}
 var back={"pos":Vector2(1000,1880),"stop":true,"mode":"cruise"}
 var plan=[work,back];var dimensions=Vector2(2000,2080)
 check(Route.valid_goals(plan,dimensions),"explicit task then withdrawal accepted as operator intent")
 for bad in ["",12,"not a site"]:
  var invalid=work.duplicate(true);invalid.task_site=bad
  check(not Route.valid_goals([invalid],dimensions),"malformed task identifier rejects: "+str(bad))
 var passthrough=work.duplicate(true);passthrough.stop=false
 check(not Route.valid_goals([passthrough],dimensions),"fieldwork cannot be a PASS waypoint")
 var legacy=work.duplicate(true);legacy.legacy=true
 check(not Route.valid_goals([legacy],dimensions),"legacy endpoint cannot silently acquire new task")
 var compiled=Route.compile(Vector2(1000,1880),plan,path,dimensions)
 check(compiled.ok and compiled.route[1].get("task_site","")=="chain_west","compile carries task only onto physical final arrival node")
 check(not compiled.route[0].has("task_site") and not compiled.route[2].has("task_site") and not compiled.route[3].has("task_site"),"avoidance corners and withdrawal remain ordinary route nodes")
 check(not Route.valid_unit({"route":compiled.route,"silent":true},false,dimensions),"legacy route without explicit accepted plan cannot acquire executable task")
 var u={"name":"DRONE A","pos":Vector2(1000,1880),"vel":Vector2.ZERO,"route":compiled.route,"route_plan":plan,"route_undo":[plan.duplicate(true)],"silent":true}
 check(Route.valid_unit(u,false,dimensions),"optional task plan and undo validate together")
 var saved=bytes_to_var(var_to_bytes(u));check(saved==u and Route.valid_unit(saved,false,dimensions),"task intent/undo survives exact serialization without capture timer")
 var corrupt=u.duplicate(true);corrupt.route[0].task_site="chain_west"
 check(not Route.valid_unit(corrupt,false,dimensions),"terrain corner cannot execute task early")
 corrupt=u.duplicate(true);corrupt.route[1].task_site="chain_east"
 check(not Route.valid_unit(corrupt,false,dimensions),"runtime node cannot substitute a different known task")
 u.task_run={"site_id":"chain_west","phase":"running","resume_hold":"SCOUT"}
 check(Route.valid_unit(u,false,dimensions),"clockless running marker belongs to current accepted task")
 corrupt=u.duplicate(true);corrupt.task_run.site_id="chain_east"
 check(not Route.valid_unit(corrupt,false,dimensions),"orphan/mismatched execution marker rejects")
 var old={"route":[],"silent":true};var bytes=var_to_bytes(old)
 check(Route.valid_unit(old,false,dimensions) and var_to_bytes(old)==bytes,"untouched old unit remains byte-exact without optional state")
 var copy=Route.goals(u);copy[0].task_site="changed"
 check(u.route_plan[0].task_site=="chain_west","editing intent copy cannot change accepted current task")
 var completed=u.duplicate(true);Route.arrived(completed,compiled.route[1])
 check(completed.route_plan==[back] and not completed.has("task_run"),"canonical completion pop releases tail and clears completed execution marker")
 Route.clear(u);check(not u.has("task_run") and not u.has("route_plan") and not u.has("route_undo"),"explicit route clear removes task bookkeeping")
 print("OBSERVED TASK ROUTE CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
