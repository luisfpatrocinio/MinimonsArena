extends CharacterBody3D
class_name Entity
## Classe que comporta as propriedades e métodos comuns a todas as entidades do jogo: Player, Inimigos e Coletáveis.

## Sinal emitido quando a entidade está morrendo no momento em que (hp < 0_)
signal dying();

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity");
var hp = 3;

func _physics_process(delta) -> void:
	applyGravity(delta);
	
func applyGravity(delta):
		if not is_on_floor():
			velocity.y -= gravity * delta;
			

func takeDamage(amount):
	if self.hp > amount:
		hp -= amount;
		return
	dying.emit();
