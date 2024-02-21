extends Area2D
class_name HitboxComponent

@export var attack_damage: int = 1
@export var enabled: int = true

func _on_area_entered(area):
	if area is HurtboxComponent and enabled:
		attack_hurtbox(area)

func attack_hurtbox(area):
	var attack = Attack.new()
	attack.attack_damage = attack_damage
	area.damage(attack)
	
