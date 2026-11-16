extends "res://tests/challenges_ui_tests.gd"
const Soundscape=preload("res://src/audio/soundscape.gd")
# Real touch enters each overlay; Android Back is primary, Escape also returns.
func shape_case(shape):
 root.size=shape;await settle()
 var path="user://fix2-front-%d.save"%shape.x
 var game=load("res://scenes/main.tscn").instantiate();game.set_script(load("res://tests/density_main.gd"))
 game.capture_scenario="runtime-test";game.store.path=path
 root.add_child(game);await settle();game.set_process(false)
 game.completed=[0];game.unlocked=1;game._show_campaign();game.capture_scenario="";game._save_archive()
 var front=Front.new();front.settings_store.path=path+".settings";game.add_child(front);front.setup(game);await settle()
 check(button(front,"frontend_new_campaign")==null,"erase progress is absent from title")
 var bd=front.title_backdrop
 check(bd!=null and bd.is_inside_tree() and bd.visible,"C4 title backdrop exists on the title "+str(shape))
 if bd!=null:
  check(bd.get_global_rect().encloses(root.get_visible_rect()),"C4 backdrop fills the viewport "+str(shape))
  check(bd.get_index()<front.scroll.get_index() and bd.mouse_filter==Control.MOUSE_FILTER_IGNORE,"C4 backdrop sits behind the menu and ignores touches")
  check(bd.is_processing(),"C4 backdrop animates while the title shows")
  check(bd.static_layer.size.is_equal_approx(bd.size) and bd.craft_layer.size.is_equal_approx(bd.size),"C4 backdrop layers match its size")
  check(bd.craft_position(0.).x<bd.size.x and bd.craft_position(0.)==bd.craft_position(0.),"C4 craft starts at a fixed place")
  var wordmark_ok=front.title_label!=null and bd.get_global_rect().encloses(front.title_label.get_global_rect())
  check(wordmark_ok,"C4 wordmark lies inside the backdrop plate area")
  front._settings_screen();await settle()
  check(bd.visible and bd.get_global_rect().encloses(root.get_visible_rect()) and not bd.is_processing(),"C4 backdrop stays behind the other screens and stops its drift when the title is not shown")
  front._title_screen();await settle()
  check(bd.visible and bd.is_processing(),"C4 backdrop resumes when the title returns")
  bd.set_frozen(true)
  check(not bd.is_processing(),"C4 frozen backdrop does not process")
  bd.set_frozen(false)
  for id in ["frontend_continue","frontend_modes","frontend_settings","frontend_challenges","frontend_credits"]:check(button(front,id)!=null,"C4 title keeps button "+id)
 for navigation in ["android","keyboard"]:
  await press(front,"frontend_settings")
  var back=button(front,"frontend_back")
  check(back!=null and root.get_visible_rect().encloses(back.get_global_rect()),"settings Back is above fold "+str(shape))
  check(button(front,"frontend_new_campaign")!=null,"settings retains confirmed campaign reset")
  if navigation=="android":await android_back()
  else:await escape_key()
  check(front.screen=="title" and game.screen=="menu","settings Back returns overlay to title")
  front._title_screen();await settle()
  await press(front,"frontend_challenges")
  back=button(front,"frontend_back")
  check(back!=null and root.get_visible_rect().encloses(back.get_global_rect()),"challenge list Back is above fold")
  await press(front,"challenge_shelf_passive")
  back=button(front,"challenge_back")
  check(back!=null and root.get_visible_rect().encloses(back.get_global_rect()),"challenge detail Back is above fold")
  if navigation=="android":await android_back()
  else:await escape_key()
  check(front.screen=="challenges","detail Back returns to challenge list")
  if navigation=="android":await android_back()
  else:await escape_key()
  check(front.screen=="title","list Back returns to title")
  front._title_screen();await settle()
 game.queue_free();await settle()
 for file in [path,path+".settings"]:
  for suffix in ["",".bak",".tmp"]:DirAccess.remove_absolute(file+suffix)
# WP-39: Android Back lands where the screen's own on-screen back button lands.
func back_parity():
 root.size=Vector2i(2184,1968);await settle()
 var path="user://fix2-parity.save"
 var game=load("res://scenes/main.tscn").instantiate();game.set_script(load("res://tests/density_main.gd"))
 game.capture_scenario="runtime-test";game.store.path=path
 root.add_child(game);await settle();game.set_process(false)
 game.completed=[0];game.unlocked=1;game._show_campaign();game.capture_scenario="";game._save_archive()
 var front=Front.new();front.settings_store.path=path+".settings";game.add_child(front);front.setup(game);await settle()
 var Modes=load("res://src/presentation/runs/modes_frontend.gd")
 var cases={
  "modes":func():Modes.show(front),
  "career":func():load("res://src/presentation/career/career_frontend.gd").show(front),
  "expeditions":func():Modes.expeditions(front),
  "run_seed":func():Modes.seed_screen(front,7),
  "challenges":func():load("res://src/presentation/frontend/challenges_frontend.gd").show(front),
  "challenge_details":func():load("res://src/presentation/frontend/challenges_frontend.gd").details(front,"shelf_passive"),
  "credits":func():front._credits_screen(),
  "settings":func():front._settings_screen(),
 }
 for name in cases:
  front._title_screen();await settle();cases[name].call();await settle()
  check(front.screen==name,"parity setup reaches "+name)
  var visible_back=button(front,"challenge_back") if name=="challenge_details" else button(front,"frontend_back")
  check(visible_back!=null,"parity "+name+" has a visible back button")
  if visible_back==null:continue
  await tap(visible_back.get_global_rect().get_center())
  var by_button=front.screen
  front._title_screen();await settle();cases[name].call();await settle()
  await android_back()
  check(front.screen==by_button,"Android Back matches the on-screen back button on "+name+": "+front.screen+" vs "+by_button)
 front._title_screen();await settle()
 if front.profile_picker.available():
  front.profile_picker.show_picker();await settle()
  await tap(button(front,"profiles_back").get_global_rect().get_center());var by_profiles=front.screen
  front.profile_picker.show_picker();await settle();await android_back()
  check(front.screen==by_profiles and by_profiles=="title","Android Back matches the profiles back button")
 # Credits show credits, not engineering notes.
 front._credits_screen();await settle()
 var text=""
 for child in front.column.get_children():
  if child is Label:text+=child.text+"\n"
 for banned in [".wav","SHA256",".gd",".json"]:check(not text.contains(banned),"credits screen hides "+banned)
 var raw=str(Soundscape.ATTRIBUTION.get_meta("attribution"))
 var names=0
 for line in raw.split("\n"):
  var t=line.strip_edges()
  if t.begins_with("**"):
   names+=1;var credited=t.replace("**","")
   check(text.contains(credited.substr(0,credited.find(".")) if credited.find(".")>0 else credited),"credits keep the author line: "+credited.left(40))
  elif t.begins_with("Source:"):check(text.contains(t),"credits keep "+t)
 check(names>=2,"the attribution resource names its authors")
 check(text.contains("Full audio source and licence record: in the game files."),"credits point to the full record")
 game.queue_free();await settle()
 for file in [path,path+".settings"]:
  for suffix in ["",".bak",".tmp"]:DirAccess.remove_absolute(file+suffix)
func run():
 for shape in [Vector2i(2520,1080),Vector2i(2184,1968),Vector2i(960,432)]:await shape_case(shape)
 await back_parity()
 print("FIX2 FRONTEND UI CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
