extends SceneTree
# WP-128: the status strip carries one NEXT line from launch through "ready to recover" on operations 01 to 06, the recovery
# wording is plain, and the GOAL chip points at what NEXT names.
const NextStep=preload("res://src/presentation/next_step.gd")
const Settings=preload("res://src/presentation/frontend/frontend_settings.gd")
var checks=0
var failures=0
func check(ok,label):
	checks+=1
	if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():call_deferred("run")
func settle():
	for n in 6:await process_frame
func make(shape:Vector2i,scale:float,index:int):
	root.size=shape;await settle()
	Settings.current["text_scale"]=scale
	var game=load("res://scenes/main.tscn").instantiate();game.set_script(load("res://tests/density_main.gd"))
	game.store.path="user://wp128-next-%d-%d.save"%[index,Time.get_ticks_usec()]
	if shape.x==2520:game.fixture_safe_area=Rect2(136,0,2384,1080)
	root.add_child(game);await settle();game.set_process(false)
	game._start_mission(index);await settle();game._layout();await settle()
	game.sim.sirens=[]
	if game.mission_hud.hints.panel.visible:game.mission_hud.hints.dismiss()
	return game
func shown(game)->String:
	game.sim.message="";game._refresh();await settle()
	return game.mission_hud.intent.text
func run():
	await process_frame
	var saved=Settings.current.duplicate()
	for shape in [Vector2i(2520,1080),Vector2i(2184,1968)]:
		for scale in [1.0,1.5]:
			for index in 6:
				var game=await make(shape,scale,index)
				var sim=game.sim
				var label="%dx%d x%.1f op%02d"%[shape.x,shape.y,scale,index+1]
				var text:String=await shown(game)
				print("NEXT ",label," launch [",text.replace("\n"," // "),"]")
				check(text.count("NEXT:")==1,label+" launch shows one NEXT line: "+text)
				check(text.count("\n")<=1,label+" launch holds two lines: "+text)
				check(NextStep.step(sim).text.begins_with("NEXT:") and not NextStep.step(sim).site.is_empty(),label+" launch NEXT names a chart point")
				# Every required record taken: the next step is the way home.
				for o in sim.mission.objectives:
					if not o.get("optional",false):o.captured=true
				if sim.mission.has("blackwater_delivery"):sim.mission.blackwater_delivery.aboard=[0,1]  # op03 also needs both packets aboard
				var far:Vector2=sim.mission.extraction+Vector2(240,0)
				sim.units[0].pos=far;sim.units[0].vel=Vector2.ZERO
				text=await shown(game)
				print("NEXT ",label," home [",text.replace("\n"," // "),"]")
				check(sim.all_records() and text.contains("NEXT: bring Quietus into the"),label+" records done: NEXT says to bring Quietus into the ring: "+text)
				check(not text.contains("retained kit") and not text.contains("settled in MIDDLE;"),label+" the opaque recovery wording is gone: "+text)
				var goal:Dictionary=NextStep.step(sim).site
				check(goal.get("pos",Vector2.ZERO)==sim.mission.extraction,label+" the goal chip names the extraction")
				sim.units[0].pos=sim.mission.extraction+Vector2(20,0);sim.units[0].band=2
				text=await shown(game)
				check(text.contains("NEXT: rise to"),label+" in the ring but too deep: "+text)
				sim.units[0].band=1;sim.units[0].vel=Vector2(30,0)
				text=await shown(game)
				check(text.contains("NEXT: slow Quietus"),label+" in the ring but too fast: "+text)
				game.queue_free();await settle()
	Settings.current=saved
	print("NEXT STEP CHECKS ",checks," FAILURES ",failures)
	quit(1 if failures>0 else 0)
