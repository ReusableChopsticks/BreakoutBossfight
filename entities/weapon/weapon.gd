extends Node2D

@onready var up_attack_area: Area2D = $UpAttackArea
@onready var down_attack_area: Area2D = $DownAttackArea
@onready var left_attack_area: Area2D = $LeftAttackArea
@onready var right_attack_area: Area2D = $RightAttackArea
@onready var anim: AnimationPlayer = $AnimationPlayer

var attack_area: Area2D
func use_weapon(_delta):
	#print(PlayerStats.facing_dir)
	#if Input.is_action_just_pressed("attack"):
	if Input.is_action_pressed("face up"):
		attack_area = up_attack_area
		anim.play("up_attack")
	elif Input.is_action_pressed("move_down"):
		#TODO: i wanna have this dash you all the way to the ground
		attack_area = down_attack_area
		anim.play("down_attack")
	elif PlayerStats.facing_dir >= 1:
		attack_area = right_attack_area
		anim.play("right_attack")
	else:
		attack_area = left_attack_area
		anim.play("left_attack")
	await anim.animation_finished

# this is called in the attack animation (call method track)
func get_hits():
	for area in attack_area.get_overlapping_areas():
		if area.get_parent() is BaseBullet:
			area.get_parent().deflect()
