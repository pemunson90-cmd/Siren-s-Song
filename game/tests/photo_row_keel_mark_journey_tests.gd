extends SceneTree
const J=preload("res://tests/photo_row_journey_support.gd")
const G=preload("res://tests/glass_reach_journeys.gd")
func _initialize():
 # Follow095's proven fleet approach after Quietus restores the real service
 # passage. Use legal owner racks and public controls, with no automatic defence.
 var h=J.new(18,"keel_mark",1)
 var g=G.new()
 var racks=preload("res://src/equipment/tool_racks.gd").empty()
 h.s.start(18,"endurance",{"context":J.Sim.Consequences.context(g.progress()),"tool_racks":racks,"fitted":{"quietus":"quietus_baffles","drone_a":"drone_deep_cells","drone_b":"drone_survey_array"}})
 h.initial_tools=h.s.tools.duplicate(true)
 h.s.command("select",{"unit":1});h.s.command("drone_drive",{"mode":"quiet"})
 h.s.command("select",{"unit":0})
 var travelled=h.check(g.course(h.s,18) and g.failures==0,"Quietus physically restores service and reaches recovery")
 for point in [Vector2(2650,1900),Vector2(2650,1150),Vector2(2300,1300),Vector2(1702,1278),Vector2(1750,1278)]:
  if travelled:travelled=h.go(point)
 if travelled and h.depth(0) and h.focus():
  h.study(Vector2.INF,Vector2(1550,1278),1)
 g.free()
 h.finish(self,"PHOTO ROW KEEL MARK JOURNEY")
