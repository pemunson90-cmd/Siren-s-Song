extends "res://tests/stable_board_ui_support.gd"
# Native cover / mirrored partition of the complete stable-board matrix.
func partition_shape()->Vector2i:return Vector2i(2520,1080)
func partition_mirrored()->bool:return true
