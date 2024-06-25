extends Entity
class_name Monster

const speed = 6.9
const JUMP_VELOCITY = 4.5

## Pontos totais adquiridos em uma run
# TODO: usar isso
var points: int = 0;

## Turnos sobrevividos em uma run
# TODO: usar isso
var stagesSurvived: int = 0;

## Inimigos mortos pelo player em uma run
# TODO: usar isso
var enemiesKilled: int = 0;

var modelDir: Vector2 = Vector2(0, 0);

var myModel: Node3D = null;
var myAnim: AnimationPlayer;

var attackScene: PackedScene = preload("res://Scenes/attackHitBox.tscn");
var attacking: bool = false;

var dancing: bool = false;

var inputAxis: Vector2 = Vector2.ZERO;

func _ready():
	# Conecta o sinal do player morrendo ( que vem da entidade )
	self.dying.connect(_onDying)
	Global.monsterNode = self;

func _physics_process(delta):
	super(delta);
	myAnim = myModel.get_node("AnimationPlayer") as AnimationPlayer;	
	inputAxis = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down");
	if inputAxis.length() < 0.20:
		inputAxis = Vector2.ZERO;
	
	if Global.camMode == 0 or Global.camMode == 1:
		# Camera Top Down
		if inputAxis and !attacking:
			velocity.x = inputAxis.x * speed
			velocity.z = inputAxis.y * speed
		else:
			velocity.x = move_toward(velocity.x, 0, speed)
			velocity.z = move_toward(velocity.z, 0, speed)
			
	
	## WARNING: TESTES
	if Input.is_action_just_pressed("ui_home"):
		dying.emit()
	
	manageDirection();
	handleKnockback();
	move_and_slide();
	manageAnimations();
	attacking = myAnim.current_animation == "Bite_Front";


func handleKnockback():
	velocity += self.knockback * self.knockbackMultipliyer

func manageDirection():
	if dancing:
		myModel.look_at(Global.levelNode.cameraPivot.global_position * Vector3(1, -1.50, -1))
		return;
	
	# Definir nova direção de vista quando o Player se move
	if inputAxis != Vector2.ZERO:
		modelDir = modelDir.lerp(inputAxis, 0.20);
	
	# Olhar para direção do movimento
	var _newDir = position - Vector3(modelDir.x, 0, modelDir.y);
	if _newDir != position: myModel.look_at(_newDir)

func manageAnimations():
	if dancing:
		if myAnim.has_animation("Dance"):
			myAnim.play("Dance");
			return
	
	var actions = ["Bite_Front"]
	if myAnim.current_animation not in actions:
		if velocity == Vector3.ZERO:
			if myAnim.has_animation("Idle"):
				myAnim.play("Idle");
			else:
				myAnim.play("Flying");
		else:
			if myAnim.has_animation("Walk"):
				myAnim.play("Walk");
			else:
				myAnim.play("Flying");
		# Atacar
		if Input.is_action_just_pressed("ui_accept"):
			myAnim.play("Bite_Front");
			attack()
	
func attack():
	var player_position = global_transform.origin
	var direction_3d = Vector3(modelDir.x, 0.10, modelDir.y).normalized()
	var hitbox_position = player_position + direction_3d * 2
	var hitbox_instance = attackScene.instantiate()
	hitbox_instance.global_transform.origin = hitbox_position
	hitbox_instance.hitboxOwner = self;
	Global.levelNode.add_child(hitbox_instance)

# TODO: Adcionar mais variáveis e detalhes ao scoreboard, assim que mais coisas forem se desenvolvendo
func _onDying():
	var _monsterKey = Global.monsterKey
	var levelScore = ScoreManager.generateLevelScore(_monsterKey, points, stagesSurvived, enemiesKilled)
	ScoreManager.lastGamePlayedScore = levelScore
	ScoreManager.registerScore(levelScore)
	Global.transitionTo("scoreScene")
