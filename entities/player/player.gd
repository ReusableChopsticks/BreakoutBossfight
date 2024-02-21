extends CharacterBody2D
class_name Player

func _physics_process(_delta):
	PlayerStats.player_pos = global_position
