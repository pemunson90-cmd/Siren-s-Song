extends SceneTree
const Content=preload("res://src/campaign/resolution_missions.gd")
const Sim=preload("res://src/simulation/simulation.gd")
var checks=0
var failures=0
func check(ok:bool,label:String)->void:
 checks+=1
 if not ok:failures+=1;printerr("FAIL: ",label)
func length_of(route:Array,origin:Vector2)->float:
 var total=0.0
 for node in route:total+=origin.distance_to(node.pos);origin=node.pos
 return total
func _initialize()->void:
 var m=Content.make(12,{"thread":"deep","completed":[9,11]})
 check(m.get("physical_gates",[]).size()==1,"concealed operation contains one real mechanical sluice")
 if not m.get("physical_gates",[]).is_empty():
  var gate=m.physical_gates[0]
  var actuator=m.objectives.filter(func(o):return o.get("site_id","")==gate.site_id)
  check(not gate.opened and gate.closed_shape in m.get("structures",[]),"closed mechanical shape is present in collision geometry")
  check(actuator.size()==1 and actuator[0].get("optional",false) and actuator[0].get("completion_open_structure","")==gate.id,"actual local optional actuation opens its named gate")
  check(not gate.site_id in m.required_site_ids,"unannounced quiet recovery does not require opening the gate")
  var sim=Sim.new();sim.start(0);sim.mission=m;sim._build_navigation()
  var center=gate.closed_shape.get_center();var a=center-Vector2(0,300);var b=center+Vector2(0,300)
  check(sim.blocked(center,12) and not sim.line_clear(a,b),"closed sluice blocks actual hull occupancy and line of sight")
  check(not sim.acoustic_paths.clear(a,b),"closed sluice is also an acoustic obstacle")
  var witness=m.signal_sources[0].pos+Vector2(0,180)
  var quiet=sim.path(witness,m.extraction)
  check(not quiet.is_empty(),"unopened quiet detour reaches recovery")
  # Data-unit contrast only: the campaign-owner hook must perform this exact
  # geometry update atomically on earned actuator capture, and test restore.
  m.structures.erase(gate.closed_shape);sim._build_navigation()
  var opened=sim.path(witness,m.extraction)
  print("SERVICE_ROUTE_LENGTH closed=",length_of(quiet,witness)," open=",length_of(opened,witness)," closed_nodes=",quiet," open_nodes=",opened)
  check(not sim.blocked(center,12) and sim.line_clear(a,b),"open service passage has real collision and sight clearance")
  check(sim.acoustic_paths.clear(a,b) and not sim.acoustic_paths.arrivals(a,b,900).is_empty(),"opened geometry rebuild permits an actual direct received arrival")
  check(not opened.is_empty() and length_of(quiet,witness)-length_of(opened,witness)>500,"opened service passage materially shortens the actual return plan")
 var warning=Content.make(13,{"thread":"shelf","completed":[10,11]})
 check(warning.objectives.size()==1 and warning.objectives[0].get("kind","")=="transmitter","overt operation is not another pair of receiver preparations")
 var tx=warning.objectives[0]
 check(tx.get("own_origin",false) and tx.get("origin_region",Rect2()).get_area()>1000000,"pilot chooses transmission origin within a substantial charted sector")
 check(tx.duration==6 and tx.required_unit==0 and not tx.get("sampler_compatible",false),"Quietus must settle and speak itself, without a mandatory equipment gate")
 check(warning.signal_sources.size()==1 and not warning.signal_sources[0].get("active",true),"actual response carrier is silent until the warning is sent")
 check(warning.signal_sources.size()==1 and tx.get("completion_enable_source","")==warning.signal_sources[0].id,"transmission triggers the specific physical response source")
 check(warning.required_site_ids==["warning_transmission","warning_reply"] and warning.signal_sources.size()==1 and warning.signal_sources[0].confirm,"sending alone cannot resolve the operation before received reply and recovery")
 if warning.signal_sources.size()==1:
  var sim=Sim.new();sim.start(0);sim.mission=warning;sim._build_navigation()
  var reply=warning.signal_sources[0]
  check(sim.acoustic_paths.arrivals(Vector2(500,1120),reply.pos,900).is_empty() and not sim.acoustic_paths.arrivals(Vector2(1740,440),reply.pos,900).is_empty(),"approaching the berth receives its reply through actual water before the distant western origin")
  check(not sim.acoustic_paths.arrivals(reply.pos,Vector2(500,1120),tx.completion_emission.radius).is_empty() and not sim.acoustic_paths.arrivals(reply.pos,Vector2(1840,1080),tx.completion_emission.radius).is_empty(),"both declared transmission choices physically deliver the actual warning to the responder")
 print("RESOLUTION OPERATIONS CHECKS ",checks," FAILURES ",failures)
 quit(1 if failures else 0)
