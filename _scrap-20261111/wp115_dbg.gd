extends "res://tests/status_text_ui_tests.gd"
func run():
	var game=await make_game(6,Vector2i(960,432))
	var hud=game.mission_hud
	var b=hud.find_child("HuntMeterButton",true,false)
	print("DBG chip ",b," vis ",b.visible if b else "-"," pos ",b.position if b else "-"," size ",b.size if b else "-")
	print("DBG hud size ",hud.size," tip ",hud.hints.panel.visible,hud.hints.panel.get_rect()," cur ",hud.hints.current)
	var Meter=preload("res://src/presentation/hunt_meter.gd")
	if b:
		for o in Meter._obstacles(hud,b):print("DBG obstacle ",o)
	print("DBG intent ",hud.intent.get_rect()," text ",hud.intent.text.replace("\n"," / "))
	print("DBG msg [",game.sim.message,"] cur [",hud.current_message,"] standing [",hud.strip_standing,"] scale ",Settings.text_scale()," chartw ",game.ocean.chart_width())
	quit(0)
