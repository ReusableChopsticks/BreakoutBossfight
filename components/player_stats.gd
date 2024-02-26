extends Node

"""
Global player stats!!!
"""
# global pos of player
var player_pos: Vector2
var health: int = 0:
	set(val):
		health = val
		player_health_updated.emit(val)

signal player_health_updated(val: int)

#region Movement
# always either left (-1) or right (1)
@export var facing_dir: int = 1
const LEFT = -1
const RIGHT = 1
func get_facing_dir() -> String:
	if facing_dir == -1:
		return "left"
	elif facing_dir == 1:
		return "right"
	else:
		printerr("facing_dir var in PlayerStats is somehow not 1 or -1???")
		return ""
#endregion
