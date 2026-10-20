extends RefCounted
# Disposable real-Main persistence fixtures. Callback dispatch is a technical
# check, not a campaign journey or real-player input claim.
const Store=preload("res://src/persistence/save_store.gd")
static func _settle(t):
	for frame in 3:await t.process_frame
static func _game(t,path:String):
	var game=load("res://scenes/main.tscn").instantiate();game.store.path=path
	t.root.add_child(game);game.set_process(false);await _settle(t);return game
static func _action(game,id:String):
	for button in game.menu.find_children("*","Button",true,false):
		if button.get_meta("action","")==id:return button
	return null
static func _visible(game,fragment:String)->bool:
	return game.menu.find_children("*","Label",true,false).any(func(label):return label.is_visible_in_tree() and fragment in label.text)
static func _click(t,button):
	button.pressed.emit();await _settle(t)
static func _remove(path:String):
	for suffix in ["",".bak",".tmp"]:DirAccess.remove_absolute(path+suffix)
static func run(t):
	var prefix="user://save-feedback-%d-%d"%[OS.get_process_id(),Time.get_ticks_usec()]
	var missing=prefix+"/archive.save";var path=prefix+".save"
	var game=await _game(t,missing)
	game._start_mission(0);game.completed=[0];game.unlocked=1
	game.sim.command("route",{"point":Vector2(360,800)});game.sim.paused=false
	for frame in 30:game.sim.advance(1./60.)
	game.sim.paused=true
	var state=game.sim.snapshot();game._save_archive()
	t.check(not game.store.warning.is_empty(),"isolated missing-directory fixture reaches actual archive write failure")
	t.check(game.sim.snapshot()==state,"failed write preserves current craft resources time route and campaign simulation")
	game.sim.message="An ordinary new world message"
	for transition in [game._show_campaign,game._settings_menu,func():game._briefing(1),game._show_campaign]:
		transition.call();await _settle(t)
		t.check(_visible(game,"PROGRESS NOT SAVED") and _visible(game,game.store.warning),"save failure remains visible after menu transition "+game.screen)
	var retry=_action(game,"retry_save")
	t.check(retry!=null and retry.is_visible_in_tree(),"unsaved current progress exposes an ordinary explicit retry")
	if retry!=null:
		await _click(t,retry)
		t.check(_visible(game,"PROGRESS NOT SAVED"),"a second actual failed retry cannot clear unsaved status")
		game.store.path=path;state=game.sim.snapshot();var archive=game._archive()
		await _click(t,retry)
		t.check(game.sim.snapshot()==state and game.completed==[0] and game.unlocked==1,"successful retry preserves active simulation and campaign progress")
		t.check(game.store.load_game()==archive,"successful explicit retry writes and verifies the current binary archive")
		t.check(not _visible(game,"PROGRESS NOT SAVED") and not retry.is_visible_in_tree(),"only verified successful save clears the failed-save status")
	else:
		# Still seed a normal current archive so the separate startup cases run RED.
		game.store.path=path;game.store.save(game._archive())
	var saved=game.store.load_game();game.queue_free();await _settle(t)
	var store=Store.new();store.path=path
	t.check(store.save(saved),"startup recovery fixture creates a normal verified backup")
	var file=FileAccess.open(path,FileAccess.WRITE);file.store_string("unreadable-primary");file.close()
	game=await _game(t,path)
	t.check(game.active_started and game.sim.snapshot()==saved.active and game.completed==saved.completed,"startup backup recovery retains actual current campaign and active dive")
	var recovered_notice=game.store.warning
	t.check(_visible(game,recovered_notice),"startup recovered-backup warning is visible in operations")
	game.sim.message="A later independent mission message";game._settings_menu();await _settle(t)
	t.check(_visible(game,recovered_notice),"recovered-backup warning survives settings and transient world messages")
	game._save_archive();game._show_campaign();await _settle(t)
	t.check(_visible(game,recovered_notice),"successful later save does not silently dismiss archive recovery history")
	# Acknowledging recovery is independent of an outstanding failed write.
	game.store.path=missing;game._save_archive();var acknowledge=_action(game,"ack_archive_warning")
	t.check(acknowledge!=null,"archive notice has a deliberate dismissal separate from save success")
	if acknowledge!=null:
		await _click(t,acknowledge)
		t.check(not _visible(game,recovered_notice) and _visible(game,"PROGRESS NOT SAVED"),"dismissing archive notice cannot clear current unsaved progress")
	game.queue_free();await _settle(t);_remove(path)
	file=FileAccess.open(path,FileAccess.WRITE);file.store_string("unreadable-primary");file.close()
	game=await _game(t,path);var unreadable_notice=game.store.warning
	t.check(not unreadable_notice.is_empty() and _visible(game,unreadable_notice),"startup unreadable-archive warning is visible before any new operation")
	game.sim.message="A new operation message";game._settings_menu();await _settle(t)
	t.check(_visible(game,unreadable_notice),"unreadable-archive warning persists across ordinary menu transitions")
	acknowledge=_action(game,"ack_archive_warning")
	if acknowledge!=null:await _click(t,acknowledge)
	t.check(FileAccess.get_file_as_string(path)=="unreadable-primary","reading or dismissing startup warning never overwrites retained original archive")
	game.queue_free();await _settle(t);_remove(path)
