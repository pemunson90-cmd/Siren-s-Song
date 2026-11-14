extends "res://tests/challenges_ui_tests.gd"
# 124 staged native captures, with public photo and craft/object projections.
const Settings=preload("res://src/presentation/frontend/frontend_settings.gd")
const Scene=preload("res://src/presentation/photo_scene.gd")
var folder=OS.get_environment("SIRENS_124_CAPTURE_DIR")
func shot(label):
 if folder.is_empty() or DisplayServer.get_name()=="headless":return
 await RenderingServer.frame_post_draw
 check(root.get_texture().get_image().save_png(folder.path_join(label+".png"))==OK,"native capture "+label)
func run():
 if not folder.is_empty():DirAccess.make_dir_recursive_absolute(folder)
 var saved=Settings.current.duplicate(true)
 for shape in [Vector2i(2520,1080),Vector2i(2184,1968)]:
  for scale in [1.,1.5]:
   root.size=shape;await settle()
   var g=load("res://scenes/main.tscn").instantiate();g.set_script(load("res://tests/density_main.gd"));g.capture_scenario="runtime-test"
   g.store.path="user://pr-audit-layout.save"
   if shape.x==2520:g.fixture_safe_area=Rect2(136,0,2384,1080)
   root.add_child(g);await settle();g.set_process(false)
   Settings.current.text_scale=scale
   g._start_mission(0);g._enter_water();await settle()
   g.hints_seen=g.OnboardingText.HINTS.keys();g.mission_hud.hints.panel.hide()
   var s=g.sim;var o=s.mission.objectives[0];var u=s.units[0]
   u.pos=o.pos+Vector2.from_angle(o.subject.facing)*100.;u.angle=u.pos.angle_to_point(o.pos);u.vel=Vector2.ZERO;u.band=o.get("band",1)
   g.ocean.focus_craft();g._layout();g._refresh();await settle()
   var stamp="%dx%d-%d"%[shape.x,shape.y,roundi(scale*100)]
   await shot(stamp+"-photo")
   # Exercise the same hidden-feature hint beside an unknown public contact.
   var ocean=g.ocean;var p=u.pos+Vector2(25,0)
   ocean.world_label_rects.clear()
   var first=ocean.world_label_position(p,"UNKNOWN SIGNAL SOURCE",17)
   ocean.reserve_world_label(first,"UNKNOWN SIGNAL SOURCE",17)
   var hint="SCORED PLATING: HIDDEN"
   var second=ocean.world_label_position(p,hint,14)
   check(first.is_finite() and second.is_finite(),"both chart labels can be placed "+stamp)
   if second.is_finite():
    var bounds=ocean.world_label_rect(second,hint,14)
    check(not ocean.world_label_rects[0].intersects(bounds),"hint clears unknown contact "+stamp)
    check(not ocean.ui_blocked_rects.any(func(r):return r.intersects(bounds)) and not ocean.optical_feed.get_rect().intersects(bounds),"hint clears dock "+stamp)
   var feed=ocean.optical_feed
   var tag=Scene.tag_rect(feed.picture_rect,feed.picture_rect.get_center(),"BEACON LAMP",feed.receiver_font_size,0)
   check(feed.picture_rect.encloses(tag),"photo annotation fits image "+stamp)
   check(tag.end.y<feed.picture_rect.end.y-maxi(10,feed.receiver_font_size-2)-6,"annotation clears aspect readout "+stamp)
   g._start_mission(34);g._enter_water();s=g.sim;s.paused=true
   var target={}
   for site in s.observable_sites():
    if "DISCONNECT" in str(site.get("name","")):target=site;break
   check(not target.is_empty(),"public disconnect choice exists "+stamp)
   if not target.is_empty():
    g.mission_hud.choose_units=[1];g.mission_hud.choose_next="object";g.mission_hud.open("choose",target);g._layout();g._refresh();await settle()
    var b=g.mission_hud.extra.choose_object
    check(b.text=="DISCONNECT\nBY Q","complete action and recipient on choice "+stamp)
    if g.mission_hud.order_dock.visible:
     g.mission_hud.order_dock_scroll.ensure_control_visible(b);await settle()
     check(g.mission_hud.order_dock_scroll.get_global_rect().encloses(b.get_global_rect()),"complete choice reachable by scroll "+stamp)
    await shot(stamp+"-choice")
   g.queue_free();await settle()
 Settings.current=saved
 print("PR AUDIT LAYOUT CHECKS ",checks," FAILURES ",failures)
 quit(1 if failures else 0)
