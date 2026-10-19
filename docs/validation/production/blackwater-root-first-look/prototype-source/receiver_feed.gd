extends "res://src/presentation/camera_feed.gd"
# Plain prototype instrumentation, not authored assets or captured sound.
func _draw():
	if sim==null or sim.capture_unit<0:return
	var objective=sim.mission.objectives[sim.capture_target]
	if objective.get("kind","")!="exchange":super._draw();return
	var c=sim.exchange_context(sim.capture_target)
	var font=ThemeDB.fallback_font
	draw_rect(Rect2(Vector2.ZERO,size),Color("07151d"));draw_rect(Rect2(Vector2.ZERO,size),Color("6b9d9f"),false,1)
	draw_string(font,Vector2(14,25),"HYDROPHONES / "+sim.units[sim.capture_unit].name,HORIZONTAL_ALIGNMENT_LEFT,-1,14,PHOSPHOR)
	draw_string(font,Vector2(14,59),objective.name,HORIZONTAL_ALIGNMENT_LEFT,-1,16,Color("e0bf83"))
	draw_string(font,Vector2(14,91),"LOCAL REPLAY" if c.replay>0 else ("LOCAL CARRIER" if c.get("open",false) else "LOCAL GAP / HOLDING"),HORIZONTAL_ALIGNMENT_LEFT,-1,14,PHOSPHOR)
	draw_string(font,Vector2(14,127),"Settled reception %.1f / 2.0s"%sim.exchange.progress,HORIZONTAL_ALIGNMENT_LEFT,-1,14,PHOSPHOR)
	draw_string(font,Vector2(14,159),"Movement or carrier loss resets progress",HORIZONTAL_ALIGNMENT_LEFT,-1,13,PHOSPHOR)
	draw_string(font,Vector2(14,189),"No claim that nearby enemies heard a tool",HORIZONTAL_ALIGNMENT_LEFT,-1,12,PHOSPHOR)
	draw_rect(Rect2(12,size.y-16,size.x-24,4),Color("25464b"));draw_rect(Rect2(12,size.y-16,(size.x-24)*clampf(sim.exchange.progress/2,0,1),4),PHOSPHOR)
