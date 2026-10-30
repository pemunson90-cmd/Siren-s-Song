extends RefCounted
# Mode-local controls share allocation, limits and cargo arithmetic with Campaign.
const Racks=preload("res://src/equipment/tool_racks.gd")
const View=preload("res://src/presentation/tool_racks_view.gd")
static func change(host,is_run:bool,slot:String,id:String,delta:int)->void:
 if not Racks.enabled:return
 if host.active_started or host.save_failed:return
 if not is_run and host._mutations_blocked():return
 if not View.edit(host,slot,id,delta,host.run_state.stock if is_run else {},is_run):return
 var next=host.tool_racks
 if is_run:
  host.run_state.tool_racks=next.duplicate(true)
  host._show_campaign()
 else:
  host._save_archive();host._show_fittings()
static func show(host,is_run:bool)->void:
 View.show_mode(host,is_run,func(slot,id,delta):change(host,is_run,slot,id,delta))
