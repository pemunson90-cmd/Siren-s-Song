extends SceneTree
# A4 (WP-19): the opening operations without depth charts chart water by a
# 24x40 cell scan on every sensor pulse. The scan now skips cells outside every
# live craft's reach square. This suite proves the result is identical: the
# same cells become known, in the same order, as the full scan gives.
const Sim=preload("res://src/simulation/simulation.gd")
var checks=0
var failures=0
func check(ok:bool,label:String):
	checks+=1
	if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():call_deferred("run")
# The full scan as it was before A4, applied to a copy.
func reference(s)->Dictionary:
	var ref=s.known.duplicate()
	for y in 24:
		for x in 40:
			if ref.get(Vector2i(x,y),false)==true:continue
			if s.visible(Vector2(x*40+20,y*40+20)):ref[Vector2i(x,y)]=true
	return ref
func uses_scan(s)->bool:
	return s.depth_charts.get(1)==null and not s.mission.has("world_size")
func compare(s,label:String)->void:
	var ref=reference(s)
	s._observe()
	check(s.known==ref,label+": same known cells")
	check(s.known.keys()==ref.keys(),label+": same insertion order")
func run():
	var scanned=0
	for operation in [0,2,3,4,5]:
		var s=Sim.new();s.start(operation,"survey")
		if not uses_scan(s):continue
		scanned+=1
		compare(s,"op %d at launch"%operation)
		# Walk every craft across the map, including edges and corners.
		var step=0
		for y in range(20,960,188):
			for x in range(20,1600,236):
				var p=Vector2(x,y)
				s.units[step%s.units.size()].pos=p
				s.units[(step+1)%s.units.size()].pos=Vector2(1600,960)-p
				compare(s,"op %d step %d"%[operation,step]);step+=1
		# A lost craft charts nothing.
		s.units[1].alive=false;s.units[1].pos=Vector2(60,60);s.units[2].pos=Vector2(1540,900)
		compare(s,"op %d with a lost drone"%operation)
		# A legacy survey shows the whole map: the scan must not skip anything.
		var fresh=Sim.new();fresh.start(operation,"survey");fresh.recon_time=4.0
		compare(fresh,"op %d during a survey"%operation)
		check(fresh.known.size()>=s.known.size(),"op %d survey charts at least as much"%operation)
	check(scanned>0,"at least one opening operation still uses the cell scan")
	print("LEGACY OBSERVE CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
