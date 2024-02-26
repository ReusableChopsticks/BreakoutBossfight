extends HealthComponent
class_name PlayerHealthComponent

func _ready():
	health = max_health

func damage(attack: Attack):
	health -= max(attack.attack_damage, 0)
	PlayerStats.health = health
	if health > 0:
		print("HEALTH: " + str(health))
	if health == 0:
		print(get_parent().name + " IS DEAD")
