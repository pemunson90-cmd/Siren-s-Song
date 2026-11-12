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
# WP-11 (I2): centre text stays inside the ring's inner disc. The title wraps to
# at most two lines at word breaks; any line still too wide ends in an ellipsis.
# Lines that already fit are returned unchanged. Switch: FIT_TEXT.
const FIT_TEXT=true
const DISC_FILL=.9
static func text_width(hud_ring_radius:float,h:float)->float:
 return maxf(h,2.*(hud_ring_radius-h*.7)*DISC_FILL)
static func fit_lines(lines:Array,font:Font,font_size:int,max_width:float)->Array:
 if not FIT_TEXT:return lines
 var out=[]
 for n in lines.size():
  var text=str(lines[n])
  if font.get_string_size(text,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size).x<=max_width:out.append(text);continue
  if n==0:
   var words=text.split(" ",false);var first=""
   var rest_at=words.size()
   for i in words.size():
    var trial=(first+" "+words[i]).strip_edges()
    if i>0 and font.get_string_size(trial,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size).x>max_width:rest_at=i;break
    first=trial
   if rest_at<words.size():
    out.append(ellipsize(first,font,font_size,max_width))
    out.append(ellipsize(" ".join(words.slice(rest_at)),font,font_size,max_width))
    continue
  out.append(ellipsize(text,font,font_size,max_width))
 return out
static func ellipsize(text:String,font:Font,font_size:int,max_width:float)->String:
 if font.get_string_size(text,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size).x<=max_width:return text
 var cut=text.length()
 while cut>1 and font.get_string_size(text.substr(0,cut).strip_edges()+"…",HORIZONTAL_ALIGNMENT_LEFT,-1,font_size).x>max_width:cut-=1
 return text.substr(0,cut).strip_edges()+"…"
static func first_baseline(center_y:float,back:Rect2,h:float,scale:float,count:int,font:Font,font_size:int)->float:
 var above=back.position.y-maxf(STYLE.min_gap,h*scale*STYLE.caption_gap)-font.get_descent(font_size)-(count-1)*(font_size+STYLE.line_gap)
 return minf(center_y+h*STYLE.caption_top,above)
