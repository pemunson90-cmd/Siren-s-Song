extends SceneTree
# WP-110: the ROUTE PROGRAM screen shows the Sirens the player knows (as the dive chart does), marks the rock where a leg
# meets it, says SAME for "keep the current setting", gives distance and bearing instead of raw coordinates, and the
# lock card, chart tag and contact list name each Siren one way.
const Sim=preload("res://src/simulation/simulation.gd")
const ProgramPanel=preload("res://src/presentation/route_program_panel.gd")
const Preview=preload("res://src/presentation/route_program_preview.gd")
const Words=preload("res://src/presentation/hud_words.gd")
const Compass=preload("res://src/presentation/compass.gd")
const ContactFeedback=preload("res://src/presentation/contact_feedback.gd")
const HandPilot=preload("res://src/simulation/hand_pilot/hand_pilot.gd")
const HullBand=preload("res://src/presentation/route_clearance/hull_band.gd")
class Host extends Control:
	var sim
	var ui_touch_height=48.0
	var screen="mission"
	var hud=Control.new()
	func _order(name,args):sim.command(name,args)
	func _report_targets():pass
	func _refresh():pass
	func _save_archive():pass
	func _layout():pass
var checks=0
var failures=0
func check(ok,label):
	checks+=1
	if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():call_deferred("run")
func contact(sim,id,pos,kind,age=0.):
	sim.contacts[id]={"pos":pos,"time":sim.elapsed-age,"angle":0.,"lock":0.,"mode":"PATROL","type":kind,"display_type":kind,"target":-1}
# A water point whose straight leg from the craft crosses charted rock without ending in it.
func rock_point(s)->Variant:
	var from:Vector2=s.units[0].pos
	for distance in [160.0,240.0,320.0,420.0,540.0,700.0,900.0]:
		for i in 32:
			var p:Vector2=from+Vector2.from_angle(TAU*i/32.0)*distance
			if Rect2(Vector2.ONE*24,s.world_size()-Vector2.ONE*48).has_point(p) and not HandPilot.rock_at(s,p) and HandPilot.crosses_rock(s,from,p):return p
	return null
func run():
	var s=Sim.new();s.start(0);s.paused=true
	var host=Host.new();host.sim=s;host.size=Vector2(2520,1080);root.add_child(host)
	var panel=ProgramPanel.new();host.add_child(panel);panel.open(host)
	await process_frame
	var preview=panel.preview
	# 1. Sirens: only what the contact list holds, with the dive chart's names and positions.
	s.contacts.clear()
	contact(s,0,Vector2(900,500),"sweeper");contact(s,1,Vector2(900,500),"patroller",12.)
	var known=preview.known_sirens()
	check(known.size()==2 and known[0].pos==Vector2(900,500) and known[1].pos==Vector2(900,500),"the screen holds a last-seen mark for each held contact: %d"%known.size())
	check(known[0].name=="S1 SWEEPER" and known[1].name=="S2 PATROL" and not known[1].fresh,"each carries the id, its kind and a stale flag")
	s.contacts.clear()
	check(preview.known_sirens().is_empty() and not s.sirens.is_empty(),"a Siren the player has no contact for is never shown, though the dive holds some")
	preview.queue_redraw();await process_frame
	# 2. Rock: the screen marks the point where the leg first meets rock, the same call the dive chart's red leg uses.
	var p=rock_point(s)
	check(p!=null,"the opening chart has a water point behind charted rock")
	if p!=null:
		var origin:Vector2=s.units[0].pos
		var rock=preview.leg_rock_point(origin,p)
		check(rock!=null and rock==HandPilot.rock_point(s,origin,p) and preview.leg_crosses_rock(origin,p),"the preview reports where the leg meets rock")
		panel.choose_point(p);await process_frame
		check(preview.pending_point!=null and preview.pending_rock==rock and rock.distance_to(origin)<p.distance_to(origin),"the waiting point carries the rock's point, short of the point itself")
		panel.choose_point(p);await process_frame
		check(preview.pending_point==null and preview.pending_rock==null and not s.route_goals().is_empty(),"the second tap places it and clears the mark")
		var marks=preview.rock_marks()
		var warned=HandPilot.warnings(s,0).filter(func(w):return w.reason==HandPilot.ROCK_REASON).map(func(w):return w.at)
		check(not marks.is_empty() and marks==warned,"the programmed leg's rock mark is the dive chart's red-leg point: %s"%str(marks))
	# A leg with open water under it gets no mark.
	s.command("route_undo",{});panel.refresh()
	# 3. Words.
	s.command("route",{"point":s.units[0].pos+Vector2(60,0)});s.command("route_insert",{"index":1,"point":s.units[0].pos+Vector2(60,120)})
	panel.refresh();await process_frame
	var goals=s.route_goals()
	var rows=panel.rows.get_children().map(func(b):return b.text)
	check(rows.size()==goals.size() and rows.size()>=1,"one row per point")
	var first:String=rows[0]
	var want:String="1 · SAME · STOP · %d m, bearing %03d°"%[roundi(s.units[0].pos.distance_to(goals[0].pos)),Compass.bearing(goals[0].pos-s.units[0].pos)]
	if not goals[0].stop:want=want.replace("STOP","PASS")
	check(first==want,"a row gives distance and bearing from the craft, not coordinates: %s"%first)
	if rows.size()>1:
		var next:String=Words.PROGRAM_ROW%[2,Words.program_mode(goals[1].mode,false),"STOP" if goals[1].stop else "PASS",roundi(goals[0].pos.distance_to(goals[1].pos)),Compass.bearing(goals[1].pos-goals[0].pos)]
		check(rows[1]==next,"a later row measures from the point before it: %s"%rows[1])
	var all_text:String=" ".join(rows)+" "+panel.info.text+" "+panel.mode_button.text+" "+panel.arrival_button.text+" "+panel.point_info.text
	var coordinates=RegEx.create_from_string("\\d+, \\d+")
	check(coordinates.search(first)==null and not "INHERIT" in all_text,"no raw coordinates and no INHERIT on the screen: %s"%all_text)
	check(panel.mode_button.text=="TO: SAME" and "SAME keeps its current setting" in panel.info.text,"the button and the help line both say SAME")
	check("AT: STOP halts" in panel.info.text and "TO: how the craft travels" in panel.info.text,"the help line explains TO and AT")
	var jargon=Words.PROGRAM_PAN+" "+HullBand.STYLE.legend
	check(not "PINCH" in jargon and not "HULL WIDTH" in jargon and not "BAND =" in jargon,"no developer notes on the chart: "+jargon)
	s.selected=1;panel.refresh();await process_frame
	check(panel.info.text.contains("DRIVE ") and "TO: how the drone travels" in panel.info.text,"a drone's help line names the drone")
	check(Words.program_mode("inherit",true)=="SAME" and Words.program_mode("inherit",false)=="SAME" and Words.program_mode("cruise",false)=="CRUISE","one word for the unchanged setting, both craft")
	panel.queue_free();host.hud.free();host.queue_free()
	await process_frame;await process_frame
	print("ROUTE PROGRAM SCREEN CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
