extends BaseBullet
class_name TrackingBullet

# rate of change of velocity while tracking player
@export var track_speed = 20

func setup(bullet: BulletConfig):
	sprite.play("spinning_bullet")
	position = bullet.spawn_pos
	velocity = bullet.start_velocity
	return self

func deflect():
	sprite.play("spinning_bullet_deflected")
	set_deflected()
	# set to bounce off environment (walls)
	set_collision_mask_value(3, true)


func _physics_process(delta):
	var col_info = move_and_collide(velocity * delta)
	velocity += (PlayerStats.player_pos - global_position).normalized() * track_speed
