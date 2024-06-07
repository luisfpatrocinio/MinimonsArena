extends Node
class_name EnemiesManager

## Posição padrão de spawn de inimigos.
@export var defaultSpawnPos: Vector2 = Vector2(10, 10);

## Scene de partículas de spawn
@onready var spawnParticlesScene: PackedScene = preload("res://Scenes/spawn_particles.tscn");

## Temporario
var randInd: int;

const enemyPackage: PackedScene = preload("res://Scenes/enemy.tscn");

func _ready():
	randomize();
	randomizeSpawnSettings();

func _process(delta):
	pass

## Instancia um inimigo e adiciona como filho 
func spawnEnemy(spawnPosition: Vector2 = defaultSpawnPos, modelInd: int = -1):
	if modelInd < 0:
		modelInd = randInd;
	
	var _enemy: Enemy = enemyPackage.instantiate();
	var _monsterKey = Global.monsterDict.keys()[modelInd];
	_enemy.setEnemyModel(_monsterKey);
	add_child(_enemy);
	var _spawnPosition = Vector3(spawnPosition.x, 0, spawnPosition.y);
	_enemy.global_position = _spawnPosition;
	
	var _part = spawnParticlesScene.instantiate();
	_part.global_position = _spawnPosition;
	Global.levelNode.add_child(_part);
	
	randomizeSpawnSettings()
	
	
## Randomiza índice do monstro e posição de spawn:
func randomizeSpawnSettings() -> void:
	randInd = randi() % Global.monsterDict.size();
	defaultSpawnPos = Vector2(
		randi_range(-10, 10),
		randi_range(-10, 10)
	);
