extends RefCounted
# Isolated challenger budgets, in seconds for a 100-point supply at full work.
# Longer operations retain room for Quietus-only acquisition and withdrawal.
# Authored budgets live in operation_meta.gd ROWS (oxygen_seconds, drone_seconds);
# operations without them, and unknown IDs, get its DEFAULT_ENDURANCE (300 s, 240 s).
const Meta=preload("res://src/campaign/operation_meta.gd")
static func for_mission(id:int)->Dictionary:return Meta.endurance(id)
