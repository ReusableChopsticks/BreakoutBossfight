extends Area2D
class_name HitboxComponent

@export var attack_damage: int = 1
# this is mainly for damaging enemies with your weapon
# because you can't disable area monitoring and call get_overlapping_areas
@export var damage_on_enter: int = true

func _on_area_entered(area):
	if area is HurtboxComponent and damage_on_enter:
		attack_hurtbox(area)

func attack_hurtbox(area):
	var attack = Attack.new()
	attack.attack_damage = attack_damage
	area.damage(attack)
	
