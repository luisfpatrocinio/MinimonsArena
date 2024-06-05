extends CharacterBody3D

class_name Enemy

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity");

func setEnemyModel(ind: int):
	var _enemyModelPackage = Global.enemyDict.get(str(ind)).get("model") as PackedScene;
	var _model = _enemyModelPackage.instantiate();
	add_child(_model);

func _process(delta):
	
	if not is_on_floor():
		velocity.y -= gravity * delta;

	move_and_slide();
