extends SceneTree
const Sim=preload("res://src/simulation/simulation.gd")
var checks=0
var failures=0
var last_emp={}
func check(ok,label):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func make():
 var s=Sim.new();s.start(10,"disruption",{"fitted":{"quietus":"","drone_a":"drone_sampler","drone_b":""}});return s
func protect(s):
 if s.elapsed-last_emp.get(s.get_instance_id(),-10.0)<0.3:return
 for c in s.contacts.values():
  if s.elapsed-c.time<0.3 and c.get("lock",0)>=1 and s.tools.emp>0:
   for id in c.get("seen_by",[]):
    if s.units[id].alive and s.units[id].pos.distance_to(c.pos)<340:
     var selected=s.selected;s.command("select",{"unit":id});s.command("emp");last_emp[s.get_instance_id()]=s.elapsed;s.command("select",{"unit":selected});return
func step(s,count):
 s.paused=false
 for n in count:
  s.advance(1./60)
  if n%18==0:protect(s)
func plan(s):
 s.command("select",{"unit":1});s.command("route",{"point":Vector2(650,1120)})
 var accepted=s.command("route_edit",{"index":0,"task_site":"chain_west"})
 s.command("waypoint_mode");s.command("queue");s.command("route",{"point":Vector2(1000,1780)});s.command("select",{"unit":0})
 return accepted and s.route_goals(1)[0].get("task_site","")=="chain_west"
func _initialize():
 var s=make()
 check(plan(s),"existing route edit explicitly binds observed task and queued return")
 if s.route_goals(1)[0].get("task_site","")!="chain_west":finish();return
 check(s.route_goals(1)[0].stop and s.route_goals(1).size()==2,"QUEUE in PASS mode cannot erase task STOP")
 var old=make();var legacy=old.snapshot();check(not legacy.units.any(func(u):return u.has("task_run")),"task-absent initial snapshot adds no runtime bookkeeping")
 check(s.task_options(1,Vector2(650,1120)).any(func(o):return o.site_id=="chain_west" and o.duration==8.0 and o.audible),"public task choices describe actual fitted eight-second audible job")
 check(s.task_options(2,Vector2(650,1120)).is_empty() and s.task_options(1,Vector2(1000,1880)).is_empty(),"unfitted craft and out-of-reach point expose no task options")
 var accepted=s.snapshot();s.command("select",{"unit":1});var before=s.snapshot()
 check(not s.command("route_edit",{"index":0,"task_site":"guessed_hidden"}) and s.snapshot()==before,"unknown task edit rejects atomically")
 check(not s.command("route_edit",{"index":0,"stop":false}) and s.message.contains("Remove TASK"),"task cannot turn into PASS without explaining TASK removal")
 s.command("select",{"unit":0})
 for n in 1200:
  step(s,1)
  if s.capture_unit==1:break
 check(s.capture_unit==1 and s.capture_target==0 and s.selected==0,"arrived task starts canonical fieldwork without changing player selection")
 check(s.units[1].route.size()>1 and s.route_goals(1).size()==2 and s.units[1].task_run.phase=="running","task retains actual arrival node and withdrawal tail during work")
 check(s.capture_feedback().duration==8.0 and s.noises.any(func(n):return n.label=="CAMERA"),"task uses canonical fitted duration and audible exposure")
 s.paused=true;var inflight=s.snapshot();s.advance(10)
 check(s.snapshot()==inflight,"pause freezes task and sole capture channel")
 var copy=make();check(copy.restore(inflight) and copy.snapshot()==inflight,"in-flight task and canonical capture save/restore exactly")
 var unknown=inflight.duplicate(true);unknown.units[1].route_plan[0].task_site="guessed_hidden"
 for node in unknown.units[1].route:
  if node.get("task_site","")=="chain_west":node.task_site="guessed_hidden"
 unknown.units[1].task_run.site_id="guessed_hidden"
 check(not Sim.valid_snapshot(unknown),"saved task cannot bind unobserved source despite internally matching schema")
 var invalid_clock=inflight.duplicate(true);invalid_clock.capture_time=INF
 check(not Sim.valid_snapshot(invalid_clock),"running task cannot restore forged canonical progress")
 # Controlled own-intent fixture from a real in-flight save: preserve an
 # armed guard through canonical HOLD, then use its ACTUAL fresh own contacts.
 var guarded=inflight.duplicate(true);guarded.units[1].task_run.resume_hold="SCOUT"
 var scout=make();check(scout.restore(guarded),"saved armed guard remains bound to actual running task")
 scout.paused=false;scout.advance(1./60)
 check(scout.capture_unit==-1 and scout.units[1].hold=="SCOUT_STOP" and scout.units[1].task_run.phase=="blocked","fresh own observation latches SCOUT while canonical task HOLD is active")
 var undo=s.snapshot();s.command("select",{"unit":1});s.command("route_edit",{"index":1,"point":Vector2(1050,1780)})
 check(s.capture_unit==1 and s.units[1].task_run.phase=="running","future withdrawal edit preserves active canonical job")
 s.command("route_undo");check(s.route_goals(1)[1].pos==Vector2(1000,1780) and s.capture_unit==1,"undo future edit preserves physical work")
 s.restore(inflight)
 for n in 1300:
  step(s,1);step(copy,1)
  if s.mission.objectives[0].captured and s.units[1].route.is_empty():break
 check(s.mission.objectives[0].captured and s.units[1].pos.distance_to(Vector2(1000,1780))<9 and s.units[1].alive,"only actual completion releases normal physical withdrawal")
 # Existing unsaved sensor_clock differs on fresh/reused restores; do not
 # claim full AI/contact phase fidelity. Canonical task/craft future is exact.
 check(not s.units[1].has("task_run") and s.units==copy.units and s.capture_feedback()==copy.capture_feedback(),"completed task marker and canonical player/capture continuation restore exactly")
 var interrupted=make();plan(interrupted)
 for n in 1200:
  step(interrupted,1)
  if interrupted.capture_unit==1:break
 interrupted.command("select",{"unit":1});interrupted.command("contact_hold")
 check(interrupted.capture_unit==-1 and interrupted.units[1].task_run.phase=="blocked","explicit guard command interrupts automatic fieldwork")
 step(interrupted,30)
 check(not interrupted.mission.objectives[0].captured and interrupted.capture_unit==-1,"blocked task does not automatically restart after pilot override")
 interrupted.command("contact_hold")
 interrupted.command("route_edit",{"index":0,"task_site":"chain_west"})
 check(not interrupted.units[1].has("task_run"),"explicit task reissue rearms blocked intent without restoring stale guard")
 interrupted.command("emergency",{"point":Vector2(1000,1780)})
 check(not interrupted.units[1].has("task_run") and not interrupted.route_goals(1)[0].has("task_site"),"emergency replacement clears task intent and stale guard restoration")
 var lost=make();plan(lost);lost.paused=false
 for n in 3600:
  lost.advance(1./60)
  if not lost.units[1].alive:break
 check(not lost.units[1].alive and lost.capture_unit!=1 and not lost.mission.objectives[0].captured and lost.units[1].task_run.phase=="blocked","actual unprotected loss interrupts task without granting completion or withdrawal")
 var busy=make();busy.command("silent");busy.command("route",{"point":Vector2(650,1120)})
 busy.command("select",{"unit":1});busy.command("route",{"point":Vector2(650,1120)});busy.command("select",{"unit":0})
 for n in 1500:
  step(busy,1)
  if busy.units[0].route.is_empty():break
 check(busy.command("camera") and busy.capture_unit==0,"ordinary manual Quietus work owns the one channel")
 busy.command("select",{"unit":1});busy.command("route_insert",{"index":0,"point":Vector2(650,1120),"task_site":"chain_west"})
 busy.command("queue");busy.command("route",{"point":Vector2(1000,1780)});busy.command("select",{"unit":0})
 step(busy,30)
 check(busy.capture_unit==0 and busy.capture_time>0 and busy.route_goals(1)[0].get("task_site","")=="chain_west" and not busy.units[1].has("task_run"),"queued task waits without selecting or cancelling another craft's manual work")
 step(busy,240)
 check(busy.mission.objectives[0].captured and not busy.route_goals(1).any(func(g):return g.has("task_site")),"another canonical completion legitimately satisfies task and releases tail")
 var over=make();over.command("silent");over.command("route",{"point":Vector2(650,1120)});plan(over)
 for n in 1500:
  step(over,1)
  if over.units[0].route.is_empty():break
 check(over.capture_unit==1 and over.selected==0 and over.camera_context().ready and over.camera_context().get("override_task",false),"pilot gets explicit physical manual override of automatic work")
 check(over.command("camera") and over.capture_unit==0 and over.capture_time==0 and over.units[1].task_run.phase=="blocked" and over.selected==0,"manual override takes canonical channel and blocks automatic task without selection theft")
 step(over,30)
 check(over.capture_unit==0 and over.capture_time>0 and not over.mission.objectives[0].captured,"blocked automatic task does not steal manual channel back")
 finish()
func finish():
 print("OBSERVED TASK EXECUTION CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
