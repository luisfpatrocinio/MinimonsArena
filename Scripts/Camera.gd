extends Node3D

## Camera com um SpringArm, permite alterar o zoom facilmente
class_name Camera

## Emitido quando a animação [moveTo] acaba
signal moveToFinished;


@onready var camera3d: Camera3D = $SpringArm3D/Camera3D;
@onready var springArm: SpringArm3D = $SpringArm3D;

func _ready():
	
	camera3d.look_at(springArm.global_position);

## Move o pivot da camera até o ponto especificado, também é possível atribuir uma duração da animação
func moveTo(pos: Vector3, duration: float = 1.0):
	await self.create_tween().set_trans(Tween.TRANS_QUART).tween_property(self, "global_position", pos, duration).finished;
	
	moveToFinished.emit();
	
## Recomendado usar esse pra alternar o zoom 
func setSpringLength(value: float, duration: float = 1.0):
	springArm.create_tween().set_trans(Tween.TRANS_QUART).tween_property(springArm, "spring_length", value, duration);

## Metodo de zoomIn caso precise, soma o amount ao valor atual
func zoomIn(amount: float, duration: float = 1.0):
	var _actualLen = springArm.spring_length;
	
	springArm.create_tween().set_trans(Tween.TRANS_QUART).tween_property(springArm, "spring_length", _actualLen + amount, duration);
	
## Metodo de zoomOut caso precise, subtrai o amount ao valor atual
func zoomOut(amount: float, duration: float = 1.0):
	zoomIn(-amount, duration);
