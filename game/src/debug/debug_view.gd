extends PanelContainer
# Touch-first scrolling developer panel. All interactive rows use the host's 48dp metric.
# WP-120: the QUICK block at the top runs the console's commands from buttons (no typing). Debug builds only:
# debug_console.gd installs this panel and is itself never created in a release build.
const HELP="jump 0..41 | preset deep/shelf concealed/overt none/concealed/overt found/absent\nfact KEY VALUE | clear KEY | complete OP | grant ID [COUNT] | granttools | unlock\noverlay sight/hearing/patrol/hunt/locks/noise/endurance/cargo/chart\ntime 0.25..16 | step | invulnerable [on/off] | known | oxygen [lock/unlock] | win | lose | end | export | help\nProfile/run changes permanently mark DEV. Setup commands apply between dives."
const SPEEDS=[1,2,4,8,16]
var console
var output:Label
var entry:LineEdit
var body:VBoxContainer
var thread="deep"
var channel="concealed"
var votes="none"
var sorley="absent"
var op=0
func _ready()->void:mouse_filter=Control.MOUSE_FILTER_STOP
func _process(_dt)->void:
 var extent=console.host.size
 position=Vector2(12,12);size=extent-Vector2(24,24)
func _make(text:String,id:String,parent:Control)->Button:
 var b=Button.new();b.text=text;b.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
 b.custom_minimum_size.y=maxf(48,console.host.ui_touch_height);b.set_meta("ui_action","dev_"+id)
 if parent!=null:b.size_flags_horizontal=Control.SIZE_EXPAND_FILL
 (parent if parent!=null else body).add_child(b);return b
func button(text:String,callback:Callable,id:String="",parent:Control=null)->Button:
 var b=_make(text,id,parent);b.pressed.connect(callback,CONNECT_DEFERRED);return b
func run(command:String)->void:
 output.text=console.execute(command)
# A grid cell whose label follows a state the command changes (label.call() gives the new text).
func toggle(parent:Control,label:Callable,command:Callable,id:String)->Button:
 var b=_make(label.call(),id,parent)
 b.pressed.connect(func():run(command.call());b.text=label.call(),CONNECT_DEFERRED)
 return b
func on_off(value)->String:return "ON" if value else "OFF"
# WP-120: the quick block. Order: speed, survival, oxygen, reveal, operations, dive end, hardware, overlays.
func quick()->void:
 var head=Label.new();head.text="QUICK";body.add_child(head)
 var grid=GridContainer.new();grid.columns=3 if console.host.size.x>900 else 2;grid.size_flags_horizontal=Control.SIZE_EXPAND_FILL
 grid.add_theme_constant_override("h_separation",6);grid.add_theme_constant_override("v_separation",6);body.add_child(grid)
 for speed in SPEEDS:
  var s=speed
  toggle(grid,func():return "SPEED %dx%s"%[s,"  <" if is_equal_approx(console.time_scale,float(s)) else ""],func():return "time "+str(s),"speed_%d"%s)
 toggle(grid,func():return "INVULNERABLE: "+on_off(console.invulnerable),func():return "invulnerable off" if console.invulnerable else "invulnerable on","invulnerable")
 button("OXYGEN REFILL",func():run("oxygen"),"oxygen",grid)
 toggle(grid,func():return "OXYGEN LOCK: "+on_off(console.oxygen_locked),func():return "oxygen unlock" if console.oxygen_locked else "oxygen lock","oxygen_lock")
 button("REVEAL CHARTS AND OBJECTIVES",func():run("known"),"known",grid)
 button("WIN DIVE NOW",func():run("win");hide(),"win",grid)
 button("LOSE DIVE NOW",func():run("lose");hide(),"lose",grid)
 button("UNLOCK ALL HARDWARE",func():run("unlock"),"unlock",grid)
 button("GRANT TOOLS",func():run("granttools"),"granttools",grid)
 for layer in console.Overlay.LAYERS:
  var key=layer
  toggle(grid,func():return "OVERLAY %s: %s"%[key.to_upper(),on_off(console.layers.get(key,false))],func():return "overlay "+key,"overlay_"+key)
 # JUMP TO operation: every registered operation by its number as the dive title shows it, and its name.
 var jump=Label.new();jump.text="JUMP TO OPERATION";body.add_child(jump)
 var picker=OptionButton.new();picker.custom_minimum_size.y=maxf(48,console.host.ui_touch_height);body.add_child(picker)
 for id in console.Catalog.registered_ids():picker.add_item("%02d  %s"%[id+1,console.Catalog.make(id).get("title",str(id))],id)
 picker.select(picker.get_item_index(op));picker.item_selected.connect(func(index):op=picker.get_item_id(index))
 var jumps=GridContainer.new();jumps.columns=2;jumps.size_flags_horizontal=Control.SIZE_EXPAND_FILL;body.add_child(jumps)
 button("JUMP TO SELECTED",func():run("jump "+str(op)),"jump",jumps)
 button("COMPLETE SELECTED",func():
  if console.host.active_started and console.host.sim.outcome.is_empty():run("end")
  run("complete "+str(op)),"complete",jumps)
func rebuild()->void:
 for child in get_children():remove_child(child);child.queue_free()
 var scroll=ScrollContainer.new();scroll.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED;add_child(scroll)
 body=VBoxContainer.new();body.size_flags_horizontal=Control.SIZE_EXPAND_FILL;scroll.add_child(body)
 button("CLOSE DEVELOPER CONSOLE",func():hide(),"close")
 output=Label.new();output.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;output.text=HELP;body.add_child(output)
 quick()
 entry=LineEdit.new();entry.placeholder_text="Command (desktop history: Up / Down)";entry.custom_minimum_size.y=maxf(48,console.host.ui_touch_height);body.add_child(entry)
 entry.text_submitted.connect(func(line):run(line);entry.clear())
 entry.gui_input.connect(func(event):
  if event is InputEventKey and event.pressed and event.keycode in [KEY_UP,KEY_DOWN] and not console.history.is_empty():
   console.history_index=clampi(console.history_index+(-1 if event.keycode==KEY_UP else 1),0,console.history.size())
   entry.text=console.history[console.history_index] if console.history_index<console.history.size() else "";entry.caret_column=entry.text.length();accept_event())
 button("RUN COMMAND",func():run(entry.text);entry.clear(),"command")
 button("THREAD: "+thread.to_upper(),func():thread="shelf" if thread=="deep" else "deep";rebuild(),"thread")
 button("CONFLUENCE: "+channel.to_upper(),func():channel="overt" if channel=="concealed" else "concealed";rebuild(),"channel")
 button("LATE VOTES: "+votes.to_upper(),func():votes={"none":"concealed","concealed":"overt","overt":"none"}[votes];rebuild(),"votes")
 button("SORLEY: "+sorley.to_upper(),func():sorley="found" if sorley=="absent" else "absent";rebuild(),"sorley")
 button("END DEV DIVE / RETURN TO SETUP",func():run("end"),"end")
 button("APPLY HISTORY PRESET",func():run("preset %s %s %s %s"%[thread,channel,votes,sorley]),"preset")
 # Touch selectors retain a keyboard-free path to every fact and grant command.
 var facts=OptionButton.new();facts.custom_minimum_size.y=maxf(48,console.host.ui_touch_height);body.add_child(facts)
 for key in console.Catalog.fact_keys():facts.add_item(key)
 var value=LineEdit.new();value.placeholder_text="Fact value";value.custom_minimum_size.y=maxf(48,console.host.ui_touch_height);body.add_child(value)
 button("SET SELECTED FACT",func():run("fact "+facts.get_item_text(facts.selected)+" "+value.text),"fact")
 button("CLEAR SELECTED FACT",func():run("clear "+facts.get_item_text(facts.selected)),"clear")
 var grants=OptionButton.new();grants.custom_minimum_size.y=maxf(48,console.host.ui_touch_height);body.add_child(grants)
 var ids=console.State.Equipment.ITEMS.keys()+console.host.economy.stock.keys()+preload("res://src/campaign/economy_table.gd").UNLOCK_PRICE.keys()+console.Tools.ids()
 for id in ids:grants.add_item(id)
 button("GRANT SELECTED (ONE)",func():run("grant "+grants.get_item_text(grants.selected)),"grant")
 for item in [["ONE PAUSED TICK","step"],["EXPORT RUN LOG","export"]]:
  var command=item[1];button(item[0],func():run(command),command)
