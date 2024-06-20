extends Node

var debugMode: bool = false;

## Modo de câmera atual. (em desuso)
var camMode: int = 0;

# Propriedades das tags lidas
## Dicionário com informações das tags atualmente exibidas em tela.
var detectedTagsDict: Dictionary = {}

## Referência do node do Level
@onready var levelNode : Level = null

## Referência do node de Interface
@onready var interfaceNode : Interface = null

## Referência do node do Player
@onready var monsterNode: Monster = null

## Chave do player atual.
var monsterKey: String = "";

## Score
var score: int = 0;	# TODO: Utilizar o ScoreManager e não a Global.

## Dicionário de modelos de monstros.
var monsterDict: Dictionary = {
	"chicken": {
		"id": 1,
		"model": preload("res://Monsters/Chicken.gltf"),
		"name": "Chicken"
	},
	"demon": {
		"id": 2,
		"model": preload("res://Monsters/Demon.gltf"),
		"name": "Demon"
	},
	"panda": {
		"id": 3,
		"model": preload("res://Monsters/Panda.gltf"),
		"name": "Panda"
	},
	"skull": {
		"id": 4,
		"model": preload("res://Monsters/Skull.gltf"),
		"name": "Skull"
	},
	"alien": {
		"id": 5,
		"model": preload("res://Monsters/Alien_Tall.gltf"),
		"name": "Alien"
	},
	"bat": {
		"id": 6,
		"model": preload("res://Monsters/Bat.gltf"),
		"name": "Bat"
	},
	"bee": {
		"id": 7,
		"model": preload("res://Monsters/Bee.gltf"),
		"name": "Bee"
	},
	"cyclops": {
		"id": 8,
		"model": preload("res://Monsters/Cyclops.gltf"),
		"name": "Cyclops"
	},
	"cactus": {
		"id": 9,
		"model": preload("res://Monsters/Cactus.gltf"),
		"name": "Cactus"
	},
}

## [PackedScene] correspondente a transição de Fade In.
@onready var transitionFadeInScene = preload("res://Scenes/transition_fade_in.tscn")

## Dicionário com as [PackedScene] utilizadas no jogo.
var scenesDict: Dictionary = {
	"title": preload("res://Scenes/UI/main_menu.tscn"),
	"characterSelect": preload("res://Scenes/character_select.tscn"),
	"gameLevel": preload("res://Scenes/world.tscn"),
	"scoreScene" : preload("res://Scenes/score_scene.tscn")
}

## Array que guarda a chave dos personagens selecionados. Permite a inserção de mais de uma chave
## para que seja possível mais de um jogador.
var selectedCharacters = []

# 
signal insertTag(pos, id)

func _process(delta):	
	# Alterar modo de câmera. TODO: Teste.
	if Input.is_action_just_pressed("ui_end") and levelNode != null:
		camMode += 1;
		print("[GLOBAL] camMode = ", camMode);
	camMode = camMode % 2;
	
	manageCamera()
	
func insertTagOnDict(tagNo: int) -> void:
	# Perguntar se já existe essa tag, para ver se podemos inserir.
	if detectedTagsDict.has(tagNo):
		return
	detectedTagsDict[tagNo] = {
		"tag": tagNo,
		"tvec": Vector3.ZERO
	}
	print_rich("[color=orange][b][GLOBAL.insertTagOnDict][/b] - Tag %s inserida com sucesso." % [tagNo]);
	insertTag.emit(Vector3.ZERO, tagNo);


## Altera o comportamento da câmera de acordo o camMode.
func manageCamera() -> void:
	if levelNode == null:
		return
	var _cam = levelNode.cameraPivot as Node3D;	
	var _ang = Time.get_ticks_msec() / 5000.0;
	if camMode == 0:
		var _y = 5 + sin(_ang) * 1;
		_cam.position = Vector3(0, _y, 12);
		_cam.look_at(Vector3(0, -2, 5));
	elif camMode == 1:
		var _rvec = getBoardRVec3();
		var _l = 24;
		var _ang2 = deg_to_rad(_rvec.x);
		var _newPos = Vector3(cos(_ang2) * _l, 0, sin(_ang2) * _l);
		_cam.position = _cam.position.lerp(_newPos, 0.20);
		_cam.look_at(Vector3.ZERO);
		
	

## Função que vai analisar se o level está atendendo as condições necessárias.
func checkLevel() -> bool:
	#TODO: Conferir dicionário de levels.
	return true;


## Inicia uma transição para uma Scene específica por meio da chave do scenesDict.
func transitionTo(sceneKey: String) -> void:
	if Global.find_child("TransitionFadeIn") == null:
		var _trans = transitionFadeInScene.instantiate();
		_trans.destinySceneKey = sceneKey;
		Global.add_child(_trans);

func convertArrayStrToVector3(arrayStr: String) -> Vector3:
	if arrayStr == "":
		return Vector3.ZERO;
	# [[-0.10224713], [-0.06778016], [ 0.22128833]]
	# Retirar todos os colchetes
	var _fixedStr = arrayStr.replacen("[", "");
	_fixedStr = _fixedStr.replacen("]", "");
	
	var _elements = _fixedStr.split(", ");
	var _dist = 80;
	var _x = float(_elements[0]) * -_dist;
	var _y = float(_elements[1]) * -_dist;
	var _z = float(_elements[2]) * -_dist;
	var _vector3 = Vector3(_x, _y, _z);
	return _vector3;
	
func getBoardTVec3() -> Vector3:
	return detectedTagsDict.get(0, {"tvec": Vector3.ZERO}).get("tvec");
	
func getBoardRVec3() -> Vector3:
	return detectedTagsDict.get(0, {"rvec": Vector3.ZERO}).get("rvec");

## Retorna o dicionário da entidade a partir do identificador da Tag ARUCO.
func getEntityKeyById(tagId: int) -> String:
	# Percorre todas as keys do dicionário, até encontrar uma com o ID desejado.
	var _keys = monsterDict.keys();
	for key in _keys:
		if monsterDict[key].get("id") == tagId:
			return key
	return ""

## Remove todas as entradas do dicionário detectedTagsDict, exceto aquelas cujas chaves estão 
## listadas no array tagsArray.
func removeAllTagsExcept(tagsArray):
	var _keys = detectedTagsDict.keys();
	for _key in _keys:
		# Verifica se essa key pertence ao array das que devem permanecer.
		if !tagsArray.has(_key):
			detectedTagsDict.erase(_key);
			print_rich("[color=orange][b][GLOBAL][/b] - Tag removida: ", _key);
			if Global.levelNode == null:
				return
			var _cards = Global.levelNode.get_node("Cards");
			for _card in _cards.get_children():
				if _card.tagId == int(_key):
					_card.queue_free();

## Retorna se a carta de tabuleiro está posicionada		
func checkHasBoard() -> bool:
	return Global.detectedTagsDict.has(0);
	
## Retorna se a carta do player atual está em campo		
func checkHasPlayer() -> bool:
	if len(Global.selectedCharacters) <= 0:
		return false
		
	var _playerKey = Global.selectedCharacters[0];
	for tag in Global.detectedTagsDict:
		var _key = Global.getEntityKeyById(tag);
		if _key == _playerKey:
			return true;
	return false;
	
	
func clearDetectedTagsDict() -> void:
	Global.detectedTagsDict = {};
	for tag in Global.detectedTagsDict:
		if tag != 0:
			Global.detectedTagsDict.erase(tag);

func getDotsString() -> String:
	var _pointsCount = (Time.get_ticks_msec() / 500) % 4;
	return str(".").repeat(_pointsCount);
