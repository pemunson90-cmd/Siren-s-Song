extends RefCounted
const WORLD=Vector2(1600,960)
var view_size=Vector2(1600,960)
var center=WORLD/2
var zoom:=1.0
var scale:=1.0
var offset:=Vector2.ZERO
func configure(dimensions: Vector2) -> void:
	view_size=dimensions.max(Vector2.ONE); _update()
func _update() -> void:
	scale=minf(view_size.x/WORLD.x,view_size.y/WORLD.y)*zoom
	var half=view_size/(2*scale)
	center.x=WORLD.x/2 if half.x>=WORLD.x/2 else clampf(center.x,half.x,WORLD.x-half.x)
	center.y=WORLD.y/2 if half.y>=WORLD.y/2 else clampf(center.y,half.y,WORLD.y-half.y)
	offset=view_size/2-center*scale
func fit() -> void:
	zoom=1.0; center=WORLD/2; _update()
func zoom_at(factor: float,anchor: Vector2) -> void:
	var world=to_world(anchor)
	zoom=clampf(zoom*factor,1.0,4.0)
	scale=minf(view_size.x/WORLD.x,view_size.y/WORLD.y)*zoom
	center=world-(anchor-view_size/2)/scale; _update()
func pan(delta: Vector2) -> void:
	center-=delta/scale; _update()
func to_world(point: Vector2) -> Vector2: return (point-offset)/scale
func to_screen(point: Vector2) -> Vector2: return offset+point*scale
