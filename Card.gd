extends Node3D
class_name Card

@export var tagId: int = 0;
@onready var myMesh: MeshInstance3D = get_node("MeshInstance3D");
var myScale: float = 1.0;

func _ready():
	$Label3D.text = str(tagId);
	$Label3D.scale.x = -1;

func _process(delta):
	# Apontar a label para a câmera, de modo a tornar legível o texto.
	$Label3D.look_at(Global.levelNode.cameraPivot.global_position);
	
	global_position.y = move_toward(global_position.y, 1.0, 0.169)
	
	# Caso seja uma tag tabuleiro:
	if tagId == 0:
		global_position = Vector3(0, global_position.y, 0);
	else:
		if Global.detectedTagsDict.has(tagId):
			if Global.checkHasBoard():			
				var _myDict = Global.detectedTagsDict[tagId];
				var _sp = 0.169;
				var _x = _myDict["tvec"].x;
				var _y = _myDict["tvec"].y;
				var _targetPosition: Vector3 = Vector3(_x, 2, _y);				
				_targetPosition = adjustPos(_targetPosition);
				global_position.x = lerp(global_position.x, _targetPosition.x, _sp);
				global_position.z = lerp(global_position.z, _targetPosition.z, _sp);
	
## Tornar visível caso a tag exista no dicionário.
func adjustScale():
	myScale = 1.0 if Global.detectedTagsDict.has(tagId) else 0.0;
	scale.x = lerp(scale.x, myScale, 0.169);
	scale.z = lerp(scale.z, myScale, 0.169);

## Torna a posição relativa à posição do tabuleiro.
func adjustPos(vec3: Vector3) -> Vector3:
	# Transformada do tabuleiro
	var _boardPos = Global.getBoardTVec3();
	_boardPos = Vector3(_boardPos.x, 2, _boardPos.y);
	
	var pos = vec3 - _boardPos;
	
	#var rvec = Global.getBoardRVec3().y;
	#var l = pos.length();
	#var ang1 = atan2(vec3.z - _boardPos.z, vec3.x - _boardPos.x);
	#pos.x = l * cos(ang1);
	#pos.z = l * sin(ang1);
	#print("rvec: ",  rvec);
	
	return pos;
	
func despawn():
	var tween = get_tree().create_tween();
	tween.tween_property($MeshInstance3D, "scale", Vector3.ZERO, 1);
	tween.tween_callback(self.queue_free);
