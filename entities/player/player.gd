extends CharacterBody2D

var direction
@export var move_speed = 200

func _process(delta):
	direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * move_speed
	move_and_slide()
