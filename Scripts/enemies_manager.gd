extends Node

class_name EnemiesManager

@export var defaultSpawnPos: Vector2 = Vector2(10, 10);

## Var temporaria: Index do modelo do inimigo, deve ser configurado de outra forma.
@export var enemyind := 1;

## Temporario
var randInd: int;

const enemyPackage: PackedScene = preload("res://Scenes/enemy.tscn");

func _ready():
	randomize();
	randInd = randi_range(1, Global.enemyDict.size());
	pass

func _process(delta):
	
	pass

## Instancia um inimigo e adiciona como filho 
func spawnEnemy(spawnPosition: Vector2 = defaultSpawnPos, modelInd: int = -1):
	
	if modelInd < 0:
		modelInd = randInd;
	
	## Mesmo que usar o instantiate, só que com parametros (e sem precisar do pacote)
	var _enemy: Enemy = enemyPackage.instantiate();
	_enemy.setEnemyModel(modelInd);
	add_child(_enemy);
	_enemy.global_position = Vector3(spawnPosition.x, 0, spawnPosition.y);
	
	## Temporario
	randInd = randi_range(1, Global.enemyDict.size());
	
	defaultSpawnPos = Vector2(
		randi_range(-10, 10),
		randi_range(-10, 10)
	)
