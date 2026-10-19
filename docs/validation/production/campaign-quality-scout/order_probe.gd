extends SceneTree
const Sim=preload("res://src/simulation/simulation.gd")
func _initialize(): call_deferred("run")
func run():
	for reverse in [false,true]:
		var s=Sim.new(); s.start(2,"survey")
		for target_id in ([1,0] if reverse else [0,1]):
			var target=s.mission.objectives[target_id]
			var vantage=Vector2(760,410) if target_id==0 else Vector2(1150,480)
			s.command("select",{"unit":1}); var routed=s.command("route",{"point":vantage}); s.paused=false
			for n in 1600:
				s.advance(0.1)
				for c in s.contacts.values():
					if s.elapsed-c.time<0.3 and c.lock>1 and s.tools.emp>0: s.command("select",{"unit":int(c.target)}); s.command("emp"); s.command("select",{"unit":1}); break
				if not s.units[1].alive or (s.units[1].route.is_empty() and s.units[1].vel.length()<2): break
			print("ARRIVE reverse=",reverse," target=",target_id," routed=",routed," t=",s.elapsed," alive=",s.units[1].alive," context=",s.camera_context())
			var accepted=s.command("camera")
			for n in 45: s.advance(0.1)
			print("RECORD reverse=",reverse," target=",target_id," accepted=",accepted," t=",s.elapsed," records=",s.mission.objectives.map(func(o):return o.captured)," tools=",s.tools," outcome=",s.outcome," hull=",s.hull," pos=",s.units[1].pos," contacts=",s.contacts," message=",s.message," events=",s.events)
			if not s.units[1].alive: break
	quit()
