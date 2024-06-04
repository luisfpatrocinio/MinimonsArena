extends Node3D

class_name Level

@onready var monsterNode: Monster = get_node("Monster");
@onready var cameraPivot: Node3D = get_node("CameraPivot");

func setMonster(ind):
	var _monsterModel = Global.monsterDict.get(str(ind)).get("model") as PackedScene;
	var _model = _monsterModel.instantiate();
	
	if Global.actualMonsterModelIndKey != ind:
		var actualMonsterModel = monsterNode.get_child(1)
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
	var _ang = Time.get_ticks_msec() / 5000.0;
	var _l = 24;
	cameraPivot.position.x = cos(_ang) * 2;
	cameraPivot.position.z = _l + sin(_ang) * 2;
	cameraPivot.look_at(monsterNode.position);

