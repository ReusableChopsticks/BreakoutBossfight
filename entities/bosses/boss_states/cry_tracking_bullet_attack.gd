extends AttackState
class_name EyeTrackingBulletAttack

@export var attack_node: BaseAttack
@export var delay_before_attack_finished: float = 2

func enter():
	attack_node.attack()
	await attack_node.finished
	await get_tree().create_timer(delay_before_attack_finished).timeout
	transitioned.emit(self, "EyeIdleState")
