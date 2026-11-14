extends RefCounted
# One title-button seam into fixed replay mode; reuses the frontend's scroll and touch sizing.
# Revert: remove that entry and this file plus challenge_session.gd. Campaign menus stay intact.
const Archive=preload("res://src/campaign/challenges/challenge_archive.gd")
const Catalog=preload("res://src/campaign/challenges/challenge_catalog.gd")
const Records=preload("res://src/campaign/challenges/challenge_records.gd")
const Session=preload("res://src/presentation/frontend/challenge_session.gd")
const SaveErrorView=preload("res://src/presentation/frontend/save_error_view.gd")
const Missions=preload("res://src/campaign/missions.gd")
# Words for a locked card (critic 14 Nov: "recover operation 01" did not say it meant the Campaign).
const TEXT={"lock":"LOCKED · Recover %02d %s in the Campaign","note":"Recover %02d %s in the Campaign to unlock this challenge.","progress":"Campaign so far: %d operations recovered.","fresh":"Campaign so far: no operation recovered yet."}
static func operation_name(row:Dictionary)->String:
	var op:int=int(row.op)
	if op<Missions.TITLES.size():return str(Missions.TITLES[op])
	return str(row.title).split(" / ")[0].capitalize()
static func lock_line(row:Dictionary,key:String="lock")->String:
	return TEXT[key]%[int(row.op)+1,operation_name(row)]
static func lock_note(front,row:Dictionary)->String:
	var done:int=completed(front).size()
	return lock_line(row,"note")+"\n"+(TEXT.progress%done if done>0 else TEXT.fresh)
static func completed(front)->Array:
	return front.host._campaign_completed() if front.host.has_method("_campaign_completed") else []
static func history(front)->Dictionary:
	var value=front.host.get("challenge_records")
	return value if value is Dictionary else {}
static func show(front)->void:
	Archive.restore(front.host)
	front._reset("challenges")
	front._button("BACK",front._return,"frontend_back")
	front._text("CHALLENGES",32,Color("80d9cf"))
	front._text("Replay recovered operations with a fixed fleet and one rule. Campaign progress stays as it was.",16)
	var saved=history(front);var recovered=completed(front)
	var error=front.host.get_meta("challenge_save_error","")
	if error is String and not error.is_empty():
		SaveErrorView.front_retry(front,"PROGRESS NOT SAVED\n"+error+"\nResults are held in this session.",16,"RETRY SAVE",func():Archive.persist(front.host);show(front),"challenge_retry_save")
	# Wide: each challenge is a card in a grid of two columns. Narrow: the stacked list as ever.
	var grid=front._grid(func():show(front))
	for row in Catalog.all():
		var id:String=row.id;var available=Catalog.unlocked(row,recovered)
		var best=saved.get(id,{}).get("best",{})
		var detail=Records.summary(best) if available else Catalog.description(row)+"\n"+lock_line(row)
		var add=func():
			var note:Array=[null]  # a lambda copies plain variables, so the label is held in an array it can read later
			# A locked card stays tappable: a tap shows what unlocks it, and where the Campaign stands, under the card.
			var tap=func():
				if available:details(front,id);return
				if is_instance_valid(note[0]):note[0].text=lock_note(front,row);note[0].show()
			var b=front._button(row.title+"\n"+detail,tap,"challenge_"+id)
			b.set_meta("challenge_id",id);b.set_meta("locked",not available)
			if not available:
				b.modulate=Color(1,1,1,.62)
				var label=front._text("",15,Color("e9cb8c"));label.hide();label.name="LockNote_"+id;note[0]=label
		if grid!=null:front._into(front._card(grid),add)
		else:add.call()
static func details(front,id:String)->void:
	var row=Catalog.get_challenge(id)
	if row.is_empty() or not Catalog.unlocked(row,completed(front)):return
	front._reset("challenge_details")
	front._button("BACK",func():show(front),"challenge_back")
	front._text(row.title,30,Color("80d9cf"))
	front._text(Catalog.description(row),20)
	var stock=front.host._loadout_stock(row.loadout)
	front._text("FIXED %s · O₂ %d%% · EMP %d · SURVEY %d\nSTANDARD FRAMES · NO FITTINGS"%[preload("res://src/equipment/field_tools.gd").loadout_label(row.loadout),stock[0],stock[1],stock[2]],16)
	front._text("PARS · %02d:%02d · HULL %d%% · TOOLS %d"%[int(row.par.time)/60,int(row.par.time)%60,roundi(row.par.hull),row.par.tools],17)
	front._text("Best: "+Records.summary(history(front).get(id,{}).get("best",{})),16)
	for line in Records.route_lines(row,history(front).get(id,{})):front._text(line,16)
	front._text("A new attempt starts fresh. Ending it records a loss; successful bests remain.",15)
	front._button("START CHALLENGE · START PAUSED",func():start(front,id),"challenge_start")
static func start(front,id:String)->void:
	var row=Catalog.get_challenge(id)
	if row.is_empty() or not Catalog.unlocked(row,completed(front)):return
	load("res://src/presentation/frontend/mode_launcher.gd").launch(front,Session,"ChallengeSession",{"challenge_id":id,"return_to_list":func():show(front)})
