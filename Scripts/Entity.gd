extends CharacterBody3D
class_name Entity
## Classe que comporta as propriedades e métodos comuns a todas as entidades do jogo: Player, Inimigos e Coletáveis.

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity");
var hp = 3;

func _physics_process(delta) -> void:
	applyGravity(delta);
	
func applyGravity(delta):
		if not is_on_floor():
			velocity.y -= gravity * delta;
