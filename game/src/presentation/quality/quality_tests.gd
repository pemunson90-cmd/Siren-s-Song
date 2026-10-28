extends SceneTree
# Source-known module, settings and matched fixed-step simulation checks.
const Store=preload("res://src/persistence/settings_store.gd")
const Settings=preload("res://src/presentation/frontend/frontend_settings.gd")
const Simulation=preload("res://src/simulation/simulation.gd")
const Table=preload("res://src/presentation/quality/quality_table.gd")
const Governor=preload("res://src/presentation/quality/quality_governor.gd")
const Region=preload("res://src/presentation/art/region_renderer.gd")
class DrawProbe extends RefCounted:
	var world_offset=Vector2.ZERO
	var world_scale=1.0
	var size=Vector2(400,300)
	var calls:Array=[]
	func draw_rect(rect:Rect2,color:Color)->void:calls.append([rect,color])
	func draw_line(a:Vector2,b:Vector2,color:Color,width:float)->void:calls.append([a,b,color,width])
var failures:=0
var checks:=0
func check(ok:bool,label:String)->void:
	checks+=1
	if not ok:failures+=1;printerr("FAIL ",label)
func _initialize()->void:
	check(Table.normalize(null)==Table.STANDARD and Table.normalize("bad")==Table.STANDARD,"invalid or absent tier defaults to STANDARD")
	check(Table.decorative_enabled("required_terrain",Table.LOW_EFFECTS),"unknown switches preserve information")
	var governor=Governor.new(false)
	var early=false
	for n in 220:early=governor.observe_frame(.05) or early
	check(not early and governor.suggestion().is_empty(),"no suggestion before warmup plus ten over-budget seconds")
	var emissions=0
	for n in 80:
		if governor.observe_frame(.05):emissions+=1
	check(emissions==1 and governor.suggestion().tier==Table.LOW_EFFECTS,"one suggestion after sustained slow frames")
	governor.observe_frame(.05,Table.STANDARD,false)
	check(not governor.suggestion().is_empty(),"earned suggestion persists through pause or menu until dismissed")
	check(governor.average_frame_seconds()==0.0,"ineligible time resets sampling without hiding consent choices")
	governor.dismiss()
	for n in 300:governor.observe_frame(.05)
	check(governor.suggestion().is_empty(),"dismissal lasts for governor session")
	var interrupted=Governor.new(false)
	for n in 180:interrupted.observe_frame(.05)
	for n in 300:interrupted.observe_frame(1./60.)
	for n in 180:interrupted.observe_frame(.05)
	check(interrupted.suggestion().is_empty(),"recovery resets sustained over-budget duration")
	interrupted.observe_frame(.05,Table.LOW_EFFECTS)
	check(interrupted.average_frame_seconds()==0.,"LOW EFFECTS resets measurement")
	interrupted.observe_frame(.05,Table.STANDARD,false)
	check(interrupted.suggestion().is_empty(),"ineligible frames do not suggest")
	var headless=Governor.new()
	check(DisplayServer.get_name()=="headless","run this probe headless")
	for n in 300:headless.observe_frame(.05)
	check(headless.suggestion().is_empty() and headless.average_frame_seconds()==0. and headless.should_redraw(.1,true),"headless measurement is a no-op and redraw throttle bypasses")
	var gate=Governor.new(false)
	gate.should_redraw(0.,true)
	var idle_draws=0
	for n in 600:
		if gate.should_redraw(1./60.,true):idle_draws+=1
	check(idle_draws==100,"unchanged paused gate requests 10 redraws/sec at 60Hz")
	check(gate.should_redraw(0.,true,true),"selection/camera/order/overlay change redraws immediately")
	gate.invalidate();check(gate.should_redraw(0.,true),"explicit invalidation redraws immediately")
	for n in 10:
		check(gate.should_redraw(1./60.,true,false,false,true),"gesture keeps full redraw cadence")
	check(gate.should_redraw(0.,true,false,true),"animated overlay redraws immediately")
	check(gate.should_redraw(0.,false),"resume redraws on next frame")
	var style={"light":Color(.2,.3,.4,.2),"falloff":.1,"drift":Vector2(1,2),"dust":Color.WHITE,"floor":Color.BLACK,"stone":Color.GRAY,"edge":Color.WHITE}
	var standard=DrawProbe.new();var low=DrawProbe.new()
	Region.atmosphere(standard,style,Vector2(400,300),1.)
	Region.atmosphere(low,style,Vector2(400,300),1.,Table.LOW_EFFECTS)
	check(standard.calls.size()>=16 and low.calls.is_empty(),"LOW EFFECTS omits named decorative atmosphere draws")
	standard.calls.clear()
	var terrain={"clear_cells":[Vector2i(1,1)],"surface_segments":[[Vector2.ZERO,Vector2(40,40)]]}
	Region.chart_terrain(standard,terrain,1.,style);Region.chart_terrain(low,terrain,1.,style)
	check(standard.calls==low.calls and low.calls.size()==3,"measured terrain remains identical")
	check(Store.sanitize({}).quality==Table.STANDARD,"absent quality retains STANDARD")
	for invalid in [null,true,0,[],{},"low_effects"]:
		check(Store.sanitize({"quality":invalid}).quality==Table.STANDARD,"invalid quality retains STANDARD: "+str(invalid))
	var store=Store.new();store.path="user://quality-test-settings.json"
	for tier in [Table.STANDARD,Table.LOW_EFFECTS]:
		check(store.save_settings({"quality":tier}),"quality saves: "+tier)
		check(store.load_settings().quality==tier,"quality roundtrips: "+tier)
	DirAccess.remove_absolute(store.path)
	var snapshots=[]
	for tier in [Table.STANDARD,Table.LOW_EFFECTS]:
		Settings.apply({"quality":tier})
		var sim=Simulation.new();sim.start(0,"endurance");sim.paused=false
		for n in 3600:sim.advance(1.0/60.0)
		check(is_equal_approx(sim.elapsed,60.0),"stationary safe-start scenario advances all 60 simulation seconds")
		snapshots.append(sim.snapshot())
		print("QUALITY matched_60s tier=",tier," sha256=",var_to_bytes(sim.snapshot()).hex_encode().sha256_text()," elapsed=",sim.elapsed)
	check(snapshots[0]==snapshots[1],"matched 60-second fixed-step simulation snapshots are identical in both tiers")
	Settings.apply(Store.DEFAULTS)
	print("QUALITY synthetic_idle_gate_hz=",idle_draws/10.)
	print("QUALITY CHECKS ",checks," FAILURES ",failures)
	quit(1 if failures else 0)
