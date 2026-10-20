extends RefCounted
# A read-only projection of successfully recovered equipment. Main owns fitting,
# uniqueness, persistence and the launch snapshot; this view grants nothing.
const Catalog=preload("res://src/equipment/equipment_catalog.gd")
const SLOTS={"quietus":"QUIETUS","drone_a":"DRONE A","drone_b":"DRONE B"}
static func rows(context:Dictionary)->Array:
 var result=[];var slots=context.get("slots",{});var available=context.get("available",[])
 for slot in SLOTS:
  for item in context.get("catalog",[]):
   if slot not in item.compatible_slots:continue
   var other=""
   for key in SLOTS:
    if key!=slot and slots.get(key,"")==item.id:other=key
   result.append({"slot":slot,"station":SLOTS[slot],"id":item.id,"name":item.name,"current":slots.get(slot,""),"benefit":item.benefit,"cost":item.cost,"blocked_by":SLOTS.get(other,""),"unavailable":item.id not in available})
 return result
static func fitting(main,context:Dictionary,choose:Callable)->Array:
 var options=rows(context);var buttons=[]
 if options.is_empty():return buttons
 main._menu_text("RECOVERED FITTINGS / NEXT LAUNCH",19)
 main._menu_text("BARE remains available. A launch fixes its equipment; resuming keeps the active dive’s fit.",15)
 var described=[]
 for row in options:
  if row.id not in described:
   main._menu_text("%s\n%s\nCOST · %s"%[row.name,row.benefit,row.cost],16);described.append(row.id)
  var fitted=row.current==row.id
  var title="%s · %s → BARE"%[row.station,row.name] if fitted else "%s · BARE → FIT %s"%[row.station,row.name]
  var blocked=row.unavailable or (not fitted and not row.blocked_by.is_empty())
  if blocked:title="%s · %s ON %s"%[row.station,row.name,row.blocked_by]
  if row.unavailable:title="%s · %s UNAVAILABLE · LEFT BEHIND"%[row.station,row.name]
  var slot=row.slot;var id="" if fitted else row.id
  var button=main._button(main.panel_box,title,func():choose.call(slot,id),"fit_"+slot)
  button.disabled=blocked;buttons.append(button)
 return buttons
static func status(sim)->String:
 if not sim.has_method("equipment_feedback"):return ""
 var feedback=sim.equipment_feedback();var slots=feedback.get("fitted",{});var index=clampi(sim.selected,0,2);var slot=SLOTS.keys()[index]
 var id=slots.get(slot,"")
 if id.is_empty():return ""
 return "%s · %s"%[SLOTS[slot],Catalog.ITEMS.get(id,{}).get("name","FITTED EQUIPMENT").to_upper()]

static func correlation(sim)->Dictionary:
 if not sim.has_method("equipment_feedback"):return {}
 var feedback=sim.equipment_feedback()
 return feedback.get("correlation",{}) if feedback.get("fitted",{}).get("quietus","")=="quietus_correlator" else {}
static func correlation_detail(sim)->String:
 var result=correlation(sim)
 if result.is_empty():return ""
 var state=result.get("status","listening");var title={"listening":"LISTENING · %.1f / 6s settled"%result.get("dwell",0.),"match":"MATCHED CADENCE","other":"OTHER CADENCE","unresolved":"UNRESOLVED · no unique match"}.get(state,"UNRESOLVED")
 var text="QUIETUS CORRELATOR · "+title
 var index=0
 for arrival in result.get("arrivals",[]):
  index+=1
  var direction:Vector2=arrival.direction
  var bearing=fposmod(rad_to_deg(atan2(direction.x,-direction.y)),360.)
  text+="\nM%d %s · %03d° ±%d° · %.1fs ago\n%s"%[index,"MATCHED CADENCE" if arrival.get("classification","")=="match" else "OTHER CADENCE",roundi(bearing)%360,roundi(rad_to_deg(arrival.uncertainty)),maxf(0.,sim.elapsed-arrival.time),cadence_text(arrival.get("cadence",[]))]
 return text+"\n"+result.get("qualification","Cadence only; identity, range and passage safety remain unknown.")
static func cadence_text(cadence:Array)->String:
 var parts=[]
 for value in cadence:parts.append("%.1f"%value)
 return "PULSES "+" / ".join(parts)+"s" if not parts.is_empty() else "Cadence unresolved"
static func sample_detail(sim)->String:
 if sim.selected not in [1,2] or not sim.has_method("equipment_feedback"):return ""
 var slot="drone_a" if sim.selected==1 else "drone_b"
 if sim.equipment_feedback().get("fitted",{}).get(slot,"")!="drone_sampler":return ""
 var active=sim.capture_unit==sim.selected
 var context=sim.camera_context();var target=sim.capture_target if active else context.get("target",-1)
 var sites=sim.observable_sites()
 if target<0 or target>=sites.size() or not sites[target].get("sampler_compatible",false) or (not active and not context.get("ready",false)):return ""
 return "FIELD SAMPLE · AUDIBLE 8s"+(" · %.1f / 8s"%sim.capture_time if active else " · settle to begin")
