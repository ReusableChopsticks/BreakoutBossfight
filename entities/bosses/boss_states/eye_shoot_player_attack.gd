extends AttackState
class_name EyeShootPlayerAttack

@export var attack_node: DirectionAttack

func enter():
	attack_node.attack()
	await attack_node.finished
	transitioned.emit(self, "EyeIdleState")
