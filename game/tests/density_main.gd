extends "res://src/main.gd"
func ui_density_dpi() -> float: return 420.0
func ui_density_source() -> String: return "test_android_density_fixture"

# Recorded physical inset from native run39222413584; desktop test only.
var fixture_safe_area: Rect2=Rect2()
func _apply_safe_area() -> void:
 if not fixture_safe_area.has_area():
  super._apply_safe_area(); return
 if applying_safe_area:return
 applying_safe_area=true
 var viewport_size=get_viewport_rect().size
 var safe=preload("res://src/presentation/layout_metrics.gd").content_rect(viewport_size,Vector2(get_window().size),fixture_safe_area)
 offset_left=safe.position.x;offset_top=safe.position.y
 offset_right=safe.end.x-viewport_size.x;offset_bottom=safe.end.y-viewport_size.y
 applying_safe_area=false
func _ui_metrics() -> Dictionary:
 var result=super._ui_metrics()
 if fixture_safe_area.has_area():
  result.safe_rect=_rect_values(fixture_safe_area)
  result["safe_area_source"]="recorded_android_39222413584_fixture"
 return result
