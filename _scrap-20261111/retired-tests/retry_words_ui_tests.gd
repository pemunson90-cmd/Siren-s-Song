extends "res://tests/wide_menus_ui_tests.gd"
# WP-105 (critic round 7): the result screen's RETRY DIVE says what it carries; the Expedition words agree (kit and
# scarcity lines, the "Earned" line, one rounding of hull, one word for recovered); the loadout steppers match.
# Real screens at the cover screen (2520x1080) and the inner screen (2184x1968).
const Flow=preload("res://src/presentation/flow/campaign_flow.gd")
const Words=preload("res://src/presentation/runs/run_words.gd")
const RunRecords=preload("res://src/campaign/runs/run_records.gd")
const RunTable=preload("res://src/campaign/runs/run_table.gd")
const Names=preload("res://src/names.gd")
var seen:Array=[]
func words_case()->void:
 var survey=Names.LOADOUT_SURVEY
 # (a) The kit line and the scarcity line agree: a scarce run says it starts with fewer of each tool than the full kit.
 var kit=Words.kit_line(survey,2)
 check(kit.contains("Survey") and kit.contains("2 fewer of each tool") and kit.contains("scarce"),"the kit line explains what scarcity takes from the full kit: "+kit)
 check(not Words.kit_line(survey,0).contains("fewer"),"a supplied run's kit line adds no scarcity sentence")
 check(Words.kit_line(survey)==Words.kit_line(survey,0),"the kit line without a scarcity is the supplied one")
 # (b) A scarce run's line stays true after an offer pick: it speaks of what a recovery adds, and of the offer.
 var scarce=RunRecords.scarcity_line(survey,2)
 check(scarce.contains("adds no supplies of its own") and scarce.contains("next-dive offer"),"the scarce line does not deny the offer's supplies: "+scarce)
 check(not scarce.contains("recovered operations add no supplies"),"the old absolute wording is gone")
 # (c) Earned lists the archive and the photograph, then the supplies.
 var before={"emp":3,"decoy":2,"recon":1,"knock":1,"sonobuoy":0,"silt_screen":0,"hull_patch":0,"relay_buoy":0}
 var after=before.duplicate();var kept=before.duplicate()
 var won=Words.dive_ledger(before,after,kept,"Shelf Passive",.72)
 check(won[2]=="Earned: archive recovered (Shelf Passive), photo B (72%).","a recovery's Earned line names the archive and the photograph grade: "+won[2])
 kept["decoy"]=3
 check(Words.dive_ledger(before,after,kept,"Shelf Passive",.9)[2]=="Earned: archive recovered (Shelf Passive), photo A (90%), +1 Decoy.","the supplies follow the archive and the photograph")
 check(Words.dive_ledger(before,after,before,"Shelf Passive",-1.)[2]=="Earned: archive recovered (Shelf Passive).","a recovery without a photograph lists the archive only")
 check(Words.dive_ledger(before,after,before)[2]=="Earned: nothing.","a lost dive with no supplies still earns nothing")
 # (e) One word: recovered, never cleared, on the records list and in the record's lines.
 var row=Archive_finished()
 var summary:Array=load("res://src/presentation/runs/run_summary_view.gd").summary_lines(row)
 check(summary[0].contains("operations recovered") and not summary[0].contains("cleared"),"the run record says recovered: "+summary[0])
 check(summary[1].contains("fewer of each tool") or row.scarcity==0,"the record's kit line carries the run's scarcity")
func Archive_finished()->Dictionary:
 return {"seed":11,"depth":2,"total":5,"status":"lost","loadout":Names.LOADOUT_SURVEY,"scarcity":2,"hunt_stage":1,"spent":RunRecords.counts(),"gained":RunRecords.counts(),"operations":[]}
func result_case(shape:Vector2i)->void:
 root.size=shape;await settle()
 var tag=" at "+str(shape)
 var path="user://retry-words-%d.save"%shape.x
 var game=await make_game(path)
 game.size=Vector2(game.get_viewport_rect().size);game._layout();await settle()
 # (d) The result's hull is the dive's reading, rounded the way the fleet instruments round it.
 game.sim.hull=76.6
 check(Flow.stats_line(game.sim).contains("Hull 77%"),"the result's hull rounds as the dive does (76.6 reads 77)"+tag)
 game.sim.hull=76.4
 check(Flow.stats_line(game.sim).contains("Hull 76%"),"the result's hull rounds down below .5"+tag)
 # (4) RETRY DIVE says the hull it starts with, from the number the briefing uses.
 game.sim.hull=55.;game.sim.outcome="lost";game.sim.message="Hull lost."
 game._debrief();await settle()
 var retry=button(game,"retry")
 var carried=Flow.carried_hull(game)
 check(retry!=null and carried<100 and retry.text==Flow.RETRY_HULL%carried,"RETRY DIVE names the hull the next dive starts with: "+str(retry.text if retry!=null else "none")+tag)
 check(Flow.carried_damage_line(game).contains("hull %d%%"%carried),"the briefing line and the button give the same hull"+tag)
 check(retry!=null and retry.get_global_rect().size.y>=game.ui_touch_height-.5,"the longer RETRY DIVE keeps its touch height"+tag)
 game.economy.cond[Names.CRAFT_QUIETUS]=100
 check(Flow.retry_label(game)=="RETRY DIVE","an undamaged retry keeps the plain label"+tag)
 seen.append("%s retry: %s"%[str(shape),retry.text.replace("\n"," ") if retry!=null else "none"])
 # (f) The loadout steppers: the same font, weight, size and button size, minus and plus alike.
 game._show_fittings();await settle()
 var steps:Array=game.panel_box.find_children("*","Button",true,false).filter(func(b):return str(b.get_meta("action","")).contains("_add_") or str(b.get_meta("action","")).contains("_remove_"))
 check(steps.size()>=2,"the fittings screen shows loadout steppers"+tag)
 if steps.size()>=2:
  var first=steps[0]
  for b in steps:
   var same=b.get_theme_font_size("font_size")==first.get_theme_font_size("font_size") and b.get_theme_font("font").base_font==first.get_theme_font("font").base_font and b.get_theme_font("font").variation_embolden==first.get_theme_font("font").variation_embolden and b.custom_minimum_size==first.custom_minimum_size and is_equal_approx(b.size.x,first.size.x)
   check(same,"stepper %s matches the others in size, weight and button size%s"%[b.get_meta("action"),tag])
  var font:Font=first.get_theme_font("font")
  seen.append("%s steppers: %d, font size %d, has U+2212 %s, +%s -%s"%[str(shape),steps.size(),first.get_theme_font_size("font_size"),str(font.has_char(0x2212)),str(font.get_string_size("+",HORIZONTAL_ALIGNMENT_LEFT,-1,first.get_theme_font_size("font_size"))),str(font.get_string_size("−",HORIZONTAL_ALIGNMENT_LEFT,-1,first.get_theme_font_size("font_size")))])
 await finish(game,path)
func run():
 words_case()
 for shape in [Vector2i(2520,1080),Vector2i(2184,1968)]:await result_case(shape)
 for line in seen:print("RW ",line)
 print("RETRY WORDS UI CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
