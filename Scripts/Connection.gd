extends Node

## Classe responsável por conectar o jogo ao servidor em Python.

## Inicializar servidor
@export var port: int = 5569;
var server := UDPServer.new()

## Clientes conectados
var peers = []

var connected: bool = false;

func _ready():
	# Iniciar servidor
	server.listen(port);

func _process(delta):
	# IMPORTANTE: Processar novos pacotes.
	server.poll() 
	
	# Um pacote com uma nova combinação de endereço/porta foi recebido no socket:
	#print("Conectado: ", connected);
	if server.is_connection_available():
		connected = true;
		var peer: PacketPeerUDP = server.take_connection();
		var packet = peer.get_packet();
		managePackageContent(packet);
		
	if !server.is_listening():
		connected = false;

func managePackageContent(packet):
	var content = packet.get_string_from_utf8();
	
	# Limpar array de tags caso não hajam tags detectadas.
	if str(content).contains("EMPTY"):
		Global.detectedTagsDict = {};
	
	# Fail fast: pacote inválido. Para nosso jogo, um pacote sem ":" não tem utilidade.
	if not str(content).contains(":"):
		return
	
	# Limpar o dicionário, de modo que tags ausentes sejam removidas.
	#Global.detectedTagsDict = {};
	
	# Dividir primeiramente em tags.
	var tags: PackedStringArray = str(content).split("#");
	
	var _detectedTagsIds: Array[int] = [];
	for i in range(len(tags)):
		var tag: String = tags[i]; 
		var keys: PackedStringArray = str(tag).split("$");
		for pair in keys:
			var _pairParts = pair.split(":");
			var _key = _pairParts[0];
			if _key == "tag":
				_detectedTagsIds.append(int(_pairParts[1]));
	print_rich("[color=green][b][CONNECTION][/b] - Received Detected Tags IDs: ", _detectedTagsIds)
	
	# Para cada tag, coletar valores de cada chave.
	for i in range(len(tags)):
		var tag: String = tags[i]; 
		
		# Obter cada chave dessa tag atual.
		var keys: PackedStringArray = str(tag).split("$");
		
		# Precisamos guardar o ID da tag atual, para que possamos atribuir valores às variáveis 
		# corretas.
		var _actualTagId = "";
		for pair in keys:
			var _pairParts: PackedStringArray = pair.split(":");
			var _key: String = _pairParts[0];
			match _key:
				"tag":
					_actualTagId = int(_pairParts[1]);
					Global.insertTagOnDict(_actualTagId);
					#_detectedTagsIds.append(_actualTagId);
				
				"tvecs":
					var _tvec = str(_pairParts[1]);
					Global.detectedTagsDict[_actualTagId]["tvec"] = Global.convertArrayStrToVector3(_tvec);
					
				"rvecs":
					var _rvec = str(_pairParts[1]);
					Global.detectedTagsDict[_actualTagId]["rvec"] = Global.convertArrayStrToVector3(_rvec);

	# Depois de tudo, precisamos remover as tags que não estão no dicionário.
	Global.removeAllTagsExcept(_detectedTagsIds);
	

