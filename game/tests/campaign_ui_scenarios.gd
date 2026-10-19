extends RefCounted
const Routes=preload("res://tests/campaign_scenarios.gd")
static func run(t,game) -> void:
	game.completed=[]; game.unlocked=0; game.upgrade="disruption"
	for id in 6:
		game._briefing(id); await t.process_frame
		var begin
		for child in game.panel_box.get_children():
			if child is Button and child.get_meta("action","")=="begin": begin=child
		t.check(begin!=null,"campaign mission %d presents an ENTER WATER action"%(id+1))
		if begin==null: return
		await t.click(begin.get_global_rect().get_center())
		t.check(game.screen=="mission" and game.mission_index==id,"campaign mission %d begins through actual pointer input"%(id+1))
		var s=game.sim; s.units[1].alive=false; s.units[2].alive=false
		if id==4:
			preload("res://tests/listening_well_command_plan.gd").play(true,false,s)
		if id==5:
			preload("res://tests/finale_command_plan.gd").play(false,"complete",true,-1,s)
		for objective in ([] if id in [4,5] else s.mission.objectives):
			var vantage=objective.pos+Vector2(0,210)
			if s.blocked(vantage,25): vantage=objective.pos+Vector2(-210,0)
			if not Routes.move(s,vantage): break
			s.command("camera")
			for n in int((objective.get("duration",4.0)+0.5)*10): s.advance(0.1)
		Routes.move(s,s.mission.extraction)
		await t.process_frame; await t.process_frame
		t.check(game.screen=="debrief" and s.outcome=="won" and id in game.completed and game.unlocked==mini(5,id+1),"campaign mission %d completion unlocks the correct next dive"%(id+1))
	var ending=false
	for child in game.panel_box.get_children():
		if child is Label and "Campaign complete" in child.text: ending=true
	t.check(game.completed.size()==6 and ending,"six actual mission recoveries reach the campaign ending and preserve replay progress")
