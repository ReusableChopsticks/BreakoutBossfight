extends BaseAttack
class_name TargetAttack

@export var bullet_scene: PackedScene
@export var target_node: Node2D
# time to reach target
@export var travel_time: float
@export_range(0.01, 2) var fire_interval: float = 0.5
@export var fire_amount: int = 3

var bullet_config: BulletConfig
var target_pos: Vector2

# Called when the node enters the scene tree for the first time.
func _ready():
	preview_attack()
	target_pos = PlayerStats.player_pos

func attack():
	for i in range(fire_amount):
		# set to target, and if no target set, default to player pos
		if target_node:
			target_pos = target_node.global_position
		else:
			target_pos = PlayerStats.player_pos
		
		bullet_config = BulletConfig.new()
		bullet_config.spawn_pos = global_position
		#bullet_config.travel_time = travel_time
		var bullet = spawn_bullet(bullet_scene, bullet_config)
		# move bullet to target pos with tween
		var tween = bullet.create_tween().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
		tween.tween_property(bullet, "global_position", target_pos, travel_time)
		await get_tree().create_timer(fire_interval).timeout
	finished.emit()
