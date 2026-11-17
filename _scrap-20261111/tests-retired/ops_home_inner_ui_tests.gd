extends "res://tests/ops_home_ui_tests.gd"
# CI partition only: inherited run retains both text scales and all recovery states.
func home_case(shape, recovered, scale):
 if shape==Vector2i(2184,1968):await super.home_case(shape,recovered,scale)
