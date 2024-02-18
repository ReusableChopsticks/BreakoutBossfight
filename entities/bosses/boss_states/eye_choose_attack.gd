extends State
class_name EyeChooseAttack

var attacks: Array = []
var last_attack

# todo: combos? chain attacks? perhaps even simultaneous violences?

# add attacks to the array
func _ready():
	for child in get_parent().get_children():
		if child is AttackState:
			attacks.append(child)
		#else:
			#printerr("AttackState %s has non-attack child %s" % [name, child.name])

func enter():
	# TODO: make sure no attack repeats twice?
	var chosen = attacks.pick_random().name
	transitioned.emit(self, chosen)
	
func exit():
	pass

