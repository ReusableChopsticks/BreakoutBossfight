extends State
class_name EyeIntroState

@export var anim: AnimationMixer

func enter():
	anim.play("intro")
	await anim.animation_finished
	transitioned.emit(self, "EyeIdleState")

func update(delta: float):
	pass

func exit():
	pass
