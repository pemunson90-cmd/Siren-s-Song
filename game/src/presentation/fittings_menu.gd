extends RefCounted
# Standalone preparation entry; the existing catalog still validates every choice.
# Seam: Main._show_fittings. Revert: remove entry, method and this view.
# WP-53: on a wide screen the summary (what each craft carries, locker and cargo bars, cost, currency) is a
# left column that stays in view and the controls scroll on their own on the right (PrepColumns). On a narrow
# screen the sections come in the order they always did.
const Equipment=preload("res://src/presentation/equipment_context.gd")
const FitSurface=preload("res://src/presentation/fit_surface/fit_surface_view.gd")
const PrepColumns=preload("res://src/presentation/prep_columns.gd")
const Metrics=preload("res://src/presentation/layout_metrics.gd")
const UiStyle=preload("res://src/presentation/ui_style.gd")
const RackView=preload("res://src/presentation/tool_racks_view.gd")
const EconomyPanel=preload("res://src/presentation/economy_panel.gd")
const Tools=preload("res://src/equipment/field_tools.gd")
const SUPPLIES_BUTTON="SUPPLIES AND COSTS"
const RECORDS_BUTTON="RESEARCH AND RECORDS"
static func show(main)->void:
 # A redraw after a tool change is not a new visit: the first-visit note stays away and the feedback marker stays.
 var fresh=main.screen!="fittings"
 if fresh and main.has_meta(RackView.CHANGED_META):main.remove_meta(RackView.CHANGED_META)
 main.screen="fittings";main.sim.paused=true;main._clear_menu()
 # Wide: BACK shares the first line with the heading so the summary column fits a 720 px high canvas.
 if not PrepColumns.wide(main):main._button(main.panel_box,"BACK TO OPERATIONS",main._show_campaign,"back")
 var columns=PrepColumns.open(main,main._show_fittings,true)
 var left=columns[0];var right=columns[1];var wide=PrepColumns.is_wide(main)
 PrepColumns.into(main,left,_heading.bind(main,fresh,wide))
 # Wide: the first-visit note and the launch note lead the scrolling controls (the summary column keeps to the
 # lines that must stay in view) and the carry sentences sit with each craft's bars (RackView).
 if wide:
  if fresh:PrepColumns.into(main,right,func():EconomyPanel.currency_hint(main))
  PrepColumns.into(main,right,_note.bind(main))
 else:PrepColumns.into(main,right,_frames.bind(main))
 if not wide:PrepColumns.into(main,left,func():main._menu_text(RackView.carry_text(main.tool_racks),15))
 if Tools.enabled:RackView.show(main,left,right)
 if wide:PrepColumns.into(main,right,_frames.bind(main))
 PrepColumns.into(main,right,_links.bind(main))
 main.call_deferred("_layout")
static func _heading(main,fresh:bool,wide:bool)->void:
 var title=main._menu_text("FITTINGS",30)
 if wide:
  var line=HBoxContainer.new();line.add_theme_constant_override("separation",roundi(Metrics.MENU_COLUMN_GAP));main.panel_box.add_child(line)
  var back=main._button(line,"BACK TO OPERATIONS",main._show_campaign,"back")
  back.custom_minimum_size.x=main.ui_touch_height*UiStyle.PREP_BACK_TOUCHES
  title.reparent(line);title.custom_minimum_size.x=0;title.size_flags_horizontal=Control.SIZE_EXPAND_FILL;title.vertical_alignment=VERTICAL_ALIGNMENT_CENTER
  EconomyPanel.currency_line(main)
 else:EconomyPanel.currency(main,fresh)
 if not wide:_note(main)
static func _note(main)->void:
 main._menu_text("Changes apply from your next launch. RESUME keeps the active dive's equipment.",16)
# Hull and drone frames, then the recovered fittings cards.
static func _frames(main)->void:
 var context=main._equipment_context()
 if 0 in main.completed or not main._equipment_entitlements().is_empty():
  Equipment.loadout(main,context.slots,func(key,id):main._choose_equipment(key,id,-1))
 else:main._menu_text("Recover the first operation to choose hull and drone frames.",16)
 FitSurface.fitting(main,context,func(key,id):main._choose_equipment(key,id,-1),main._show_fittings)
static func _links(main)->void:
 if preload("res://src/campaign/economy_table.gd").enabled:main._button(main.panel_box,SUPPLIES_BUTTON,main._show_economy,"economy")
 preload("res://src/presentation/archive/archive_nav.gd").entry(main)
 # The archive entry is the button just added; the fittings screen words it plainly.
 var records_button=main.panel_box.get_child(main.panel_box.get_child_count()-1)
 if records_button is Button and records_button.get_meta("action","")=="archive":records_button.text=RECORDS_BUTTON
 preload("res://src/campaign/early_reward/early_reward.gd").fittings(main)
