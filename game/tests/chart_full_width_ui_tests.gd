extends "res://tests/stable_board_ui_support.gd"
# WP-101: the dive chart uses the whole screen. The camera panel is an overlay (a small strip folded, a solid panel open), so
# the chart rect and its fit zoom do not depend on it; opening or folding it never moves or rescales the chart, and no chart
# label or tap target sits under the open panel. Cover (2520x1080), inner (2184x1968) and a phone (1080x2400), text 100% and 150%.
var shapes=[Vector2i(2520,1080),Vector2i(2184,1968),Vector2i(1080,2400)]
func frame_photo(sim):
 sim.sirens=[];sim.units[1].alive=false;sim.units[2].alive=false
 var spire=Vector2(1300,300);var facing=2.74
 var q=sim.units[0];q.pos=spire+Vector2.from_angle(facing+PI)*150;q.angle=facing;q.vel=Vector2.ZERO;q.band=1;q.transition={}
 sim._use_band(1)
func width_case(shape:Vector2i,text_scale:float):
 var game=await make_game(0,shape)
 var settings=Store.DEFAULTS.duplicate(true);settings.text_scale=text_scale
 Settings.apply(settings,game);await settle()
 for id in ["warning","sweep"]:
  if id not in game.hints_seen:game.hints_seen.append(id)
 var sim=game.sim;var ocean=game.ocean;var feed=ocean.optical_feed
 sim.paused=true;frame_photo(sim);sim.message=""
 game._refresh();await settle()
 var tag="%s text %d%%"%[str(shape),int(text_scale*100)]
 feed.compact=true;game._refresh();await settle()
 check(feed.is_visible_in_tree(),"the camera panel is present "+tag)
 var folded_rect=ocean.stable_chart_rect()
 check(is_equal_approx(folded_rect.size.x,ocean.size.x),"folded, the chart uses the full width "+tag)
 ocean.fit_chart();await settle()
 var span=ocean.world_size().x*ocean.chart_camera.scale
 var fraction=span/ocean.size.x
 print("CHART WIDTH ",tag," folded chart=",folded_rect.size.x,"/",ocean.size.x," fit span fraction=",snappedf(fraction,.01))
 if shape.x==2184:check(fraction>=.85,"inner screen, folded: the fitted region spans at least 85% of the width "+tag+" "+str(fraction))
 # Opening and folding the panel leaves the chart where it was.
 ocean.chart_camera.mode="follow";ocean._sync_camera();ocean.focus_craft();await settle()
 var anchor=ocean.screen_position(sim.units[0].pos);var scale_before=ocean.world_scale
 var chart_before=ocean.stable_chart_rect()
 feed.compact=false;game._refresh();await settle()
 check(ocean.screen_position(sim.units[0].pos).distance_to(anchor)<.1 and is_equal_approx(ocean.world_scale,scale_before),"opening the panel does not move or rescale the chart "+tag)
 check(ocean.stable_chart_rect()==chart_before,"opening the panel keeps the chart rect "+tag)
 # Open: labels stay off the panel, and its area is not a chart tap.
 var panel:Rect2=feed.get_rect();var fit:Rect2=ocean.label_fit_rect()
 check(fit.end.x<=panel.position.x or panel.size.x<=0.,"open, labels may not reach under the panel "+tag)
 for plate in ocean.world_label_rects:check(not panel.intersects(plate),"open, no label plate under the panel "+tag+" "+str(plate))

 check(feed.blocks_point(feed.global_position+panel.size*.5),"open, taps on the panel belong to it "+tag)
 feed.compact=true;game._refresh();await settle()
 check(ocean.screen_position(sim.units[0].pos).distance_to(anchor)<.1 and is_equal_approx(ocean.world_scale,scale_before),"folding the panel does not move or rescale the chart "+tag)
 check(not feed.blocks_point(feed.global_position+Vector2(2,feed.size.y*.5+40)) or feed.size.y<feed.toggle_rect.end.y+60,"folded, a tap away from OPEN reaches the chart "+tag)
 game.queue_free();await settle()
func run():
 DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
 for shape in shapes:
  for text_scale in [1.0,1.5]:await width_case(shape,text_scale)
 print("CHART FULL WIDTH UI CHECKS ",checks," FAILURES ",failures)
 quit(1 if failures else 0)
