extends Sprite2D

@export var offset_right := Vector2(60, -60)
var offset_left: Vector2
var _offset: Vector2
@export_range(0, 1) var lerp_weight: float = 0.2
@export var player: Player

func _ready():
	offset_left = Vector2(-offset_right.x, offset_right.y)
	PlayerStats.player_health_updated.connect(on_health_update)

func on_health_update(health: int):
	if health >= 0:
		frame = 5 - health

func _physics_process(delta):
	_offset = offset_right if PlayerStats.facing_dir == PlayerStats.LEFT else offset_left
	global_position = lerp(global_position, player.global_position + _offset, lerp_weight)
	look_at(player.global_position)
	global_rotation_degrees += -110
