extends Node3D

@export var tagId: int = 0;
@onready var myMesh: MeshInstance3D = get_node("MeshInstance3D");
var myScale: float = 1.0;

func _ready():
	var _colors = [Color.RED, Color.AQUA, Color.NAVY_BLUE, Color.GREEN, Color.YELLOW];
	var _material = myMesh.mesh.surface_get_material(0)
	_material.albedo_color = _colors[tagId % len(_colors)]
	
	$Label3D.text = str(tagId);
	$Label3D.scale.x = -1;

func _process(delta):
	# Apontar a label para a câmera, de modo a tornar legível o texto.
	$Label3D.look_at(Global.levelNode.cameraPivot.global_position);
	
	#adjustScale();
	
	#TODO: Seria interessante fazer a carta sumir caso não esteja no tabuleiro
	
	# Caso seja uma tag tabuleiro:
	if tagId == 0:
		global_position = Vector3(0, global_position.y, 0);
	else:
		visible = false;
		if Global.detectedTagsDict.has(tagId):
			visible = true;
			var _myDict = Global.detectedTagsDict[tagId];
			var _sp = 0.169;
			var _targetPosition: Vector3 = Vector3(_myDict["tvec"].x, 2, _myDict["tvec"].y);
			_targetPosition = adjustPos(_targetPosition);
			global_position.x = lerp(global_position.x, _targetPosition.x, _sp);
			global_position.z = lerp(global_position.z, _targetPosition.z, _sp);
			#global_position = lerp(global_position, _targetPosition, _sp);
	
## Tornar visível caso a tag exista no dicionário.
func adjustScale():
	myScale = 1.0 if Global.detectedTagsDict.has(tagId) else 0.0;
	scale.x = lerp(scale.x, myScale, 0.169);
	scale.z = lerp(scale.z, myScale, 0.169);

func adjustPos(vec3: Vector3) -> Vector3:
	var _boardPos = Global.getBoardVec3();
	_boardPos = Vector3(_boardPos.x, 2, _boardPos.y)
	return vec3 - _boardPos;
