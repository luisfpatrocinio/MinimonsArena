extends CharacterBody3D
class_name Entity
## Classe que comporta as propriedades e métodos comuns a todas as entidades do jogo: Player, Inimigos e Coletáveis.

## Sinal emitido quando a entidade está morrendo no momento em que (hp < 0_)
signal dying();

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity");
var hp = 3;

## Um vetor 3 que representa o knockback ganhado
var knockback = Vector3.ZERO

## A resistência do knockback
@export var knockbackResistence = 0.05

@export var knockbackMultipliyer = 10

func _ready():
	connect("dying", despawn);
	#createSpawnParticles()
	pass

func _physics_process(delta) -> void:
	knockback = knockback.move_toward(Vector3.ZERO, knockbackResistence)
	applyGravity(delta);
	
func applyGravity(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta;
			

func takeDamage(amount):
	if self.hp >= amount:
		hp -= amount;
		return
	dying.emit();

## Cria partículas de sumiço e se destrói.
func despawn():
	createSpawnParticles()
	queue_free();

## Create Spawn Particles
func createSpawnParticles() -> void:
	Global.levelNode.createSpawnParticles(global_position);
	pass
