extends Control
# The waterfall projects received samples only. Horizontal axis=bearing,
# vertical axis=sample age. It never queries live enemies.
var sim
func _draw():
 if sim==null:return
 var frame=Rect2(Vector2(32,24),size-Vector2(40,36));draw_rect(frame,Color("07151b"))
 var font=ThemeDB.fallback_font
 for bearing in [0,90,180,270,360]:
  var x=frame.position.x+frame.size.x*bearing/360.
  draw_line(Vector2(x,frame.position.y),Vector2(x,frame.end.y),Color(.25,.5,.53,.25))
  draw_string(font,Vector2(x-8,18),str(bearing),HORIZONTAL_ALIGNMENT_LEFT,-1,14,Color("88bcbf"))
 for age in [0,5,10,15,20]:
  var y=frame.position.y+frame.size.y*age/20.
  draw_string(font,Vector2(1,y+4),str(age)+"s",HORIZONTAL_ALIGNMENT_LEFT,-1,12,Color("88bcbf"))
  draw_line(Vector2(frame.position.x,y),Vector2(frame.end.x,y),Color(.25,.5,.53,.16))
 for row in sim.Sonar.feedback(sim,sim.selected).rows:
  var age=sim.elapsed-row.time
  var degrees=fposmod(rad_to_deg(atan2(row.direction.x,-row.direction.y)),360.)
  var point=frame.position+Vector2(frame.size.x*degrees/360.,frame.size.y*age/20.)
  var spread=lerpf(18.,4.,row.confidence)
  draw_line(point-Vector2(spread,0),point+Vector2(spread,0),Color("edb36c") if row.kind=="echo" else Color("76d6c7"),2+row.confidence*2)
static func detail(sim)->String:
 var feedback=sim.Sonar.feedback(sim,sim.selected);var u=sim.units[sim.selected]
 var text="BEARING HISTORY · %s\n%s · %s / %s · pending %d\nOwn noise ~%dm · passive masking ×%.1f"%[u.name,sim.Depth.NAMES[u.band],feedback.sector.to_upper(),feedback.power.to_upper(),feedback.pending,roundi(feedback.own_noise),1.+feedback.own_noise/180.]
 var rows=feedback.rows.slice(maxi(0,feedback.rows.size()-4));rows.reverse()
 for row in rows:
  var degrees=fposmod(rad_to_deg(atan2(row.direction.x,-row.direction.y)),360.)
  text+="\n%03d° ±%d° · %.1fs · %d%% · %s"%[roundi(degrees)%360,roundi(lerpf(28,5,row.confidence)),maxf(0,sim.elapsed-row.time),roundi(row.confidence*100),row.classification]
 if rows.is_empty():text+="\nNo received signals. Move quietly or separate craft for independent bearing rays."
 return text+"\n"+sim.Depth.context(sim)+"\nBearings alone give no range, band or clear passage. Echoes keep their original reflection time."
static func draw_bearings(canvas,sim):
 var feedback=sim.Sonar.feedback(sim,sim.selected)
 var drawn={}
 var rows=feedback.rows.duplicate();rows.reverse()
 for row in rows:
  if drawn.has(row.enemy) or sim.elapsed-row.time>3:continue
  drawn[row.enemy]=true
  var point:Vector2=row.origin;var direction:Vector2=row.direction
  var color=Color(.3,.85,.76,.35) if row.kind=="bearing" else Color(.95,.65,.3,.5)
  canvas.draw_line(point+direction*35,point+direction*170,color,1.5/canvas.world_scale)
  var spread=deg_to_rad(lerpf(28,5,row.confidence))
  for side in [-1,1]:canvas.draw_line(point+direction*35,point+direction.rotated(spread*side)*170,Color(color,.2),1./canvas.world_scale)
