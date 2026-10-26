extends RefCounted
# Same contract for the existing craft-local pass. Context carries only the
# original canvas, simulation reference and unchanged unit index; no state writes.
# Revert the Witness migration to restore the direct three-argument call.
const Witness=preload("res://src/presentation/witness_evacuation_view.gd")
static func applies(sim)->bool:return sim!=null
static func build_panel(_hud)->void:pass
static func draw(view)->void:Witness.draw_carried(view.canvas,view.sim,view.unit)
