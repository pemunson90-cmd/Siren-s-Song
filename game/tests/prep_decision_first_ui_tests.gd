extends "res://tests/challenges_ui_tests.gd"
# Prep screens lead with the decision: loadout first on Fittings, contracts first on the Career board.
const CareerArchive=preload("res://src/campaign/career/career_archive.gd")
const Career=preload("res://src/campaign/career/career_state.gd")
const CareerFront=preload("res://src/presentation/career/career_frontend.gd")
func ids(host):
	var out=[]
	for b in host.panel_box.get_children():
		if b is Button:out.append(b.get_meta("ui_action",""))
	return out
func first_index(list,pred):
	for i in list.size():
		if pred.call(list[i]):return i
	return -1
func run():
	var path="user://prep-decision-first.save"
	var host=load("res://scenes/main.tscn").instantiate();host.set_script(load("res://tests/density_main.gd"))
	host.capture_scenario="runtime-test";host.store.path=path;root.add_child(host);await settle()
	host._show_fittings();await settle()
	var list=ids(host);print("FITTINGS ORDER ",list)
	var link=func(i):return i=="economy" or i.begins_with("archive") or i.begins_with("early")
	check(list[0]=="back","Fittings leads with BACK")
	check(list.size()>1 and not link.call(list[1]),"first control after BACK is a loadout or module control: "+str(list.slice(0,3)))
	var last_loadout=-1
	for i in list.size():
		if not link.call(list[i]) and i>0:last_loadout=i
	for i in list.size():
		if link.call(list[i]):check(i>1,"link "+list[i]+" follows the loadout")
	host.completed.append(0);host._show_fittings();await settle()
	list=ids(host);print("FITTINGS ORDER (first operation recovered) ",list)
	check(list.size()>1 and list[1].begins_with("frame_"),"recovered: first control after BACK is a hull or drone frame control: "+str(list.slice(0,3)))
	for i in list.size():
		if link.call(list[i]):check(i>1,"recovered: link "+list[i]+" follows the loadout")
	var front=Front.new();host.add_child(front);front.setup(host,true)
	check(CareerArchive.persist(host,Career.new_career()),"career fixture")
	CareerFront.start(front);await settle();var session=host.get_node("CareerSession")
	var board=ids(session);print("CAREER ORDER ",board)
	var contract=first_index(board,func(i):return i.begins_with("career_contract_"))
	check(contract>=0,"contract buttons present")
	for id in ["career_supplies","career_fittings","career_return"]:check(board.has(id),"still present "+id)
	check(contract<board.find("career_supplies") and contract<board.find("career_fittings"),"contracts precede management buttons")
	var history=session.panel_box.find_children("*","Label",true,false).filter(func(n):return n.text.contains(" RECOVERED · "))
	check(history.size()==1 and history[0].get_index()>session.panel_box.get_children()[0].get_index(),"history text present")
	if history.size()==1:
		var first=session.panel_box.get_children().filter(func(n):return n is Button and n.get_meta("ui_action","").begins_with("career_contract_"))[0]
		check(first.get_index()<history[0].get_index(),"first contract precedes history text")
	print("PREP DECISION FIRST UI CHECKS ",checks," FAILURES ",failures)
	quit(1 if failures>0 else 0)
