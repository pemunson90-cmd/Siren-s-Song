extends RefCounted
# Only charted own actions, effective own clocks and received measurements.
# No reply activation, remote source or delivery truth is presentation input.
static func operation(sim,index:int=-1)->Dictionary:
 if not sim.has_method("operation_context"):return {}
 var sites=sim.observable_sites()
 if index<0:index=sim.camera_context().get("target",-1)
 if index<0 or index>=sites.size():return {}
 for item in sim.operation_context().get("operations",[]):
  if item.site_id==sites[index].get("site_id",""):
   var copy=item.duplicate(true);copy["target"]=index;return copy
 return {}
static func action(sim,index:int=-1)->Dictionary:
 var op=operation(sim,index)
 if op.is_empty():return {}
 var clock=sim.capture_feedback();var context=sim.camera_context()
 var running=clock.target==op.target and clock.unit>=0
 var duration=clock.duration if running else op.duration
 var label=op.action
 var detail="%s · %.1f / %ds"%[label,clock.elapsed,roundi(duration)] if running else "%s · hold %ds"%[label,roundi(duration)]
 if label=="TRANSMIT":detail+=" at Quietus’s actual position inside the charted sector."
 else:detail+=" · optional machinery control; the quiet detour remains available."
 if op.get("completed",false) and not op.get("repeatable",false):detail="SLUICE OPEN · passage remains open; actuation is complete."
 else:
  var pulse=op.get("emission",{})
  if not pulse.is_empty():detail+="\nAUDIBLE on completion · %ds · ~%dm open-water reach; listener reception unknown."%[roundi(pulse.duration),roundi(pulse.radius)]
  var start=op.get("start_emission",{})
  if not start.is_empty():detail+="\nSampler start pulse · %ds · ~%dm open-water reach."%[roundi(start.duration),roundi(start.radius)]
 var enabled=context.get("ready",false) and context.get("target",-1)==op.target and (not op.get("completed",false) or op.get("repeatable",false))
 return {"label":label,"enabled":enabled,"detail":detail,"target":op.target}
static func phase(sim)->String:
 if not sim.has_method("operation_context"):return ""
 for op in sim.operation_context().get("operations",[]):
  if op.action!="TRANSMIT":continue
  if op.has("attempt"):return "TRANSMITTING"
  var clock=sim.capture_feedback();var sites=sim.observable_sites()
  if clock.unit>=0 and clock.target>=0 and clock.target<sites.size() and sites[clock.target].get("site_id","")==op.site_id:return "TRANSMITTING"
  if not op.get("completed",false):return "UNSENT"
  var completed_time=op.get("last_completed",{}).get("time",INF)
  for reading in sim.signal_readings():
   if reading.time>=completed_time:return "RECEIVED"
  return "SENT"
 return ""
static func detail(sim,index:int=-1)->String:
 var info=action(sim,index)
 if info.is_empty():return ""
 var text=info.detail;var op=operation(sim,index)
 if op.action=="TRANSMIT":
  text+="\n"+phase(sim)+" · sending does not confirm delivery or safe passage."
  var last=op.get("last_completed",{})
  if not last.is_empty():text+="\nLast completed own send · %.1fs ago at %d, %d."%[last.age,roundi(last.pos.x),roundi(last.pos.y)]
  text+="\nRECEIVED MEASUREMENTS · %d (historical arrivals, not delivery acknowledgments)."%sim.signal_readings().size()
  text+="\nOnly received arrival measurements establish reception; direction may bend around terrain."
 return text
