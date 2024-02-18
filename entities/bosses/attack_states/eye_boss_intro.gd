extends State
class_name EyeBossIntroState

@export var anim: AnimationMixer

func enter():
	anim.play("intro")

func update(delta: float):
	await anim.animation_finished
	transitioned.emit(self, "EyeBossIdleState")

func exit():
	pass
