extends RefCounted
# A read-only projection of successfully recovered equipment. Main owns fitting,
# uniqueness, persistence and the launch snapshot; this view grants nothing.
const Catalog=preload("res://src/equipment/equipment_catalog.gd")
const Economy=preload("res://src/campaign/economy.gd")
const SLOTS={"quietus":"QUIETUS","drone_a":"DRONE A","drone_b":"DRONE B"}
# A locked frame is bought with alloy when tapped, then chosen like any other.
static func _pick_frame(main,locked:bool,unit:int,id:String,key:String,choose:Callable)->void:
 if locked and not Economy.buy_unlock(main.economy,Economy.unlock_of(unit,id)):return
 choose.call(key,id)
static func rows(context:Dictionary)->Array:
 var result=[];var slots=context.get("slots",{});var available=context.get("available",[])
 for slot in SLOTS:
  var unit=Catalog.SLOTS.find(slot)
  for item in context.get("catalog",[]):
   if slot not in item.compatible_slots:continue
   var holder=Catalog.key_of(slots,item.id);var other=Catalog._unit_of(holder) if not holder.is_empty() else ""
   var here=other==slot
   var refusal="";var replaces=""
   if not here and other.is_empty() and item.id in available and Catalog.ITEMS.has(item.id):
    var attempt=Catalog.choose(slots,slot,item.id,available)
    if not attempt.ok:refusal=attempt.get("reason","")
    else:
     for previous in Catalog.items_for(slots,unit):
      if previous not in Catalog.items_for(attempt.fitted,unit):replaces=Catalog.ITEMS[previous].name
   result.append({"slot":slot,"station":SLOTS[slot],"id":item.id,"name":item.name,"current":item.id if here else "","key":holder if here else slot,"benefit":item.benefit,"cost":item.cost,"mount":Catalog.ITEMS.get(item.id,{}).get("mount",""),"power":Catalog.ITEMS.get(item.id,{}).get("power",0),"cargo":Catalog.ITEMS.get(item.id,{}).get("cargo",0),"blocked_by":SLOTS.get(other,"") if not here else "","refused":refusal,"replaces":replaces,"unavailable":item.id not in available,"unit":unit})
 return result
static func fitting(main,context:Dictionary,choose:Callable)->Array:
 var options=rows(context);var buttons=[]
 if options.is_empty():return buttons
 main._menu_text("RECOVERED FITTINGS / NEXT LAUNCH",19)
 main._menu_text("BARE remains available. A launch fixes its equipment; resuming keeps the active dive’s fit. Each fitting takes a typed mount and draws power from its craft.",15)
 var described=[]
 for row in options:
  if row.id not in described:
   var needs="%s MOUNT · %d POWER"%[row.mount,row.power]+(" · %d CARGO"%row.cargo if row.cargo>0 else "") if not row.mount.is_empty() else ""
   main._menu_text("%s\n%s\nCOST · %s"%[row.name,row.benefit,row.cost]+("\n"+needs if not needs.is_empty() else ""),16);described.append(row.id)
  var fitted=row.current==row.id
  var title="%s · %s → BARE"%[row.station,row.name] if fitted else ("%s · BARE → FIT %s"%[row.station,row.name] if row.replaces.is_empty() else "%s · FIT %s · REPLACES %s"%[row.station,row.name,row.replaces])
  var blocked=row.unavailable or (not fitted and (not row.blocked_by.is_empty() or not row.refused.is_empty()))
  if not fitted and not row.refused.is_empty():title="%s · %s REFUSED · %s"%[row.station,row.name,row.refused.to_upper()]
  if not fitted and not row.blocked_by.is_empty():title="%s · %s ON %s"%[row.station,row.name,row.blocked_by]
  if row.unavailable:title="%s · %s UNAVAILABLE · LEFT BEHIND"%[row.station,row.name]
  var key=row.key;var id="" if fitted else row.id
  var button=main._button(main.panel_box,title,func():choose.call(key,id),"fit_"+row.slot)
  button.disabled=blocked;buttons.append(button)
 return buttons
# Hull and chassis frames with typed mounts and budget bars. Returns frame buttons.
static func _bar(main,parent:Node,label:String,value:float,cap:float,text:String,over:bool)->void:
 var column=VBoxContainer.new();column.size_flags_horizontal=Control.SIZE_EXPAND_FILL;column.mouse_filter=Control.MOUSE_FILTER_PASS;parent.add_child(column)
 var caption=Label.new();caption.text="%s %s"%[label,text];caption.add_theme_font_size_override("font_size",roundi(13*main.ui_touch_height/48.0));column.add_child(caption)
 var bar=ProgressBar.new();bar.show_percentage=false;bar.max_value=maxf(cap,0.001);bar.value=minf(value,cap);bar.mouse_filter=Control.MOUSE_FILTER_PASS
 bar.custom_minimum_size=Vector2(0,maxf(8,main.ui_touch_height*0.18))
 var fill=StyleBoxFlat.new();fill.bg_color=Color("e08a5c") if over else Color("6bd5cb");var back=StyleBoxFlat.new();back.bg_color=Color("17323a")
 bar.add_theme_stylebox_override("fill",fill);bar.add_theme_stylebox_override("background",back);column.add_child(bar)
static func frame_summary(fit:Dictionary,unit:int)->String:
 var b=Catalog.budget(fit,unit);var parts=[]
 for mount in b.mounts:parts.append("%s %s"%[mount.type,Catalog.ITEMS[mount.item].name if not mount.item.is_empty() else "empty"])
 return "%s · %s\n%s\nMOUNTS · %s"%[SLOTS[Catalog.SLOTS[unit]],b.name.to_upper(),Catalog.frame(fit,unit).summary," · ".join(parts)]
static func loadout(main,fit:Dictionary,choose:Callable)->Array:
 var buttons=[]
 main._menu_text("HULL AND DRONE FRAMES / NEXT LAUNCH",19)
 main._menu_text("POWER and CARGO are hard limits. NOISE scales motion sound, ENDURANCE scales life support or battery. A bus drawn to capacity makes SONAR pulses cost half again as much.",15)
 for unit in 3:
  var b=Catalog.budget(fit,unit)
  main._menu_text(frame_summary(fit,unit),16)
  var strip=HBoxContainer.new();strip.mouse_filter=Control.MOUSE_FILTER_PASS;strip.custom_minimum_size.x=minf(610,main.size.x-120);strip.add_theme_constant_override("separation",12);main.panel_box.add_child(strip)
  _bar(main,strip,"POWER",b.power,b.power_cap,"%d / %d"%[b.power,b.power_cap],b.power>=b.power_cap and b.power>0)
  _bar(main,strip,"CARGO",b.cargo,b.cargo_cap,"%d / %d"%[b.cargo,b.cargo_cap],b.cargo_cap>0 and b.cargo>=b.cargo_cap)
  _bar(main,strip,"NOISE",b.noise,1.5,"%d%%"%roundi(b.noise*100),b.noise>1.0)
  _bar(main,strip,"ENDURANCE",b.endurance,2.0,"%d%%"%roundi(b.endurance*100),b.endurance<1.0)
  for id in Catalog.frames(unit):
   var key=Catalog.FRAME_KEYS[Catalog.SLOTS[unit]]
   var attempt=Catalog.choose(fit,key,id,[])
   var selected=Catalog.frame_id(fit,unit)==id
   var title="%s · %s%s"%[SLOTS[Catalog.SLOTS[unit]],Catalog.frames(unit)[id].name.to_upper()," · SELECTED" if selected else ""]
   if not attempt.ok:title+=" · REFUSED · "+attempt.reason.to_upper()
   var locked=Economy.frame_locked(main.economy,main.expedition,unit,id)
   var price=Economy.unlock_cost(main.economy,Economy.unlock_of(unit,id))
   if locked:title="%s · %s · LOCKED · BUY %s"%[SLOTS[Catalog.SLOTS[unit]],Catalog.frames(unit)[id].name.to_upper(),Economy.fmt(price)]
   var button=main._button(main.panel_box,title,_pick_frame.bind(main,locked,unit,id,key,choose),"frame_"+Catalog.SLOTS[unit]+"_"+id)
   button.disabled=selected or not attempt.ok or (locked and not Economy.can_pay(main.economy,price));buttons.append(button)
 return buttons
static func status(sim)->String:
 if not sim.has_method("equipment_feedback"):return ""
 var feedback=sim.equipment_feedback();var fit=feedback.get("fitted",{});var index=clampi(sim.selected,0,2);var slot=SLOTS.keys()[index]
 var parts=[]
 if Catalog.frame_id(fit,index)!="standard" and Catalog.valid_fitting(fit):parts.append(Catalog.frame(fit,index).name.to_upper())
 for id in Catalog.items_for(fit,index):parts.append(Catalog.ITEMS.get(id,{}).get("name","FITTED EQUIPMENT").to_upper())
 if parts.is_empty():return ""
 return "%s · %s"%[SLOTS[slot]," · ".join(parts)]

static func correlation(sim)->Dictionary:
 if not sim.has_method("equipment_feedback"):return {}
 var feedback=sim.equipment_feedback()
 return feedback.get("correlation",{}) if Catalog.has(feedback.get("fitted",{}),0,"quietus_correlator") else {}
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
 if not Catalog.has(sim.equipment_feedback().get("fitted",{}),sim.selected,"drone_sampler"):return ""
 var active=sim.capture_unit==sim.selected
 var context=sim.camera_context();var target=sim.capture_target if active else context.get("target",-1)
 var sites=sim.observable_sites()
 if target<0 or target>=sites.size() or not sites[target].get("sampler_compatible",false) or (not active and not context.get("ready",false)):return ""
 return "FIELD SAMPLE · AUDIBLE 8s"+(" · %.1f / 8s"%sim.capture_time if active else " · settle to begin")
