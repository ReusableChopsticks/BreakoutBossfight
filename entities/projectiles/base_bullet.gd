extends CharacterBody2D
class_name BaseBullet

"""
All bullets must have these functions:
	setup(config: BulletConfig) # constructor
	deflect() # changes bullet state after player attack
	
	BulletConfig is a contract where you look into the bullet code and pass in the required values
"""

var is_normal: bool
var is_deflected: bool

# sets is_deflected to true and sets collision layer to player bullet
func setup_deflected():
	is_deflected = true
	# set to player bullet
	set_collision_layer_value(5, true)
	set_collision_layer_value(4, false)

# set bullet to bounce off environment (walls)
func set_environment_collision(val: bool = true):
	if val:
		set_collision_mask_value(3, true)
	else:
		set_collision_mask_value(3, false)
