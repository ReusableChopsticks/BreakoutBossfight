extends State
class_name PlayerAttackState

@onready var anim: AnimationMixer = $"../PlayerNodeReferences".anim_player

func enter():
	anim.mixer_updated
	anim.play("attack")
	#await anim.animation_finished
	transitioned.emit(self, "PlayerMoveState")

