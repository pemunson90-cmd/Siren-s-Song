extends RefCounted
# 126: read-only command wording and approach selection. No saved state or rules.
const Work=preload("res://src/presentation/work_task/work_task.gd")
const Racks=preload("res://src/equipment/tool_racks.gd")
const Tools=preload("res://src/equipment/field_tools.gd")
const Photo=preload("res://src/simulation/photo_capture.gd")

static func verb(o:Dictionary)->String:
 return Work.action_verb(o)

static func stock(sim,id:String)->int:
 return 0 if sim.selected>0 and id in Racks.QUIETUS_ONLY else Racks.count(sim,id)

static func brief_stock(racks:Dictionary)->String:
 var rows=[]
 for unit in 3:
  var counts=[]
  for id in Tools.ids():
   if id in Tools.field_ids() and not Tools.is_enabled(id):continue
   counts.append("%s %d"%[Racks.label(id),int(racks.get(Racks.UNITS[unit],{}).get(id,0))])
  rows.append(Work.NAMES[unit]+": "+" / ".join(counts))
 return "\n".join(rows)

static func launch_stock(host)->String:
 var q=host.tool_racks.get("quietus",{})
 return "NEXT DIVE / RETRY / %s / QUIETUS\nO₂ %d%% · DISRUPT %d · SURVEY %d"%[host.upgrade.to_upper(),host._loadout_stock(host.upgrade)[0],int(q.get("emp",0)),int(q.get("recon",0))]

static func recovery_name(sim)->String:
 var names=[]
 for corridor in sim.extraction_corridors():
  if corridor.pos.distance_to(sim.mission.extraction)<1.:names.append(str(corridor.name))
 return " / ".join(names) if not names.is_empty() else "RECOVERY MOUTH"

# Arguments contain public projections only. Do not look up an unseen object's
# true position. The measured chart certifies the whole hull footprint, not just
# an empty-looking pixel. Choose the closest reachable point to this craft.
static func approach(sim,target:Dictionary)->Dictionary:
 var u=sim.units[sim.selected]
 if not target.has("pos"):return {"ready":false,"reason":"Locate the work site first"}
 var bands=Work.bands_of(target)
 if u.band not in bands:return {"ready":false,"reason":"Needs %s before plotting work approach"%sim.Depth.NAMES[bands[0]]}
 if not u.transition.is_empty():return {"ready":false,"reason":"Finish changing depth first"}
 var reach=float(target.get("work_range",sim.Photo.reach(sim,sim.selected)))
 var chart=sim.depth_charts.get(u.band)
 var origin:Vector2=u.pos
 if sim.queue_mode and not u.route.is_empty():origin=u.route.back().pos
 if chart==null:return legacy_approach(sim,origin,target,reach)
 var points=[]
 if chart.is_clear(target.pos):points.append(target.pos)
 if chart.is_clear(origin) and origin.distance_to(target.pos)<=reach:points.append(origin)
 var tile=float(chart.TILE)
 for cell in chart.clear_cells:
  # The closest point in a certified cell can fit a 60m work reach even when
  # its centre does not. Stay just inside that cell at shared boundaries.
  var point=origin.clamp(Vector2(cell)*tile+Vector2.ONE*.01,(Vector2(cell)+Vector2.ONE)*tile-Vector2.ONE*.01)
  if point.distance_to(target.pos)<=reach:points.append(point)
  var toward=target.pos.clamp(Vector2(cell)*tile+Vector2.ONE*.01,(Vector2(cell)+Vector2.ONE)*tile-Vector2.ONE*.01)
  if toward.distance_to(target.pos)<=reach:points.append(toward)
 points.sort_custom(func(a,b):return origin.distance_squared_to(a)<origin.distance_squared_to(b))
 for point in points:
  if chart.point_blocked(point) or chart.known_path(origin,point).is_empty():continue
  # Match the existing route compiler too, without installing a program.
  if sim.player_path(origin,point).is_empty():continue
  return {"ready":true,"point":point,"reason":"Measured %s work point / %dm work range"%[sim.Depth.NAMES[u.band],roundi(reach)]}
 return {"ready":false,"reason":"No measured approach within %dm: survey another side on %s"%[roundi(reach),sim.Depth.NAMES[u.band]]}

# Opening legacy charts show their physical terrain. Require every part of the
# proposed approach to lie in already observed cells as well. Never certify cells.
static func legacy_approach(sim,origin:Vector2,target:Dictionary,reach:float)->Dictionary:
 var points=[]
 for cell in sim.known:
  if not sim.known[cell]:continue
  var point=Vector2(cell)*40.+Vector2(20,20)
  if point.distance_to(target.pos)<=reach:points.append(point)
 points.sort_custom(func(a,b):return origin.distance_squared_to(a)<origin.distance_squared_to(b))
 for point in points:
  var path=sim.player_path(origin,point)
  if path.is_empty():continue
  var start=origin;var measured=true
  for node in path:
   for step in maxi(1,ceili(start.distance_to(node.pos)/10.))+1:
    var p=start.lerp(node.pos,float(step)/maxi(1,ceili(start.distance_to(node.pos)/10.)))
    if not sim.known.get(Vector2i((p/40.).floor()),false):measured=false;break
   if not measured:break
   start=node.pos
  if measured:return {"ready":true,"point":point,"reason":"Observed MIDDLE approach / %dm work range"%roundi(reach)}
 return {"ready":false,"reason":"No measured approach within %dm: survey another side on MIDDLE"%roundi(reach)}

static func route_target(hud,key:String)->Dictionary:
 var sim=hud.host.sim
 if key=="route_here":
  var target=hud.subject.duplicate(true)
  if Work.pinnable(target):
   var o=Work.site(sim,{"index":int(target.index)})
   if Photo.stage(o)=="lead":return {} # Keep the public search area, never the hidden subject.
   target.merge(o,true)
  elif target.get("subkind","") in ["choir","glass_work"]:
   target["work_range"]=60.
   target["band"]=int(target.get("band",1))
  elif target.get("kind","")!="salvage":return {}
  if target.get("kind","")=="salvage":
   target["work_range"]=sim.salvage_context(target.item).get("range",60.)
   target["band"]=sim.Depth.cargo_band(sim,target.item)
  return target
 if key=="glass_route":
  var c=sim.glass_context()
  if c.is_empty():return {}
  var a=c.artifact
  return {"pos":a.pos,"band":a.band,"work_range":60.} if not a.is_empty() and a.state in ["site","wreck"] else {"pos":c.work_pos,"band":1,"work_range":60.}
 if key=="choir_route":
  var targets=preload("res://src/presentation/industrial_view.gd").targets(sim)
  if targets.is_empty():return {}
  var target=hud.subject.duplicate() if hud.subject.get("subkind","")=="choir" else targets[0].duplicate()
  target["work_range"]=60.
  return target
 return {}

static func route(hud,key:String)->void:
 var target=route_target(hud,key)
 if target.is_empty():
  if key=="route_here":hud.host._order("route",{"point":hud.subject.pos})
  return
 var result=approach(hud.host.sim,target)
 if result.ready:hud.host._order("route",{"point":result.point})
 else:hud.host.sim.message=result.reason;hud.host._refresh()

static func depth_reason(sim,direction:int)->String:
 var u=sim.units[sim.selected];var band=int(u.band)+direction
 if not u.alive:return "Craft lost"
 if band<0:return "Already SHALLOW"
 if band>2:return "Already DEEP"
 if not u.transition.is_empty():return "Depth change / %.1fs remaining"%u.transition.remaining
 if direction<0 and sim.Depth.SurvivorAscent.count(sim.mission,sim.selected)>0 and u.get("ascent_settle",0.)>0:return "Survivors settling / %.1fs"%u.ascent_settle
 if sim.Choir.towing(sim,sim.selected) or sim.mission.get("concealed_harbour",{}).get("carrier",-1)==sim.selected:return "Release physical tow first"
 return ""

static func local_reason(sim,c:Dictionary,band:int=-1)->String:
 var why=str(c.get("reason","Unavailable here"))
 var u=sim.units[sim.selected]
 if not c.get("ready",false) and ("depth" in why or "band" in why) and band>=0:
  return "Needs "+sim.Depth.NAMES[band] if u.band!=band else "Finish changing depth / %.1fs"%u.transition.remaining if not u.transition.is_empty() else "Settle on "+sim.Depth.NAMES[band]
 if not c.get("ready",false) and ("within" in why or "Reach" in why or "range" in why):
  if c.has("distance"):why+=" / %dm away"%roundi(c.distance)
  elif c.has("pos"):why+=" / %dm away"%roundi(u.pos.distance_to(c.pos))
 return why

static func work_band(info:Dictionary,c:Dictionary)->int:
 if not c.has("pos"):return -1
 var sites=info.get("sites",[]).duplicate()
 for key in ["load","artifact"]:
  if not info.get(key,{}).is_empty():sites.append(info[key])
 for site in sites:
  if site.has("band") and site.pos.distance_to(c.pos)<1.:return int(site.band)
 return -1

static func camera_busy(sim)->bool:
 var id=sim.selected
 return not sim.module_recovery_status().jobs[id].is_empty() or sim.Cache.blocks(sim,"camera") or sim.Delivery.busy(sim,id) or sim.Witness.busy(sim,id) or sim.Glass.busy(sim,id) or sim.Choir.busy(sim,id) or sim._warning_chain_busy(id)

static func projected_reasons(hud)->void:
 var sim=hud.host.sim
 var plant=preload("res://src/presentation/warning_chain_view.gd").context(sim)
 for row in plant.get("actions",[]):
  var context=row.duplicate()
  var station="inlet" if row.id in ["connect","backup"] else "panel"
  for known in plant.get("stations",[]):
   if known.id==station:context["pos"]=known.pos
  hud.extra["chain_"+row.id].tooltip_text=local_reason(sim,context,1)
 var shelf=preload("res://src/presentation/shelf_habitat_view.gd").context(sim)
 if not shelf.is_empty():
  hud.extra.shelf_alarm.tooltip_text=local_reason(sim,shelf.alarm)
  for row in shelf.galleries:
   if row.id==hud.subject.get("site",""):hud.extra.shelf_warn.tooltip_text=local_reason(sim,row.action)
 var wake=preload("res://src/presentation/wake_crossing_view.gd").context(sim)
 if not wake.is_empty():hud.extra.wake_playback.tooltip_text=local_reason(sim,wake)
 var tender=preload("res://src/presentation/rendezvous_view.gd").context(sim)
 if not tender.is_empty():hud.extra.rendezvous_release.tooltip_text=local_reason(sim,tender.control)
 var recipient=sim.warning_recipient_status()
 if not recipient.is_empty():
  hud.extra.warning_gate.tooltip_text=local_reason(sim,recipient.actions.gate)
  hud.extra.warning_exposed.tooltip_text=local_reason(sim,recipient.actions.depart)
  hud.extra.warning_sheltered.tooltip_text="Open the service gate first" if not recipient.gate.opened else local_reason(sim,recipient.actions.depart)
 var concealed=sim.concealed_status()
 if concealed.get("known",false):
  hud.extra.concealed_attach.tooltip_text=concealed.actions.reason
  hud.extra.concealed_release.tooltip_text="Select the craft carrying this tow" if concealed.carrier>=0 else "No physical tow attached"
  hud.extra.concealed_seat.tooltip_text="Attach the tow first"
  for row in concealed.actions.seats:
   if row.id==hud.subject.get("seat",""):hud.extra.concealed_seat.tooltip_text=local_reason(sim,row)
 if not sim.blackwater_delivery_status().is_empty():
  for pair in [[1,"blackwater_a"],[2,"blackwater_b"],[sim.selected,"blackwater_handoff"]]:hud.extra[pair[1]].tooltip_text=local_reason(sim,sim.blackwater_handoff_context(pair[0]))

# Buttons keep a short action and one compact requirement. Full public refusal
# text stays available to touch through the existing popup activation path.
static func reason_token(reason:String)->String:
 var lower=reason.to_lower()
 if "quietus" in lower:return "QUIETUS ONLY"
 if "zero stock" in lower:return "NONE ABOARD"
 if "no measured approach" in lower:return "SURVEY SIDE"
 if "needs " in lower:
  for band in ["SHALLOW","MIDDLE","DEEP"]:
   if band.to_lower() in lower:return "NEEDS "+band
 if "already " in lower:return reason.to_upper()
 if "changing depth" in lower or "depth change" in lower:return "CHANGING DEPTH"
 if "settle below 2" in lower:return "SETTLE <2m/s"
 if "settling" in lower or "settle" in lower:return "SETTLING"
 # Prefer current distance to the work range when both are projected.
 for word in reason.replace("/"," ").split(" ",false):
  if word.ends_with("m") and word.trim_suffix("m").is_valid_int():
   if word+" away" in reason:return word
 if "recovery range" in lower:return reason.get_slice(" / ",0)
 if "heading" in lower or "bearing" in lower or "face " in lower:return "ALIGN BEARING"
 if "speed" in lower or "slow" in lower:return "SLOW DOWN"
 if "recharg" in lower:return "RECHARGING"
 if "active work" in lower or "busy" in lower:return "FINISH WORK"
 if "tow" in lower:return "CHECK TOW"
 if "arrivals" in lower:return "NO ARRIVALS"
 if "craft lost" in lower:return "CRAFT LOST"
 if "locate" in lower or "unknown" in lower:return "LOCATE SITE"
 if "collision damage" in lower:return "NEEDS DAMAGE"
 if "active"==lower:return "ACTIVE"
 if "lock" in lower:
  for lock in ["A","B","C"]:
   if "lock "+lock.to_lower() in lower:return "AFTER LOCK "+lock
  return "AFTER LOCK"
 if "gate" in lower:return "CHECK GATE"
 if "within" in lower or "reach" in lower or "range" in lower:return "OUT OF RANGE"
 return "CHECK STATUS"

static func short_label(base:String)->String:
 var line=base.get_slice("\n",0)
 var second=base.get_slice("\n",1)
 if second.is_valid_int():return line+" "+second
 if base.begins_with("ROUTE TO\n"):return "ROUTE"
 # Field tools already carry count and action on line one; their original
 # second line is availability. Preserve both words of other action labels.
 if not line.is_empty() and line.get_slice(" ",line.get_slice_count(" ")-1).is_valid_int():return line
 var label=base.replace("\n"," ")
 if label=="TRANSFER TO QUIETUS":return "TRANSFER"
 if label=="RESTORE SERVICE":return "RESTORE"
 if label=="OPEN LOCAL GATE":return "OPEN GATE"
 if label.begins_with("RECOVER 4s"):return "RECOVER"
 if label.begins_with("RELEASE BERTH"):return "RELEASE BERTH"
 return label

static func reason_button(button,reason:String,inline:bool=false)->void:
 var previous=str(button.get_meta("truthful_render",""))
 var base=str(button.get_meta("truthful_base",button.text)) if button.text==previous else button.text
 button.set_meta("truthful_base",base)
 button.text=base.replace("\n"," ") if inline else base
 if button.disabled and not reason.is_empty():
  var label=short_label(base);var token=reason_token(reason)
  if inline:button.text=label+" / "+token
  else:
   # Two newline-delimited lines can still wrap to four on the native radial.
   # Keep the original caption when an extra token would grow its text. The
   # full refusal always remains available on tap, even without a token.
   var font=button.get_theme_font("font");var font_size=button.get_theme_font_size("font_size")
   var width=maxf(1.,button.size.x-4.)
   if font.get_string_size(token,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size).x>width:
    token=token.trim_prefix("NEEDS ").trim_prefix("CHECK ")
   if font.get_string_size(label,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size).x<=width and font.get_string_size(token,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size).x<=width:
    button.text=label+"\n"+token
 button.set_meta("truthful_render",button.text)
 button.set_meta("truthful_reason",reason if button.disabled else "")
 button.tooltip_text=reason if button.disabled else ""

static func recovery_label(sim)->String:
 var name=recovery_name(sim).split(" / ")[0].to_upper()
 for pair in [["NORTH","N."],["SOUTH","S."],["EAST","E."],["WEST","W."]]:name=name.replace(pair[0],pair[1])
 name=name.replace(" RECOVERY","").replace(" MOUTH","")
 name=name.replace("REACH","RCH").replace("COLLAR","CLR").replace(" ","")
 var distance=roundi(sim.units[0].pos.distance_to(sim.mission.extraction))
 # Keep exact metres on distant mouths without wrapping the native radial.
 # Direction plus the mouth's initial remains identifiable in the full chooser.
 name=name.left(3 if distance>=1000 else 5)
 return "WITHDRAW\n%s%dm"%[name,distance]

static func activate(hud,button)->void:
 if not button.disabled:
  if hud.has_meta("truthful_feedback"):
   hud.remove_meta("truthful_feedback")
   hud.intent.visible=not hud.host.advanced_orders
  button.pressed.emit()
  return
 var reason=str(button.get_meta("truthful_reason",button.tooltip_text))
 if reason.is_empty():reason="Unavailable here"
 hud.host.sim.message=reason
 hud.set_meta("truthful_feedback",{"reason":reason,"page":hud.page,"unit":hud.host.sim.selected})
 hud.host._refresh()

static func apply(hud)->void:
 var sim=hud.host.sim;var u=sim.units[sim.selected]
 projected_reasons(hud)
 hud.extra.arrivals.disabled=preload("res://src/presentation/expedition_view.gd").measurements(sim,-1 if hud.host.advanced_orders else sim.selected).is_empty()
 for key in ["route_here","glass_route","choir_route"]:
  if not hud.extra[key].is_visible_in_tree():continue
  var target=route_target(hud,key)
  if not target.is_empty():
   var result=approach(sim,target)
   hud.extra[key].disabled=not result.ready
   hud.extra[key].tooltip_text=result.reason
  elif key=="route_here":hud.extra[key].disabled=false;hud.extra[key].tooltip_text=""
 var glass=sim.glass_context()
 for action in glass.get("actions",{}):hud.extra["glass_"+action].tooltip_text=local_reason(sim,glass.actions[action],int(glass.artifact.get("band",1)) if action=="recover" else 1)
 var choir=sim.choir_context()
 for action in choir.get("actions",{}):hud.extra["choir_"+action].tooltip_text=local_reason(sim,choir.actions[action],work_band(choir,choir.actions[action]))
 if hud.subject.get("kind","")=="salvage":hud.extra.salvage.tooltip_text=local_reason(sim,sim.salvage_context(hud.subject.item),sim.Depth.cargo_band(sim,hud.subject.item))
 for pair in [["depth_up",-1],["depth_down",1]]:
  var why=depth_reason(sim,pair[1]);hud.extra[pair[0]].disabled=not why.is_empty();hud.extra[pair[0]].tooltip_text=why
 hud.extra.glass_withdraw.text=recovery_label(sim).replace("\n"," ") if hud.text_scale>=1.5 else recovery_label(sim)
 var q=sim.units[0]
 hud.extra.glass_withdraw.tooltip_text="Quietus required" if sim.selected!=0 else "Needs MIDDLE" if q.band!=1 else "Finish changing depth" if not q.transition.is_empty() else "%dm / 65m recovery range"%roundi(q.pos.distance_to(sim.mission.extraction)) if q.pos.distance_to(sim.mission.extraction)>65 else "Settle below 2m/s" if q.vel.length()>=2 else ""
 hud.extra.glass_withdraw.disabled=not hud.extra.glass_withdraw.tooltip_text.is_empty()
 var context=sim.camera_context();var target=int(context.get("target",-1))
 if hud.page=="object" and hud.subject.get("kind","")=="objective" and int(hud.subject.get("index",-1))>=0:target=int(hud.subject.index)
 var sites=sim.observable_sites()
 if target>=0 and target<sites.size() and preload("res://src/presentation/operation_instruments.gd").operation(sim,target).is_empty() and sites[target].get("site_id","")!="rendezvous" and hud.host.order_buttons.camera.text not in ["WATCH\nORDERS","PLANT\nCONTROLS","WITNESS\nWINCH","GATE\nCONTROLS","RECIPIENT\nCONTROLS"]:
  hud.host.order_buttons.camera.text=verb(sites[target])
 if target>=0 and target<sites.size() and sites[target].has("glass_effect"):
  for label in [hud.intent,hud.instrument_info,hud.host.detail_label]:label.text=label.text.replace("Camera exposure","Machinery work").replace("CAMERA exposure","Machinery work")
 # A chosen transmission sector owns its refusal even when the generic camera
 # currently resolves a different nearby receiver.
 if target>=0 and target<sites.size() and sites[target].get("own_origin",false) and hud.host.order_buttons.camera.disabled:
  var site=sites[target]
  hud.host.order_buttons.camera.tooltip_text="Quietus required" if sim.selected!=0 else "Craft lost" if not u.alive else "Finish changing depth" if not u.transition.is_empty() else "Needs MIDDLE" if u.band!=1 else "Enter the charted transmission sector" if not site.get("origin_region",Rect2()).has_point(u.pos) else "Settle below 12m/s" if u.vel.length()>=12 else "Finish this craft's active work first"
 if hud.host.order_buttons.camera.disabled:
  if hud.host.order_buttons.camera.tooltip_text.is_empty():hud.host.order_buttons.camera.tooltip_text="Finish this craft's active work first" if camera_busy(sim) else str(context.get("text","Locate a site first"))
 var buttons=hud.extra.duplicate()
 buttons.merge(hud.host.order_buttons)
 for key in buttons:
  var b=buttons[key];var why=str(b.tooltip_text)
  if key in Tools.ids() and b.disabled:
   why="Quietus only" if sim.selected>0 and key in Racks.QUIETUS_ONLY else "Zero stock on "+Work.NAMES[sim.selected] if stock(sim,key)<=0 else b.text.get_slice("\n",1) if key in Tools.field_ids() else why
  if key=="arrivals" and b.disabled:why="No received arrivals on this craft" if not hud.host.advanced_orders else "No received fleet arrivals"
  if key=="sonar_emit" and b.disabled:why="Finish changing depth" if not u.transition.is_empty() else "Sonar recharging / %.1fs"%sim.ping_time
  if key=="glass_transfer" and b.disabled:why="Material must be aboard a drone"
  if b.disabled and why.is_empty():why="Craft lost" if not u.alive else "Quietus required" if key=="all_stop" else "No local work available" if key.ends_with("route") else "Unavailable here"
  if key=="glass_withdraw":
   b.set_meta("truthful_reason",why);b.tooltip_text=why
  else:reason_button(b,why,hud.text_scale>=1.5 and hud.host.advanced_orders and key!="choose_object")
 # ARRIVALS owns its sheet after all generic sampling/machinery status writes.
 if hud.page=="signals":hud.instrument_info.text=preload("res://src/presentation/expedition_view.gd").detail(sim,hud.subject.get("receiver",-1))
 # A grey tap owns the existing status line until a command changes the
 # message or the player changes context, including during active machinery.
 var feedback=hud.get_meta("truthful_feedback",{})
 if feedback.get("reason","")==sim.message and feedback.get("page","")==hud.page and feedback.get("unit",-1)==sim.selected:
  hud.intent.text=Work.NAMES[sim.selected]+" / "+sim.message
  hud.intent.show()
 elif hud.has_meta("truthful_feedback"):
  hud.remove_meta("truthful_feedback")
  hud.intent.visible=not hud.host.advanced_orders
