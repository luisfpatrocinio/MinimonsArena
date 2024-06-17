extends Area3D

var hitboxOwner: Entity = null;

func _on_timer_timeout():
	queue_free()

func _on_body_entered(body):
	print(hitboxOwner)
	print(body)
	if body != hitboxOwner:
		print("Machucamos um: ", body);
