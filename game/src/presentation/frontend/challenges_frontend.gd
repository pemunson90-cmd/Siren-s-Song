extends RefCounted
# One title-button seam into fixed replay mode; reuses the frontend's scroll and touch sizing.
# Revert: remove that entry and this file plus challenge_session.gd. Campaign menus stay intact.
const Archive=preload("res://src/campaign/challenges/challenge_archive.gd")
const Catalog=preload("res://src/campaign/challenges/challenge_catalog.gd")
const Records=preload("res://src/campaign/challenges/challenge_records.gd")
const Session=preload("res://src/presentation/frontend/challenge_session.gd")
static func completed(front)->Array:
	return front.host._campaign_completed() if front.host.has_method("_campaign_completed") else []
static func history(front)->Dictionary:
	var value=front.host.get("challenge_records")
	return value if value is Dictionary else {}
static func show(front)->void:
	Archive.restore(front.host)
	front._reset("challenges")
	front._button("BACK",front._title_screen,"frontend_back")
	front._text("CHALLENGES",32,Color("80d9cf"))
	front._text("Replay recovered operations with a fixed fleet and one rule. Campaign progress stays as it was.",16)
	var saved=history(front);var recovered=completed(front)
	var error=front.host.get_meta("challenge_save_error","")
	if error is String and not error.is_empty():
		front._text("PROGRESS NOT SAVED\n"+error+"\nResults are held in this session.",16,Color("efc28d"))
		front._button("RETRY SAVE",func():Archive.persist(front.host);show(front),"challenge_retry_save")
	for row in Catalog.all():
		var id:String=row.id;var available=Catalog.unlocked(row,recovered)
		var best=saved.get(id,{}).get("best",{})
		var detail=Records.summary(best) if available else "LOCKED · recover operation %02d"%[int(row.op)+1]
		var b=front._button(row.title+"\n"+detail,func():details(front,id),"challenge_"+id,not available)
		b.set_meta("challenge_id",id)
static func details(front,id:String)->void:
	var row=Catalog.get_challenge(id)
	if row.is_empty() or not Catalog.unlocked(row,completed(front)):return
	front._reset("challenge_details")
	front._button("BACK",func():show(front),"challenge_back")
	front._text(row.title,30,Color("80d9cf"))
	front._text(Catalog.description(row),20)
	var stock=front.host._loadout_stock(row.loadout)
	front._text("FIXED %s · O₂ %d%% · DISRUPT %d · SURVEY %d\nSTANDARD FRAMES · NO FITTINGS"%[row.loadout.to_upper(),stock[0],stock[1],stock[2]],16)
	front._text("PARS · %02d:%02d · HULL %d%% · TOOLS %d"%[int(row.par.time)/60,int(row.par.time)%60,roundi(row.par.hull),row.par.tools],17)
	front._text("Best: "+Records.summary(history(front).get(id,{}).get("best",{})),16)
	front._text("A new attempt starts fresh. Ending it records a loss; successful bests remain.",15)
	front._button("START CHALLENGE · START PAUSED",func():start(front,id),"challenge_start")
static func start(front,id:String)->void:
	var row=Catalog.get_challenge(id)
	if row.is_empty() or not Catalog.unlocked(row,completed(front)):return
	var session=load("res://scenes/main.tscn").instantiate()
	session.set_script(Session);session.name="ChallengeSession"
	session.campaign_host=front.host;session.challenge_id=id
	session.return_to_list=func():show(front)
	session.process_mode=Node.PROCESS_MODE_ALWAYS
	session.freeze_campaign()
	front.host.add_child(session)
