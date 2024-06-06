extends Node3D

class_name Level

@onready var monsterNode: Monster = get_node("Monster");
@onready var cameraPivot: Node3D = get_node("CameraPivot");
@onready var enemiesManager: EnemiesManager = get_node("EnemiesManager");

func setMonster(monsterKey):
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
	$Label.text = "";
	var _keys = Global.detectedTagsDict.keys();
	for i in range(len(_keys)):
		var _thisKey = _keys[i];
		$Label.text += str(Global.detectedTagsDict.get(_thisKey).get("tvec"));
		$Label.text += "\n"

## Temporario
func _input(event):
	if event is InputEventKey:
		if event.keycode == KEY_B and event.pressed:
			## Pode passar uma posição e um index
			enemiesManager.spawnEnemy();
