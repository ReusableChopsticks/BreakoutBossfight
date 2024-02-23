extends Node2D
class_name PlayerWeapon

@export var deflect_start_radius: int = 100

@onready var up_attack_area: Area2D = $UpAttackArea
@onready var down_attack_area: Area2D = $DownAttackArea
@onready var left_attack_area: Area2D = $LeftAttackArea
@onready var right_attack_area: Area2D = $RightAttackArea
@onready var deflect_area: Area2D = $DeflectArea
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var deflect_cs2d: CollisionShape2D = deflect_area.get_child(0)

signal attack_finished

# the chosen attack
var attack_area: Area2D
var charge: int = 0

func use_weapon(dir: StringName):
	#print(PlayerStats.facing_dir)
	#if Input.is_action_just_pressed("attack"):
	if dir == "up":
		attack_area = up_attack_area
		anim.play("up_attack")
	elif dir == "down":
		#TODO: i wanna have this dash you all the way to the ground
		attack_area = down_attack_area
		anim.play("down_attack")
	elif dir == "right":
		attack_area = right_attack_area
		anim.play("right_attack")
	else:
		attack_area = left_attack_area
		anim.play("left_attack")
	await anim.animation_finished
	attack_finished.emit()

func use_deflect_attack():
	anim.play("deflect_attack")
	await anim.animation_finished
	charge = 0
	attack_finished.emit()

#called in animation track
func deflect_bullets():
	for area in deflect_area.get_overlapping_areas():
		if area.get_parent() is BaseBullet:
			area.get_parent().deflect()

# this is called in the attack animation (call method track)
func get_hits():
	for area in attack_area.get_overlapping_areas():
		# charge weapon when bullets hit
		if area.get_parent() is BaseBullet:
			add_charge()
			# call a function on bullet like .hit() to indicate it was hit
		# directly attack boss
		elif area is HurtboxComponent:
			var attack = Attack.new()
			attack.attack_damage = 5
			area.damage(attack)

func add_charge(amount = 1):
	charge += 1
