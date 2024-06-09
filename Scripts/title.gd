extends Node3D

var titleStep = 0;

## Caso demore a conectar, o jogador será informado que pode atravessar o bloqueio.
var waitedTooLong: bool = false;

@onready var titleLabel: Label3D = get_node("Label3D");

func _process(delta):
	match titleStep:
		0:
			if Input.is_action_just_pressed("ui_accept"):
				titleStep = 1;				
				await get_tree().create_timer(3).timeout;
				waitedTooLong = true;
		1:
			var _pointsCount = (Time.get_ticks_msec() / 500) % 4;
			
			if Connection.connected:
				titleLabel.text = "Conexão com a câmera estabelecida!";
				await get_tree().create_timer(2).timeout;
				Global.transitionTo("characterSelect");
			else:
				titleLabel.text = "Tentando conectar à câmera" + str(".").repeat(_pointsCount);
				
				if waitedTooLong:
					titleLabel.text += "\nAperte ESC para iniciar de qualquer forma."
				
				# DEBUG: Atravessar bloqueio. TODO: Retirar.
				if Input.is_action_just_pressed("ui_cancel"):
					Global.transitionTo("characterSelect");
			
			
