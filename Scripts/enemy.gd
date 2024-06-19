extends Entity
class_name Enemy

var myModel: Node3D = null; 	# Atribuído no setEnemyModel.
var myAnim: AnimationPlayer; 	# Atribuído no setEnemyModel.

func _ready():
	connect("dying", die)

func setEnemyModel(monsterKey: String):
	if !Global.monsterDict.has(monsterKey):
		return;
	var _enemyDict: Dictionary = Global.monsterDict.get(monsterKey);
	var _enemyModelPackage = _enemyDict.get("model") as PackedScene;
	var _model = _enemyModelPackage.instantiate();
	myModel = _model;
	myAnim = myModel.get_node("AnimationPlayer") as AnimationPlayer;
	add_child(_model);

func _physics_process(delta):
	super(delta);
	move_and_slide();

func takeDamage(amount):
	super(amount);
	playAnim("HitRecieve");

func playAnim(animKey: String):
	if myAnim != null and myAnim.has_animation(animKey):
		myAnim.play(animKey);

func die():
	despawn();
	Global.score += 100;	# TODO: Utilizar o ScoreManager
	pass
