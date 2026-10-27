extends RefCounted
# Standalone preparation entry; the existing catalog still validates every choice.
# Seam: Main._show_fittings. Revert: remove entry, method and this view.
const Equipment=preload("res://src/presentation/equipment_context.gd")
static func show(main)->void:
 main.screen="fittings";main.sim.paused=true;main._clear_menu()
 main._button(main.panel_box,"BACK TO OPERATIONS",main._show_campaign,"back")
 main._menu_text("FITTINGS / NEXT LAUNCH",30)
 main._menu_text("Changes apply to the next dive. RESUME keeps the active dive's equipment.",16)
 if preload("res://src/campaign/economy_table.gd").enabled:main._button(main.panel_box,"SUPPLIES / COSTS",main._show_economy,"economy")
 preload("res://src/campaign/early_reward/early_reward.gd").fittings(main)
 var context=main._equipment_context()
 if 0 in main.completed or not main._equipment_entitlements().is_empty():
  Equipment.loadout(main,context.slots,func(key,id):main._choose_equipment(key,id,-1))
 else:main._menu_text("Recover the first operation to choose hull and drone frames.",16)
 Equipment.fitting(main,context,func(key,id):main._choose_equipment(key,id,-1))
 main.call_deferred("_layout")
