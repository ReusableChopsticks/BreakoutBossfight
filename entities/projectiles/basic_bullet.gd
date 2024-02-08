extends BaseBullet
class_name BasicBullet

@export var initial_velocity: Vector2

func setup(spawn_pos: Vector2, start_velocity: Vector2):
	self.spawn_pos = spawn_pos
	initial_velocity = start_velocity

func spawn():
	pass

func _ready():
	velocity = initial_velocity

func _physics_process(delta):
	var col_info = move_and_collide(velocity * delta)
	if col_info:
		velocity = velocity.bounce(col_info.get_normal())
