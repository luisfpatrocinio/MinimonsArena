extends Node3D

## Classe responsável por instanciar um [Dice] e tratar a resposta com base no banco de ações.
class_name DiceManager

# TODO: Remover depois
@onready var camera: Camera = $Camera

const dicePackage: PackedScene = preload("res://Scenes/dice.tscn")

# TODO: remover quando não for mais preciso
func _ready():
	rollDice();

## Instancia um dado e retorna o valor ( Por enquanto ele tambem gerencia a camera, mas apenas para essa cena )
func rollDice(posOrigin: Vector3 = Vector3.ZERO) -> int:
	var _dice: Dice = dicePackage.instantiate();
	_dice.global_position = posOrigin;
	add_child(_dice);
	_dice.roll()
	
	# O sinal que retorna o valor
	var response = await _dice.rollFinished;
	
	## ta aqui por enquanto
	camera.moveTo(_dice.global_position);
	await camera.moveToFinished;
	
	var _zoom = 5;
	camera.setSpringLength(_zoom);
	
	return response;
