extends SceneTree
var checks=0
var failures=0
func check(ok,label):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():
 var path="res://src/simulation/observed_task_plan.gd"
 if not ResourceLoader.exists(path):check(false,"observed task goal offers canonical work decisions without another timer")
 else:
  var task=load(path)
  var goal={"pos":Vector2(650,1120),"stop":true,"mode":"inherit","task_site":"chain_west"}
  var sites=[{"site_id":"chain_west","kind":"receiver","pos":Vector2(480,1000),"captured":false,"required_unit":0,"sampler_compatible":true}]
  var fitted={"drone_a":"drone_sampler"}
  var unit={"alive":true,"pos":goal.pos,"vel":Vector2.ZERO,"hold":""}
  var context={"paused":false,"guard_blocked":false,"ready":true,"capture_unit":-1,"capture_site":""}
  check(task.qualify(goal,sites,1,fitted).ok,"charted static receiver and fitted craft qualify")
  check(not task.qualify(goal,[],1,fitted).ok,"unknown source cannot become task by guessed ID")
  check(not task.qualify(goal,sites,1,{}).ok and task.qualify(goal,sites,0,{}).ok,"hardware gates only remote field ability, Quietus keeps baseline task")
  var moving=sites.duplicate(true);moving[0].moving=true
  check(not task.qualify(goal,moving,1,fitted).ok,"moving sources excluded from static task scope")
  var operation=sites.duplicate(true);operation[0]["completion_open_structure"]="sluice"
  check(not task.qualify(goal,operation,0,{}).ok,"active machinery cannot be disguised as quiet receiver fieldwork")
  var duplicate=sites.duplicate(true);duplicate.append(sites[0].duplicate(true))
  check(not task.qualify(goal,duplicate,1,fitted).ok,"ambiguous public site identifier rejects")
  var before=[goal.duplicate(true),sites.duplicate(true),unit.duplicate(true),context.duplicate(true)]
  check(task.decide(goal,sites,unit,1,fitted,context).action=="begin","arrived settled compatible task requests canonical begin")
  check(before==[goal,sites,unit,context],"decision cannot mutate route, capture clock or actors")
  context.paused=true;check(task.decide(goal,sites,unit,1,fitted,context).action=="wait","paused simulation cannot start fieldwork")
  context.paused=false;unit.vel=Vector2(3,0)
  check(task.decide(goal,sites,unit,1,fitted,context).reason=="settle","real residual motion delays work")
  unit.vel=Vector2.ZERO;unit.pos=Vector2(650,1160)
  check(task.decide(goal,sites,unit,1,fitted,context).reason=="travel","task cannot begin before accepted arrival")
  unit.pos=goal.pos;context.capture_unit=0;context.capture_site="chain_east"
  check(task.decide(goal,sites,unit,1,fitted,context).reason=="channel_busy","another canonical capture is not cancelled or duplicated")
  context.capture_unit=1;context.capture_site="chain_west"
  check(task.decide(goal,sites,unit,1,fitted,context).reason=="working","own canonical capture continues without another begin")
  unit.task_run={"site_id":"chain_west","phase":"running","resume_hold":"SCOUT"}
  context.capture_unit=-1;context.capture_site=""
  check(task.decide(goal,sites,unit,1,fitted,context).action=="blocked","interrupted canonical work never silently restarts")
  sites[0].captured=true
  check(task.decide(goal,sites,unit,1,fitted,context).action=="complete","actual captured fact alone permits queued continuation")
  sites[0].captured=false;unit.erase("task_run");context.guard_blocked=true
  check(task.decide(goal,sites,unit,1,fitted,context).reason=="guard","SCOUT WAIT and manual HOLD remain authoritative")
  context.guard_blocked=false;context.ready=false
  check(task.decide(goal,sites,unit,1,fitted,context).action=="blocked","physical capture readiness is never bypassed")
  context.ready=true;unit.alive=false
  check(task.decide(goal,sites,unit,1,fitted,context).action=="blocked","lost craft does not complete fieldwork")
  check(task.valid_run({}) and task.valid_run({"site_id":"chain_west","phase":"blocked","resume_hold":""}),"optional clockless runtime state validates")
  check(not task.valid_run({"site_id":"chain_west","phase":"running","resume_hold":"","time":8}) and not task.valid_run({"site_id":"chain_west","phase":"done","resume_hold":""}),"invented progress and completion status reject")
 print("OBSERVED TASK PLAN CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
