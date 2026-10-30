extends RefCounted
# Mode-local controls share allocation, limits and cargo arithmetic with Campaign.
const Racks=preload("res://src/equipment/tool_racks.gd")
const View=preload("res://src/presentation/tool_racks_view.gd")
const Tools=preload("res://src/equipment/field_tools.gd")
static func change(host,is_run:bool,slot:String,id:String,delta:int)->void:
 if host.active_started or host.save_failed:return
 if not is_run and host._mutations_blocked():return
 var next=host.tool_racks.duplicate(true)
 next[slot][id]=int(next[slot].get(id,0))+delta
 if not Racks.valid(next):return
 if is_run and not Racks.available(next,host.run_state.stock):return
 if delta>0 and not Racks.reason(host.fitted_equipment,next).is_empty():return
 host.tool_racks=next
 if is_run:
  host.run_state.tool_racks=next.duplicate(true)
  host._show_campaign()
 else:
  host._save_archive();host._show_fittings()
static func show(host,is_run:bool)->void:
 host._menu_text("TOOLS / LOCKERS + CARGO",19)
 host._menu_text("Each craft deploys its own tools. Extra charges beyond its locker share cargo with modules and winch work. Unload to recover cargo."+(" Unloaded stock stays ashore for later operations." if is_run else " Extra charges cost career supplies each launch."),15)
 host._menu_text(View.summary(host),15)
 var why=Racks.reason(host.fitted_equipment,host.tool_racks)
 if not why.is_empty():host._menu_text(why,15)
 for slot in Racks.UNITS:
  host._menu_text(slot.to_upper(),17)
  for id in Tools.ids():
   if slot!="quietus" and id in Racks.QUIETUS_ONLY:continue
   if id in Tools.field_ids() and not Tools.is_enabled(id):continue
   var n=int(host.tool_racks[slot].get(id,0))
   host._menu_text("%s %d"%[Racks.label(id),n],15)
   var candidate=host.tool_racks.duplicate(true);candidate[slot][id]=n+1
   var add=host._button(host.panel_box,"LOAD +1 "+Tools.spec(id).name,change.bind(host,is_run,slot,id,1),"mode_rack_add_"+slot+"_"+id)
   add.disabled=host.save_failed or not Racks.valid(candidate) or not Racks.reason(host.fitted_equipment,candidate).is_empty() or (is_run and not Racks.available(candidate,host.run_state.stock))
   var remove=host._button(host.panel_box,"UNLOAD -1 "+Tools.spec(id).name,change.bind(host,is_run,slot,id,-1),"mode_rack_remove_"+slot+"_"+id)
   remove.disabled=host.save_failed or n<=0
