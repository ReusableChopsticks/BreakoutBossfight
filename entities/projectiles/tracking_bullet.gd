extends BaseBullet
class_name TrackingBullet

# rate of change of velocity while tracking player
@export var track_speed = 20
@export var max_speed = 600

var deflected := false

func setup(bullet: BulletConfig):
	sprite.play("spinning_bullet")
	position = bullet.spawn_pos
	velocity = bullet.start_velocity
	return self

func deflect():
	_set_deflected()

func _set_deflected_sprite():
	sprite.play("spinning_bullet_deflected")

func _physics_process(delta):
	var _col_info = move_and_collide(velocity * delta)
	if !is_deflected:
		velocity += (PlayerStats.player_pos - global_position).normalized() * track_speed
		if velocity.length() > max_speed:
			velocity = velocity.normalized() * max_speed
