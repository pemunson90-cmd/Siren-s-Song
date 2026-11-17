extends "res://tests/fix2_menu_ui_tests.gd"
func shape_case(shape):
 root.size=shape;await settle()
 var game=load("res://scenes/main.tscn").instantiate();game.set_script(load("res://tests/density_main.gd"));game.capture_scenario="runtime-test"
 root.add_child(game);await settle();game.set_process(false);game._start_mission(1);await settle()
 var cue=game.hud.get_node_or_null("FirstSirenCue")
 check(cue!=null,"cue registered in the actual game at "+str(shape))
 if cue==null:game.queue_free();await settle();return
 game.hints_seen=["move","pause","drone","noise","sweep","warning"];game.mission_hud.hints.dismiss()
 var s=game.sim;s.paused=false
 s.mission.rocks=[];s.mission.structures=[];s._build_navigation();s._configure_terrain();s._configure_depth_charts()
 var enemy=s.sirens[0];enemy.pos=s.units[0].pos+Vector2(120,0);enemy.home=enemy.pos;enemy.goal=enemy.pos;enemy.route=[];enemy.patrol_points=[];enemy.stun=0.;enemy.band=s.units[0].band;enemy.transition={};s.sirens=[enemy]
 for id in [1,2]:s.units[id].alive=false
 s._threats(.1)
 check(cue.voice.playing,"warning sound starts before suspension")
 check(cue.voice.bus==game.sound.ALERTS_BUS,"first notice routes its recording through Alerts")
 var alert_index=AudioServer.get_bus_index(cue.voice.bus)
 check(AudioServer.get_bus_send(alert_index)=="Master","first notice gain is independent of Effects")
 check(is_equal_approx(cue.voice.volume_db,cue.Table.AUDIO.gain_db) and is_equal_approx(db_to_linear(AudioServer.get_bus_volume_db(alert_index)),.8),"first notice keeps its authored gain and legacy default category gain")
 game.sound.effects_volume=0.;game.sound.apply_bus_levels();cue.refresh()
 check(cue.voice.playing,"Effects zero retains an active first notice")
 game.sound.alerts_volume=0.;game.sound.apply_bus_levels();cue.refresh()
 check(not cue.voice.playing,"Alerts zero stops an active first notice")
 var audio_count=cue.audio_events.size();var notice={"id":0,"time":s.elapsed}
 cue._notice(notice)
 check(not cue.voice.playing and cue.audio_events.size()==audio_count,"Alerts zero blocks a fresh first-notice playback")
 game.sound.alerts_volume=.8;game.sound.apply_bus_levels();cue._notice(notice)
 check(cue.voice.playing and cue.audio_events.size()==audio_count+1,"Alerts restored permits a fresh notice with Effects still zero")
 # The extra playback above exercises only the audio boundary; retain the acquisition log.
 cue.audio_events.resize(audio_count);game.sound.effects_volume=.8;game.sound.apply_bus_levels()
 cue._notification(Node.NOTIFICATION_APPLICATION_PAUSED);cue.refresh()
 check(cue.voice.stream_paused,"application suspension freezes a playing cue immediately")
 cue._notification(Node.NOTIFICATION_APPLICATION_RESUMED)
 game._refresh();await settle()
 check(cue.is_visible_in_tree() and cue.frames.size()==1,"existing acquisition shows a visible bearing mark")
 check(cue.audio_events.size()==1 and cue.audio_events[0].cue==cue.Table.AUDIO.id,"distinct soft warning audio event logged")
 check(cue.mouse_filter==Control.MOUSE_FILTER_IGNORE,"passive cue never intercepts map touch")
 check(Rect2(Vector2.ZERO,game.size).encloses(cue.marker_rect),"mark fits the actual Fold7 content bounds")
 check(cue.font_size>=18 and cue.marker_rect.size.y>=game.ui_touch_height*.8,"mark remains readable at Android density")
 check(ThemeDB.fallback_font.get_string_size(cue.label_text(),HORIZONTAL_ALIGNMENT_LEFT,-1,cue.font_size).x<cue.marker_rect.size.x-cue.marker_rect.size.y,"bearing text fits the mark")
 s.selected=1;cue.refresh();check("FROM Q" in cue.label_text(),"switching selected craft cannot mislabel the captured bearing");s.selected=0
 var capture_dir=OS.get_environment("CUE_CAPTURE_DIR")
 if not capture_dir.is_empty():
  await RenderingServer.frame_post_draw
  root.get_texture().get_image().save_png(capture_dir+"/cue-%d.png"%shape.x)
 s.sirens.append(enemy.duplicate(true));s.sirens[1].pos+=Vector2(20,0)
 # Stretch only this test sample so frame waits cannot finish it before pause.
 # Production pitch/cutoff stay in the table; keep the real touch helper intact.
 cue.voice.pitch_scale=.01
 s.siren_notice.emit(1,s.units[0].pos+Vector2.RIGHT*140)
 check(cue.voice.playing,"fresh warning is playing before real-touch pause")
 var pause=game.pause_button;await tap(pause.get_global_rect().get_center())
 check(s.paused,"real touch pause remains available with the mark")
 cue.refresh();check(cue.voice.stream_paused,"warning sound freezes while paused")
 await settle();check(cue.voice.stream_paused,"paused warning remains suspended across rendered waits")
 cue.voice.pitch_scale=cue.Table.AUDIO.pitch
 await android_back();check(game.screen!="mission" or s.paused,"Android Back keeps its existing safe behavior")
 game.screen="mission";game.hud.show();s.paused=false
 s.sirens.append(enemy.duplicate(true));s.sirens[2].pos+=Vector2(40,0)
 s.siren_notice.emit(2,s.units[0].pos+Vector2.RIGHT*160)
 check(cue.voice.playing,"a different Siren has its own once-only sound")
 game.sound.suspend()
 check(cue.voice.stream_paused,"direct campaign sound suspension freezes the cue without refresh")
 game.sound.resume();cue.refresh()
 game.settings.mute=true;game.sound.muted=true;cue.refresh()
 check(not cue.voice.playing,"mute silences an active cue")
 game.sound.muted=false;game.settings.mute=false
 s.elapsed+=cue.Table.DURATION+.1;cue.refresh()
 check(not cue.visible,"expired cue hides without changing simulation time")
 game.completed=[0];game.unlocked=1
 var archive=game._archive();check(archive.has("first_siren_seen"),"presentation deduplication is archived separately from simulation")
 var save_path="user://first-siren-cue-%d.save"%shape.x
 game.store.path=save_path
 check(game.store.save(archive),"current cue archive saves with validation")
 var restored=load("res://scenes/main.tscn").instantiate();restored.set_script(load("res://tests/density_main.gd"));restored.capture_scenario="runtime-test";restored.store.path=save_path
 root.add_child(restored);await settle();restored.set_process(false);restored._load_archive();restored._enter_water();restored.sim.paused=false
 var loaded=restored.hud.get_node("FirstSirenCue");restored.sim._threats(.1);loaded.refresh()
 check(loaded.audio_events.is_empty() and loaded.frames.is_empty(),"reload of the same dive never replays consumed first notices")
 restored.queue_free();await settle()
 for suffix in ["",".bak",".tmp"]:DirAccess.remove_absolute(save_path+suffix)
 var invalid=archive.duplicate(true);invalid["first_siren_seen"]=[-1]
 check(not game.store.valid(invalid),"invalid optional presentation history is rejected")
 invalid["first_siren_seen"]=[0,0];check(not game.store.valid(invalid),"duplicate saved Siren IDs are rejected")
 invalid.erase("first_siren_seen");check(game.store.valid(invalid),"older archives without cue history still load")
 game._start_mission(4);s=game.sim;s.siren_notice.emit(0,s.units[0].pos+Vector2.RIGHT*100);cue.refresh()
 check(not cue.visible,"later operations never display the cue")
 game.queue_free();await settle()
func run():
 for shape in [Vector2i(2520,1080),Vector2i(2184,1968)]:await shape_case(shape)
 print("FIRST SIREN CUE UI CHECKS %d FAILURES %d"%[checks,failures]);quit(1 if failures else 0)
