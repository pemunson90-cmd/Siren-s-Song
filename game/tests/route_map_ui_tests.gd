extends "res://tests/fix2_menu_ui_tests.gd"
func tap(point):
 var move=InputEventMouseMotion.new();move.device=InputEvent.DEVICE_ID_EMULATION;move.position=point;move.global_position=point;root.push_input(move,true)
 for pressed in [true,false]:
  var event=InputEventMouseButton.new();event.device=InputEvent.DEVICE_ID_EMULATION;event.position=point;event.button_index=MOUSE_BUTTON_LEFT;event.pressed=pressed;root.push_input(event,true);await process_frame
 await settle()
func drag_chart(start:Vector2,delta:Vector2):
 var down=InputEventMouseButton.new();down.device=InputEvent.DEVICE_ID_EMULATION;down.position=start;down.button_index=MOUSE_BUTTON_LEFT;down.pressed=true;root.push_input(down,true);await process_frame
 var previous=start
 for n in 16:
  var point=start+delta*(n+1)/16.
  var move=InputEventMouseMotion.new();move.device=InputEvent.DEVICE_ID_EMULATION;move.position=point;move.global_position=point;move.relative=point-previous;move.button_mask=MOUSE_BUTTON_MASK_LEFT;root.push_input(move,true);previous=point;await process_frame
 down=InputEventMouseButton.new();down.device=InputEvent.DEVICE_ID_EMULATION;down.position=start+delta;down.button_index=MOUSE_BUTTON_LEFT;down.pressed=false;root.push_input(down,true);await settle()
func shape_case(shape):
 root.size=shape;await settle()
 var game=load("res://scenes/main.tscn").instantiate();game.set_script(load("res://tests/density_main.gd"));game.capture_scenario="runtime-test"
 root.add_child(game);await settle();game.set_process(false);game._show_campaign();await settle()
 var opened=await press(game,"route_map")
 if not opened:game.queue_free();await settle();return
 var view=game.get_node_or_null("RouteMapView")
 check(view!=null and game.screen=="route_map","real touch opens the standalone route map")
 if view==null:game.queue_free();await settle();return
 var before=game._archive().duplicate(true)
 check(view.buttons.size()==30,"the real view presents all thirty nodes")
 check(view.buttons[0].text.contains("AVAILABLE") and view.buttons[1].text.contains("UNKNOWN"),"fresh map names only the available first operation")
 check(view.buttons.values().all(func(b):return b.size.y>=game.ui_touch_height and b.size.x>=game.ui_touch_height),"all node targets meet Android minimums")
 check(button(game,"route_map_back").size.y>=game.ui_touch_height,"Back remains a full touch target")
 var alternate=Vector2i(2184,1968) if shape.x==2520 else Vector2i(2520,1080)
 root.size=alternate;await settle()
 check(view.buttons.values().all(func(b):return b.size.y>=game.ui_touch_height) and Rect2(Vector2.ZERO,view.size).encloses(Rect2(view.chart.position,view.chart.size)),"live resize keeps the chart and touch targets within the viewport")
 root.size=shape;await settle()
 var area=view.chart.get_global_rect()
 await drag_chart(area.get_center(),Vector2(-300,-120))
 check(view.chart.scroll_horizontal>0 and view.chart.scroll_vertical>0 and game.screen=="route_map","real drag pans both axes without launching an operation")
 var old_size=view.buttons[0].size
 await press(game,"route_map_zoom_in")
 check(view.zoom>1. and view.buttons[0].size.x>old_size.x,"real touch zoom enlarges the chart")
 await press(game,"route_map_zoom_out");await press(game,"route_map_zoom_out")
 check(view.zoom==view.Table.VIEW.zoom_min and view.buttons[0].size.y>=game.ui_touch_height,"zoom cannot shrink touch targets below the minimum")
 check(game._archive()==before,"viewing, pan and zoom never write campaign or active-dive state")
 var selected=await press(game,"route_map_op_0")
 check(selected and game.screen=="briefing" and game.get_node_or_null("RouteMapView")==null,"available node opens its existing briefing through real touch")
 await android_back();check(game.screen=="menu","Android Back leaves the existing briefing normally")
 game.completed=[0,1,2,3,4,5];game.unlocked=5
 game.expedition=preload("res://src/campaign/campaign_consequences.gd").upgrade({"version":2,"route":"deep","routes":["deep"],"completed":[6,7,9,11,12,14,15,16,17],"facts":{"deep":"observed","confluence_route":"concealed"}})
 game.photo_intel={"silt_scour":{"q":.4,"op":17}}
 check(game.store.valid(game._archive()),"mid-campaign fixture is a valid existing save")
 game._show_campaign();await settle();await press(game,"route_map");view=game.get_node("RouteMapView")
 before=game._archive().duplicate(true)
 check(view.buttons[17].text.contains("RECOVERED") and view.buttons[18].text.contains("AVAILABLE"),"mid-campaign map follows actual route availability")
 check(view.buttons[19].text.contains("KNOWN FROM PHOTOS") and not view.buttons[19].disabled,"returned film names an unreached operation without opening its route")
 await press(game,"route_map_op_19")
 check(game.screen=="route_map" and view.detail.text.contains("film") and not view.detail.text.contains("AVAILABLE"),"photo-known node explains information without starting a locked operation")
 var captures=OS.get_environment("ROUTE_MAP_CAPTURE_DIR")
 if not captures.is_empty():
  await RenderingServer.frame_post_draw
  root.get_texture().get_image().save_png(captures+"/route-map-%d.png"%shape.x)
 check(game._archive()==before,"photo rumours grant no progress, equipment or save state")
 await press(game,"route_map_back");check(game.screen=="menu" and game.get_node_or_null("RouteMapView")==null,"on-screen Back restores the fallback operations list")
 await press(game,"route_map");await escape_key();check(game.screen=="menu" and game.get_node_or_null("RouteMapView")==null,"Escape closes the route map")
 await press(game,"route_map");await android_back();check(game.screen=="menu" and game.get_node_or_null("RouteMapView")==null,"Android Back matches Escape")
 var Table=load("res://src/campaign/route_map/route_graph_table.gd");Table.enabled=false;game._show_campaign();await settle()
 check(button(game,"route_map")==null and button(game,"mission0")!=null,"off switch restores the unchanged flat list")
 Table.enabled=true;game.queue_free();await settle()
func run():
 var emulation=Input.is_emulating_touch_from_mouse();Input.set_emulate_touch_from_mouse(true)
 for shape in [Vector2i(2520,1080),Vector2i(2184,1968)]:await shape_case(shape)
 Input.set_emulate_touch_from_mouse(emulation)
 print("ROUTE MAP UI CHECKS %d FAILURES %d"%[checks,failures]);quit(1 if failures else 0)
