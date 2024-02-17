extends BaseBullet
class_name KinematicBullet

@export var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")
@export_range(0, 1) var bounce_decrease: float = 0.8

func setup(bullet_config: BulletConfig):
	position = bullet_config.spawn_pos
	velocity = bullet_config.start_velocity
	return self
	
func deflect():
	set_deflected()
	set_environment_collision()
	velocity *= 1.5

func _physics_process(delta):
	velocity.y += gravity * delta
	var col_info = move_and_collide(velocity * delta)
	if col_info:
		velocity = velocity.bounce(col_info.get_normal()) * bounce_decrease
