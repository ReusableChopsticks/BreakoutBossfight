extends State
class_name PlayerAttackState

@onready var anim: AnimationMixer = $"../PlayerNodeReferences".anim_player
@onready var player: Player = $"../.."
@onready var move_settings: PlayerMoveState = $"../PlayerMoveState"
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func enter():
	anim.play("attack")
	await anim.animation_finished
	transitioned.emit(self, "PlayerMoveState")

func physics_update(delta):
	var weight = move_settings.friction_lerp if player.is_on_floor() else move_settings.air_friction_lerp 
	player.velocity.x = lerpf(player.velocity.x, 0, weight)
	player.velocity.y += gravity * delta
	player.move_and_slide()
