extends AttackState
class_name CryRainAttack

@export var attack_node: BaseAttack
@export var tear_drop_amount = 15
@export var interval := 0.05
@export var max_x_velocity = 1000
@export var y_vel = 500

func enter():
	for i in range(tear_drop_amount):
		var x = randi_range(-max_x_velocity, max_x_velocity)
		var y = y_vel + randi_range(-100, 100)
		attack_node.start_velocity = Vector2(x, y)
		attack_node.attack()
		await get_tree().create_timer(interval).timeout
	#await attack_node.finished
	transitioned.emit(self, "EyeIdleState")
	
func exit():
	pass

func update(_delta: float):
	pass
	
func physics_update(_delta: float):
	pass
