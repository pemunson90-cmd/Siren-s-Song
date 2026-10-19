extends SceneTree
class PublicCorrelation:
 extends RefCounted
 var selected=0
 var elapsed=10.5
 var mission={"id":9,"expedition_revision":2}
 var units=[{"name":"QUIETUS","pos":Vector2(100,100)}]
 var result={"status":"match","dwell":6.,"arrivals":[{"receiver":0,"origin":Vector2(200,400),"direction":Vector2.RIGHT,"time":10.,"uncertainty":.18,"cadence":[.8,1.6,.8],"classification":"match"},{"receiver":0,"origin":Vector2(200,400),"direction":Vector2.UP,"time":10.,"uncertainty":.65,"cadence":[.4,.4,1.2],"classification":"other"}],"qualification":"Cadence only; identity, range and passage safety remain unknown."}
 func equipment_feedback():return {"fitted":{"quietus":"quietus_correlator"},"correlation":result.duplicate(true)}
 func signal_readings():return []
class PublicSampler:
 extends RefCounted
 var selected=1
 var capture_unit=-1
 var capture_target=0
 var capture_time=0.
 func equipment_feedback():return {"fitted":{"quietus":"","drone_a":"drone_sampler","drone_b":""}}
 func observable_sites():return [{"site_id":"chain_west","sampler_compatible":true}]
 func camera_context():return {"ready":true,"target":0,"text":"FIELD SAMPLE · AUDIBLE 8s"}
var checks=0
var failures=0
func check(ok:bool,label:String):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():call_deferred("run")
func run():
 var equipment=load("res://src/presentation/equipment_context.gd")
 check(equipment!=null,"public equipment view exists")
 if equipment==null:finish();return
 var catalog=[{"id":"quietus_correlator","name":"CADENCE CORRELATOR","compatible_slots":["quietus"],"benefit":"Compare a received cadence with a recovered reference.","cost":"6s settled listening; identity and range unknown."},{"id":"drone_sampler","name":"FIELD SAMPLER","compatible_slots":["drone_a","drone_b"],"benefit":"Operate a compatible field receiver remotely.","cost":"8s exposed, versus Quietus4s; one sampler shared."}]
 var context={"slots":{},"catalog":catalog,"available":[]};var before=context.duplicate(true)
 check(equipment.rows(context).is_empty(),"field notes without recovered entitlement expose no fitting choice")
 check(context==before,"view does not grant or mutate equipment")
 context.available=["quietus_correlator","drone_sampler"]
 var rows=equipment.rows(context)
 check(rows.size()==3,"recovered public catalog offers only compatible owned craft")
 check(rows[0].slot=="quietus" and rows[0].id=="quietus_correlator" and rows[1].id=="drone_sampler","fittings preserve specific Quietus and drone capability identities")
 check(rows.all(func(row):return row.current=="" and not row.benefit.is_empty() and not row.cost.is_empty()),"absent fit stays explicitly BARE and each option explains benefit and cost")
 context.slots={"quietus":"quietus_correlator","drone_a":"drone_sampler","drone_b":""}
 check(equipment.rows(context)[0].current=="quietus_correlator","selected launch fitting is shown without reinterpretation")
 var scene=load("res://src/presentation/receiver_scene.gd")
 check(scene!=null,"truthful receiver scene exists")
 if scene!=null:
  check(scene.applies(7,{"site_id":"rendezvous"}) and not scene.applies(3,{"site_id":"rendezvous"}),"Deep reception replaces unrelated Foundry only in its authored context")
  check("ANALYTICAL" in scene.title() and not "OPTICAL" in scene.title(),"local receiver rendering makes no viewpoint-photo claim")
 var received=load("res://src/audio/received_cues.gd")
 check(received!=null,"receiver-owned cue adapter exists")
 if received!=null:
  var cue=received.new();var event={"type":"carrier_received","receiver":1,"direction":Vector2(-.6,.8),"time":4.,"identity":"carrier","pos":Vector2(9999,9999)}
  check(cue.take(event,1,4.,false)=={},"paused reception cannot start an audible cue")
  check(cue.take(event,0,4.,true)=={},"unselected remote hydrophone is not panned as local hearing")
  var heard=cue.take(event,1,4.,true)
  check(heard.cue=="carrier_received" and is_equal_approx(heard.relative.x,-330.),"received cue pan derives actual receiver arrival direction, never hidden event.pos")
  check(cue.take(event,1,4.,true)=={},"same received event is not repeated")
  event.time=4.75;check(cue.take(event,1,4.75,true)=={},"ordinary sample refresh does not spam sound")
  event.time=10.;event.type="return_received";event.identity="return"
  check(cue.take(event,1,10.,true).get("cue","")=="return_received","received RETURN has its own semantic cue")
  event.time=15.;check(cue.take(event,1,30.,true)=={},"stale restored event does not fake new reception")
  event.time=1.;check(not cue.take(event,1,1.,true).is_empty(),"new dive clock resets prior-dive reception suppression")
 var public=PublicCorrelation.new();var result_before=public.result.duplicate(true)
 var detail=equipment.correlation_detail(public)
 check("M1 MATCHED CADENCE" in detail and "090°" in detail and "0.5s" in detail,"matched result identifies its exact historical bearing and age before a source fix")
 check("M2 OTHER CADENCE" in detail and "000°" in detail and "identity" in detail,"nonmatching arrival retains distinct direction and cadence-only qualification")
 var presentation=load("res://src/presentation/expedition_view.gd")
 check(presentation.has_method("display_measurements"),"classified fan geometry shares the same public M labels as the detail card")
 if presentation.has_method("display_measurements"):
  var shown=presentation.display_measurements(public,0)
  check(shown.size()==2 and shown[0].measurement=="M1" and shown[0].origin==Vector2(200,400) and shown[0].classification=="match","M1 fan is anchored to received historical origin, not current craft or source position")
  public.units[0].pos=Vector2(999,999)
  check(presentation.display_measurements(public,0)==shown and public.result==result_before,"moving the craft cannot move or mutate the classified historical sample")
 var sampler=PublicSampler.new()
 check(equipment.has_method("sample_detail"),"equipped field sampling has explicit public audible-task presentation")
 if equipment.has_method("sample_detail"):
  check("FIELD SAMPLE" in equipment.sample_detail(sampler) and "AUDIBLE 8s" in equipment.sample_detail(sampler),"ready fitted drone discloses eight-second audible exposure")
  sampler.capture_unit=1;sampler.capture_time=2.5
  check("2.5 / 8s" in equipment.sample_detail(sampler),"active field sampling retains own task progress and disclosure")
 var sound=load("res://src/audio/soundscape.gd")
 var carrier=sound.samples("carrier_received");var answer=sound.samples("return_received")
 check(carrier!=answer and carrier!=sound.samples("alert"),"received carrier and RETURN have distinct non-alert sonic identities")
 for values in [carrier,answer]:
  var energy=0.;var peak=0.
  for value in values:energy+=value*value;peak=maxf(peak,absf(value))
  check(energy>1. and peak<.5,"received cue has audible energy and conservative clipping headroom")
 finish()
func finish():print("CAMPAIGN INSTRUMENT CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
