extends AttackState
class_name EyeRadialBeamAttack

@export var attack_node: RadialAttack

func enter():
	attack_node.attack()
	await attack_node.finished
	transitioned.emit(self, "EyeIdleState")
