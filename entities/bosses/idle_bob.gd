extends State
class_name IdleBob

@export var boss: CharacterBody2D
# how long boss should idle before choosing next attack
@export var idle_time: float = 4

var anim: AnimationPlayer

func enter():
	anim = boss.get_node("AnimationPlayer")
	anim.play("idle")
	await get_tree().create_timer(idle_time).timeout
	transitioned.emit()

func exit():
	anim.stop()
