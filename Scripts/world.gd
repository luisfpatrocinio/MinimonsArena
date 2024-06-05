extends Node3D

class_name Level

@onready var monsterNode: Monster = get_node("Monster");
@onready var cameraPivot: Node3D = get_node("CameraPivot");
@onready var enemiesManager: EnemiesManager = $EnemiesManager 

func setMonster(ind):
	var _monsterModel = Global.monsterDict.get(str(ind)).get("model") as PackedScene;
	var _model = _monsterModel.instantiate();
	
	if Global.actualMonsterModelIndKey != ind:
		var actualMonsterModel = monsterNode.		get_child(1)
		if actualMonsterModel != null:		
			actualMonsterModel.queue_free()
		monsterNode.add_child(_model)
		Global.actualMonsterModelIndKey = ind
	
	monsterNode.myModel = _model;

func _ready():
	Global.levelNode = self
	Global.setupLevel()

func _process(delta):
	$Label.text = str(Global.actualDirection)
	
	# Movimentar Camera
	

## Temporario
func _input(event):
	if event is InputEventKey:
		if event.keycode == KEY_B and event.pressed:
			## Pode passar uma posição e um index
			enemiesManager.spawnEnemy();
