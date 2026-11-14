extends RefCounted
# [AI-DESIGNED] WP-20 (code audit A3): chart terrain geometry built once per
# chart generation instead of one draw_rect per cell and two draw_line calls per
# rock face on every frame.
#
# Cell fills become one quad per clear cell in a single ArrayMesh (world
# coordinates, per-vertex colour, so zoom never invalidates it). Rock faces
# become one PackedVector2Array of endpoint pairs drawn with two draw_multiline
# calls. Line widths are NOT stored: callers pass 7./scale and
# Palette.stroke(2.)/scale at draw time, so on-screen widths are identical at
# every zoom without a rebuild.
#
# The cache is a RefCounted kept in the view's metadata. It is never part of the
# simulation and never saved.
#
# ENABLED=false makes every caller fall back to the original per-cell drawing,
# which stays in each draw function as the fallback path.
const ENABLED=true
const Palette=preload("res://src/presentation/accessibility/palette.gd")
const META="_chart_geometry_cache"
# Runtime switch, initialised from ENABLED (tests flip it to prove the fallback).
static var enabled:bool=ENABLED
var key:Array=[]
var quads:PackedVector2Array=PackedVector2Array()
var colors:PackedColorArray=PackedColorArray()
var mesh:ArrayMesh=null
var face_points:PackedVector2Array=PackedVector2Array()
var rebuilds:int=0
static func active(data:Dictionary)->bool:
	# Charts without a generation counter cannot be keyed safely: draw uncached.
	return enabled and data.has("generation")
# Returns the cache for this view and slot, rebuilding only when the key changed.
# extra: anything else the geometry depends on (style colours...). color_fn maps a
# clear-cell key to its fill colour and is called only during a rebuild.
static func request(view,slot:String,data:Dictionary,extra:Array,color_fn:Callable):
	var caches:Dictionary=view.get_meta(META,{})
	var cache=caches.get(slot)
	if cache==null:
		cache=load("res://src/presentation/chart_cache/chart_geometry_cache.gd").new();caches[slot]=cache;view.set_meta(META,caches)
	# The content hashes matter: one view outlives many dives, and a new dive or a
	# restored save can reuse a generation number with the same counts but other cells.
	var clear:Array=data.get("clear_cells",[]);var faces:Array=data.get("surface_segments",[])
	var wanted:Array=[data.get("generation"),float(data.get("cell_size",40.)),clear.size(),faces.size(),clear.hash(),faces.hash(),Palette.high_contrast(),extra]
	if cache.key!=wanted:cache._rebuild(data,wanted,color_fn)
	return cache
func _rebuild(data:Dictionary,wanted:Array,color_fn:Callable)->void:
	rebuilds+=1;key=wanted
	var cell=float(data.get("cell_size",40.))
	quads=PackedVector2Array();colors=PackedColorArray();face_points=PackedVector2Array();mesh=null
	var indices=PackedInt32Array();var n=0
	# Feathered edge: a vertex is as opaque as the share of the four cells around it that are measured water, and one
	# ring of cells around the water fades from that to nothing. The chart reads as a soft stain, not hard blocks.
	var clear:Dictionary={};for tile in data.get("clear_cells",[]):clear[Vector2i(tile)]=true
	var ring:Dictionary={}
	for tile in clear:
		for dx in range(-1,2):
			for dy in range(-1,2):
				var near=tile+Vector2i(dx,dy)
				if not clear.has(near):ring[near]=true
	var vertices=PackedVector2Array();var vertex_colors=PackedColorArray()
	for tile in clear:
		var origin=Vector2(tile)*cell;var color:Color=color_fn.call(tile)
		var corners=PackedVector2Array([origin,origin+Vector2(cell,0),origin+Vector2(cell,cell),origin+Vector2(0,cell)])
		quads.append_array(corners)
		for k in 4:colors.append(_feathered(color,clear,tile+Vector2i(int(k in [1,2]),int(k in [2,3]))))
	for tile in ring:
		var origin=Vector2(tile)*cell;var color:Color=color_fn.call(tile)
		vertices.append_array(PackedVector2Array([origin,origin+Vector2(cell,0),origin+Vector2(cell,cell),origin+Vector2(0,cell)]))
		for k in 4:vertex_colors.append(_feathered(color,clear,tile+Vector2i(int(k in [1,2]),int(k in [2,3]))))
	var all_vertices=quads+vertices;var all_colors=colors+vertex_colors
	n=all_vertices.size()
	for q in range(0,n,4):indices.append_array(PackedInt32Array([q,q+1,q+2,q,q+2,q+3]))
	if n>0:
		var arrays=[];arrays.resize(Mesh.ARRAY_MAX)
		arrays[Mesh.ARRAY_VERTEX]=all_vertices;arrays[Mesh.ARRAY_COLOR]=all_colors;arrays[Mesh.ARRAY_INDEX]=indices
		mesh=ArrayMesh.new();mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,arrays)
	for face in data.get("surface_segments",[]):
		if face.size()!=2:continue
		face_points.append(face[0]);face_points.append(face[1])
# The grid corner `corner` touches four cells; its opacity is the share of them that are measured water.
func _feathered(color:Color,clear:Dictionary,corner:Vector2i)->Color:
	var share=0
	for offset in [Vector2i(-1,-1),Vector2i(0,-1),Vector2i(-1,0),Vector2i(0,0)]:
		if clear.has(corner+offset):share+=1
	return Color(color,color.a*share/4.0)
func draw_fill(view)->void:
	if mesh!=null:view.draw_mesh(mesh,null)
# Two batched calls for every rock face: stone body, then edge line.
func draw_faces(view,stone:Color,stone_width:float,edge:Color,edge_width:float)->void:
	if face_points.is_empty():return
	view.draw_multiline(face_points,stone,stone_width)
	view.draw_multiline(face_points,edge,edge_width)
