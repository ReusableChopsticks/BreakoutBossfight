extends HealthComponent
class_name PlayerHealthComponent



func _ready():
	health = max_health

func damage(attack: Attack):
	health -= max(attack.attack_damage, 0)
	PlayerStats.health = health
	if health > 0:
		PlayerStats.player_damaged.emit()
		print("HEALTH: " + str(health))
	if health == 0:
		print(get_parent().name + " IS DEAD")


func _on_player_player_fallen(_pos: Vector2):
	var attack = Attack.new()
	attack.attack_damage = 1
	damage(attack)
