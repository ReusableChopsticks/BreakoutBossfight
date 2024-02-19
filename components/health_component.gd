extends Node
class_name HealthComponent

@export var max_health: int = 100
var health: int

func _ready():
	health = max_health

func damage(attack: Attack):
	health -= max(attack.attack_damage, 0)
	if health > 0:
		print("HEALTH: " + str(health))
	if health == 0:
		print(get_parent().name + " IS DEAD")
