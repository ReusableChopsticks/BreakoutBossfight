extends BaseAttack
class_name TargetAttack

@export var bullet_scene: PackedScene
@export var target_pos: Vector2 = Vector2.ZERO
# time to reach target
@export var travel_time: float
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
		bullet_config.travel_time = travel_time
		var bullet = spawn_bullet(bullet_scene, bullet_config)
		# move bullet to target pos with tween
		var tween = bullet.create_tween().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
		tween.tween_property(bullet, "global_position", target_pos, travel_time)
		await get_tree().create_timer(fire_interval).timeout