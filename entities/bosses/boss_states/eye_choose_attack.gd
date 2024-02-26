extends State
class_name EyeChooseAttack

var attacks: Array = []
var available_attacks: Array = []
var last_attack = null

@export var anim: AnimationPlayer

# todo: combos? chain attacks? perhaps even simultaneous violences?

# add attacks to the array
func _ready():
	for child in get_parent().get_children():
		if child is AttackState:
			attacks.append(child)
	available_attacks.append_array(attacks)
	print(available_attacks)
	print("################")
		#else:
			#printerr("AttackState %s has non-attack child %s" % [name, child.name])

func enter():
	# make sure no attack repeats twice in a row
	var chosen = available_attacks.pick_random()
	if last_attack != null:
		available_attacks.append(last_attack)
	last_attack = chosen
	available_attacks.erase(chosen)
	print(available_attacks)

	transitioned.emit(self, chosen.name)
	
func exit():
	pass

