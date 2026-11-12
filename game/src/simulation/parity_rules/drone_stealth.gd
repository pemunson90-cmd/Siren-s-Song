extends RefCounted
# WP-16 (parity_rules.gd, rules "calm_sirens_ignore_drones" and "quiet_drones").
# [PAT, 2026-11-12] On drones and Siren attention: "That's fine they should be
# stealthier than the sub but still able to fuck up and die". Pat then chose,
# from four options, "D with B": calm Sirens ignore drones, as the v7 prototype
# did ("destroy drones only when alerted/investigating (calm Sirens leave scouts
# alone)", prototype line 379), and drones are quieter.
#
# [AI-DESIGNED] Calm means: the Siren is not investigating, searching or
# locking, holds no target, and global Hunt is below SEARCHING. A calm Siren
# does not acquire a drone by sight. Once it is alerted for any reason (it heard
# something, it is locking Quietus, Hunt has risen) a drone in its sight is a
# target like any craft, with the same lock and beam. Hearing is unchanged
# except that a drone's movement noise reaches NOISE times as far.
const Rules=preload("res://src/simulation/parity_rules/parity_rules.gd")
const Hunt=preload("res://src/simulation/hunt_pressure/hunt_pressure.gd")
const NOISE=0.6
const ALERT_MODES=["INVESTIGATE","SEARCH","LOCKING"]
# Hunt stage index from which every Siren treats drones as targets (SEARCHING).
const ALERT_STAGE=2
static func calm(sim,siren:Dictionary)->bool:
 if str(siren.get("mode","")) in ALERT_MODES:return false
 if float(siren.get("lock",0.))>0. or int(siren.get("target",-1))>=0:return false
 return Hunt.stage(sim.mission)<ALERT_STAGE
# True when this Siren, as it is now, does not acquire this craft by sight.
static func ignores(sim,siren:Dictionary,unit_id:int)->bool:
 return unit_id>0 and Rules.on(sim.mission,"calm_sirens_ignore_drones") and calm(sim,siren)
static func noise(sim,unit_id:int)->float:
 return NOISE if unit_id>0 and Rules.on(sim.mission,"quiet_drones") else 1.0
