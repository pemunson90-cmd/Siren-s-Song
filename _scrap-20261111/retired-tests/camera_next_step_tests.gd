extends SceneTree
# WP-95: the camera panel leads with one plain next step; a refused photograph names what to photograph first; every
# place that names a Siren uses the one numbering (simulation/siren_tag.gd); the lock card offers only moves that can help.
const Sim=preload("res://src/simulation/simulation.gd")
const Photo=preload("res://src/simulation/photo_capture.gd")
const Pricing=preload("res://src/simulation/photo_pricing/photo_pricing.gd")
const Table=preload("res://src/simulation/photo_pricing/photo_pricing_table.gd")
const NextStep=preload("res://src/photo_grade/next_step.gd")
const Equipment=preload("res://src/equipment/equipment_catalog.gd")
const SirenTag=preload("res://src/simulation/siren_tag.gd")
const MoveTiming=preload("res://src/presentation/lock_move_timing.gd")
const Missions=preload("res://src/campaign/missions.gd")
var checks=0
var failures=0
func check(ok,label):
	checks+=1
	if not ok:failures+=1;printerr("FAIL ",label)
func fresh(id:int):
	var s=Sim.new();s.start(id,"endurance");s.sirens=[];s.units[1].alive=false;s.units[2].alive=false
	return s
func _initialize():call_deferred("run")
func row(why:String)->Dictionary:
	return {"id":"a","label":"VENT","apparent":true,"ready":false,"why":why}
func run():
	# The dark west relay of operation 1, from 170 m, with no fitted camera extras.
	var dark=fresh(1);var relay=dark.mission.objectives[0]
	dark.units[0].pos=relay.pos+Vector2.from_angle(float(relay.subject.facing))*170.0;dark.units[0].angle=float(relay.subject.facing)+PI
	var frame=Photo.frame(dark,0,relay,0.0)
	var readout=Pricing.readout(dark,0,relay)
	var optics=Photo.optics(dark,0)
	var step=NextStep.read(frame,readout,optics,Photo.flash_left(dark,0))
	check(not step.is_empty() and not step.text.is_empty(),"a dark feature gets a next step: "+str(step))
	check(not step.text.contains("TOO") and not step.text.contains("WAIT") and not step.text.contains("not fitted"),"the next step is plain words: "+str(step.get("text","")))
	# The words by cause, from the same facts.
	var near:={"dist":267.0,"rows":[row("TOO SOFT · x")]}
	check(NextStep.read(near,{"plain":155.0},{"flash":false,"integrate":0.0},0).text==Table.NEXT.close%155,"too far for a sharp frame: move within the reach")
	var close:={"dist":100.0,"rows":[row("TOO DARK · x")]}
	check(NextStep.read(close,{"plain":155.0},{"flash":true,"integrate":0.0},2).text==Table.NEXT.light,"in reach but dark, with a flash: light it")
	check(NextStep.read(close,{"plain":155.0},{"flash":false,"integrate":8.0},0).text==Table.NEXT.hold%roundi(Table.STILL_HOLD),"in reach but dark, with the low-light back: hold still")
	check(NextStep.read(close,{"plain":155.0},{"flash":false,"integrate":0.0},0).text==Table.NEXT.dark,"dark with nothing to light it: says so")
	for pair in [["HIDDEN","hidden"],["CROPPED","cropped"],["OUT OF FOCUS","focus"],["FINE DETAIL · use a TIGHT frame","tight"],["WAITING FOR ITS CYCLE","cycle"]]:
		check(NextStep.read({"dist":50.0,"rows":[row(pair[0])]},{},{},0).text==Table.NEXT[pair[1]],"%s has its own plain step"%pair[0])
	check(NextStep.read({"rows":[{"id":"a","label":"V","apparent":true,"ready":true,"why":""}]},{},{},0).is_empty(),"a ready frame needs no next step")
	check(Table.SOFT_REASON.begins_with(Table.LIGHT_REASONS[1]),"a soft row still starts with the word the light price matches")
	# Wording of the other readouts.
	for key in ["light_flash_none","light_wait_none"]:check(not Table.TEXT[key].contains("WAIT") and not Table.TEXT[key].contains("FLASH"),"%s is not jargon: %s"%[key,Table.TEXT[key]])
	# A refused photograph names what to photograph first.
	var req=Missions.make(3).objectives[1].requirement
	check(req.contains("Photograph") and req.contains("FURNACE VENT") and not req.contains("Resolve"),"operation 3's requirement names what to photograph first: "+req)
	var req5=Missions.make(5).objectives[2].requirement
	check(req5.begins_with("Photograph ") and req5.contains("TRANSMITTER CROWN"),"operation 5's requirement names what to photograph first: "+req5)
	# One numbering for a Siren.
	check(SirenTag.tag(0)=="S1" and SirenTag.tag(1)=="S2","the first Siren is S1")
	var sim=fresh(0);sim.sirens=[{"pos":sim.units[0].pos+Vector2(60,0),"type":"patroller","band":1,"mode":"PATROL","lock":0.0,"angle":0.0,"target":-1,"transition":{}}]
	check(Photo.siren_objective(sim,0)>=0 and Photo.state(sim).studies[0].name.begins_with(SirenTag.tag(0)),"the photo study names the Siren by the shared tag: "+str(Photo.state(sim).studies[0].name))
	# The lock card lists only the moves that can end a running lock.
	var moves=[{"order":"silent"},{"order":"decoy"},{"order":"emp"}]
	var useful=MoveTiming.useful(moves).map(func(m):return m.order)
	check(useful==["silent","emp"],"the decoy is left off the lock card: "+str(useful))
	print("CAMERA NEXT STEP CHECKS ",checks," FAILURES ",failures)
	quit(1 if failures else 0)
