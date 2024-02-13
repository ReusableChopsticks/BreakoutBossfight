extends BaseBullet
class_name ExplodingBullet

var target
var travel_time
@onready var timer: Timer = $ExplodeTimer

func setup(bullet: BulletConfig):
	get_tree().create_timer(bullet.travel_time).timeout.connect(explode)
	return self

# play another attack
func explode():
	print("boom!")

# cannot be deflected?
func deflect():
	pass


#func _on_explode_timer_timeout():
	#explode()
