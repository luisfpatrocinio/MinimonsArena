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
	#debugShowPositions();

func setMonster(monsterKey):
	if monsterNode == null:
		return;
		
	print("Definindo monstro: ", monsterKey);
	var _monsterModel = Global.monsterDict.get(monsterKey).get("model") as PackedScene;
	var _model = _monsterModel.instantiate();
	
	var actualMonsterModel = monsterNode.get_child(1)
	if actualMonsterModel != null:
		actualMonsterModel.queue_free()
	monsterNode.add_child(_model)
	monsterNode.myModel = _model;

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
	var _part = cardScene.instantiate();
	_part.global_position = spawnPosition;
	_part.tagId = tagId;
	Global.levelNode.get_node("Cards").add_child(_part);
	print_rich("[b][WORLD.spawnCard][/b] - Carta posicionada: ", tagId);


## Transforma todas as cartas do tabuleiro em inimigos.
func generateEntities() -> void:
	print_rich("[b][WORLD.generateEntities][/b] - Gerando entidades a partir das cartas.")
	for child: Entity in enemiesManager.get_children():
		child.despawn();
	
	var _cards: Node3D = get_node("Cards");
	for _card in _cards.get_children():
		if _card.tagId == 0 or !_card.visible:
			continue
			
		## TODO: Chave do modelo a partir do TagID (int)
		var _modelKey = Global.getEntityKeyById(_card.tagId);
		enemiesManager.spawnEnemy(Vector2(_card.global_position.x, _card.global_position.z), _card.tagId)
		_card.visible = false;

## Destrói entidades e repõe as cartas no tabuleiro.	
func startPreparation() -> void:
	print_rich("[b][WORLD.startPreparation][/b] - Etapa de preparação.")
	for child: Entity in enemiesManager.get_children():
		child.despawn();
	
	var _cards: Node3D = get_node("Cards");
	for _card in _cards.get_children():
		print_rich("[b][WORLD][/b] - Carta destruída: ", _card.tagId);
		_card.despawn();
	
	# Limpa dicionário.
	Global.detectedTagsDict = {};

func debugShowPositions():
	$Label.text = "";
	var _keys = Global.detectedTagsDict.keys();
	for i in range(len(_keys)):
		var _thisKey = _keys[i];
		$Label.text += str(_thisKey) + " --- ";
		$Label.text += str(Global.detectedTagsDict.get(_thisKey).get("tvec"));
		$Label.text += "\n"
