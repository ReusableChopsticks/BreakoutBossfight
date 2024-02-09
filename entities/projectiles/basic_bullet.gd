extends BaseBullet
class_name BasicBullet

func setup(bullet: BulletConfig):
	position = bullet.spawn_pos
	velocity = bullet.start_velocity


func _physics_process(delta):
	var col_info = move_and_collide(velocity * delta)
	if col_info:
		velocity = velocity.bounce(col_info.get_normal())
