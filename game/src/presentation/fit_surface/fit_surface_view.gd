extends RefCounted
# Screen widget: craft tabs, one section per mount type, one row per module that fits the shown craft.
# Rows keep the legacy fit_<slot> action and fitting_id meta, so taps still go straight to Main._choose_equipment.
# Seams: fittings_menu.gd show, flow/campaign_flow.gd briefing (fit hook). Revert: fit_surface_table.enabled=false.
const Table=preload("res://src/presentation/fit_surface/fit_surface_table.gd")
const Model=preload("res://src/presentation/fit_surface/fit_surface.gd")
const Equipment=preload("res://src/presentation/equipment_context.gd")
const Catalog=preload("res://src/equipment/equipment_catalog.gd")
const Economy=preload("res://src/campaign/economy.gd")
const META="fit_surface_tab"
static func tab_of(main)->String:
 var tab=main.get_meta(META,Table.TABS[0])
 return tab if tab in Table.TABS else Table.TABS[0]
# Switch the shown craft, rebuild the screen and keep the reading position.
static func _pick_tab(main,slot:String,rebuild:Callable)->void:
 main.set_meta(META,slot)
 var position=main.scroll.scroll_vertical
 rebuild.call()
 var heading=main.panel_box.get_child(0)
 (func():
  await main.get_tree().process_frame
  if is_instance_valid(heading) and heading.get_parent()==main.panel_box:main.scroll.scroll_vertical=position
 ).call_deferred()
# Tabs, frame line, budget bars and grouped rows. Returns the fit buttons (as Equipment.fitting does).
static func fitting(main,context:Dictionary,choose:Callable,rebuild:Callable)->Array:
 if not Table.enabled:return Equipment.fitting(main,context,choose)
 var buttons=[]
 if Equipment.rows(context).is_empty():return buttons
 var shown=tab_of(main)
 main._menu_text("RECOVERED FITTINGS / NEXT LAUNCH",19)
 main._menu_text("BARE remains available. A launch fixes its equipment; resuming keeps the active dive’s fit.",15)
 main._menu_text("Pick a craft, then a mount: each row shows what the tap changes.",15)
 var strip=HBoxContainer.new();strip.mouse_filter=Control.MOUSE_FILTER_PASS;strip.add_theme_constant_override("separation",8)
 strip.custom_minimum_size.x=minf(610,main.size.x-120);main.panel_box.add_child(strip)
 for slot in Table.TABS:
  var tab=main._button(strip,("[%s]" if slot==shown else "%s")%Equipment.SLOTS[slot],_pick_tab.bind(main,slot,rebuild),"fit_tab_"+slot)
  tab.size_flags_horizontal=Control.SIZE_EXPAND_FILL;tab.mouse_filter=Control.MOUSE_FILTER_PASS;tab.disabled=slot==shown
 var unit=Catalog.SLOTS.find(shown);var fit=Catalog.canonical(context.get("slots",{}))
 var owned=Model.frames_owned(main.economy,main.expedition,unit)
 var frame=Catalog.budget(fit,unit)
 main._menu_text("%s · %s · %d of %d frames owned"%[Equipment.SLOTS[shown],frame.name.to_upper(),owned[0],owned[1]],16)
 var bars=HBoxContainer.new();bars.mouse_filter=Control.MOUSE_FILTER_PASS;bars.add_theme_constant_override("separation",12)
 bars.custom_minimum_size.x=minf(610,main.size.x-120)
 main.panel_box.add_child(bars)
 var full=frame.power>=frame.power_cap and frame.power>0
 Equipment._bar(main,bars,"POWER",frame.power,frame.power_cap,"%d / %d"%[frame.power,frame.power_cap],full)
 full=frame.cargo_cap>0 and frame.cargo>=frame.cargo_cap
 Equipment._bar(main,bars,"CARGO",frame.cargo,frame.cargo_cap,"%d / %d"%[frame.cargo,frame.cargo_cap],full)
 Equipment._bar(main,bars,"NOISE",frame.noise,1.5,"%d%%"%roundi(frame.noise*100),frame.noise>1.0)
 Equipment._bar(main,bars,"ENDURANCE",frame.endurance,2.0,"%d%%"%roundi(frame.endurance*100),frame.endurance<1.0)
 var groups=Model.sections(context,shown)
 if groups.is_empty():main._menu_text("No recovered fitting fits this craft yet.",16)
 for group in groups:
  main._menu_text(group.label,17)
  for row in group.rows:
   var fitted=row.current==row.id
   var delta=Model.delta_text(context,row)
   var text="%s\n%s · %s"%[Model.title(row),Model.state_tag(row),delta if not delta.is_empty() else Model.draw_text(row)]
   var key=row.key;var id="" if fitted else row.id
   var button=main._button(main.panel_box,text,Equipment._choose_fitting.bind(main,key,id,row.id,choose),"fit_"+row.slot)
   button.set_meta("fitting_id",row.id)
   button.disabled=row.unavailable or (not fitted and (not row.blocked_by.is_empty() or not row.refused.is_empty()))
   buttons.append(button)
   main._menu_text("%s\nCOST · %s"%[row.benefit,row.cost],14)
 return buttons
# Compact fit summary for the briefing; the tabbed list below it holds the detail.
static func summary(main,context:Dictionary)->void:
 if not Table.enabled or Equipment.rows(context).is_empty():return
 main._menu_text(Model.summary(context),14)
