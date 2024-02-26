extends State
class_name PlayerAttackState

# how long to hold attack button for deflect attack
@export var deflect_hold_time: float = 1
@export var hold_time_before_freeze: float = 0.2
@export var weapon: PlayerWeapon

@onready var player: Player = $"../.."
@onready var move_settings: PlayerMoveState = $"../PlayerMoveState"
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var _hold_time = 0
var attack_dir: String
	
func enter():
	_hold_time = 0
	if Input.is_action_pressed("face up"):
		attack_dir = "up"
	elif Input.is_action_pressed("move_down"):
		attack_dir = "down"
	else:
		attack_dir = PlayerStats.get_facing_dir()

func update(delta: float):
	if Input.is_action_pressed("attack"):
		_hold_time += delta

var is_attacking = false
func physics_update(delta):
	# regular attack
	if Input.is_action_just_released("attack") and _hold_time < deflect_hold_time:
		weapon.use_weapon(attack_dir)
		#await weapon.attack_finished
		transitioned.emit(self, "PlayerMoveState")
	elif !is_attacking and _hold_time >= deflect_hold_time:
		is_attacking = true
		weapon.use_deflect_attack()
		await weapon.attack_finished
		transitioned.emit(self, "PlayerMoveState")
	
	if _hold_time < 0.3:
		handle_physics(delta)
	
func handle_physics(delta):
	# handle gravity while attacking; no movement! 
	var weight = move_settings.friction_lerp if player.is_on_floor() else move_settings.air_friction_lerp 
	# this line ends up just awkwardly stopping the player
	#player.velocity.x = lerpf(player.velocity.x, 0, weight)
	player.velocity.y += gravity * delta
	player.move_and_slide()

func exit():
	is_attacking = false
