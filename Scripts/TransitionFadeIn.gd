extends CanvasLayer

var progress: float = 0.0;
var destinySceneKey: String = "";
@onready var colorRect: ColorRect = get_node("ColorRect");

func _process(delta):
	var _progressTo = 1.20;
	progress = move_toward(progress, _progressTo, 0.069);
	colorRect.color.a = progress;
	
	if progress >= _progressTo:
		var _scene = Global.scenesDict.get(destinySceneKey);
		get_tree().change_scene_to_packed(_scene);
		queue_free();
