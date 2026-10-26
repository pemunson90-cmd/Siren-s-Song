extends RefCounted
# ARCH2 contract: registry dispatches this refresh block and world drawing
# at their original positions. Existing picking/input and helpers stay here.
# Revert this PR to restore the two direct call sites and original HUD block.
static func applies(sim)->bool:return not context(sim).is_empty()
static func build_panel(hud)->void:
 var sim=hud.host.sim
 var wake=context(sim)
 if not wake.is_empty():
  hud.extra.wake_playback.disabled=not wake.ready
  hud.extra.wake_playback.text="PLAYING\n%ds LEFT"%ceili(wake.remaining) if wake.active else "PLAYBACK\nSPENT" if wake.used else "PLAY OLD LOOP\nONCE ·15s"
  if hud.subject.get("subkind","")=="wake_repeater":
   hud.instrument_info.text=detail(sim)
   if hud.page=="inspect":hud.host.title_label.hide();hud.host.detail_label.hide()
static func context(sim)->Dictionary:return sim.wake_context() if sim!=null and sim.has_method("wake_context") else {}
static func replaces_site(sim,site:Dictionary)->bool:return sim.mission.get("id")==9 and site.get("site_id","")=="wake_repeater"
static func subject(sim,value:Dictionary)->Dictionary:
 var c=context(sim)
 if not c.get("known",false):return {}
 var sites=sim.observable_sites();var index=value.get("index",-1)
 if value.get("subkind","")!="wake_repeater" and not (index>=0 and index<sites.size() and replaces_site(sim,sites[index])):return {}
 return {"kind":"objective","subkind":"wake_repeater","name":"RIG BEACON LOOP","pos":c.pos}
static func pick(view,sim,point:Vector2,touch:float)->Dictionary:
 var c=context(sim)
 if c.get("known",false) and point.distance_to(view.screen_position(c.pos))<=maxf(touch*.5,38*view.world_scale):return subject(sim,{"subkind":"wake_repeater"})
 return {}
static func detail(sim)->String:
 var c=context(sim)
 if not c.get("known",false):return ""
 return "RIG BEACON LOOP · ONE USE\n"+("PLAYBACK TIMER ·%ds from your local order\n"%ceili(c.remaining) if c.active else "")+c.reason+"\n\n"+c.account+"\n\nAny bare craft can connect within65m, clear line, below2m/s. One1100m open-water emission lasts15s; basalt can weaken or block it. Ordinary listeners may investigate its water, but current sight and louder evidence take priority. No guard response is guaranteed. Time it against your own crossing, then recover the operator. A watch with sight can report after2 uninterrupted seconds; cover or disruption cancels. A reached peer searches a coarse old point, not your live position. The longer outer water remains available without playback or tools."
static func draw(view,sim=null)->void:
 if sim==null:sim=view.sim
 var c=context(sim)
 if not c.get("known",false):return
 var p:Vector2=c.pos;var scale=maxf(.01,view.world_scale)
 var live=not sim.passive_receivers(p).is_empty() or preload("res://src/simulation/world_region.gd").survey_visible(sim,p)
 # Empty pressure berths and a spent/charged resonator are measured fixed
 # hardware. Their working lights animate only under current local observation.
 for n in 4:
  var berth=Rect2(p+Vector2(65+n*35,-90),Vector2(27,180))
  view.draw_rect(berth,Color("112932"));view.draw_rect(berth,Color("496463"),false,2./scale)
  for rib in 5:view.draw_line(berth.position+Vector2(0,20+rib*35),berth.position+Vector2(27,20+rib*35),Color("284d53"),3.)
 view.draw_line(p-Vector2(35,0),p+Vector2(210,0),Color("5c7770"),5.)
 view.draw_rect(Rect2(p-Vector2(32,42),Vector2(64,84)),Color("193740"))
 var color=Color("dbb97a") if not c.used else Color("718c86")
 for n in 5:
  var x=p.x+(n-2)*13;view.draw_line(Vector2(x,p.y-32),Vector2(x,p.y+32),color,4.)
 if live:
  view.draw_circle(p+Vector2(0,-48),5,Color("edc47c") if not c.used else Color("647b76"))
  if c.active:
   var radius=40+fposmod(sim.elapsed*55,100)
   view.draw_arc(p,radius,0,TAU,48,Color(.87,.71,.4,1.-(radius-40)/100.),2./scale)
 view._label(p+Vector2(-105,-100),"OLD LOOP ·%ds"%ceili(c.remaining) if live and c.active else "EMPTY BERTHS · ONE PLAYBACK" if not c.used else "OLD LOOP · PLAYBACK SPENT",color,maxi(5,roundi(view.feedback_font_size/scale)))
