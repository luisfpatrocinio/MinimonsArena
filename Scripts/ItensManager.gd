extends Node3D

## Classe responsável por gerenciar todo tipo de entidade de item
class_name ItemsManager

## Posição padrão de drop de itens.
@export var defaultDropPos: Vector2 = Vector2(10, 10);

## Scene de partículas de spawn
@onready var spawnParticlesScene: PackedScene = preload("res://Scenes/spawn_particles.tscn");

const itemPackage = preload("res://Scenes/item.tscn");

## Temporario
var randInd: int;

const chestPackage = preload("res://Scenes/chest.tscn")

##TODO: depois trocar por um json ou csv
var itensData: Array[Dictionary] = [
	{ 
		"itemName": "Health Potion",
		"iconPath": "res://icon.svg",
		"modelPath": "res://Assets/Objects/PickupHealth.glb",
	},
	{ 
		"itemName": "Coin",
		"iconPath": "res://icon.svg",
		"modelPath": "res://Assets/Objects/Coin.glb",
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

func dropItem(dropPosition: Vector2 = defaultDropPos, res: ItemRes = null):
	if !res:
		res = pickRandomItem();
		
	## Coloquei por enquanto, apenas pra obter um y satisfatório
	var _playerPos = Global.monsterNode.global_position;
	
	var _item: Item = itemPackage.instantiate();
	_item.setItemRes(res) 
	_item.global_position = Vector3(
		dropPosition.x,
		_playerPos.y + 2,
		dropPosition.y
	);
	
	get_parent().add_child(_item);
	
	randomizeSpawnSettings();

## Instancia um baú e adiciona como filho 
func dropChest(dropPosition: Vector2 = defaultDropPos):
	
	var _chest: Chest = chestPackage.instantiate();
	
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
