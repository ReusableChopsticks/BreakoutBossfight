extends CharacterBody2D
class_name Player

#region Movement
@export_group("Movement")
@export_subgroup("Basic Controls")
# base move speed
@export var move_speed = 200
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
@export_range(0, 10) var dash_velocity_multiplier: float = 5
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
# this is not for character animation, but controls dash timings precisely
@onready var dash_anim: AnimationPlayer = $Animators/DashAnimationPlayer

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

var is_invincible = false

func check_collisions():
	if (is_on_floor() or is_on_wall_only()) and not is_dashing and !can_dash:
		can_dash = true
	handle_coyote()
	handle_buffer()

#region Jump
# handles has_coyote variable
func handle_coyote():
	# detect the frame the player leaves the floor
	if last_floor == true and is_on_floor() == false:
		has_coyote = true
		coyote_timer.start()
	# detect the frame the player leaves a wall
	if last_wall == true and is_on_wall_only() == false and not is_wall_jumping:
		has_wall_coyote = true
		wall_coyote_timer.start()
	last_floor = is_on_floor()
	last_wall = is_on_wall_only()

func handle_buffer():
	if Input.is_action_just_pressed("jump") and not is_on_floor():
		has_buffer = true
		buffer_timer.start()
	if Input.is_action_just_pressed("jump") and not is_on_wall_only():
		has_wall_buffer = true
		wall_jump_buffer_timer.start()
	if ((Input.is_action_just_pressed("move_left") or Input.is_action_just_pressed("move_right"))):
		has_move_buffer = true
		move_buffer_timer.start()

func handle_jump():
	# jump if on floor or coyote time active
	if Input.is_action_just_pressed("jump") and (is_on_floor() or has_coyote):
		execute_jump()
	# jump if buffer is active 
	elif is_on_floor() and has_buffer:
		execute_jump()
	# Hold jump to go higher
	elif is_jumping and Input.is_action_pressed("jump") and can_hold_jump and not is_on_ceiling():
		velocity.y = jump_velocity
	# bump head = stop jump
	if is_on_ceiling():
		release_jump()

func execute_jump():
	is_jumping = true
	velocity.y = jump_velocity
	can_hold_jump = true
	jump_hold_timer.start()
	has_coyote = false
	has_buffer = false
	has_wall_buffer = false

func release_jump():
	is_jumping = false
	can_hold_jump = false
	velocity.y *= release_cancel_mult
#endregion


#region WallJump
var last_wall_normal_x = 0
func handle_wall_jump():
	# stop previous jump when landing on wall
	if is_on_wall_only() and not is_jumping:
		is_jumping = false
		can_hold_jump = false
		is_wall_jumping = false
		# wall slide logic
		if direction:
			velocity.y = lerpf(velocity.y, wall_slide_speed, wall_slide_lerp)
	# detect when to wall jump
	if (Input.is_action_just_pressed("jump") 
				and (is_on_wall_only() or has_wall_coyote)
				and (direction or has_move_buffer)):
		execute_wall_jump()
	elif is_on_wall_only() and has_wall_buffer:
		execute_wall_jump()
	# controls moment where wall jump velocity is forced
	if is_wall_jumping:
		velocity.x = lerpf(wjump_x_velocity * last_wall_normal_x, move_speed, air_friction_lerp)
		
func execute_wall_jump():
	last_wall_normal_x = wall_normal.x
	velocity.y = wjump_y_velocity
	velocity.x = wjump_x_velocity * last_wall_normal_x
	has_wall_coyote = false
	has_wall_buffer = false
	is_wall_jumping = true
	$Timers/WallJumpXBoostTimer.start()
#endregion

func handle_gravity(delta):
	# only apply gravity multiplier if within jump apex
	var y_apex_mod = apex_grav_multiplier if (
				velocity.y < apex_range 
				and velocity.y > -apex_range 
				and not is_on_wall()
						) else 1.0
	# upon jump release, add force downwards
	if not Input.is_action_pressed("jump") and velocity.y < 0:
		release_jump()
	# apply gravity if in air while clamping to max fall speed
	if not is_on_floor():
		# basically unlimited up velocity explaining the -999999
		velocity.y = clampf(velocity.y + (gravity * delta * y_apex_mod), -999999, max_fall_velocity)

var direction = 0
func handle_direction():
	# keep facing_dir to last direction facing when staying still
	direction = signf(Input.get_axis("move_left", "move_right"))
	facing_dir = direction if direction != 0 and not is_dashing else facing_dir
	PlayerStats.facing_dir = facing_dir
	# left and right movement on ground and air
	if direction and not is_wall_jumping:
		velocity.x = lerpf(velocity.x, direction * move_speed, move_lerp)
	else:
		# floor and air frictions
		if is_on_floor():
			velocity.x = lerpf(velocity.x, 0, friction_lerp)
		else:
			velocity.x = lerpf(velocity.x, 0, air_friction_lerp)
	# add x boost when jump at apex
	if velocity.y < apex_range and velocity.y > -apex_range and velocity.y != 0:
		velocity.x = lerpf(velocity.x, move_speed * apex_x_multiplier * direction, 0.2)

#region Dash
func handle_dash():
	if Input.is_action_just_pressed("dash") and can_dash and not dash_anim.is_playing():
		execute_dash()
	if is_dashing:
		velocity.x = facing_dir * dash_velocity_multiplier * move_speed
		velocity.y = 0

func execute_dash():
	is_dashing = true
	can_dash = false
	dash_anim.play("dash")
	
func finish_dash():
	is_dashing = false

func set_invincible(value: bool):
	is_invincible = value
#endregion

func _physics_process(delta):
	check_collisions()
	handle_jump()
	handle_gravity(delta)
	handle_direction()
	handle_wall_jump()
	handle_dash()

	#print(velocity)
	move_and_slide()
	wall_normal = get_wall_normal()

func print_inputs():
	if Input.is_action_just_pressed("jump"):
		print("jump")
		print(is_on_wall_only())
	elif Input.is_action_just_pressed("move_left"):
		print("left")
		print(is_on_wall_only())
	elif Input.is_action_just_pressed("move_right"):
		print("right")
		print(is_on_wall_only())
	#elif Input.is_anything_pressed():
		#print("############")
	if is_on_wall_only():
		modulate = Color.DARK_RED
	else:
		modulate = Color.WHITE

#region Timers
func _on_jump_hold_timer_timeout():
	if velocity.y < 0:
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
#endregion

