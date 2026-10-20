extends SceneTree
const Sim=preload("res://src/simulation/simulation.gd")
const Campaign=preload("res://src/campaign/expedition_campaign.gd")
const Store=preload("res://src/persistence/save_store.gd")
var checks=0
var failures=0
func check(ok:bool,label:String):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func step(s,seconds:float):
 s.paused=false
 for n in ceili(seconds*60):s.advance(1./60.)
 s.paused=true
func progress()->Dictionary:
 return {"version":2,"route":"deep","routes":["deep"],"facts":{"deep":"Deep branch recovered","rendezvous":"Berthing correction recovered"},"completed":[6,7],"notes":{},"references":{"return_cadence":[.8,1.6,.8]},"entitlements":["quietus_correlator"],"history":[],"selected_thread":""}
func _initialize():call_deferred("run")
func run():
 var s=Sim.new();s.start(9,"endurance",{"context":{"references":progress().references},"fitted":{"quietus":"quietus_correlator","drone_a":"","drone_b":""}})
 check(s.has_method("wake_context"),"Wake exposes a local one-use diversion context")
 if not s.has_method("wake_context"):finish();return
 check(Sim.valid_snapshot(s.snapshot()),"fresh expanded Wake is a valid current dive")
 check(not s.wake_context().known and not s.command("wake_playback"),"unmeasured remote hardware cannot be activated")
 step(s,6.8)
 check(s.correlation.status=="match" and s.mission.objectives.is_empty(),"genuine berthing reference still separates received patterns before exact source acquisition")
 s.units[1].pos=Vector2(1520,680);s.units[1].vel=Vector2.ZERO;s.command("select",{"unit":1});step(s,.8)
 check(s.wake_context().known and s.wake_context().ready and s.wake_context().account.contains("empty"),"a bare drone locally discovers the keeper's deliberate empty loop and its remaining playback")
 check(not s.all_records(),"optional diversion account never replaces the real onward packet")
 var before=s.snapshot();s.advance(5);check(s.snapshot()==before,"unlimited pause acquires no account, report or playback time")
 s.units[1].vel=Vector2(3,0);check(not s.command("wake_playback"),"moving craft cannot spend the one remaining local playback")
 s.units[1].vel=Vector2.ZERO
 var guard=s.sirens[1];guard.pos=Vector2(1000,560);guard.home=guard.pos;guard.goal=guard.pos;guard.route=[]
 var tools=s.tools.duplicate();check(s.command("wake_playback") and s.tools==tools,"local one-use hardware emits without consuming unrelated finite tools")
 check(s.noises.any(func(n):return n.pos==Vector2(1520,620) and n.radius==1100 and n.time==15),"playback is a real finite emission at its own fixed hardware")
 var used=s.snapshot();check(not s.command("wake_playback") and s.snapshot()==used,"repeat command cannot recharge or extend the diversion")
 step(s,.2)
 check(guard.mode=="INVESTIGATE" and guard.goal.distance_to(Vector2(1520,620))<100,"ordinary hunter physically hears and investigates actual playback water")
 var store=Store.new();store.path="user://wake-crossing-test.save"
 var archive={"version":1,"unlocked":5,"completed":[0,1,2,3,4,5],"upgrade":"endurance","settings":{},"expedition":progress(),"active":s.snapshot()}
 check(store.save(archive) and store.load_game()==archive,"actual checksummed binary archive preserves active finite playback")
 var restored=Sim.new();check(restored.restore(store.load_game().active) and restored.wake_context().used,"current restore cannot refund spent hardware")
 step(restored,16);check(not restored.noises.any(func(n):return n.label=="OLD DEPARTURE LOOP"),"playback really expires rather than sustaining an infinite lure")
 check(not restored.wake_context().active and restored.wake_context().remaining==0,"own playback clock expires without implying a remote guard state")
 check(not restored.command("wake_playback"),"expired one-use hardware stays spent")
 var old=s.snapshot();old.mission.erase("wake_crossing");check(not Sim.valid_snapshot(old),"obsolete active9 is rejected without compatibility flags or fabricated new work")
 for suffix in ["",".bak",".tmp"]:DirAccess.remove_absolute(store.path+suffix)
 report_case()
 history_case()
 finish()
func history_case():
 var s=Sim.new();s.start(9);var m=s.mission;m.recovered=true
 var p=Campaign.recover(progress(),m)
 check(p.facts.get("wake_crossing","")=="repeater_unused","first successful quiet recovery records only the actual unused-hardware outcome")
 m.wake_crossing.played_at=0.0;m.wake_crossing.played_by=1
 var replay=Campaign.recover(p,m)
 check(replay.facts.get("wake_crossing","")=="repeater_unused","replay cannot rewrite a committed quiet crossing as a later diversion")
 var used=Campaign.recover(progress(),m)
 check(used.facts.get("wake_crossing","")=="repeater_played","fresh recovered playback commits its actual local action without claiming remote safety")
 var next=preload("res://src/campaign/missions.gd").make(11,{"thread":"deep","completed":[6,7,9],"facts":used.facts,"references":{}})
 check(next.signal_sources[0].evidence.contains("spent the old loop"),"later live factory account selectively recognizes the actually spent old loop")
 var legacy=p.duplicate(true);legacy.facts.erase("wake_crossing")
 check(not Campaign.recover(legacy,m).facts.has("wake_crossing"),"already committed pre-expansion history does not fabricate newly performed work")
 legacy.history=[]
 check(not Campaign.recover(legacy,m).facts.has("wake_crossing"),"completed9 boundary remains authoritative even when an older archive has no history row")
func report_case():
 # Controlled geometry fixture for an actual sight/report and its stale memory.
 var s=Sim.new();s.start(9)
 for id in [1,2]:s.units[id].alive=false
 s.units[0].pos=Vector2(670,520);s.units[0].vel=Vector2.ZERO
 for id in 2:
  var g=s.sirens[id];g.pos=Vector2(780,520) if id==0 else Vector2(1140,400);g.home=g.pos;g.goal=g.pos;g.route=[];g.patrol_points=[];g.type="sentinel"
 step(s,2.2)
 check(s.sirens[1].has("report_interest") and s.hull==100,"real sight sends a bounded stale report across the open northern saddle before any beam")
 var point=s.sirens[1].last_known;s.units[0].pos=Vector2(300,1700);step(s,.2)
 check(s.sirens[1].last_known==point,"report never tracks a subsequently hidden craft")
 check(Sim.valid_snapshot(s.snapshot()),"Wake report state uses its actual region bounds in current saves")
 var saved=s.snapshot();var resumed=Sim.new();check(resumed.restore(saved),"partial local pursuit survives current restoration")
 step(resumed,13);check(not resumed.sirens[1].has("report_interest"),"received local report expires without hidden global pursuit")
 s=Sim.new();s.start(9)
 for id in [1,2]:s.units[id].alive=false
 s.units[0].pos=Vector2(670,1320);s.units[0].vel=Vector2.ZERO
 for id in 2:
  var g=s.sirens[id];g.pos=Vector2(780,1320) if id==0 else Vector2(620,1600);g.home=g.pos;g.goal=g.pos;g.route=[];g.patrol_points=[];g.type="sentinel"
 step(s,2.2)
 check(s.sirens[1].has("report_interest") and s.sirens[1].last_known.y>960 and Sim.valid_snapshot(s.snapshot()),"actual southern sight report serializes within Wake's taller physical region")
func finish():print("WAKE CROSSING CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
