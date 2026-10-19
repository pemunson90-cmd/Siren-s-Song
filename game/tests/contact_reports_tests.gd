extends SceneTree
const Sim=preload("res://src/simulation/simulation.gd")
const Reports=preload("res://src/simulation/contact_reports.gd")
const Feedback=preload("res://src/presentation/contact_feedback.gd")
const SaveStore=preload("res://src/persistence/save_store.gd")
var checks=0
var failures=0
func check(ok:bool,label:String):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func fixture():
 # Explicit mechanic fixture; ordinary authored finale trace is separate.
 var s=Sim.new();s.start(5);s.mission.rocks=[];s.mission.structures=[];s._build_navigation()
 for i in 3:s.units[i].pos=Vector2(700,600);s.units[i].alive=i==0;s.units[i].vel=Vector2.ZERO
 s.sirens=s.sirens.slice(0,2)
 for i in 2:
  var e=s.sirens[i];e.pos=Vector2(550-i*300,600);e.home=e.pos;e.goal=e.pos;e.type="sentinel";e.route=[];e.patrol_points=[];e.stun=0.0;e.lock=0.0;e.target=-1;e.suspicion=0.0
 return s
func sight(s,seconds:float):
 for n in int(round(seconds*60)):Reports.advance(s,[0,-1],[true,false],1.0/60)
func _initialize():
 var s=fixture();check(s.mission.get("contact_report_revision",0)==1,"fresh finale enables local reports")
 var earlier_unchanged=true
 for chapter in 5:
  var earlier=Sim.new();earlier.start(chapter);earlier_unchanged=earlier_unchanged and not earlier.mission.has("contact_report_revision")
 check(earlier_unchanged,"earlier authored encounters retain their existing pacing and briefings")
 check(s._heard_arrival(s.sirens[1]).is_empty(),"quiet peer lacks original stimulus")
 sight(s,1.0);check(s.sirens[0].get("report",{}).get("charge",0)>0.9 and s.sirens[1].get("attention_time",0)==0,"report has an interruptible charge")
 s._observe();var rows=Feedback.entries(s.contacts,s.elapsed,s.units)
 check(rows.any(func(r):return r.text.contains("REPORT")),"earned witness contact explains report countdown")
 var partial=s.snapshot();var restored=Sim.new();check(restored.restore(partial),"partial report restores")
 var store=SaveStore.new();store.path="user://contact-report-test-%d.save"%OS.get_process_id()
 var archive={"version":1,"unlocked":5,"completed":[],"settings":{},"upgrade":"endurance","active":partial}
 check(store.save(archive) and store.load_game().active==partial,"real checksummed archive retains partial report without a schema change")
 for suffix in ["",".bak",".tmp"]:DirAccess.remove_absolute(store.path+suffix)
 var frozen=restored.snapshot();restored.advance(4);check(restored.snapshot()==frozen,"pause freezes partial report")
 sight(s,1.1);sight(restored,1.1)
 check(s.sirens[1].get("attention_time",0)>9 and s.sirens[1].goal==restored.sirens[1].goal,"completion transfers one deterministic stale point")
 check(s.sirens[1].goal.distance_to(Vector2(700,600))<=57,"report quantizes an observed location")
 s._observe();rows=Feedback.entries(s.contacts,s.elapsed,s.units)
 check(rows.any(func(r):return r.text.contains("REPORT SENT")),"earned completed emission has a causal completion cue")
 var point=s.sirens[1].goal;s.units[0].pos=Vector2(1000,800);Reports.advance(s,[-1,-1],[false,false],1.0/60)
 check(s.sirens[1].goal==point,"hidden relocation never updates received report")
 var received=Sim.new();check(received.restore(s.snapshot()) and received.sirens[1].report_interest==s.sirens[1].report_interest,"received knowledge resumes without refreshing its age")
 for n in 620:Reports.advance(s,[-1,-1],[false,false],1.0/60)
 check(not s.sirens[1].has("report_interest") and s.sirens[1].goal==s.sirens[1].home,"expired report cannot sustain hidden pursuit")
 s=fixture();s.sirens[1]["report_interest"]=0.01;s.sirens[1].stun=2;s.sirens[1].mode="DISRUPTED"
 Reports.advance(s,[-1,-1],[false,false],1.0/60)
 check(s.sirens[1].mode=="DISRUPTED","knowledge expiry cannot override physical disruption")
 s=fixture();sight(s,1);Reports.advance(s,[-1,-1],[false,false],1.0/60);sight(s,1.1)
 check(s.sirens[1].get("attention_time",0)==0,"lost sight cancels rather than pauses transmission")
 s=fixture();sight(s,1);s.sirens[0].stun=3;Reports.advance(s,[0,-1],[true,false],1.0/60)
 check(s.sirens[0].report.charge==0 and s.sirens[1].get("attention_time",0)==0,"disrupted sender cannot complete")
 s=fixture();sight(s,1);s.sirens[0]["pin_time"]=2;Reports.advance(s,[0,-1],[true,false],1.0/60)
 check(s.sirens[0].report.charge==0,"pinned sender cannot report")
 s=fixture();s.sirens[1].pos=Vector2(50,600);sight(s,2.1)
 check(s.sirens[1].get("attention_time",0)==0,"report has bounded acoustic reach")
 s=fixture();s.mission.structures=[Rect2(380,0,80,960)];s._build_navigation();sight(s,2.1)
 check(s.sirens[1].get("attention_time",0)==0,"solid wall blocks report instead of sharing knowledge globally")
 s=fixture();s.acoustic_paths.thermal_fronts=[{"area":Rect2(400,500,100,200),"transmission":0.55,"close_range":120.0}];sight(s,2.1)
 check(s.sirens[1].get("attention_time",0)==0,"real thermal crossings weaken the report path")
 s=fixture();var third=s.sirens[1].duplicate(true);third.pos=Vector2(300,700);third.home=third.pos;s.sirens.append(third)
 for n in 130:Reports.advance(s,[0,-1,-1],[true,false,false],1.0/60)
 check(s.sirens.filter(func(e):return e.has("report_interest")).size()==1,"one strongest peer investigates instead of every listener converging")
 s=fixture();s.sirens[1].goal=Vector2(200,200)
 for n in 130:Reports.advance(s,[0,-1],[true,true],1.0/60)
 check(s.sirens[1].goal==Vector2(200,200),"fresh local hearing beats report")
 s=fixture();s.sirens[1].goal=Vector2(200,200)
 for n in 130:Reports.advance(s,[0,0],[true,true],1.0/60)
 check(s.sirens[1].goal==Vector2(200,200),"fresh sight and beam are authoritative")
 s=fixture();s.units[0].vel=Vector2(96,0)
 check(not s._heard_arrival(s.sirens[1]).is_empty(),"loud drone-speed counterexample already informs peer")
 s=fixture();sight(s,1);check(s.command("emp"),"pilot can spend finite disruption during charge")
 Reports.advance(s,[-1,-1],[false,false],1.0/60)
 check(s.sirens[0].report.charge==0 and not s._heard_arrival(s.sirens[1]).is_empty() and s.tools.emp==1,"interruption noise can replace the report with ordinary hearing")
 s=fixture();s.paused=false
 for n in 130:s.advance(1.0/60)
 check(s.sirens[1].has("report_interest") and s.sirens[1].pos.x>250 and s.hull==100,"production sensing moves otherwise-uninformed peer without changing beam window")
 s=fixture();s.mission.structures=[Rect2(650,500,30,80)];s._build_navigation();s.units[0].angle=-PI/2;s._observe()
 check(s.contacts.has(0) and s.command("emergency",{"point":Vector2(740,540)}),"pilot can replot behind physical cover from an earned witness without a tool")
 s.paused=false
 for n in 180:s.advance(1.0/60)
 check(not s.sirens[1].has("report_interest") and s.sirens[0].get("report",{}).get("sent",0)==0 and s.hull==100 and s.tools.emp==2,"quiet physical withdrawal breaks sight before report completion")
 s=fixture();sight(s,1);var old=s.snapshot();old.mission.erase("contact_report_revision")
 old.mission.erase("acoustic_revision")
 for e in old.sirens:e.erase("report")
 var legacy=Sim.new();check(legacy.restore(old) and legacy.snapshot()==old,"legacy archive retains exact old behavior/state")
 sight(legacy,3);check(not legacy.sirens[0].has("report"),"legacy mission cannot gain new reports")
 var bad=partial.duplicate(true);bad.sirens[0].report.charge=NAN;check(not Sim.valid_snapshot(bad),"nonfinite charge rejected")
 bad=partial.duplicate(true);bad.sirens[0].report.target=9;check(not Sim.valid_snapshot(bad),"invalid report target rejected")
 bad=old.duplicate(true);bad.sirens[0]["report"]=partial.sirens[0].report;check(not Sim.valid_snapshot(bad),"report state requires explicit optional mechanic revision")
 print("CONTACT REPORT CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
