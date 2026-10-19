extends SceneTree
const Sim=preload("res://src/simulation/simulation.gd")
var failures=0
var checks=0
func check(ok:bool,label:String):
 checks+=1
 if not ok:failures+=1;print("FAIL ",label)
func _initialize():
 var s=Sim.new();s.start(6)
 check(s.mission.id==6,"Divergence has a stable post-tutorial mission ID")
 if s.mission.id!=6:quit(1);return
 check(s.has_method("observable_sites") and s.observable_sites().is_empty(),"unlocated sources create no exact initial objective marks")
 check(s.signal_readings().is_empty(),"paused deployment does not collect signal readings")
 var before=s.snapshot();s.advance(12);check(s.snapshot()==before,"pause grants no passive samples or expedition progress")
 var deep=s.mission.signal_sources[0];s.units[0].pos=deep.pos+Vector2(0,180);s.paused=false;s.advance(0.1)
 check(s.mission.expedition_facts.has("deep"),"one close legitimate passive observation establishes a source without sample gate")
 check(s.observable_sites().size()==1,"only the observed source becomes an exact site")
 for reading in s.signal_readings():
  check(not reading.has("pos") and not reading.has("source") and not reading.has("points") and reading.has_all(["origin","direction","time","uncertainty","receiver","label"]),"public bearing contains received direction and age rather than hidden position/path")
 s.paused=true;var snap=s.snapshot();var restored=Sim.new();check(restored.restore(snap) and restored.snapshot()==snap,"new source observations and sites survive exact save restore")
 var other=s.mission.signal_sources[1];s.units[1].pos=other.pos+Vector2(0,150);s.paused=false
 for n in 9:s.advance(0.1)
 check(s.mission.expedition_facts.has_all(["deep","shelf"]),"independent drone can preserve the second interpretation")
 var exit=s.extraction_corridors().filter(func(e):return e.route=="shelf")[0]
 s.units[0].pos=exit.pos;s.units[0].vel=Vector2.ZERO;s.advance(0.1)
 check(s.outcome=="won" and s.mission.chosen_route=="shelf","physical selected exit wins its investigated route even when both facts are aboard")
 var campaign=load("res://src/campaign/expedition_campaign.gd")
 check(campaign.available([0,1,2,3,4,5],{})==[6],"earned tutorial completion opens only the implemented entry")
 var progress=campaign.recover({},s.mission)
 check(not progress.is_empty() and progress.route=="shelf" and progress.remote_decoy and campaign.available([0,1,2,3,4,5],progress)==[6,8],"successful corridor recovery unlocks playable selected continuation and one concrete module")
 var withdrawal=Sim.new();withdrawal.start(6);withdrawal.paused=false;withdrawal.advance(0.1)
 check(withdrawal.outcome!="won","deployment basin cannot instantly grant a completed expedition")
 withdrawal.units[0].pos=withdrawal.mission.extraction;withdrawal.mission["withdrawal_armed"]=true;withdrawal.advance(0.1)
 check(withdrawal.outcome=="withdrawn" and campaign.recover({},withdrawal.mission).is_empty(),"incomplete withdrawal grants no route/module")
 print("DIVERGENCE CHECKS ",checks," FAILURES ",failures)
 quit(1 if failures else 0)
