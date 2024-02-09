extends Node2D

@export var bullet_scene: PackedScene = preload("res://entities/projectiles/basic_bullet.tscn")

func _physics_process(delta):
	pass


func _on_timer_timeout():
	var bullet: BasicBullet = bullet_scene.instantiate()
	var bullet_config = BulletConfig.new()
	bullet_config.start_velocity = Vector2(200, 500)
	bullet.setup(bullet_config)
	add_child(bullet)
	
