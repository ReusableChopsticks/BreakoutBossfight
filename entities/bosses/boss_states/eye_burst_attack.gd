extends AttackState
class_name EyeBurstAttack

@export var attack_node: BaseAttack

func enter():
	attack_node.attack()
	await attack_node.finished
	transitioned.emit(self, "EyeIdleState")
	
func exit():
	pass

func update(_delta: float):
	pass
	
func physics_update(_delta: float):
	pass
