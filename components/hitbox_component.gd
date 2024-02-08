extends Area2D
class_name HitboxComponent

@export var attack_damage: int = 1

func _on_area_entered(area):
	if area is HurtboxComponent:
		var attack = Attack.new()
		attack.attack_damage = attack_damage
		area.damage(attack)
