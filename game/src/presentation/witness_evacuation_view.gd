extends Control
# Public custody and local readiness only. This presenter never advances work,
# discovers a berth, changes progression or infers an unseen evacuation fleet.
const KIT=preload("res://src/equipment/equipment_catalog.gd")
const AMBER=Color("e3bd7c")
const TEAL=Color("8ad6c9")
var arrival_data:Dictionary={}

static func status(sim)->Dictionary:
 return sim.witness_status() if sim!=null and sim.has_method("witness_status") else {}
static func work(sim,unit:int)->Dictionary:
 var jobs=status(sim).get("jobs",[])
 if unit<0 or unit>=jobs.size() or jobs[unit].is_empty():return {"unit":-1}
 var result=jobs[unit].duplicate(true);result.unit=unit;return result
static func carries(sim,unit:int)->bool:
 var loads=status(sim).get("cargo",[])
 return unit>=0 and unit<loads.size() and not loads[unit].is_empty()
static func cargo(sim,unit:int)->String:
 return "LIVING WITNESS · LAND" if carries(sim,unit) else ""
static func task(sim,unit:int)->String:
 var job=work(sim,unit)
 return "WINCH %d%% · WITNESS"%clampi(floori(job.elapsed/maxf(.01,job.duration)*100),0,100) if job.unit>=0 else ""
static func active(sim,unit:int)->bool:return work(sim,unit).unit>=0 or carries(sim,unit)
static func site(sim)->Dictionary:
 if status(sim).is_empty():return {}
 for candidate in sim.salvage_sites():
  if candidate.get("witness",false):return candidate
 return {}
static func site_for_item(sim,item:String)->bool:
 var target=site(sim)
 return not target.is_empty() and target.item==item
static func replaces_site(sim,objective:Dictionary)->bool:
 return not status(sim).is_empty() and objective.get("site_id","")=="witness_packet"
static func harbour_subject(sim,subject:Dictionary)->bool:
 var info=status(sim)
 return not info.is_empty() and subject.get("subkind","")=="corridor" and subject.get("pos") ==info.harbour.pos
static func site_lines(sim,target:Dictionary)->Array:
 var info=status(sim);var lines=["OCCUPIED POD","LIVING WITNESS"]
 if info.get("capsule",{}).get("state","")=="salvage":lines[0]="OWN TRANSPORT WRECK"
 for module in sim.module_recovery_status().get("modules",[]):
  if module.state=="salvage" and module.pos.distance_to(target.pos)<=1:
   lines.append(KIT.ITEMS.get(module.item,{"name":module.item}).name.to_upper())
 return lines
static func salvage_detail(sim,item:String)->String:
 var target=site(sim)
 if target.is_empty():return detail(sim)
 return "\n".join(site_lines(sim,target))+"\n"+sim.salvage_context(item).reason+"\nONE WINCH · 4s · within 60m · clear line · below 2m/s\nAUDIBLE · 520m open-water estimate\nThe living witness rides this real craft. LAND WITNESS at southeast harbour; Quietus must also recover. Colocated kit shares this winch and stays inactive cargo."
static func detail(sim)->String:
 var info=status(sim)
 if info.is_empty():return ""
 var lines=[info.text];var pod=info.capsule
 if not pod.is_empty():
  if pod.state=="carried":lines.append("ACTUAL TRANSPORT · "+sim.units[pod.carrier].name)
  elif pod.state=="salvage":lines.append("OWN LOST TRANSPORT · same sealed occupied pod")
  elif pod.state=="landed":lines.append("LANDED BY · "+sim.units[pod.landed_by].name)
 lines.append("LAND WITNESS · selected carrier within 60m of southeast harbour, clear line, below 2m/s. Quietus recovery is separate.")
 lines.append(sim.witness_context().land.reason)
 return "\n".join(lines)
static func touch_rects(view,sim,touch:float)->Array:
 var target=site(sim)
 if target.is_empty():return []
 var radius=maxf(touch*.5,30*view.world_scale)
 return [Rect2(view.screen_position(target.pos)-Vector2.ONE*radius,Vector2.ONE*radius*2)]
static func pick(view,sim,point:Vector2,touch:float)->Dictionary:
 var target=site(sim);var boxes=touch_rects(view,sim,touch)
 if target.is_empty() or boxes.is_empty() or not boxes[0].has_point(point):return {}
 return {"kind":"salvage","item":target.item,"name":"OCCUPIED WITNESS CAPSULE","pos":target.pos}
static func draw_world(view,sim)->void:
 var info=status(sim)
 if info.is_empty():return
 var scale=maxf(.01,view.world_scale);var harbour:Vector2=info.harbour.pos
 # The refuge is briefed geography; the berth is drawn only after measurement.
 for side in [-1,1]:
  var edge=harbour+Vector2(-38,side*32)
  view.draw_line(edge,edge+Vector2(76,0),Color("547e7d"),3/scale)
  view.draw_line(edge,edge+Vector2(0,-side*12),TEAL,2/scale)
 var pod=info.capsule
 if pod.is_empty() or pod.state=="carried":return
 if pod.state=="at_berth":
  for side in [-1,1]:view.draw_line(pod.pos+Vector2(-34,side*24),pod.pos+Vector2(34,side*24),Color("698b88"),3/scale)
 _pod(view,pod.pos,1.,scale)
static func draw_carried(view,sim,unit:int)->void:
 if not carries(sim,unit):return
 # Caller owns the real craft's rotation and position, exactly like its hull.
 var offset=Vector2(-7,26) if unit==0 else Vector2(-3,17)
 view.draw_line(Vector2(-18,0),offset+Vector2(-12,0),Color("698b88"),2)
 _pod(view,offset,.65 if unit==0 else .48,1.)
static func _pod(view,pos:Vector2,extent:float,scale:float)->void:
 var points=PackedVector2Array()
 for p in [Vector2(-25,-10),Vector2(18,-10),Vector2(26,-4),Vector2(26,4),Vector2(18,10),Vector2(-25,10),Vector2(-30,4),Vector2(-30,-4),Vector2(-25,-10)]:points.append(pos+p*extent)
 view.draw_colored_polygon(points,Color("29494d"));view.draw_polyline(points,AMBER,maxf(1.,1.6/scale))
 view.draw_rect(Rect2(pos+Vector2(-10,-6)*extent,Vector2(16,12)*extent),Color("102830"))
 view.draw_circle(pos+Vector2(-2,-1)*extent,3*extent,TEAL)
 view.draw_line(pos+Vector2(-2,2)*extent,pos+Vector2(-2,5)*extent,TEAL,maxf(1.,1.3/scale))
 for x in [-20,13]:view.draw_line(pos+Vector2(x,-9)*extent,pos+Vector2(x,9)*extent,Color("95a38b"),maxf(1.,1.2/scale))
static func arrival(main)->void:
 var info=status(main.sim)
 if info.is_empty() or not info.landed:return
 var scene=load("res://src/presentation/witness_evacuation_view.gd").new()
 scene.name="WitnessArrival";scene.arrival_data=info.capsule.duplicate(true)
 scene.custom_minimum_size=Vector2(0,main.ui_touch_height*1.65);scene.mouse_filter=Control.MOUSE_FILTER_IGNORE
 main.panel_box.add_child(scene)
 main._menu_text("WITNESS LANDED · "+main.sim.units[info.capsule.landed_by].name+"\nTHIS RECOVERY · CONCEALED HARBOUR",20)
 if main.sim.outcome!="won":main._menu_text("The passenger reached harbour. Quietus did not recover; this dive grants no new campaign arrival.",17)
 elif info.capsule.rescues>0:main._menu_text("Same occupied pod rescued %d time(s) after actual transport loss."%info.capsule.rescues,17)
func _ready():resized.connect(queue_redraw)
func _draw():
 if arrival_data.is_empty():return
 draw_rect(Rect2(Vector2.ZERO,size),Color("081d27"))
 var scale=minf(size.x/560.,size.y/130.);var center=Vector2(size.x*.5,size.y*.5)
 draw_set_transform(center,0,Vector2.ONE*scale)
 # A sheltered berth with the one observed passenger, not departing vessels.
 for side in [-1,1]:
  draw_colored_polygon(PackedVector2Array([Vector2(side*275,-70),Vector2(side*185,-70),Vector2(side*155,-25),Vector2(side*175,65),Vector2(side*275,70)]),Color("18363e"))
  draw_line(Vector2(-68,side*26),Vector2(68,side*26),Color("6f9990"),4)
 _pod(self,Vector2.ZERO,1.7,1.)
 draw_arc(Vector2.ZERO,52,.12,PI-.12,32,Color("548d83"),1.5)
 draw_set_transform(Vector2.ZERO,0,Vector2.ONE)
