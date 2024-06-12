extends RigidBody3D

## Um dado que retorna um valor entre 1-6
class_name Dice

signal rollFinished(side: int);

## Força na qual o dado será arremessado
@export var rollStrength: float = 15; 

@onready var rayCasts = $RayCasts

## Aplica rotação e uma força de impulso
func roll():
	
	#TODO: Melhorar essa rotação do dado
	# aplica uma rotação e um impulso
	transform.basis = Basis(Vector3.RIGHT, randf_range(0, 2 * PI)) * transform.basis;
	transform.basis = Basis(Vector3.UP, randf_range(0, 2 * PI)) * transform.basis;
	transform.basis = Basis(Vector3.FORWARD, randf_range(0, 2 * PI)) * transform.basis;
	
	var _impulseDir = Vector3(randf_range(-0.3, 0.3), 2, randf_range(-0.3, 0.3)).normalized();
	angular_velocity = _impulseDir * rollStrength / 2	 
	apply_central_impulse(_impulseDir * rollStrength);
	

## Chamado quando o dado entra no modo [sleeping]
func _on_sleeping_state_changed():
	
	# Pra saber se ele está parado
	if sleeping:
		var landedOnSide = false;
		
		for rayCast: DiceRayCast in rayCasts.get_children():
			if rayCast.is_colliding():
				await get_tree().create_timer(.5).timeout;
				rollFinished.emit(rayCast.oppositeSide);
				landedOnSide = true;
					
		# As vezes ele para pois trava no chão, nesse caso ele rola novamente
		if !landedOnSide:
			roll();
