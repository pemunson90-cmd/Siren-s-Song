extends "res://tests/depth_sonar_ui_tests.gd"
# Actual viewport teaching/controls across the authored arc; staged context
# probes are explicitly separate from full command/input journeys.
func run():
 for arg in OS.get_cmdline_user_args():
  if arg.begins_with("--capture-dir="):captures=arg.trim_prefix("--capture-dir=");DirAccess.make_dir_recursive_absolute(captures)
 for dimensions in [Vector2i(2520,1080),Vector2i(2184,1968)]:
  root.size=dimensions;await settle()
  var g=load("res://scenes/main.tscn").instantiate();g.set_script(load("res://tests/density_main.gd"));g.store.path="user://opening-context-%d.save"%dimensions.x
  if dimensions.x==2520:g.fixture_safe_area=Rect2(136,0,2384,1080)
  root.add_child(g);await settle();g.set_process(false)
  for id in range(1,6):
   g._start_mission(id);await settle();g.mission_hud.dismiss();g._refresh();await settle()
   var h=g.mission_hud
   check(h.intent.visible and h.intent.text.contains(g.sim.mission.depth_hint),"in-play initial depth decision appears without briefing scroll: "+str(id))
   check(h.intent.get_global_rect().end.y<=dimensions.y and h.intent.size.y>=h.intent.get_line_height()*2,"context uses existing protected two-line HUD: "+str(id))
   await capture("%d-op%d-local-choice"%[dimensions.x,id])
   h.open("craft",{"kind":"craft","unit":0,"pos":g.sim.units[0].pos});await settle();await click(h.extra.depth_menu)
   check(h.page=="acoustics" and h.extra.sonar_history.visible,"real touch opens depth/sonar in opening "+str(id))
   await click(h.extra.depth_down)
   check(not g.sim.units[0].transition.is_empty() and g.sim.Depth.context(g.sim).contains("BOTH"),"real touch starts exposed deliberate transition with contextual teaching "+str(id))
   h.dismiss();g.sim.paused=false
   for n in 250:g.sim.advance(1./60)
   g.sim.paused=true;g._refresh();await settle()
   h.open("craft",{"kind":"craft","unit":0,"pos":g.sim.units[0].pos});await settle()
   check(not g.sim.camera_context().ready and g.sim.camera_context().text.contains("MIDDLE"),"depth work limitation remains discoverable in local controls "+str(id))
   await click(h.extra.depth_menu);await click(h.extra.sonar_history)
   check(h.sonar_waterfall.visible and h.instrument_info.text.contains("Own noise"),"real history input exposes masking/bearing readout "+str(id))
   await capture("%d-op%d-depth-history"%[dimensions.x,id]);h.dismiss()
  g.queue_free();await settle()
 print("OPENING DEPTH UI CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
