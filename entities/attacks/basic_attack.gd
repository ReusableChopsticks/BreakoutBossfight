extends BaseAttack
class_name BasicAttack

@export var bullet_scene: PackedScene
@export var start_velocity: Vector2 = Vector2(0, 500)
@export_range(0.01, 2) var fire_interval: float = 0.5
@export var fire_amount: int = 3

var bullet_config: BulletConfig


# Called when the node enters the scene tree for the first time.
func _ready():
	preview_attack()

func attack():
	for i in range(fire_amount):
		bullet_config = BulletConfig.new()
		bullet_config.spawn_pos = global_position
		bullet_config.start_velocity = start_velocity
		var bullet: BaseBullet = bullet_scene.instantiate().setup(bullet_config)
		$Bullets.add_child(bullet)
		await get_tree().create_timer(fire_interval).timeout
