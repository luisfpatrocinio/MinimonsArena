extends Area3D

var hitboxOwner: Entity = null;
var TIME_TO_DESTROY = 1;
@onready var timer = $Timer

## Variável usada para garantir que a hitbox só dará dano uma vez
var used = false

func _ready() -> void:
	timer.start(TIME_TO_DESTROY)

func _process(delta):
	if not is_instance_valid(hitboxOwner):
		queue_free()

func _on_timer_timeout():
	queue_free()

func _on_body_entered(body):
	if body != hitboxOwner and body is Entity and not used:
		body.takeDamage(1);
		var oposite_direction = hitboxOwner.global_position.direction_to(body.global_position)
		body.knockback = oposite_direction
		print("Machucamos um: ", body);
		used = true
