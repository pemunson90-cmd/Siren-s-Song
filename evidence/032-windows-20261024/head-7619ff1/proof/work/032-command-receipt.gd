extends SceneTree
# Evidence supplement only, linked to the native fixture by complete state hash.
# Frozen game code is unchanged. This probe never claims a GPU-render command row.
const Sim=preload("res://src/simulation/simulation.gd")
const Art=preload("res://src/presentation/art/art_renderer.gd")
const Table=preload("res://src/presentation/art/art_table.gd")
var checks=0
var failures=0
var folder=""
func _initialize():call_deferred("run")
func check(ok,label):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func digest(state):return var_to_bytes(state).hex_encode().sha256_text()
func save_state(name,state):
 var file=FileAccess.open(folder.path_join(name+".bin"),FileAccess.WRITE)
 file.store_buffer(var_to_bytes(state));file.close()
func run():
 var native=""
 for arg in OS.get_cmdline_user_args():
  if arg.begins_with("--folder="):folder=arg.trim_prefix("--folder=")
  if arg.begins_with("--native="):native=arg.trim_prefix("--native=")
 if folder.is_empty() or native.is_empty():printerr("Probe needs explicit output and native result paths");quit(1);return
 DirAccess.make_dir_recursive_absolute(folder)
 var data=JSON.parse_string(FileAccess.get_file_as_string(native))
 if not data is Array or data.size()!=120:printerr("Probe requires the completed120-row native packet");quit(1);return
 var objects=Performance.get_monitor(Performance.OBJECT_COUNT)
 var memory=Performance.get_monitor(Performance.MEMORY_STATIC)
 var at=Time.get_ticks_usec();Art.prepare()
 var cache={"scope":"one-time geometry/palette initialization, headless CPU; excludes texture load/GPU allocation","usec":Time.get_ticks_usec()-at,"objects_delta":Performance.get_monitor(Performance.OBJECT_COUNT)-objects,"static_bytes_delta":Performance.get_monitor(Performance.MEMORY_STATIC)-memory,"outlines":Art.outlines.size(),"uvs":Art.uvs.size(),"texture_shades":Art.texture_shades.size(),"lamp_vertices":Art.lamp.size(),"lamp_colors":Art.lamp_colors.size()}
 var records=[]
 for dimensions in [Vector2i(2520,1080),Vector2i(2184,1968)]:
  for scene in 3:
   # Kept identical to art_render_measurements.gd setup at7619ff1. Native rows
   # must match this exact complete snapshot before linking a command receipt.
   var s=Sim.new();s.start(0,"endurance");s.paused=true;s.elapsed=10.
   s.units[0].pos=Vector2(360,450);s.units[0].angle=0.
   s.units[1].pos=Vector2(370,550);s.units[1].angle=0.
   s.units[2].pos=Vector2(370,650);s.units[2].angle=0.
   s.contacts={}
   for n in 5:
    s.contacts[n]={"pos":[Vector2(700,180),Vector2(860,130),Vector2(720,380),Vector2(850,520),Vector2(700,650)][n],"angle":0.,"type":["patroller","sentinel","sweeper","hunter","hunter"][n],"time":10. if n<4 else 6.,"mode":"PATROL","lock":0.,"target":-1,"band":1}
   if scene in [1,2]:
    s.units[0].pos=s.mission.objectives[0].pos-Vector2(130,0)
    if scene==1:
     s.mission["earned_terrain"]=true;s.mission["world_size"]=Vector2(1600,960);s.mission["region_revision"]=1
     s.mission["launch_seed"]=Rect2(s.units[0].pos-Vector2(80,80),Vector2(160,160))
     s._configure_terrain();s._configure_depth_charts()
    if scene==2:
     # The native lamp test restores this complete state before timed blocks.
     var saved=s.snapshot();check(s.restore(saved),"reproduce native lamp-test restore")
   var before=s.snapshot();var state_hash=digest(before)
   var name="%dx%d-scene%d"%[dimensions.x,dimensions.y,scene]
   var matches=0
   for row in data:
    if str(row.name).begins_with(name+"-"):
     matches+=1
     check(row.snapshot==state_hash and row.snapshot_after==state_hash,"initial complete state links native row "+str(row.name)+" block"+str(row.block))
   check(matches==20 and Sim.valid_snapshot(before),"linked20 native rows have valid state "+name)
   var reference=Sim.new();var restored=reference.restore(before)
   check(restored,"exact reference restores "+name)
   var reference_accepted=reference.command("select",{"unit":1}) if restored else false
   var reference_hash=digest(reference.snapshot()) if restored else ""
   var accepted=s.command("select",{"unit":1});var after=s.snapshot()
   check(accepted==reference_accepted and digest(after)==reference_hash and Sim.valid_snapshot(after),"ordinary command accepts and preserves complete reference state "+name)
   save_state(name+"-before",before);save_state(name+"-after-command",after)
   records.append({"name":name,"native_rows":matches,"before_hash":state_hash,"after_native_draw_hash":state_hash,"command":{"name":"select","args":{"unit":1}},"accepted":accepted,"reference_accepted":reference_accepted,"after_command_hash":digest(after),"reference_command_hash":reference_hash,"valid_before":Sim.valid_snapshot(before),"valid_after":Sim.valid_snapshot(after)})
   s=null;reference=null
 var file=FileAccess.open(folder.path_join("command-receipts.json"),FileAccess.WRITE)
 file.store_string(JSON.stringify({"scope":"separate headless command receipt linked to all native rows by exact full state hash","state_hash_algorithm":"SHA256 of hexadecimal var_to_bytes(snapshot), matching native fixture","cache":cache,"rows":records}));file.close()
 print("ART COMMAND RECEIPT CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
