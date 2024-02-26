extends State
class_name EyeIntroState

@export var anim: AnimationPlayer

func enter():
	anim.play("intro")
	await anim.animation_finished
	transitioned.emit(self, "EyeIdleState")

func update(_delta: float):
	pass

func exit():
	pass
