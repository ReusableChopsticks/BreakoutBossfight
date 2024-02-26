extends State
class_name EyeIdleState

@export var idle_time: float = 4
@export var anim: AnimationPlayer

@onready var eye_anim := $"../../Eye/Animations/EyeAnimationPlayer"

func enter():
	eye_anim.play("close_eye")
	await eye_anim.animation_finished
	eye_anim.queue("open_eye")
	$"../../Eye/Eyeball/Iris".frame = 0
	anim.play("idle")
	await get_tree().create_timer(idle_time).timeout
	transitioned.emit(self, "EyeChooseAttack")

func update(_delta: float):
	pass

func exit():
	pass
