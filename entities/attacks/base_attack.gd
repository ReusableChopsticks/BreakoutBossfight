extends Node2D
class_name BaseAttack

# if set to true, call the attack on _ready() to see how it looks
@export var set_preview: bool = false

func preview_attack():
	if set_preview:
		call("attack")
