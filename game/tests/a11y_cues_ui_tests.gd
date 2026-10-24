extends "res://tests/challenges_ui_tests.gd"
# Source-known layout and touch fixtures at recorded 420 dpi. Actual isolated
# SettingsStore files persist; campaign boot persistence is intentionally disabled.
const Settings=preload("res://src/presentation/frontend/frontend_settings.gd")
const Store=preload("res://src/persistence/settings_store.gd")
var capture_dir=""
func capture(name):
 if not capture_dir.is_empty() and DisplayServer.get_name()!="headless":
  await RenderingServer.frame_post_draw
  check(root.get_texture().get_image().save_png(capture_dir.path_join(name+".png"))==OK,"native GPU capture saved "+name)
func shape_case(shape):
 root.size=shape;await settle()
 var path="user://a11y-ui-%d-settings.json"%shape.x
 var store=Store.new();store.path=path
 check(store.save_settings(Store.DEFAULTS),"scoped real settings fixture starts explicitly")
 Settings.apply(Store.DEFAULTS)
 var game=load("res://scenes/main.tscn").instantiate();game.set_script(load("res://tests/density_main.gd"));game.capture_scenario="runtime-test";game.settings_path=path
 if shape.x==2520:game.fixture_safe_area=Rect2(136,0,2384,1080)
 root.add_child(game);await settle();game.set_process(false);game._show_campaign();await settle()
 var front=Front.new();front.settings_store.path=path;game.add_child(front);front.setup(game);await settle()
 await press(front,"frontend_settings");await press(front,"text_scale_150")
 for id in ["setting_safe_palette","setting_audio_captions","setting_haptics"]:
  var b=button(front,id);check(b!=null,"setting is present "+id)
  if b!=null:
   var dp=float(root.size.x)/root.get_visible_rect().size.x*160./420.
   check(b.size.x*dp>=48 and b.size.y*dp>=48,"new settings retain48dp targets at420dpi")
  await press(front,id)
 await create_timer(.4).timeout
 var saved=store.load_settings()
 check(saved.safe_palette and saved.audio_captions and not saved.haptics and saved.text_scale==1.5,"real touch settings persist all optional fields at150percent")
 await android_back();check(front.screen=="title","Android Back returns from settings")
 front._dismiss();await settle();game._start_mission(0);game.sim.paused=false
 var s=game.sim;var o=s.mission.objectives[0];var u=s.units[0]
 u.pos=o.pos+Vector2.from_angle(o.subject.facing)*100.;u.angle=u.pos.angle_to_point(o.pos);u.vel=Vector2.ZERO
 s.elapsed=10.;game.sound.update(s,0.);s.elapsed=11.
 s.contacts={0:{"pos":u.pos+Vector2(80,0),"time":11.,"mode":"LOCKING","lock":2.,"target":0,"type":"patroller","source":"optical","angle":0.,"band":1}}
 s.events=[{"type":"sweep_received","receiver":0,"time":11.,"direction":Vector2.UP}]
 game.sound.muted=true;game.sound.update(s,0.);game._layout();await settle()
 var baseline=s.snapshot();var view=game.audio_captions
 print("A11Y GEOMETRY ",shape," visible=",view.visible," high=",view.get_meta("placement_height",0)," text=",view.text," rect=",view.get_global_rect()," host=",game.size," occupied=",view.occupied)
 check(view.visible and "HEARD" in view.text,"muted critical receiver captions are drawn beside live camera and lock")
 check(Rect2(game.global_position,game.size).encloses(view.get_global_rect()),"caption stays inside safe content")
 for rect in view.occupied:check(not view.get_global_rect().intersects(rect),"caption is disjoint from existing critical HUD camera badge and active controls")
 check(view.mouse_filter==Control.MOUSE_FILTER_IGNORE and s.snapshot()==baseline,"caption layout preserves touch and simulation")
 for safe in [false,true]:
  Settings.current.safe_palette=safe;game._refresh();await settle();game.ocean.queue_redraw();game.lock_warning.queue_redraw()
  await capture("a11y-%d-%s"%[shape.x,"safe" if safe else "standard"])
 # Existing mandatory film reserve becomes explicit even if optional captions go off.
 s.mission.photo_pricing={"film":[0,4,4]};game.ocean.queue_redraw();await settle()
 await capture("a11y-%d-film-empty"%shape.x)
 # Source-known no-chart-space fixture: the already existing hints occupy the
 # available chart. Captions move into the existing status text, retaining it.
 var hints=game.mission_hud.hints.panel;var old_rect=hints.get_rect();var old_visible=hints.visible
 hints.position=Vector2.ZERO;hints.size=game.size;hints.show()
 var status_before=game.mission_hud.intent.text
 view.refresh(game)
 check(view.get_meta("status_fallback",false) and status_before in game.mission_hud.intent.text and "HEARD" in game.mission_hud.intent.text,"no free chart space retains caption and every existing status word")
 check(Rect2(Vector2.ZERO,game.size).encloses(game.mission_hud.intent.get_rect()),"crowded fallback remains in safe content at150percent")
 hints.position=old_rect.position;hints.size=old_rect.size;hints.visible=old_visible
 game._refresh();await settle()
 check(not view.get_meta("status_fallback",false) and not "HEARD: sweeper warning" in game.mission_hud.intent.text,"free-space return removes only the caption suffix cleanly")
 Settings.current.audio_captions=false;game._refresh();await settle()
 check(not view.visible and game.lock_warning.visible,"captions off retains mandatory lock warning")
 # Both existing settings surfaces use the same optional settings and seam.
 game._settings_menu();await settle();await press(game,"setting_audio_captions")
 check(store.load_settings().audio_captions,"operation settings persists through the same SettingsStore")
 await android_back();check(game.screen=="menu","Android Back leaves operation settings")
 game.queue_free();await settle();Settings.apply(Store.DEFAULTS)
 for suffix in ["",".tmp"]:DirAccess.remove_absolute(path+suffix)
func run():
 for arg in OS.get_cmdline_user_args():
  if arg.begins_with("--capture-dir="):capture_dir=arg.trim_prefix("--capture-dir=")
 for shape in [Vector2i(2520,1080),Vector2i(2184,1968)]:await shape_case(shape)
 print("A11Y CUES UI CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
