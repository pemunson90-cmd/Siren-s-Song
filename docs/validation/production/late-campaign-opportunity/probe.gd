extends SceneTree
const Sim=preload("res://src/simulation/simulation.gd")
var last_emp=-99.0
func _initialize():call_deferred("run")
func step(s,seconds,protect):
	for n in int(round(seconds*10)):
		s.advance(.1)
		if not s.outcome.is_empty():return
		if protect and s.elapsed-last_emp>1:
			for c in s.contacts.values():
				if s.elapsed-c.time<.3 and c.lock>1 and c.target>=0 and s.tools.emp>0:
					var selected=s.selected;s.command("select",{"unit":c.target});s.command("emp");s.command("select",{"unit":selected});last_emp=s.elapsed;break
func run():
	for protect in [false,true]:
		var s=Sim.new();s.start(4,"disruption");last_emp=-99
		for id in 3:
			var unit=1 if s.units[1].alive else 2
			if not s.units[unit].alive:break
			var point=[Vector2(800,390),Vector2(1150,450),Vector2(780,850)][id]
			s.command("select",{"unit":unit});var routed=s.command("route",{"point":point});s.paused=false
			for n in 1600:
				step(s,.1,protect)
				if not s.outcome.is_empty() or not s.units[unit].alive or (s.units[unit].route.is_empty() and s.units[unit].vel.length()<2):break
			print("ARRIVAL protect=",protect," id=",id," unit=",unit," route=",routed," time=",s.elapsed," context=",s.camera_context())
			if not s.units[unit].alive:break
			var camera=s.command("camera");step(s,4.5,protect)
			print("EXPOSURE protect=",protect," id=",id," camera=",camera," time=",s.elapsed," records=",s.mission.objectives.map(func(o):return o.captured)," drones=",s.units[1].alive,",",s.units[2].alive," tools=",s.tools," message=",s.message)
			if not s.mission.objectives[id].captured:break
		print("RESULT protect=",protect," outcome=",s.outcome," time=",s.elapsed," hull=",s.hull," sub_pos=",s.units[0].pos," drones=",s.units[1].alive,",",s.units[2].alive," records=",s.mission.objectives.map(func(o):return o.captured)," story=",s.mission.record," events=",s.events)
	quit()
