class_name ServerNode
extends Node

var camMode: int = 0;
var server := UDPServer.new()
var peers = []

var actualDirection = 0.0
var orientation = 0
var globalX = 0
var globalY = 0

@onready var levelNode : Level = null
@onready var monsterNode = null

var actualMonsterModelIndKey = "0";

var editMode: bool = false;

var monsterDict = {
	"1": {
		"model": preload("res://Monsters/Chicken.gltf"),
		"name": "Chicken"
	},
	"2": {
		"model": preload("res://Monsters/Demon.gltf"),
		"name": "Demon"
	},
	"3": {
		"model": preload("res://Monsters/Panda.gltf"),
		"name": "Panda"
	},
	"4": {
		"model": preload("res://Monsters/Skull.gltf"),
		"name": "Skull"
	},
}
var enemyDict: Dictionary = {
	"1": {
		"model": preload("res://Monsters/Alien_Tall.gltf"),
		"name": "Alien"
	},
	"2": {
		"model": preload("res://Monsters/Bat.gltf"),
		"name": "Bat"
	},
	"3": {
		"model": preload("res://Monsters/Bee.gltf"),
		"name": "Bee"
	},
	"4": {
		"model": preload("res://Monsters/Cyclops.gltf"),
		"name": "Cyclops"
	},
}

func convertOrientationToInt(orient: String):
	match orient:
		"UP":
			return 0
		"RIGHT":
			return 1
		"DOWN":
			return 2
		"LEFT":
			return 3

func floatToVector2(angle_deg: float) -> Vector2:
	var angle_rad = deg_to_rad(angle_deg)  # Converter ângulo de graus para radianos
	var x = cos(angle_rad)
	var y = sin(angle_rad)
	return Vector2(x, y)

func _ready():
	server.listen(5569)
	

func _process(delta):
	server.poll() # Important!
	if server.is_connection_available():
		var peer: PacketPeerUDP = server.take_connection()
		var packet = peer.get_packet()
		#print("Accepted peer: %s:%s" % [peer.get_packet_ip(), peer.get_packet_port()])
		var content = packet.get_string_from_utf8()
		#$Panel/Label.text = content
		print("Received data: %s" % [content])
		
		# Dividir bastante o pacote:
		if not str(content).contains(":"):
			return
			
		var commands = str(content).split("|")
		for command in commands:
			var commandParts = command.split(":")
			var _key = commandParts[0]
			match _key:
				"content":
					var monsterInd = commandParts[1]
					levelNode.setMonster(monsterInd)
					
				"ang":
					actualDirection = float(commandParts[1])
				"x":
					globalX = float(commandParts[1])
				"y":
					globalY = float(commandParts[1])
				"ori":
					orientation = convertOrientationToInt(commandParts[1])

		# Reply so it knows we received the message.
		#peer.put_packet(packet)
		## Keep a reference so we can keep contacting the remote peer.
		#peers.append(peer)
	

	for i in range(0, peers.size()):
		pass # Do something with the connected peers.
	
	if Input.is_action_just_pressed("ui_cancel"):
		camMode += 1;
		camMode = camMode % 3;
	
	manageCamera()
	
func manageCamera():
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

func setupLevel():
	var monsterInd = "1";
	levelNode.setMonster(monsterInd)

## Função que vai analisar se o level está atendendo as condições necessárias.
func checkLevel() -> bool:
	#TODO: Conferir dicionário de levels.
	return true;
