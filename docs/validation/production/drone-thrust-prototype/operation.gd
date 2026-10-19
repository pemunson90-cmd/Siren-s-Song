extends SceneTree
var Experiment=load("/workspace/Siren-s-Song-drone-investigation/work/drone-thrust-prototype/thrust_sim.gd")
var artifact_dir="/workspace/Siren-s-Song-drone-investigation/work/drone-thrust-prototype/"
func issue(s,commands:Array,order:String,args:Dictionary={}):
	var accepted=s.command(order,args)
	var entry={"t":snappedf(s.elapsed,0.001),"selected":s.selected,"order":order,"ok":accepted}
	if args.has("unit"):entry.unit=args.unit
	if args.has("point"):entry.point=[args.point.x,args.point.y]
	if order!="select" or not commands.is_empty():commands.append(entry)
	return accepted
func run_operation(thrust:float,idle:bool=false)->Dictionary:
	var s=Experiment.new();s.drone_thrust=thrust;s.start(1,"endurance")
	var commands:Array=[];var samples:Array=[];var max_speed=[0.0,0.0];var radius_time=[0.0,0.0];var moving_time=[0.0,0.0]
	var capture_times=[-1.0,-1.0,-1.0];var arrival_times=[-1.0,-1.0];var drone_returned={1:false,2:false};var returning=false
	var first_contact=-1.0;var first_damage=-1.0;var last_emp=-100.0
	if not idle:
		for id in [1,2,0]:
			issue(s,commands,"select",{"unit":id});issue(s,commands,"route",{"point":[Vector2(840,780),Vector2(420,490),Vector2(1220,490)][id]})
	s.paused=false
	for n in 1600:
		s.advance(0.1)
		if first_contact<0 and not s.contacts.is_empty():first_contact=s.elapsed
		if first_damage<0 and s.hull<100:first_damage=s.elapsed
		for i in [1,2]:
			var speed=s.units[i].vel.length();max_speed[i-1]=maxf(max_speed[i-1],speed)
			radius_time[i-1]+=s.Acoustics.motion_radius(speed)*0.1
			if speed>1:moving_time[i-1]+=0.1
			if not idle and drone_returned[i] and arrival_times[i-1]<0 and s.units[i].pos.distance_to(s.mission.extraction)<65 and speed<12:arrival_times[i-1]=s.elapsed
		for o in 3:
			if s.mission.objectives[o].captured and capture_times[o]<0:capture_times[o]=s.elapsed
		if not idle:
			for contact in s.contacts.values():
				if s.elapsed-contact.time>0.3 or contact.lock<1 or s.tools.emp<=0 or s.elapsed-last_emp<0.3:continue
				var nearest=0;var distance=INF
				for id in 3:
					if s.units[id].alive and s.units[id].pos.distance_to(contact.pos)<distance:nearest=id;distance=s.units[id].pos.distance_to(contact.pos)
				issue(s,commands,"select",{"unit":nearest});issue(s,commands,"emp");last_emp=s.elapsed;break
			for drone in [1,2]:
				if s.mission.objectives[drone-1].captured and not drone_returned[drone] and s.units[drone].alive:
					issue(s,commands,"select",{"unit":drone});issue(s,commands,"route",{"point":s.mission.extraction});drone_returned[drone]=true
			if s.capture_unit<0 and not s.all_records():
				for objective_id in 3:
					var unit_id=[1,2,0][objective_id];var o=s.mission.objectives[objective_id]
					if not o.captured and s.units[unit_id].alive and s.units[unit_id].pos.distance_to(o.pos)<230:
						issue(s,commands,"select",{"unit":unit_id});issue(s,commands,"camera");break
			if s.all_records() and not returning:
				issue(s,commands,"select",{"unit":0});issue(s,commands,"route",{"point":s.mission.extraction});returning=true
		if n%10==0:
			var units=[]
			for u in s.units:units.append({"pos":[u.pos.x,u.pos.y],"speed":u.vel.length(),"alive":u.alive,"battery":u.battery,"silent":u.silent})
			samples.append({"t":s.elapsed,"hull":s.hull,"tools":s.tools.duplicate(),"units":units,"records":s.mission.objectives.map(func(o):return o.captured),"contacts":s.contacts.values().map(func(c):return {"pos":[c.pos.x,c.pos.y],"time":c.time,"lock":c.lock,"mode":c.mode})})
		if not s.outcome.is_empty() or (idle and s.elapsed>=40.0) or s.elapsed>=60.0:break
	var result={"thrust":thrust,"idle":idle,"outcome":s.outcome,"time":s.elapsed,"hull":s.hull,"oxygen":s.oxygen,"tools":s.tools,"alive":s.units.map(func(u):return u.alive),"battery":s.units.map(func(u):return u.battery),"capture_times":capture_times,"drone_home_times":arrival_times,"first_contact":first_contact,"first_damage":first_damage,"max_speed":max_speed,"radius_time":radius_time,"moving_time":moving_time}
	var label=("idle-" if idle else "split-")+str(int(thrust))
	FileAccess.open(artifact_dir+label+".json",FileAccess.WRITE).store_string(JSON.stringify({"summary":result,"commands":commands,"samples":samples},"\t"))
	print(JSON.stringify(result));return result
func _initialize():
	for thrust in [96.0,72.0,60.0]:run_operation(thrust)
	for thrust in [96.0,60.0]:run_operation(thrust,true)
	quit()
