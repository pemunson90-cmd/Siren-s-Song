extends SceneTree
const Prefs=preload("res://src/presentation/frontend/frontend_settings.gd")
func _initialize():call_deferred("run")
func settle():
 for n in 6:await process_frame
func run():
 root.size=Vector2i(1280,720)
 var game=load("res://scenes/main.tscn").instantiate();game.capture_scenario="runtime-test";game.settings_path="user://mute-probe.json";root.add_child(game);await settle();game.set_process(false)
 Prefs.apply(Prefs.SettingsStore.DEFAULTS,game)
 game._settings_menu();await settle()
 var front=game.get_node("Frontend");front._set_value("master",.35);front._toggle_mute();await settle()
 print("MUTE_BEFORE_CLOSE master=",Prefs.current.master," restore=",front.unmuted_master)
 front._return();await settle();game._settings_menu();await settle();front=game.get_node("Frontend")
 print("MUTE_AFTER_REOPEN master=",Prefs.current.master," restore=",front.unmuted_master)
 front._toggle_mute();await settle();print("MUTE_AFTER_UNMUTE master=",Prefs.current.master)
 front._return();game.queue_free();await settle();quit()
