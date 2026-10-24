extends RefCounted
# ARCH2 contract adapter keeps the Control-backed recipient screen and its Node
# lifetimes/API untouched. Its later world slot stays after legacy intervening
# views. Revert this PR to restore direct seams and remove only this adapter.
const Recipient=preload("res://src/presentation/warning_recipient_view.gd")
static func applies(sim)->bool:return sim!=null
static func build_panel(hud)->void:
 var sim=hud.host.sim
 var recipient=Recipient.status(sim)
 if not recipient.is_empty():
  hud.extra.warning_exposed.disabled=not recipient.actions.depart.ready
  hud.extra.warning_sheltered.disabled=not recipient.actions.depart.ready or not recipient.gate.opened
  hud.extra.warning_gate.disabled=not recipient.actions.gate.ready
  if hud.subject.get("subkind","") in ["warning_recipient","warning_gate"]:hud.instrument_info.text=Recipient.detail(sim,hud.subject)
  var recipient_primary=Recipient.primary_subject(sim)
  if hud.page=="craft" and not recipient_primary.is_empty():
   hud.host.order_buttons.camera.text="GATE\nCONTROLS" if recipient_primary.subkind=="warning_gate" else "RECIPIENT\nCONTROLS";hud.host.order_buttons.camera.disabled=false
   hud.instrument_info.text=Recipient.detail(sim,recipient_primary)
static func draw(view)->void:Recipient.draw_world(view,view.sim)
