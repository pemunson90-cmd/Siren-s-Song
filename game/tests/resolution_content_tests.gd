extends SceneTree
const MODULE="res://src/campaign/resolution_missions.gd"
var checks=0
var failures=0
func check(ok:bool,label:String)->void:
 checks+=1
 if not ok:failures+=1;printerr("FAIL: ",label)
func _initialize()->void:
 check(ResourceLoader.exists(MODULE),"authored resolution jobs and recovered-history conditions exist")
 if failures:finish();return
 var content=load(MODULE)
 check(content.available({}).is_empty(),"field session without recovered onward job cannot open Confluence")
 check(content.available({"notes":{"mission":9},"facts":{"confluence_route":"overt"}}).is_empty(),"retained notes cannot grant a resolution job")
 for id in [9,10]:
  check(content.available({"completed":[id],"facts":{}})==[11],"either recovered branch rejoins without requiring both")
 check(content.available({"completed":[9,11],"facts":{"confluence_route":"concealed"}})==[11,12],"recovered concealed departure opens only concealed recovery")
 check(content.available({"completed":[10,11],"facts":{"confluence_route":"overt"}})==[11,13],"recovered overt departure opens only warning job")
 check(content.available({"completed":[9,11],"facts":{"confluence_route":"unknown"}})==[11],"an unsupported departure cannot invent a resolution")
 var history={"thread":"deep","completed":[9],"facts":{},"references":{"return_cadence":[.8,1.6,.8]},"notes":{"unrecovered":"packet"}}
 var before=history.duplicate(true)
 var confluence=content.make(11,history)
 check(history==before and not confluence.launch_context.has("notes"),"authored launch context copies recovered history without mutating it or carrying notes")
 check(confluence.launch_context.references==history.references,"only actually recovered reference is carried into the next encounter")
 check(content.make(11,{"completed":[10],"facts":{}}).start!=confluence.start,"Deep and Shelf approach Confluence from different physical mouths")
 check(content.make(11,{"thread":"shelf","completed":[9,10]}).start==content.make(11,{"completed":[10]}).start,"later alternate recovery does not replace the committed Shelf physical approach")
 check(content.make(99).is_empty(),"reserved authoring module does not alias an invalid mission ID")
 for id in [11,12,13]:
  var mission=content.make(id,history)
  check(mission.id==id and mission.expedition_revision==2,"each job has its stable new campaign ID and opt-in revision")
  check(mission.world_size.x>=2200 and mission.world_size.y>=2400,"resolution jobs have authored regional traversal beyond a fitted arena")
  check(not mission.required_site_ids.is_empty(),"every recovery requires earned named sites even before source discovery")
  check(mission.signal_sources.all(func(s):return s.get("optical","") in content.FIELD_RECORDS),"new helper receives explicit field-record keys for each dynamic source")
  check(not mission.sirens.is_empty() and mission.sirens.all(func(s):return s.mode=="PATROL" and s.lock==0 and s.target==-1),"authored threats begin with ordinary patrol knowledge")
  check(content.resolution(mission).is_empty(),"authored ending text cannot resolve an unrecovered dive")
 var concealed=content.make(12,history);var overt=content.make(13,history)
 check(concealed.start!=overt.start and concealed.extraction!=overt.extraction and concealed.rocks!=overt.rocks,"concealed and overt jobs have different terrain and traversal")
 check(concealed.objectives.size()==1 and concealed.objectives[0].get("optional",false) and concealed.signal_sources.size()==1,"concealed witness stays unlocated while optional mechanical control is charted")
 check(not concealed.signal_sources.any(func(s):return s.has("completion_emission")),"witness acquisition preserves a nonbroadcast recovery plan")
 check(overt.objectives.size()==1 and overt.objectives[0].get("own_origin",false) and overt.objectives[0].required_unit==0,"warning is an own-origin operation rather than another preparation chain")
 check(overt.objectives[0].completion_emission.radius==2000 and overt.objectives[0].completion_emission.duration==8,"overt warning causes a finite physical transmission")
 check(concealed.objectives[0].sampler_compatible and concealed.objectives[0].required_unit==0,"drone specialization can open the optional service sluice while Quietus remains a fallback")
 concealed.recovered=true
 check(content.resolution(concealed).is_empty(),"recovered flag alone cannot replace a witness packet")
 concealed.objectives=[{"site_id":"witness_packet","captured":true}]
 check(content.resolution(concealed).is_empty(),"an abstract captured flag cannot replace a physically landed living witness")
 concealed.witness_evacuation.state="landed"
 check(content.resolution(concealed).is_empty(),"physically landed witness still needs its newly promised local consequence")
 concealed.concealed_harbour.connected=false;concealed.concealed_harbour.receipt=true
 check(content.resolution(concealed)=="concealed_recovery","landed witness and earned local consequence complete the concealed job")
 overt.recovered=true
 for objective in overt.objectives:objective.captured=true
 overt.objectives.append({"site_id":"warning_reply","captured":true})
 check(content.resolution(overt).is_empty(),"a recovered warning and ACK cannot replace physical recipient arrival")
 overt.warning_recipient.receipt=true
 check(content.resolution(overt)=="overt_warning","actual recipient receipt and recovered Q complete the overt job")
 overt.objectives[1].captured=false
 check(content.resolution(overt).is_empty(),"preparation notes alone cannot claim the warning was forwarded")
 finish()
func finish()->void:
 print("RESOLUTION CONTENT CHECKS ",checks," FAILURES ",failures)
 quit(1 if failures else 0)
