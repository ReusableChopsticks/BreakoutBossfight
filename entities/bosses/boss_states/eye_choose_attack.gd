extends State
class_name EyeChooseAttack

var attacks: Array = []
var available_attacks: Array = []
var last_attack = null

var attack_to_iris: Dictionary = {
	"EyeTrackingBulletAttack": 1,
	"EyeRadialBeamAttack": 2,
	"EyeShootPlayerAttack": 3,
	"CryRainAttack": 4,
	"EyeBurstAttack": 5
}

@export var iris: Sprite2D
@export var anim: AnimationPlayer

# todo: combos? chain attacks? perhaps even simultaneous violences?

# add attacks to the array
func _ready():
	for child in get_parent().get_children():
		if child is AttackState:
			attacks.append(child)
		#else:
			#printerr("AttackState %s has non-attack child %s" % [name, child.name])
	available_attacks.append_array(attacks)

func enter():
	# make sure no attack repeats twice in a row
	var chosen = available_attacks.pick_random()
	if last_attack != null:
		available_attacks.append(last_attack)
	last_attack = chosen
	available_attacks.erase(chosen)

	anim.play("close_eye")
	await anim.animation_finished
	anim.queue("open_eye")
	iris.frame = attack_to_iris[chosen.name]
	await get_tree().create_timer(0.5).timeout
	transitioned.emit(self, chosen.name)
	
func exit():
	pass

