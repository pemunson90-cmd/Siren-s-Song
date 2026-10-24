extends RefCounted
# ARCH2 contract adapter retains the original Control arrival screen and all
# legacy projection/input/drawing helpers. Revert this PR to restore direct seams.
const Witness=preload("res://src/presentation/witness_evacuation_view.gd")
static func applies(sim)->bool:return sim!=null
static func build_panel(hud)->void:
 var sim=hud.host.sim
 var witness=Witness.status(sim)
 if not witness.is_empty():
  hud.extra.witness_land.disabled=not sim.witness_context().land.ready
  hud.extra.witness_land.tooltip_text=sim.witness_context().land.reason
  if Witness.site_for_item(sim,hud.subject.get("item","")):
   var winch=sim.salvage_context(hud.subject.item)
   hud.extra.salvage.text="WINCH\nWITNESS" if not winch.active else "WINCH\n%d%%"%floori(winch.elapsed/winch.duration*100)
  if (hud.page=="inspect" and hud.subject.get("subkind","")!="concealed") or Witness.harbour_subject(sim,hud.subject):hud.instrument_info.text=Witness.detail(sim)+"\n\n"+hud.instrument_info.text
  if not Witness.site(sim).is_empty() and hud.subject.get("kind","")=="craft":hud.host.order_buttons.camera.text="WITNESS\nWINCH"
static func draw(view)->void:Witness.draw_world(view,view.sim)
