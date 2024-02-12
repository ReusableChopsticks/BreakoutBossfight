extends BaseAttack
class_name RandomDirAttack

@export var bullet_scene: PackedScene
@export var speed: int = 500
@export_range(0.01, 2) var fire_interval: float = 0.3
@export var fire_amount: int = 10

var bullet_config: BulletConfig

# Called when the node enters the scene tree for the first time.
func _ready():
	preview_attack()

func attack():
	for i in range(fire_amount):
		bullet_config = BulletConfig.new()
		bullet_config.start_velocity = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized() * speed
		add_child(bullet_scene.instantiate().setup(bullet_config))
		await get_tree().create_timer(fire_interval).timeout
