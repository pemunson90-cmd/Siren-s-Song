extends RefCounted
# 098 next-launch controls use the host's 48 dp scrolling buttons and ordinary Fittings Back route.
# Revert: Racks.enabled=false. No writes to a launched dive, including Ironman.
const Racks=preload("res://src/equipment/tool_racks.gd")
const Tools=preload("res://src/equipment/field_tools.gd")
const Catalog=preload("res://src/equipment/equipment_catalog.gd")
const Economy=preload("res://src/campaign/economy.gd")
static func _redraw(host,action:Callable)->void:
 var position=host.scroll.scroll_vertical
 action.call();host._save_archive();host._show_fittings()
 var heading=host.panel_box.get_child(0)
 (func():
  await host.get_tree().process_frame
  if is_instance_valid(heading) and heading.get_parent()==host.panel_box:host.scroll.scroll_vertical=position
 ).call_deferred()
static func fill(host,choice:String)->void:
 host.upgrade=choice;host.tool_racks=Racks.template(choice)
static func edit(host,slot:String,id:String,delta:int,stock:Dictionary={},stock_limited:bool=false)->bool:
 if not Racks.enabled:return false
 var next=host.tool_racks.duplicate(true)
 next[slot][id]=int(next[slot].get(id,0))+delta
 if not Racks.valid(next):return false
 if stock_limited and not Racks.available(next,stock):return false
 # Unloading is always possible, even after choosing a smaller frame.
 if delta>0 and not Racks.reason(host.fitted_equipment,next).is_empty():return false
 host.tool_racks=next
 return true
static func show_mode(host,is_run:bool,change:Callable)->void:
 if not Racks.enabled:return
 host._menu_text("TOOLS / LOCKERS + CARGO",19)
 host._menu_text("Each craft deploys its own tools. Extra charges beyond its locker share cargo with modules and winch work. Unload to recover cargo."+(" Unloaded stock stays ashore for later operations." if is_run else " Extra charges cost career supplies each launch."),15)
 host._menu_text(summary(host),15)
 var why=Racks.reason(host.fitted_equipment,host.tool_racks)
 if not why.is_empty():host._menu_text(why,15)
 controls(host,Racks.UNITS,change,"mode_rack",host.run_state.stock if is_run else {},false,is_run)
static func controls(host,slots:Array,change:Callable,prefix:String,stock:Dictionary={},detailed:bool=false,stock_limited:bool=false)->void:
 if not Racks.enabled:return
 for slot in slots:
  if prefix=="mode_rack":host._menu_text(slot.to_upper(),17)
  for id in Tools.ids():
   if slot!="quietus" and id in Racks.QUIETUS_ONLY:continue
   if id in Tools.field_ids() and not Tools.is_enabled(id):continue
   var n=int(host.tool_racks[slot].get(id,0))
   var label=Racks.label(id) if prefix=="mode_rack" else Tools.spec(id).name.to_upper()
   host._menu_text("%s %d%s"%[label,n," | %.2f SPACE EACH (LOCKER FIRST)"%[Tools.CARGO_WEIGHTS[id]/100.0] if detailed else ""],15)
   var candidate=host.tool_racks.duplicate(true);candidate[slot][id]=n+1
   var slot_key=slot+"_" if prefix=="mode_rack" else ""
   var add=host._button(host.panel_box,"LOAD +1 "+Tools.spec(id).name,change.bind(slot,id,1),prefix+"_add_"+slot_key+id)
   add.disabled=(prefix=="mode_rack" and host.save_failed) or not Racks.valid(candidate) or not Racks.reason(host.fitted_equipment,candidate).is_empty() or (stock_limited and not Racks.available(candidate,stock))
   var remove=host._button(host.panel_box,"UNLOAD -1 "+Tools.spec(id).name,change.bind(slot,id,-1),prefix+"_remove_"+slot_key+id)
   remove.disabled=(prefix=="mode_rack" and host.save_failed) or n<=0
static func summary(host)->String:
 var lines=[]
 for unit in 3:
  var b=Catalog.budget(host.fitted_equipment,unit)
  var used=b.cargo+Racks.cargo(host.tool_racks,unit)
  var locker=Racks.locker_ticks(unit)/100.0
  var held=Racks.locker_used_ticks(host.tool_racks,unit)/100.0
  lines.append("%s LOCKER %.2f / %.2f | %.2f LEFT\nCARGO %.2f / %d | %.2f LEFT"%[Catalog.NAMES[Racks.UNITS[unit]],held,locker,locker-held,used,b.cargo_cap,b.cargo_cap-used])
 return "\n".join(lines)
static func stock(host)->String:
 var parts=[]
 for id in Tools.ids():parts.append("%d %s"%[Racks.total(host.tool_racks,id),Racks.label(id)])
 return " / ".join(parts)
static func show(host)->void:
 if not Racks.enabled:return
 host._menu_text("FINITE TOOLS / LOCKERS + CARGO",19)
 host._menu_text("Templates fill dedicated tool lockers and keep cargo free for winch work. Tools fill the locker first; overflow shares cargo with modules and winch work. LOAD +1 may use cargo. RESUME preserves the active dive's stock.",15)
 for choice in Tools.LOADOUTS:
  var oxygen=host._loadout_stock(choice)[0]
  host._button(host.panel_box,"FILL %s | O2 %d%%"%[choice.to_upper(),oxygen],func():_redraw(host,func():fill(host,choice)),"tools_loadout_"+choice)
 host._menu_text(summary(host),15)
 var why=Racks.reason(host.fitted_equipment,host.tool_racks)
 if not why.is_empty():host._menu_text(why+". Unload charges or choose a larger frame before launch.",15)
 host._menu_text("EXTRA CHARGE MANUFACTURING / NEXT LAUNCH: "+Economy.fmt(Racks.cost(host.tool_racks,host.upgrade,host.economy))+". Template totals are free; extras are charged each launch, including Ironman retries.",15)
 host._button(host.panel_box,"EMPTY ALL RACKS",func():_redraw(host,func():host.tool_racks=Racks.empty()),"rack_empty")
 var selected=host.get_meta("rack_craft","quietus")
 for slot in Racks.UNITS:
  var button=host._button(host.panel_box,"EDIT "+Catalog.NAMES[slot],func():_redraw(host,func():host.set_meta("rack_craft",slot)),"rack_craft_"+slot)
  button.disabled=slot==selected
 host._menu_text("%s / %s"%[Catalog.NAMES[selected],"Torpedo and Hull patch: Quietus only." if selected=="quietus" else "Loaded tools deploy from this drone. Torpedo and Hull patch: Quietus only."],15)
 controls(host,[selected],func(slot,id,delta):_redraw(host,func():edit(host,slot,id,delta)),"rack",{},true)
