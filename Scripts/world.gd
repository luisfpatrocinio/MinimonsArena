extends Node3D

class_name Level

@onready var monsterNode: Monster = get_node("Monster");
@onready var cameraPivot: Node3D = get_node("CameraPivot");
@onready var enemiesManager: EnemiesManager = get_node("EnemiesManager");
@onready var itensManager: ItensManager = $ItensManager;
@onready var interfaceNode: CanvasLayer = get_node("Interface");

## Scene de carta
@onready var cardScene: PackedScene = preload("res://Scenes/cardTag.tscn");

## Scene de partículas de spawn
@onready var spawnParticlesScene: PackedScene = preload("res://Scenes/spawn_particles.tscn");

## Scene do Player
const playerScene: PackedScene = preload("res://Scenes/monster.tscn");
@onready var charactersNode: Node3D = get_node("Character");

## Level Details
var level = {
	"requiredTags": [0, 1, 2]
}

func _ready():
	Global.levelNode = self
	Global.removeAllTagsExcept([0]);	# Remover todas as cartas, exceto tabuleiro.
	Global.setupLevel()
	Global.insertTag.connect(spawnCard)

func _process(delta):
	pass

func dropChest():
	itensManager.dropChest();

func dropItem():
	itensManager.dropItem();

## Temporario
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

## Cria partículas de surgimento ou dessurgimento. Foi adicionada no Level para evitar pequenas falhas visuais.
func createSpawnParticles(spawnPosition: Vector3) -> void:
	var _part = spawnParticlesScene.instantiate();
	_part.global_position = spawnPosition;	
	Global.levelNode.add_child(_part);
	
## Cria partículas de surgimento ou dessurgimento. Foi adicionada no Level para evitar pequenas falhas visuais.
func spawnCard(spawnPosition: Vector3, tagId: int) -> void:
	if tagId == 0:
		return;
	
	if Global.levelNode.get_node("Game").stage != Game.STAGES.PREPARATION:
		print_rich("[b][WORLD.spawnCard][/b] - Carta %s não instanciada pois estamos em jogo.: "  % [tagId]);
		return;
	
	var _part = cardScene.instantiate();
	_part.global_position = spawnPosition;
	_part.tagId = tagId;
	Global.levelNode.get_node("Cards").add_child(_part);	
	print_rich("[b][WORLD.spawnCard][/b] - Carta posicionada: ", tagId);


## Transforma todas as cartas do tabuleiro em inimigos.
func generateEntities() -> void:
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

func spawnPlayer(spawnPosition: Vector2, modelInd: int):
	## Instancia um inimigo e adiciona como filho 
	var _player: Monster = playerScene.instantiate();
	var _monsterKey = Global.getEntityKeyById(modelInd);
		
	print("Definindo player: ", _monsterKey);
	var _monsterModel = Global.monsterDict.get(_monsterKey).get("model") as PackedScene;
	var _model = _monsterModel.instantiate();
	
	var actualMonsterModel = _player.get_child(1)
	if actualMonsterModel != null:
		actualMonsterModel.queue_free()
	_player.add_child(_model)
	_player.myModel = _model;
	
	charactersNode.add_child(_player);
	
	var _spawnPosition = Vector3(spawnPosition.x, 0, spawnPosition.y);
	_player.global_position = _spawnPosition;
	_player.createSpawnParticles();
	print("[WORLD] - Player instanciado na posição: ", _spawnPosition);

