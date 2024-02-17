extends State
class_name IdleBob

@export var boss: CharacterBody2D

var anim: AnimationPlayer

func enter():
	anim = boss.get_node("AnimationPlayer")
	anim.play("test")

func exit():
	anim.stop()
