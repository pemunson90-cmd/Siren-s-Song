extends RefCounted
const Sim=preload("res://src/simulation/simulation.gd")
class Voyage:
 extends "res://src/simulation/simulation.gd"
 var hunt_peak=0.
 var lock_seconds=0.
 var heard_frames=0
 var silent_throughout=true
 var orders=[]
 var heard_by={}
 var use_flash=true
 func command(order:String,args:Dictionary={})->bool:
  orders.append(order)
  return super.command(order,args)
 func advance(dt:float)->void:
  silent_throughout=silent_throughout and units[0].silent
  var before=elapsed
  super.advance(dt)
  silent_throughout=silent_throughout and units[0].silent
  hunt_peak=maxf(hunt_peak,float(mission.get("reconnaissance",{}).get("hunt",0.)))
  if elapsed<=before:return
  if contacts.values().any(func(c):return elapsed-c.time<.4 and c.get("lock",0)>0):lock_seconds+=elapsed-before
 func _heard_arrival(enemy:Dictionary)->Dictionary:
  var arrival=super._heard_arrival(enemy)
  if arrival.get("player_craft",false):
   heard_frames+=1;heard_by[sirens.find(enemy)]=int(heard_by.get(sirens.find(enemy),0))+1
  return arrival
 func metrics()->Dictionary:
  return {"op":mission.id,"outcome":outcome,"time":elapsed,"hull":hull,"oxygen":oxygen,"hunt":hunt_peak,"lock":lock_seconds,"heard_frames":heard_frames,"heard_by":heard_by,"silent":silent_throughout,"flash_left":Photo.flash_left(self,0),"shots":mission.get("photo",{}).get("shots",[]).map(func(shot):return {"key":shot.key,"q":shot.q,"flash":shot.flash,"usable":shot.usable})}
static func tick(s,seconds):
 s.paused=false
 for n in ceili(seconds*60):
  s.advance(1./60)
  if not s.outcome.is_empty():break
 s.paused=true
static func shift(s,id,band)->bool:
 s.command("select",{"unit":id})
 if s.units[id].band==band:return true
 if not s.command("depth",{"band":band}):return false
 tick(s,4.1);return s.units[id].band==band and s.units[id].transition.is_empty()
static func go(s,id,point)->bool:
 s.command("select",{"unit":id})
 if not s.command("route",{"point":point}):return false
 s.paused=false
 for n in 18000:
  s.advance(1./60)
  if not s.outcome.is_empty():break
  if s.units[id].pos.distance_to(point)<18 and s.units[id].vel.length()<2:break
 s.paused=true
 return s.units[id].alive and s.units[id].pos.distance_to(point)<25
static func record(s,id,index,framed=false)->bool:
 s.command("select",{"unit":id})
 var o=s.mission.objectives[index]
 if framed:
  if not s.command("frame",{"mode":"wide","focus":o.optical,"flash":index==0 and s.use_flash}):return false
  tick(s,3.)
 if not s.command("camera"):return false
 tick(s,float(o.get("duration",4.))+.3)
 return o.captured
static func play(id:int,band:int,voyage=null,flash:bool=true,launch:Dictionary={}):
 var s=Voyage.new() if voyage==null else voyage;s.use_flash=flash
 var config={"tool_racks":preload("res://src/equipment/tool_racks.gd").empty(),"fitted":{"quietus":"photo_flash" if id==39 else "","drone_a":"","drone_b":""}}
 config.merge(launch,true);s.start(id,"endurance",config)
 var ok=true
 if id==3:
  ok=shift(s,0,2) and go(s,0,Vector2(960,500))
  s.command("select",{"unit":1});s.command("drone_drive",{"mode":"quiet"})
  ok=go(s,1,Vector2(1090,580)) and record(s,1,0) and ok
  s.command("select",{"unit":1});s.command("drone_drive",{"mode":"transit"});s.command("route",{"point":Vector2(1080,820)})
  ok=go(s,0,Vector2(1060,580)) and go(s,0,Vector2(1060,820)) and ok
  ok=shift(s,0,band) and ok
  ok=go(s,0,Vector2(1110,820)) and record(s,0,1) and ok
  ok=shift(s,0,1) and go(s,0,s.mission.extraction) and ok
 else:
  for p in [Vector2(550,300),Vector2(1430,300)]:ok=go(s,0,p) and ok
  ok=record(s,0,1,true) and ok
  for p in [Vector2(550,300),Vector2(530,700)]:ok=go(s,0,p) and ok
  ok=record(s,0,0,true) and ok
  ok=shift(s,0,band) and ok
  for p in [Vector2(650,820),Vector2(1850,820)]:ok=go(s,0,p) and ok
  for p in [Vector2(2250,820),Vector2(2450,700)]:ok=go(s,0,p) and ok
  ok=shift(s,0,1) and ok
  for p in [Vector2(2800,1450),s.mission.extraction]:ok=go(s,0,p) and ok
  tick(s,1.)
 var r=s.metrics();r.accepted=ok;r.band=band
 return {"sim":s,"metrics":r}
