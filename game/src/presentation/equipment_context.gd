extends RefCounted
const Names=preload("res://src/names.gd")
# A read-only projection of successfully recovered equipment. Main owns fitting,
# uniqueness, persistence and the launch snapshot; this view grants nothing.
const Catalog=preload("res://src/equipment/equipment_catalog.gd")
const Economy=preload("res://src/campaign/economy.gd")
const Card=preload("res://src/presentation/fit_surface/fit_card.gd")
const Bar=preload("res://src/presentation/fit_surface/fit_bar.gd")
const UiStyle=preload("res://src/presentation/ui_style.gd")
const PrepColumns=preload("res://src/presentation/prep_columns.gd")
const Metrics=preload("res://src/presentation/layout_metrics.gd")
const NEXT_LAUNCH_NOTE="Applies from your next launch."
const SLOTS={Names.CRAFT_QUIETUS:Names.UNIT_QUIETUS,Names.CRAFT_DRONE_A:Names.UNIT_DRONE_A,Names.CRAFT_DRONE_B:Names.UNIT_DRONE_B}
# A locked frame is bought with alloy when tapped, then chosen like any other.
static func _pick_frame(main,locked:bool,unit:int,id:String,key:String,choose:Callable)->void:
 if locked and not Economy.buy_unlock(main.economy,Economy.unlock_of(unit,id)):return
 choose.call(key,id)
static func rows(context:Dictionary)->Array:
 var result=[];var slots=context.get("slots",{});var available=context.get("available",[])
 # Quietus first, then each drone module with both compatible carriers together.
 for carriers in [[Names.CRAFT_QUIETUS],[Names.CRAFT_DRONE_A,Names.CRAFT_DRONE_B]]:
  for item in context.get("catalog",[]):
   for slot in carriers:
    var unit=Catalog.SLOTS.find(slot)
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
 heading(main,"RECOVERED FITTINGS")
 main._menu_text("BARE remains available. A launch fixes its equipment; resuming keeps the active dive’s fit. Each fitting takes a typed mount and draws power from its craft.",15)
 for row in options:
  var needs="%s MOUNT · %d POWER"%[row.mount,row.power]+(" · %d CARGO"%row.cargo if row.cargo>0 else "") if not row.mount.is_empty() else ""
  buttons.append(fitting_card(main,row,needs,choose,true))
 return buttons
# A section heading with one small sub-line under it.
static func heading(main,title:String,note:String=NEXT_LAUNCH_NOTE)->void:
 main._menu_text(title,19)
 main._menu_text(note,14)
# The card for one fitting row. `detail` is an extra line (budget change or mount needs). The craft name is
# added when the card is not already under a craft tab. Tapping behaves as the old row did.
static func fitting_card(main,row:Dictionary,detail:String,choose:Callable,with_craft:bool)->Button:
 var fitted=row.current==row.id
 var spec={"name":("%s · %s"%[row.station,row.name]) if with_craft else row.name,"line":row.benefit,"chosen":fitted,"lock":"","extra":[]}
 if row.unavailable:spec.lock="Left behind. It is not in your stores."
 elif fitted:spec.extra.append("Tap to remove it.")
 elif not row.blocked_by.is_empty():spec.lock="Fitted on %s. Remove it there first."%row.blocked_by
 elif not row.refused.is_empty():spec.lock="Cannot fit: %s"%row.refused
 else:spec.extra.append("Tap to fit it." if row.replaces.is_empty() else "Tap to fit it. It replaces %s."%row.replaces)
 spec.extra.append(detail);spec.extra.append("COST · %s"%row.cost)
 var key=row.key;var id="" if fitted else row.id
 var button=Card.add(main,spec,_choose_fitting.bind(main,key,id,row.id,choose),"fit_"+row.slot)
 button.set_meta("fitting_id",row.id)
 button.disabled=row.unavailable or (not fitted and (not row.blocked_by.is_empty() or not row.refused.is_empty()))
 return button
# Keep the selected module and its alternative carriers in view after rebuilding.
static func _choose_fitting(main,key:String,id:String,module_id:String,choose:Callable)->void:
 choose.call(key,id)
 var heading=main.panel_box.get_child(0)
 for n in 2:await main.get_tree().process_frame
 if not is_instance_valid(heading) or heading.get_parent()!=main.panel_box:return
 var group=Rect2();var found=false
 # On a wide Fittings screen the cards sit in the right-hand column, which scrolls on its own.
 for control in main.panel_box.find_children("*","Button",true,false):
  if control.get_meta("fitting_id","")==module_id:
   group=group.merge(control.get_global_rect()) if found else control.get_global_rect();found=true
 var scroller=PrepColumns.scroller(main)
 var area=scroller.get_global_rect()
 if not found or group.size.y>area.size.y:return
 if group.position.y<area.position.y:scroller.scroll_vertical-=ceili(area.position.y-group.position.y)
 elif group.end.y>area.end.y:scroller.scroll_vertical+=ceili(group.end.y-area.end.y)
# Hull and chassis frames with typed mounts and budget bars. Returns frame buttons.
# The four budget bars of one craft in one row. POWER and CARGO fill to their limit; NOISE and ENDURANCE
# are drawn to true scale with the stock value (100%) marked by a tick. Returns the bars.
static func budget_bars(main,b:Dictionary)->Array:
 # WP-93: four captions in one row can need more than the column holds (a tall touch row on a phone, the
 # narrow half of a two-column briefing). When they do the bars wrap into two rows of two.
 var strip=GridContainer.new();strip.columns=4;strip.mouse_filter=Control.MOUSE_FILTER_PASS
 strip.add_theme_constant_override("h_separation",roundi(Metrics.BAR_STRIP_GAP));strip.add_theme_constant_override("v_separation",roundi(Metrics.BAR_STRIP_GAP));main.panel_box.add_child(strip)
 var scale=UiStyle.BAR_SCALE_MAX
 var bars=[
  Bar.add(main,strip,"POWER",b.power,b.power_cap,"%d / %d"%[b.power,b.power_cap],b.power>=b.power_cap and b.power>0),
  Bar.add(main,strip,"CARGO",b.cargo,b.cargo_cap,"%d / %d"%[b.cargo,b.cargo_cap],b.cargo_cap>0 and b.cargo>=b.cargo_cap),
  Bar.add(main,strip,"NOISE",b.noise,scale,"%d%%"%roundi(b.noise*100),b.noise>1.0,1.0),
  Bar.add(main,strip,"ENDURANCE",b.endurance,scale,"%d%%"%roundi(b.endurance*100),b.endurance<1.0,1.0)]
 strip.set_meta(STRIP_META,true);refit_strip(strip,PrepColumns.strip_width(main))
 return bars
const STRIP_META="bar_strip"
# One row of four when the captions fit `room`, else two rows of two. The briefing calls this again for
# each strip once it has split into columns and knows how wide a column is.
static func refit_strip(strip:GridContainer,room:float)->void:
 strip.columns=4
 if strip.get_combined_minimum_size().x>room:strip.columns=2
# A two-column briefing: no menu text or bar strip asks for more than one column holds.
static func fit_to_column(box:Control,room:float)->void:
 for label in box.find_children("*","Label",true,false):label.custom_minimum_size.x=minf(label.custom_minimum_size.x,room)
 for strip in box.find_children("*","GridContainer",true,false):
  if strip.has_meta(STRIP_META):refit_strip(strip,room)
# The craft name and its current mounts; the frame itself is described by the cards under it.
static func frame_summary(fit:Dictionary,unit:int)->String:
 var b=Catalog.budget(fit,unit);var parts=[]
 for mount in b.mounts:parts.append("%s %s"%[mount.type,Catalog.ITEMS[mount.item].name if not mount.item.is_empty() else "empty"])
 return "%s\nMOUNTS · %s"%[SLOTS[Catalog.SLOTS[unit]]," · ".join(parts)]
# What choosing a frame costs or why it cannot be chosen, as the lock line of its card.
static func frame_lock(main,unit:int,id:String,attempt:Dictionary)->String:
 if Economy.frame_locked(main.economy,main.expedition,unit,id):
  var price=Economy.unlock_cost(main.economy,Economy.unlock_of(unit,id))
  var line="Tap to buy it for %s."%Economy.fmt(price)
  return line if Economy.can_pay(main.economy,price) else "Costs %s. You are short by %s."%[Economy.fmt(price),Economy.shortfall(main.economy,price)]
 return "" if attempt.ok else "Cannot choose: %s"%attempt.reason
static func loadout(main,fit:Dictionary,choose:Callable)->Array:
 var buttons=[]
 heading(main,"HULL AND DRONE FRAMES")
 main._menu_text("POWER and CARGO are hard limits. NOISE scales motion sound, ENDURANCE scales life support or battery. A bus drawn to capacity makes SONAR pulses cost half again as much.",15)
 for unit in 3:
  var b=Catalog.budget(fit,unit)
  main._menu_text(frame_summary(fit,unit),16)
  budget_bars(main,b)
  for id in Catalog.frames(unit):
   var key=Catalog.FRAME_KEYS[Catalog.SLOTS[unit]]
   var attempt=Catalog.choose(fit,key,id,[])
   var selected=Catalog.frame_id(fit,unit)==id
   var locked=Economy.frame_locked(main.economy,main.expedition,unit,id)
   var price=Economy.unlock_cost(main.economy,Economy.unlock_of(unit,id))
   var spec={"name":Catalog.frames(unit)[id].name,"line":Catalog.frames(unit)[id].summary,"chosen":selected,"lock":frame_lock(main,unit,id,attempt)}
   var button=Card.add(main,spec,_pick_frame.bind(main,locked,unit,id,key,choose),"frame_"+Catalog.SLOTS[unit]+"_"+id)
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
