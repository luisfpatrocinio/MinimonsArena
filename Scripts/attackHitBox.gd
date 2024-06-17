extends Area3D

var hitboxOwner: Entity = null;

func _process(delta):
	if not is_instance_valid(hitboxOwner):
		queue_free()

func _on_timer_timeout():
	queue_free()

func _on_body_entered(body):
	print(hitboxOwner)
	print(body)
	if body != hitboxOwner:
		print("Machucamos um: ", body);
