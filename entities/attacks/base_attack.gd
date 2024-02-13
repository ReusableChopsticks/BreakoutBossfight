extends Node2D
class_name BaseAttack

# if set to true, call the attack on _ready() to see how it looks
@export var set_preview: bool = false

func preview_attack():
	if set_preview:
		call("attack")

func spawn_bullet(bullet_scene: PackedScene, bullet_config: BulletConfig):
	var bullet = bullet_scene.instantiate()
	$Bullets.add_child(bullet)
	bullet.setup(bullet_config)
	return bullet
