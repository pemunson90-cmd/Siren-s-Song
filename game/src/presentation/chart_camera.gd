extends RefCounted
const WORLD=Vector2(1600,960)
var world_size=WORLD
var view_size=WORLD
var view_origin=Vector2.ZERO
var desired_center=WORLD/2
var _center=WORLD/2
var center:Vector2:
 get:return _center
 set(value):desired_center=value;_center=value
var mode="overview"
var zoom:=1.0
var scale:=1.0
var offset:=Vector2.ZERO
func configure(dimensions:Vector2,bounds:Vector2=WORLD,origin:Vector2=Vector2.ZERO) -> void:
 view_size=dimensions.max(Vector2.ONE);view_origin=origin;world_size=bounds.max(Vector2.ONE);_update()
func fit_scale() -> float:return minf(view_size.x/world_size.x,view_size.y/world_size.y)
func _update() -> void:
 if mode=="overview":desired_center=world_size/2;zoom=1.
 # Retain tactical follow magnification, capped so a tall viewport's narrow
 # chart still shows at least 600m across, including the local body and cone.
 if mode=="follow":zoom=minf(maxf(view_size.y/600.,view_size.x/1000.),view_size.x/600.)/fit_scale()
 scale=fit_scale()*zoom
 var half=view_size/(2*scale)
 _center=Vector2(world_size.x/2 if half.x>=world_size.x/2 else clampf(desired_center.x,half.x,world_size.x-half.x),world_size.y/2 if half.y>=world_size.y/2 else clampf(desired_center.y,half.y,world_size.y-half.y))
 offset=view_origin+view_size/2-_center*scale
func follow(point:Vector2) -> void:
 mode="follow";desired_center=point;_update()
func fit() -> void:
 mode="overview";zoom=1.;desired_center=world_size/2;_update()
func zoom_at(factor:float,anchor:Vector2) -> void:
 var world=to_world(anchor);mode="free"
 var maximum=maxf(4.,maxf(world_size.x/WORLD.x,world_size.y/WORLD.y)*4.)
 zoom=clampf(zoom*factor,1.,maximum);scale=fit_scale()*zoom
 desired_center=world-(anchor-view_origin-view_size/2)/scale;_update()
func pan(delta:Vector2) -> void:
 mode="free";desired_center=center-delta/scale;_update()
# Follow magnification is derived from the viewport, not a saved player choice.
# Keep the existing field canonical while free-view magnification remains exact.
func snapshot() -> Dictionary:return {"mode":mode,"center":desired_center,"zoom":1.0 if mode=="follow" else zoom}
func restore(state:Dictionary) -> void:
 if state.get("mode","") not in ["follow","free","overview"] or not state.get("center") is Vector2:return
 var point:Vector2=state.center;var magnification=state.get("zoom",1.)
 if not point.is_finite() or not (magnification is float or magnification is int) or not is_finite(magnification) or magnification<1:return
 mode=state.mode;desired_center=point;zoom=clampf(magnification,1.,maxf(4.,maxf(world_size.x/WORLD.x,world_size.y/WORLD.y)*4.));_update()
func to_world(point:Vector2) -> Vector2:return (point-offset)/scale
func to_screen(point:Vector2) -> Vector2:return offset+point*scale
