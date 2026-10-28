extends RefCounted
# Existing radial buttons, salvage markers and craft cargo projection only.
const Cache=preload("res://src/simulation/optional_cache.gd")
static func applies(sim)->bool:return sim!=null and Cache.applies(sim)
static func setup(hud)->void:
 hud.extra.cache_menu=hud.host._button(hud,"CACHE",func():hud.open("cache"),"cache_menu")
 for action in ["unload","transfer","drop"]:
  hud.extra["cache_"+action]=hud.host._button(hud,{"unload":"UNLOAD CACHE\nAT RECOVERY","transfer":"TRANSFER CACHE\nTO QUIETUS","drop":"DROP ONE\nCACHE PIECE"}[action],func():hud.host._order("cache_action",{"action":action}),"cache_"+action)
static func controls(hud)->Array:
 return [hud.extra.cache_unload,hud.extra.cache_transfer,hud.extra.cache_drop,hud.extra.inspect]
static func captions(sim)->Array:
 var received=Cache.pieces(sim).values().filter(func(p):return p.state=="received").size()
 return ["RECEIVED %d / 3"%received,"CARGO %d / %d"%[sim.ModuleRecovery.carried(sim,sim.selected),sim.ModuleRecovery.capacity(sim,sim.selected)],"ACCOUNT RECEIVED" if received==3 else "UNLOAD READY" if Cache.unload_context(sim).ready else "UNLOAD · MIDDLE / MOUTH / STOP"]
static func build_panel(hud)->void:
 var sim=hud.host.sim;var c=Cache.unload_context(sim)
 hud.extra.cache_unload.disabled=not c.ready;hud.extra.cache_unload.tooltip_text=c.reason
 hud.extra.cache_transfer.disabled=not Cache.transfer_ready(sim)
 hud.extra.cache_drop.disabled=Cache.carried(sim,sim.selected)==0 or Cache.occupied(sim,sim.selected) or not sim.units[sim.selected].transition.is_empty()
 if hud.page=="cache":
  var lines=["OPTIONAL SERVICE CACHE · %d / %d places used"%[sim.ModuleRecovery.carried(sim,sim.selected),sim.ModuleRecovery.capacity(sim,sim.selected)]]
  for item in Cache.IDS:
   var p=Cache.pieces(sim)[item]
   lines.append(item.replace("_"," ").to_upper()+" · "+(sim.units[p.carrier].name if p.state=="cargo" else p.state.to_upper())+" · "+sim.Depth.NAMES[p.band])
  lines.append(c.reason)
  lines.append("Tap a charted cache piece for RECOVER. Four seconds settled, within60m, same depth, clear terrain;520m audible winch. UNLOAD frees places before the required photograph is finished. All three received earn a first-return account; optional cargo never gates victory.")
  hud.instrument_info.text="\n".join(lines)+"\n"+sim.message
static func cargo(sim,id:int)->Array:
 var result=[]
 for item in Cache.pieces(sim):
  var p=Cache.pieces(sim)[item]
  if p.state=="cargo" and p.carrier==id:result.append("CACHE CARGO · "+item.replace("_"," ").to_upper())
 return result
static func work(sim,id:int)->Dictionary:
 if not Cache.busy(sim,id):return {}
 var job=sim.mission.optional_cache.jobs[id].duplicate(true);job.unit=id;job.duration=Cache.Winch.DURATION;return job
static func debrief(main)->void:
 if not applies(main.sim):return
 var received=Cache.pieces(main.sim).values().filter(func(p):return p.state=="received").size()
 main._menu_text("OPTIONAL CACHE · %d / 3 RECEIVED\n"%received+(Cache.NOTE if received==3 else "The complete service account requires three physical pieces. Remaining pieces were left in the water."),17)
