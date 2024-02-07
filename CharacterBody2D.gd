extends CharacterBody2D



func _physics_process(delta):
	# Add the gravity.
	velocity = Input.get_vector("move_left", "move_right", "face up", "move_down") * 200
	
	move_and_slide()


func _on_area_2d_area_entered(area):
	print("entered: " + area.name)
