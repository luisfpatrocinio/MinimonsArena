class_name ServerNode
extends Node

## Modo de câmera atual. (em desuso)
var camMode: int = 0;

## Inicializar servidor
var server := UDPServer.new()

## Clientes conectados
var peers = []

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
@onready var monsterNode = null

## Chave do player atual.
var monsterKey: String = "";

## Estado do Modo de Edição
var editMode: bool = false;

## Dicionário de modelos de monstros.
var monsterDict: Dictionary = {
	"chicken": {
		"model": preload("res://Monsters/Chicken.gltf"),
		"name": "Chicken"
	},
	"demon": {
		"model": preload("res://Monsters/Demon.gltf"),
		"name": "Demon"
	},
	"panda": {
		"model": preload("res://Monsters/Panda.gltf"),
		"name": "Panda"
	},
	"skull": {
		"model": preload("res://Monsters/Skull.gltf"),
		"name": "Skull"
	},
	"alien": {
		"model": preload("res://Monsters/Alien_Tall.gltf"),
		"name": "Alien"
	},
	"bat": {
		"model": preload("res://Monsters/Bat.gltf"),
		"name": "Bat"
	},
	"bee": {
		"model": preload("res://Monsters/Bee.gltf"),
		"name": "Bee"
	},
	"cyclops": {
		"model": preload("res://Monsters/Cyclops.gltf"),
		"name": "Cyclops"
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


func _ready():
	# Iniciar servidor
	server.listen(5569)
	
	
func _process(delta):
	server.poll() # Important!
	
	if server.is_connection_available():
		var peer: PacketPeerUDP = server.take_connection()
		var packet = peer.get_packet()
		var content = packet.get_string_from_utf8()
		print("Received data: %s" % [content])
		
		# Fail fast: pacote inválido.
		if not str(content).contains(":"):
			# TODO: Não faz sentido encerrar a process. Transformar em função.
			return
		
		# Limpar o dicionário, de modo que tags ausentes sejam removidas.
		detectedTagsDict = {};
		
		# Dividir primeiramente em tags.
		var tags: PackedStringArray = str(content).split("#");
		
		# Para cada tag, coletar valores de cada chave.
		for _tagNo in range(len(tags)):
			var tag: String = tags[_tagNo]; #  tagId:40$rvecs:4404404040404$tvecs:4449494949494
			
			# Obter cada chave dessa [tag] atual.
			var keys: PackedStringArray = str(tag).split("$")
			
			var _actualTagId = "";
			for pairKey in keys:
				var commandParts: PackedStringArray = pairKey.split(":") #["tag", "30"]
				var _key: String = commandParts[0];
				match _key:
					"tag":
						_actualTagId = int(commandParts[1]);
						insertTagOnDict(_actualTagId);
					
					"tvecs":
						var _tvec = str(commandParts[1]);
						detectedTagsDict[_actualTagId]["tvec"] = convertArrayStrToVector3(_tvec);
						
					"rvecs":
						print("bolas");
						#rvecs[_tagNo] = str(commandParts[1]);
					#"ang":
						#actualDirection = float(commandParts[1])
					#"x":
						#globalX = float(commandParts[1])
					#"y":
						#globalY = float(commandParts[1])
					#"ori":
						#orientation = convertOrientationToInt(commandParts[1])

		# Reply so it knows we received the message.
		#peer.put_packet(packet)
		## Keep a reference so we can keep contacting the remote peer.
		#peers.append(peer)
	
	#for i in range(0, peers.size()):
		#pass # Do something with the connected peers.
	
	# Alterar modo de câmera
	if Input.is_action_just_pressed("ui_cancel"):
		camMode += 1;
		camMode = camMode % 3;
	
	manageCamera()

func insertTagOnDict(tagNo: int) -> void:
	# Perguntar se já existe essa tag, para ver se podemos inserir.
	if detectedTagsDict.has(tagNo):
		print("Já temos a tag %s no dicionário." % [tagNo]);
		return
	detectedTagsDict[tagNo] = {
		"tag": tagNo,
		"tvec": Vector3.ZERO
	}
	print("Tag %s inserida com sucesso." % [tagNo]);


## Altera o comportamento da câmera de acordo o camMode.
func manageCamera() -> void:
	if levelNode == null:
		return
	var _cam = levelNode.cameraPivot as Node3D;	
	var _ang = Time.get_ticks_msec() / 5000.0;
	if camMode == 0:
		var _y = 10 + sin(_ang) * 4;
		_cam.position = Vector3(0, _y, 30);
		_cam.look_at(Vector3(0, 0, 0));
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

## Inicializa o Level
func setupLevel() -> void:
	levelNode.setMonster(Global.monsterKey)

## Função que vai analisar se o level está atendendo as condições necessárias.
func checkLevel() -> bool:
	#TODO: Conferir dicionário de levels.
	return true;


## Inicia uma transição para uma Scene específica por meio da chave do scenesDict.
func transitionTo(sceneKey: String) -> void:
	#var _scene = Global.scenesDict.get(sceneKey);
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
	print(_fixedStr);
	
	var _elements = _fixedStr.split(", ");
	var _x = float(_elements[0]) * -100;
	var _y = float(_elements[1]) * -100;
	var _z = float(_elements[2]) * -100;
	var _vector3 = Vector3(_x, _y, _z);
	return _vector3;
	
