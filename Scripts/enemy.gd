extends Entity
class_name Enemy
@onready var attackScene: PackedScene = preload("res://Scenes/attackHitBox.tscn")
@onready var attackCooldownTimer: Timer = get_node("timerToAttack")
var myModel: Node3D = null; 	# Atribuído no setEnemyModel.
var myAnim: AnimationPlayer; 	# Atribuído no setEnemyModel.

## Direção usada no movimento do inimigo
var direction: Vector3

## Velocidade de movimento do inimigo
@export var speed: float = 2

##

enum states {
	NORMAL,
	ATTACKING
}

var actualState: states = states.NORMAL

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
	match actualState:
		states.NORMAL:
			attackCooldownTimer.paused = true
			moveTowardsPlayer()
		states.ATTACKING:
			attackCooldownTimer.paused = false
			velocity = Vector3.ZERO
	
	super(delta);
	move_and_slide();

func takeDamage(amount):
	super(amount);
	playAnim("HitRecieve");

func getPlayerDirection():
	var player = Global.monsterNode
	if !Global.monsterNode:
		return Vector3.ZERO
	return global_position.direction_to(player.global_position)
	
func moveTowardsPlayer():
	lookAtPlayer()
	direction = getPlayerDirection()
	velocity = direction * speed
	if !myModel: return
	

func lookAtPlayer():
	var playerPosition = Global.monsterNode.global_position
	myModel.look_at(Vector3(-playerPosition.x, 0, -1.5 * playerPosition.z))
	

func playAnim(animKey: String):
	if myAnim != null and myAnim.has_animation(animKey):
		myAnim.play(animKey);

func die():
	despawn();
	Global.score += 100;	# TODO: Utilizar o ScoreManager
	pass

func changeState(newState: states):
	if actualState == newState:
		return
	actualState = newState
	

func manageAnimations():
	if myAnim.current_animation != "Bite_Front":
		myAnim.play("walk")
		

func attack():
	lookAtPlayer()
	var player_position = global_transform.origin
	var direction_3d = Vector3(direction.x, 0.10, direction.y).normalized()
	var hitbox_position = player_position + direction_3d * 2
	var hitbox_instance = attackScene.instantiate()
	hitbox_instance.global_transform.origin = hitbox_position
	hitbox_instance.hitboxOwner = self;
	Global.levelNode.add_child(hitbox_instance)
	playAnim("Bite_Front")

func _on_player_detector_body_entered(body: Node3D) -> void:
	if body is Monster:
		changeState(states.ATTACKING)

func _on_player_detector_body_exited(body: Node3D) -> void:
	if body is Monster:
		changeState(states.NORMAL)

func _on_attack_cooldown_timeout() -> void:
	attack()
	attackCooldownTimer.start(0.3)
