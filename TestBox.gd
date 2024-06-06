extends Node3D

func _draw():
	pass

func _process(delta):
	if Global.detectedTagsDict.has(0):
		var _myDict = Global.detectedTagsDict[0]
		global_position.x = _myDict["tvec"].x ;
		global_position.z = _myDict["tvec"].z;
