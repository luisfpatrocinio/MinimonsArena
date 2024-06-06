extends Entity
class_name Enemy

func setEnemyModel(monsterKey: String):
	var _enemyModelPackage = Global.monsterDict.get(monsterKey).get("model") as PackedScene;
	var _model = _enemyModelPackage.instantiate();
	add_child(_model);

func _physics_process(delta):
	super(delta);
	move_and_slide();
	
