extends Control
# Read-only world-space instrumentation; no Simulation writes or commands.
const Hunt=preload("res://src/simulation/hunt_pressure/hunt_pressure.gd")
const Recon=preload("res://src/simulation/recon_consequences.gd")
const Sweeper=preload("res://src/simulation/sweeper_senses.gd")
const Network=preload("res://src/simulation/acoustic_network.gd")
const Industry=preload("res://src/simulation/industrial_threats.gd")
const LAYERS=["sight","hearing","patrol","hunt","locks","noise","endurance","cargo","chart"]
var console
func on(key:String)->bool:return console.layers.get(key,false)
func text(at:Vector2,value:String)->void:draw_string(ThemeDB.fallback_font,at,value,HORIZONTAL_ALIGNMENT_LEFT,-1,16,Color("ffe389"))
func ring(at:Vector2,radius:float,color:Color)->void:
 var ocean=console.host.ocean
 draw_arc(ocean.screen_position(at),radius*ocean.world_scale,0,TAU,64,color,1.5)
# Ranges are emission-dependent open-water bounds. Network relays receive packets,
# buoys sample sound, and industrial roles use their own unscaled sight path.
static func ranges(sim,s:Dictionary)->Dictionary:
 var role=s.get("type","")
 if role in Network.ROLES:
  var hearing=0.
  var u=sim.units[0]
  if role=="buoy" and u.alive and s.band in sim.Depth.occupied(u) and sim.propulsion_speed(u)>12:
   hearing=minf(650.,sim.motion_radius(0)*1.6)
  return {"silent":0.,"cruise":0.,"hearing":hearing,"label":"relay: packet reception only" if role=="relay" else "buoy: Quietus emission, open water upper bound"}
 var scale=1. if role in Industry.ROLES else Hunt.sight(sim.mission,s,Recon.readiness(s))
 var source=sim.motion_radius(0) if sim.mission.get("acoustic_revision",0)==1 else (430. if sim.propulsion_speed(sim.units[0])>50 else 0.)
 return {"silent":180.*scale,"cruise":290.*scale,"hearing":source*Recon.readiness(s)*Sweeper.ear(s),"label":"hearing: Quietus emission, open water upper bound"}
func _draw()->void:
 if console==null or not console.State.marked(console.host) or console.host.screen!="mission":return
 var sim=console.host.sim;var ocean=console.host.ocean
 var lines=["DEV"]
 for s in sim.sirens:
  var p=ocean.screen_position(s.pos)
  var range=ranges(sim,s)
  if on("sight") and range.cruise>0:
   ring(s.pos,range.silent,Color(.3,1.,.6,.5));ring(s.pos,range.cruise,Color(1.,.3,.3,.6))
  if on("hearing"):
   if range.hearing>0:ring(s.pos,range.hearing,Color(.5,.6,1.,.5))
   text(p+Vector2(0,40),range.label)
  if on("patrol"):
   text(p,str(s.get("mode",""))+" band "+str(s.get("band",1)))
   var previous=p
   for point in s.get("patrol_points",[]):
    var at=ocean.screen_position(point if point is Vector2 else point.get("pos",s.pos));draw_line(previous,at,Color(.8,.6,1.,.8),2.);previous=at
  if on("locks"):text(p+Vector2(0,20),"lock %.2f / 4 s"%float(s.get("lock",0.)))
 if on("hunt"):lines.append("Hunt %.1f / peak %.1f"%[Hunt.view(sim).hunt,console.metrics.hunt_peak])
 if on("noise"):ring(sim.units[0].pos,sim.motion_radius(0),Color(1.,.7,.2,.7))
 if on("endurance"):
  lines.append("Oxygen %.1f / %.0fs life support / hull %.1f"%[sim.oxygen,console.metrics.get("oxygen_seconds",0.),sim.hull])
  for u in sim.units:lines.append("%s endurance %.1f"%[u.name,float(u.get("battery",sim.oxygen))])
 if on("cargo"):
  for i in sim.units.size():
   var budget=console.State.Equipment.budget(sim.mission.get("launch_equipment",{}),i)
   var carried=preload("res://src/simulation/module_recovery.gd").carried(sim,i)
   lines.append("%s: modules %d / winch places %d / fitted cargo %.2f"%[sim.units[i].name,carried,console.Racks.winch_capacity(sim.mission,i),float(budget.cargo)])
 if on("chart"):
  for chart in sim.depth_charts.values():
   if chart==null:continue
   for cell in chart.clear_cells:
    var at=ocean.screen_position(Vector2(cell)*40.)
    draw_rect(Rect2(at,Vector2.ONE*40.*ocean.world_scale),Color(.4,1.,.7,.35),false)
 for i in lines.size():text(Vector2(14,140+i*20),lines[i])
