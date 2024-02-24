extends CharacterBody2D
class_name BaseBullet

"""
All bullets must have these functions:
	setup(config: BulletConfig) # constructor
	deflect() # changes bullet state after player attack
	hit() # get slapped nerd
	
	BulletConfig is a contract where you look into the bullet code and pass in the required values
"""

@export var free_on_collide: bool = true

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var is_normal: bool
var is_deflected: bool
var speed: float

# sets is_deflected to true and sets collision layer to player bullet
func set_deflected():
	is_deflected = true
	# for both self and the hitbox component
	for i: CollisionObject2D in [self, $HitboxComponent]:
		# set to player bullet
		i.set_collision_layer_value(5, true)
		i.set_collision_layer_value(4, false)
		# mask with enemy instead of player
		i.set_collision_mask_value(1, false)
		i.set_collision_mask_value(2, true)

	velocity = (BossStats.centre_pos - global_position).normalized() * velocity.length()

# set bullet to bounce off environment (walls)
func set_environment_collision(val: bool = true):
	if val:
		set_collision_mask_value(3, true)
	else:
		set_collision_mask_value(3, false)

func setup(_config: BulletConfig):
	pass

# despawn self after certain amount of time
func _on_delete_timer_timeout():
	call_deferred("queue_free")


func _on_hitbox_component_area_entered(area):
	if free_on_collide and area.get_parent() is Player:
		call_deferred("queue_free")
