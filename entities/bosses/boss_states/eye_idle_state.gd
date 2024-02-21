extends State
class_name EyeIdleState

@export var idle_time: float = 4
@export var anim: AnimationPlayer


func enter():
	anim.play("idle")
	await get_tree().create_timer(idle_time).timeout
	transitioned.emit(self, "EyeChooseAttack")

func update(_delta: float):
	pass

func exit():
	pass
