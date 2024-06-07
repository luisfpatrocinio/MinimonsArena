extends Node3D

class_name Level

@onready var monsterNode: Monster = get_node("Monster");
@onready var cameraPivot: Node3D = get_node("CameraPivot");
@onready var enemiesManager: EnemiesManager = get_node("EnemiesManager");
@onready var itensManager: ItensManager = $ItensManager

## Scene de partículas de spawn
@onready var spawnParticlesScene: PackedScene = preload("res://Scenes/spawn_particles.tscn");

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

func _ready():
	Global.levelNode = self
	Global.setupLevel()

func _process(delta):
	pass
	#debugShowPositions();

func dropChest():
	itensManager.dropChest();

## Temporario
func _input(event):
	if event is InputEventKey:
		if event.keycode == KEY_B and event.pressed:
			## Pode passar uma posição e um index
			enemiesManager.spawnEnemy();
			
		if event.keycode == KEY_C and event.pressed:
			## Recebe uma posição
			dropChest();
			
		if event.keycode == KEY_V and event.pressed:
			## Limpa tabuleiro
			updateBoard();

## Cria partículas de surgimento ou dessurgimento. Foi adicionada no Level para evitar pequenas falhas visuais.
func createSpawnParticles(spawnPosition: Vector3) -> void:
	var _part = spawnParticlesScene.instantiate();
	_part.global_position = spawnPosition;	
	Global.levelNode.add_child(_part);
	
func updateBoard() -> void:
	for child: Entity in enemiesManager.get_children():
		child.despawn();

func debugShowPositions():
	$Label.text = "";
	var _keys = Global.detectedTagsDict.keys();
	for i in range(len(_keys)):
		var _thisKey = _keys[i];
		$Label.text += str(_thisKey) + " --- ";
		$Label.text += str(Global.detectedTagsDict.get(_thisKey).get("tvec"));
		$Label.text += "\n"
