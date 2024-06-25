extends Node3D

## Classe responsável por gerenciar os objetos instanciados no Level.
class_name Level

## Referência ao nó do monstro do jogador.
@onready var monsterNode: Monster = get_node("Monster")
## Referência ao nó que comporta os monstros dos jogadores.
@onready var charactersNode: Node3D = get_node("Character");
## Referência ao nó de pivô da câmera.
@onready var cameraPivot: Node3D = get_node("CameraPivot")
## Referência ao nó de springArm da câmera.
@onready var springArm: SpringArm3D = get_node("CameraPivot/SpringArm3D")
## Referência ao gerenciador de inimigos.
@onready var enemiesManager: EnemiesManager = get_node("EnemiesManager")
## Referência ao gerenciador de itens.
@onready var itemsManager: ItemsManager = get_node("ItemsManager")
## Referência ao nó da interface.
@onready var interfaceNode: CanvasLayer = get_node("Interface")
## Referência ao gerenciador do jogo.
@onready var gameManager: Game = get_node("Game")
## Scene de carta
@onready var cardScene: PackedScene = preload("res://Scenes/cardTag.tscn");
## Scene de partículas de spawn
@onready var spawnParticlesScene: PackedScene = preload("res://Scenes/spawn_particles.tscn");
## Scene do Player
const playerScene: PackedScene = preload("res://Scenes/monster.tscn");
## Scene da interface de resultados
const scoreScene: PackedScene = preload("res://Scenes/score_scene.tscn")


## Level Details (TODO)
var level = {
	"requiredTags": [0, 1, 2]
}
## Função chamada quando o nó está pronto. Inicializa configurações globais.
func _ready():
	# Define a referência global do Level para o nó atual.
	Global.levelNode = self
	# Remove todas as cartas do jogo, exceto as do tabuleiro.
	Global.removeAllTagsExcept([0]);
	# Conecta o sinal 'insertTag' à função 'spawnCard' para gerar cartas.
	Global.insertTag.connect(spawnCard)
	

## Faz surgir um baú numa posição aleatória. #TODO: Parametrizar posição de surgimento.
func dropChest():
	itemsManager.dropChest();

## Faz surgir um item numa posição aleatória. #TODO: Parametrizar posição de surgimento.
func dropItem():
	itemsManager.dropItem();

## Cria partículas de surgimento ou dessurgimento. Foi adicionada no Level para evitar pequenas falhas visuais.
func createSpawnParticles(spawnPosition: Vector3) -> void:
	var _part = spawnParticlesScene.instantiate();
	_part.global_position = spawnPosition;	
	Global.levelNode.add_child(_part);
	
## Função para instanciar e posicionar uma carta [Card] com ID específico no jogo na posição [Vector3] desejada.
func spawnCard(spawnPosition: Vector3, tagId: int) -> void:
	# Carta de Tabuleiro não pode ser instanciada.
	if tagId == 0:
		return;
	
	# Não instanciar caso não estejamos na Etapa de Preparação.
	if Global.levelNode.get_node("Game").stage != Game.STAGES.PREPARATION:
		print_rich("[b][WORLD.spawnCard][/b] - Carta %s não instanciada pois estamos em jogo.: "  % [tagId]);
		return;
	
	# Instanciar cena da carta na posição desejada, e atribuindo seu ID (valor da tag).
	var _part = cardScene.instantiate();
	_part.global_position = spawnPosition;
	_part.tagId = tagId;
	Global.levelNode.get_node("Cards").add_child(_part);
	print_rich("[b][WORLD.spawnCard][/b] - Carta posicionada: ", tagId);


## Transforma todas as cartas do tabuleiro em inimigos.
func generateEntities() -> void:
	if Global.debugMode:
		print_rich("[b][WORLD.generateEntities][/b] - Forçando o spawn de entidades (DEBUG_MODE = true)")
		forceEntitySpawn()
		return
		
	print_rich("[b][WORLD.generateEntities][/b] - Gerando entidades a partir das cartas.");
	# Destrói todas as entidades, só pra garantir.
	for child: Entity in enemiesManager.get_children():
		child.despawn();
	
	# Percorre todas as cartas.
	var _cards: Node3D = get_node("Cards");
	for _card in _cards.get_children():
		# Não instanciar a carta de tabuleiro.
		if _card.tagId == 0 or !_card.visible:
			continue
		
		_card.visible = false;		
		
		var _modelKey = Global.getEntityKeyById(_card.tagId);
		
		# Se for o player:		
		if _modelKey == Global.selectedCharacters[0]:
			spawnPlayer(Vector2(_card.global_position.x, _card.global_position.z), _card.tagId)
			continue;
			
		## TODO: Chave do modelo a partir do TagID (int)
		enemiesManager.spawnEnemy(Vector2(_card.global_position.x, _card.global_position.z), _card.tagId)

## Destrói entidades e repõe as cartas no tabuleiro.	
func startPreparation() -> void:
	gameManager.stage = Game.STAGES.PREPARATION;
	print_rich("[b][WORLD.startPreparation][/b] - Etapa de preparação.")
	for player: Monster in charactersNode.get_children():
		print_rich("[b][WORLD.startPreparation][/b] - Player despawnado.")		
		player.despawn();
	
	for child: Entity in enemiesManager.get_children():
		print_rich("[b][WORLD.startPreparation][/b] - Entidade %s despawnada." % [child.name])		
		child.despawn();
	
	var _cards: Node3D = get_node("Cards");
	for _card in _cards.get_children():
		print_rich("[b][WORLD][/b] - Carta destruída: ", _card.tagId);				
		_card.despawn();
	
	# Limpa dicionário.
	Global.clearDetectedTagsDict();

## Função para instanciar e posicionar um jogador no jogo.
func spawnPlayer(spawnPosition: Vector2, modelInd: int):
	# Instancia um inimigo e adiciona como filho 
	var _player: Monster = playerScene.instantiate();
	# Obtém a chave do modelo do jogador a partir do índice fornecido.
	var _monsterKey = Global.getEntityKeyById(modelInd);	
	print("Definindo player: ", _monsterKey);
	
	## Obtém o modelo do monstro correspondente à chave.
	var _monsterModel = Global.monsterDict.get(_monsterKey).get("model") as PackedScene;
	## Instancia o modelo do monstro.
	var _model = _monsterModel.instantiate();
	
	# Verifica se o jogador já tem um modelo de monstro filho e, se sim, remove-o.
	var actualMonsterModel = _player.get_child(1)
	if actualMonsterModel != null:
		actualMonsterModel.queue_free()
		
	# Adiciona o novo modelo de monstro como filho do jogador.
	_player.add_child(_model)
	# Define o modelo do monstro no jogador.
	_player.myModel = _model;
	
	_player.dying.connect(_onPlayerDie)
	
	# Adiciona o jogador ao nó de personagens.
	charactersNode.add_child(_player);
	
	# Converte a posição de spawn de Vector2 para Vector3 e define a posição global do jogador.
	var _spawnPosition = Vector3(spawnPosition.x, 0, spawnPosition.y);
	_player.global_position = _spawnPosition;
	_player.createSpawnParticles();
	print("[WORLD] - Player instanciado na posição: ", _spawnPosition);
	
func _onPlayerDie():
	await get_tree().create_timer(1).timeout;
	var _score: CanvasLayer = scoreScene.instantiate();
	add_child(_score);
	#_score.global_position = Vector2.ZERO;
	
## (DEBUG) Funções de Teste.
func _input(event):
	if event is InputEventKey:
		if event.keycode == KEY_B and event.pressed:
			## Pode passar uma posição e um index
			enemiesManager.spawnEnemy();
			
		if event.keycode == KEY_C and event.pressed:
			## Recebe uma posição
			dropChest();
			
		if event.keycode == KEY_C and event.pressed:
			## Recebe uma posição
			dropItem();
			
		if event.keycode == KEY_V and event.pressed:
			## Limpa tabuleiro
			generateEntities();
			
## Spawna forçadamente entidades, usado quando o [Global.debugMode] = true
func forceEntitySpawn(enemies_count=1):
	var playerPosition = Vector2(0, 0)
	spawnPlayer(playerPosition, 1)
	for i in range(enemies_count):
		enemiesManager.spawnEnemy(playerPosition + Vector2(randi_range(3, 5), randi_range(3, 5)))
