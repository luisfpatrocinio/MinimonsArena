extends Node3D

const dicePackage = preload("res://Scenes/dice.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	rollDice();
	$Pivot/Camera3D.look_at($Pivot.global_position);

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func rollDice(posOrigin: Vector3 = Vector3.ZERO) -> int:
	var _dice: Dice = dicePackage.instantiate();
	add_child(_dice);
	_dice.global_position = posOrigin;
	_dice.roll()
	
	# O sinal que retorna o valor
	var response = await _dice.rollFinished;
	
	#$Pivot.create_tween().tween_property($Pivot, "global_position", _dice.global_position, 1);
	
	return response;
