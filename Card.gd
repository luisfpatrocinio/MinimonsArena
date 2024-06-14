extends Node3D
class_name Card

@export var tagId: int = 0;
@onready var myMesh: MeshInstance3D = get_node("MeshInstance3D");
var myScale: float = 1.0;

func _ready():
	#var material = myMesh.get_surface_material(0);
	#material.albedo_color = Color(1, 0, 0);
	#myMesh.set_surface_material(0, material);
	
	$Label3D.text = str(tagId);
	$Label3D.scale.x = -1;

func _process(delta):
	# Apontar a label para a câmera, de modo a tornar legível o texto.
	$Label3D.look_at(Global.levelNode.cameraPivot.global_position);
	
	#adjustScale();
	
	global_position.y = move_toward(global_position.y, 1.0, 0.169)
	#TODO: Seria interessante fazer a carta sumir caso não esteja no tabuleiro
	
	# Caso seja uma tag tabuleiro:
	if tagId == 0:
		global_position = Vector3(0, global_position.y, 0);
	else:
		if Global.detectedTagsDict.has(tagId):
			if Global.checkHasBoard():			
				var _myDict = Global.detectedTagsDict[tagId];
				var _sp = 0.169;
				var _targetPosition: Vector3 = Vector3(_myDict["tvec"].x, 2, _myDict["tvec"].y);
				_targetPosition = adjustPos(_targetPosition);
				global_position.x = lerp(global_position.x, _targetPosition.x, _sp);
				global_position.z = lerp(global_position.z, _targetPosition.z, _sp);
	
## Tornar visível caso a tag exista no dicionário.
func adjustScale():
	myScale = 1.0 if Global.detectedTagsDict.has(tagId) else 0.0;
	scale.x = lerp(scale.x, myScale, 0.169);
	scale.z = lerp(scale.z, myScale, 0.169);

func adjustPos(vec3: Vector3) -> Vector3:
	var _boardPos = Global.getBoardVec3();
	_boardPos = Vector3(_boardPos.x, 2, _boardPos.y)
	return vec3 - _boardPos;
	
func despawn():
	var tween = get_tree().create_tween();
	tween.tween_property($MeshInstance3D, "scale", Vector3.ZERO, 1);
	tween.tween_callback(self.queue_free);
