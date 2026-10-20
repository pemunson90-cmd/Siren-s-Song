extends SceneTree
# Real recovery controller, responsive hit regions and injected touch navigation.
var checks=0
var failures=0
func check(ok,label):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():call_deferred("run")
func settle():
 for n in 6:await process_frame
func tap(point:Vector2):
 for down in [true,false]:
  var touch=InputEventScreenTouch.new();touch.index=0;touch.position=point;touch.pressed=down;root.push_input(touch,true)
  var mouse=InputEventMouseButton.new();mouse.device=InputEvent.DEVICE_ID_EMULATION;mouse.position=point;mouse.global_position=point;mouse.button_index=MOUSE_BUTTON_LEFT;mouse.pressed=down;root.push_input(mouse,true);await process_frame
 await settle()
func run():
 for dimensions in [Vector2i(2520,1080),Vector2i(2184,1968)]:
  root.size=dimensions;await settle()
  var game=load("res://scenes/main.tscn").instantiate();game.set_script(load("res://tests/density_main.gd"));game.capture_scenario="confluence-resolution-ui"
  root.add_child(game);await settle();game.set_process(false)
  game.completed=[0,1,2,3,4,5]
  game.expedition={"version":2,"route":"deep","routes":["deep"],"facts":{"deep":"Recovered deep carrier"},"completed":[6,7,9],"notes":{},"references":{},"entitlements":[],"history":[],"selected_thread":"deep"}
  game._start_mission(11)
  var route="concealed" if dimensions.x==2520 else "overt"
  game.sim.mission.recovered=true;game.sim.mission.chosen_route=route
  game.sim.mission.expedition_facts={"confluence_packet":game.sim.mission.signal_sources[0].evidence}
  var source=game.sim.mission.signal_sources[0]
  game.sim.mission.objectives=[{"site_id":source.id,"name":source.label,"pos":source.pos,"kind":"receiver","required_unit":0,"duration":4.,"captured":true,"evidence":source.evidence,"optical":source.optical}]
  game.sim.outcome="won";game._debrief();game._layout();await settle()
  var scene=game.get_node_or_null("ConfluenceResolution")
  check(scene!=null and not game.menu.visible,"successful Confluence recovery enters a dedicated scene")
  check(game.expedition.completed.has(11) and game.expedition.facts.get("confluence_route")==route,"scene preserves the campaign-owned physical route commitment")
  var controls=game._ui_metrics().controls
  check(["next_expedition","evidence","retry","back"].all(func(action):return controls.any(func(c):return c.action==action and not c.clipped)),"all four recovery actions including Field Record are visible on the actual layout")
  if scene!=null:
   check(scene.art_rect.size.y>game.size.y*.45,"departure occupies the play viewport rather than a scrolling record card")
   var button=scene.actions.get_children().filter(func(c):return c.get_meta("action","")=="next_expedition")[0]
   var point=button.get_global_rect().get_center()
   await tap(point)
   check(game.screen=="briefing" and game.get_node_or_null("ConfluenceResolution")==null,"actual Continue touch disposes recovery scene and opens the chosen continuation")
  game.queue_free();await settle()
 print("CONFLUENCE RESOLUTION UI CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
