extends State
class_name PlayerMoveState

@onready var p: CharacterBody2D = get_parent().get_parent()

@export_group("Components")
@export var hurtbox: HurtboxComponent
@export_group("")

#region Movement
@export_group("Movement")
@export_subgroup("Basic Controls")
# base move speed
@export var move_speed = 600
@export var jump_velocity = -600.0
@export var max_fall_velocity = 2000
# how fast you can change directon
@export_range(0.0, 1.0) var move_lerp: float = 1
# how fast you stop on ground
@export_range(0.0, 1.0) var friction_lerp: float = 1
# how fast you stop in air
@export_range(0.0, 1.0) var air_friction_lerp: float = 1

@export_subgroup("Wall Jump")
var is_wall_jumping = false
@export var wall_slide_speed = 500
@export var wall_slide_lerp = 0.1
@export var wjump_x_velocity = 1000
@export var wjump_y_velocity = -1000
var has_wall_coyote = false
var has_wall_buffer = false
var has_move_buffer = false

@export_subgroup("Apex Bonuses")
# how much to cut off your y velocity after releasing jump / hit ceiling
@export_range(0, 1) var release_cancel_mult: float = 0.2
# what y velocity range covers the apex of your jump
@export_range(0, 500) var apex_range: float = 200
# decrease gravity when at apex of jump for greater hangtime
@export_range(0, 1.0) var apex_grav_multiplier: float = 0.7
# boost x velocity at jump apex
@export_range(1.0, 2.0) var apex_x_multiplier: float = 1.5
@export_subgroup("Dash")
@export_range(0, 10) var dash_velocity_multiplier: float = 2
@export_group("")
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
#var gravity: float = 3000
# downwards force for jump releases and ceiling bumps

@onready var jump_hold_timer: Timer = $Timers/JumpHoldTimer
@onready var coyote_timer: Timer = $Timers/CoyoteTimer
@onready var wall_coyote_timer: Timer = $Timers/WallCoyoteTimer
@onready var buffer_timer: Timer = $Timers/BufferTimer
@onready var wall_jump_buffer_timer: Timer = $Timers/WallJumpBufferTimer
@onready var move_buffer_timer: Timer = $Timers/MoveBufferTimer
@onready var i_frames_timer: Timer = $Timers/IFramesTimer
# this is not for character animation, but controls dash timings precisely
@onready var dash_anim: AnimationPlayer = $"../../DashAnimationPlayer"

@onready var character_anim: AnimationPlayer = $"../PlayerNodeReferences".char_anim_player
@onready var sprite: Sprite2D = $"../../PlayerSprite"

# apply constant force up while holding like hollow knight jump
var can_hold_jump: bool = true
# allow player to jump if they press key before hitting ground
var has_buffer: bool = false
var has_coyote: bool = false
var is_jumping = false
var can_dash = true
var is_dashing = false
# tracks if floor has just been left
var last_floor
var last_wall
# left (-1) or right (1)
var facing_dir = 1
var wall_normal = 0
#endregion

const LEFT = -1
const RIGHT = 1

# makes sure that nothing can set make you not invincible until your i frames are done
var is_invincible = false:
	set(val):
		if i_frames_timer.is_stopped():
			is_invincible = val
			
func _ready():
	PlayerStats.player_damaged.connect(_on_player_damaged)

func check_collisions():
	if (p.is_on_floor() or p.is_on_wall_only()) and !can_dash and !is_dashing:
		can_dash = true
	if p.is_on_wall_only() and is_dashing:
		is_dashing = false
		can_dash = true
	# return to default sprite if not on wall
	if not p.is_on_wall_only():
		sprite.frame = 0
	handle_coyote()
	handle_buffer()

#region Jump
# handles has_coyote variable
func handle_coyote():
	# detect the frame the player leaves the floor
	if last_floor == true and p.is_on_floor() == false:
		has_coyote = true
		coyote_timer.start()
	# detect the frame the player leaves a wall
	if last_wall == true and p.is_on_wall_only() == false and not is_wall_jumping:
		has_wall_coyote = true
		wall_coyote_timer.start()
	last_floor = p.is_on_floor()
	last_wall = p.is_on_wall_only()

func handle_buffer():
	if Input.is_action_just_pressed("jump") and not p.is_on_floor():
		has_buffer = true
		buffer_timer.start()
	if Input.is_action_just_pressed("jump") and not p.is_on_wall_only():
		has_wall_buffer = true
		wall_jump_buffer_timer.start()
	if ((Input.is_action_just_pressed("move_left") or Input.is_action_just_pressed("move_right"))):
		has_move_buffer = true
		move_buffer_timer.start()

func handle_jump():
	# jump if on floor or coyote time active
	if Input.is_action_just_pressed("jump") and (p.is_on_floor() or has_coyote):
		execute_jump()
	# jump if buffer is active 
	elif p.is_on_floor() and has_buffer:
		execute_jump()
	# Hold jump to go higher
	elif is_jumping and Input.is_action_pressed("jump") and can_hold_jump and not p.is_on_ceiling():
		p.velocity.y = jump_velocity
	# bump head = stop jump
	if p.is_on_ceiling():
		release_jump()

func execute_jump():
	is_jumping = true
	p.velocity.y = jump_velocity
	can_hold_jump = true
	jump_hold_timer.start()
	has_coyote = false
	has_buffer = false
	has_wall_buffer = false
	character_anim.play("jump")

func release_jump():
	is_jumping = false
	can_hold_jump = false
	p.velocity.y *= release_cancel_mult
#endregion


#region WallJump
var last_wall_normal_x = 0
func handle_wall_jump():
	# stop previous jump when landing on wall
	if p.is_on_wall_only() and not is_jumping:
		is_jumping = false
		can_hold_jump = false
		is_wall_jumping = false
		# wall slide logic
		if direction:
			p.velocity.y = lerpf(p.velocity.y, wall_slide_speed, wall_slide_lerp)
			# PLAYER SPRITE FOR WALL SLIDE PROTOTYPE
			sprite.frame = 1 if direction == LEFT else 2
			
	# detect when to wall jump
	if (Input.is_action_just_pressed("jump") 
				and (p.is_on_wall_only() or has_wall_coyote)
				and (direction or has_move_buffer)):
		execute_wall_jump()
	elif p.is_on_wall_only() and has_wall_buffer:
		execute_wall_jump()
	# controls moment where wall jump velocity is forced
	if is_wall_jumping:
		p.velocity.x = lerpf(wjump_x_velocity * last_wall_normal_x, move_speed * last_wall_normal_x, air_friction_lerp)

func execute_wall_jump():
	last_wall_normal_x = wall_normal.x
	p.velocity.y = wjump_y_velocity
	p.velocity.x = wjump_x_velocity * last_wall_normal_x
	has_wall_coyote = false
	has_wall_buffer = false
	is_wall_jumping = true
	if last_wall_normal_x == LEFT:
		character_anim.play("left_wall_jump")
	else:
		character_anim.play("right_wall_jump")
	$Timers/WallJumpXBoostTimer.start()
#endregion

func handle_gravity(delta):
	# only apply gravity multiplier if within jump apex
	var y_apex_mod = apex_grav_multiplier if (
				p.velocity.y < apex_range 
				and p.velocity.y > -apex_range 
				and not p.is_on_wall()
						) else 1.0
	# upon jump release, add force downwards
	if not Input.is_action_pressed("jump") and p.velocity.y < 0:
		release_jump()
	# apply gravity if in air while clamping to max fall speed
	if not p.is_on_floor():
		# basically unlimited up velocity explaining the -999999
		p.velocity.y = clampf(p.velocity.y + (gravity * delta * y_apex_mod), -999999, max_fall_velocity)

var direction = 0
func handle_direction():
	# keep facing_dir to last direction facing when staying still
	direction = signf(Input.get_axis("move_left", "move_right"))
	facing_dir = direction if direction != 0 and not is_dashing else facing_dir
	PlayerStats.facing_dir = facing_dir
	# left and right movement on ground and air
	if direction and not is_wall_jumping:
		p.velocity.x = lerpf(p.velocity.x, direction * move_speed, move_lerp)
	else:
		# floor and air frictions
		if p.is_on_floor():
			p.velocity.x = lerpf(p.velocity.x, 0, friction_lerp)
		else:
			p.velocity.x = lerpf(p.velocity.x, 0, air_friction_lerp)
	# add x boost when jump at apex
	if p.velocity.y < apex_range and p.velocity.y > -apex_range and p.velocity.y != 0:
		p.velocity.x = lerpf(p.velocity.x, move_speed * apex_x_multiplier * direction, 0.2)

#region Dash
func handle_dash():
	if Input.is_action_just_pressed("dash") and can_dash and not dash_anim.is_playing():
		execute_dash()
	if is_dashing:
		p.velocity.x = facing_dir * dash_velocity_multiplier * move_speed
		p.velocity.y = 0

func execute_dash():
	is_dashing = true
	can_dash = false
	dash_anim.play("dash")
	character_anim.play("dash")
	
# used while dashing in dash animation
func finish_dash():
	is_dashing = false

# used while dashing in dash animation
func set_invincible(value: bool):
	is_invincible = value
	hurtbox.set_hurtbox_monitorable(!value)
#endregion

# teleport back to safety
func _on_player_player_fallen(pos: Vector2):
	p.position = pos

# set Iframes
func _on_player_damaged():
	set_invincible(true)
	i_frames_timer.start()
	p.modulate.a = 0.3

func enter():
	pass

func physics_update(delta):
	check_collisions()
	handle_jump()
	handle_gravity(delta)
	handle_direction()
	handle_wall_jump()
	handle_dash()

	p.move_and_slide()
	wall_normal = p.get_wall_normal()
	
	#print(velocity)
	#print_inputs()
	
	if Input.is_action_just_pressed("attack"):
		transitioned.emit(self, "PlayerAttackState")
	
func exit():
	is_dashing = false
	is_wall_jumping = false
	is_jumping = false

func print_inputs():
	if Input.is_action_just_pressed("jump"):
		print("jump")
		print(p.is_on_wall_only())
	elif Input.is_action_just_pressed("move_left"):
		print("left")
		print(p.is_on_wall_only())
	elif Input.is_action_just_pressed("move_right"):
		print("right")
		print(p.is_on_wall_only())
	#elif Input.is_anything_pressed():
		#print("############")
	if p.is_on_wall_only():
		p.modulate = Color.DARK_RED
	else:
		p.modulate = Color.WHITE

#region Timers
func _on_jump_hold_timer_timeout():
	if p.velocity.y < 0 and is_jumping:
		release_jump()
	can_hold_jump = false

func _on_coyote_timer_timeout():
	has_coyote = false

func _on_buffer_timer_timeout():
	has_buffer = false

func _on_wall_jump_buffer_timer_timeout():
	has_wall_buffer = false

func _on_wall_jump_x_boost_timer_timeout():
	is_wall_jumping = false

func _on_wall_coyote_timer_timeout():
	has_wall_coyote = false

func _on_move_buffer_timer_timeout():
	has_move_buffer = false

func _on_i_frames_timer_timeout():
	set_invincible(false)
	p.modulate.a = 1


