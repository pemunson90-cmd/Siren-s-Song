extends RefCounted
# Shared role names only; sensing, movement and combat tuning stay with their owners.
# Revert by restoring the save checker list and the sweeper's literal role name.
const SWEEPER = "sweeper"
const ALL = ["patroller", "sentinel", "hunter", SWEEPER, "buoy", "relay", "interceptor", "warden"]
