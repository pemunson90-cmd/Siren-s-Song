extends RefCounted
const Names=preload("res://src/names.gd")
# 098 next-launch controls use the host's 48 dp scrolling buttons and ordinary Fittings Back route.
# Revert: Racks.enabled=false. No writes to a launched dive, including Ironman.
# WP-44: one row per tool, true-scale space bars, plain sentences. Rules, saves and action ids are unchanged.
const Racks=preload("res://src/equipment/tool_racks.gd")
const Tools=preload("res://src/equipment/field_tools.gd")
const Catalog=preload("res://src/equipment/equipment_catalog.gd")
const Economy=preload("res://src/campaign/economy.gd")
const UiStyle=preload("res://src/presentation/ui_style.gd")
const FitBar=preload("res://src/presentation/fit_surface/fit_bar.gd")
const FitCard=preload("res://src/presentation/fit_surface/fit_card.gd")
const HEADING="TOOLS FOR THE NEXT DIVE"
const SUB_FITTINGS="Each craft uses the tools it carries. Tools fill a craft's locker first, then its cargo space."
const SUB_EXPEDITION="Tools you unload stay ashore for later operations."
const SUB_CAREER="Extra charges cost career supplies at every launch."
const QUICK_FILL="QUICK FILL"
const COST_FREE="Extra charges for the next launch: free."
const COST_PAID="Extra charges for the next launch cost %s."
const COST_NOTE="The quick fills are free; anything you add on top is paid for at every launch."
const FULL_RACKS_HINT=". Unload charges or choose a larger frame before launch."
const QUIETUS_ONLY_NOTE="Torpedoes and hull patches fit the Quietus only."
const DRONE_NOTE="Tools you load here deploy from this drone. "
const NO_TOOLS="%s carries no tools."
const CARRIES="%s carries: %s."
const DETAIL="Takes %d%% of a locker."
const LOCKER_BAR="LOCKER"
const CARGO_BAR="CARGO"
# Plain sentences for the load_reason codes (the codes stay internal).
const REASONS={"SAVE PENDING":"Save the expedition first.","RACK FULL":"This craft already carries the most allowed.","CARGO FULL":"Locker and cargo are full.","NONE ASHORE":"None left in expedition stock."}
# Wording that is not the field_tools name: singular noun, plural noun.
const NOUNS={"recon":"survey charge"}
const PLURALS={"knock":"torpedoes"}
static func _redraw(host,action:Callable)->void:
 var position=host.scroll.scroll_vertical
 action.call();host._save_archive();host._show_fittings()
 var heading=host.panel_box.get_child(0)
 (func():
  await host.get_tree().process_frame
  if is_instance_valid(heading) and heading.get_parent()==host.panel_box:host.scroll.scroll_vertical=position
 ).call_deferred()
static func fill(host,choice:String)->void:
 host.upgrade=choice;host.tool_racks=Racks.template(choice)
static func edit(host,slot:String,id:String,delta:int,stock:Dictionary={},stock_limited:bool=false)->bool:
 if not Racks.enabled:return false
 var next=host.tool_racks.duplicate(true)
 next[slot][id]=int(next[slot].get(id,0))+delta
 if not Racks.valid(next):return false
 if stock_limited and not Racks.available(next,stock):return false
 # Unloading is always possible, even after choosing a smaller frame.
 if delta>0 and not Racks.reason(host.fitted_equipment,next).is_empty():return false
 host.tool_racks=next
 return true
static func show_mode(host,is_run:bool,change:Callable)->void:
 if not Racks.enabled:return
 host._menu_text(HEADING,19)
 host._menu_text(SUB_EXPEDITION if is_run else SUB_CAREER,15)
 var why=Racks.reason(host.fitted_equipment,host.tool_racks)
 if not why.is_empty():host._menu_text(why,15)
 for slot in Racks.UNITS:
  host._menu_text(Catalog.NAMES[slot],17)
  _bars(host,Racks.UNITS.find(slot))
  controls(host,[slot],change,"mode_rack",host.run_state.stock if is_run else {},false,is_run)
# One row per tool: name, count and detail on the left; minus and plus on the right.
static func controls(host,slots:Array,change:Callable,prefix:String,stock:Dictionary={},_detailed:bool=false,stock_limited:bool=false)->void:
 if not Racks.enabled:return
 for slot in slots:
  for id in Tools.ids():
   if slot!=Names.CRAFT_QUIETUS and id in Racks.QUIETUS_ONLY:continue
   if id in Tools.field_ids() and not Tools.is_enabled(id):continue
   var n=int(host.tool_racks[slot].get(id,0))
   var candidate=host.tool_racks.duplicate(true);candidate[slot][id]=n+1
   var slot_key=slot+"_" if prefix=="mode_rack" else ""
   var row=HBoxContainer.new();row.size_flags_horizontal=Control.SIZE_EXPAND_FILL;host.panel_box.add_child(row)
   var left=VBoxContainer.new();left.size_flags_horizontal=Control.SIZE_EXPAND_FILL;row.add_child(left)
   _text(host,left,"%s · %d"%[Tools.spec(id).name,n],UiStyle.RACK_TEXT_SIZE)
   _text(host,left,DETAIL%roundi(Tools.CARGO_WEIGHTS[id]*100.0/Racks.locker_ticks(Racks.UNITS.find(slot))),UiStyle.RACK_DETAIL_SIZE)
   var remove=_step(host,row,UiStyle.RACK_MINUS,change.bind(slot,id,-1),prefix+"_remove_"+slot_key+id)
   remove.disabled=(prefix=="mode_rack" and host.save_failed) or n<=0
   var add=_step(host,row,UiStyle.RACK_PLUS,change.bind(slot,id,1),prefix+"_add_"+slot_key+id)
   add.disabled=(prefix=="mode_rack" and host.save_failed) or not Racks.valid(candidate) or not Racks.reason(host.fitted_equipment,candidate).is_empty() or (stock_limited and not Racks.available(candidate,stock))
   if add.disabled:
    var why=REASONS.get(load_reason(host,candidate,prefix,stock,stock_limited),"")
    add.tooltip_text=why
    if not why.is_empty():_text(host,host.panel_box,why,UiStyle.RACK_DETAIL_SIZE)
static func _step(host,row:Node,text:String,action:Callable,action_id:String)->Button:
 var button=host._button(row,text,action,action_id)
 button.custom_minimum_size=Vector2(host.ui_touch_height,host.ui_touch_height)
 return button
static func _text(host,parent:Node,text:String,size:int)->Label:
 var scaled=roundi(size*host.ui_touch_height/48.0*preload("res://src/presentation/frontend/frontend_settings.gd").text_scale())
 var label=host._label(parent,text,scaled);label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;label.size_flags_horizontal=Control.SIZE_EXPAND_FILL
 label.custom_minimum_size.x=120
 return label
# Two true-scale bars for one craft: locker held out of its locker, cargo used out of its cap.
static func _bars(host,unit:int)->void:
 var b=Catalog.budget(host.fitted_equipment,unit)
 var used=b.cargo+Racks.cargo(host.tool_racks,unit)
 var locker=float(Racks.locker_ticks(unit));var held=float(Racks.locker_used_ticks(host.tool_racks,unit))
 var row=HBoxContainer.new();row.size_flags_horizontal=Control.SIZE_EXPAND_FILL;host.panel_box.add_child(row)
 FitBar.add(host,row,LOCKER_BAR,held,locker,"%d%%"%roundi(held*100.0/locker),held>locker)
 FitBar.add(host,row,CARGO_BAR,used,float(b.cargo_cap),"%s of %s"%[_num(used),_num(b.cargo_cap)],used>b.cargo_cap)
static func _num(value)->String:
 return str(roundi(value)) if is_equal_approx(value,roundf(value)) else "%.2f"%value
# WP-11 (I6): a grey plus names its reason in words and in its tooltip. Checks run in the same order as disabled.
static func load_reason(host,candidate:Dictionary,prefix:String,stock:Dictionary,stock_limited:bool)->String:
 if prefix=="mode_rack" and host.save_failed:return "SAVE PENDING"
 if not Racks.valid(candidate):return "RACK FULL"
 if not Racks.reason(host.fitted_equipment,candidate).is_empty():return "CARGO FULL"
 if stock_limited and not Racks.available(candidate,stock):return "NONE ASHORE"
 return ""
# What each craft carries, in words, with zero counts left out.
static func carry_text(racks:Dictionary)->String:
 var lines=[]
 for slot in Racks.UNITS:
  var parts=[]
  for id in Tools.ids():
   if id in Tools.field_ids() and not Tools.is_enabled(id):continue
   var n=int(racks.get(slot,{}).get(id,0))
   if n>0:parts.append("%d %s"%[n,_noun(id,n)])
  var who=Catalog.NAMES[slot].capitalize()
  lines.append(CARRIES%[who,", ".join(parts)] if not parts.is_empty() else NO_TOOLS%who)
 return "\n".join(lines)
static func _noun(id:String,n:int)->String:
 var name:String=Tools.spec(id).name
 if name==name.to_upper():return name
 if n==1:return NOUNS.get(id,name.to_lower())
 return PLURALS.get(id,NOUNS.get(id,name.to_lower())+"s")
static func show(host)->void:
 if not Racks.enabled:return
 host._menu_text(HEADING,19)
 host._menu_text(SUB_FITTINGS,15)
 host._menu_text(QUICK_FILL,15)
 for choice in Tools.LOADOUTS:
  var oxygen=host._loadout_stock(choice)[0]
  FitCard.add(host,{"name":"%s · OXYGEN %d%%"%[Tools.loadout_label(choice),oxygen],"chosen":host.tool_racks==Racks.template(choice)},func():_redraw(host,func():fill(host,choice)),"tools_loadout_"+choice)
 for unit in 3:
  host._menu_text(Catalog.NAMES[Racks.UNITS[unit]],15)
  _bars(host,unit)
 var why=Racks.reason(host.fitted_equipment,host.tool_racks)
 if not why.is_empty():host._menu_text(why+FULL_RACKS_HINT,15)
 var cost=Economy.fmt(Racks.cost(host.tool_racks,host.upgrade,host.economy))
 host._menu_text(COST_FREE if cost.is_empty() or cost==Economy.fmt({}) else COST_PAID%cost.to_lower(),15)
 host._menu_text(COST_NOTE,15)
 host._button(host.panel_box,"EMPTY ALL RACKS",func():_redraw(host,func():host.tool_racks=Racks.empty()),"rack_empty")
 var selected=host.get_meta("rack_craft",Names.CRAFT_QUIETUS)
 var picker=HBoxContainer.new();picker.size_flags_horizontal=Control.SIZE_EXPAND_FILL;host.panel_box.add_child(picker)
 for slot in Racks.UNITS:
  var button=host._button(picker,"EDIT "+Catalog.NAMES[slot],func():_redraw(host,func():host.set_meta("rack_craft",slot)),"rack_craft_"+slot)
  button.size_flags_horizontal=Control.SIZE_EXPAND_FILL
  UiStyle.apply_card(button,slot==selected,false)
  button.disabled=slot==selected
 host._menu_text(Catalog.NAMES[selected]+": "+(QUIETUS_ONLY_NOTE if selected==Names.CRAFT_QUIETUS else DRONE_NOTE+QUIETUS_ONLY_NOTE),15)
 controls(host,[selected],func(slot,id,delta):_redraw(host,func():edit(host,slot,id,delta)),"rack",{},true)
