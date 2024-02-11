extends BaseBullet
class_name KinematicBullet

@export var gravity: int = 1000
@export_range(0, 1) var bounce_decrease: float = 0.8

func setup(config: BulletConfig):
	position = config.spawn_pos
	velocity = config.start_velocity
	return self
	
func deflect():
	setup_deflected()
	set_environment_collision()

func _physics_process(delta):
	velocity.y += gravity * delta
	var col_info = move_and_collide(velocity * delta)
	if col_info:
		velocity = velocity.bounce(col_info.get_normal()) * bounce_decrease
