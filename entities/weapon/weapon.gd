extends Node2D
class_name PlayerWeapon

@export var deflect_start_radius: int = 100
@export var increase_radius_per_hit: int = 15
@export var max_charge: int = 10

#region Area2D's
@onready var up_attack_area: Area2D = $UpAttackArea
@onready var down_attack_area: Area2D = $DownAttackArea
@onready var left_attack_area: Area2D = $LeftAttackArea
@onready var right_attack_area: Area2D = $RightAttackArea
@onready var deflect_area: Area2D = $DeflectArea
#endregion

@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var deflect_cs2d: CollisionShape2D = deflect_area.get_child(0)
@onready var glow_sprite: Node2D = $DeflectAttackRange
@onready var base_deflect_sprite_scale: Vector2 = glow_sprite.scale
@onready var charge_wheel: Sprite2D = $RangeChargeWheel

signal attack_finished

# the chosen attack
var attack_area: Area2D
var charge: int = 0

func _ready():
	deflect_cs2d.shape.radius = deflect_start_radius

func use_weapon(dir: StringName):
	#print(PlayerStats.facing_dir)
	#if Input.is_action_just_pressed("attack"):
	if dir == "up":
		attack_area = up_attack_area
		anim.play("up_attack")
	# BUDGET CUTS BABYYYY NO MORE DOWN ATTACK GRAAAAAAAH
	#elif dir == "down":
		#attack_area = down_attack_area
		#anim.play("down_attack")
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
	var deflected_bullets = deflect_area.get_overlapping_areas()
	# 0.1s per bullet if < 4, make it faster otherwise
	var pause_interval = 0.3 / deflected_bullets.size()
	for area in deflected_bullets:
		if area.get_parent() is BaseBullet:
			get_tree().paused = true
			area.get_parent().deflect()
			await get_tree().create_timer(pause_interval).timeout
			get_tree().paused = false
	# reset charge
	set_charge(0)

# this is called in the attack animation (call method track)
func get_hits():
	for area in attack_area.get_overlapping_areas():
		# charge weapon when bullets hit
		if area.get_parent() is BaseBullet:
			add_charge()
			area.get_parent().hit()
			# call a function on bullet like .hit() to indicate it was hit
		# directly attack boss
		elif area is HurtboxComponent:
			var attack = Attack.new()
			attack.attack_damage = 5
			area.damage(attack)

func add_charge(amount: int = 1):
	if charge < max_charge:
		deflect_cs2d.shape.radius += increase_radius_per_hit
		glow_sprite.scale = base_deflect_sprite_scale * (deflect_cs2d.shape.radius / deflect_start_radius)
	charge = min(max_charge, charge + amount)
	print(charge)

# amount must be in range [0, max_charge]
# default is reset charge
func set_charge(amount: int = 0):
	charge = amount
	deflect_cs2d.shape.radius = deflect_start_radius + (increase_radius_per_hit * amount)
	glow_sprite.scale = base_deflect_sprite_scale * (deflect_cs2d.shape.radius / deflect_start_radius)

# Responsible for wheel expanding indicator of holding down charge attack
var tween: Tween
func play_charge_anim(time: float):
	tween = get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(charge_wheel, "scale", glow_sprite.scale, time)
	tween.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_EXPO)
	tween.parallel().tween_property(charge_wheel, "rotation", PI/4, time)
	await tween.finished
	exit_charge_anim()

func exit_charge_anim():
	if tween:
		tween.kill()
	charge_wheel.rotation = 0
	charge_wheel.scale = Vector2.ZERO
