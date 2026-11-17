extends RefCounted
const Names=preload("res://src/names.gd")
# Shared role names only; sensing, movement and combat tuning stay with their owners.
# Revert by restoring the save checker list and the sweeper's literal role name.
const SWEEPER = Names.ROLE_SWEEPER
const ALL = [Names.ROLE_PATROLLER, Names.ROLE_SENTINEL, Names.ROLE_HUNTER, SWEEPER, Names.ROLE_BUOY, Names.ROLE_RELAY, Names.ROLE_INTERCEPTOR, Names.ROLE_WARDEN]
