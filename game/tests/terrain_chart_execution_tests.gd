extends SceneTree
const Sim=preload("res://src/simulation/simulation.gd")
var checks=0
var failures=0
func check(ok,label):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func fixture(with_wall=true):
 var s=Sim.new();s.start(0)
 s.mission.merge({"id":14,"terrain_chart_revision":1,"chart_geometry_revision":1,"world_size":Vector2(1200,1200),"region_revision":1,"launch_seed":Rect2(80,800,400,320),"start":Vector2(300,1000),"extraction":Vector2(300,1000),"rocks":[Rect2(600,100,120,720)] if with_wall else [],"sirens":[],"objectives":[],"delivery_revision":1,"handoff_pos":Vector2(1000,200),"withdrawal_pos":Vector2(300,1000),"handoff_sector":Rect2(880,80,240,240),"launch_context":{},"carried_evidence":"","handoff_complete":false,"withdrawal_armed":false,"recovered":false},true)
 s.units[0].pos=Vector2(300,1000);s.units[1].pos=Vector2(300,900);s.units[2].pos=Vector2(440,1000);s.sirens=[]
 s._build_navigation();s.call("_configure_chart")
 return s
func _initialize():
 var probe=Sim.new()
 if not probe.has_method("public_chart"):check(false,"actual Sim exposes earned chart execution")
 else:
  var a=fixture();var b=fixture(false)
  var initial=a.public_chart()
  check(a.command("route",{"point":Vector2(640,500)}) and b.command("route",{"point":Vector2(640,500)}) and a.units[0].route==b.units[0].route,"actual unknown destination order and compile ignore hidden endpoint rock")
  check(a.public_chart()==initial,"paused order adds no knowledge")
  var state_before=a.snapshot();var segments=a.course_segments(0);var delivery=a.delivery_context()
  check(segments.any(func(part):return part.confirmed) and segments.any(func(part):return not part.confirmed),"public course segments distinguish certified prefix from speculative intention")
  check(delivery.handoff_sector==a.mission.handoff_sector and not delivery.return_available and not delivery.handoff_complete,"delivery DTO exposes announced destination and own recovery prerequisites")
  check(a.snapshot()==state_before,"course and delivery presentation getters earn no observations and mutate no intent")
  check(a._repair_current_leg(a.units[0]) and b._repair_current_leg(b.units[0]) and a.units[0].route==b.units[0].route,"turn-displaced repair reads identical public chart rather than hidden layouts")
  a.command("ping");check(a.public_chart()==initial,"paused SONAR earns no chart measurements")
  a.command("recon");check(a.public_chart()==initial,"paused finite RECON arms tool without chart stamping")
  a.paused=false;a.advance(Sim.STEP)
  check(a.public_chart()!=initial and a.tools.recon==1,"unpaused sensor pulse applies finite survey once ordinary time runs")
  var stop=fixture();stop.mission.rocks=[Rect2(860,100,120,900)];stop._build_navigation();stop._configure_chart();stop.mission.objectives=[{"site_id":"known_receiver","name":"OBSERVED TEST RECEIVER","pos":Vector2(1100,900),"kind":"receiver","captured":false}];stop.command("select",{"unit":1});stop.command("route",{"point":Vector2(1100,900)});stop.command("route_edit",{"index":0,"mode":"cruise","task_site":"known_receiver"});stop.command("queue");stop.command("route",{"point":Vector2(300,900)})
  var intent=stop.route_goals(1);stop.paused=false
  var collided=false;var peak=0.0
  for tick in 1800:
   stop.advance(Sim.STEP)
   if stop.blocked(stop.units[1].pos,12):collided=true
   peak=maxf(peak,stop.units[1].vel.length())
  check(peak>90,"test reaches actual transit velocity before observing wall")
  check(not collided and stop.units[1].alive and stop.units[1].vel.length()<0.01,"TRANSIT96 near unseen wall brakes without physical collision")
  check(stop.route_goals(1)==intent and stop.units[1].route.size()>=2 and stop.course_status(1).state=="blocked","new terrain latches replot and keeps incoming mode STOP and queued withdrawal")
  check(stop.units[1].hold=="" and stop.capture_unit==-1,"terrain stop does not replace pilot hold or fabricate task/capture")
  stop.units[1].hold="SCOUT_STOP";var guarded=stop.units[1].pos;stop.advance(0.1)
  check(stop.units[1].hold=="SCOUT_STOP" and stop.units[1].pos==guarded,"terrain stop keeps latched SCOUT release authority")
  var diagonal=Sim.new();diagonal.start(14,"disruption",{"context":{"completed":[12],"facts":{"resolution":"concealed_recovery","confluence_route":"concealed"}}});diagonal.command("route",{"point":diagonal.mission.handoff_pos});diagonal.paused=false
  for tick in 1200:diagonal.advance(Sim.STEP)
  check(diagonal.course_status(0).state=="blocked","conservative diagonal cell frontier beside an observed face provides replot cue rather than permanent unresolved drift")
  var state=stop.snapshot();check(Sim.valid_snapshot(state),"optional chart and course latch validate")
  var loaded=Sim.new();check(loaded.restore(state) and loaded.public_chart()==stop.public_chart() and loaded.units==stop.units,"restore rebuilds chart without new observation or intent mutation")
  var restored=loaded.snapshot();check(restored.terrain_chart==state.terrain_chart and restored.tick_phase==state.tick_phase,"chart restore preserves earned knowledge and exact existing tick phase")
  var legacy=Sim.new();legacy.start(0);check(not legacy.snapshot().has("terrain_chart") and legacy.public_chart().is_empty(),"old missions retain absent chart schema and behavior")
  check(not fixture().all_records(),"empty objectives cannot complete carried-evidence delivery at launch")
  var withdrawal=Sim.new();withdrawal.start(14,"disruption",{"context":{"completed":[12],"facts":{"resolution":"concealed_recovery","confluence_route":"concealed"}}})
  withdrawal.command("route",{"point":Vector2(300,2480)});withdrawal.paused=false
  for tick in 600:withdrawal.advance(Sim.STEP)
  withdrawal.command("route",{"point":withdrawal.mission.withdrawal_pos})
  for tick in 600:withdrawal.advance(Sim.STEP)
  check(withdrawal.outcome=="withdrawn" and not withdrawal.mission.handoff_complete and not withdrawal.mission.recovered,"ordinary departure and settled early return retain notes without delivery success")
  var evolving=Sim.new();evolving.start(14,"disruption",{"context":{"completed":[12],"facts":{"resolution":"concealed_recovery","confluence_route":"concealed"}}});evolving.command("route",{"point":Vector2(300,2000)});evolving.paused=false
  for tick in 47:evolving.advance(Sim.STEP)
  evolving.paused=true;var copy=Sim.new();check(copy.restore(evolving.snapshot()),"active earned-chart running course restores")
  evolving.paused=false;copy.paused=false
  for tick in 80:evolving.advance(Sim.STEP);copy.advance(Sim.STEP)
  check(evolving.snapshot()==copy.snapshot(),"identical future ticks preserve chart observations physics AI and phase exactly")
 print("TERRAIN CHART EXECUTION CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
