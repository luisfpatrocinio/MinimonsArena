extends RigidBody3D

class_name Dice

signal rollFinished(side: int);

@export var rollStrength: float = 15; 

@onready var rayCasts = $RayCasts

func roll():
	transform.basis = Basis(Vector3.RIGHT, randf_range(0, 3 * PI)) * transform.basis;
	transform.basis = Basis(Vector3.FORWARD, randf_range(0, 3 * PI)) * transform.basis;
	transform.basis = Basis(Vector3.UP, randf_range(0, 3 * PI)) * transform.basis;
	
	var _impulseDir = Vector3(randf_range(-0.5, 0.5), 1, randf_range(-0.5, 0.5)).normalized();
	angular_velocity = _impulseDir * rollStrength / 2  
	apply_central_impulse(_impulseDir * rollStrength);
	
	
func _on_sleeping_state_changed():
	if sleeping:
		var landedOnSide = false;
		
		for rayCast: DiceRayCast in rayCasts.get_children():
			if rayCast.is_colliding():
				await get_tree().create_timer(.5).timeout;
				rollFinished.emit(rayCast.oppositeSide);
				landedOnSide = true;
				
		if !landedOnSide:
			roll();
