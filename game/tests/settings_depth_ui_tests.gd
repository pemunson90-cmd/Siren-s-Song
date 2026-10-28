extends "res://tests/challenges_ui_tests.gd"
# SETDEPTH touch journey at 150 percent text on both recorded viewports: open each settings page, change one
# control on it, press Back, and confirm the values persisted and reopen selected. Real isolated SettingsStore.
const Settings=preload("res://src/presentation/frontend/frontend_settings.gd")
const Store=preload("res://src/persistence/settings_store.gd")
func target_ok(b,label):
 var dp=float(root.size.x)/root.get_visible_rect().size.x*160./420.
 check(b!=null and b.size.x*dp>=48 and b.size.y*dp>=48,"48dp target at 420dpi: "+label)
func open_settings(game,path):
 var front=Front.new();front.settings_store.path=path;game.add_child(front);front.setup(game);await settle()
 await press(front,"frontend_settings")
 return front
func shape_case(shape):
 root.size=shape;await settle()
 var path="user://settings-depth-%d.json"%shape.x
 for suffix in ["",".tmp"]:DirAccess.remove_absolute(path+suffix)
 var store=Store.new();store.path=path
 check(store.save_settings(Store.DEFAULTS),"scoped settings fixture starts at defaults")
 Settings.apply(Store.DEFAULTS)
 var game=load("res://scenes/main.tscn").instantiate();game.set_script(load("res://tests/density_main.gd"));game.capture_scenario="runtime-test";game.settings_path=path
 if shape.x==2520:game.fixture_safe_area=Rect2(136,0,2384,1080)
 root.add_child(game);await settle();game.set_process(false);game._show_campaign();await settle()
 var front=await open_settings(game,path)
 for page in ["audio","display","controls"]:check(button(front,"settings_page_"+page)!=null,"page tab present: "+page)
 # DISPLAY: text size first so every later page is exercised at 150 percent.
 await press(front,"settings_page_display");await press(front,"text_scale_150")
 for id in ["text_scale_150","frame_cap_30","setting_high_contrast","setting_audio_captions"]:target_ok(button(front,id),id)
 await press(front,"setting_safe_palette")
 # AUDIO: a toggle and distinct gains on every independent mixer control.
 await press(front,"settings_page_audio")
 for id in ["mute","setting_night_mode"]:target_ok(button(front,id),id)
 await press(front,"setting_night_mode")
 var levels={"master":0.65,"music":0.15,"effects":0.2,"alerts":0.3,"messages":0.45}
 var found=0
 for slider in front.find_children("*","HSlider",true,false):
  if slider.get_meta("ui_action","") in ["setting_alerts","setting_messages","setting_music","setting_effects","setting_master"]:
   found+=1;check(slider.size.y*float(root.size.x)/root.get_visible_rect().size.x*160./420.>=48,"slider 48dp: "+slider.get_meta("ui_action",""))
   var key=String(slider.get_meta("ui_action","")).trim_prefix("setting_")
   slider.value=levels[key]
 check(found==5,"all five mixer sliders are on the AUDIO page")
 # CONTROLS: strength, drag and hold presets.
 await press(front,"settings_page_controls")
 for id in ["setting_haptics","haptic_strength_1","haptic_strength_3","drag_preset_0","drag_preset_2","hold_preset_0","hold_preset_2"]:target_ok(button(front,id),id)
 await press(front,"haptic_strength_3");await press(front,"drag_preset_2");await press(front,"hold_preset_0")
 check(Settings.current.haptic_strength==3 and Settings.current.drag_preset==2 and Settings.current.hold_preset==0,"presets apply live")
 await create_timer(.4).timeout
 var saved=store.load_settings()
 check(saved.text_scale==1.5 and saved.safe_palette and saved.night_mode and is_equal_approx(saved.alerts,0.3),"display and audio changes persist")
 for key in levels:
  check(is_equal_approx(saved[key],levels[key]),"independent mixer choice persists: "+key)
 check(saved.haptic_strength==3 and saved.drag_preset==2 and saved.hold_preset==0,"controls changes persist")
 await android_back();check(front.screen=="title","Android Back returns from settings")
 front._dismiss();await settle()
 # Reopen: a fresh settings screen shows the stored choices selected on each page.
 Settings.apply(store.load_settings())
 front=await open_settings(game,path)
 await press(front,"settings_page_controls")
 check(button(front,"haptic_strength_3").button_pressed and button(front,"drag_preset_2").button_pressed and button(front,"hold_preset_0").button_pressed,"reopened CONTROLS page shows stored presets")
 await press(front,"settings_page_display");check(button(front,"text_scale_150").button_pressed,"reopened DISPLAY page shows 150 percent")
 await press(front,"settings_page_audio");check(button(front,"setting_night_mode").text.ends_with("ON"),"reopened AUDIO page shows night mode on")
 # RESET restores the canonical defaults, including the legacy-equivalent 0.8 cue gains.
 await press(front,"settings_reset");await create_timer(.4).timeout
 var reset=store.load_settings()
 for key in Store.DEFAULTS:
  check(reset[key]==Store.DEFAULTS[key],"RESET restores persisted default: "+key)
  check(Settings.current[key]==Store.DEFAULTS[key],"RESET applies live default: "+key)
 for key in levels:
  check(is_equal_approx(AudioServer.get_bus_volume_db(0),Settings.master_db(Store.DEFAULTS.master)) if key=="master" else is_equal_approx(game.sound.get(key+"_volume"),Store.DEFAULTS[key]),"RESET applies audio gain: "+key)
 for slider in front.find_children("*","HSlider",true,false):
  var key=String(slider.get_meta("ui_action","")).trim_prefix("setting_")
  if levels.has(key):check(is_equal_approx(slider.value,Store.DEFAULTS[key]),"RESET displays default mixer choice: "+key)
 await android_back()
 game.queue_free();await settle();Settings.apply(Store.DEFAULTS)
 for suffix in ["",".tmp"]:DirAccess.remove_absolute(path+suffix)
func run():
 for shape in [Vector2i(2520,1080),Vector2i(2184,1968)]:await shape_case(shape)
 print("SETTINGS DEPTH UI CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
