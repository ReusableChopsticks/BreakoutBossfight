extends CharacterBody2D
class_name Player

signal player_fallen(pos: Vector2)

func _physics_process(_delta):
	PlayerStats.player_pos = global_position

func handle_player_fallen_off(respawn_pos: Vector2):
	player_fallen.emit(respawn_pos)
