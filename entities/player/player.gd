extends CharacterBody2D
var i = 0
#region Movement
@export_group("Movement")
@export_subgroup("Basic Controls")
# base move speed
@export var move_speed = 200
@export var jump_velocity = -400.0
@export var max_fall_velocity = 4000
# how fast you can change directon
@export_range(0.0, 1.0) var move_lerp: float = 1
# how fast you stop on ground
@export_range(0.0, 1.0) var friction_lerp: float = 1
# how fast you stop in air
@export_range(0.0, 1.0) var air_friction_lerp: float = 1

@export_subgroup("Wall Jump")
var is_wall_jumping = false

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
	if is_on_floor() and not is_dashing and !can_dash:
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
	elif last_wall == true and is_on_wall_only() == false and not is_wall_jumping:
		has_wall_coyote = true
		wall_coyote_timer.start()
	last_floor = is_on_floor()
	last_wall = is_on_wall_only()

func handle_buffer():
	if Input.is_action_just_pressed("jump") and not is_on_floor():
		has_buffer = true
		buffer_timer.start()
	elif Input.is_action_just_pressed("jump") and not is_on_wall_only():
		has_wall_buffer = true
		wall_jump_buffer_timer.start()

func handle_jump():
	# jump if on floor or coyote time active
	if Input.is_action_just_pressed("jump") and (is_on_floor() or has_coyote):
		execute_jump()
	# jump if buffer is active 
	elif is_on_floor() and has_buffer:
		execute_jump()
		has_buffer = false
	# Hold jump to go higher
	elif is_jumping and Input.is_action_pressed("jump") and can_hold_jump and not is_on_ceiling():
		velocity.y = jump_velocity
		print(i)
		i += 1
	# bump head = stop jump
	if is_on_ceiling():
		release_jump()

func execute_jump():
	print("jump")
	is_jumping = true
	velocity.y = jump_velocity
	can_hold_jump = true
	jump_hold_timer.start()
	has_coyote = false
	has_buffer = false

func release_jump():
	is_jumping = false
	can_hold_jump = false
	velocity.y *= release_cancel_mult
#endregion


#region WallJump
@export var wall_slide_multiplier = 0.9
var has_wall_coyote = false
var has_wall_buffer = false
func handle_wall_jump():
	if is_on_wall_only() and direction:
		is_jumping = false
		can_hold_jump = false
		velocity.y *= wall_slide_multiplier
	if Input.is_action_just_pressed("jump") and (is_on_wall_only() or has_wall_coyote):
		execute_wall_jump()
		
var wall_boost = 2000
func execute_wall_jump():
	velocity.y = -700
	velocity.x = wall_boost * wall_normal.x
	#print(wall_normal.x)
	has_wall_coyote = false
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
	if direction:
		#velocity.x = velocity.x + (direction * move_speed)
		velocity.x = lerpf(velocity.x, direction * move_speed, move_lerp)
	else:
		if is_on_floor():
			velocity.x = lerpf(velocity.x, 0, friction_lerp)
		else:
			velocity.x = lerpf(velocity.x, 0, air_friction_lerp)
	# add x boost when jump at apex
	if velocity.y < apex_range and velocity.y > -apex_range and velocity.y != 0:
		velocity.x = lerpf(velocity.x, velocity.x * apex_x_multiplier, 0.5)

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
	
	print(velocity)
	move_and_slide()
	wall_normal = get_wall_normal()


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

#func _on_dash_cooldown_timer_timeout():
	#can_dash = true
