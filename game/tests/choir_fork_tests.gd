extends SceneTree
const Catalog=preload("res://src/campaign/operation_catalog.gd")
const Sim=preload("res://src/simulation/simulation.gd")
const Fork=preload("res://src/campaign/arcs/choir_fork.gd")
var checks=0
var failures=0
func check(ok,label):
	checks+=1
	if not ok:failures+=1;printerr("FAIL ",label)
func route_history(value)->Dictionary:return {"facts":{"confluence_route":value}}
func _initialize():
	var overt=Catalog.make(23,route_history("overt"));var overt24=Catalog.make(24,route_history("overt"))
	check(overt.corridors.size()==1 and overt.corridors[0].pos==Vector2(2750,300),"overt op23 uses the north recovery mouth")
	check(overt24.corridors.size()==1 and overt24.corridors[0].pos==Vector2(2750,500),"overt op24 uses the north/east recovery mouth")
	check(overt.corridors[0].name=="CHOIR NORTH RECOVERY" and overt.brief.contains("open warning passage recorded at Confluence"),"overt briefing carries the earlier cause")
	for value in ["concealed","", "invalid"]:
		for id in [23,24]:
			var m=Catalog.make(id,route_history(value))
			check(m.corridors.size()==1 and m.corridors[0].pos==m.start and m.corridors[0].name=="CHOIR SOUTH RECOVERY","fallback preserves south recovery %s/%s"%[id,value])
	var missing=Catalog.make(23,{})
	check(missing.corridors[0].pos==missing.start,"missing history preserves south recovery")
	var s=Sim.new();var context=route_history("overt");s.start(23,"endurance",{"context":context});context.facts.confluence_route="concealed"
	var frozen=s.snapshot();check(Sim.valid_snapshot(frozen),"active fork dive snapshot validates")
	check(frozen.mission.corridors[0].pos==Vector2(2750,300) and frozen.mission.launch_context.facts.confluence_route=="overt","launch route is frozen into active dive")
	var restored=Sim.new();check(restored.restore(frozen),"active fork dive snapshot restores")
	check(restored.mission.corridors[0].pos==Vector2(2750,300),"roundtrip preserves selected recovery variant")
	for id in [22,30]:
		var base=Catalog.make(id);var changed=Catalog.make(id,route_history("overt"))
		check(base.corridors==changed.corridors and base.extraction==changed.extraction,"control op geometry unchanged %d"%id)
	for id in [23,24]:
		var op=Catalog.make(id,route_history("overt"));var live=Sim.new();live.start(id,"endurance",{"context":route_history("overt")})
		check(not op.iron_choir.sites.is_empty() and not live.all_records() and not live.extraction_corridors()[0].available,"industrial work remains mandatory before recovery %d"%id)
	print("CHOIR FORK CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
