extends "res://tests/chart_label_fit_ui_tests.gd"
# WP-99 (blind critics, 14 Nov): the folded camera strip takes only taps on its own OPEN button, a craft under it stays
# tappable; the order wheel's hit testing matches what it draws; unknown-area labels at one bearing share a label;
# the Hunt chip says why its stage changed. Real Main scene at the cover (2520x1080) and inner (2184x1968) screens,
# at normal and 150% text.
const Hunt=preload("res://src/simulation/hunt_pressure/hunt_pressure.gd")
const Recon=preload("res://src/simulation/recon_consequences.gd")
const Meter=preload("res://src/presentation/hunt_meter.gd")
const MeterTable=preload("res://src/presentation/hunt_meter/meter_table.gd")
const LeadLabels=preload("res://src/presentation/threat_read/lead_labels.gd")
const SCALES=[1.0,1.5]
func set_scale(game,value:float):
 var settings=Store.DEFAULTS.duplicate(true);settings.text_scale=value
 Settings.apply(settings,game);await settle()
func feed_case(shape:Vector2i,value:float):
 var game=await make_game(0,shape)
 await set_scale(game,value)
 for id in ["warning","sweep"]:
  if id not in game.hints_seen:game.hints_seen.append(id)
 var sim=game.sim;var ocean=game.ocean;var hud=game.mission_hud
 sim.paused=true;frame_photo(sim);sim.units[1].alive=true;sim.message=""
 game._refresh();await settle()
 var tag="%s text %.1f"%[str(shape),value]
 var feed=ocean.optical_feed
 check(feed.is_visible_in_tree() and not feed.compact,"the camera panel is open "+tag)
 var open_width:float=feed.size.x
 check(feed.mouse_filter==Control.MOUSE_FILTER_STOP and hud.blocks(feed.get_global_rect().get_center()),"the open panel owns a tap on its body "+tag)
 feed.compact=true;game._refresh();await settle()
 check(feed.mouse_filter==Control.MOUSE_FILTER_IGNORE,"the folded strip does not stop taps by itself "+tag)
 check(feed.size.x<=feed.compact_width()+1.0 and feed.size.x<open_width,"the folded strip is only as wide as its title and button need "+tag+" "+str(feed.size.x)+" vs "+str(open_width))
 var toggle_centre:Vector2=feed.global_position+feed.toggle_rect.get_center()
 check(hud.blocks(toggle_centre),"the OPEN button still owns its tap "+tag)
 var beside:=Vector2.INF
 var strip_ok:=true
 for fraction in [0.02,0.12,0.3,0.45]:
  var local:=Vector2(feed.size.x*fraction,feed.size.y*.5)
  if feed.toggle_rect.has_point(local):continue
  strip_ok=strip_ok and not feed.blocks_point(feed.global_position+local)
  if beside==Vector2.INF and not hud.blocks(feed.global_position+local):beside=feed.global_position+local
 check(strip_ok and beside!=Vector2.INF,"the rest of the folded strip lets a tap through to the chart "+tag)
 # A craft under the strip is tappable: the tap opens its orders and leaves the strip folded.
 sim.units[1].pos=ocean.map_position(beside-ocean.global_position);game._refresh();await settle()
 var before:bool=game.advanced_orders
 await tap(beside)
 check(not before and game.advanced_orders and feed.compact,"a tap on a craft under the folded strip reaches the craft, not the panel "+tag)
 hud.dismiss();sim.selected=0;game._refresh();await settle()
 check(feed.is_visible_in_tree() and feed.compact,"the strip is back after the craft order closes "+tag)
 await tap(feed.global_position+feed.toggle_rect.get_center())
 check(not feed.compact,"the OPEN button opens the panel "+tag)
 # The wheel: only what it draws takes a tap.
 await tap(game.ocean.global_position+ocean.screen_position(sim.units[0].pos))
 if game.advanced_orders and not hud.ring_buttons.is_empty() and not hud.has_meta(preload("res://src/presentation/status_text/status_view.gd").GRID):
  var middle:Vector2=hud.global_position+hud.center
  check(hud.sector_at(middle)==null,"the wheel's empty centre selects no segment "+tag)
  var corner:Vector2=middle+Vector2.ONE*(hud.ring_radius+hud.touch_height*.65)*.98
  check(hud.sector_at(corner)==null,"the wheel's empty corner selects no segment "+tag)
  check(hud.sector_at(middle+Vector2(0,-hud.ring_radius))!=null,"a point on the drawn ring selects a segment "+tag)
 game.queue_free();await settle()
func lead_case(shape:Vector2i):
 var game=await make_game(0,shape)
 var sim=game.sim;var ocean=game.ocean
 sim.paused=true;sim.sirens=[];game._refresh();await settle()
 var tag=str(shape)
 ocean.queue_redraw();await settle()
 var baseline:int=ocean.world_label_rects.size()
 var from:Vector2=sim.units[sim.selected].pos
 # Two unknown areas at one bearing (a few degrees apart) and one far from it.
 var near:=Vector2(0,-1)
 sim.mission["photo_hidden"]=[
  {"pos":from+near*700.0,"lead":{"alias":"UNKNOWN STRUCTURE","r":120.0,"off":Vector2.ZERO}},
  {"pos":from+near.rotated(deg_to_rad(2.0))*1100.0,"lead":{"alias":"UNKNOWN STRUCTURE","r":120.0,"off":Vector2.ZERO}}]
 ocean.chart_camera.fit();ocean._sync_camera();ocean.queue_redraw();await settle()
 var merged:int=ocean.world_label_rects.size()
 check(merged-baseline<=1,"two unknown areas at one bearing add at most one label plate "+tag+" "+str(merged-baseline))
 sim.mission["photo_hidden"].append({"pos":from+near.rotated(deg_to_rad(90.0))*700.0,"lead":{"alias":"UNKNOWN STRUCTURE","r":120.0,"off":Vector2.ZERO}})
 ocean.queue_redraw();await settle()
 var plates:Array=ocean.world_label_rects
 for n in plates.size():
  for m in range(n+1,plates.size()):check(not plates[n].grow(-.5).intersects(plates[m].grow(-.5)),"label plates do not overlap "+tag)
 game.queue_free();await settle()
func lead_group_rules():
 var c:=Color.WHITE
 var rows:=[{"pos":Vector2(1,1),"name":"UNKNOWN STRUCTURE","color":c,"bearing":91.0},{"pos":Vector2(2,2),"name":"UNKNOWN STRUCTURE","color":c,"bearing":92.0},{"pos":Vector2(3,3),"name":"UNKNOWN STRUCTURE","color":c,"bearing":144.0},{"pos":Vector2(4,4),"name":"OTHER","color":c,"bearing":91.0}]
 var groups:=LeadLabels.group(rows)
 check(groups.size()==3,"bearings 091 and 092 share one label; 144 and another name keep their own")
 check(LeadLabels.text(groups[0])=="UNKNOWN STRUCTURE · AREA ×2 · BRG 092" or LeadLabels.text(groups[0])=="UNKNOWN STRUCTURE · AREA ×2 · BRG 091","the shared label names its count and a bearing: "+LeadLabels.text(groups[0]))
 check(LeadLabels.text(groups[1])=="UNKNOWN STRUCTURE · AREA · BRG 144","a single area keeps its label")
 var wrap:=LeadLabels.group([{"pos":Vector2.ZERO,"name":"A","color":c,"bearing":359.0},{"pos":Vector2.ZERO,"name":"A","color":c,"bearing":2.0}])
 check(wrap.size()==1 and int(wrap[0].bearing)<=2 or int(wrap[0].bearing)>=359,"bearings across north share one label")
func chip(hud)->Button:
 return hud.find_child("HuntMeterButton",true,false) as Button
# The note breaks its own lines; its words are what is judged.
func flat(note:Label)->String:
 return note.text.replace("\n"," ")
func shown_note(hud)->Label:
 return hud.find_child("HuntMeterChange",true,false) as Label
func note_case(shape:Vector2i,value:float):
 var game=await make_game(6,shape)
 await set_scale(game,value)
 var hud=game.mission_hud;var sim=game.sim
 var tag="%s text %.1f"%[str(shape),value]
 game._refresh();await settle()
 check(shown_note(hud)==null or not shown_note(hud).visible,"no stage-change note before any change "+tag)
 Hunt.note(sim.mission,"EXPOSURE");Recon.action(sim.mission,50.0);Hunt.observe(sim,0.0)
 game._refresh();await settle()
 var note:Label=shown_note(hud);var button:Button=chip(hud)
 check(note!=null and note.visible and flat(note)=="SEARCHING: your shutter was heard","the stage change is explained: "+(note.text if note!=null else "none")+" "+tag)
 if note!=null and note.visible and button!=null:
  var area:=Rect2(game.global_position,game.size)
  check(area.encloses(note.get_global_rect()) and not note.get_global_rect().intersects(button.get_global_rect()),"the note sits inside the screen, clear of the chip "+tag)
  for other in hud.action_controls().values():
   if other.is_visible_in_tree():check(not note.get_global_rect().intersects(other.get_global_rect()),"the note stays clear of "+str(other.get_meta("action","control"))+" "+tag)
  if hud.alarm.visible:check(not note.get_global_rect().intersects(hud.alarm.get_global_rect()),"the note stays clear of a warning "+tag)
 sim.elapsed+=MeterTable.CHANGE_SECONDS+1.0;game._refresh();await settle()
 check(note==null or not note.visible,"the note leaves after its few seconds "+tag)
 sim.mission.reconnaissance.floor=0.0;sim.mission.reconnaissance.hunt=2.0;Hunt.observe(sim,0.0)
 game._refresh();await settle()
 note=shown_note(hud)
 check(note!=null and note.visible and flat(note)=="DORMANT: things have been quiet","a cooling change says it was quiet: "+(note.text if note!=null else "none")+" "+tag)
 game.queue_free();await settle()
func reason_rules():
 var view={"stage":"STIRRING"}
 check(Meter.change_text(view,"EXPOSURE")=="STIRRING: your shutter was heard","exposure reason wording")
 check(Meter.change_text(view,"COOLING")=="STIRRING: things have been quiet","cooling reason wording")
 check(Meter.change_text(view,"NOT A CAUSE")=="STIRRING: "+MeterTable.TEXT.reason_other,"an unknown cause still reads plainly")
func run():
 for arg in OS.get_cmdline_user_args():
  if arg.begins_with("--capture-dir="):capture_dir=arg.trim_prefix("--capture-dir=")
 lead_group_rules()
 reason_rules()
 var only:="";
 for arg in OS.get_cmdline_user_args():
  if arg.begins_with("--only="):only=arg.trim_prefix("--only=")
 for shape in shapes:
  for value in SCALES:
   if only in ["","feed"]:await feed_case(shape,value)
   if only in ["","note"]:await note_case(shape,value)
  if only in ["","lead"]:await lead_case(shape)
 print("PANEL TAPS LABELS NOTE UI CHECKS ",checks," FAILURES ",failures)
 quit(1 if failures else 0)
