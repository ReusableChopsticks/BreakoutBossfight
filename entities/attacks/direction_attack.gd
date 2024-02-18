extends BaseAttack
class_name DirectionAttack

@export var bullet_scene: PackedScene
@export var target_node: Node2D
@export var speed: int = 500
@export_range(0.01, 2) var fire_interval: float = 0.5
@export var fire_amount: int = 3

var bullet_config: BulletConfig
var target_pos: Vector2

func _ready():
	preview_attack()

func attack():
	for i in range(fire_amount):
		# set to target, and if no target set, default to player pos
		if target_node:
			target_pos = target_node.global_position
		else:
			target_pos = PlayerStats.player_pos
		
		bullet_config = BulletConfig.new()
		bullet_config.spawn_pos = global_position
		bullet_config.start_velocity = (target_pos - global_position).normalized() * speed
		spawn_bullet(bullet_scene, bullet_config)
		await get_tree().create_timer(fire_interval).timeout
