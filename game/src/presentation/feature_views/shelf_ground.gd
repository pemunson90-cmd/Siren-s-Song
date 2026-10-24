extends RefCounted
# Same three-function contract, dedicated to Shelf's earlier terrain phase.
# Legacy drawing stays in Shelf; revert the Shelf migration to remove this seam.
const Shelf=preload("res://src/presentation/shelf_habitat_view.gd")
static func applies(sim)->bool:return Shelf.applies(sim)
static func build_panel(_hud)->void:pass
static func draw(view)->void:Shelf.draw_ground(view,view.sim)
