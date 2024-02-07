extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.play("test")
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_body_entered(body):
	pass
	#if body.name == "Player":
		#print("ow")
		#call_deferred("reset")

func reset():
	get_tree().reload_current_scene()
