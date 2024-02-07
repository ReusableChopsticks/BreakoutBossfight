extends Area2D
class_name HitboxComponent

@export var attack_damage: int = 1

func _on_area_entered(area):
	print("waaaah")
	if area.has_method("damage"):
		var attack = Attack.new()
		attack.attack_damage = attack_damage
		area.damage(attack)


func _on_body_entered(body):
	print("THIS IS WRONG")
