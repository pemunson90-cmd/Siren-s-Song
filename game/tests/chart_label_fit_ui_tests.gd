extends "res://tests/stable_board_ui_support.gd"
# WP-78: every chart label in the dive is drawn whole inside the visible chart, clear of the camera panel and of the
# HUD (nothing cut by an edge, nothing under a panel), and no two label plates overlap. Real Main scene, camera panel open,
# the craft panned toward each edge of the chart, at the cover screen (2520x1080) and the inner screen (2184x1968).
# The shutter ring and its IN SHUTTER REACH names are the labels a critic saw cut ("HUTTER REACH").
const ThreatRead=preload("res://src/presentation/threat_read/threat_read.gd")
const ThreatTable=preload("res://src/presentation/threat_read/threat_read_table.gd")
# Fraction of the chart the craft is moved toward: centre, then each edge and corner.
const SHIFTS=[Vector2(0,0),Vector2(-.42,0),Vector2(.42,0),Vector2(0,-.42),Vector2(0,.42),Vector2(-.42,-.42),Vector2(.42,.42),Vector2(-.42,.42),Vector2(.42,-.42)]
var shapes=[Vector2i(2520,1080),Vector2i(2184,1968)]
func frame_photo(sim):
 # The photo_fixture of threat_read_tests: Quietus 150 m from a spire, facing it, with a known contact inside the ring.
 sim.sirens=[];sim.units[1].alive=false;sim.units[2].alive=false
 var spire=Vector2(1300,300);var facing=2.74
 var q=sim.units[0];q.pos=spire+Vector2.from_angle(facing+PI)*150;q.angle=facing;q.vel=Vector2.ZERO;q.band=1;q.transition={}
 sim._use_band(1)
 sim.contacts={0:{"pos":q.pos+Vector2(300,0),"time":sim.elapsed,"mode":"PATROL","lock":0.,"target":-1,"type":"patroller","band":1,"angle":0.,"source":"optical"},
  1:{"pos":q.pos+Vector2(-250,120),"time":sim.elapsed,"mode":"PATROL","lock":0.,"target":-1,"type":"patroller","band":1,"angle":0.,"source":"optical"}}
func label_case(shape:Vector2i,shift:Vector2):
 var game=await make_game(0,shape)
 for id in ["warning","sweep"]:
  if id not in game.hints_seen:game.hints_seen.append(id)
 var sim=game.sim;var ocean=game.ocean
 sim.paused=true;frame_photo(sim);sim.message=""
 game._refresh();await settle()
 var tag="%s shift %s"%[str(shape),str(shift)]
 ocean.chart_camera.mode="follow";ocean._sync_camera()
 var chart=ocean.stable_chart_rect()
 ocean.pan_chart(Vector2(chart.size.x*shift.x,chart.size.y*shift.y)*-1.);game._refresh();await settle()
 ocean.queue_redraw();await settle()
 var reach=ThreatRead.shutter_reach(sim)
 check(not reach.is_empty(),"a shutter reach is drawn "+tag)
 var plates:Array=ocean.world_label_rects
 var bounds:Rect2=ocean.stable_chart_rect()
 var covers:Array=ocean.ui_blocked_rects.duplicate()
 if game.mission_hud!=null:covers.append_array(game.mission_hud.threat_rects().map(func(r):return Rect2(r.position-ocean.global_position,r.size)))
 if ocean.optical_feed!=null and ocean.optical_feed.is_visible_in_tree():covers.append(ocean.optical_feed.get_rect())
 covers.append_array(ocean.card_blocked_rects())  # WP-129
 for n in plates.size():
  var plate:Rect2=plates[n]
  check(bounds.encloses(plate),"label plate is whole inside the chart, not in the camera lane %s: %s"%[tag,str(plate)])
  check(not covers.any(func(r):return r.intersects(plate)),"label plate clears every panel %s: %s"%[tag,str(plate)])
  for m in range(n+1,plates.size()):
   check(not plate.grow(-.5).intersects(plates[m].grow(-.5)),"label plates do not overlap %s %s %s"%[tag,str(plate),str(plates[m])])
 print("CHART LABELS ",tag," plates=",plates.size())
 game.queue_free();await settle()
# WP-129: a contact-heavy dive (six held contacts round Quietus) with a tip card, an UNDO chip and a one-off notice over the
# chart: no two drawn labels overlap, and no label overlaps a card, the notice, a HUD rectangle or a craft.
func crowd_case(shape:Vector2i):
 var game=await make_game(0,shape)
 for id in ["warning","sweep"]:
  if id not in game.hints_seen:game.hints_seen.append(id)
 var sim=game.sim;var ocean=game.ocean
 sim.paused=true;frame_photo(sim);sim.message=""
 var q=sim.units[0].pos
 for n in 6:
  sim.contacts[10+n]={"pos":q+Vector2.from_angle(TAU*n/6.0)*Vector2(180+30*n,120),"time":sim.elapsed,"mode":"SEARCH","lock":0.,"target":-1,"type":"sweeper","band":1,"angle":0.,"source":"heard"}
 game._refresh();await settle()
 ocean.chart_camera.mode="follow";ocean._sync_camera()
 var tag="crowd %s"%str(shape)
 var chart=ocean.stable_chart_rect()
 ocean.card_rects=[Rect2(chart.position+Vector2(40,chart.size.y*.15),Vector2(chart.size.x*.2,110)),Rect2(chart.position+Vector2(chart.size.x*.3,chart.size.y*.55),Vector2(chart.size.x*.15,90))]
 ocean.notice_rects=[Rect2(chart.position+Vector2(chart.size.x*.45,chart.size.y*.12),Vector2(chart.size.x*.2,80))]
 ocean.queue_redraw();await settle()
 var plates:Array=ocean.world_label_rects
 check(plates.size()>=3,"the crowded dive draws several labels "+tag)
 var covers:Array=ocean.ui_blocked_rects+ocean.card_blocked_rects()+ocean.own_craft_rects()
 for n in plates.size():
  var plate:Rect2=plates[n]
  check(not covers.any(func(r):return r.intersects(plate)),"a label overlaps no card, notice, HUD rectangle or craft %s: %s"%[tag,str(plate)])
  for m in range(n+1,plates.size()):
   check(not plate.grow(-.5).intersects(plates[m].grow(-.5)),"no two labels overlap %s"%tag)
 # The notice slot covers no craft and no held contact.
 var crafts:Array=ocean.own_craft_rects()
 var on_craft:Rect2=crafts[0]
 check(not ocean.notice_clear(on_craft),"a notice over a craft is refused "+tag)
 # The shorter label keeps the head part.
 check(ocean.shorter_label("S2 SWEEPER · SEARCH · MIDDLE")=="S2 SWEEPER · SEARCH" and ocean.shorter_label("OWN SHUTTER")=="","labels shorten by their trailing parts")
 print("CHART LABELS ",tag," plates=",plates.size())
 game.queue_free();await settle()
func run():
 DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
 for shape in shapes:
  for shift in SHIFTS:await label_case(shape,shift)
  await crowd_case(shape)
 print("CHART LABEL FIT UI CHECKS ",checks," FAILURES ",failures)
 quit(1 if failures else 0)
