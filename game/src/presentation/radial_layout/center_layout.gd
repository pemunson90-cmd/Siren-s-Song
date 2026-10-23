extends RefCounted
# Center text and BACK share the free space inside the real command rectangles.
# Revert: remove CenterLayout seams in mission_hud.gd; no saved state.
const STYLE={"back_max":.65,"back_min":-.35,"back_step":.05,"caption_gap":.1,"line_gap":5.,"caption_top":-.65,"min_gap":4.}
static func back_rect(center:Vector2,body:Vector2,h:float,scale:float,commands:Array)->Rect2:
 var steps=roundi((STYLE.back_max-STYLE.back_min)/STYLE.back_step)
 for n in steps+1:
  var rect=Rect2(center+Vector2(-body.x/2,h*scale*(STYLE.back_max-n*STYLE.back_step)),body)
  if not commands.any(func(button):return button.get_rect().intersects(rect)):
   return rect
 return Rect2(center-body/2,body)
static func first_baseline(center_y:float,back:Rect2,h:float,scale:float,count:int,font:Font,font_size:int)->float:
 var above=back.position.y-maxf(STYLE.min_gap,h*scale*STYLE.caption_gap)-font.get_descent(font_size)-(count-1)*(font_size+STYLE.line_gap)
 return minf(center_y+h*STYLE.caption_top,above)
