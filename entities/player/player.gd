extends CharacterBody2D

var direction
@export var move_speed = 200
@export var jump_velocity = -400.0
@export var max_fall_velocity = 800
# Get the gravity from the project settings to be synced with RigidBody nodes.
#var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var gravity: float = 1500

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y = clampf(velocity.y + (gravity * delta), -999999, max_fall_velocity)

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * move_speed
	else:
		velocity.x = move_toward(velocity.x, 0, move_speed)
	
	move_and_slide()
