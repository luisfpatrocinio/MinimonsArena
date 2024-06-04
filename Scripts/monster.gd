extends CharacterBody3D
class_name Monster

const speed = 5.0
const JUMP_VELOCITY = 4.5

var modelDir: Vector2 = Vector2(0, 0);

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity");

var myModel: Node3D = null;
var myAnim: AnimationPlayer;

func _physics_process(delta):
	myAnim = myModel.get_node("AnimationPlayer") as AnimationPlayer;
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta;
	
	var lAxisY = Input.get_axis("ui_up", "ui_down");
	var lAxisX = Input.get_axis("ui_left", "ui_right");
	
	var _axis = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down");
	if _axis.length() < 0.20:
		_axis = Vector2.ZERO;
#	var _axis = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down");
	
	if _axis:
		velocity.x = _axis.x * speed
		velocity.z = _axis.y * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
	
	move_and_slide();
	
	# Definir nova direção de vista quando o Player se move
	if _axis != Vector2.ZERO:
		modelDir = modelDir.lerp(_axis, 0.20);
	
	# Olhar para direção do movimento
	var _newDir = position - Vector3(modelDir.x, 0, modelDir.y);
	if _newDir != position: myModel.look_at(_newDir)
	
	if myAnim.current_animation != "Bite_Front":
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

		if Input.is_action_just_pressed("ui_accept"):
			myAnim.play("Bite_Front");


func manageSprites():
	var _anim = "Idle"
	if velocity.length() > 0:
		_anim = "Walk"
	if !is_on_floor():
		_anim = "Jump"
	
	var _animationPlayer = myModel.get_node("AnimationPlayer") as AnimationPlayer;
	_animationPlayer.play(_anim);
	



func _on_timer_timeout():
	pass # Replace with function body.
