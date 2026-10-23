extends SceneTree
const Sim=preload("res://src/simulation/simulation.gd")
const Gear=preload("res://src/equipment/equipment_catalog.gd")
var checks=0
var failures=0
func check(ok,label):
	checks+=1
	if not ok:failures+=1;printerr("FAIL ",label)
func fresh(op:int,chassis:String="standard"):
	var s=Sim.new();s.start(op,"endurance",{"fitted":Gear.canonical({"chassis_a":chassis})});s.selected=1
	var a=s.mission.glass_reach.artifact if op<22 else s.mission.iron_choir.artifact
	s.units[1].pos=a.pos;s.units[1].vel=Vector2.ZERO;s.units[1].band=a.band;s._use_band(a.band)
	return s
func ctx(s):return s.Glass.context(s,"recover") if s.mission.id<22 else s.Choir.context(s,"recover")
func fill(s,id:int):
	s.mission["module_recovery"]={"modules":{},"jobs":[{},{},{}],"result":{},"deferred":""}
	for n in s.ModuleRecovery.capacity(s,id):
		s.mission.module_recovery.modules["cargo_fixture_%d"%n]={"state":"cargo","unit":id,"pos":s.units[id].pos}
func _initialize():
	for op in [17,20,21,26,27]:
		var scout=fresh(op,"scout")
		if op==27:scout.mission.iron_choir.artifact.state="site"
		check(scout.ModuleRecovery.capacity(scout,1)==0 and not ctx(scout).ready,"op%d refuses physical material on a zero-cargo Scout"%op)
		var s=fresh(op)
		if op==27:s.mission.iron_choir.artifact.state="site"
		check(ctx(s).ready,"op%d retains ordinary recovery with a free cargo place"%op)
		fill(s,1)
		check(not ctx(s).ready,"op%d rejects recovery on an already full carriage"%op)
		var a=s.mission.glass_reach.artifact if op<22 else s.mission.iron_choir.artifact
		s.mission.module_recovery.modules={};a.state="cargo";a.carrier=1
		check(s.ModuleRecovery.carried(s,1)==1,"op%d material occupies the shared physical cargo budget"%op)
	var transfer=fresh(20);var a=transfer.mission.glass_reach.artifact;a.state="cargo";a.carrier=1
	transfer.units[0].pos=transfer.units[1].pos;transfer.units[0].band=transfer.units[1].band;transfer.units[0].vel=Vector2.ZERO
	fill(transfer,0)
	check(not transfer.Glass.transfer(transfer,1) and a.carrier==1,"full Quietus refuses transfer without moving material custody")
	transfer.mission.module_recovery.modules={}
	check(transfer.Glass.transfer(transfer,1) and a.carrier==0,"local transfer succeeds when Quietus has room")
	var witness=Sim.new();witness.start(12)
	witness.mission.witness_evacuation.state="carried";witness.mission.witness_evacuation.carrier=0
	check(witness.ModuleRecovery.carried(witness,0)==1,"occupied capsule shares capacity with salvaged hardware")
	var rescue=Sim.new();rescue.start(12,"endurance",{"fitted":Gear.canonical({"hull":"quiet","drone_a":"drone_deep_cells"})});rescue.sirens=[]
	var pod=rescue.mission.witness_evacuation
	rescue.units[0].pos=pod.pos+Vector2(0,40);rescue.units[0].vel=Vector2.ZERO
	var hardware=rescue.mission.module_recovery.modules.drone_deep_cells
	hardware.state="salvage";hardware.unit=-1;hardware.pos=pod.pos
	rescue.units[1].alive=false;pod.state="salvage"
	rescue.paused=false;rescue.advance(0.1);rescue.paused=true
	check(rescue.command("salvage",{"item":"witness_capsule"}),"one-place Quietus begins an ordinary shared-wreck rescue")
	rescue.paused=false
	for n in 250:rescue.advance(1./60.)
	rescue.paused=true
	check(pod.state=="carried" and rescue.ModuleRecovery.carried(rescue,0)==1 and hardware.state=="salvage","occupied capsule takes the free place and excess hardware stays recoverable")
	print("AUDIT ARTIFACT CARGO CHECKS ",checks," FAILURES ",failures)
	quit(1 if failures else 0)
