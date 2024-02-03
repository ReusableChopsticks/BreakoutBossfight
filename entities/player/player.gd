extends CharacterBody2D

var direction
@export var move_speed = 200
@export var jump_velocity = -400.0
@export var max_fall_velocity = 4000
@export_range(0.0, 1.0) var move_lerp: float = 1
@export_range(0.0, 1.0) var stop_lerp: float = 1
@export_range(0.0, 1.0) var air_friction_lerp: float = 1
# Get the gravity from the project settings to be synced with RigidBody nodes.
#var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var gravity: float = 3000
# downwards force for jump releases and ceiling bumps
var push_down_velocity = 100

@onready var jump_hold_timer: Timer = $Timers/JumpHoldTimer
@onready var coyote_timer: Timer = $Timers/CoyoteTimer
@onready var buffer_timer: Timer = $Timers/BufferTimer
# apply constant force up while holding like hollow knight jump
var can_hold_jump: bool = true
# allow player to jump if they press key before hitting ground
var has_buffer: bool = false
var has_coyote: bool = false
var is_jumping = false
var last_floor

# handles has_coyote variable
func handle_coyote():
	# detect the frame the player leaves the floor
	if last_floor == true and is_on_floor() == false:
		has_coyote = true
		coyote_timer.start()
	last_floor = is_on_floor()

func handle_buffer():
	if Input.is_action_just_pressed("jump") and not is_on_floor():
		has_buffer = true
		buffer_timer.start()

func handle_jump():
	handle_coyote()
	handle_buffer()
	if Input.is_action_just_pressed("jump") and (is_on_floor() or has_coyote):
		execute_jump()
	# jump if buffer is active 
	elif is_on_floor() and has_buffer:
		execute_jump()
		has_buffer = false
	# Hold jump to go higher
	elif is_jumping and Input.is_action_pressed("jump") and can_hold_jump and not is_on_ceiling():
		velocity.y = jump_velocity
	# bump head = stop jump
	if is_on_ceiling():
		release_jump()
	
		
func execute_jump():
	print("jump")
	is_jumping = true
	velocity.y = jump_velocity * 2
	can_hold_jump = true
	jump_hold_timer.start()
	has_coyote = false

func release_jump():
	is_jumping = false
	can_hold_jump = false
	velocity.y = push_down_velocity

func handle_gravity(delta):
	# upon jump release, add force downwards
	if not Input.is_action_pressed("jump") and velocity.y < 0:
		release_jump()
	if not is_on_floor():
		velocity.y = clampf(velocity.y + (gravity * delta), -999999, max_fall_velocity)

func handle_direction():
	var direction = Input.get_axis("move_left", "move_right")
	if direction:
		#velocity.x = velocity.x + (direction * move_speed)
		velocity.x = lerpf(velocity.x, direction * move_speed, move_lerp)
	else:
		if is_on_floor():
			velocity.x = lerpf(velocity.x, 0, stop_lerp)
		else:
			velocity.x = lerpf(velocity.x, 0, air_friction_lerp)

func _physics_process(delta):
	handle_jump()
	handle_gravity(delta)
	handle_direction()
	
	## Handle jump.
	#if Input.is_action_just_pressed("jump") and is_on_floor():
		#velocity.y = jump_velocity
		#can_hold_jump = true
		#jump_hold_timer.start()
	#
		#velocity.y = jump_velocity
	## jump cancel boosts you down faster
	## applied only when you release while ascending
	#if Input.is_action_just_released("jump") and velocity.y < 0:
		#velocity.y = push_down_velocity
#
	# Get the input direction and handle the movement/deceleration.
	#var direction = Input.get_axis("move_left", "move_right")
	#if direction:
		#velocity.x = direction * move_speed
	#else:
		#velocity.x = move_toward(velocity.x, 0, move_speed)
	
	move_and_slide()


func _on_jump_hold_timer_timeout():
	if velocity.y < 0:
		release_jump()
	can_hold_jump = false

func _on_coyote_timer_timeout():
	has_coyote = false

func _on_buffer_timer_timeout():
	has_buffer = false
