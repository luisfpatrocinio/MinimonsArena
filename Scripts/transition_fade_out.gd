extends CanvasLayer

var progress: float = 1.0;
var destinySceneKey: String = "";
@onready var colorRect: ColorRect = get_node("ColorRect");

func _process(delta):
	var _progressTo = 0.0;
	progress = move_toward(progress, _progressTo, 0.069);
	colorRect.color.a = progress;
	
	if progress <= _progressTo:
		queue_free();

