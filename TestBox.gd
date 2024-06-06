extends Node3D

func _draw():
	pass

func _process(delta):
	if Global.detectedTagsDict.has(0):
		var _myDict = Global.detectedTagsDict[0];
		var _sp = 0.169;
		global_position.x = lerp(global_position.x, _myDict["tvec"].x, _sp);
		global_position.z = lerp(global_position.z, _myDict["tvec"].z, _sp);
