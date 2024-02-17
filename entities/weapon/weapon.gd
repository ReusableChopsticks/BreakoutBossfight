extends Node2D

@onready var up_attack_area: Area2D = $UpAttackArea
@onready var down_attack_area: Area2D = $DownAttackArea
@onready var left_attack_area: Area2D = $LeftAttackArea
@onready var right_attack_area: Area2D = $RightAttackArea

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


var attack_area
func _process(_delta):
	#print(PlayerStats.facing_dir)
	if Input.is_action_just_pressed("attack"):
		if Input.is_action_pressed("face up"):
			attack_area = up_attack_area
		elif Input.is_action_pressed("move_down"):
			attack_area = down_attack_area
		elif PlayerStats.facing_dir >= 1:
			attack_area = right_attack_area
		else:
			attack_area = left_attack_area
		
		for area in attack_area.get_overlapping_areas():
			if area.get_parent() is BaseBullet:
				area.get_parent().deflect()


func weapon_attack():
	pass
