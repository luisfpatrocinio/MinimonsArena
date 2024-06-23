extends Node

class_name CameraConnectionManagere
## Classe responsável por conectar o jogo ao servidor em Python via UDP.

## Porta do servidor para incializar a comunicação.
@export var port: int = 5569;

## Instância do Servidor UDP.
var server := UDPServer.new()

## Lista de clientes conectados
var peers = []

## Indica se há uma conexão estabelecida com o servidor.
var connected: bool = false;

## Inicializar a comunicação com o Servidor na porta especificada.
func _ready():
	server.listen(port);

func _process(delta):
	# Processa novos pacotes recebidos pelo servidor.
	server.poll() 
	
	# Verifica se um novo pacote com uma combinação de endereço/porta foi recebido.
	if server.is_connection_available():
		connected = true;
		
		# Aceita a conexão e obtém o peer do pacote UDP.
		var peer: PacketPeerUDP = server.take_connection();
		
		# Obter o pacote recebido e gerenciar seu conteúdo.
		var packet = peer.get_packet();	
		managePackageContent(packet);
	
	# Verificar se o servidor não está mais escutando (listening).
	if !server.is_listening():
		connected = false;


## Função para gerenciar o conteúdo de um pacote recebido.
func managePackageContent(packet):
	# Obtém o conteúdo do pacote como uma string UTF-8.
	var content = packet.get_string_from_utf8();
	
	# Limpa o array de tags se não houver conteúdo no pacote.
	if len(content) <= 0:
		print_rich("[color=green][b][CONNECTION][/b] - Pacote vazio recebido. Limpando dicionário.");
		Global.removeAllTagsExcept([]);
	
	# Fail fast: retorna se o pacote for inválido (não contém ":").
	if not str(content).contains(":"):
		return
	
	# Divide o conteúdo em tags usando "#" como delimitador.
	var tags: PackedStringArray = str(content).split("#")
	
	# Array para armazenar os IDs das tags detectadas.
	var _detectedTagsIds: Array[int] = [];
	
	# Itera sobre as tags para coletar os IDs das tags detectadas.
	for i in range(len(tags)):
		var tag: String = tags[i]; 
		var keys: PackedStringArray = str(tag).split("$");
		for pair in keys:
			var _pairParts = pair.split(":");
			var _key = _pairParts[0];
			if _key == "tag":
				_detectedTagsIds.append(int(_pairParts[1]));
	
	print_rich("[color=green][b][CONNECTION][/b] - Received Detected Tags IDs: ", _detectedTagsIds);
	
	# Itera novamente sobre as tags para coletar os valores de cada chave.
	for i in range(len(tags)):
		var tag: String = tags[i]; 
		# print_rich("[color=green][b][CONNECTION][/b] - Operando tag: ", tag)
		
		# Obtém cada chave da tag atual.
		var keys: PackedStringArray = str(tag).split("$");
		
		# Armazena o ID da tag atual para atribuir valores às variáveis corretas.
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

	# Remove as tags que não estão no dicionário de tags detectadas.
	Global.removeAllTagsExcept(_detectedTagsIds);
