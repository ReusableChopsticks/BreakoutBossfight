extends BaseBullet
class_name KinematicBullet

@export var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")
@export_range(0, 1) var bounce_decrease: float = 0.8

func setup(bullet_config: BulletConfig):
	position = bullet_config.spawn_pos
	velocity = bullet_config.start_velocity
	return self
	
func deflect():
	_set_deflected()
	_set_environment_collision()
	velocity.x *= 1.3
	velocity.y *= 1.5

func _set_deflected_sprite():
	sprite.frame = 1

func _physics_process(delta):
	velocity.y += gravity * delta
	var col_info = move_and_collide(velocity * delta)
	if col_info:
		velocity = velocity.bounce(col_info.get_normal()) * bounce_decrease
	rotation = velocity.angle() - PI/2
