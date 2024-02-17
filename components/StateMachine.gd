extends Node
class_name StateMachine

@export var initial_state: State

var current_state: State
var states: Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.transitioned.connect(on_child_transition)
		else:
			printerr("State machine in %s has non-state child" % get_parent().name)
	
	if initial_state:
		initial_state.enter()
		current_state = initial_state

func _process(delta):
	if current_state:
		current_state.update(delta)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if current_state:
		current_state.physics_update(delta)

"""
state: the state that called it
new_state_name: what state you want to transition to
"""
func on_child_transition(state, new_state_name):
	#FIXME: this may be wrong? change != to ==
	if state != current_state:
		return
	
	var new_state: State = states.get(new_state_name.to_lower())
	if !new_state_name:
		return
		
	if current_state:
		current_state.exit()
	new_state.enter()
	current_state = new_state
