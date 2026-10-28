extends SceneTree
# Ironman integrity: pinned SAVE2 record flag, restore refusal, profile copy/export guard.
# Non-Ironman behavior must stay identical. Revert: Table.ironman_lock=false, Rules.IRONMAN_GUARD=false.
const Economy=preload("res://src/campaign/economy.gd")
const Store=preload("res://src/persistence/save_store.gd")
const Table=preload("res://src/persistence/save_states/save2_table.gd")
const Controller=preload("res://src/persistence/save_states/save2_controller.gd")
const Session=preload("res://src/persistence/save_states/save2_session.gd")
const Save2Store=preload("res://src/persistence/save_states/save2_store.gd")
const Profiles=preload("res://src/persistence/profiles/profile_store.gd")
var checks=0
var failures=0
class FakeHost extends Node:
	var economy:Dictionary
	var store:Dictionary={"suspended":false}
	var active_started:=false
func check(ok,label):
	checks+=1
	if not ok:failures+=1;printerr("FAIL ",label)
func archive(ironman:bool)->Dictionary:
	return {"version":2,"unlocked":0,"completed":[],"settings":{},"upgrade":"endurance","economy":Economy.new_state("standard",ironman)}
func clean(path:String)->void:
	for suffix in ["",".bak",".tmp"]:DirAccess.remove_absolute(path+suffix)
func _initialize():call_deferred("run")
func run():
	records();locking();profiles()
	print("IRONMAN INTEGRITY CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
func records()->void:
	var live="user://ironman_live.save";clean(live)
	var manager=Save2Store.new(live)
	check(manager.save_manual(0,archive(true),"Iron slot",false,"missing") ,"ironman manual state writes")
	check(manager.save_manual(1,archive(false),"Plain slot",false,"missing") ,"non-ironman manual state writes")
	var iron=manager.inspect("manual",0);var plain=manager.inspect("manual",1)
	check(iron.status=="ready" and iron.record.ironman==true,"ironman flag is pinned in the SAVE2 record")
	check(plain.status=="ready" and plain.record.ironman==false,"non-ironman record pins false")
	var store=Store.new()
	var good=iron.data.duplicate(true);good[Table.RECORD]=iron.record.duplicate(true)
	check(store.valid(good),"pinned ironman record validates")
	var stripped=good.duplicate(true);stripped[Table.RECORD].ironman=false
	check(not store.valid(stripped),"record that disagrees with the sealed economy is rejected")
	var wrong=good.duplicate(true);wrong[Table.RECORD].ironman=1
	check(not store.valid(wrong),"non-bool ironman record field rejected")
	var legacy=plain.data.duplicate(true);legacy[Table.RECORD]=plain.record.duplicate(true);legacy[Table.RECORD].erase("ironman")
	check(store.valid(legacy),"record without the optional field still validates")
	var extra=legacy.duplicate(true);extra[Table.RECORD]["surprise"]=1
	check(not store.valid(extra),"record with an unknown extra field rejected")
	for index in 3:manager.delete_entry("manual",index,true,manager.inspect("manual",index).get("token","missing"))
	clean(live)
func locking()->void:
	var iron=FakeHost.new();iron.economy=Economy.new_state("standard",true)
	var plain=FakeHost.new();plain.economy=Economy.new_state("standard",false)
	check(Controller.locked(iron) and not Controller.locked(plain),"only an Ironman campaign is locked")
	check(not Controller.manual_allowed(iron) and Controller.manual_allowed(plain),"ironman hides new hard saves; non-ironman unchanged")
	check(not Session.restore(iron,"manual",0,"x") and iron.get_meta("save2_session_error","")==Table.IRONMAN_LINE,"restore refused for ironman with a plain reason")
	check(not Session.restore(iron,"fork",0,"x"),"fork replay refused for ironman")
	Table.ironman_lock=false
	check(not Controller.locked(iron) and Controller.manual_allowed(iron),"off switch restores the earlier behavior")
	Table.ironman_lock=true
	iron.free();plain.free()
func profiles()->void:
	var p=Profiles.new();p.directory="user://profile-ironman-fixture";p.legacy="user://legacy-ironman-fixture.save"
	DirAccess.make_dir_recursive_absolute(p.directory)
	var dir=DirAccess.open(p.directory)
	for file in dir.get_files():DirAccess.remove_absolute(p.directory+"/"+file)
	for suffix in p.Rules.SUFFIXES:DirAccess.remove_absolute(p.legacy+suffix)
	var legacy=Store.new();legacy.path=p.legacy
	check(legacy.save(archive(false)) and legacy.save(archive(false)),"fixture legacy archive")
	check(p.open(),"fixture profiles open")
	var slot0=Store.new();slot0.path=p.slot_path(0)
	var slot1=Store.new();slot1.path=p.slot_path(1)
	check(p.copy(0,1,true),"non-ironman profile copy unchanged")
	check(slot0.save(archive(true)) and slot0.save(archive(true)),"slot 0 becomes an Ironman campaign")
	var before=p.snapshot(1)
	check(not p.copy(0,1,true) and p.snapshot(1)==before and p.warning.contains("one timeline"),"ironman profile cannot be copied out")
	check(p.export_profile(0)=="" and p.warning.contains("one timeline"),"ironman profile cannot be exported")
	var plain=p.snapshot(1)
	check(not p.replace(0,plain,true) and p.snapshot(0)!=plain,"progress cannot replace an Ironman profile")
	check(p.clear(0,true) and p.snapshot(0)[""]==null,"clearing an Ironman profile ends that run and stays allowed")
	check(p.copy(1,0,true),"slot is ordinary again after clear")
	DirAccess.make_dir_recursive_absolute(p.directory)
