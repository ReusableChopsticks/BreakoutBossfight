extends BaseBullet
class_name BasicBullet

func setup(bullet: BulletConfig):
	$AnimatedSprite2D.frame = 0
	position = bullet.spawn_pos
	velocity = bullet.start_velocity
	return self

func deflect():
	$AnimatedSprite2D.frame = 1
	set_deflected()
	# set to bounce off environment (walls)
	set_collision_mask_value(3, true)
	
	

func _physics_process(delta):
	var col_info = move_and_collide(velocity * delta)
	if col_info:
		velocity = velocity.bounce(col_info.get_normal())
