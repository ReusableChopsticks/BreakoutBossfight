extends State
class_name EyeBossIdleState

@export var idle_time: float = 4
@export var anim: AnimationPlayer
var time: float = 0

func enter():
	anim.play("idle")

func update(delta: float):
	time += delta
	if time >= idle_time:
		transitioned.emit(self, "DecideAttack")

func exit():
	pass
