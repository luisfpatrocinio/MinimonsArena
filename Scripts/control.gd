extends Node

## Modo de câmera atual. (em desuso)
var camMode: int = 0;

# Propriedades das tags lidas
## Vetores de rotação, em strings.
var rvecs: Array[String] = []
## Vetores de transformação, em strings.
var tvecs: Array[String] = []

## Dicionário com informações das tags atualmente exibidas em tela.
var detectedTagsDict: Dictionary = {}

## Referência do node do Level
@onready var levelNode : Level = null

## Referência do node do Player
@onready var monsterNode: Monster = null

## Chave do player atual.
var monsterKey: String = "";

## Estado do Modo de Edição
var editMode: bool = false;

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
	"title": preload("res://Scenes/title.tscn"),
	"characterSelect": preload("res://Scenes/character_select.tscn"),
	"gameLevel": preload("res://Scenes/world.tscn"),
	"scoreScene" : preload("res://Scenes/score_scene.tscn")
}

# 
signal insertTag(pos, id)
	
func _process(delta):	
	# Alterar modo de câmera
	if Input.is_action_just_pressed("ui_cancel") and false:
		camMode += 1;
		camMode = camMode % 4;
	
	manageCamera()

func insertTagOnDict(tagNo: int) -> void:
	# Perguntar se já existe essa tag, para ver se podemos inserir.
	if detectedTagsDict.has(tagNo):
		return
	detectedTagsDict[tagNo] = {
		"tag": tagNo,
		"tvec": Vector3.ZERO
	}
	print("[GLOBAL.insertTagOnDict] - Tag %s inserida com sucesso." % [tagNo]);
	insertTag.emit(Vector3.ZERO, tagNo);
	# NÃO USADO MAIS: emit_signal("InsertTag", Vector3.ZERO, tagNo);


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
		var _l = 24;
		_cam.position.x = cos(_ang) * _l;
		_cam.position.z = sin(_ang) * _l;
		_cam.position.y = 0;
		_cam.look_at(monsterNode.position);
	elif camMode == 2:
		var _newPos = monsterNode.position + Vector3(monsterNode.modelDir.x, 0, monsterNode.modelDir.y) * -16
		_cam.position = _cam.position.lerp(_newPos, 0.169 / 4.0);
		_cam.look_at(monsterNode.position)
	elif camMode == 3:
		_cam.position.x = 0
		_cam.position.z = 0
		_cam.position.y = 32;
		_cam.look_at(levelNode.position);

## Inicializa o Level
func setupLevel() -> void:
	levelNode.setMonster(Global.monsterKey)

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
	
func getBoardVec3() -> Vector3:
	return detectedTagsDict.get(0, {"tvec": Vector3.ZERO}).get("tvec");

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
			print("[GLOBAL] - Tag removida: ", _key);
			var _cards = Global.levelNode.get_node("Cards");
			for _card in _cards.get_children():
				if _card.tagId == int(_key):
					_card.queue_free();
			
