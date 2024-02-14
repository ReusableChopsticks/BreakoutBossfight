extends BaseAttack
class_name RadialAttack

@export var bullet_scene: PackedScene
@export var speed: int = 500
@export var bullet_burst_amount: int = 10
@export var degrees_offset_per_burst = 5
@export_range(0.01, 2) var fire_interval: float = 0.3
@export var fire_amount: int = 10

var bullet_config: BulletConfig

# Called when the node enters the scene tree for the first time.
func _ready():
	preview_attack()

func attack():
	var rotate_offset = 0
	var angle_interval = (2 * PI) / bullet_burst_amount
	for j in range(fire_amount):
		for i in range(bullet_burst_amount):
			bullet_config = BulletConfig.new()
			bullet_config.spawn_pos = global_position
			bullet_config.start_velocity = Vector2.UP.rotated((angle_interval * i) + rotate_offset) * speed
			spawn_bullet(bullet_scene, bullet_config)
			
		await get_tree().create_timer(fire_interval).timeout
		rotate_offset += degrees_offset_per_burst
