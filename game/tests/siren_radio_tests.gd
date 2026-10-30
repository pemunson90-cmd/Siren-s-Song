extends SceneTree
const Sim=preload("res://src/simulation/simulation.gd")
const Reports=preload("res://src/simulation/contact_reports.gd")
const Catalog=preload("res://src/campaign/operation_catalog.gd")
var checks=0
var failures=0
func check(ok:bool,label:String):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func fixture():
 var s=Sim.new();s.start(5);s.mission.rocks=[];s.mission.structures=[];s.mission.depth_geometry={};s._build_navigation()
 for i in 3:s.units[i].pos=Vector2(700,600);s.units[i].alive=true;s.units[i].vel=Vector2.ZERO
 s.sirens=s.sirens.slice(0,2)
 for i in 2:
  var e=s.sirens[i];e.band=1;e.pos=Vector2(550-i*300,600);e.home=e.pos;e.goal=e.pos;e.type="patroller";e.route=[];e.patrol_points=[];e.stun=0.0;e.lock=0.0;e.target=-1;e.suspicion=0.0
 return s
func tick(s,seconds:float,seen:int=0,distraction:bool=false):
 for n in int(round(seconds*60)):Reports.advance(s,[seen,-1],[seen>=0,false],1.0/60,[distraction,false])
func _initialize():call_deferred("run")
func run():
 for id in Catalog.registered_ids():
  var m=Catalog.make(id);var count=m.sirens.filter(Reports.eligible).size()
  check((m.get("contact_report_revision",0)==2)==(count>=2),"op %d enables radio exactly when two eligible Sirens exist"%id)
 var carried=Sim.new();carried.start(31,"endurance",{"context":{"facts":{"warning_chain":"service_local_receipt"}}})
 check(carried.sirens.filter(Reports.eligible).size()==1 and not carried.mission.has("contact_report_revision"),"recovered receipt removes its watch before fresh radio eligibility")
 check(Sim.valid_snapshot(carried.snapshot()),"single-watch carried operation starts with a valid current snapshot")
 var carried_copy=Sim.new()
 check(carried_copy.restore(carried.snapshot()),"single-watch carried operation restores without enabling a peer report")
 check(not carried.mission.brief.contains("A pair of recovery watches"),"single remaining watch briefing never promises a radio pair")
 var s=fixture();tick(s,2.1)
 check(s.sirens[0].report.charge>2 and not s.sirens[1].has("report_interest"),"new radio does not finish at legacy two seconds")
 var partial=s.snapshot();var restored=Sim.new()
 check(restored.restore(partial),"new revision charge saves and restores")
 restored.advance(20);check(restored.snapshot()==partial,"pause freezes new charge")
 s.units[0].pos=Vector2(720,680);tick(s,1)
 check(s.sirens[1].last_known==Vector2(720,720),"completion shares latest observed coarse point")
 var point=s.sirens[1].goal;s.units[0].pos=Vector2(1000,800);tick(s,.1,-1)
 check(s.sirens[1].goal==point,"report never tracks hidden movement")
 s=fixture();tick(s,2.5);tick(s,.1,-1);tick(s,1.1)
 check(not s.sirens[1].has("report_interest") and s.sirens[0].report.charge<2,"broken contact discards partial charge")
 s=fixture();tick(s,2.5);s.sirens[0].stun=2;tick(s,.1)
 check(s.sirens[0].report.charge==0,"Disrupt cancels charge")
 s=fixture();tick(s,2.5);tick(s,.1,1)
 check(s.sirens[0].report.charge<.11 and not s.sirens[1].has("report_interest"),"drone attention cancels Quietus report")
 tick(s,3,1);check(s.sirens[1].has("report_interest"),"drone contact may start a full new report")
 s=fixture();tick(s,2.5);tick(s,.1,0,true)
 check(s.sirens[0].report.charge==0,"received distraction cancels despite simultaneous sight")
 s=fixture();tick(s,2.5);check(s.command("decoy",{"point":Vector2(600,600)}),"public Decoy spends a real charge")
 s._threats(1.0/60)
 check(s.sirens[0].report.charge==0,"production received Decoy cancels report")
 s=fixture();var third=s.sirens[1].duplicate(true);third.pos=Vector2(300,700);s.sirens.append(third)
 for n in 181:Reports.advance(s,[0,-1,-1],[true,false,false],1.0/60)
 check(s.sirens.filter(func(e):return e.has("report_interest")).size()==2,"all eligible acoustic peers receive stale point")
 s=fixture();s.sirens[1].type="sweeper";tick(s,3.1)
 check(not s.sirens[1].has("report_interest"),"protected sweeper never receives radio intent")
 s=fixture();s.sirens[0].type="sweeper";tick(s,3.1)
 check(not s.sirens[0].has("report"),"protected sweeper never reports")
 s=fixture();s.mission.world_size=Vector2(2200,2600);s.units[0].pos=Vector2(2199,2599);tick(s,1)
 check(s.sirens[0].report.point.x<=2200 and s.sirens[0].report.point.y<=2600,"coarse report stays inside non-grid world bounds")
 var bad=partial.duplicate(true);bad.sirens[0].report.charge=3.1
 check(not Sim.valid_snapshot(bad),"charge over centralized duration rejected")
 bad=partial.duplicate(true);bad.mission.erase("sirens")
 check(not Sim.valid_snapshot(bad),"missing authored report roster rejected without script error")
 bad=partial.duplicate(true);bad.mission.sirens=7
 check(not Sim.valid_snapshot(bad),"non-array authored report roster rejected without script error")
 await audio_checks()
 print("SIREN RADIO CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
func audio_checks():
 var sound=preload("res://src/audio/soundscape.gd").new();root.add_child(sound);await process_frame
 var s=fixture();s.paused=false;sound.update(s,0)
 var layer=sound.get_node("EventAudio")
 tick(s,1);sound.update(s,0)
 check(not "siren_report" in layer.played,"unobserved enemy report cannot leak through sound")
 s._observe();sound.update(s,0)
 check("siren_report" in layer.played,"earned fresh chart report sounds once")
 sound.update(s,0);check(layer.played.is_empty(),"refresh does not replay report cue")
 layer.last_play={};s.elapsed=1;sound.update(s,0)
 check(layer.played.is_empty(),"stale contact never sounds a live report")
 sound.queue_free();await process_frame
