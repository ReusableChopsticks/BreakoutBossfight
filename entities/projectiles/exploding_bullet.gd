extends BaseBullet
class_name ExplodingBullet

var target
var travel_time

func setup(bullet: BulletConfig):
	global_position = bullet.spawn_pos
	velocity = bullet.start_velocity
	get_tree().create_timer(bullet.travel_time).timeout.connect(explode)
	return self

# play another attack
func explode():
	$RadialAttack.attack()
	# replace with explode animation
	visible = false

# cannot be deflected?
func deflect():
	pass

func _physics_process(delta):
	move_and_collide(velocity * delta)
