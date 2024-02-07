extends Node
class_name HealthComponent

@export var max_health: int = 100
var health: int

func _ready():
	health = max_health

func damage(attack: Attack):
	health -= attack.attack_damage
	print("HEALTH: " + str(health))
	if health <= 0:
		print("HEALTH COMPONENT ANNOUNCES I AM DEAD")
