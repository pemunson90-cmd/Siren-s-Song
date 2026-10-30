extends "res://tests/audit_navigation_tests.gd"
# Engine touch events generate their own mouse partners. Do not manually inject
# mouse events: that omitted the real regression in the earlier layout fixtures.
var folder=OS.get_environment("SIRENS_CHART_CAPTURE_DIR")
func native_event(point,index,down):
 var touch=InputEventScreenTouch.new();touch.index=index;touch.position=root.get_screen_transform()*point;touch.pressed=down;Input.parse_input_event(touch);await process_frame
func native_touch(point):
 for down in [true,false]:await native_event(point,0,down)
 await settle()
func shot(label):
 if folder.is_empty() or DisplayServer.get_name()=="headless":return
 await settle();await RenderingServer.frame_post_draw
 check(root.get_texture().get_image().save_png(folder+"/"+label+".png")==OK,"capture "+label)
func run():
 Input.set_emulate_touch_from_mouse(true)
 Input.emulate_mouse_from_touch=true
 if not folder.is_empty():DirAccess.make_dir_recursive_absolute(folder)
 print("STAGED chart-stop plus photo-preview fixture; real touch; no voyage claim")
 for shape in [Vector2i(2520,1080),Vector2i(2184,1968)]:
  for scale in [1.,1.5]:
   for compact in [false,true]:
    for action in ["chart_continue","chart_replan"]:
     if "--quick" in OS.get_cmdline_user_args() and (shape.x!=2520 or scale!=1. or not compact or action!="chart_replan"):continue
     var game=await make_game(shape,scale)
     game.hints_seen=game.OnboardingText.HINTS.keys()
     if shape.x==2520:game.fixture_safe_area=Rect2(136,0,2384,1080);game._layout()
     game._start_mission(0);await settle()
     var s=game.sim;wall_fixture(s);s.paused=true
     s.command("route",{"point":Vector2(1200,500)})
     game._refresh();await settle();measure_wall(s);move_for(s,30)
     for o in s.mission.objectives:
      if not o.get("subject",{}).is_empty():
       o.pos=s.units[0].pos+Vector2(-60,0);o.band=s.units[0].band;s.units[0].angle=PI;break
     game._refresh();await settle()
     var feed=game.ocean.optical_feed
     check(feed.is_visible_in_tree(),"actual photo viewfinder visible")
     if feed.get("compact")!=null and feed.compact!=compact:
      var point=feed.global_position+feed.toggle_rect.get_center()
      await native_event(point,0,true)
      # A second finger on inert optics cannot steal the first release.
      var inert=feed.global_position+Vector2(20,20)
      await native_event(inert,1,true);await native_event(inert,1,false)
      await native_event(point,0,false);await settle()
      check(feed.compact==compact and not game.advanced_orders,"native touch folds once without another modal")
     game._refresh();await settle()
     var choice=game.mission_hud.chart_choice
     var label="%dx%d-%d-%s-%s"%[shape.x,shape.y,roundi(scale*100),"compact" if compact else "full",action]
     check(choice.panel.visible,"choice visible "+label)
     var overlaps=choice.panel.get_global_rect().intersects(feed.get_global_rect())
     print("CHART GEOMETRY ",label," overlap=",overlaps," actual_compact=",feed.get("compact"))
     if feed.get("compact")!=null:check(not overlaps,"choice avoids optics "+label)
     await shot(label+"-choice")
     var goals=s.route_goals().duplicate(true)
     var target=button(game,action)
     check(target!=null and target.is_visible_in_tree(),"decision target remains available "+label)
     if target!=null:
      if not compact:
       # Conversely a secondary fold cannot swallow a primary decision release.
       var point=target.get_global_rect().get_center()
       await native_event(point,0,true)
       var fold=feed.global_position+feed.toggle_rect.get_center()
       await native_event(fold,1,true);await native_event(fold,1,false)
       await native_event(point,0,false);await settle()
       check(feed.compact and not game.advanced_orders,"secondary fold preserves primary decision ownership "+label)
      else:await native_touch(target.get_global_rect().get_center())
     check(s.route_goals()==goals,"touch retains destination "+label)
     if action=="chart_continue":check(not s.units[0].has("chart_stop"),"continue actually clears held stop "+label)
     check(game.screen==("program" if action=="chart_replan" else "mission"),"tap owns decision "+label)
     await shot(label+"-result")
     game.queue_free();await settle()
 print("AUDIT OPTICS TOUCH CHECKS ",checks," FAILURES ",failures)
 quit(1 if failures else 0)
