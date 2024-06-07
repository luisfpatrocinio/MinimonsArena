extends CPUParticles3D

func _ready():
	pass

func _on_finished():
	queue_free();


func _on_timer_timeout():
	emitting = true;
