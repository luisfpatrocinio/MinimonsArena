extends Node

## Classe responsável por gerenciar todo tipo de entidade de item
class_name ItensManager

## Posição padrão de drop de itens.
@export var defaultDropPos: Vector2 = Vector2(10, 10);

## Scene de partículas de spawn
@onready var spawnParticlesScene: PackedScene = preload("res://Scenes/spawn_particles.tscn");

## Temporario
var randInd: int;

const chestPackage = preload("res://Scenes/chest.tscn")

##TODO: depois trocar por um json ou csv
var itensData: Array[Dictionary] = [
	{ 
		"itemName": "Maçã",
		"iconPath": "res://icon.svg",
		"modelPath": "res://Ultimate Stylized Nature - May 2022/glTF/Bush.gltf",
	},
	{ 
		"itemName": "Pera",
		"iconPath": "res://icon.svg",
		"modelPath": "res://Ultimate Stylized Nature - May 2022/glTF/Bush_Small.gltf",
	}
];

## Lista de todos os itens possíveis, em resource
var itens: Array[ItemRes] = [];

func _ready():
	randomize();
	randomizeSpawnSettings();
	
	loadItens()

func _process(delta):
	pass

## Transforma o csv ou json em um array de resource item
func loadItens():
	for item in itensData:
		var _i = ItemRes.new();
		
		_i.itemName = item.itemName;
		_i.iconPath = item.iconPath;
		_i.modelPath = item.modelPath;
		
		itens.append(_i);

## Instancia um baú e adiciona como filho 
func dropChest(dropPosition: Vector2 = defaultDropPos):
	
	var _chest = chestPackage.instantiate();
	
	## O baú está atribuindo aléatoriamente um tipo de item a ele
	_chest.setItemRes(pickRandomItem());
	add_child(_chest);
	
	## Coloquei por enquanto, apenas pra obter um y satisfatório
	var _playerPos = Global.monsterNode.global_position;
	
	var _dropPosition = Vector3(dropPosition.x, _playerPos.y, dropPosition.y);
	_chest.global_position = _dropPosition;
	
	var _part = spawnParticlesScene.instantiate();
	_part.global_position = _dropPosition;
	Global.levelNode.add_child(_part);
	 
	randomizeSpawnSettings()
	
func pickRandomItem():
	var _item: ItemRes = itens.pick_random();
	return _item;
	
## Randomiza índice do monstro e posição de spawn:
func randomizeSpawnSettings() -> void:
	defaultDropPos = Vector2(
		randi_range(-10, 10),
		randi_range(-10, 10)
	);
