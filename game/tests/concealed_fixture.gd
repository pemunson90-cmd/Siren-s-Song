extends RefCounted
# Test-only own-position fixture for older custody/UI assertions. This executes
# real local commands and actual reply time, but is never journey evidence.
static func solve(sim)->void:
 if sim.mission.get("id")!=12 or not sim.mission.has("concealed_harbour") or sim.mission.witness_evacuation.state not in ["carried","landed","salvage"] or sim.mission.concealed_harbour.receipt:return
 var body=sim.units[0].duplicate(true);var selected=sim.selected;var paused=sim.paused
 var shelf=sim.mission.concealed_harbour.thread=="shelf"
 sim.selected=0;sim.units[0].pos=Vector2(1940,1040) if shelf else Vector2(1840,1010);sim.units[0].vel=Vector2.ZERO;sim.units[0].route=[];sim.units[0].hold=""
 if sim.command("concealed_tow",{"action":"attach"}):
  sim.units[0].pos=Vector2(1920,990) if shelf else Vector2(1840,850);sim.paused=false
  sim.advance(1./60.)
  if shelf:sim.command("concealed_tow",{"action":"service"})
  for n in 132:sim.advance(1./60.)
  if not shelf:sim.command("concealed_tow",{"action":"release"})
 sim.units[0]=body;sim.selected=selected;sim.paused=paused
