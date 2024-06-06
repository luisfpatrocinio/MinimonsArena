extends Node
class_name ItensManager

## Posição padrão de drop de itens.
@export var defaultDropPos: Vector2 = Vector2(10, 10);

## Scene de partículas de spawn
@onready var spawnParticlesScene: PackedScene = preload("res://Scenes/spawn_particles.tscn");

## Temporario
var randInd: int;

const chestPackage = preload("res://Scenes/chest.tscn")

func _ready():
	randomize();
	randomizeSpawnSettings();

func _process(delta):
	pass

## Instancia um inimigo e adiciona como filho 
func dropChest(dropPosition: Vector2 = defaultDropPos):
	
	var _chest = chestPackage.instantiate();
	add_child(_chest);
	
	## Coloquei por enquanto, apenas pra obter um y satisfatório
	var _playerPos = Global.monsterNode.global_position;
	
	var _dropPosition = Vector3(dropPosition.x, _playerPos.y, dropPosition.y);
	_chest.global_position = _dropPosition;
	
	var _part = spawnParticlesScene.instantiate();
	_part.global_position = _dropPosition;
	Global.levelNode.add_child(_part);
	
	randomizeSpawnSettings()
	
## Randomiza índice do monstro e posição de spawn:
func randomizeSpawnSettings() -> void:
	defaultDropPos = Vector2(
		randi_range(-10, 10),
		randi_range(-10, 10)
	);
