extends RefCounted
# ARCH2 cargo-panel contract. This view has no world-drawing responsibility;
# its draw hook is intentionally empty and it is registered only in HUD_PANELS.
# Revert this PR to restore the direct HUD block. Legacy cargo/input helpers stay.
static func applies(sim)->bool:return sim!=null
static func build_panel(hud)->void:
 var sim=hud.host.sim
 var delivery=status(sim)
 if not delivery.is_empty():
  hud.intent.text=summary(sim)+" · "+hud.intent.text
  hud.host.order_buttons.camera.disabled=not sim.camera_context().ready
  if hud.page=="delivery" or (hud.page=="inspect" and hud.subject.get("kind","")!="salvage"):hud.instrument_info.text=detail(sim)+"\n\n"+hud.instrument_info.text
  if sim.selected>0:hud.extra.blackwater_handoff.disabled=not sim.blackwater_handoff_context(sim.selected).ready
  for pair in [[1,hud.extra.blackwater_a],[2,hud.extra.blackwater_b]]:
   var context=sim.blackwater_handoff_context(pair[0]);pair[1].disabled=not context.ready
   pair[1].text="TRANSFER %s\nTO Q"%["A" if pair[0]==1 else "B"]
static func draw(_view)->void:pass
# Mission cargo and local handoff readiness come only from public projections.
static func status(sim)->Dictionary:
 return sim.blackwater_delivery_status() if sim.has_method("blackwater_delivery_status") else {}
static func counts(sim)->Dictionary:
 var info=status(sim);var aboard=0;var notes=0
 for packet in info.get("packets",[]):
  aboard+=int(packet.aboard);notes+=int(packet.recorded)
 return {"aboard":aboard,"notes":notes}
static func summary(sim)->String:
 if status(sim).is_empty():return ""
 var count=counts(sim);return "Q ABOARD %d/2 · FIELD NOTES %d/2"%[count.aboard,count.notes]
static func packet_names(sim,ids:Array)->String:
 var names=[]
 for packet in status(sim).get("packets",[]):
  if packet.id in ids:names.append(packet.name)
 return " + ".join(names)
static func cargo(sim,unit:int)->String:
 var info=status(sim)
 if info.is_empty() or unit<0 or unit>=info.cargo.size() or info.cargo[unit].is_empty():return ""
 return ("ABOARD · " if unit==0 else "BUFFER · ")+packet_names(sim,info.cargo[unit])
static func work(sim,unit:int)->Dictionary:
 var info=status(sim)
 if info.is_empty() or unit<0 or unit>=info.jobs.size() or info.jobs[unit].is_empty():return {"unit":-1}
 var result=info.jobs[unit].duplicate(true);result.unit=unit;return result
static func task(sim,unit:int)->String:
 var job=work(sim,unit)
 return "RECOVER %d%% · RAW DATA"%clampi(floori(job.elapsed/maxf(.01,job.duration)*100),0,100) if job.unit>=0 else ""
static func wreck_cargo(sim,item:String)->String:
 for site in sim.salvage_sites():
  if site.item==item and not site.get("packets",[]).is_empty():return "RAW DATA · "+packet_names(sim,site.packets)
 return ""
static func active(sim,unit:int)->bool:return work(sim,unit).unit>=0 or not cargo(sim,unit).is_empty()
static func carriers(sim)->Array:
 var result=[]
 if status(sim).is_empty():return result
 for unit in [1,2]:
  var context=sim.blackwater_handoff_context(unit)
  if not context.packets.is_empty():result.append(context)
 return result
static func detail(sim)->String:
 var info=status(sim)
 if info.is_empty():return ""
 var lines=[summary(sim),info.text]
 for packet in info.packets:
  var state="ABOARD QUIETUS" if packet.aboard else "NOT RECORDED" if not packet.recorded else "FIELD NOTE · RAW DATA NEEDED"
  if not packet.aboard and not packet.carriers.is_empty():
   var names=[]
   for unit in packet.carriers:names.append(sim.units[unit].name)
   state="BUFFER · "+", ".join(names)
  if not packet.aboard and not packet.salvage.is_empty():state+=" · OWN WRECK"
  lines.append(packet.name+" · "+state)
 for context in carriers(sim):lines.append(sim.units[context.carrier].name+" → Q · "+context.reason)
 lines.append("TRANSFER: both craft settled below 2m/s, within 60m, clear line of sight, neither busy. Quietus can SAMPLE each relay directly; field notes alone do not deliver raw data.")
 return "\n".join(lines)
static func debrief_text(sim)->String:
 if status(sim).is_empty():return ""
 var count=counts(sim)
 return "RAW EXCHANGE DELIVERED %d/2\nFIELD NOTES RETAINED %d/2\nOnly packets physically aboard Quietus qualify for recovery."%[count.aboard,count.notes]
static func debrief(main)->void:
 var text=debrief_text(main.sim)
 if not text.is_empty():main._menu_text(text,17)
