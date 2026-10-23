extends "res://tests/challenges_ui_tests.gd"
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
func run():
 for shape in [Vector2i(2520,1080),Vector2i(2184,1968),Vector2i(960,432)]:await shape_case(shape)
 print("FIX2 FRONTEND UI CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
