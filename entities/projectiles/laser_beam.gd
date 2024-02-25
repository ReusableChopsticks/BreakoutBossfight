extends BaseBullet
class_name LaserBeam

@export var idle_time: float = 1
@onready var anim: AnimationPlayer = $AnimationPlayer

func setup(bullet: BulletConfig):
	position = bullet.spawn_pos
	# angle based on starting velocity provided
	rotation = bullet.start_velocity.angle() - PI/2
	fire()
	return self

func fire():
	anim.play("appear")
	anim.queue("idle")
	await get_tree().create_timer(idle_time).timeout
	anim.stop()
	anim.play("fire")

func deflect():
	pass
