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
# WP-31: centre lines are never cut. Every line wraps at word breaks; when a word is
# still too wide or the stack is too tall, the type shrinks (never below MIN_SIZE).
# Returns {"lines":Array,"size":int}.
const MIN_SIZE=10
static func wrap_line(text:String,font:Font,font_size:int,max_width:float)->Array:
 if font.get_string_size(text,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size).x<=max_width:return [text]
 var out=[];var current=""
 for word in text.split(" ",false):
  var trial=(current+" "+word).strip_edges()
  if current.is_empty() or font.get_string_size(trial,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size).x<=max_width:current=trial
  else:out.append(current);current=word
 if not current.is_empty():out.append(current)
 return out
static func fit_wrapped(lines:Array,font:Font,font_size:int,max_width:float,max_height:float)->Dictionary:
 var size=font_size
 while true:
  var out=[];var widest=0.
  for line in lines:
   for part in wrap_line(str(line),font,size,max_width):
    out.append(part);widest=maxf(widest,font.get_string_size(part,HORIZONTAL_ALIGNMENT_LEFT,-1,size).x)
  var height=out.size()*(size+STYLE.line_gap)
  if (widest<=max_width+.5 and height<=max_height) or size<=MIN_SIZE:return {"lines":out,"size":size}
  size-=1
 return {"lines":lines,"size":font_size}
# WP-36 (visual review C3): fit_wrapped checked one width for every line, but the disc is
# narrower away from its middle, so a long line near the top or bottom ("▸ UNKNOWN SIGNAL SOURCE")
# was cut at the disc edge. fit_disc wraps each line to the chord at its own height and
# shrinks the type (floor MIN_SIZE) until every line's text rectangle lies inside the disc
# (an ellipse when the status table reshapes it). first_y.call(count,size) gives the first
# baseline for a stack of that many lines. Returns {"lines","size","first_y"}.
const EDGE_PAD=2.
static func line_rect(text:String,font:Font,font_size:int,center_x:float,baseline:float)->Rect2:
 var width=font.get_string_size(text,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size).x
 return Rect2(Vector2(center_x-width/2,baseline-font.get_ascent(font_size)),Vector2(width,font.get_height(font_size)))
static func inside(rect:Rect2,center:Vector2,radii:Vector2)->bool:
 for corner in [rect.position,Vector2(rect.end.x,rect.position.y),Vector2(rect.position.x,rect.end.y),rect.end]:
  if ((corner-center)/radii).length_squared()>1.:return false
 return true
static func chord_room(font:Font,font_size:int,center:Vector2,radii:Vector2,baseline:float)->float:
 var top=baseline-font.get_ascent(font_size)
 var dy=maxf(absf(top-center.y),absf(top+font.get_height(font_size)-center.y))
 var ry=radii.y-EDGE_PAD
 if dy>=ry:return 0.
 return 2.*(radii.x-EDGE_PAD)*sqrt(1.-(dy/ry)*(dy/ry))*DISC_FILL
static func wrap_disc(lines:Array,font:Font,font_size:int,center:Vector2,radii:Vector2,first:float)->Array:
 var out=[];var step=font_size+STYLE.line_gap
 for line in lines:
  var current=""
  for word in str(line).split(" ",false):
   var trial=(current+" "+word).strip_edges()
   if current.is_empty() or font.get_string_size(trial,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size).x<=chord_room(font,font_size,center,radii,first+out.size()*step):current=trial
   else:out.append(current);current=word
  if not current.is_empty() or str(line).strip_edges().is_empty():out.append(current)
 return out
static func fit_disc(lines:Array,font:Font,font_size:int,center:Vector2,radii:Vector2,max_height:float,first_y:Callable)->Dictionary:
 var size=font_size
 while true:
  var count=lines.size();var out=[];var first=0.
  for attempt in 4:
   first=first_y.call(count,size);out=wrap_disc(lines,font,size,center,radii,first)
   if out.size()==count:break
   count=out.size()
  first=first_y.call(out.size(),size)
  var fits=out.size()*(size+STYLE.line_gap)<=max_height
  for n in out.size():
   if not inside(line_rect(out[n],font,size,center.x,first+n*(size+STYLE.line_gap)),center,radii):fits=false;break
  if fits or size<=MIN_SIZE:return {"lines":out,"size":size,"first_y":first}
  size-=1
 return {"lines":lines,"size":font_size,"first_y":first_y.call(lines.size(),font_size)}
static func ellipsize(text:String,font:Font,font_size:int,max_width:float)->String:
 if font.get_string_size(text,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size).x<=max_width:return text
 var cut=text.length()
 while cut>1 and font.get_string_size(text.substr(0,cut).strip_edges()+"…",HORIZONTAL_ALIGNMENT_LEFT,-1,font_size).x>max_width:cut-=1
 return text.substr(0,cut).strip_edges()+"…"
static func first_baseline(center_y:float,back:Rect2,h:float,scale:float,count:int,font:Font,font_size:int)->float:
 var above=back.position.y-maxf(STYLE.min_gap,h*scale*STYLE.caption_gap)-font.get_descent(font_size)-(count-1)*(font_size+STYLE.line_gap)
 return minf(center_y+h*STYLE.caption_top,above)
