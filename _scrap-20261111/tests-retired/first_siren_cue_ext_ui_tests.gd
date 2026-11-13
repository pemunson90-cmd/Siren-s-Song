extends "res://tests/fix2_menu_ui_tests.gd"
# Handoff 049 UI: op 1 chip plus one-time kind note at both Fold7 shapes by real touch.
func shape_case(shape):
 root.size=shape;await settle()
 var game=load("res://scenes/main.tscn").instantiate();game.set_script(load("res://tests/density_main.gd"));game.capture_scenario="runtime-test"
 root.add_child(game);await settle();game.set_process(false);game._start_mission(0);await settle()
 var cue=game.hud.get_node_or_null("FirstSirenCue")
 check(cue!=null,"cue registered on op 1 at "+str(shape))
 if cue==null:game.queue_free();await settle();return
 game.hints_seen=["move","pause","drone","noise","sweep","warning"];game.mission_hud.hints.dismiss()
 var s=game.sim;s.paused=false
 s.mission.rocks=[];s.mission.structures=[];s._build_navigation();s._configure_terrain();s._configure_depth_charts()
 var enemy=s.sirens[0];enemy.pos=s.units[0].pos+Vector2(120,0);enemy.home=enemy.pos;enemy.goal=enemy.pos;enemy.route=[];enemy.patrol_points=[];enemy.stun=0.;enemy.band=s.units[0].band;enemy.transition={};s.sirens=[enemy]
 for id in [1,2]:s.units[id].alive=false
 s._threats(.1);game._refresh();await settle()
 check(cue.is_visible_in_tree() and cue.frames.size()==1,"op 1 shows the bearing chip")
 check(cue.note_frames.size()==1 and cue.note_text()=="NEW SIREN TYPE: PATROLLER","op 1 shows the one-time kind note")
 var chip=cue.chip_rect;var note=cue.note_rect;var h=game.ui_touch_height
 check(not chip.intersects(note),"chip and note do not overlap each other")
 check(Rect2(Vector2.ZERO,game.size).encloses(chip) and Rect2(Vector2.ZERO,game.size).encloses(note),"chip and note fit the Fold7 content bounds")
 check(cue.marker_rect==chip and note.size.y>0.,"marker rect stays the chip and the note has its own rect for captions")
 game.lock_warning.show_hint=true;game.lock_warning.refresh(game)
 check(not game.lock_warning.banner.intersects(cue.marker_rect),"chip and note clear the 4 s lock banner including its hint")
 var font=ThemeDB.fallback_font
 check(font.get_string_size(cue.note_text(),HORIZONTAL_ALIGNMENT_LEFT,-1,cue.font_size).x<note.size.x-note.size.y*.4-8,"note text fits its box")
 check(cue.font_size>=18 and note.size.y>=h*.8,"note remains readable at Android density")
 check(cue.mouse_filter==Control.MOUSE_FILTER_IGNORE,"passive note never intercepts map touch")
 var capture_dir=OS.get_environment("CUE_CAPTURE_DIR")
 if not capture_dir.is_empty():
  await RenderingServer.frame_post_draw
  root.get_texture().get_image().save_png(capture_dir+"/cue-ext-%d.png"%shape.x)
 var pause=game.pause_button;check(pause.get_global_rect().size.y>=h*.95,"pause target stays touch sized")
 await tap(pause.get_global_rect().get_center());check(s.paused,"real touch pause works with chip and note shown")
 await tap(pause.get_global_rect().get_center());check(not s.paused,"real touch resume works")
 await android_back();check(game.screen!="mission" or s.paused,"Android Back keeps its existing safe behavior")
 game.screen="mission";game.hud.show();s.paused=false
 s.siren_notice.emit(0,s.units[0].pos+Vector2.RIGHT*100);cue.refresh()
 check(cue.note_frames.size()==1 and cue.audio_events.size()==1,"repeat notice neither re-notes nor replays the sound")
 s.elapsed+=cue.Table.NOTE_DURATION+.1;cue.refresh()
 check(not cue.visible,"chip and note hide after expiry")
 game.completed=[0];game.unlocked=1
 var archive=game._archive();check(archive.get("first_siren_types",[])==["patroller"],"seen types are archived")
 var save_path="user://cue-ext-%d.save"%shape.x
 game.store.path=save_path;check(game.store.save(archive),"archive with seen types saves")
 var restored=load("res://scenes/main.tscn").instantiate();restored.set_script(load("res://tests/density_main.gd"));restored.capture_scenario="runtime-test";restored.store.path=save_path
 root.add_child(restored);await settle();restored.set_process(false);restored._load_archive();restored._enter_water();restored.sim.paused=false
 var loaded=restored.hud.get_node("FirstSirenCue")
 check(loaded.tracker.saved_types()==["patroller"],"seen types survive save and reload")
 restored.sim.siren_notice.emit(0,restored.sim.units[0].pos+Vector2.RIGHT*100);loaded.refresh()
 check(loaded.note_frames.is_empty(),"reload never repeats a seen type note")
 restored.queue_free();await settle()
 var old=archive.duplicate(true);old.erase("first_siren_types");game.store.path=save_path
 check(game.store.save(old),"an older archive without the field saves")
 var legacy=load("res://scenes/main.tscn").instantiate();legacy.set_script(load("res://tests/density_main.gd"));legacy.capture_scenario="runtime-test";legacy.store.path=save_path
 root.add_child(legacy);await settle();legacy.set_process(false);legacy._load_archive()
 check(legacy.hud.get_node("FirstSirenCue").tracker.saved_types().is_empty() and legacy.completed==[0],"older archive loads with no seen types")
 legacy.queue_free();await settle()
 for suffix in ["",".bak",".tmp"]:DirAccess.remove_absolute(save_path+suffix)
 var invalid=archive.duplicate(true);invalid["first_siren_types"]=["a","a"]
 check(not game.store.valid(invalid),"malformed saved types are rejected by the store")
 game.store.path=save_path;game.early_reward={};game._new_campaign();await settle()
 var after_new=game.hud.get_node_or_null("FirstSirenCue")
 check(after_new!=null and after_new.tracker.saved_types().is_empty(),"a new campaign forgets seen Siren kinds")
 var fresh_archive=game.store.load_game();check(not fresh_archive.has("first_siren_types"),"the fresh save carries no old seen kinds")
 for suffix in ["",".bak",".tmp"]:DirAccess.remove_absolute(save_path+suffix)
 game.queue_free();await settle()
func run():
 for shape in [Vector2i(2520,1080),Vector2i(2184,1968)]:await shape_case(shape)
 print("FIRST SIREN CUE EXT UI CHECKS %d FAILURES %d"%[checks,failures]);quit(1 if failures else 0)
