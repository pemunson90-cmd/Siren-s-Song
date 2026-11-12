extends SceneTree
# WP-10: the debrief and the archive show what each secured photograph paid, read
# from the intel the profile stored, never from a separate formula.
const PhotoPay=preload("res://src/presentation/photo_pay/photo_pay.gd")
const Intel=preload("res://src/campaign/photo_intel.gd")
const Archive=preload("res://src/presentation/archive/archive_view.gd")
var checks=0
var failures=0
func check(ok,label):
	checks+=1
	if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():call_deferred("run")
func run_sim(s,seconds):
	s.paused=false
	for n in ceili(seconds*60):s.advance(1./60)
	s.paused=true
func screen_text(game)->String:
	return "\n".join(game.panel_box.find_children("*","Label",true,false).map(func(label):return label.text))
func run():
	await live_case()
	table_case()
	print("PHOTO PAY UI CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
func live_case():
	var game=load("res://scenes/main.tscn").instantiate();game.store.path="user://wp10-pay-%d.save"%Time.get_ticks_usec()
	root.add_child(game);game.set_process(false)
	game._start_mission(0);var s=game.sim;s.sirens=[]
	var spire=Vector2(1300,300);var facing=2.74
	s.units[0].pos=spire+Vector2.from_angle(facing)*110;s.units[0].angle=facing+PI
	run_sim(s,0.2)
	s.command("camera");run_sim(s,5)
	s.units[0].pos=spire+Vector2.from_angle(facing+PI)*110;s.units[0].angle=facing
	s.command("camera");run_sim(s,5)
	check(s.mission.objectives[0].get("captured",false),"the spire record is secured (setup)")
	s.outcome="won";s.mission["recovered"]=true
	game._debrief()
	var text=screen_text(game)
	print("PAY_BLOCK ",PhotoPay.debrief_text(s.mission,game.photo_intel).replace("\n"," | "))
	check("PHOTO PAY" in text,"the debrief carries a photo pay block")
	for key in ["spire_wreck","spire_scoring"]:
		var stored:Dictionary=game.photo_intel.get(key,{})
		check(not stored.is_empty(),"film became stored intel for "+key+" (setup)")
		if not stored.is_empty():check(("INTEL %s %d%%"%[Intel.label(key),roundi(float(stored.q)*100)]) in text,"the debrief shows the stored intel value for "+key)
	check(" · grade " in text,"each secured record shows its grade beside what it paid")
	game._show_campaign()
	Archive.show(game)
	text=screen_text(game)
	var wreck:Dictionary=game.photo_intel.get("spire_wreck",{})
	check("PAID · " in text and not wreck.is_empty() and ("INTEL %s %d%%"%[Intel.label("spire_wreck"),roundi(float(wreck.q)*100)]) in text,"the archive shows what the operation's photographs paid")
	for n in 4:await process_frame # the archive restores its scroll position a frame later
	game.queue_free();await process_frame
func table_case():
	# A research subject: the research threshold comes straight from PhotoIntel.PROJECTS.
	var p:Dictionary=Intel.PROJECTS.photo_flash
	var subject={"facing":0.0,"size":70.0,"glow":0.0,"required":["lining"],"features":[{"id":"lining","label":"VENT LINING","detail":0.4,"intel":p.intel}]}
	var o={"pos":Vector2.ZERO,"name":"VENT","captured":true,"photo_quality":0.5,"subject":subject}
	var shot={"obj":0,"usable":true,"intel":{p.intel:0.2}}
	var mission={"id":3,"objectives":[o],"photo":{"shots":[shot],"studies":[]}}
	var text=PhotoPay.debrief_text(mission,{p.intel:{"q":0.2,"op":3}})
	check(("INTEL %s 20%%"%Intel.label(p.intel)) in text,"this dive's stored value is shown as paid")
	check(("at %d%%"%roundi(float(p.q)*100)) in text and "best 20%" in text,"the better-film figure is the research table's own threshold")
	text=PhotoPay.debrief_text(mission,{p.intel:{"q":0.6,"op":2}})
	check("archive already holds 60% from dive 3" in text and not ("INTEL %s"%Intel.label(p.intel)) in text,"film below the archive's best pays nothing new and says so")
	check("cut from" in text,"research the archive already cut is named as cut")
	o.erase("photo_quality")
	check(PhotoPay.debrief_text(mission,{}).is_empty(),"no secured photograph, no pay block")
	check(PhotoPay.archive_line({},5).begins_with("PAID · no"),"an operation with no intel says so in the archive")
