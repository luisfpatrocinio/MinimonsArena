extends Entity
class_name Enemy

var myModel: Node3D = null; 	# Atribuído no setEnemyModel.
var myAnim: AnimationPlayer; 	# Atribuído no setEnemyModel.

func _ready():
	connect("dying", die)

func setEnemyModel(monsterKey: String):
	var _enemyModelPackage = Global.monsterDict.get(monsterKey).get("model") as PackedScene;
	var _model = _enemyModelPackage.instantiate();
	myModel = _model;
	myAnim = myModel.get_node("AnimationPlayer") as AnimationPlayer;
	add_child(_model);

func _physics_process(delta):
	super(delta);
	move_and_slide();

func takeDamage(amount):
	super(amount);
	myAnim.play("HitRecieve");

func die():
	despawn();
	pass
