extends RayCast3D

class_name DiceRayCast

@export var oppositeSide: int;

func _ready():
	add_exception(owner);
