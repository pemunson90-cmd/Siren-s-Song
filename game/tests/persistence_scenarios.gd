extends RefCounted
const SaveStore=preload("res://src/persistence/save_store.gd")
const Simulation=preload("res://src/simulation/simulation.gd")
static func run(t) -> void:
	var store=SaveStore.new(); store.path="user://test-quietus.save"
	for suffix in ["",".bak",".tmp"]: DirAccess.remove_absolute(store.path+suffix)
	var s=Simulation.new(); s.start(2); s.command("select",{"unit":1}); s.command("route",{"point":Vector2(780,780)})
	var data={"version":1,"unlocked":2,"completed":[0,1],"upgrade":"survey","settings":{"music":0.5,"effects":0.8},"active":s.snapshot(),"evidence":{"furnace":{"name":"FURNACE VENT","caption":"Recovered hollow castings.","optical":"furnace"}}}
	t.check(store.save(data),"versioned save writes atomically")
	var loaded=store.load_game()
	t.check(loaded==data,"campaign, settings, vectors and drone orders round-trip")
	t.check(store.save(data),"second save preserves valid backup")
	var f=FileAccess.open(store.path,FileAccess.WRITE); f.store_string("corrupted"); f.close()
	t.check(store.load_game()==data and not store.warning.is_empty(),"corrupt primary recovers previous valid backup with warning")
	var malformed=data.duplicate(true); malformed.evidence.furnace.optical="../../unknown"
	t.check(not store.save(malformed),"malformed optical evidence cannot overwrite the campaign archive")
	var future=data.duplicate(true); future.version=999
	t.check(not store.save(future),"unsupported schema cannot overwrite campaign")
	for suffix in ["",".bak",".tmp"]: DirAccess.remove_absolute(store.path+suffix)
