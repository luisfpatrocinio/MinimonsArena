extends Entity
class_name Enemy

func setEnemyModel(ind: int):
	var _enemyModelPackage = Global.enemyDict.get(str(ind)).get("model") as PackedScene;
	var _model = _enemyModelPackage.instantiate();
	add_child(_model);

func _physics_process(delta):
	super(delta);
	move_and_slide();
	
