extends "res://tests/status_text_ui_tests.gd"
# CI partition only. Retain every real-touch case on the inner display.
func table_ui():pass
func touch_case(shape:Vector2i,id:int):
 if shape==Vector2i(2184,1968):await super.touch_case(shape,id)
func received_arrivals(shape:Vector2i):
 if shape==Vector2i(2184,1968):await super.received_arrivals(shape)
